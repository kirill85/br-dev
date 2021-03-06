-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the GNU GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.html

V_ZERO  = vector3(0,0,0)
V_ID    = vector3(1,1,1)
V_NORTH = vector3(0,1,0)
V_SOUTH = vector3(0,-1,0)
V_EAST  = vector3(1,0,0)
V_WEST  = vector3(-1,0,0)
V_UP    = vector3(0,0,1)
V_DOWN  = vector3(0,0,-1)

V_FORWARDS  = V_NORTH
V_BACKWARDS = V_SOUTH
V_ABOVE     = V_UP
V_BELOW     = V_DOWN
V_LEFT      = V_WEST
V_RIGHT     = V_EAST

Q_ID = quat(1,0,0,0)

-- Quaternions are orientation *changes*, just like vectors are really position
-- *changes*.  As such, to use a quaternion as an orientation, we need a base
-- direction, just like we need a base vector vector3(0,0,0) to use vectors for
-- position data.  For everything grit-specific the base direction is V_NORTH.

Q_NORTH = quat(V_NORTH, V_NORTH)
Q_SOUTH = quat(V_NORTH, V_SOUTH)
Q_EAST  = quat(V_NORTH, V_EAST)
Q_WEST  = quat(V_NORTH, V_WEST)
Q_UP    = quat(V_NORTH, V_UP)
Q_DOWN  = quat(V_NORTH, V_DOWN)

Q_FORWARDS  = Q_NORTH
Q_BACKWARDS = Q_SOUTH
Q_ABOVE     = Q_UP
Q_BELOW     = Q_DOWN
Q_LEFT      = Q_WEST
Q_RIGHT     = Q_EAST

function euler (x,y,z)
        return quat(z,V_UP) * quat(y,V_NORTH) * quat(x,V_EAST)
end

METRES_PER_MILE = 1609

RESET = "\027[0m"
BOLD = "\027[1m"
NOBOLD = "\027[22m"
UNDERLINE = "\027[4m"
NOUNDERLINE = "\027[24m"
REVERSE = "\027[6m"
NOREVERSE = "\027[27m"
BLACK = "\027[30m"
RED = "\027[31m"
GREEN = "\027[32m"
YELLOW = "\027[33m"
BLUE = "\027[34m"
MAGENTA = "\027[35m"
CYAN = "\027[36m"
WHITE = "\027[37m"

function none_one_or_all(tab, f)
        if tab == nil then return end
        if type(tab)=="table" then
                for _,se in ipairs(tab) do f(se) end
        else    
                f(tab)
        end
end


function time(f,...)
        local before = seconds()
        f(...)
        local after = seconds()
        return after - before
end

function time_micros(f, ...)
        local before = micros()
        f(...)
        local after = micros()
        return after - before
end


function rgb (r,g,b) return vector3(r,g,b)/255 end
function v3pow (v, i) return vector3(math.pow(v.x, i), math.pow(v.y, i), math.pow(v.z, i)) end
function srgb(r,g,b) return v3pow(rgb(r,g,b), 2.2) end


function colour_norm (r,g,b)
        local luminance = math.max(math.max(r,g),b)
        return r/luminance, g/luminance, b/luminance
end
function colour_desaturate (r,g,b, amt)
        local luminance = (r+g+b)/3
        local r1,g1,b1 = luminance,luminance,luminance
        return lerp(r1,r,amt), lerp(g1,g,amt), lerp(b1,b,amt)
end

function colour_ensure_vector3 (t) 
        if type(t) == "table" then
                return vector3(t[1], t[2], t[3])
        elseif type(t) == "number" then -- 0xRRGGBB
                local b = t % 256
                t = (t - b)/256
                local g = t % 256
                t = (t - g)/256
                local r = t % 256
                t = (t - r)/256
                return rgb(r,g,b)
        end
        return t
end



function random_colour()
    return vector3(math.random(),math.random(),math.random())
end 

function random_vector3_plane_z()
    local a = math.random()*math.pi*2
    local x = math.cos(a)
    local y = math.sin(a)
    return vector3(x,y,0)
end 

function random_vector3_box(min, max)
    min = min or vector3(-1,-1,-1)
    max = max or vector3(1,1,1)
    return vector3(min.x+math.random()*(max.x-min.x), min.y+math.random()*(max.y-min.y), min.z+math.random()*(max.z-min.z))
end 

function random_vector3_sphere()
        while true do
                local r = random_vector3_box()
                local l = #r
                if l <= 1 then return r/l end
        end
end 


