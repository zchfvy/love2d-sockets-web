local socket = require 'socket'

local address, port = 'localhost', 8089
-- If you need to access this from a remote machine you will need to chane
-- the above

local entity
local updaterate = 0.1

local world = {}
local t


function love.load()
    tcp = socket.tcp()
    tcp:connect(address, port)
    -- Websockets require that we use TCP
    -- If you want flexibility to fall back to UDP in a non-web environment
    -- you will need to set this up yourself.

    t = 0
end

ready = false

function love.update(dt)
    if not ready then
        ready = true
        -- For some reason the network won't work on the first frame
        -- We skip over running gameplay in the first frame to deal with this
    else

        if not entity then
            -- Set up our entity
            math.randomseed(os.time())
            entity = tostring(math.random(99999))

            local dg = string.format('%s %s %d %d', entity, 'at', 320, 240)
            tcp:send(dg)
        end

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
