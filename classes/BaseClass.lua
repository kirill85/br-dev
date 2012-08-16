-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

verbose_receive_damage = false

function light_from_table (tab)
        local l = gfx_light_make()
        if tab.pos then l.localPosition = tab.pos end
        local sz
        if tab.diff then
                sz = math.max(math.max(math.max(1, tab.diff.x), tab.diff.y), tab.diff.z)
                l.diffuseColour = tab.diff
        end
        if tab.spec then l.specularColour = tab.spec end
        if tab.diff and not tab.spec then
                l.specularColour = tab.diff
        end
        local csz
        if sz then csz = sz / 16 end
        if tab.range then
                l.range = tab.range
                if csz then csz = csz * tab.range end
        end
        if tab.iangle then l.innerAngle = tab.iangle end
        if tab.oangle then l.outerAngle = tab.oangle end
        if tab.aim then l.localOrientation = tab.aim end
        if tab.coronaSize or csz then l.coronaSize = tab.coronaSize or csz end
        if tab.coronaColour then
                l.coronaColour = tab.coronaColour
        else
                if sz then
                        l.coronaColour = tab.diff / sz / 8
                end
        end
        local clp = tab.coronaPos or tab.pos
        if clp then l.coronaLocalPosition = clp end
        return l
end

BaseClass = {
        renderingDistance=400;
        init = function (persistent)
                local class_name = persistent.className
                local gfxMesh = persistent.gfxMesh or class_name..".mesh"
                persistent:addDiskResource(gfxMesh)
                if persistent.extraResources == nil then return end
                for _,v in ipairs(persistent.extraResources) do
                        persistent:addDiskResource(v)
                end
        end;
        activate=function (persistent, instance)
                if persistent.skipNextActivation then
                        persistent.skipNextActivation = nil
                        instance.activationSkipped = true
                        return true
                end
                --echo("Activating: "..persistent.name.." ("..persistent.className..")")
                local gfxMesh = persistent.gfxMesh or persistent.className..".mesh"
                local fqmm
                if persistent.materialMap then
                        fqmm = fqmm or {}
                        for k,v in pairs(persistent.materialMap) do
                                fqmm[fqn_ex(k, persistent.className)] = fqn_ex(v, persistent.className)
                        end
                end
                if instance.materialMap then -- allows subclasses to add to the material map
                        fqmm = fqmm or {}
                        for k,v in pairs(instance.materialMap) do
                                fqmm[fqn_ex(k, persistent.className)] = fqn_ex(v, persistent.className)
                        end
                end
                instance.gfx = gfx_body_make(gfxMesh, fqmm)
                instance.gfx.castShadows = persistent.castShadows == true
                if instance.gfx.numBones > 0 then instance.gfx:setAllBonesManuallyControlled(true) end
                instance.gfx.localPosition = persistent.spawnPos
                instance.gfx.localOrientation = persistent.rot or quat(1,0,0,0)
                
                local lights = persistent.lights
                if lights then
                        instance.lights = {}
                        instance.lightCallbacks = {}
                        instance.lightFlickedOff = {}
                        instance.lightTimeOff = {}
                        for k,tab in ipairs(lights) do
                                local l = light_from_table(tab)
                                instance.lights[k] = l
                                l.parent = instance.gfx
                                if tab.flickering then
                                        -- simulate a broken flourescent tube
                                        future_event(0, function()
                                                if l.destroyed then return end
                                                local off = math.random() < 0.33
                                                instance.lightFlickedOff[k] = off
                                                l.enabled = not instance.lightFlickedOff[k] and not instance.lightTimeOff[k]
                                                none_one_or_all(tab.emissiveMaterials, function(x)
                                                        instance.gfx:setEmissiveEnabled(fqn_ex(x, persistent.className), l.enabled)
                                                end)
                                                return math.random() * 0.2
                                        end)
                                end
                                if tab.onTime and tab.offTime then
                                        local on_time = parse_time(tab.onTime)
                                        local off_time = parse_time(tab.offTime)
                                        local on_during_night = on_time > off_time
                                        local first_time = on_during_night and off_time or on_time
                                        local last_time = on_during_night and on_time or off_time
                                        if tab.timeOnOffRandomness then
                                                local random_secs = parse_time(tab.timeOnOffRandomness)
                                                first_time = first_time + math.random()*random_secs
                                                last_time = last_time + math.random()*random_secs
                                        end
                                        local cb = function()
                                                local off
                                                if env.secondsSinceMidnight < first_time then
                                                        off = not on_during_night
                                                elseif env.secondsSinceMidnight < last_time then
                                                        off = on_during_night
                                                else
                                                        off = not on_during_night
                                                end
                                                instance.lightTimeOff[k] = off
                                                l.enabled = not instance.lightFlickedOff[k] and not instance.lightTimeOff[k]
                                                none_one_or_all(tab.emissiveMaterials, function(x)
                                                        instance.gfx:setEmissiveEnabled(fqn_ex(x, persistent.className), l.enabled)
                                                end)
                                        end
                                        instance.lightCallbacks[k] = cb
                                        --env:addClockCallback(cb)
                                        env.tickCallbacks:insert(("lights_callback_"..k), cb)
                                        cb(env.secondsSinceMidnight)
                                end
                        end
                end

                if persistent.colourSpec then
                        persistent:setRandomColour()
                end
        end;
        setRandomColour=function(persistent)
                if not persistent.activated then error("not activated") end
                local cs = persistent.colourSpec
                local prob_total = 0
                for k,v in ipairs(cs) do
                        prob_total = prob_total + (v.probability or 1)
                end
                local r = math.random() * prob_total
                prob_total = 0
                for k,v in ipairs(cs) do
                        prob_total = prob_total + (v.probability or 1)
                        if r < prob_total then
                                persistent:setRandomColourFromSet(v)
                                return
                        end
                end
        end;
        setRandomColourFromSet=function(persistent, colset, indexes)
                if not persistent.activated then error("not activated") end
                local cs = persistent.colourSpec
                if type(colset) == "number" then
                        colset = cs[colset]
                end
                local cols = {}
                for i=1,4 do -- 4 colours to choose
                        if colset[i] == nil or #colset[i] == 0 then
                                cols[i] = "white"
                        else
                                local set = {}
                                local function incorporate_all (tab)
                                        for _,v in ipairs(tab) do
                                                if type(v) == "string" and v:sub(1,1) == "*" then
                                                        incorporate_all(carcol_groups[v:sub(2)])
                                                else
                                                        set[#set+1] = v
                                                end
                                        end
                                end
                                incorporate_all(colset[i])
                                cols[i] = set[indexes and indexes[i] or math.random(#set)]
                        end
                end
                persistent:setColour(cols)
        end;
        setColour=function(persistent, cols)
                if not persistent.activated then error("not activated") end
                assert(type(cols)=="table")
                for i=1,4 do -- 4 colours to choose
                        local col = cols[i]
                        if col ~= nil then
                                if type(col) ~= "table" and type(col) ~= "string" then
                                        error("Expecting table or string for coloured part "..i..", class \""..persistent.className.."\"")
                                end
                                while type(col) == "string" do
                                        local col2 = carcols[col]
                                        if col2==nil then
                                                error("Class \""..persistent.className.."\" could not find colour \""..col.."\"")
                                        end
                                        if type(col2) ~= "table" and type(col2) ~= "string" then
                                                error("Expecting table or string looking up car colour table with name\""..col.."\"")
                                        end
                                        col = col2
                                end
                                local diff = colour_ensure_vector3(col[1])
                                local met = col[2] or 0.5
                                local spec = colour_ensure_vector3(col[3]) or vector3(1,1,1)
                                persistent.instance.gfx:setPaintColour(i-1, diff, met, spec)
                        end
                end
        end;
        setFade=function(persistent, fade)
                local instance = persistent.instance
                if instance.gfx then
                        instance.gfx.fade = fade
                end
                if instance.lights then
                        for k,v in pairs(instance.lights) do
                                v.fade = fade
                        end
                end
        end;
        deactivate=function(persistent)
                local instance = persistent.instance
                --echo("Deactivating: "..persistent.name.." ("..persistent.className..")")
                persistent.pos = persistent.spawnPos
                instance.gfx = safe_destroy(instance.gfx)
                if instance.lights then
                        for k,v in pairs(instance.lights) do
                                instance.lights[k] = safe_destroy(v)
                                if instance.lightCallbacks[k] then
                                        --env:removeClockCallback(instance.lightCallbacks[k])
                                        env.tickCallbacks:removeByName(("lights_callback_"..k))
                                        instance.lightCallbacks[k] = nil
                                end
                        end
                end
        end;
        reload=function(persistent)
                persistent:reloadDiskResources();
        end;
        ignite=function() end;

        getStatistics = function (persistent)
                local instance = persistent.instance
                local gfx = instance.gfx
    
                local tot_triangles, tot_batches = gfx.triangles, gfx.batches

                echo("Mesh: "..gfx.meshName)

                echo(" Triangles: "..gfx.triangles)
                echo(" Batches: "..gfx.batches)

                return tot_triangles, tot_batches
        end;

}

function dump_object_line(persistent)
        local x,y,z = unpack(persistent.spawnPos)
        return ("object \"%s\" (%f,%f,%f) {name=\"%s\", rot=%s}"):format(persistent.className, x,y,z, persistent.name, tostring(persistent.rot))
end

