-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading env.lua")

sky_material "Sky" {
    emissiveMap = "starfield.dds";
    special = true;
}

sky_material "Moon" {
    emissiveMap = "starfield.dds";
    alphaRejectThreshold = 0.5;
}

local sky_mat = get_material("SKY:/system/Sky")

function format_time (secs)
    secs = secs or 0
    return string.format("%02d:%02d:%02d", math.mod(math.floor(secs/60/60),24),
                                           math.mod(math.floor(secs/60),60),
                                           math.mod(secs,60))
end

function parse_time (str)
    local function throw() error("Invalid time: \""..str.."\"", 1) end
    if #str ~= 8 then throw() end
    for i=1,8 do
        local char = str:sub(i,i)
        if i==3 or i==6 then
            if char ~= ":" then throw() end
        else
            if char ~= "0" and
               char ~= "1" and
               char ~= "2" and
               char ~= "3" and
               char ~= "4" and
               char ~= "5" and
               char ~= "6" and
               char ~= "7" and
               char ~= "8" and
               char ~= "9" then
                throw()
            end
        end
    end
    local iter = str:gmatch("[^:]+")
    local hours = tonumber(iter())
    local mins = tonumber(iter())
    local secs = tonumber(iter())
    if hours >= 24 then throw() end
    if mins >= 60 then throw() end
    if secs >= 60 then throw() end
    return (hours * 60 + mins) * 60 + secs
end

-- avoid GC overhead
local col_names = { "col0", "col1", "col2", "col3", "col4", "col5" }
local scol_names = { "scol0", "scol1", "scol2", "scol3", "scol4", "scol5" }

