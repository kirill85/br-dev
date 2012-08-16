PileClass = {
        renderingDistance=400;
        init = function (persistent)
                -- iterate over the guys i will spawn to see what their "advance prepares" should be
                --echo("Initialising: "..persistent.name.." ("..persistent.className..")")
        end;
        activate=function (persistent, instance)
                --echo("Activating: "..persistent.name.." ("..persistent.className..")")
                instance.children = {}
                for k,v in ipairs(persistent.class.dump) do
                        local oclass, opos, otab = unpack(v)
                        if persistent.rot then
                                opos = persistent.rot * opos
                                otab.rot = persistent.rot * (otab.rot or Q_ID)
                        end
                        otab.temporary = true
                        opos = persistent.spawnPos + opos
                        instance.children[k] = object_add(oclass,opos,otab)
                end
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

