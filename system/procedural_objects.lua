-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the GNU GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.html

print("Loading procedural_objects.lua")

-- TODO: error check (spelling of fields)
ProceduralObjectClasses = ProceduralObjectClasses or {}

function physics:setProceduralObjectClass(name, tab)
        name = fqn(name)
        tab.class = fqn(tab.class) or "/common/veg/TropPlant1"
        tab.density = tab.density or 0.01
        tab.minSlope = tab.minSlope or 0
        tab.maxSlope = tab.maxSlope or 180
        tab.minElevation = tab.minElevation or -10000
        tab.maxElevation = tab.maxElevation or 10000
        tab.noZ = tab.noZ or false
        tab.alignSlope = tab.alignSlope or false
        tab.rotate = tab.rotate or false
        tab.seed = tab.seed or false
        local poc = ProceduralObjectClasses[name]
        if poc == nil then
                -- create material
                poc = {}
                ProceduralObjectClasses[name] = poc
        end
        for k,v in pairs(tab) do poc[k] = v end
        return poc
end

function physics:getProceduralObjectClass(name)
        name = fqn(name)
        return ProceduralObjectClasses[name]
end

