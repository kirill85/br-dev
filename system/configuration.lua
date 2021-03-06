-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the GNU GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.html

print("Loading user configuration")


safe_include("/user_cfg.lua")

user_cfg = user_cfg or { }
debug_cfg = debug_cfg or { }
user_core_bindings = user_core_bindings or { }
user_ghost_bindings = user_ghost_bindings or { }
user_drive_bindings = user_drive_bindings or { }
user_foot_bindings = user_foot_bindings or { }


local user_cfg_default = {
    shadowRes = 1024;
    shadowEmulatePCF = false;
    shadowFilterTaps = 4;
    shadowFilterSize = 4;
    shadowFilterNoise = true;
    shadowFilterDither = false;
    shadowPCSSPadding = 0.8;
    shadowPCSSStart = 0.2;
    shadowPCSSEnd0 = 20;
    shadowPCSSEnd1 = 50;
    shadowPCSSEnd2 = 200;
    shadowPCSSAdj0 = 3;
    shadowPCSSAdj1 = 1;
    shadowPCSSAdj2 = 1;
    shadowPCSSSpreadFactor0 = 1;
    shadowPCSSSpreadFactor1 = 1;
    shadowPCSSSpreadFactor2 = 0.28;
    shadowFadeStart = 150;
    fullscreen = false;
    res = {800,600};
    visibility = 1;
    graphicsRAM = 128;
    anisotropy = 0;
    lockMemory = true;
    textureShrink = 0;
    screenshotFormat = "png";
    mouseInvert = false;
    mouseSensitivity = 0.03;
    vsync = false;
    monitorHeight = 0.27;
    monitorEyeDistance = 0.6;
    minPerceivedDepth = 0.3;
    maxPerceivedDepth = 2;
    lowPowerMode = false;
	audioMasterVolume = 0.75;
    vehicleCameraTrack = true;
    thirdPerson = false;
}

local user_cfg_doc = {
    shadowRes = "resolution of the shadow textures";
    shadowEmulatePCF = "antialias shadow edges";
    shadowFilterTaps = "quality of soft shadows";
    shadowFilterSize = "size of penumbra";
    shadowFilterNoise = "a cheap way of getting softer shadows";
    shadowFilterDither = "another cheap way of getting softer shadows";
    shadowPCSSPadding = "overlap between shadow regions";
    shadowPCSSStart = "distance from camera where shadows start";
    shadowPCSSEnd0 = "distance from camera to transition to 2nd shadow map";
    shadowPCSSEnd1 = "distance from camera to transition to 3rd shadow map";
    shadowPCSSEnd2 = "distance from camera where shadows end";
    shadowPCSSAdj0 = "'optimal adjust' for 1st shadow map";
    shadowPCSSAdj1 = "'optimal adjust' for 2nd shadow map";
    shadowPCSSAdj2 = "'optimal adjust' for 3rd shadow map";
    shadowPCSSSpreadFactor0 = "penumbra multiplier for 1st shadow map";
    shadowPCSSSpreadFactor1 = "penumbra multiplier for 2st shadow map";
    shadowPCSSSpreadFactor2 = "penumbra multiplier for 3rd shadow map";
    shadowFadeStart = "distance where shadow starts to fade";
    fullscreen = "as opposed to windowed mode";
    res = "desktop resolution when fullscreened";
    visibility = "factor on draw distance";
    graphicsRAM = "Size of textures+mesh cache to maintain";
    anisotropy = "avoids blurring of roads";
    lockMemory = "avoids excessive disk IO";
    textureShrink = "mipmap bias";
    screenshotFormat = "format in which to store textures";
    mouseInvert = "whether forward motion should look down";
    mouseSensitivity = "how easy it is to turn with mouse";
    vsync = "avoid corruption due to out of sync monitor updates";
    monitorHeight = "todo";
    monitorEyeDistance = "todo";
    minPerceivedDepth = "todo";
    maxPerceivedDepth = "todo";
    lowPowerMode = "Reduce FPS and physics accuracy";
	audioMasterVolume = "Master audio volume";
    vehicleCameraTrack = "Camera automatically follows vehicles";
    thirdPerson = "Third person camera for self";
}

