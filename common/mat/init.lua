-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

material "Red" { diffuseColour={.5,0,0}, specularColour={1,0,0} }
material "Blue" { diffuseColour={0,0,.5}, specularColour={0,0,1} }
material "Green" { diffuseColour={0,.5,0}, specularColour={0,1,0} }
material "Yellow" { diffuseColour={.5,.5,0}, specularColour={1,1,0} }
material "Orange" { diffuseColour={0.5,0.1,0}, specularColour={1,0.5,0} }
material "Cyan" { diffuseColour={0,.5,.5}, specularColour={0,1,1} }
material "Magenta" { diffuseColour={.5,0,.5}, specularColour={1,0,1} }
material "Black" { diffuseColour={.01,0,0}, specularColour={.2,0,0} }
material "White" { diffuseColour={.7,.7,.7}, specularColour={1,1,1} }
material "Grey" { diffuseColour={.5,.5,.5}, specularColour={.5,.5,.5} }

material "Test" { diffuseMap="../tex/Test.dds" }
material "TestNorm" { diffuseMap="../tex/Test.dds", normalMap="../tex/Test_n.dds" }

material "Burnt" { diffuseColour={0.1072549, 0.04, 0.015} }

material "Grass" { diffuseMap = "../tex/davec/Grass_d.dds" }
material "PackedGravel" { diffuseMap = "../tex/davec/PackedGravel_d.dds", normalMap = "../tex/davec/PackedGravel_n.dds", specularColour=vector3(0.12,0.12,0.12); specularMap = "../tex/davec/PackedGravel_d.dds", }
material "RoadSurface" { diffuseMap = "../tex/davec/RoadSurface_d.dds", normalMap = "../tex/davec/RoadSurface_n.dds", specularColour=vector3(0.12,0.12,0.12), specularMap = "../tex/davec/RoadSurface_s.dds" }
material "RedBrick" { diffuseMap = "../tex/davec/RedBrick_d.dds", normalMap = "../tex/davec/RedBrick_n.dds", vertexAmbient=true }
material "RoofTiles" { diffuseMap="../tex/davec/RoofTiles_d.dds", specularFromDiffuse={-1,1}, diffuseColour=srgb(248, 253, 255) , specularColour=srgb(248, 253, 255), vertexAmbient=true }

