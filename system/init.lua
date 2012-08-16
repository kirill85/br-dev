-- (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- TODO: refactor the whole game code to use this DEBUG thingy properly
-- to avoid to include unneeded shit if DEBUG is not set
DEBUG = true -- whether or not to include the debug data, dirty hax and so on

print "Initialising script..."

io.stdout:setvbuf("no") -- no output buffering
collectgarbage("setpause",200) -- begin a gc cycle after blah% increase in ram use
collectgarbage("setstepmul",200) -- collect at blah% the rate of new object creation

--set_texture_verbose(true)
--set_mesh_verbose(true)
--set_keyb_verbose(true)

initialise_all_resource_groups()

include "strict.lua"
include "util.lua"
include "abbrev.lua"
include "hud.lua"

print "Starting game engine..."

main = {
        shouldQuit = false,
        frameCallbacks = CallbackReg.new()
}

function quit()
        main.shouldQuit = true
end
exit = quit

function main:run (...)
        -- execute cmdline arguments on console
        local arg = ""
        for i=2,select('#',...) do
                arg = arg.." "..select(i,...)
        end
        if #arg > 0 then
                console:exec(arg:sub(2))
        end

        local last_focus = true

        local failName = {}

        -- rendering loop
        while not clicked_close() and not main.shouldQuit do

                
                if last_focus and not have_focus() then
                        keyb_flush() -- get rid of any sticky keys
                        last_focus = false
                        ui:updateGrabbed()
                elseif not last_focus and have_focus() then
                        last_focus = true
                        ui:updateGrabbed()
                end


                xpcall(function ()
                        	failName.name = nil
                        	main.frameCallbacks:executeExtended(function (name,cb,path,...)
                                failName.name = name
                                --t:reset()
                                if cb == nil then
                                        --echo(RED.."Callback was nil: "..name)
                                        return true
                                end
                                path_stack_push_dir(path)
                                local result = cb(...)
                                path_stack_pop()
                                --local us = t.us
                                --if us>5000 and name~="GFX.frameCallback" then
                                --        print("callback \""..name.."\" took "..us/1000 .."ms ")
                                --end
                                return result
                        	end)
                        	failName.name = nil

                        	if get_main_win().isActive == false then
                           	    --sleep_seconds(0.2)
                                sleep(200000)
                        	end
                end,error_handler)

                if failName.name then
                        path_stack_pop()
                        echo("Removed frameCallback: "..failName.name)
                        main.frameCallbacks:removeByName(failName.name)
                end
        end

        save_user_cfg()

        env:shutdown()     
end

sm = get_sm()


include "ui.lua"

include "gfx.lua"

include "materials.lua"

include "physics.lua"
include "physical_materials.lua"
include "procedural_objects.lua"
include "procedural_batches.lua"

include "console_prompt.lua"
include "console.lua"

include "pid_ctrl.lua"

include "player_ctrl.lua"

include "capturer.lua"

include "configuration.lua"

include "env.lua"

include "audio.lua"

include "/classes/init.lua"
include "/common/init.lua"

safe_include "/autoexec.lua"

if DEBUG then
	include "simplemenu.lua" --hacky menu :D
	include "placement_editor.lua"
	include "/models/init.lua"
	include "/vehicles/init.lua"
end

