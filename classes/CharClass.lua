CharClass = extends (ColClass) {
    renderingDistance = 100;
    castShadows = true;

    height = 1.8;
    radius = 0.3;
    
    camAttachPos = V_ZERO;

    walkSpeed = 1.4; -- measured in meters per second
    runSpeed = 7;
    speedGainStep = 1;

    --footPos = vector(0,0,-0.5) -- example how to override foot position
    
    terminalVelocity = 20;
    mass = 80;
    maxGradient = 1.5;
}

local function initDefaultState(persistent, instance)
    instance.forwards = 0
    instance.backwards = 0
    instance.strafeLeft = 0
    instance.strafeRight = 0
    instance.desiredSpeed = persistent.walkSpeed
    instance.currentSpeed = 0
    instance.jump = false
    instance.crouch = false

    instance.fallVelocity = 0
end

function CharClass.activate(persistent, instance)
    ColClass.activate(persistent, instance)
    persistent.needsStepCallbacks = true

    instance.isActor = true
    initDefaultState(persistent, instance)

    local body = instance.body
    body.ghost = true

    local old_update_callback = body.updateCallback
    body.updateCallback = function (p,q)
        old_update_callback(p,q)
        instance.camAttachPos = body:localToWorld(persistent.camAttachPos)
    end
end

function CharClass.deactivate(persistent, instance)
    ColClass.deactivate(persistent)
    persistent.needsStepCallbacks = false
end

local function actor_cast (pos, ray, radius, height, body)
        return physics_sweep_cylinder(radius, height, quat(1,0,0,0), pos, ray, true, 0, body)
end
local function vector_without_component (v, n)
    return v - dot(v, n) * n
end
local function cast_cylinder_with_deflection (body, radius, height, pos, movement)
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

    --echo('-------------')

    -- check foot and height at source
    -- check pat to destination above step hieght
    -- 
    local curr_foot = persistent.footPos and body:localToWorld(persistent.footPos) or body.worldPosition
    local height = persistent.height
    local half_height = persistent.height/2
    local curr_centre = curr_foot + vector3(0,0,half_height)

    local radius = persistent.radius

    if instance.jumpHappened and not instance.offGround then
        instance.fallVelocity = persistent.jumpVelocity
        instance.jumpHappened = false
    end

    local gravity = physics_get_gravity().z

    local old_fall_velocity = instance.fallVelocity
    instance.fallVelocity = instance.fallVelocity + elapsed * gravity
    if instance.fallVelocity > persistent.terminalVelocity then
        instance.fallVelocity = persistent.terminalVelocity
    end

    --echo('fallVelocity: '..instance.fallVelocity)

    -- FALL / JUMP
    -- shoot sphere from centre of capsule
    local fall_vect = elapsed * vector3(0,0,instance.fallVelocity)
    local fall_fraction, floor, floor_normal = actor_cast(curr_centre, fall_vect, radius - 0.01, height, body)
    local floor_impulse = 0
    if fall_fraction == nil then
        instance.offGround = true
        fall_fraction = 1
    else
        instance.offGround = false
        floor_impulse = persistent.mass * old_fall_velocity
        instance.fallVelocity = 0
    end
    --echo('fall_dist: '..(fall_fraction * fall_vect).."  off_ground: "..tostring(instance.offGround))
    curr_foot = curr_foot + fall_fraction * fall_vect

    local no_step_up = instance.offGround

    if not instance.offGround then
        local floor_gradient = 1/floor_normal.z
        -- special case for vertical walls -- helps going up steps
        if floor_gradient < 5 and floor_gradient > persistent.maxGradient then
            no_step_up = true
        end

        -- apply force to ground
        --gravity
        local ground_force = vector3(0,0,persistent.mass * gravity)
        ground_force = math.min(#ground_force, floor.mass * 5) * norm(ground_force)
        floor:force(ground_force, curr_foot)
        if floor_impulse ~= 0 then
            --landing force
            local ground_impulse = vector3(0,0, floor_impulse)
            ground_impulse = math.min(#ground_impulse, floor.mass * elapsed * 100) * norm(ground_impulse)
            floor:impulse(ground_impulse, curr_foot)
        end
    end



    -- WALK/STRAFE in a given direction
    instance.localMove = instance.localMoveIntended
    if instance.moving then
        local speed = (instance.runState and persistent.runSpeed or persistent.walkSpeed) * elapsed
        local walk_dir = quat(player_ctrl.camYaw, V_DOWN)
        local walk_vect = speed * (walk_dir * norm(instance.localMove))
        if #walk_vect > 0.003 then
            body.worldOrientation = quat(V_FORWARDS, norm(walk_vect))
        end

        local step_height = persistent.stepHeight

        local walk_cyl_height = height - step_height
        local walk_cyl_centre = curr_centre + vector3(0,0,step_height/2)
        if no_step_up then
            walk_cyl_height = height
            walk_cyl_centre = curr_centre
        end
        local retries, new_walk_vect, collision_body, collision_normal, collision_pos = cast_cylinder_with_deflection(body, radius, walk_cyl_height, walk_cyl_centre, walk_vect)

        if collision_body then
            local push_force = instance.runState and persistent.runPushForce or persistent.pushForce
            local magnitude = math.min(persistent.pushForce, collision_body.mass * 15) * -collision_normal
            collision_body:force(magnitude, collision_pos)
        end
        --echo('first walk test:   retries: '..tostring(retries).." tried_vect:"..walk_vect.."  vect:"..new_walk_vect)

        curr_foot = curr_foot + new_walk_vect
        curr_centre = curr_foot + vector3(0,0,height/2)

        if retries and not no_step_up then
            -- just using this position is no good, will ghost through steps
            -- always adding on step_height to z is no good either -- actual step may be less than this (or zero)
            -- so we shoot a ray down to find the actual amount we have stepped up
            local step_check_fraction = actor_cast(curr_centre+vector3(0,0,step_height/2), vector3(0,0,-step_height), radius-0.01, height-step_height, body)
            step_check_fraction = step_check_fraction or 1 -- might not hit the ground due to rounding errors etc
            local actual_step_height = step_height*(1-step_check_fraction)

            -- if we hvae an upwards velocity, work out if we would have made the step or not
            -- if not, set velocity to 0 so that we don't give an unnatural boost
            local parabolic_height = instance.fallVelocity^2  / 2 / gravity
            --echo("fail", instance.fallVelocity, parabolic_height, actual_step_height)
            if parabolic_height > 0 and parabolic_height <  actual_step_height then
                instance.fallVelocity = 0
            end

            --echo('actual step height:'..actual_step_height)
            curr_foot = curr_foot + vector3(0,0, actual_step_height)
        end

    end

    
    body.worldPosition = curr_foot
end

function CharClass:setForwards(v)
    self.instance.forwards = v and 1 or 0
end
function CharClass:setBackwards(v)
    self.instance.backwards = v and 1 or 0
end
function CharClass:setStrafeLeft(v)
    self.instance.strafeLeft = v and 1 or 0
end
function CharClass:setStrafeRight(v)
    self.instance.strafeRight = v and 1 or 0
end
function CharClass:setRun(v)
    self.instance.desiredSpeed = v and self.runSpeed or self.walkSpeed
end
function CharClass:setCrouch(v)
    self.instance.crouch = v
end
function CharClass:setJump(v)
    self.instance.jump = v
end
