CharClass = extends (ColClass) {
    renderingDistance = 100.0;
    castShadows = true;

    camAttachPos = V_ZERO;

    mass = 0;
    height = 1.8; -- parameters for casted cylinder
    radius = 0.3;
    
    walkSpeed = 10;
    runSpeed = 20;
    speedGainStep = 15; -- speed to gain per second (simply acceleration)
    strafeRun = false; --allow strafe running bug? http://en.wikipedia.org/wiki/Strafe_run#Straferunning


    jumpsAllowed = 2; -- how much jumps allowed in a row, before landing again (2 = aka double jump)
    jumpVelocity = 5;

    stepHeight = 0.3;
    floorAngleThreshold = 48; --FIXME: take most common apropriate value, and remove this extra variable
    slopeLimit = 50; -- maximum walkable slope angle

    pushForce = 1000;
    runPushForce = 1500;
}

local function initDefaultState(persistent, instance)
    instance.forwards = 0
    instance.backwards = 0
    instance.left = 0
    instance.right = 0
    instance.currSpeed = 0
    instance.desiredSpeed = persistent.walkSpeed
    instance.lastMoveDirection = V_ZERO
    instance.fallVelocity = 0
    instance.offGround = false
    instance.jumpsDone = 0
    instance.jump = false
    instance.crouch = false
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
            wall_normal = norm(wall_normal * vector3(1,1,0))
            movement = movement*walk_fraction + vector_without_component(movement*(1-walk_fraction), wall_normal)
        else
            return i, movement, ret_body, ret_normal, ret_pos
        end 
    end 
    
    return false, V_ZERO, ret_body, ret_normal, ret_pos
end


function CharClass.stepCallback(persistent, elapsed)
    local instance = persistent.instance
    local body = instance.body

    body.worldOrientation = quat(player_ctrl.camYaw, V_DOWN) -- aling body orientation to camera yaw

    local currCenter = body.worldPosition -- assumes origin of body at bounding box center

    if instance.jump then
        if instance.offGround then
            if instance.jumpsDone < persistent.jumpsAllowed then --check if we have ability to jump in air (aka double-jump)
                instance.fallVelocity = persistent.jumpVelocity
                instance.jumpsDone = instance.jumpsDone + 1

            end
        else
            instance.fallVelocity = persistent.jumpVelocity
            instance.jumpsDone = 1
        end
        instance.jump = false
    end
    

    local gravity = physics_get_gravity().z
    local oldFallVelocity = instance.fallVelocity
    instance.fallVelocity = instance.fallVelocity + elapsed * gravity
    local fallVect = elapsed * vector3(0,0,instance.fallVelocity)
    local fallFraction, floorBody, floorNormal = actor_cast(currCenter, fallVect, persistent.radius - 0.01, persistent.height, body)
    local stepUp
    if fallFraction == nil then -- we are in mid air
        instance.offGround = true
        stepUp = false
        fallFraction = 1
        
        currCenter = currCenter + fallFraction * fallVect
    else -- we are on ground
        instance.offGround = false
        stepUp = true
        instance.fallVelocity = 0

        local groundForce = vector3(0,0,persistent.mass * gravity) -- pressure to ground
        local floorImpulse = persistent.mass * oldFallVelocity
        if floorImpulse ~= 0 then -- apply fall impulse to ground if any
            groundForce = groundForce + vector3(0,0,floorImpulse)
        end
        floorBody:force(groundForce, currCenter - vector3(0,0,persistent.height/2)) --force to ground at foot position

        --handle ground slopiness
        local surfaceAngle = 90-math.deg(math.asin(floorNormal.z)) 
        if surfaceAngle < 78 and surfaceAngle > persistent.floorAngleThreshold then
            -- don't check for step if the surface is too smooth
            stepUp = false
        end
        if surfaceAngle > persistent.slopeLimit then 
            --slide down the slopes above the slope limit
            currCenter = currCenter + quat(90, norm(cross(fallVect, floorNormal))) * floorNormal * gravity * elapsed
            --instance.offGround = true
            instance.stepUp = false
        end
    end
    
    local moveState = vector3(instance.right - instance.left, instance.forwards - instance.backwards, 0)
    if moveState ~= V_ZERO then
        if not persistent.strafeRun then
            moveState = norm(moveState)
        end

        local walkVect = (body.worldOrientation * moveState) * (instance.desiredSpeed * elapsed)
        local walkCylHeight = persistent.height - persistent.stepHeight
        local walkCylCenter = currCenter + vector3(0,0, persistent.stepHeight/2)
        if not stepUp then
            walkCylHeight = persistent.height
            walkCylCenter = currCenter
        end
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

            --echo('actual step height:'..actual_step_height)
            currCenter = currCenter + vector3(0,0, actualStepHeight)
        end

        --currCenter = currCenter + (body.worldOrientation * moveState) * (instance.desiredSpeed * elapsed)
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