function yaw(x, y)
        return math.deg(math.atan2(x,y))
end

function pitch (z)
        return math.deg(math.asin(z))
end

function yaw_pitch (v)
        local yaw = math.deg(math.atan2(v.x,v.y))
        local pitch = math.deg(math.asin(v.z))
        return yaw, pitch
end


function clamp(v,bot,top)
        if v < bot then return bot end
        if v > top then return top end
        return v
end

function lerp(bot, top, v)
        return v * (top-bot) + bot
end

function invlerp(bot, top, v)
        return (v - bot) / (top-bot)
end

function nonzero(v)
        return v==0 and 1 or v
end

function between(v,here1,here2)
        local bot, top = math.min(here1,here2), math.max(here1,here2)
        return v >= bot and v <= top 
end

function sign(v)
        if v==0 then return 0 end
        return v<0 and -1 or 1
end


function table.clone(tab)
        local r = {}
        for k,v in pairs(tab or {}) do r[k] = v end
        return r
end

function find(haystack,needle)
        for k,v in pairs(haystack) do
                if v==needle then
                        return k
                end
        end
end

function filter(tab,c)
        local r = {}
        for _,v in ipairs(tab) do
                if c(v) then
                        table.insert(r,v)
                end
        end
        return r
end

function tabmap(tab,f)
        local r = {}
        for k,v in pairs(tab) do
                local k2, v2 = f(k,v)
                r[k2] = v2
        end
        return r
end

function map(tab,f)
        local r = {}
        for _,v in ipairs(tab) do
                table.insert(r,f(v))
        end
        return r
end

function foreach(tab,f)
        if tab==nil then return end
        for k,v in ipairs(tab) do
                f(v,k)
        end
end

function swapeach(tab,f)
        for k,v in ipairs(tab) do
                tab[k] = f(v)
        end
end

function isarray(tab)
        local sz = #tab
        local count = 0
        for k,_ in pairs(tab) do
                if type(k)~="number" then return false end
                if k < 1 then return false end
                if k > sz then return false end
                count = count + 1
        end
        return count == sz
end

function dump(obj,colour,n,d,ind)
        n = n or 100
        d = d or 0
        if colour == nil then colour = true end
        local t = type(obj)
        if t == 'string' then
                return '\"'..obj..'\"'
        elseif t == 'table' then
                if d == 4 then return tostring(t) end
                local mt = getmetatable(obj)
                if mt and mt.__dump then
                        return mt.__dump(obj, colour, n, d+1, ind)
                else
                        return table.dump(obj, n, d+1, ind, colour)
                end
        else
                return tostring(obj)
        end
end

