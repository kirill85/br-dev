-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

do
    particle "Smoke" {
        map = "GenericParticleSheet.dds"; blending = "ALPHA";
        frames = { 640,512, 128, 128, };  frame = 0;
        initialVolume = 10; maxVolume = 200; life = 2;
        behaviour = particle_behaviour_alpha_gas_ball;
        alphaCurve = Plot{[0]=0.0,[0.2]=0.4,[1]=0};
        convectionCurve = particle_convection_curve;
    }

    particle "TexturedSmoke" {
        map = "GenericParticleSheet.dds"; blending = "ALPHA"; premultipliedAlpha = false;
        frames = { 640,640, 128, 128, };  frame = 0;
        initialVolume = 10; maxVolume = 200; life = 2;
        behaviour = particle_behaviour_alpha_gas_ball;
        alphaCurve = Plot{[0]=0, [0.1]=1.0, [0.6]=0.3,[1]=0};
        convectionCurve = particle_convection_curve;
    }
end


function emit_smoke (pos, vel, start_size, end_size, colour, life)
    start_size = start_size or 0.3
    end_size = end_size or 1
    colour = colour or vector3(1,1,1)
    life = life or 3
    local r1 = start_size/2
    local r2 = end_size/2
    gfx_particle_emit("/common/particles/Smoke", pos, {
        angle = 360*math.random();
        velocity = vel;
        initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
        maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
        life = life;
        colour = colour;
        age = 0;
    })
end

function emit_textured_smoke (pos, vel, start_size, end_size, colour, life)
    start_size = start_size or 0.3
    end_size = end_size or 1
    colour = colour or vector3(1,1,1)
    life = life or 3
    local r1 = start_size/2
    local r2 = end_size/2
    gfx_particle_emit("/common/particles/TexturedSmoke", pos, {
        angle = 360*math.random();
        velocity = vel;
        initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
        maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
        life = life;
        colour = colour;
        age = 0;
    })
end


function puff_textured()
    local p = pick_pos()
    local time = 8
    for i=1,50 do
        local dir = random_vector3_sphere()
        if dir.z < 0 then dir = dir * vector3(1,1,-1) end
        local dist = math.random()
        local rand_colour = (0.5*dist)*vector3(1,1,1)
        dist = dist * 8
        emit_textured_smoke(p+dist*dir * vector3(1,1,0.5), dir*vector3(1,1,2), dist, dist*4, rand_colour, math.random() * time)
    end
end

ui:bind("C+F2",function() puff_textured() end, nil, true)




function emit_tyre_smoke (cp, qty)
    emit_textured_smoke(cp + 0.25*V_UP,
               random_vector3_box(vector3(-0.2,-0.2,0.6), vector3(0.2,0.2,0.7)),
               0.5,
               2.5,
               qty * (1-math.random()/3),
               vector3(1,1,1),
               2
    )
end





particle "EngineSmoke" {
    map = "GenericParticleSheet.dds"; blending = "ALPHA";
    frames = { 640,512, 128, 128, };  frame = 0;
    behaviour = function (tab, elapsed)

        -- age ranges from 0 (new) to 1 (dead)
        tab.age = tab.age + elapsed / tab.life
        if tab.age > 1 then
            return false
        end

        tab.position = tab.position + (tab.velocity + vector3(math.random(-100,100)/100,math.random(-100,100)/100,0)) * elapsed

        tab.volume = lerp(tab.initialVolume, tab.endVolume, tab.age)
        local radius = math.pow(tab.volume/math.pi*3/4, 1/3) -- sphere: V = 4/3πr³
        tab.width = 2 * radius
        tab.height = tab.width
        tab.depth = tab.width

        tab.alpha = 0.3*math.pow(1-tab.age, 3)

    end;
    initialVolume = 0.003;
    endVolume = 0.006;
    age = 0;
    life = 1;
}

-- damage is from 0 to 1
local engine_smoke_colour = Plot {
    [0.00] = 1.0;
    [0.40] = 1.0;
    [0.80] = 0.5;
    [1.00] = 0.0;
};
function emit_engine_smoke (damage, pos)
    local off = vector3(math.random(-80,80)/1000, math.random(-80,80)/1000, 0)
    local vel = (damage * 3*off + vector3(0,0,1*damage)) + vector3(0, 0, 2.0)
    gfx_particle_emit("/common/particles/EngineSmoke", pos + off, {
                      velocity = vel,
                      initialVolume = (math.random()*0.03 + 0.03) * clamp(damage, 0.1, 1),
                      endVolume = (math.random()*0.3 + 0.3) * clamp(damage, 0.1, 1),
                      colour = clamp(engine_smoke_colour[damage] + math.random()*0.08, 0, 1) * vector3(1,1,1),
                      life = clamp(damage, 0.5, 1);
                     })
end





local exhaust_smoke_alpha = Plot{
    [0] = 0.3;
    [10] = 0.2;
    [20] = 0.1;
    [30] = 0;
}

particle "ExhaustSmoke" {
    map = "GenericParticleSheet.dds"; blending = "ALPHA";
    frames = {
                640,512, 128, 128,
                640,640, 128, 128,
             };
    frame = 0;

    behaviour = function (particle, elapsed)
        particle.life = particle.life - elapsed
        if particle.life <= 0 then
            return false
        end
        
        local vel
        if particle.speed < 1 then
            vel = particle.velocity
        else
            vel = V_UP * (0.05*particle.speed)
        end
        
        particle.position = particle.position + (vel + vector3(math.random(-100,100)/100,math.random(-100,100)/100,math.random(-100,100)/100)) * elapsed
        
        particle.width = 0.15 - 0.5*particle.life
        particle.height = particle.width
        
        particle.alpha = clamp(exhaust_smoke_alpha[particle.speed] - (particle.life), 0,1)
    end;
}

local exhaust_smoke_life = Plot{
    [0] = 0.3;
    [1] = 0.25;
    [5] = 0.1;
    [20] = 0.05;
    [30] = 0;
}
local exhaust_smoke_color = Plot{
    [0] = 0.4;
    [10] = 0.2;
    [30] = 0;
}

function emit_exhaust_smoke (speed, pos, vel)
    gfx_particle_emit("/common/particles/ExhaustSmoke", pos, {
                      velocity = vel,
                      colour = exhaust_smoke_color[speed] * vector3(1,1,1);
                      life = exhaust_smoke_life[speed];
                      speed = speed;
                      frame = math.random(0,1);
                     })
end

particle "RocketExhaustSmoke" {
    map = "GenericParticleSheet.dds"; blending = "ALPHA";
    frames = {
                640,512, 128, 128,
                640,640, 128, 128,
             };
    frame = 0;
    startWidth = 1;
    
    behaviour = function (particle, elapsed)
        particle.life = particle.life - elapsed
        if particle.life <= 0 then
            return false
        end
        
        particle.position = particle.position + (particle.velocity + vector3(math.random(-100,100)/100,math.random(-100,100)/100,math.random(-100,100)/100)) * elapsed
        
        particle.width = particle.startWidth - math.pow(particle.life, 3)
        particle.height = particle.width
        particle.colour = lerp(vector3(1,0,0),vector3(1,0.3,0), clamp(particle.width, 0, 0.75))
        particle.alpha = clamp(0.6 - 0.1/particle.life, 0,1)
    end;
}

function emit_rocket_smoke(pos, vel, width)
       gfx_particle_emit("/common/particles/RocketExhaustSmoke", pos, {
                      velocity = vel,
                      --startWidth = width;
                      colour = vector3(1,0,0);
                      life = 0.25;
                      startWidth = width;
                      frame = math.random(0,1);
                     })
end

