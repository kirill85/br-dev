CharClass = extends (ColClass) {
    renderingDistance = 100.0;
    castShadows = true;

    mass = 0;

    height = 1.8;
    radius = 0.3;
    
    camAttachPos = V_ZERO;

    walkSpeed = 10;
    runSpeed = 20;
    speedGainStep = 15;
    
    jumpVelocity = 5;

    stepHeight = 0.3;
    maxFloorGradient = 1.5;

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
    instance.jump = false
    instance.crouch = false

    instance.mass = persistent.mass
end

function CharClass.activate(persistent, instance)
    ColClass.activate(persistent, instance)

    persistent.needsStepCallbacks = true

    instance.isActor = true
    initDefaultState(persistent, instance)

    local body = instance.body
    body.ghost = true
    
    if body.mass ~= 0 then -- convert object to static
        instance.mass = body.mass -- mass info from gcol overrides class mass info
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

    local currCenter = body.worldPosition --currFoot + vector3(0,0,persistent.height/2)

    if instance.jump and not instance.offGround then
        instance.fallVelocity = persistent.jumpVelocity
    end
    instance.jump = false

    local gravity = physics_get_gravity().z
    local oldFallVelocity = instance.fallVelocity
    instance.fallVelocity = instance.fallVelocity + elapsed * gravity
    local fallVect = elapsed * vector3(0,0,instance.fallVelocity)
    local fallFraction, floorBody, floorNormal = actor_cast(currCenter, fallVect, persistent.radius - 0.01, persistent.height, body)
    local noStepUp
    if fallFraction == nil then
        instance.offGround = true
        fallFraction = 1
        
        currCenter = currCenter + fallFraction * fallVect
    else
        instance.offGround = false
        instance.fallVelocity = 0

        local groundForce = vector3(0,0,instance.mass * gravity) -- pressure to ground
        local floorImpulse = instance.mass * oldFallVelocity
        if floorImpulse ~= 0 then -- apply fall impulse to ground if any
            groundForce = groundForce + vector3(0,0,floorImpulse)
        end
        floorBody:force(groundForce, currCenter - vector3(0,0,persistent.height/2))

        noStepUp = instance.offGround --handle ground slopiness
        local floorGradient = 1/floorNormal.z
        if floorGradient < 5 and floorGradient > persistent.maxFloorGradient then
            noStepUp = true
        end
    end

    
    local moveState = vector3(instance.right - instance.left, instance.forwards - instance.backwards, 0)
    if moveState ~= V_ZERO then
        moveState = norm(moveState)

        local walkVect = (body.worldOrientation * moveState) * (instance.desiredSpeed * elapsed)
        local walkCylHeight = persistent.height - persistent.stepHeight
        local walkCylCenter = currCenter + vector3(0,0, persistent.stepHeight/2)
        if noStepUp then
            walkCylHeight = persistent.height
            walkCylCenter = currCenter
        end
        local retries, newWalkVect, collisionBody, collisionNormal, collisionPos = cast_cylinder_with_deflection(body, persistent.radius, walkCylHeight, walkCylCenter, walkVect)
        
        if collisionBody then --push the collided body in front of us
            local pushForce = (instance.desiredSpeed == persistent.runSpeed) and persistent.runPushForce or persistent.pushForce
            collisionBody:force(pushForce * -collisionNormal, collisionPos)
        end

        currCenter = currCenter + newWalkVect

        if retries and not noStepUp then
            -- just using this position is no good, will ghost through steps
            -- always adding on step_height to z is no good either -- actual step may be less than this (or zero)
            -- so we shoot a ray down to find the actual amount we have stepped up
            local stepCheckFraction = actor_cast(currCenter+vector3(0,0,persistent.stepHeight/2), vector3(0,0,-persistent.stepHeight), persistent.radius-0.01, persistent.height-persistent.stepHeight, body)
            stepCheckFraction = stepCheckFraction or 1 -- might not hit the ground due to rounding errors etc
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