function table.keys(tab, limit)
        limit = limit or 100
        local keys = {}
        local max_key_len = 0
        local counter = 0
        for k,v in pairs(tab) do
                if counter < limit then
                        keys[#keys+1] = k
                        if max_key_len < #tostring(k) then
                                max_key_len = #tostring(k)
                        end
                end
                counter = counter + 1
        end
        return keys, counter, max_key_len
end

function table.dump(tab, n, d,ind_level, colour)
        d = d or 0
        ind_level = ind_level or 0
        if colour == nil then colour = true end
        local new_ind_level = ind_level + 2
        n = n or 100
        local r = ""
        local ind = (" "):rep(ind_level)
        local ind2 = (" "):rep(new_ind_level)
        if isarray(tab) and #tab <= 20 then
                if #tab == 0 then
                        return '{}'
                end
                r = r .. '{'
                local sep = ' '
                for _,v in ipairs(tab) do
                        r = r .. sep .. dump(v, colour, n, d, ind_level)
                        sep = ', '
                end
                r = r .. ' }'
        else
                local keys, counter, max_key_len = table.keys(tab, n)
                table.sort(keys)
                r = r .. ind .. '{'
                for k,v in ipairs(keys) do
                        --if k > 1 then
                                r = r.."\n"..ind2
                        --end
                        local key = tostring(v)
                        local val = dump(tab[v], colour, n, d, new_ind_level)
                        r = r..(colour and GREEN or "")..key..(colour and RESET or "")..(colour and BOLD or "")
                        r = r..(" "):rep(max_key_len-#key)
                        r = r.." = "..(colour and NOBOLD or "")..val..';'
                end
                if counter > n then
                        r = r.."\n"..ind2.."(and "..tostring(counter-n).." more...)"
                end
                r = r .. '\n' .. ind .. '}'
        end
        return r
end

function table.unique (tab)
        local r = { }
        for _,v in ipairs(tab) do
                r[v] = true
        end
        local r2 = { }
        for k,_ in pairs(r) do
                r2[#r2+1] = k
        end
        return r2
end

function pretty_matrix (...)
        return string.format("╭                                     ╮\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "╰                                     ╯", ...)
end

-- thanks rici!
function memoize(func, t)
        return setmetatable(t or {}, {__index = function(t, k)
                local v = func(k);
                t[k] = v;
                return v;
        end })
end

-- thanks ToxicFrog!
function string.split(s, pat) 
        local i, result = 1, {} 
        if not pat or pat == "" then return s end 
        while i do 
                local b, e = s:find(pat, i) 
                if b then b = b - 1 end 
                table.insert(result, s:sub(i, b)) 
                i = e 
                if i then i = i + 1 end 
        end 
        return result
end 

--[[
function check_args(types,...)
        if #types~=#{...} then
                error("Expected "..#types.." args, got "..#{...}..".",3)
        end
        for k,v in ipairs({...}) do
                if type(v) ~= types[k] then
                        error("Argument "..k.." expected "..types[k].." got "..type(v)..".")
                end
        end
        return ...
end
--]]

function extends (parent)
        return function(child)
                --[[
                for k,v in pairs(parent) do
                        if child[k] == nil then
                                child[k] = v
                        end
                end
                --]]
                setmetatable(child, { __index = parent })
                return child
        end
end

function make_instance_mt(class,fr,fw,fts)
        fr = fr or function() return nil end
        fw = fw or function() return nil end
        return {
                __index = function(t,k) 
                        local use,value = fr(k) 
                        if use then return value end
                        return class[k]
                end,
                __newindex = function(t,k,v)
                        if class[k] ~= nil then
                                class[k] = v
                        else
                                if fw(k,v)==nil then
                                        rawset(t,k,v)
                                end
                        end
                end,
                __tostring = fts
        }
end

function make_instance(obj,class,fr,fw,fts)
        return setmetatable(obj, make_instance_mt(class,fr,fw,fts))
end

function safe_destroy(obj)
        if obj==nil then return end
        if type(obj)=="userdata" and not alive(obj) then return end
        obj:destroy()
end




-- mapping from name (string) to function
CallbackReg = { } 
-- can't use varags because they cannot be captured in closures
-- use executeExtended if 4 params is not enough
function CallbackReg:execute (p1, p2, p3, p4)
        local broken_callbacks
        for _,record in ipairs(self.callBacks) do
                local _, cb, path = unpack(record)
                path_stack_push_dir(path)
                local status, continue = xpcall(function() return cb(p1, p2, p3, p4) end, error_handler)
                if status then
                        broken_callbacks = broken_callbacks or { }
                        broken_callbacks[#broken_callbacks] = record
                end
                path_stack_pop()
                if continue == false then return false end
        end
        if broken_callbacks then
                for _,v in ipairs(broken_callbacks) do
                        self:removeByName(record[1])
                end
        end
        return true
end
function CallbackReg:executeExtended (f,...)
        for _,record in ipairs(self.callBacks) do
                local name, cb, path = unpack(record)
                local continue = f(name,cb,path,...)
                if continue == false then return false end
        end
end
function CallbackReg:clear(...)
        self.callBacks = {}
end
function CallbackReg:removeByName(name,...)
        local tab = {}
        for _,record in ipairs(self.callBacks) do
                if record[1]~=name then
                        table.insert(tab,record)
                else
                        record[2] = function () end
                end
        end
        self.callBacks = tab
end
function CallbackReg:getIndex(name,...)
        for k,v in ipairs(self.callBacks) do
                if v[1] == name then
                        return k
                end
        end
end
function CallbackReg:getIndexSafe(name,...)
        local tmp = self:getIndex(name)
        if tmp==nil then
                error("Couldn't find a callback called \""..name.."\"",3)
        end
        return tmp
end
function CallbackReg:insert(name,cb,pos)
        pos = pos or #self.callBacks+1
        table.insert(self.callBacks,pos,{name,cb,path_stack_top()})
end
function CallbackReg.new()
        local self = {}
        self.callBacks = {} --initially empty
        make_instance(self,CallbackReg)
        return self
end


RunningStats = {}
function RunningStats:calcMin()
        local max
        for _,v in ipairs(self.recordedValues) do
                max = max or v
                max = math.min(v,max)
        end     
        return max
end
function RunningStats:calcMax()
        local max
        for _,v in ipairs(self.recordedValues) do
                max = max or v
                max = math.max(v,max)
        end     
        return max
end
function RunningStats:calcAverage()
        local total = 0
        for _,v in ipairs(self.recordedValues) do
                total = total + v
        end     
        return total / #self.recordedValues
end
function RunningStats:add(v)
        table.remove(self.recordedValues)
        table.insert(self.recordedValues,1,v)
end
function RunningStats.new(n)
        local self = { recordedValues = {} }
        for i=1,n do
                self.recordedValues[i] = 0
        end
        return make_instance(self,RunningStats)
end

function killobj(x)
        if x.destroyed then return end
        local near = x.near
        local far = x.far
        x:destroy()
        if x.near then
                killobj(x)
        end
        if x.far then
                killobj(x)
        end
end


function verify_input(v, spec, level)
        level = level and (level+1) or 2
        if spec[1] == "one of" then
                for i=2,#spec do
                        if v == spec[i] then return end
                end
                local str ="\""..tostring(v).."\" unacceptable, try "
                local sep = ""
                for i=2,#spec do
                        str = str..sep..tostring(spec[i])
                        sep = ", "
                        if i==#spec-1 then
                                sep = sep.."or "
                        end
                end
                error(str,level)
        elseif spec[1] == "range" then
                verify_input(v, {"number"}, level+1)
                local low, high = spec[2], spec[3]
                if v < low or v > high then
                        local str ="\""..tostring(v).."\" unacceptable, must be inside "..low.." to "..high
                        error(str,level)
                end
        elseif spec[1] == "int range" then
                verify_input(v, {"int"}, level+1)
                local low, high = spec[2], spec[3]
                if v < low or v > high then
                        local str ="\""..tostring(v).."\" unacceptable, must be inside "..low.." to "..high
                        error(str,level)
                end
        elseif spec[1] == "string" then
                if type(v) ~= "string" then
                        local str ="\""..tostring(v).."\" unacceptable, must be a string"
                        error(str,level)
                end
        elseif spec[1] == "int" then
                verify_input(v, {"number"}, level+1)
                if math.floor(v) ~= v then
                        local str ="\""..tostring(v).."\" unacceptable, must be an integer"
                        error(str, level)
                end
        elseif spec[1] == "number" then
                if type(v) ~= "number" then
                        local str ="\""..tostring(v).."\" unacceptable, must be a number"
                        error(str,level)
                end
        elseif spec[1] == "table" then
                local size = spec[2]
                if type(v) ~= "table" then
                        local str ="\""..tostring(v).."\" unacceptable, must be a table"
                        error(str,level)
                end
                if #v ~= size then
                        local str ="array unacceptable, must have exactly "..size.." elements"
                        error(str,level)
                end
                for i=1,size do
                        if spec[2+i] then
                                verify_input(v[i], spec[2+i], level+1)
                        end
                end
        else
                error("Unrecognised specification: "..tostring(spec[1]))
        end
end


function make_active_table(tab, verification, commit)

        local c = { autoUpdate = false }
        local p = { }

        for k,v in pairs(tab) do
                p[k] = v
        end

        for k,_ in pairs(tab) do
                tab[k] = nil
        end

        tab.c = c
        tab.p = p

        setmetatable(tab, {
                __index = function (self, k)
                        local v = self.c[k]
                        if v == nil then error("No such setting: \""..k.."\"",2) end
                        return v
                end,
                __newindex = function (self, k, v)
                        if k == "autoUpdate" then
                                verify_input(v,{"one of",false,true})
                                self.c[k] = v
                        else
                                local spec = verification[k]
                                if spec == nil then error("No such setting: \""..k.."\"",2) end
                                verify_input(v,spec,2)
                                self.p[k] = v
                        end
                        if not self.c.autoUpdate then return end
                        commit(self.c, self.p)
                end,
                __dump = function(self,...) return dump(self.c,...) end
        })

end


-- their days are numbered
function ensure_array(v, size)
        verify_input(v,{"array", size},2)
end

function ensure_number(v, level)
        verify_input(v,{"number"},2)
end

function ensure_range(v, low, high)
        verify_input(v,{"range", low, high},2)
end

function ensure_int(v, level)
        verify_input(v,{"int"},level+1)
end

function ensure_int_range(v, low, high)
        verify_input(v,{"int range", low, high},2)
end

function ensure_one_of(v, allowed)
        verify_input(v,{"one of", unpack(allowed)},2)
end


local running_map = nil

function map_ghost_spawn(pos, quat)
    if running_map ~= path_stack_top() then
        player_ctrl:warp(pos, quat or Q_ID)
        running_map = path_stack_top()
        return true
    end
end