local user_cfg_spec = {
    shadowRes = { "one of", 128,256,512,1024,2048,4096 };
    shadowEmulatePCF = { "one of", false, true };
    shadowFilterTaps = { "one of", 1, 4, 9, 16, 25, 36 };
    shadowFilterSize = { "range", 0, 40 };
    shadowFilterNoise = { "one of", false, true };
    shadowFilterDither = { "one of", false, true };
    shadowPCSSPadding = { "range", 0, 100 };
    shadowPCSSStart = { "range", 0, 10000 };
    shadowPCSSEnd0 = { "range", 0, 10000 };
    shadowPCSSEnd1 = { "range", 0, 10000 };
    shadowPCSSEnd2 = { "range", 0, 10000 };
    shadowPCSSAdj0 = { "range", 0, 10000 };
    shadowPCSSAdj1 = { "range", 0, 10000 };
    shadowPCSSAdj2 = { "range", 0, 10000 };
    shadowPCSSSpreadFactor0 = { "range", 0, 20 };
    shadowPCSSSpreadFactor1 = { "range", 0, 20 };
    shadowPCSSSpreadFactor2 = { "range", 0, 20 };
    shadowFadeStart = { "range", 0, 10000 };
    res = { "table", 2, {"int range", 1, 4096}, {"int range", 1, 4096} };
    fullscreen = { "one of", false, true };
    visibility = { "range", 0, 5 }; 
    graphicsRAM = { "int range", 0, 2048 };
    lockMemory = { "one of", false, true };
    anisotropy = { "int range", 0, 16 };
    textureShrink = { "int range", 0, 4 };
    screenshotFormat = { "one of", "png","tga" };
    mouseInvert = { "one of", false, true };
    mouseSensitivity = { "range", 0, 10 };
    vsync = { "one of", false, true };
    monitorHeight = { "range", 0.01, 1000 }; 
    monitorEyeDistance =  { "range", 0.01, 1000 }; 
    minPerceivedDepth =  { "range", 0.01, 1000 }; 
    maxPerceivedDepth =  { "range", 0.01, 1000 }; 
    lowPowerMode = { "one of", false, true };
	audioMasterVolume =  { "range", 0, 1 }; 
	vehicleCameraTrack = { "one of", false, true };
    thirdPerson = { "one of", false, true};
}           
            

local debug_cfg_default = {
    shadowCast = true;
    shadowReceive = true;
    vertexProcessing = true;
    textureFetches = true;
    fragmentProcessing = true;
    heightmapBlending = true;
    falseColour = false;
    normalMaps = true;
    diffuseMaps = true;
    specularMaps = true;
    translucencyMaps = true;
    colourMaps = true;
    vertexDiffuse = true;
    filtering = true;
    fog = true;
    fixedFunction = false;
    boundingBoxes = false;
    texturePane = "none";
    texturePaneSize = 128;
    FOV = 75;
    farClip = 800;
    polygonMode = "SOLID";
    physicsWireFrame = false;
    physicsDebugWorld = true;
    textureAnimation = true;
    textureScale = true;
    shadingModel = "SHARP";
    gammaCorrectionIn = 2.2;
    gammaCorrectionOut = 2.2;
    reverseSpecular = true;
    deferredShading = true;
    maxLightRange = 1;
}

