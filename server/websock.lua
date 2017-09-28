local copas = require('copas')
local websocket = require('websocket')


local world = {}
local data, msg_or_ip, port_or_nil
local entity, cmd, arms

local running = true

function run_websock(ws)
    while running do
        data = ws:receive()
        if data then
            print(data)
            entity, cmd, parms = data:match('^(%S*) (%S*) (.*)')
            if cmd == 'move' then
                local x, y = parms:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')
                assert (x and y)
                x, y = tonumber(x), tonumber(y)
                local ent = world[entity] or {x=0, y=0}
                world[entity] = {x=ent.x+x, y=ent.y+y}
            elseif cmd == 'at' then
                local x, y = parms:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')
                assert (x and y)
                x, y = tonumber(x), tonumber(y)
                world[entity] = {x=x, y=y}
            elseif cmd == 'update' then
                for k, v in pairs(world) do
                    dg = string.format('%s %s %d %d\r\n', k, 'at', v.x, v.y)
                    print(dg)
                    ws:send(dg, 2)
                end
            elseif cmd == 'quit' then
                running = false
            else
                print('unrecognized command:', cmd)
            end
        else
            error('Unknown network error: ')
            ws:close()
            return
        end
    end
end

local server = websocket.server.copas.listen {
    port = 8089,
    protocols = {
        binary = run_websock
    },
    default = run_websock
}

print "Beginning server loop."

copas.loop()

print "Thank you."
