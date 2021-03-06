ActiveObjectShell = extends (ColClass) {

    renderingDistance = 50;
    additionalState = "DefaultClassState";

    init = function (persistent)
        ColClass.init(persistent)
        echo("Creating "..persistent.name.." of class "..persistent.className.." with additionalState="..persistent.additionalState)
    end;

    activate = function (persistent, instance)
        -- initialise the super class state (basic physics)
        if ColClass.activate (persistent, instance) then
                -- if superclass returns true, skipping activation (this can happen if player is too close to spawn point)
                return true
        end

        echo("Activating "..persistent.name)

        -- initialise any state for streamed in object here (this state does not persist when streamed out)
        instance.timeSinceActivation = 0

        -- set this if you want a drivable vehicle, e.g. car, hovercraft, etc
        instance.canDrive = true

        -- request that stepCallback be called every physics tick
        persistent.needsStepCallbacks = true

    end;

    stepCallback = function (persistent, elapsed)

        -- This following line means the stepCallback can only be called on an activated object
        local instance = persistent.instance

        -- this was initialised by ColClass.activate, cache it in a local var for performance
        local body = instance.body

        -- keep track of the total time that has occured
        instance.timeSinceActivation = instance.timeSinceActivation + elapsed

        -- after every half second, apply a force
        if instance.timeSinceActivation >= 0.5 then

            -- reset the timer
            instance.timeSinceActivation = 0


            -- apply an impulsep
            local impulse_vector = body.mass * random_vector3_sphere()
            local apply_pos = body.worldPosition + 0.05*random_vector3_sphere()

            -- use :force for continuous forces (thrusts), measured in newtons, applied every frame
            -- use :impulse for instantaneous changes in momentum (shocks)
            body:impulse(impulse_vector, apply_pos)

        end

    end;

    deactivate = function (persistent)
        local instance = persistent.instance
        echo("Deactivating "..persistent.name)

        -- request that stepCallback be called every physics tick
        persistent.needsStepCallbacks = false

        -- clean up any local state here
        -- (only things like additional physics objects, graphics objects, callbacks with env system, etc)

        -- ColClass cleans up everything that ColClass.activate added
        return ColClass.deactivate (persistent)

    end;

    -- these are needed if you set instance.canDrive = true
    setPush = function (persistent, v)
        echo(persistent.name..":  push set to "..tostring(v))
    end;
    setPull = function (persistent, v)
        echo(persistent.name..":  pull set to "..tostring(v))
    end;
    setShouldSteerLeft = function (persistent, v)
        echo(persistent.name..":  steer left set to "..tostring(v))
    end;
    setShouldSteerRight = function (persistent, v)
        echo(persistent.name..":  steer right set to "..tostring(v))
    end;
    setHandbrake = function (persistent, v)
        echo(persistent.name..":  handbrake right set to "..tostring(v))
    end;
    realign = function (persistent)
        echo(persistent.name..":  realign pressed")
    end;
    setSpecialUp = function (persistent, v)
        echo(persistent.name..":  special up set to "..tostring(v))
    end;
    setSpecialDown = function (persistent, v)
        echo(persistent.name..":  special down set to "..tostring(v))
    end;
    setSpecialLeft = function (persistent, v)
        echo(persistent.name..":  special left set to "..tostring(v))
    end;
    setSpecialRight = function (persistent, v)
        echo(persistent.name..":  special right set to "..tostring(v))
    end;
    setAltUp = function (persistent, v)
        echo(persistent.name..":  alt up set to "..tostring(v))
    end;
    setAltDown = function (persistent, v)
        echo(persistent.name..":  alt down set to "..tostring(v))
    end;
    setAltLeft = function (persistent, v)
        echo(persistent.name..":  alt left set to "..tostring(v))
    end;
    setAltRight = function (persistent, v)
        echo(persistent.name..":  alt right set to "..tostring(v))
    end;
    special = function (persistent)
        echo(persistent.name..":  special pressed")
    end;

}

