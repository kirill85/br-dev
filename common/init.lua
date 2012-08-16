-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

echo ("Loading common assets")

include "particles/init.lua"
include "pmat/init.lua"
include "mat/init.lua"
include "carcols.lua"

ui:bind("F1", function()
    user_cfg.vsync = not user_cfg.vsync
    if user_cfg.vsync then
        echo("vsync on")
    else
        echo("vsync off")
    end
end)
ui:bind("middle", function() physics.prodding = true end, function() physics.prodding = false end)