local debug_cfg_doc = {
    shadowCast = "enable casting phase";
    shadowReceive = "enable receiving phase";
    vertexProcessing = "for eliminating vertex shader work";
    textureFetches = "use proper fetches instead of procedural placeholders";
    fragmentProcessing = "for eliminating fragment shader work";
    heightmapBlending = "whether to use the heightmap when blending";
    falseColour = "various debug displays";
    normalMaps = "whether to use normal maps";
    diffuseMaps = "whether to use diffuse maps";
    specularMaps = "whether to use specular maps";
    translucencyMaps = "whether to use translucency maps";
    colourMaps = "whether to use colour maps";
    vertexDiffuse = "whether to use the diffuse channel in the meshes";
    filtering = "turn off to see the texels clearly";
    fog = "enable distance fog";
    fixedFunction = "use the classic fixed function pipeline";
    boundingBoxes = "show octree culling abstractions";
    texturePane = "display texture map, specials are none, shadow1, shadow2, shadow3";
    texturePaneSize = "how large to show the shadow map";
    FOV = "field of view in degrees";
    farClip = "how far away is maximum depth";
    polygonMode = "wireframe, etc";
    physicsWireFrame = "show physics meshes";
    physicsDebugWorld = "don't limit debug display to moving objects";
    textureAnimation = "whether or not to animate textures";
    textureScale = "enable support for texture scaling from materials";
    shadingModel = "the way lighting is calculated";
    gammaCorrectionIn = "manual gamma correction for textures";
    gammaCorrectionOut = "manual reverse gamma correction for framebuffer";
    reverseSpecular = "Whether to use dimmer specular highlights on the rear side of objects as well";
    deferredShading = "Whether to render the scene with deferred shading or forward shading";
    maxLightRange = "A non-hdr pipeline would only allow 1 here";
}

local debug_cfg_spec = {
    shadowCast = { "one of", false, true };
    shadowReceive = { "one of", false, true };
    vertexProcessing = { "one of", false, true };
    textureFetches = { "one of", false, true };
    fragmentProcessing = { "one of", false, true };
    heightmapBlending = { "one of", false, true };
    falseColour = { "one of", false, "UV", "UV_STRETCH", "UV_STRETCH_BANDS", "NORMAL", "OBJECT_NORMAL", "NORMAL_MAP", "TANGENT", "BINORMAL", "UNSHADOWYNESS", "SPECULAR_COLOUR", "SPECULAR_EXPOSURE", "SPECULAR_ILLUMINATION", "SPECULAR_COMPONENT", "RSPECULAR_ILLUMINATION", "RSPECULAR_COMPONENT", "DIFFUSE_EXPOSURE", "FLAT_DIFFUSE_EXPOSURE", "DIFFUSE_ILLUMINATION", "DIFFUSE_COLOUR", "DIFFUSE_COMPONENT", "VERTEX_COLOUR", "AMBIENT_ILLUMINATION", "AMBIENT_COMPONENT", "SKY_EXPOSURE", "SKY_ILLUMINATION", "SKY_COMPONENT" };
    polygonMode = { "one of", "SOLID", "SOLID_WIREFRAME", "WIREFRAME" };
    normalMaps = { "one of", false, true };
    diffuseMaps = { "one of", false, true };
    specularMaps = { "one of", false, true };
    translucencyMaps = { "one of", false, true };
    colourMaps = { "one of", false, true };
    vertexDiffuse = { "one of", false, true };
    filtering = { "one of", false, true };
    fog = { "one of", false, true };
    fixedFunction = { "one of", false, true };
    boundingBoxes = { "one of", false, true };
    texturePane = { "string" };
    texturePaneSize = { "int range", 1, 1024 };
    FOV = { "range", 0, 120 };
    farClip = { "range", 1, 10000 };
    physicsWireFrame = { "one of", false, true };
    physicsDebugWorld = { "one of", false, true };
    textureAnimation = { "one of", false, true };
    textureScale = { "one of", false, true };
    shadingModel = { "one of", "SHARP", "HALF_LAMBERT", "WASHED_OUT" };
    gammaCorrectionIn = { "range", 0, 10 };
    gammaCorrectionOut = { "range", 0, 10 };
    reverseSpecular = { "one of", false, true };
    deferredShading = { "one of", false, true };
    maxLightRange = { "range", 1, 10 };
}   



local default_user_core_bindings = {
    console = "Tab";
    record = "C+F12";
    screenShot = "F12";
    physicsPause = "F9";
    physicsSplitImpulse = "C+F10";
    physicsOneToOne = "F10";
    gameLogicStep = "F11";
    wireFrame = "F8";
    boundingBoxes = "C+F8";
    physicsWireFrame = "F7";
    physicsDebugWorld = "C+F7";
    skyPause = "F5";
    skyEdit = "C+F5";
    clearPlaced = "F3";
    clearProjectiles = "F4";
    toggleFullScreen = "A+Return";
    fast = "right";
}

