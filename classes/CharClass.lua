--TODO: rewrite this to be compatible with other directions (sideways, and upwards) of gravity

CharClass = extends(ColClass) {
    renderingDistance = 100;
    castShadows = true;

    height = 1.8;
    radius = 0.3;

    mass = 80; --TODO: deduce from attached model's gcol body?

    camHeight = 1.4; --TODO: should use more exact position

    walkSpeed = 5;
    runSpeed = 8;

    stepHeight = 0.25;
    jumpVelocity = 3; --TODO: should use the jump height instead

    pushForce = 750; --TODO: make something about this later, maybe use a mass dependent multiplier constant?
    runPushForce = 1000;
}

function CharClass.activate(persistent, instance)
    ColClass.activate(persistent, instance)
    persistent.needsStepCallbacks = true
    
    local body = instance.body
    
    instance.isActor = true

    instance.forwards = false
    instance.backwards = false
    instance.strafeLeft = false
    instance.strafeRight = false
    instance.run = false
    instance.crouch = false
    instance.jump = false

    body.ghost = true

    local super = body.updateCallback
    body.updateCallback = function(p,q)
        super(p,q)
        instance.camAttachPos = p + vector3(0,0,persistent.camHeight)
    end
end

function CharClass.deactivate(persistent)
    persistent.needsStepCallbacks = false
    ColClass.deactivate(persistent)
end

function CharClass:abandon()
    self.instance.forwards = false
    self.instance.backwards = false
    self.instance.strafeLeft = false
    self.instance.strafeRight = false
    self.instance.run = false
    self.instance.crouch = false
    self.instance.jump = false
end

function CharClass.stepCallback(persistent, elapsed)
    local instance = persistent.instance
    local body = instance.body

    local curr_foot = body.worldPosition
    local height = persistent.height
    local half_height = persistent.height/2
    local curr_center = curr_foot + vector3(0,0,half_height)

    local radius = persistent.radius

    local gravity = physics_get_gravity().z

end

function CharClass:setForwards(v)
    self.instance.forwards = v
end
function CharClass:setBackwards(v)
    self.instance.backwards = v
end
function CharClass:setStrafeLeft(v)
    self.instance.strafeLeft = v
end
function CharClass:setStrafeRight(v)
    self.instance.strafeRight = v
end
function CharClass:setRun(v)
    self.instance.run = v
end
function CharClass:setCrouch(v)
    self.instance.crouch = v
end
function CharClass:setJump(v)
    self.instance.jump = v
end
