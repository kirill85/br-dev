print('Reading user_cfg.lua')

-- This file is output automatically by Grit.
-- You may edit it, but stick to the basic format.
-- Any clever Lua code will be lost.
--
-- WARNING:  If you are changing from a default value
-- to a custom value, don't forget to uncomment the line
-- (remove the leading -- ) otherwise it will not be
-- processed and your changes will be lost.

user_cfg = {
--    anisotropy              = 0;                  -- (avoids blurring of roads)
--    audioMasterVolume       = 0.75;               -- (Master audio volume)
--    fullscreen              = false;              -- (as opposed to windowed mode)
--    graphicsRAM             = 128;                -- (Size of textures+mesh cache to maintain)
--    lockMemory              = true;               -- (avoids excessive disk IO)
--    lowPowerMode            = false;              -- (Reduce FPS and physics accuracy)
--    maxPerceivedDepth       = 2;                  -- (todo)
--    minPerceivedDepth       = 0.3;                -- (todo)
--    monitorEyeDistance      = 0.6;                -- (todo)
--    monitorHeight           = 0.27;               -- (todo)
--    mouseInvert             = false;              -- (whether forward motion should look down)
--    mouseSensitivity        = 0.03;               -- (how easy it is to turn with mouse)
--    res                     = { 800, 600 };       -- (desktop resolution when fullscreened)
--    screenshotFormat        = "png";              -- (format in which to store textures)
--    shadowEmulatePCF        = false;              -- (antialias shadow edges)
--    shadowFadeStart         = 150;                -- (distance where shadow starts to fade)
--    shadowFilterDither      = false;              -- (another cheap way of getting softer shadows)
--    shadowFilterNoise       = true;               -- (a cheap way of getting softer shadows)
--    shadowFilterSize        = 4;                  -- (size of penumbra)
--    shadowFilterTaps        = 4;                  -- (quality of soft shadows)
--    shadowPCSSAdj0          = 3;                  -- ('optimal adjust' for 1st shadow map)
--    shadowPCSSAdj1          = 1;                  -- ('optimal adjust' for 2nd shadow map)
--    shadowPCSSAdj2          = 1;                  -- ('optimal adjust' for 3rd shadow map)
--    shadowPCSSEnd0          = 20;                 -- (distance from camera to transition to 2nd shadow map)
--    shadowPCSSEnd1          = 50;                 -- (distance from camera to transition to 3rd shadow map)
--    shadowPCSSEnd2          = 200;                -- (distance from camera where shadows end)
--    shadowPCSSPadding       = 0.8;                -- (overlap between shadow regions)
--    shadowPCSSSpreadFactor0 = 1;                  -- (penumbra multiplier for 1st shadow map)
--    shadowPCSSSpreadFactor1 = 1;                  -- (penumbra multiplier for 2st shadow map)
--    shadowPCSSSpreadFactor2 = 0.28;               -- (penumbra multiplier for 3rd shadow map)
--    shadowPCSSStart         = 0.2;                -- (distance from camera where shadows start)
--    shadowRes               = 1024;               -- (resolution of the shadow textures)
--    textureShrink           = 0;                  -- (mipmap bias)
--    vehicleCameraTrack      = true;               -- (Camera automatically follows vehicles)
--    visibility              = 1;                  -- (factor on draw distance)
--    vsync                   = false;              -- (avoid corruption due to out of sync monitor updates)
}