local default_user_ghost_bindings = {
    forwards = "w";
    backwards = "s";
    strafeLeft = "a";
    strafeRight = "d";
    board = "f";
    ascend = "Space";
    descend = "Shift";
    teleportUp = "Return";
    teleportDown = "BackSpace";
    simpleMenuShow = "`";
    placementEditor = "e";
    grab = "g";
}

local default_user_drive_bindings = {
    forwards = "w";
    backwards = "s";
    steerLeft = "a";
    steerRight = "d";
    specialLeft = "q";
    specialRight = "e";
    specialUp = "PageUp";
    specialDown = "PageDown";
    altUp = "Up";
    altDown = "Down";
    altLeft = "Left";
    altRight = "Right";
    abandon = "f";
    handbrake = "Space";
    zoomIn = {"up","S+v"};
    zoomOut = {"down","v"};
    realign = "Return";
    special = "BackSpace";
}

local default_user_foot_bindings = {
    forwards = "w";
    backwards = "s";
    strafeLeft = "a";
    strafeRight = "d";
    abandon = "f";
    jump = "Space";
    crouch = "c";
    run = "Shift";
    zoomIn = {"up","S+v"};
    zoomOut = {"down","v"};
}


local core_binding_functions = {
    console = function() console.visible = not console.visible end;
    record = function() capturer:toggle() end;
    screenShot = function() capturer:singleScreenShot() end;
    physicsPause = function ()
        physics.enabled = not physics.enabled
        echo("Physics enabled: "..tostring(physics.enabled))
    end;
    physicsSplitImpulse = function ()
        physics_option("SOLVER_SPLIT_IMPULSE", not physics_option("SOLVER_SPLIT_IMPULSE"))
        echo("Physics splitImpulse: "..tostring(physics_option("SOLVER_SPLIT_IMPULSE")))
    end;
    physicsOneToOne = function ()
        physics.oneToOne = not physics.oneToOne
        echo("Physics one-to-one: "..tostring(physics.oneToOne))
    end;
    gameLogicStep = { function () physics_step(physics_option("STEP_SIZE")) end, nil, true };
    boundingBoxes = function() debug_cfg.boundingBoxes = not debug_cfg.boundingBoxes end;
    wireFrame = function()
        local pm = debug_cfg.polygonMode
        if pm == "SOLID" then
            debug_cfg.polygonMode = "SOLID_WIREFRAME"
        elseif pm == "SOLID_WIREFRAME" then 
            debug_cfg.polygonMode = "WIREFRAME"
        else    
            debug_cfg.polygonMode = "SOLID"
        end     
    end;
    physicsWireFrame = function()
        debug_cfg.physicsWireFrame = not debug_cfg.physicsWireFrame
    end;
    physicsDebugWorld = function()
        physics.debugWorld = not physics.debugWorld
    end;
    skyPause = function() env.clockTicking = not env.clockTicking end;
    skyEdit = function() env:toggleEditMode() end;
    clearPlaced = clear_placed;
    clearProjectiles = clear_temporary;
    toggleFullScreen = function ()
        user_cfg.fullscreen = not user_cfg.fullscreen
        -- avoid these keys getting 'stuck down' as we lose focus momentarily
        keyb_flush("Alt")
        keyb_flush("Return")
        ui:flush("Alt")
        ui:flush("Return")
    end;
    fast = {function() player_ctrl.fast = true end, function() player_ctrl.fast = false end};
}

local ghost_binding_functions = {
    forwards = {function() player_ctrl.forwards=1 end, function() player_ctrl.forwards = 0 end};
    backwards = {function() player_ctrl.backwards=1 end, function() player_ctrl.backwards = 0 end};
    strafeLeft = {function() player_ctrl.left=1 end, function() player_ctrl.left = 0 end};
    strafeRight = {function() player_ctrl.right=1 end, function() player_ctrl.right = 0 end};
    board = function() player_ctrl:pickDrive() end;
    ascend = {function() player_ctrl.up=1 end, function() player_ctrl.up = 0 end};
    descend = {function() player_ctrl.down=1 end, function() player_ctrl.down = 0 end};
    teleportUp = {function() player_ctrl.camFocus = player_ctrl.camFocus+V_UP end, nil, true};
    teleportDown = {function() player_ctrl.camFocus = player_ctrl.camFocus+V_DOWN end, nil, true};
    simpleMenuShow = {function() simple_menu:show(simple_menu.Main_menu) end, nil};
    placementEditor = function() placement_editor:manip(pick_obj_safe()) end;
    grab = function() player_ctrl:grab() end;
}

