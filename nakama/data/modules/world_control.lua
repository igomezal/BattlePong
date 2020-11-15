local nakama = require("nakama")

local world_control = {}

local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

local function getTableLength(T)
    local count = 0
    for _ in pairs(T) do 
        count = count + 1 
    end
    return count
end


local player_status = {
    NOT_READY = 0,
    READY = 1,
    PLAYING = 2
}

local OpCodes = {
    update_state = 1,
    update_position = 2,
    start_match = 3
}

local commands = {}

commands[OpCodes.update_state] = function(data, state)
    local id = data.id
    local new_state = data.state
    if state.player_status[id] ~= nil then
        if new_state == player_status.READY and getTableLength(state.presences) == state.max_players then
            state.player_status[id] = new_state
        else
            state.player_status[id] = new_state
        end
    end
end

-- Updates the position in the game state
commands[OpCodes.update_position] = function(data, state)
    local id = data.id
    local position = data.pos
    if state.positions[id] ~= nil then
        state.positions[id] = position
    end
end

function world_control.match_init(context, params)
    local state = {
        presences = {},
        player_status = {},
        positions = {},
        max_players = 2
    }
    local tick_rate = 10
    local label = randomString(5)

    return state, tick_rate, label 
end

function world_control.match_join_attempt(context, dispatcher, tick, state, presence, metada)
    if state.presences[presence.user_id] ~= nil then
        return state, false, "User already logged in."
    end
    if getTableLength(state.presences) == state.max_players then
        return state, false, "Only two players can join this match"
    end
    return state, true
end


function world_control.match_join(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.user_id] = presence
        state.player_status[presence.user_id] = player_status.NOT_READY
        state.positions[presence.user_id] = {
            ["x"] = 25,
            ["y"] = 360
        }
    end

    local data = {
        ["player_status"] = state.player_status,
    }

    local encoded = nakama.json_encode(data)

    dispatcher.broadcast_message(OpCodes.update_state, encoded)
    
    return state
end

function world_control.match_leave(context, dispatcher, tick, state, presences)
    for _, presence in ipairs(presences) do
        state.presences[presence.user_id] = nil
        state.player_status[presence.user_id] = nil
        state.positions[presence.user_id] = nil
    end

    for key, _ in pairs(state.player_status) do
        state.player_status[key] = player_status.NOT_READY
    end

    local data = {
        ["player_status"] = state.player_status,
    }

    local encoded = nakama.json_encode(data)

    dispatcher.broadcast_message(OpCodes.update_state, encoded)

    return state
end

function world_control.match_loop(_, dispatcher, _, state, messages)
    for _, message in ipairs(messages) do
        local op_code = message.op_code

        local decoded = nakama.json_decode(message.data)

        -- Run boiler plate commands (state updates.)
        local command = commands[op_code]
        if command ~= nil then
            commands[op_code](decoded, state)
        end

        -- A client has selected a character and is spawning. Get or generate position data,
        -- send them initial state, and broadcast their spawning to existing clients.
        if op_code == OpCodes.update_state then
            local data = {
                ["player_status"] = state.player_status,
            }

            local encoded = nakama.json_encode(data)
            dispatcher.broadcast_message(OpCodes.update_state, encoded)

            if getTableLength(state.player_status) == state.max_players then
                local all_ready = true
                for key, _ in pairs(state.player_status) do
                    if state.player_status[key] ~= player_status.READY then
                        all_ready = false
                    end
                end

                if all_ready then
                    for key, _ in pairs(state.player_status) do
                        state.player_status[key] = player_status.PLAYING
                    end
                    dispatcher.broadcast_message(OpCodes.start_match)
                end
            end
        end
    end

    local data = {
        ["pos"] = state.positions
    }
    local encoded = nakama.json_encode(data)
    dispatcher.broadcast_message(OpCodes.update_position, encoded)

    return state
end

function world_control.match_terminate(context, dispatcher, tick, state, grace_seconds)
    return state
end

return world_control