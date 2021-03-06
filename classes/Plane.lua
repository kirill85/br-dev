Plane = extends (ColClass) {
    castShadows = true;
    renderingDistance = 200;

    cameraTrack = true;

    maxThrust = {};
    currentThrust = {};
    targetThrust = {};
    --stepThrust = 100;
    stepThrust = 25;
    
    --TODO: implement custom per-engine settings
    maxNegativeThrust = -1000;

    liftCurves = {};
    dragCurves = {};
    pressureCenters = {};
    actionVectors = {};
    glideRatios = {};
    controlTypes = {};
    aoaLimits = {};
    lastaoa = {};
    lastlift = {};
    lastdrag = {};

    rotorCurves = {};
    rotorGlide = {};
    rotorAction = {};
    rotorPressure = {};
    rotorControl = {};
    rotorRPM = {};
    rotorRad = {};

    --Shamelessly copied from vehicle base.
    steerMax = 1;
    steerRate = 0.03;
    unsteerRate = 0.06;

    steerFastSpeed = 50;

    steerMaxFast = 0.4;
    steerRateFast = 0.01;
    unsteerRateFast = 0.04;

    trailSmokePos = vector3(0,-2,0);

    health = 50000;
    --health = 25000;
    impulseDamageThreshold=1000;
    explodeInfo = { radius = 10; };

    wheelSpinTractionControlMax = 1;
    wheelSpinTractionControlRate = 4;
    wheelSpinTractionControlMin = 0.01;

    smokeSystemArg = { longevity=2, grow=2, startAlpha=1, period=20 };
    lightSystemArg = { longevity=0, grow=0, startAlpha=1, period=0 };

    brakePlot = { [-10] = 100; [0] = 100; [10] = 2500; [20] = 2500; [40] = 2500; };
}

function Plane.init(persistent)
    ColClass.init(persistent)
end