local drive_binding_functions = {
    forwards = {function() player_ctrl.vehicle:setPush(true) end, function() player_ctrl.vehicle:setPush(false) end};
    backwards = {function() player_ctrl.vehicle:setPull(true) end, function() player_ctrl.vehicle:setPull(false) end};
    steerLeft = {function() player_ctrl.vehicle:setShouldSteerLeft(true) end, function() player_ctrl.vehicle:setShouldSteerLeft(false) end};
    steerRight = {function() player_ctrl.vehicle:setShouldSteerRight(true) end, function() player_ctrl.vehicle:setShouldSteerRight(false) end};
    abandon = function() player_ctrl:abandonVehicle() end;
    handbrake = {function() player_ctrl.vehicle:setHandbrake(true) end, function() player_ctrl.vehicle:setHandbrake(false) end};
    zoomIn = {function() player_ctrl:zoomIn() end, nil, true};
    zoomOut = {function() player_ctrl:zoomOut() end, nil, true};
    realign = {function() player_ctrl.vehicle:realign() end, nil, true};
    specialUp = {function() player_ctrl.vehicle:setSpecialUp(true) end, function() player_ctrl.vehicle:setSpecialUp(false) end};
    specialDown = {function() player_ctrl.vehicle:setSpecialDown(true) end, function() player_ctrl.vehicle:setSpecialDown(false) end};
    specialLeft = {function() player_ctrl.vehicle:setSpecialLeft(true) end, function() player_ctrl.vehicle:setSpecialLeft(false) end};
    specialRight = {function() player_ctrl.vehicle:setSpecialRight(true) end, function() player_ctrl.vehicle:setSpecialRight(false) end};
    altUp = {function() player_ctrl.vehicle:setAltUp(true) end, function() player_ctrl.vehicle:setAltUp(false) end};
    altDown = {function() player_ctrl.vehicle:setAltDown(true) end, function() player_ctrl.vehicle:setAltDown(false) end};
    altLeft = {function() player_ctrl.vehicle:setAltLeft(true) end, function() player_ctrl.vehicle:setAltLeft(false) end};
    altRight = {function() player_ctrl.vehicle:setAltRight(true) end, function() player_ctrl.vehicle:setAltRight(false) end};
    special = function() player_ctrl.vehicle:special() end;
}

local foot_binding_functions = {
    forwards = {function() player_ctrl.actor:setForwards(true) end, function() player_ctrl.actor:setForwards(false) end};
    backwards = {function() player_ctrl.actor:setBackwards(true) end, function() player_ctrl.actor:setBackwards(false) end};
    strafeLeft = {function() player_ctrl.actor:setStrafeLeft(true) end, function() player_ctrl.actor:setStrafeLeft(false) end};
    strafeRight = {function() player_ctrl.actor:setStrafeRight(true) end, function() player_ctrl.actor:setStrafeRight(false) end};
    abandon = function() player_ctrl:abandonVehicle() end;
    jump = {function() player_ctrl.actor:setJump(true) end, function() player_ctrl.actor:setJump(false) end};
    run = {function() player_ctrl.actor:setRun(true) end, function() player_ctrl.actor:setRun(false) end};
    crouch = {function() player_ctrl.actor:setCrouch(true) end, function() player_ctrl.actor:setCrouch(false) end};
    zoomIn = {function() player_ctrl:zoomIn() end, nil, true};
    zoomOut = {function() player_ctrl:zoomOut() end, nil, true};
}


local function process_user_table(name, given, default)
    for k,v in pairs(given) do
        if default[k] == nil then
            echo(name.." contained unrecognised field \""..k.."\", ignoring.")
            given[k] = nil
        end
    end
    for k,v in pairs(default) do
        if given[k] == nil then
            given[k] = default[k]
        end
    end
end

