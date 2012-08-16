ColClass = extends (BaseClass) {
        receiveImpulse = function (persistent, impulse, wpos)
                if persistent.health and persistent.impulseDamageThreshold then
                        --if impulse > 0 then
                        --        --echo(persistent.name, impulse, pos, poso)
                        --        if (not other.owner.destroyed) and other.owner.className == "/vehicles/Evo" then
                        --                --echo("BOUNCE!", impulse, norm, poso)
                        --                --other:impulse(-impulse * norm, pos)
                        --                persistent:receiveDamage(20000)
                        --        end
                        --end
                        local damage = #impulse
                        if damage > persistent.impulseDamageThreshold then
                                local volume = damage / persistent.impulseDamageThreshold - 1
                                audio_play("/common/sounds/collision.wav", wpos, volume, 3, 1, 1+math.random()*0.3)
                                persistent:receiveDamage(damage)
                        end
                end
        end;
        init = function (persistent)
                local class_name = persistent.className
                local colMesh = persistent.colMesh or class_name..".gcol"
                persistent:addDiskResource(colMesh)
                BaseClass.init(persistent)
        end;
        activate=function (persistent,instance)
                if BaseClass.activate(persistent,instance) then
                        return true
                end
                local colMesh = persistent.colMesh or persistent.className..".gcol"
                --echo("adding: "..tostring(persistent).." with "..colMesh)
                local body = physics_body_make(
                        colMesh,
                        persistent.spawnPos,
                        persistent.rot or quat(1,0,0,0)
                )
                body.owner = persistent;
                instance.body = body
                if persistent.floating then
                        instance.body:deactivate()
                end
                instance.camAttachPos = vector3(0,0,0)
                -- this causes an alloc so do them here where the code is cold
                instance.body.updateCallback = function (p,q)
                        instance.camAttachPos = p
                        instance.gfx.localPosition = p
                        instance.gfx.localOrientation = q
                        persistent.pos = p
                end
                persistent.instance.health = persistent.health
                --persistent.health = persistent.health or 10000000000
                --persistent.impulseDamageThreshold = persistent.impulseDamageThreshold or 10000
                if persistent.instance.health and persistent.impulseDamageThreshold then
                        body.collisionCallback = function (life, impulse, other, m, mo,
                                                           pen, pos, poso, norm)
                                persistent:receiveImpulse(impulse * norm, pos)
                        end
                end
                local pobjs = nil -- will hold the procedural objects (if any)
                local pobjs_counter = 1
                for _,pmatname in ipairs(body.procObjMaterials) do
                        local pmat = physics:getMaterial(pmatname)
                        if pmat ~= nil and pmat.proceduralObjects ~= nil then
                                for _, proc_obj_name in ipairs(pmat.proceduralObjects) do
                                        local proc_obj = physics:getProceduralObjectClass(proc_obj_name)
                                        if proc_obj == nil then
                                                error ("Physical material \""..pmatname.."\" references unknown procedural object \""..proc_obj_name.."\"")
                                        end
                                        local t = body:scatter(
                                                pmatname,
                                                proc_obj.density,
                                                proc_obj.minSlope,
                                                proc_obj.maxSlope,
                                                proc_obj.minElevation,
                                                proc_obj.maxElevation,
                                                proc_obj.noZ,
                                                proc_obj.rotate,
                                                proc_obj.alignSlope,
                                                proc_obj.seed or math.random(100000)
                                        )
                                        local n = #t
                                        if n > 0 then pobjs = pobjs or { } end -- create a table only if we have to
                                        local ocl = class_get(proc_obj.class)
                                        local zoff = ocl.placementZOffset or 0
                                        for k=0,(n/7-1) do    
                                                local x,y,z       = t[k*7+1], t[k*7+2], t[k*7+3]
                                                local qw,qx,qy,qz = t[k*7+4], t[k*7+5], t[k*7+6], t[k*7+7]
                                                pobjs[pobjs_counter] = object (proc_obj.class) (x,y,z+zoff) { rot=quat(qw,qx,qy,qz) }
                                                pobjs_counter = pobjs_counter + 1
                                        end
                                end
                        end
                end
                instance.pobjs = pobjs
                local pbats = nil -- will hold the procedural objects (if any)
                local pbats_counter = 1
                for _,pmatname in ipairs(body.procObjMaterials) do
                        local pmat = physics:getMaterial(pmatname)
                        if pmat.proceduralBatches ~= nil then
                                for i, proc_bat_name in ipairs(pmat.proceduralBatches) do
                                        pbats = pbats or { } -- create a table only if we have to
                                        local pbat = pbats[proc_bat_name]
                                        local proc_bat = physics:getProceduralBatchClass(proc_bat_name)
                                        if pbat == nil then
                                            pbat = gfx_ranged_instances_make(proc_bat.mesh)
                                            pbat.castShadows = proc_bat.castShadows
                                            pbats[proc_bat_name] = pbat
                                        end
                                        body:rangedScatter(
                                                pmatname,
                                                pbat,
                                                proc_bat.density,
                                                proc_bat.minSlope,
                                                proc_bat.maxSlope,
                                                proc_bat.minElevation,
                                                proc_bat.maxElevation,
                                                proc_bat.noZ,
                                                proc_bat.rotate,
                                                proc_bat.alignSlope,
                                                proc_bat.seed or math.random(100000)
                                        )
                                end
                        end
                end
                instance.pbats = pbats
        end;
        deactivate=function(persistent)
                local instance = persistent.instance
                if instance.body then
                        if instance.body.mass > 0 and #(persistent.spawnPos - player_ctrl.camFocus) < persistent.renderingDistance then
                                -- avoid it respawning directly in front of the camera
                                persistent.skipNextActivation = true
                        end
                end
                                
                instance.body = safe_destroy(instance.body)
                local pobjs = instance.pobjs
                if pobjs ~= nil then
                        for _,v in ipairs(pobjs) do
                                if not v.destroyed then v:destroy() end
                        end
                end
                instance.pobjs = nil
                local pbats = instance.pbats
                if pbats ~= nil then
                        for _,v in ipairs(pbats) do
                                safe_destroy(v)
                        end
                end
                instance.pbats = nil
                BaseClass.deactivate(persistent, instance)
                return persistent.temporary -- don't respawn if it was from a pile
        end;

        getStatistics = function (persistent)
                local tot_triangles, tot_batches = BaseClass.getStatistics(persistent)
                
                local instance = persistent.instance
                local body = instance.body

                for proc_bat_name, pbat in pairs(instance.pbats) do
                        echo("  Procedural batch: "..proc_bat_name)
                        echo("    Instances: "..pbat.instances)
                        echo("    Triangles: "..pbat.triangles)
                        echo("    Batches: "..pbat.batches)
                        tot_triangles = tot_triangles + pbat.triangles
                        tot_batches = tot_batches + pbat.batches
                end

                return tot_triangles, tot_batches
        end;

        getSpeed = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.persistent.name) end
                local rb = persistent.instance.body
                return #rb.linearVelocity
        end;
        flip = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local rb = persistent.instance.body
                if rb.mass == 0 then return end
                rb.worldOrientation = quat(V_NORTH, rb.worldOrientation * V_FORWARDS * vector3(1,1,0)) * quat(0,0,1,0);
                rb.worldPosition = rb.worldPosition + vector3(0,0,1)
                rb:activate() 
        end;
        realign = function (persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local rb = persistent.instance.body
                rb.worldOrientation = quat(V_NORTH, rb.worldOrientation * V_FORWARDS * vector3(1,1,0))
                rb.worldPosition = rb.worldPosition + vector3(0,0,3);
                rb.angularVelocity = V_ZERO
                rb.linearVelocity = V_ZERO
                rb:activate() 
        end;
        special=function(persistent)
                if not persistent.activated then error("Not activated: "..persistent.name) end
                local rb = persistent.instance.body
                rb.worldOrientation = quat(V_NORTH, rb.worldOrientation * V_FORWARDS * vector3(1,1,0));
                rb.worldPosition = rb.worldPosition - vector3(0,0,3);
                rb.angularVelocity = V_ZERO
                rb.linearVelocity = V_ZERO
                rb:activate() 
        end;
        beingFired=function(persistent)
        end;
        receiveDamage=function(persistent, damage)
                local new_health = persistent.instance.health - damage
                if persistent.instance.health <= 0 then return end
                if verbose_receive_damage then
                        echo(persistent.name.." says OW! "..damage.." ["..new_health.." / "..persistent.health.." = "..math.floor(100*new_health/persistent.health).."%]")
                end
                persistent.instance.health = new_health
                if persistent.instance.health <= 0 then
                        persistent:noHealthLeft()
                end
        end;
        receiveBlast = function (persistent, impulse, wpos, damage_impulse)
                --echo(persistent.name.." caught in explosion", impulse, wpos)
                damage_impulse = damage_impulse or impulse
                persistent.instance.body:impulse(impulse, wpos)
                persistent:receiveImpulse(damage_impulse, wpos)
        end;
        receiveHeat = function (persistent, wpos, amount)
        end;
        onExplode = function (persistent)
                local xi = persistent.explodeInfo
                if xi and xi.deactivate then persistent:deactivate() end
        end;
        explode = function (persistent)
                local instance = persistent.instance
                if instance.exploded then return end
                local xi = persistent.explodeInfo
                if xi then
                        instance.exploded = true
                        if instance.health and instance.health > 0 then instance.health = 0 end
                        explosion(persistent.pos + (xi.offset or vector3(0,0,0)), xi.radius or 4, xi.force)
                        persistent:onExplode()
                end
        end;
        noHealthLeft = function(persistent)
                if persistent.explodeInfo then persistent:explode() end
        end;
        ignite=function(persistent, pname, pos, mat, fertile_life)
                --echo("igniting: "..tostring(persistent))
                if persistent.instance.body.mass==0 then
                        flame_ignite(pname, pos, mat, fertile_life)
                end
        end;
}

