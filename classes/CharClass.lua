CharClass = extends (ColClass) {
    renderingDistance = 100.0;
    castShadows = true;

    camAttachPos = V_ZERO;

    mass = 0;
    height = 1.8; -- parameters for casted cylinder
    radius = 0.3;
    
    walkSpeed = 5;
    runSpeed = 10;
    speedGainStep = 8; -- speed to gain per second (simply acceleration)
    strafeRun = false; --allow strafe running bug? http://en.wikipedia.org/wiki/Strafe_run#Straferunning

    jumpsAllowed = 2; -- how much jumps allowed in a row, before landing again (2 = aka double jump)
    jumpsIfFall = false; --allow air jumps if player just fall off the ground? (false = preventing player to save himself from fall damage by extra air jump before hit the ground)
    jumpVelocity = 5;
    jumpOffGroundTimeThreshold = 0.1; -- time since gone off ground when jumps still allowed (helps to fix unvailability of jump on small bumps)

    stepHeight = 0.3;
    floorAngleThreshold = 48; --FIXME: take most common apropriate value, and remove this extra variable
    slopeLimit = 50; -- maximum walkable slope angle

    --antiBump helps to cope "bumping" effect when walking down slopes
    antiBumpAngleThreshold = 5; -- walking on slopes steeper than that will activate "bump effect" suppression
    antiBumpFactor = 0.75; --between 0 and 1, the lower the value, the more bumps

    pushForce = 1000; --TODO: should be mass dependent
    runPushForce = 1500; --TODO: should be mass dependent
}

local function initDefaultState(persistent, instance)
    instance.forwards = 0
    instance.backwards = 0
    instance.left = 0
    instance.right = 0
    instance.currVelocity = 0
    instance.desiredSpeed = persistent.walkSpeed
    instance.lastMoveDirection = V_ZERO
    instance.fallVelocity = 0
    instance.offGround = false
    instance.jumpsDone = 0
    instance.jump = false
    instance.crouch = false
    instance.useAntiBump = false
    instance.timeSinceOffGround = 0 --TODO: replace offGround state with this, or if the "can't jump on light bumps" bug gets fixed, simply remove this one
end

function CharClass.activate(persistent, instance)
    ColClass.activate(persistent, instance)

    persistent.needsStepCallbacks = true

    instance.isActor = true
    initDefaultState(persistent, instance)

    local body = instance.body
    body.ghost = true
    
    if body.mass ~= 0 then -- convert object to static
        persistent.mass = body.mass -- mass info from gcol overrides class mass info
        body.mass = 0
    end

    local old_update_callback = body.updateCallback
    body.updateCallback = function (p,q)
        old_update_callback(p,q)
        instance.camAttachPos = body:localToWorld(persistent.camAttachPos)
    end
end;

function CharClass.deactivate(persistent)
    persistent.needsStepCallbacks = false;
    ColClass.deactivate(persistent)
end;

local function actor_cast (pos, ray, radius, height, body)
    --return physics_sweep_sphere(radius, pos, ray, true, 0, body)
    return physics_sweep_cylinder(radius, height, quat(1,0,0,0), pos, ray, true, 0, body)
end
local function vector_without_component (v, n)
    return v - dot(v, n) * n
end
local function cast_cylinder_with_deflection (body, radius, height, pos, movement)
    --echo("cast with "..pos)

    local ret_body, ret_normal, ret_pos

    for i = 0,4 do
    
        local walk_fraction, wall, wall_normal = actor_cast(pos, movement, radius - i*0.0005, height - 0.0001, body)
        if walk_fraction ~= nil then
            if ret_body == nil then
                ret_body = wall
                ret_normal = wall_normal
                ret_pos = pos + walk_fraction*movement
            end
            wall_normal = wall_normal * vector3(1,1,0) 
            if wall_normal ~= V_ZERO then wall_normal=norm(wall_normal) end
            movement = movement*walk_fraction + vector_without_component(movement*(1-walk_fraction), wall_normal)
        else
            return i, movement, ret_body, ret_normal, ret_pos
        end 
    end 
    
    return false, V_ZERO, ret_body, ret_normal, ret_pos
end