process_user_table("user_cfg", user_cfg, user_cfg_default)
process_user_table("debug_cfg", debug_cfg, debug_cfg_default)
process_user_table("user_core_bindings", user_core_bindings, default_user_core_bindings)
process_user_table("user_ghost_bindings", user_ghost_bindings, default_user_ghost_bindings)
process_user_table("user_drive_bindings", user_drive_bindings, default_user_drive_bindings)
process_user_table("user_foot_bindings", user_foot_bindings, default_user_foot_bindings)


local function bind(name, data, functions, tab)
    local function bind_it(key)
        local data = functions[name]
        if type(data) == "table" then
            -- table[1,2] may be nil so unpack won't work
            tab.bind(tab, key, data[1], data[2], data[3])
        else
            tab.bind(tab, key, data)
        end
    end
    if type(data) == "table" then
        for _,key in ipairs(data) do
            bind_it(key)
        end
    else
        bind_it(data)
    end
end

local function process_bindings(bindings, functions, tab)
    for name,key in pairs(bindings) do
        bind(name, key, functions, tab)
    end
end

process_bindings(user_core_bindings, core_binding_functions, ui.coreBinds)
process_bindings(user_ghost_bindings, ghost_binding_functions, player_ctrl.ghostBinds)
process_bindings(user_drive_bindings, drive_binding_functions, player_ctrl.driveBinds)
process_bindings(user_foot_bindings, foot_binding_functions, player_ctrl.footBinds)