debug_cfg = {
--    FOV                = 75;                      -- (field of view in degrees)
--    boundingBoxes      = false;                   -- (show octree culling abstractions)
--    colourMaps         = true;                    -- (whether to use colour maps)
--    deferredShading    = true;                    -- (Whether to render the scene with deferred shading or forward shading)
--    diffuseMaps        = true;                    -- (whether to use diffuse maps)
--    falseColour        = false;                   -- (various debug displays)
--    farClip            = 800;                     -- (how far away is maximum depth)
--    filtering          = true;                    -- (turn off to see the texels clearly)
--    fixedFunction      = false;                   -- (use the classic fixed function pipeline)
--    fog                = true;                    -- (enable distance fog)
--    fragmentProcessing = true;                    -- (for eliminating fragment shader work)
--    gammaCorrectionIn  = 2.2;                     -- (manual gamma correction for textures)
--    gammaCorrectionOut = 2.2;                     -- (manual reverse gamma correction for framebuffer)
--    heightmapBlending  = true;                    -- (whether to use the heightmap when blending)
--    maxLightRange      = 1;                       -- (A non-hdr pipeline would only allow 1 here)
--    normalMaps         = true;                    -- (whether to use normal maps)
--    physicsDebugWorld  = true;                    -- (don't limit debug display to moving objects)
--    physicsWireFrame   = false;                   -- (show physics meshes)
--    polygonMode        = "SOLID";                 -- (wireframe, etc)
--    reverseSpecular    = true;                    -- (Whether to use dimmer specular highlights on the rear side of objects as well)
--    shadingModel       = "SHARP";                 -- (the way lighting is calculated)
--    shadowCast         = true;                    -- (enable casting phase)
--    shadowReceive      = true;                    -- (enable receiving phase)
--    specularMaps       = true;                    -- (whether to use specular maps)
--    textureAnimation   = true;                    -- (whether or not to animate textures)
--    textureFetches     = true;                    -- (use proper fetches instead of procedural placeholders)
--    texturePane        = "none";                  -- (display texture map, specials are none, shadow1, shadow2, shadow3)
--    texturePaneSize    = 128;                     -- (how large to show the shadow map)
--    textureScale       = true;                    -- (enable support for texture scaling from materials)
--    translucencyMaps   = true;                    -- (whether to use translucency maps)
--    vertexDiffuse      = true;                    -- (whether to use the diffuse channel in the meshes)
--    vertexProcessing   = true;                    -- (for eliminating vertex shader work)
}

user_core_bindings = {
--    boundingBoxes       = "C+F8";
--    clearPlaced         = "F3";
--    clearProjectiles    = "F4";
--    console             = "Tab";
--    fast                = "right";
--    gameLogicStep       = "F11";
--    physicsDebugWorld   = "C+F7";
--    physicsOneToOne     = "F10";
--    physicsPause        = "F9";
--    physicsSplitImpulse = "C+F10";
--    physicsWireFrame    = "F7";
--    record              = "C+F12";
--    screenShot          = "F12";
--    skyEdit             = "C+F5";
--    skyPause            = "F5";
--    toggleFullScreen    = "A+Return";
--    wireFrame           = "F8";
}

user_ghost_bindings = {
--    ascend          = "Space";
--    backwards       = "s";
--    board           = "f";
--    descend         = "Shift";
--    forwards        = "w";
--    grab            = "g";
--    placementEditor = "e";
--    simpleMenuShow  = "`";
--    strafeLeft      = "a";
--    strafeRight     = "d";
--    teleportDown    = "BackSpace";
--    teleportUp      = "Return";
}

user_drive_bindings = {
--    abandon      = "f";
--    altDown      = "Down";
--    altLeft      = "Left";
--    altRight     = "Right";
--    altUp        = "Up";
--    backwards    = "s";
--    forwards     = "w";
--    handbrake    = "Space";
--    realign      = "Return";
--    special      = "BackSpace";
--    specialDown  = "PageDown";
--    specialLeft  = "q";
--    specialRight = "e";
--    specialUp    = "PageUp";
--    steerLeft    = "a";
--    steerRight   = "d";
--    zoomIn       = { "up", "S+v" };
--    zoomOut      = { "down", "v" };
}

user_foot_bindings = {
--    abandon     = "f";
--    backwards   = "s";
--    crouch      = "c";
--    forwards    = "w";
--    jump        = "Space";
--    run         = "Shift";
--    strafeLeft  = "a";
--    strafeRight = "d";
--    zoomIn      = { "up", "S+v" };
--    zoomOut     = { "down", "v" };
}

