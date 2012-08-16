--
-- This is the Scarman lua. just so that jostvice knows it is the scarman lua, because he has 900 .luas opened and he finds it slow to identify which lua it is. hello
--
--

local mu_front = 1.32
local mu_rear_side = 1.6
local mu_rear_drive = 1.6

local len = 0.1 --amount wheel can go up an down
local rad = 0.354 -- wheel radius
local wheelX, wheelY, wheelY2, wheelZ = 0.731, 1.063, -1.611, -0.217 --wheel Y and wheel Y 2 are the two axle's Y. the rest explains itself
local slack = 0.0 -- dunno

class "../Scarman" (Vehicle) {
        gfxMesh = "Scarman/Body.mesh",
        colMesh = "Scarman/Body.gcol",
        placementZOffset=1.4,
        powerPlots = {
                [-1] = { [0] = -6000; [10] = -6000; [25] = -4000; [40] = 0; },
                [0] = {}, --neutral
                [1] = { [0] = 8000; [10] = 8000; [20] = 7000; [100] = 7000; },
        },
        meshWheelInfo = {
                front_left = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.2;
                  left=true; attachPos=vector3(-wheelX,wheelY,wheelZ); len=len; slack=slack; mesh="Scarman/Wheel.mesh"; brakeMesh="Scarman/BrakePad.mesh"
                },

                front_right = {
                  steer=1; castRadius=0.05; rad=rad; mu=mu_front; sport=1.1; massShare = 1.2;
                  left=false; attachPos=vector3(wheelX,wheelY,wheelZ); len=len; slack=slack; mesh="Scarman/Wheel.mesh"; brakeMesh="Scarman/BrakePad.mesh"
                },

                rear_left = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 0.8;
                  left=true; attachPos=vector3(-wheelX,wheelY2,wheelZ); len=len; slack=slack; mesh="Scarman/Wheel.mesh"; brakeMesh="Scarman/BrakePad.mesh"
                },

                rear_right = {
                  rad=rad; drive=1; castRadius=0.05; handbrake=true; driveMu = mu_rear_drive; sideMu = mu_rear_side; sport = 1.1; massShare = 0.8;
                  left=false; attachPos=vector3(wheelX,wheelY2,wheelZ); len=len; slack=slack; mesh="Scarman/Wheel.mesh"; brakeMesh="Scarman/BrakePad.mesh"
                },
        },
		lightHeadLeft = {
                pos=vector3(-0.652, 1.702, 0.169), coronaPos=vector3(-0.652, 1.702, 0.169),
        };
        lightHeadRight = {
                pos=vector3( 0.652, 1.702, 0.169), coronaPos=vector3( 0.652, 1.702, 0.169),
        };
        lightBrakeLeft = {
                pos=vector3(-0.613, -2.554, 0.332), coronaPos=vector3(-0.613, -2.554, 0.332), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        };
        lightBrakeRight = {
                pos=vector3( 0.613, -2.554, 0.332), coronaPos=vector3( 0.613, -2.554, 0.3325), coronaColour=vector3(0.05, 0, 0), coronaSize = 1,
        };
        lightReverseLeft = {
                pos=vector3(-0.593, -2.534, 0.215), coronaPos=vector3( -0.593, -2.534, 0.215), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        };
        lightReverseRight = {
                pos=vector3( 0.593, -2.534, 0.215), coronaPos=vector3( 0.593, -2.534, 0.215), coronaColour=vector3(0.03, 0.03, 0.03), coronaSize = 0.7,
        };
		colourSpec = {
                { probability=1, { "velvet_red",  },
                },
				{ probability=1, { "ice_silver",  },
                },
				{ probability=1, { "carbon_gray",  },
                },
				{ probability=1, { "midnight_black",  },
                },
				{ probability=1, { "cream_white",  },
                },
				{ probability=1, { "crystal_blue",  },
                },
        },
        engineSmokeVents = {
                vector3(0.0, 1.881, 0.093);
        };
        exhaustSmokeVents = {
                vector3(-0.46, -2.6, -0.2);
                vector3(0.46, -2.6, -0.2);
        };
}


class "Wheel" (ColClass) { placementZOffset = 0.3; castShadows = true }


-- most materials are temporal and will probably joined
material "Carpaint" { paintColour = 1; specularColour={1,1,1}; gloss = 30; microFlakes=true; }
material "LightPlastic" { diffuseColour ={20,20,20}; specularColour={1,1,1}; gloss = 10; }
material "Chrome" { diffuseColour ={0.749,0.749,0.749}; specularColour={1,1,1}; gloss = 30; }
material "Pattern" { diffuseColour ={0.065,0.065,0.065}; specularColour={0.8,0.8,0.8}; gloss = 2; }
material "Blacky" { diffuseColour ={0,0,0}; specularColour={1,1,1}; gloss = 20; }
material "Headlight" { gloss = 30; specularColour={1,1,1}; alpha =0.7 }
material "Brakelight" { diffuseColour ={1.0,0.0,0.0}; specularColour={1,1,1}; gloss = 30; alpha =0.7 }
material "Turnlight" { diffuseColour ={1.0,0.597,0}; specularColour={1,1,1}; gloss = 30; alpha =0.7 }