local function commit(c, p, flush, partial)

    flush = flush or false
    partial = partial or false

    gfx_option("AUTOUPDATE",false)

    local reset_texture_pane = false or flush
    local reset_shaders = false or flush
    local reset_materials = false or flush
    local reset_deferred_shaders = false or flush
    local reset_deferred_materials = false or flush

    for k,v in pairs(p) do
        if c[k] ~= v then
            c[k] = v
    
            if k == "shadowRes" then
                gfx_option("SHADOW_RES",v)
                reset_shaders = true
            elseif k == "shadowCast" then
                gfx_option("SHADOW_CAST",v)
            elseif k == "shadowReceive" then
                gfx_option("SHADOW_RECEIVE",v)
                reset_materials = true
                reset_deferred_shaders = true
                reset_deferred_materials = true
            elseif k == "shadowEmulatePCF" then
                gfx_option("SHADOW_EMULATE_PCF", v)
                reset_shaders = true
            elseif k == "shadowFilterTaps" then
                gfx_option("SHADOW_FILTER_TAPS",v)
                reset_shaders = true
            elseif k == "shadowFilterSize" then
                gfx_option("SHADOW_FILTER_SIZE",v)
                reset_shaders = true
            elseif k == "shadowFilterNoise" then
                gfx_option("SHADOW_FILTER_DITHER_TEXTURE",v)
                reset_shaders = true
                reset_materials = true
            elseif k == "shadowFilterDither" then
                gfx_option("SHADOW_FILTER_DITHER",v)
                reset_shaders = true
            elseif k == "shadowPCSSPadding" then
                gfx_option("SHADOW_PADDING",v)
                reset_shaders = true
            elseif k == "shadowPCSSStart" then
                gfx_option("SHADOW_START",v)
            elseif k == "shadowPCSSEnd0" then
                gfx_option("SHADOW_END0",v)
                reset_shaders = true
            elseif k == "shadowPCSSEnd1" then
                gfx_option("SHADOW_END1",v)
                reset_shaders = true
            elseif k == "shadowPCSSEnd2" then
                gfx_option("SHADOW_END2",v)
                reset_shaders = true
            elseif k == "shadowPCSSAdj0" then
                gfx_option("SHADOW_OPTIMAL_ADJUST0",v)
            elseif k == "shadowPCSSAdj1" then
                gfx_option("SHADOW_OPTIMAL_ADJUST1",v)
            elseif k == "shadowPCSSAdj2" then
                gfx_option("SHADOW_OPTIMAL_ADJUST2",v)
            elseif k == "shadowPCSSSpreadFactor0" then
                gfx_option("SHADOW_SPREAD_FACTOR0", v)
                reset_shaders = true
            elseif k == "shadowPCSSSpreadFactor1" then
                gfx_option("SHADOW_SPREAD_FACTOR1", v)
                reset_shaders = true
            elseif k == "shadowPCSSSpreadFactor2" then
                gfx_option("SHADOW_SPREAD_FACTOR2", v)
                reset_shaders = true
            elseif k == "shadowFadeStart" then
                gfx_option("SHADOW_FADE_START",v)
                reset_shaders = true

            elseif k == "reverseSpecular" then
                reset_shaders = true
            elseif k == "textureShrink" then
                reset_materials = true
            elseif k == "FOV" then
                gfx_option("FOV",v)
            elseif k == "res" then
                gfx_option("FULLSCREEN_WIDTH",v[1])
                gfx_option("FULLSCREEN_HEIGHT",v[2])
            elseif k == "fullscreen" then
                gfx_option("FULLSCREEN",v)
            elseif k == "farClip" then
                gfx_option("FAR_CLIP",v)
            elseif k == "visibility" then
                core_option("VISIBILITY",v)
            elseif k == "vertexProcessing" then
                reset_materials = true
                reset_shaders = true
            elseif k == "textureFetches" then
                reset_shaders = true
            elseif k == "fragmentProcessing" then
                reset_materials = true
                reset_shaders = true
            elseif k == "heightmapBlending" then
                reset_shaders = true
            elseif k == "falseColour" then
                reset_shaders = true
                reset_materials = true
            elseif k == "graphicsRAM" then
                gfx_option("RAM",v)
                set_texture_budget(v*1024*1024)
                set_mesh_budget(0)
            elseif k == "lockMemory" then
                if v then mlockall() else munlockall() end

            elseif k == "polygonMode" then
                reset_materials = true
            elseif k == "normalMaps" then
                reset_materials = true
            elseif k == "diffuseMaps" then
                reset_materials = true
            elseif k == "specularMaps" then
                reset_materials = true
            elseif k == "translucencyMaps" then
                reset_materials = true
            elseif k == "colourMaps" then
                reset_materials = true
            elseif k == "vertexDiffuse" then
                reset_shaders = true
            elseif k == "anisotropy" then
                reset_materials = true
            elseif k == "filtering" then
                reset_materials = true
            elseif k == "textureAnimation" then
                reset_materials = true
            elseif k == "textureScale" then
                reset_materials = true
            elseif k == "fog" then
                gfx_option("FOG",v)
                reset_shaders = true
            elseif k == "boundingBoxes" then
                sm.showBoundingBoxes = v
            elseif k == "physicsWireFrame" then
                physics_option("DEBUG_WIREFRAME", v)
            elseif k == "physicsDebugWorld" then
                physics.debugWorld = v
            elseif k == "mouseSensitivity" then
                -- next mouse movement picks this up
            elseif k == "mouseInvert" then
                -- next mouse movement picks this up
            elseif k == "vsync" then
                gfx_option("VSYNC",v)
            elseif k == "screenshotFormat" then
                -- nothing to do, next screenshot will pick this up
            elseif k == "shadingModel" then
                reset_shaders = true
            elseif k == "gammaCorrectionOut" then
                reset_shaders = true
            elseif k == "gammaCorrectionIn" then
                reset_shaders = true
            elseif k == "maxLightRange" then
                reset_shaders = true
            elseif k == "fixedFunction" then
                reset_materials = true
            elseif k == "texturePane" then
                reset_texture_pane = true
            elseif k == "texturePaneSize" then
                reset_texture_pane = true
            elseif k == "deferredShading" then
                gfx_option("DEFERRED",v)
                reset_materials = true
            elseif k == "monitorHeight" then
                gfx_option("MONITOR_HEIGHT",v)
            elseif k == "monitorEyeDistance" then
                gfx_option("MONITOR_EYE_DISTANCE",v)
            elseif k == "minPerceivedDepth" then
                gfx_option("MIN_PERCEIVED_DEPTH",v)
            elseif k == "maxPerceivedDepth" then
                gfx_option("MAX_PERCEIVED_DEPTH",v)
            elseif k == "lowPowerMode" then
                -- next frame render picks this up too
                if v then
                    physics_option("STEP_SIZE", 0.05)
                    physics_option("SOLVER_ITERATIONS", 4)
                else
                    physics_option("STEP_SIZE", 0.005)
                    physics_option("SOLVER_ITERATIONS", 15)
                end
            elseif k == "audioMasterVolume" then
                audio_option("MASTER_VOLUME",v)
            elseif k == "vehicleCameraTrack" then
            elseif k == "thirdPerson" then
            else
                error("Unexpected: "..k)
            end
        end
    end

    gfx_option("AUTOUPDATE",true)

    if partial then return end

    if reset_texture_pane then
        if debug_cfg.texturePane ~= "none" then
            if debug_cfg.texturePane == "shadow1" then
                gfx.debugTexturePane.material:setTextureName(0,0,0,sm:getShadowTexture(0).name)
            elseif debug_cfg.texturePane == "shadow2" then
                gfx.debugTexturePane.material:setTextureName(0,0,0,sm:getShadowTexture(1).name)
            elseif debug_cfg.texturePane == "shadow3" then
                gfx.debugTexturePane.material:setTextureName(0,0,0,sm:getShadowTexture(2).name)
            else
                gfx.debugTexturePane.material:setTextureName(0,0,0,debug_cfg.texturePane)
            end
            gfx.debugTexturePane.visible = true
        else
            gfx.debugTexturePane.visible = false
        end
        local sz = debug_cfg.texturePaneSize
        gfx.debugTexturePane.resize = Hud.LEFT(-1,sz,sz)
    end

    if reset_deferred_shaders then
        do_reset_deferred_shaders()
    end

    if reset_deferred_materials then
        do_reset_deferred_materials()
    end
    
    if reset_shaders then
        do_reset_shaders()
    end

    if reset_materials then
        do_reset_materials()
    end
    
