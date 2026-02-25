--[[
    Area.lua implements the class [Area] that handles the management of [Game Objects]
    within a [Room]
]] Area = Object:extend()

function Area:new(room)
    self.room = room
    self.game_objects = {}
end

function Area:update(dt)
    -- Loops from end of list to start of list to remove game objects
    -- Since in Lua if you loop forward, it will end up skipping some elements
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then
            table.remove(self.game_objects, i)
        end
    end
end

function Area:draw()
    for _, game_object in ipairs(self.game_objects) do
        game_object:draw()
    end
end

function Area:addGameObject(game_object_type, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    game_object.class = game_object_type
    table.insert(self.game_objects, game_object)
    return game_object
end

function Area:getGameObjects(filter)
    local out = {}
    for _, game_object in ipairs(self.game_objects) do
        if filter(game_object) then
            table.insert(out, game_object)
        end
    end
    return out
end

function Area:queryCircleArea(x, y, radius, object_types)
    local out = {}
    for _, game_object in ipairs(self.game_objects) do
        if fn.any(object_types, game_object.class) then
            local d = distance(x, y, game_object.x, game_object.y)
            if d <= radius then
                table.insert(out, game_object)
            end
        end
    end
    return out
end

function Area:getClosestGameObject(x, y, radius, object_types)
    local min_dist = radius
    local closest = nil
    for _, game_object in ipairs(self.game_objects) do
        if fn.any(object_types, game_object.class) then
            local d = distance(x, y, game_object.x, game_object.y)
            if d <= radius then
                if d < min_dist then
                    min_dist = d
                    closest = game_object
                end
            end
        end
    end
    return closest
end

