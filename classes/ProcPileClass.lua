ProcPileClass = {
        renderingDistance=400;
        init = function (persistent)
                -- iterate over the guys i will spawn to see what their "advance prepares" should be
                --echo("Initialising: "..persistent.name.." ("..persistent.className..")")
        end;
        spawnObjects = function() end;
        activate=function (persistent, instance)
                --echo("Activating: "..persistent.name.." ("..persistent.className..")")
                instance.children = {}
                local counter = 1
                persistent:spawnObjects(function(oclass,opos,otab)
                        if persistent.rot then
                                opos = persistent.rot * opos
                                otab.rot = persistent.rot * (otab.rot or Q_ID)
                        end
                        otab.temporary = true
                        opos = persistent.spawnPos + opos
                        instance.children[counter] = object_add(oclass,opos,otab)
                        counter = counter + 1
                end)
        end;
        deactivate=function(persistent)
                --echo("Deactivating: "..persistent.name.." ("..persistent.className..")")
                -- nothing to do i think
                local instance = persistent.instance
                for k,v in ipairs(instance.children) do
                        if not v.activated then
                                v:destroy()
                        end
                end
        end;
}