end

make_active_table(user_cfg, user_cfg_spec,  commit)
make_active_table(debug_cfg, debug_cfg_spec,  commit)

commit(user_cfg.c, user_cfg.p, false, true)
commit(debug_cfg.c, debug_cfg.p, false, true)
debug_cfg.autoUpdate = true
user_cfg.autoUpdate = true

commit(user_cfg.c, user_cfg.p, true, false)





function save_user_cfg(filename)
    filename = filename or "user_cfg.lua"
    local f = io.open(filename,"w")
    f:write([[
print('Reading user_cfg.lua')

-- This file is output automatically by Grit.
-- You may edit it, but stick to the basic format.
-- Any clever Lua code will be lost.
--
-- WARNING:  If you are changing from a default value
-- to a custom value, don't forget to uncomment the line
-- (remove the leading -- ) otherwise it will not be
-- processed and your changes will be lost.

]])

    local function write_table(table_name, tab, defaults, docs)
        f:write(table_name.." = {\n")
        local names, num, max_name_len = table.keys(tab,100)
        table.sort(names)
        for _,name in ipairs(names) do
            local val = tab[name]
            local dval = defaults[name]
            local doc = docs[name]
            local line = ''
            if val == dval then
                line = line .. "--"
            end
            line = line.."    "..tostring(name)..(" "):rep(max_name_len-#name).." = "..dump(val,false)..";"
            if doc ~= nil then
                local len_so_far = #line
                line = line..(" "):rep(50-len_so_far).."  -- "
                if val ~= dval then
                    line = line .. "DEFAULT: "..dump(dval,false).."  "
                end
                line = line.."("..doc..")"
            end
            f:write(line.."\n")
        end
        f:write("}\n\n")
    end

    -- use proposed rather than current settings, to avoid writing out the autoUpdate header
    write_table("user_cfg", user_cfg.p, user_cfg_default, user_cfg_doc)
    write_table("debug_cfg", debug_cfg.p, debug_cfg_default, debug_cfg_doc)
    write_table("user_core_bindings", user_core_bindings, default_user_core_bindings, {})
    write_table("user_ghost_bindings", user_ghost_bindings, default_user_ghost_bindings, {})
    write_table("user_drive_bindings", user_drive_bindings, default_user_drive_bindings, {})
    write_table("user_foot_bindings", user_foot_bindings, default_user_foot_bindings, {})

    f:close()
end


