local nakama = require("nakama")

local function create_match_and_get_label(context, payload)
    return nakama.match_create("world_control", {})
end

local function get_match_by_label(context, payload)
    local json = nakama.json_decode(payload)
    local matches = nakama.match_list(_, _, json["label"], _, _)
    if matches[1] ~= nil then
        return matches[1].match_id
    end

    return false
end

local function get_match_list()
    return nakama.match_list()
end

nakama.register_rpc(create_match_and_get_label, "create_match_and_get_label")
nakama.register_rpc(get_match_by_label, "get_match_by_label")
nakama.register_rpc(get_match_list, "get_match_list")