local function find_sky(secs)
    secs = secs or 0
    local current_sky, next_sky, slider
    do 
        local found = false
        for _,sky in ipairs(sky_cycle) do
            current_sky = next_sky
            next_sky = sky
            if sky.time*60*60 > secs then
                found = true
                break
            end
        end
        if not found then
            -- wrap-around case
            current_sky = sky_cycle[#sky_cycle]
            next_sky = sky_cycle[1]
            slider = (secs/60/60 - current_sky.time) / (next_sky.time+24 - current_sky.time)
        else
            slider = (secs/60/60 - current_sky.time) / (next_sky.time - current_sky.time)
        end
    end
    return current_sky, next_sky, slider
end

local function recompute_sky()

    local secs = env.secondsSinceMidnight
    -- account for the fact that the sun is on the other side of the planet in summer
    local sun_adjusted_time = math.mod(secs / 60 / 60 / 24 * 360 + env.season, 360)
    local space_orientation = quat(env.latitude,V_EAST)*
                              quat(sun_adjusted_time,V_SOUTH)*
                              quat(env.earthTilt,V_WEST)
    local sun_direction =   (space_orientation * quat(env.season,V_NORTH) * V_UP)
    local moon_direction =  (space_orientation * quat(env.moonPhase,V_NORTH) * V_UP)

    -- procedural from time
    if sky_ent ~= nil then
        sky_ent.orientation = space_orientation
    end
    if moon_ent ~= nil then 
        moon_ent.orientation = space_orientation * quat(env.moonPhase,V_NORTH)
    end
    
    sky_mat:setVertexConstantFloat(0,0,"sun_pos", sun_direction.x, sun_direction.y, sun_direction.z, 0)

    local current_sky, next_sky, slider = find_sky(secs)

    local sky_ambient = lerp(current_sky.skyAmbient, next_sky.skyAmbient, slider)

    local sun_direction = norm((current_sky.moon and moon_direction or sun_direction) --[[+ sky_ambient*V_DOWN]])
    sun_direction = vector3(sun_direction.x, sun_direction.y, math.min(-0.2, sun_direction.z))
    gfx_sun_set_direction(sun_direction)

    -- interpolated from sky_cycle

    local function lerp3(a, b, slider, na, nb)
        na = na or 1; nb = nb or 1
        return lerp(a[na+0], b[nb+0], slider),
               lerp(a[na+1], b[nb+1], slider),
               lerp(a[na+2], b[nb+2], slider)
    end
    local function lerp4(a, b, slider, na, nb)
        na = na or 1; nb = nb or 1
        return lerp(a[na+0], b[nb+0], slider),
               lerp(a[na+1], b[nb+1], slider),
               lerp(a[na+2], b[nb+2], slider),
               lerp(a[na+3], b[nb+3], slider)
    end
    local fog_r, fog_g, fog_b = lerp3(current_sky.fog, next_sky.fog,slider,2,2)

    -- sky
    sky_mat:setFragmentConstantFloat(0,0,"hell_colour", fog_r, fog_g, fog_b, 0)
    sky_mat:setFragmentConstantFloat(0,0,"sun_size", lerp(current_sky.sunSize, next_sky.sunSize, slider))
    sky_mat:setFragmentConstantFloat(0,0,"sun_falloff_distance", lerp(current_sky.sunFalloffDistance, next_sky.sunFalloffDistance, slider))
    sky_mat:setFragmentConstantFloat(0,0,"sun_colour", lerp4(current_sky.sunColour, next_sky.sunColour, slider))
    sky_mat:setFragmentConstantFloat(0,0,"dividers", lerp4(current_sky.skyDividers, next_sky.skyDividers, slider))
    sky_mat:setFragmentConstantFloat(0,0,"sun_glare_distance", lerp(current_sky.sunGlareDistance, next_sky.sunGlareDistance, slider))
    sky_mat:setFragmentConstantFloat(0,0,"horizon_glare_elevation", lerp(current_sky.horizonGlareElevation, next_sky.horizonGlareElevation, slider))
    sky_mat:setFragmentConstantFloat(0,0,"cloud_colour", lerp3(current_sky.cloudColour, next_sky.cloudColour, slider))
    sky_mat:setFragmentConstantFloat(0,0,"cloud_coverage", lerp(current_sky.cloudCoverage, next_sky.cloudCoverage, slider))
    for i=1,6 do
        sky_mat:setFragmentConstantFloat(0,0,col_names[i], lerp4(current_sky.gradient[i], next_sky.gradient[i], slider))
        sky_mat:setFragmentConstantFloat(0,0,scol_names[i], lerp4(current_sky.sunGradient[i], next_sky.sunGradient[i], slider))
    end

    -- scene properties
    gfx_set_scene_ambient(vector3(lerp3(current_sky.amb, next_sky.amb, slider)))
    gfx_fog_set_colour(vector3(fog_r, fog_g, fog_b))
    gfx_fog_set_density(lerp(current_sky.fog[1], next_sky.fog[1], slider)/10)
    local shadow_strength = lerp(current_sky.shadowStrength, next_sky.shadowStrength, slider)
    sm:setShadowColour(shadow_strength, sky_ambient, 0)
    gfx_sun_set_diffuse(vector3(lerp3(current_sky.diff, next_sky.diff, slider)))
    gfx_sun_set_specular(vector3(lerp3(current_sky.spec, next_sky.spec, slider)))

end

local function maybe_commit (self)
    if not self.c.autoUpdate then return end

    local reset_sun_pos = false

    for k,v in pairs(self.p) do
        if self.c[k] ~= v then
            self.c[k] = v

            if k == "secondsSinceMidnight" then
                reset_sun_pos = true
            elseif k == "latitude" then
                reset_sun_pos = true
            elseif k == "season" then
                reset_sun_pos = true
            elseif k == "earthTilt" then
                reset_sun_pos = true
            elseif k == "clockRate" then
            elseif k == "clockTicking" then
            elseif k == "moonPhase" then
                reset_sun_pos = true
            else
                error("Unexpected: "..k)
            end
        end
    end

    if reset_sun_pos then
        recompute_sky()
        if env.clockTicking == false then
            update_hud()
        end
    end
end

local function change (self, k, v)
    if k == "autoUpdate" then
        ensure_one_of(v,{false,true})
        self.c[k] = v
    elseif k == "secondsSinceMidnight" then
        ensure_number(v)
        self.p[k] = v
    elseif k == "latitude" then
        ensure_range(v,-90,90)
        self.p[k] = v
    elseif k == "season" then
        ensure_range(v,0,360)
        self.p[k] = v
    elseif k == "earthTilt" then
        ensure_range(v,-90,90)
        self.p[k] = v
    elseif k == "clockRate" then
        ensure_range(v,-50000,50000)
        self.p[k] = v
    elseif k == "clockTicking" then
        ensure_one_of(v,{false,true})
        self.p[k] = v
    elseif k == "moonPhase" then
        ensure_range(v,0,360)
        self.p[k] = v
    else
        error("Unrecognised env setting: "..tostring(k))
    end

    maybe_commit(self)
end

function do_reset_sky_shader()
    get_gpuprog("/system/SkyProgram_f"):reload()
    get_gpuprog("/system/SkyProgram_v"):reload()
end


include "sky_cycle.lua"

function save_sky_cycle(filename)
    filename = filename or "saved_sky_cycle.lua"
    local f = io.open(filename,"w")
    if f==nil then error("Could not open file",1) end
    f:write("sky_cycle = ")
    f:write(dump(sky_cycle,false))
    f:close()
    echo("Wrote sky cycle to \""..filename.."\"")
end

if not env then
    env = {
        -- current values
        c = {
            autoUpdate = false;
        };

        -- proposed values
        p = {
            latitude = 41; 
            secondsSinceMidnight = 12*60*60; --midday
            season = 180; -- summer, stored as angle in degrees
            earthTilt = 23.44;
            clockRate = 30;
            clockTicking = true;
            moonPhase = 160; -- between sun and earth when moonPhase + season == 180 (mod 360)
        };
        
        tickCallbacks = CallbackReg.new();
    }

    disk_resource_add("/system/SkyCube.mesh")
    disk_resource_add("/system/SkyMoon.mesh")

else

    setmetatable(env,nil)
    ui.pressCallbacks:removeByName("Environment")
    main.frameCallbacks:removeByName("Environment")
    if env.edittingDisplayFrame ~= nil then
        get_hud_root():removeChild(env.edittingDisplayFrame)
    end
    --safe_destroy(env.edittingDisplay)

    sky_ent = safe_destroy(sky_ent)
    moon_ent = safe_destroy(moon_ent)

end

disk_resource_load_indefinitely("/system/SkyCube.mesh")
sky_ent = gfx_sky_body_make("/system/SkyCube.mesh", 255)
disk_resource_load_indefinitely("/system/SkyMoon.mesh")
moon_ent = gfx_sky_body_make("/system/SkyMoon.mesh", 254)

env.edittingDisplayFrame = get_hud_root():addChild("Pane")
env.edittingDisplayFrame.resize = function (pw, ph) return 0, ph - (25+4)*13 - 4, 360, 25*13+8 end
env.edittingDisplayFrame.material = "system/Console"
env.edittingDisplayFrame.visible = false

env.edittingDisplay = env.edittingDisplayFrame:addChild("ShadowText",{font = "misc.fixed", charHeight = 13})
env.edittingDisplay.resize = function (pw, ph) return 4, 4, pw-8, ph-8 end
env.edittingDisplay.text = "test"

env.zero = false
env.superZero = false
env.moreRed = false
env.lessRed = false
env.moreGreen = false
env.lessGreen = false
env.moreBlue = false
env.lessBlue = false
env.moreAlpha = false
env.lessAlpha = false
env.moreSize = false
env.lessSize = false
env.edittingField = "amb"
env.edittingTime = find_sky(env.secondsSinceMidnight) 

function env:windBackwards()
    local s = self.secondsSinceMidnight/60/60
    -- search for GLB
    local current_sky  = nil
    for _,sky in ipairs(sky_cycle) do
        if sky.time < s then
            if current_sky==nil or current_sky.time<sky.time then
                current_sky = sky
            end
        end
    end
    current_sky = current_sky or sky_cycle[#sky_cycle]
    self.edittingTime = current_sky
    env.secondsSinceMidnight = current_sky.time * 60 * 60
    env.tickCallbacks:execute(env.secondsSinceMidnight)
end

function env:windForwards()
    local s = self.secondsSinceMidnight/60/60
    -- search for LUB
    local current_sky  = nil
    for _,sky in ipairs(sky_cycle) do
        if sky.time > s then
            if current_sky==nil or current_sky.time>sky.time then
                current_sky = sky
            end
        end
    end
    current_sky = current_sky or sky_cycle[1]
    self.edittingTime = current_sky
    self.secondsSinceMidnight = current_sky.time * 60 * 60
    env.tickCallbacks:execute(env.secondsSinceMidnight)
end

function env:toggleEditMode()
    if self.edittingDisplayFrame.visible then
        self.edittingDisplayFrame.visible = false
    else
        self:windForwards()
        self:windBackwards()
        self.edittingDisplayFrame.visible = true
    end
end

function env:shutdown()
    safe_destroy(sky_ent)
end

local prev_edit = { }

local next_edit = {
    amb = "diff";
    diff = "spec";
    spec = "fog";
    fog = "grad6";
    grad6 = "grad5";
    grad5 = "grad4";
    grad4 = "grad3";
    grad3 = "grad2";
    grad2 = "grad1";
    grad1 = "sunGrad6";
    sunGrad6 = "sunGrad5";
    sunGrad5 = "sunGrad4";
    sunGrad4 = "sunGrad3";
    sunGrad3 = "sunGrad2";
    sunGrad2 = "sunGrad1";
    sunGrad1 = "sunSize";
    sunSize = "sunColour";
    sunColour = "horizonGlareLevel";
    horizonGlareLevel = "sunGlareRadius";
    sunGlareRadius = "shadowStrength";
    shadowStrength = "cloudColour";
    cloudColour = "cloudCoverage";
    cloudCoverage = "skyAmbient";
    skyAmbient = "amb";
}

for k,v in pairs(next_edit) do
    prev_edit[v] = k
end

local edit_details = {
    amb                   = { function(sky) return sky.amb end, 1, 2, 3, nil, nil, nil };
    diff                  = { function(sky) return sky.diff end, 1, 2, 3, nil, nil, nil };
    spec                  = { function(sky) return sky.spec end, 1, 2, 3, nil, nil, nil };
    fog                   = { function(sky) return sky.fog end, 2, 3, 4, 1, nil, nil, nil };
    grad6                 = { function(sky) return sky.gradient[6] end, 1, 2, 3, 4, nil, nil };
    grad5                 = { function(sky) return sky.gradient[5] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 4 };
    grad4                 = { function(sky) return sky.gradient[4] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 3 };
    grad3                 = { function(sky) return sky.gradient[3] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 2 };
    grad2                 = { function(sky) return sky.gradient[2] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 1 };
    grad1                 = { function(sky) return sky.gradient[1] end, 1, 2, 3, 4, nil, nil };
    sunGrad6              = { function(sky) return sky.sunGradient[6] end, 1, 2, 3, 4, nil, nil };
    sunGrad5              = { function(sky) return sky.sunGradient[5] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 4 };
    sunGrad4              = { function(sky) return sky.sunGradient[4] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 3 };
    sunGrad3              = { function(sky) return sky.sunGradient[3] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 2 };
    sunGrad2              = { function(sky) return sky.sunGradient[2] end, 1, 2, 3, 4, function(sky) return sky.skyDividers end, 1 };
    sunGrad1              = { function(sky) return sky.sunGradient[1] end, 1, 2, 3, 4, nil, nil };
    sunSize               = { nil, nil, nil, nil, nil, function(sky) return sky end, "sunSize" };
    sunColour             = { function(sky) return sky.sunColour end, 1, 2, 3, 4, function(sky) return sky end, "sunFalloffDistance"};
    horizonGlareLevel     = { nil, nil, nil, nil, nil, function(sky) return sky end, "horizonGlareElevation" };
    sunGlareRadius        = { nil, nil, nil, nil, nil, function(sky) return sky end, "sunGlareDistance" };
    shadowStrength        = { nil, nil, nil, nil, nil, function(sky) return sky end, "shadowStrength" };
    cloudColour           = { function(sky) return sky.cloudColour end, 1, 2, 3, nil, nil, nil };
    cloudCoverage         = { nil, nil, nil, nil, nil, function(sky) return sky end, "cloudCoverage" };
    skyAmbient            = { nil, nil, nil, nil, nil, function(sky) return sky end, "skyAmbient" };
}

local function append_edit(str,colours,extra_name,extra_format,extra)
    if env.edittingField == str then
        env.edittingDisplay:setColourTop(1,1,0,1)
        env.edittingDisplay:setColourBottom(1,0,0,1)
    end

    env.edittingDisplay:append(str)
    env.edittingDisplay:setColourTop(1,1,1,1)
    env.edittingDisplay:setColourBottom(1,1,1,1)

    env.edittingDisplay:append(" = ")

    if colours then
        env.edittingDisplay:append("RGB(")
        for i,col in ipairs(colours) do
            if i>1 then env.edittingDisplay:append(", ") end
            env.edittingDisplay:append(string.format("%0.3f",col))
        end
        env.edittingDisplay:append(")")
    end

    if extra_name then
        if colours then env.edittingDisplay:append(" ") end
        env.edittingDisplay:append((extra_name~="" and extra_name.." " or "")..string.format(extra_format,extra))
    end

    env.edittingDisplay:append("\n")

end

function update_hud()
    env.edittingDisplay:reset()
    local sky = env.edittingTime
    append_edit("amb", sky.amb)
    append_edit("diff", sky.diff)
    append_edit("spec", sky.spec)
    append_edit("fog", {sky.fog[2], sky.fog[3], sky.fog[4]}, "strength", "%0.2f", sky.fog[1])
    append_edit("grad6", sky.gradient[6], "height", "%0.1f", 90)
    append_edit("grad5", sky.gradient[5], "height", "%0.1f", sky.skyDividers[4])
    append_edit("grad4", sky.gradient[4], "height", "%0.1f", sky.skyDividers[3])
    append_edit("grad3", sky.gradient[3], "height", "%0.1f", sky.skyDividers[2])
    append_edit("grad2", sky.gradient[2], "height", "%0.1f", sky.skyDividers[1])
    append_edit("grad1", sky.gradient[1], "height", "%0.1f", 0)
    append_edit("sunGrad6", sky.sunGradient[6], "height", "%0.1f", 90)
    append_edit("sunGrad5", sky.sunGradient[5], "height", "%0.1f", sky.skyDividers[4])
    append_edit("sunGrad4", sky.sunGradient[4], "height", "%0.1f", sky.skyDividers[3])
    append_edit("sunGrad3", sky.sunGradient[3], "height", "%0.1f", sky.skyDividers[2])
    append_edit("sunGrad2", sky.sunGradient[2], "height", "%0.1f", sky.skyDividers[1])
    append_edit("sunGrad1", sky.sunGradient[1], "height", "%0.1f", 0)
    append_edit("sunSize", nil, "", "%0.2f", sky.sunSize)
    append_edit("sunColour", sky.sunColour, "falloff", "%0.3f", sky.sunFalloffDistance)
    append_edit("horizonGlareLevel", nil, "", "%0.3f", sky.horizonGlareElevation)
    append_edit("sunGlareRadius", nil, "", "%0.3f", sky.sunGlareDistance)
    append_edit("shadowStrength", nil, "", "%0.3f", sky.shadowStrength)
    append_edit("cloudColour", sky.cloudColour)
    append_edit("cloudCoverage", nil, "", "%0.3f", sky.cloudCoverage)
    append_edit("skyAmbient", nil, "", "%0.3f", sky.skyAmbient)
    --append_edit("sunGlareCol2", sky.sunGlareCol2, "radius", "%0.3f", sky.sunGlareDistance)
    --append_edit("sunGlareCol1", sky.sunGlareCol1, "transition", "%0.3f", sky.sunGlareTransition)
    --append_edit("horizonGlareCol2", sky.horizonGlareCol2, "height", "%0.3f", sky.horizonGlareElevation)
    --append_edit("horizonGlareCol1", sky.horizonGlareCol1, "transition", "%0.3f", sky.horizonGlareTransition)
    env.edittingDisplay:append((env.edittingTime.moon and "Moon" or "Sun").." casts shadows\n\n\n")
    env.edittingDisplay:commit()
    env.edittingDisplay:triggerResize()
end

update_hud()

-- put behind the console so that the console still works when we're in edit mode
ui.pressCallbacks:insert("Environment",function (key)
    if not env.edittingDisplayFrame.visible then return end
    if key=='+Left' then
        env:windBackwards()
    elseif key=='+Right' then
        env:windForwards()
    elseif key=='+Up' then
        env.edittingField = prev_edit[env.edittingField]
        update_hud()
    elseif key=='+Down' then
        env.edittingField = next_edit[env.edittingField]
        update_hud()
    elseif key=='+NUMPAD5' then
        env.edittingTime.moon = not env.edittingTime.moon
        update_hud()
    elseif key=='+NUMPAD7' then env.lessRed = true
    elseif key=='-NUMPAD7' then env.lessRed = false
    elseif key=='+NUMPAD9' then env.moreRed = true
    elseif key=='-NUMPAD9' then env.moreRed = false
    elseif key=='+NUMPAD4' then env.lessGreen = true
    elseif key=='-NUMPAD4' then env.lessGreen = false
    elseif key=='+NUMPAD6' then env.moreGreen = true
    elseif key=='-NUMPAD6' then env.moreGreen = false
    elseif key=='+NUMPAD1' then env.lessBlue = true
    elseif key=='-NUMPAD1' then env.lessBlue = false
    elseif key=='+NUMPAD3' then env.moreBlue = true
    elseif key=='-NUMPAD3' then env.moreBlue = false
    elseif key=='+NUMPAD0' then env.lessAlpha = true
    elseif key=='-NUMPAD0' then env.lessAlpha = false
    elseif key=='+NUMPAD.' then env.moreAlpha = true
    elseif key=='-NUMPAD.' then env.moreAlpha = false
    elseif key=='+NUMPAD8' then env.moreSize = true
    elseif key=='-NUMPAD8' then env.moreSize = false
    elseif key=='+NUMPAD2' then env.lessSize = true
    elseif key=='-NUMPAD2' then env.lessSize = false
    elseif key=='+0' then env.zero = true
    elseif key=='+-' then env.superZero = true
    else
        return
    end
    return false
end, ui.pressCallbacks:getIndexSafe("grit_console")+1)


local last_time = seconds()

local function frameCallback()
    local clock_rate = env.clockRate

    local curr_time = seconds()
    local elapsed = curr_time - last_time
    last_time = curr_time

    if env.clockTicking and not env.edittingDisplayFrame.visible then

        env.secondsSinceMidnight = math.mod(env.secondsSinceMidnight + elapsed * env.clockRate, 24*60*60)

        env.tickCallbacks:execute(env.secondsSinceMidnight)

    elseif env.edittingDisplayFrame.visible then

        local details = edit_details[env.edittingField]

        local qty = (ui:ctrl() and .1 or 1) * 60/256 * elapsed

        if details[1] then
            local tab = details[1](env.edittingTime)
            local r = details[2]
            local g = details[3]
            local b = details[4]
            local a = details[5]

            if r and env.moreRed   then tab[r] = clamp(tab[r] + qty, 0, 4) end
            if r and env.lessRed   then tab[r] = clamp(tab[r] - qty, 0, 4) end
            if g and env.moreGreen then tab[g] = clamp(tab[g] + qty, 0, 4) end
            if g and env.lessGreen then tab[g] = clamp(tab[g] - qty, 0, 4) end
            if b and env.moreBlue  then tab[b] = clamp(tab[b] + qty, 0, 4) end
            if b and env.lessBlue  then tab[b] = clamp(tab[b] - qty, 0, 4) end
            if a and env.moreAlpha then tab[a] = clamp(tab[a] + qty, 0, 1) end
            if a and env.lessAlpha then tab[a] = clamp(tab[a] - qty, 0, 1) end

            if r and env.zero   then tab[r] = 0 end
            if r and env.zero   then tab[r] = 0 end
            if g and env.zero then tab[g] = 0 end
            if g and env.zero then tab[g] = 0 end
            if b and env.zero  then tab[b] = 0 end
            if b and env.zero  then tab[b] = 0 end
            if a and env.zero then tab[a] = 0 end
            if a and env.zero then tab[a] = 0 end

        end

        if details[6] then
            local tab = details[6](env.edittingTime)
            local key = details[7]

            if env.moreSize   then tab[key] = tab[key] + qty*10 end
            if env.lessSize   then tab[key] = tab[key] - qty*10 end

            if env.superZero then tab[key] = 0 end
        end

        env.zero = false
        env.superZero = false

        recompute_sky()
        update_hud()

    end
end

main.frameCallbacks:insert("Environment", frameCallback)

setmetatable(env, {
    __index = function (self, k)
        local v = self.c[k] ;
        if v == nil then
            error("No such setting: \""..k.."\"",2)
        end
        return v
    end,
    __newindex = function (self, k, v) change(self,k,v) end
})

env.autoUpdate = true
