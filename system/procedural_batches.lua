-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the GNU GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.html

print("Loading procedural_batches.lua")

-- TODO: error check (spelling of fields)
ProceduralBatchClasses = ProceduralBatchClasses or {}

function physics:setProceduralBatchClass(name, tab)
        local function default (k, v) 
                if tab[k] == nil then tab[k] = v end 
        end
        name = fqn(name)

        default("mesh", "/common/veg/TropPlant1.mesh")
        default("triangles", 50000)
        default("tangents", false)
        default("density", 0.01)
        default("minSlope", 0)
        default("maxSlope", 180)
        default("minElevation", -10000)
        default("maxElevation", 10000)
        default("noZ", false)
        default("alignSlope", false)
        default("rotate", false)
        default("seed", false)
        default("castShadows", true)

        tab.mesh = fqn(tab.mesh)

        -- XXX HACK! this should be done by the background loader using resource dependencies
        --disk_resource_load_indefinitely(tab.mesh)

        local poc = ProceduralBatchClasses[name]
        if poc == nil then
                -- create material
                poc = {}
                ProceduralBatchClasses[name] = poc
        end
        for k,v in pairs(tab) do poc[k] = v end
        return poc
end

function physics:getProceduralBatchClass(name)
        name = fqn(name)
        return ProceduralBatchClasses[name]
end