function CharClass.stepCallback(persistent, elapsed) --FIXME: this is very rough code, must be refactored hard in the future
    local instance = persistent.instance
    local body = instance.body

    body.worldOrientation = quat(player_ctrl.camYaw, V_DOWN) -- aling body orientation to camera yaw

    local currCenter = body.worldPosition -- assumes origin of body at bounding box center

    if instance.jump then
        if instance.offGround and (instance.timeSinceOffGround > persistent.jumpOffGroundTimeThreshold) then
            if instance.jumpsDone < persistent.jumpsAllowed then --check if we have ability to jump in air (aka double-jump)
                instance.fallVelocity = persistent.jumpVelocity
                instance.jumpsDone = instance.jumpsDone + 1
            end
        else
            instance.fallVelocity = persistent.jumpVelocity
            instance.jumpsDone = 1
        end
        if instance.timeSinceOffGround > persistent.jumpOffGroundTimeThreshold then
            instance.jump = false
        end
    end

    local gravity = physics_get_gravity().z
    local oldFallVelocity = instance.fallVelocity
    instance.fallVelocity = instance.fallVelocity + elapsed * gravity
    local fallVect = elapsed * vector3(0,0,instance.fallVelocity)
    local fallFraction, floorBody, floorNormal = actor_cast(currCenter, fallVect, persistent.radius - 0.01, persistent.height, body)
    local stepUp
    if fallFraction == nil then -- we are in mid air
        instance.offGround = true
        instance.antiBump = false
        instance.jump = false
        stepUp = false
        instance.timeSinceOffGround = instance.timeSinceOffGround + elapsed
        if instance.jumpsDone == 0 then -- we just fall off, no air jumps allowed
            if not persistent.jumpsIfFall then
                instance.jumpsDone = persistent.jumpsAllowed
            end
        end

        currCenter = currCenter + fallVect
    else -- we are on ground
        instance.timeSinceOffGround = 0
        --first, handle ground slopiness
        local surfaceAngle = 90-math.deg(math.asin(floorNormal.z)) 

        --FIXME: I guess this can be removed
        --if surfaceAngle < 78 and surfaceAngle > persistent.floorAngleThreshold then
            -- don't check for step if the surface is too smooth??
            --stepUp = false
        --end
        if surfaceAngle > persistent.slopeLimit then --slide down the slopes above the slope limit
            --sliding at the speed of gravity
            -- FIXME: there is a chance to penetrate ground while sliding
            currCenter = currCenter + quat(90, norm(cross(fallVect, floorNormal))) * floorNormal * gravity * elapsed
            instance.offGround = true
            stepUp = false
        else --tell that we're purely on ground
            instance.offGround = false
            instance.fallVelocity = 0
            instance.jumpsDone = 0
            stepUp = true
            if surfaceAngle > persistent.antiBumpAngleThreshold then
                instance.useAntiBump = true
            else
                instance.useAntiBump = false
            end
        end

        --even if we're sliding on slope, we still apllying force down to the ground surface
        local groundForce = vector3(0,0,persistent.mass * gravity) -- pressure to ground
        local floorImpulse = persistent.mass * oldFallVelocity
        if floorImpulse ~= 0 then -- apply fall impulse to ground if any
            groundForce = groundForce + vector3(0,0,floorImpulse)
        end
        floorBody:force(groundForce, currCenter - vector3(0,0,persistent.height/2)) --force to ground at foot position
    end
    
    local antiBumpState = (instance.useAntiBump and instance.jumpsDone == 0) and -persistent.antiBumpFactor or 0 --applying antibump factor if needed, also trying to avoid jump suppression here
    local moveState = vector3(instance.right - instance.left, instance.forwards - instance.backwards, antiBumpState)
    if moveState ~= V_ZERO then
        if not persistent.strafeRun then
            moveState = norm(moveState)
        end
        
        local walkVect = (body.worldOrientation * moveState) * (instance.desiredSpeed * elapsed)
        local walkCylHeight = stepUp and persistent.height - persistent.stepHeight or persistent.height
        local walkCylCenter = stepUp and currCenter + vector3(0,0, persistent.stepHeight/2) or currCenter
        
        local retries, newWalkVect, collisionBody, collisionNormal, collisionPos = cast_cylinder_with_deflection(body, persistent.radius, walkCylHeight, walkCylCenter, walkVect)
        
        if collisionBody then --push the collided body in front of us
            local pushForce = (instance.desiredSpeed == persistent.runSpeed) and persistent.runPushForce or persistent.pushForce
            collisionBody:force(pushForce * -collisionNormal, collisionPos)
        end

        currCenter = currCenter + newWalkVect

        if retries and stepUp then
            -- just using this position is no good, will ghost through steps
            -- always adding on step_height to z is no good either -- actual step may be less than this (or zero)
            -- so we shoot a ray down to find the actual amount we have stepped up
            local stepCheckFraction = actor_cast(currCenter+vector3(0,0,persistent.stepHeight/2), vector3(0,0,-persistent.stepHeight), persistent.radius-0.01, persistent.height-persistent.stepHeight, body)
            -- substraction of 0.01 from stepCheckFraction roughly fixes "trip on stairs" problem
            stepCheckFraction = stepCheckFraction and stepCheckFraction--[[-0.01--]] or 1 -- might not hit the ground due to rounding errors etc
            local actualStepHeight = persistent.stepHeight*(1-stepCheckFraction)

            -- if we have an upwards velocity, work out if we would have made the step or not
            -- if not, set velocity to 0 so that we don't give an unnatural boost
            local parabolicHeight = instance.fallVelocity^2  / 2 / gravity
            if parabolicHeight > 0 and parabolicHeight <  actualStepHeight then
                instance.fallVelocity = 0
            end

            currCenter = currCenter + vector3(0,0, actualStepHeight)
        end
    end

    body.worldPosition = currCenter
end;

function CharClass:setForwards(v)
    self.instance.forwards = v and 1 or 0
end;
function CharClass:setBackwards(v)
    self.instance.backwards = v and 1 or 0
end;
function CharClass:setStrafeLeft(v)
    self.instance.left = v and 1 or 0
end;
function CharClass:setStrafeRight(v)
    self.instance.right = v and 1 or 0
end;
function CharClass:setRun(v)
    self.instance.desiredSpeed = v and self.runSpeed or self.walkSpeed
end;
function CharClass:setCrouch(v)
    self.instance.crouch = v
end;
function CharClass:setJump(v)
    self.instance.jump = v
end;