function Plane.activate (persistent,instance)
    if ColClass.activate(persistent,instance) then
        return true
    end

    persistent.needsFrameCallbacks = true
    persistent.needsStepCallbacks = true

    instance.push = 0
    instance.parked = true
    instance.canDrive = true

    -- 0 means retracted, 1 means down
    instance.gearState = 0.999
    instance.desiredGearState = 1
    local f = function (k,v) return instance.gfx:getBoneId(k), v end
    instance.gearDoors = tabmap(persistent.gearDoors or {}, f)
    instance.gearStruts = tabmap(persistent.gearStruts or {}, f) 
    instance.gearStrutNames = tabmap(persistent.gearStruts or {}, function (k,v) return instance.gfx:getBoneId(k), k end)

    instance.altHackTimer=0

    instance.numWheels = 0
    if persistent.bonedWheelInfo then
            for k, info in pairs(persistent.bonedWheelInfo) do
                    instance.numWheels = instance.numWheels + 1
            end
    end
    if persistent.meshWheelInfo then
            for k, info in pairs(persistent.meshWheelInfo) do
                    instance.numWheels = instance.numWheels + 1
            end
    end

    local mpw = 0
    if instance.numWheels > 0 then mpw = instance.body.mass/instance.numWheels end

    instance.steer, instance.shouldSteerLeft, instance.shouldSteerRight = 0, 0, 0 
    instance.tractionControl = 1

    instance.maxThrust={}
    instance.currentThrust={}
    instance.targetThrust={}
    instance.stepThrust=persistent.stepThrust
    instance.maxNegativeThrust = persistent.maxNegativeThrust

    --Engine defs go here.
    for i,tp in ipairs(persistent.thrustPlots) do
        instance.maxThrust[i]=Plot(tp)
        instance.currentThrust[i] = 0.0
        instance.targetThrust[i] = 0.0
    end

    instance.liftCurves = {};
    instance.dragCurves = {};
    instance.pressureCenters = {};
    instance.actionVectors = {};
    instance.glideRatios = {};
    instance.aoaLimits = {};
    instance.controlTypes = {};
    instance.lastaoa = {};
    instance.lastlift = {};
    instance.lastdrag = {};

    instance.smokeTimer=0
    
    --[[
    instance.lightSystem = sm:createParticleSystem(persistent.name..":LightParticleSystem")
    instance.gfx:attachObject(instance.lightSystem)
    instance.lightSystem.materialName = "common/particles/Light"
    instance.lightSystem:update(0)
    --]]

    --Surface defs here.
    for i, info in ipairs(persistent.surfaceInfo) do
        instance.liftCurves[i]=Plot(info.lift)
        instance.dragCurves[i]=Plot(info.drag)
        instance.pressureCenters[i]=info.cpr
        instance.actionVectors[i]=info.act
        instance.glideRatios[i]=info.glide
        instance.controlTypes[i]=info.ctype
        instance.aoaLimits[i]=info.limitAoA
        instance.lastaoa[i] = 0.0
        instance.lastlift[i] = 0.0
        instance.lastdrag[i] = 0.0
    end

    instance.rotorCurves={}
    instance.rotorPressure={}
    instance.rotorAction={}
    instance.rotorRPM={}
    instance.rotorRad={}
    instance.rotorGlide={}
    instance.rotorControl={}
    instance.rotorCyclicX={}
    instance.rotorCyclicY={}

    instance.collective=0.5
    instance.collectiveStep=0.025
    instance.collectiveTarget=0

    instance.cyclicx=0
    instance.cyclicy=0
    instance.cyclicxTarget=0
    instance.cyclicyTarget=0
    instance.cyclicStep=0.1

    for i, info in ipairs(persistent.rotorInfo) do
        instance.rotorCurves[i]=Plot(info.lift)
        instance.rotorPressure[i]=info.cpr
        instance.rotorAction[i]=info.act
        instance.rotorRPM[i]=info.rpm
        instance.rotorRad[i]=info.diameter/3
        instance.rotorGlide[i]=info.glide
        instance.rotorCyclicX[i]=info.cyclicx
        instance.rotorCyclicY[i]=info.cyclicy
        instance.rotorControl[i]=info.ctype
    end

    instance.lights = {}
    --[[    
    for i, info in ipairs(class.lightInfo) do
        instance.lights[i]={}
        instance.lights[i].pos=info.pos
        instance.lights[i].rad=info.rad
        instance.lights[i].color=info.color
    end
    --]]

    instance.pitch, instance.pitchUp, instance.pitchDown=0,0,0
    instance.roll, instance.rollLeft, instance.rollRight=0,0,0

    instance.brakeCurve = Plot (persistent.brakePlot)

    instance.wheels = {}
    instance.drivenWheels = {}
    instance.handbrakeWheels = {}

    for name, info in pairs(persistent.bonedWheelInfo) do
                local wmass = (info.massShare or 1) * mpw
                if info.mu ~= nil then info.driveMu = info.mu ; info.sideMu = info.mu end
                instance.wheels[name] = WheelAssembly.newBoned(name, persistent, wmass, info)
                instance.wheels[name].steerFactor = info.steer or 0
                instance.wheels[name].drive = false

                if info.handbrake then table.insert(instance.handbrakeWheels,instance.wheels[name]) end
        end

        local last_callback = instance.body.updateCallback
    instance.body.updateCallback = function (p,q)
                last_callback(p,q)
                for _,wheel in pairs(instance.wheels) do
                        wheel:updateGFX()
                end
        end


end

