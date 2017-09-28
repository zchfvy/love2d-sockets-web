local socket = require 'socket'

local address, port = '192.168.1.38', 8089

local entity
local updaterate = 0.1

local world = {}
local t


function love.load()
    tcp = socket.tcp()
    tcp:connect(address, port)

    t = 0
end

ready = 0

function init()
    math.randomseed(os.time())
    entity = tostring(math.random(99999))

    local dg = string.format('%s %s %d %d', entity, 'at', 320, 240)
    tcp:send(dg)
end

function love.update(dt)
    if ready == 0 then
        ready = 1 -- For some reason the network won't work on the first frame
    elseif ready == 1 then
        init()
        ready = 2
    else
        t = t + dt

        if t > updaterate then
            local x, y = 0,0
            if love.keyboard.isDown('up')    then y=y-(20*t) end
            if love.keyboard.isDown('down')  then y=y+(20*t) end
            if love.keyboard.isDown('left')  then x=x-(20*t) end
            if love.keyboard.isDown('right') then x=x+(20*t) end

            local dg = string.format('%s %s %f %f', entity, 'move', x, y)
            tcp:send(dg)

            local dg = string.format('%s %s $', entity, 'update')
            tcp:send(dg)

            t=t-updaterate
        end

        repeat
            data, msg = tcp:receive('*l') -- the '*l' isn't strictly required
                                          -- here, it's the default

            if data then
                ent, cmd, parms = data:match('^(%S*) (%S*) (.*)')
                if cmd == 'at' then
                    local x, y = parms:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')
                    assert (x and y)
                    x, y = tonumber(x), tonumber(y)
                    world[ent] = {x=x, y=y}
                else
                    print('unrecognised command:', cmd)
                end
            elseif msg ~= 'timeout' then
                error('Network error: '..tostring(msg))
            end
        until not data
    end
end


function love.draw()
    for k, v in pairs(world) do
        love.graphics.print(k, v.x, v.y)
    end
end
