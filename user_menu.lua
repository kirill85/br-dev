simple_menu.Main_menu = {
	Title = "Main menu";
	{"Vehicles", function() simple_menu:show(simple_menu.Vehicles_menu) end};
	{"Maps", function() simple_menu:show(simple_menu.Maps_menu) end};
	{"Developers'", function() simple_menu:show(simple_menu.Dev_menu) end};
	{"Misc", function() simple_menu:show(simple_menu.Misc_menu) end};

	MenuType = "root";
}

simple_menu.Vehicles_menu = {
	Title = "Vehicles";
	{"Gallardo", function() place("/vehicles/Gallardo") end};
	{"Scarman", function() place("/vehicles/Scarman") end};
	{"Hoverman", function() place("/vehicles/Hoverman") end};

	MenuType = "child";
}

local loadMap = function(map)
	object_all_del();
	include "/system/env.lua"
	include(map)
end

simple_menu.Maps_menu = {
	Title = "Maps";
	{"Urban", function() loadMap("/maps/urban/init.lua") end};
	MenuType = "child";
}

simple_menu.Dev_menu = {
	Title = "Developers'";
	{"Keyboard verbose", function() set_keyb_verbose(not get_keyb_verbose()) end};
	{"Bounding boxes", function() debug_cfg.boundingBoxes = not debug_cfg.boundingBoxes end};
	{"Clear placed", clear_placed};
	{"Clear projectiles", clear_temporary};
	{"Clear everything", function() object_all_del() end};
	{"Wireframe", function()
		local pm = debug_cfg.polygonMode
		if pm == "SOLID" then
			debug_cfg.polygonMode = "SOLID_WIREFRAME"
		--elseif pm == "SOLID_WIREFRAME" then 
			--debug_cfg.polygonMode = "WIREFRAME"
		else    
			debug_cfg.polygonMode = "SOLID"
		end
    	end};
	{"Physics wireframe", function() debug_cfg.physicsWireFrame = not debug_cfg.physicsWireFrame end};
	{"Reinclude system/init.lua", function() include "/system/init.lua" end};

	MenuType = "child";
}

simple_menu.Misc_menu = {
	Title = "Misc";
	{"UnitCube", function() place("/models/unitcube/UnitCube") end};
    {"SmallCharacter", function() place "/models/small_character/SmallCharacter" end };
	{"MediumCharacter", function() place "/models/medium_character/MediumCharacter" end};
    {"BigCharacter", function() place "/models/big_character/BigCharacter" end};
    {"TestActor", function() place "/models/test/TestActor" end};
	{"Bunker1", function() place("/models/bunker1/Bunker1") end};
    {"Steps", function() simple_menu:show(simple_menu.Steps) end};
    {"Slopes", function() simple_menu:show(simple_menu.Slopes) end};

	MenuType = "child";
}

simple_menu.Steps = {
    Title = "Spawn Steps";
    {"15 Units", function() place("/models/steps/Steps15") end};
    {"29 Units", function() place("/models/steps/Steps29") end};
    {"31 Units", function() place("/models/steps/Steps31") end};
    {"50 Units", function() place("/models/steps/Steps50") end};
    {"100 Units", function() place("/models/steps/Steps100") end};
    
    MenuType = "child";
}

simple_menu.Slopes = {
    Title = "Spawn Slopes";
    {"22 Degrees", function() place("/models/slopes/Slope22") end};
    {"34 Degrees", function() place("/models/slopes/Slope34") end};
    {"45 Degrees", function() place("/models/slopes/Slope45") end};
    {"56 Degrees", function() place("/models/slopes/Slope56") end};
    {"68 Degrees", function() place("/models/slopes/Slope68") end};

    MenuType = "child";
}