function Plane.stepCallback(persistent, elapsed)

    local instance = persistent.instance 

    local body = instance.body
    local velocity = body.linearVelocity
    local speed = #velocity

    local av = body.angularVelocity
    body:torque(-1.5 * av)
    body:torque(-2.0*dot(av, av) * av)

    --Process thrust.
    local thrust
    for i,tp in ipairs(instance.targetThrust) do
        if instance.targetThrust[i] > instance.currentThrust[i] then
            instance.currentThrust[i] = instance.currentThrust[i] + instance.stepThrust

            --hack to prevent unwanted thrust                
            if instance.currentThrust[i]>instance.targetThrust[i] then
                instance.currentThrust[i]=instance.targetThrust[i]                
            end
        elseif instance.targetThrust[i] < instance.currentThrust[i] then
            instance.currentThrust[i] = instance.currentThrust[i] - instance.stepThrust

            --hack to prevent unwanted thrust                
            if instance.currentThrust[i]<instance.targetThrust[i] then
                instance.currentThrust[i]=instance.targetThrust[i]                
            end
        end

        --adjust currentThurst accordingly to the thrust curve
        if instance.targetThrust[i] > 0 and instance.currentThrust[i] > instance.maxThrust[i][#instance.body.linearVelocity] then
            instance.currentThrust[i] = instance.maxThrust[i][#instance.body.linearVelocity]
        end

        --print("Process__thrust", i, instance.currentThrust[i])
        thrust = body.worldOrientation * vector3(0, instance.currentThrust[i], 0)
        --print("Engine",i,thrust,body.worldPosition)
        body:force(thrust, body.worldPosition + body.worldOrientation*vector3(0,5,0))

    end

    instance.pitch=instance.pitchDown-instance.pitchUp
    instance.roll=instance.rollRight-instance.rollLeft

    --Process lift.
    local lift
    local drag
    local speedx
    local speedy
    local aoa
    local speed2
    local pos=vector3(0, 0, 0)
    local pvel
    local s
    local glide
    for s, glide in ipairs(instance.glideRatios) do
        local pcent = body.worldOrientation * instance.pressureCenters[s]
        pvel=body:getLocalVelocity(pcent, false)
        speedx = dot(pvel, body.worldOrientation * vector3(0,-1,0))
        speedy = dot(pvel, body.worldOrientation * instance.actionVectors[s])
        pvel = speedx * (body.worldOrientation * vector3(0,-1,0)) + speedy * (body.worldOrientation * instance.actionVectors[s])
        speed2 = speedx*speedx + speedy*speedy
        if speed2 > 0 then
            aoa = -dot(norm(pvel), body.worldOrientation * instance.actionVectors[s])

            if instance.controlTypes[s]=="rudder" then aoa=aoa+instance.steer/300.0 end
            if instance.controlTypes[s]=="elevator" then aoa=aoa+instance.pitch end
            if instance.controlTypes[s]=="lwing" then aoa=aoa+instance.roll end
            if instance.controlTypes[s]=="rwing" then aoa=aoa-instance.roll end
            instance.lastaoa[s]=aoa

            if aoa > 0.8 then aoa=0.8 end
            if aoa < -0.8 then aoa=-0.8 end

            --print("Surface",s,aoa,speed2)

            lift = speed2 * instance.liftCurves[s][aoa]
            if aoa < instance.aoaLimits[s][1] or aoa > instance.aoaLimits[s][2] then lift = 0 end
            drag = speed2 * instance.dragCurves[s][math.abs(aoa)] / glide
            pos = body.worldOrientation * instance.pressureCenters[s] + body.worldPosition
            body:force(lift*(body.worldOrientation * instance.actionVectors[s]), pos)
            body:force(-drag*norm(pvel), pos)

            instance.lastlift[s]=lift
            instance.lastdrag[s]=drag

            --print("Surface",s,aoa)
            --print("Surface", s, lift*(body.worldOrientation * instance.actionVectors[s]))
        end
    end

    --Process Rotors.
    if instance.collective<instance.collectiveTarget then instance.collective=instance.collective+instance.collectiveStep end
    if instance.collective>instance.collectiveTarget then instance.collective=instance.collective-instance.collectiveStep end

    if instance.cyclicx<instance.cyclicxTarget then instance.cyclicx=instance.cyclicx+instance.cyclicStep end
    if instance.cyclicx>instance.cyclicxTarget then instance.cyclicx=instance.cyclicx-instance.cyclicStep end
    if instance.cyclicy<instance.cyclicyTarget then instance.cyclicy=instance.cyclicy+instance.cyclicStep end
    if instance.cyclicy>instance.cyclicyTarget then instance.cyclicy=instance.cyclicy-instance.cyclicStep end

    local rtorque
    local wr,v2
    local act
    for s, glide in ipairs(instance.rotorGlide) do
        rtorque=0
        lift=0
        wr = instance.rotorRPM[s] * instance.rotorRad[s] * 0.104719755
        local ps = body.worldOrientation * instance.rotorPressure[s]
        pvel=body:getLocalVelocity(ps, false)
        act=body.worldOrientation*instance.rotorAction[s]
        pvel=dot(act,pvel) * act
        if instance.rotorControl[s] == "rotor" then
            v2 = pvel.x*pvel.x + pvel.vy*pvel.vy
            --Lift and position should be adjsuted for cyclic and wind.
            lift = instance.rotorCurves[s][instance.collective]
            --Needs fix for negative RPM
            rtorque = - (lift/glide)*instance.rotorRad[s]
            pos = body.worldPosition + body.worldOrientation * instance.rotorPressure[s]
            --Cyclic Control.
            pos = pos + instance.cyclicx*(body.worldOrientation*instance.rotorCyclicX[s])
            pos = pos + instance.cyclicy*(body.worldOrientation*instance.rotorCyclicY[s])

            --print("Rotor",instance.cyclicx,instance.cyclicy)
        end
        if instance.rotorControl[s] == "torque" then
            aoa=.5-instance.steer/(2*persistent.steerMax)
            if aoa<0 then aoa=0 end
            if aoa>1 then aoa=1 end
            lift = instance.rotorCurves[s][aoa]
            rtorque=0
            pos = body.worldPosition + body.worldOrientation * instance.rotorPressure[s]
        end
        --print("Rotor",s)

        if instance.parked then
            lift=0
            rtorque=0
        end
            
        body:force(lift*(body.worldOrientation * instance.rotorAction[s]), pos)
        body:torque(rtorque * body.worldOrientation * instance.rotorAction[s])
    end

    --Mark with smoke
    local arg = persistent.smokeSystemArg
    if instance.trailingSmoke then
        pos = body:localToWorld(persistent.trailSmokePos)
        local vel = random_vector3_box(vector3(-0.2,-0.2,0),vector3(0.2,0.2,0.6))
        local sz = 0.5+math.random()
        emit_textured_smoke(pos, vel, sz, sz, vector3(1,1,1))
    end

    local forward_speed = dot(velocity, body.worldOrientation * V_FORWARDS)
    local mph = forward_speed * 60 * 60 / METRES_PER_MILE

    local steerTarget = instance.shouldSteerRight + instance.shouldSteerLeft
    local change = steerTarget - instance.steer
    if math.abs(change) > 0.001 then
        local rate
        local fastness = clamp(mph/persistent.steerFastSpeed, 0, 1)
        if between(0,steerTarget,instance.steer) and math.abs(instance.steer) > 0.001 then
            rate = (1-fastness)*persistent.unsteerRate + (fastness)*persistent.unsteerRateFast
        else
            rate = (1-fastness)*persistent.steerRate + (fastness)*persistent.steerRateFast
        end
        local max = (1-fastness)*persistent.steerMax + (fastness)*persistent.steerMaxFast
        change = clamp(change,-rate, rate)
        instance.steer = instance.steer + change
        instance.steer = clamp(instance.steer, -max, max)
        for _,w in pairs(instance.wheels) do
            w:setSteer(w.steerFactor * math.deg(math.atan(instance.steer)))
        end
    end
    
    for _, wheel in pairs(instance.wheels) do
        wheel.locked = instance.parked
    end

    local tcstep = persistent.wheelSpinTractionControlRate * elapsed
    instance.tractionControl = instance.tractionControl + tcstep

    instance.tractionControl = clamp(instance.tractionControl,
                                 persistent.wheelSpinTractionControlMin,
                                 persistent.wheelSpinTractionControlMax)

    for _, wheel in ipairs(instance.handbrakeWheels) do
        if instance.handbrake then
            wheel.locked = true
        end
    end

    for _, wheel in pairs(instance.wheels) do
        if instance.brake then
            if instance.handbrake then
                wheel.locked = true
            else
                wheel:applyTorque(-sign(mph)*instance.brakeCurve[math.abs(mph)])
            end
        end
        wheel:process(elapsed)
        --local rnd = math.random
        local skidding = wheel.skidding
        if not wheel.locked then
            -- must be skidding due to wheelspin
            -- so attenuate smoke based on wheelspin
            skidding = skidding - invlerp(persistent.wheelSpinTractionControlMin, persistent.wheelSpinTractionControlMax, instance.tractionControl)
        end
            
    end
end

function Plane.deactivate (persistent)
    local instance = persistent.instance
    for k,v in pairs(instance.wheels or {}) do safe_destroy(v) end
    --safe_destroy(instance.lightSystem)
    persistent.needsFrameCallbacks = false
    persistent.needsStepCallbacks = false
    instance.wheels = {}
    instance.drivenWheels = {}
    instance.handbrakeWheels = {}
    return ColClass.deactivate(persistent)
end

function Plane.frameCallback (persistent, time)
    local instance = persistent.instance
    if instance.gfx == nil then return end
    --local body = instance.body
    --Light System
    --instance.lightSystem:update(time)
    -- TODO: use actual lights for the lights
    --[[
    for s,light in ipairs(instance.lights) do
        --pvel=vector3(body:getLocalVelocity(body.worldOrientation * light.pos,false))
        --pos = (body.worldOrientation * light.pos) + body.worldPosition + time*pvel
        --local pos = (body.worldOrientation * light.pos) + body.worldPosition
        local pos = (instance.gfx.derivedOrientation * light.pos) + instance.gfx.derivedPosition
        local cx,cy,cz = explode(light.color)
        instance.lightSystem:addParticle(pos.x,pos.y,pos.z, 0, --pos,rot
            light.rad,light.rad, --scale
            cx,cy,cz, --colour
            1.0, -- Alpha
            0, 0, 0, --Vx,Vy,Vz
            particle_smoke, instance.lightSystemArg, 0)
    end
    ]]
    local diff = instance.desiredGearState - instance.gearState
    if diff ~= 0 then
        local body = instance.body
        local class = persistent.class
        local period = instance.gearCycle or 4
        diff = clamp(diff, -time/period, time/period)
        instance.gearState = instance.gearState + diff
        local e = instance.gfx
        local t = instance.gearState
        for b,a in pairs(instance.gearStruts) do
            e:setBoneLocalOrientationOffset(b, quat(a[t], vector3(1,0,0)))

            local tab = class.gearStrutsCol[instance.gearStrutNames[b]]
            local el = tab[1]
            local q = quat(a[t], tab[2])
            local p = tab[3]
            p = p - (q * p)
            body:setPartOrientationOffset(el, q)
            body:setPartPositionOffset(el, p)
        end
        for b,a in pairs(instance.gearDoors) do
            e:setBoneLocalOrientationOffset(b,quat(a[t], vector3(0,1,0)))
        end
    end
    for k,w in pairs(instance.wheels) do
        w:updatePos()
    end
end


function Plane.getSpeed(persistent)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    --local rb = persistent.instance.body
    return #persistent.instance.body.linearVelocity
end

function Plane.setHandbrake (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.handbrake = v
end

function Plane.abandon (persistent)
    if not persistent.activated then return end
    local instance = persistent.instance
    local body = instance.body
    instance.parked = dot(body.linearVelocity, body.worldOrientation * V_FORWARDS) < 0.5
    instance.brake = false
    instance.push = 0
    instance.handbrake = false

    -- prevent thrust calculation if we abandoned vehicle
    for i,tp in ipairs(instance.targetThrust) do
        instance.currentThrust[i] = 0
        instance.targetThrust[i] = 0
    end
end

function Plane.setPull(persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end

    persistent.instance.parked = false

    for i,_ in ipairs(persistent.instance.targetThrust) do
        --print("Pulling engine", i)
        if v then persistent.instance.targetThrust[i]=persistent.instance.maxNegativeThrust;
        else persistent.instance.targetThrust[i]=0 end
        print("Pulling__thrust", i, persistent.instance.targetThrust[i], persistent.instance.currentThrust[i])
    end

    if v then
        persistent.instance.collectiveTarget=0
    else
        persistent.instance.collectiveTarget=0.5
    end
end

function Plane.setPush(persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end

    --print("Pushing", persistent.instance.body.worldPosition)

    persistent.instance.parked = false

    for i,_ in ipairs(persistent.instance.targetThrust) do
        --print("Pushing engine", i)
        if v then persistent.instance.targetThrust[i]=persistent.instance.maxThrust[i][0]        
        else persistent.instance.targetThrust[i]=0 end
        --print("Pushing__thrust", i, persistent.instance.targetThrust[i], persistent.instance.currentThrust[i])
    end

    if v then
        persistent.instance.collectiveTarget=1.0
    else
        persistent.instance.collectiveTarget=0.5
    end
end

function Plane.setShouldSteerLeft(persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.shouldSteerLeft = v and -persistent.steerMax or 0
end

function Plane.setShouldSteerRight (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.shouldSteerRight = v and persistent.steerMax or 0
end

function Plane.setAltLeft(persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.rollLeft=v and 0.13 or 0

    if v then persistent.instance.cyclicxTarget=1.0
    else persistent.instance.cyclicxTarget=0 end
end

function Plane.setAltRight (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.rollRight=v and 0.13 or 0

    if v then persistent.instance.cyclicxTarget=-1.0
    else persistent.instance.cyclicxTarget=0 end
end

function Plane.setAltDown(persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.pitchUp=v and 0.13 or 0

    if v then persistent.instance.cyclicyTarget=1.0
    else persistent.instance.cyclicyTarget=0 end
end

function Plane.setAltUp (persistent, v)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.pitchDown=v and 0.18 or 0

    if v then persistent.instance.cyclicyTarget=-1.0
    else persistent.instance.cyclicyTarget=0 end
end

function Plane.special (persistent)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.desiredGearState = 1-persistent.instance.desiredGearState
end

function Plane.warp (persistent, pos,orientation)
    pos = pos or player_ctrl:pickPos()+vector3(0,0,2)
    orientation = orientation or player_ctrl.camDir
    persistent:activate()
    if not persistent.activated then error("Tried to activate but still not activated: "..persistent.name) end
    local rb = persistent.instance.body
    rb.worldPosition = pos
    rb.worldOrientation = orientation
    rb.linearVelocity = V_ZERO
    rb.angularVelocity = V_ZERO
end

function Plane.realign (persistent)
    ColClass.realign(persistent)
    persistent.instance.broken = false
end

function Plane.reset (persistent)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.pos = persistent.instance.body.worldPosition
    persistent.rot = persistent.instance.body.worldOrientation
    persistent:deactivate()
    persistent.skipNextActivation = false
    persistent:activate()
    player_ctrl:drive(persistent)
end

function Plane.beingFired (persistent)
    if not persistent.activated then error("Not activated: "..persistent.name) end
    persistent.instance.gearState = 0.0001
    persistent.instance.desiredGearState = 0
end

function Plane.onExplode (persistent)
        if player_ctrl.vehicle == persistent then
                player_ctrl:abandonVehicle()
        end
        local instance = persistent.instance
        instance.gfx:setAllMaterials("/common/mat/Burnt")
        instance.canDrive = false     

        --prevent actual flight after explode O_o
        instance.handbrake=true
        for _, wheel in pairs(instance.wheels) do
            wheel.locked = true
        end
        for i,tp in ipairs(instance.targetThrust) do
            instance.currentThrust[i] = 0
            instance.targetThrust[i] = 0
        end        

        ColClass.onExplode(persistent)
end

