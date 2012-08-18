-- Lua file generated by Blender class export script.
-- WARNING: If you modify this file, your changes will be lost if it is subsequently re-exported from blender

class "TestActor" (CharClass) {
    renderingDistance = 100.0;
    castShadows = true;
    placementZOffset = 1;
    placementRandomRotation = false;

    height = 1.808;
    radius = 0.393;

    footPos = vector3(0,0,0); -- maps to object defaul center of gravity (in this case middle of the cube), slowly falling down
    --footPos = vector3(0,0,-0.9); -- maps to the object's bottom, the actual foot point, falling down fast
    --footPos = vector3(0,0,0.9); -- maps to object's top, keeps flying up O_o

    camAttachPos = vector3(0,0,0.854);
}

