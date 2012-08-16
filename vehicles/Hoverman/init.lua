-- hijack of JostVice's Scarman
local mass = 1400
local front_pid = {
    p = 15000;
    i = 20;
    d = 2500;
    min= -2;
    max= 2;
}

class "../Hoverman" (Hover) {
        gfxMesh = "Hoverman/Body.mesh";
        colMesh = "Hoverman/Body.gcol";
        placementZOffset=1.4;
        
        jetsHover = {
            {pos = vector3(-0.9, 1.08, -0.19), pid = front_pid}; --hovering front left
            {pos = vector3(0.9, 1.08, -0.19), pid = front_pid}; --hovering font right
            {pos = vector3(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vector3(-0.9, -1.6, -0.19)}; --hovering rear left
        };
        jetsInfo = {
            {pos = vector3(0, -2.7, 0)}; -- push/pull jet
            {pos = vector3(0, 1.35, 0.057)}; -- front steer jet
            {pos = vector3(0, -2.19, 0.057)}; -- rear steer jet
            {pos = vector3(-0.9, 1.08, -0.19)}; --hovering front left
            {pos = vector3(0.9, 1.08, -0.19)}; --hovering font right
            {pos = vector3(0.9, -1.6, -0.19)}; --hovering rear right
            {pos = vector3(-0.9, -1.6, -0.19)}; --hovering rear left
        };
        jetsControl = {
            forwards = { V_FORWARDS*mass*10 };
            backwards = { V_BACKWARDS*mass*10 };
            steerLeft = { V_ZERO, V_LEFT*mass*8.2, V_RIGHT*mass*5 };
            steerRight = { V_ZERO, V_RIGHT*mass*8.2, V_LEFT*mass*5 };
            strafeLeft = { V_ZERO, V_LEFT*mass*8.2, V_LEFT*mass*5};
            strafeRight = { V_ZERO, V_RIGHT*mass*8.2, V_RIGHT*mass*5};
        };
        
		colourSpec = {
                { probability=1, { "velvet_red",},},
				{ probability=1, { "ice_silver",},},
				{ probability=1, { "carbon_gray",},},
				{ probability=1, { "midnight_black",},},
				{ probability=1, { "cream_white",},},
				{ probability=1, { "crystal_blue",},},
        };
        
        engineSmokeVents = {
                vector3(0.0, 1.881, 0.093);
        };
}

-- most materials are temporal and will probably joined
material "Carpaint" { paintColour = 1; specularColour={1,1,1}; gloss = 30; microFlakes=true; }
material "LightPlastic" { diffuseColour ={20,20,20}; specularColour={1,1,1}; gloss = 10; }
material "Chrome" { diffuseColour ={0.749,0.749,0.749}; specularColour={1,1,1}; gloss = 30; }
material "Pattern" { diffuseColour ={0.065,0.065,0.065}; specularColour={0.8,0.8,0.8}; gloss = 2; }
material "Blacky" { diffuseColour ={0,0,0}; specularColour={1,1,1}; gloss = 20; }
material "Headlight" { gloss = 30; specularColour={1,1,1}; alpha =0.7 }
material "Brakelight" { diffuseColour ={1.0,0.0,0.0}; specularColour={1,1,1}; gloss = 30; alpha =0.7 }
material "Turnlight" { diffuseColour ={1.0,0.597,0}; specularColour={1,1,1}; gloss = 30; alpha =0.7 }

