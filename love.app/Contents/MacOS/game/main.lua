--[[
    This is a remake of BYTEPATH, a 2D arcade shooter built using Lua and LOVE2D
    with a massive skill tree, many classes and ships

    I'm following the tutorial made by the creator behind BYTEPATH
    at https://github.com/a327ex/blog/issues/30

    I'm hoping to ofcourse put my own spin on the game alongside learning the
    fundamentals of creating a 2D game using LOVE and Lua.

    Libraries:
        - rxi (simple Object Oriented Programming for LOVE)
        - Input (input handler library)
        - hump (small collection of tools for developing games with LÖVE)
        [we're importing hump specifically for its timer]
]] --
Object = require 'libraries/classic/classic'
Input = require 'libraries/Input'
Timer = require 'libraries/hump/EnhancedTimer'
Camera = require 'libraries/hump/camera'
fn = require 'libraries/moses/moses'
Physics = require 'libraries/windfield'

require 'GameObject'
require 'utils'
require 'globals'

--[[
    recursiveEnumerate(folder, file_list) takes a [folder] name and a lua table [file_list]
    and scans all the lua files in that directory recursively and append the
    relative path to the [file_list] table.
]] --
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.getInfo(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

--[[
    requireFiles(files) takes a table [files] filled with relative path to lua files
    (often libraries or objects) and require them so we don't have to manually
    what is NOT guaranteed however is the dependencies for OOP objects
    because recursiveEnumeration require files alphabetically so we can't assure that
    certain objects which inherit off of other objects will be imported correctly

    In the situation where there are OOP Inheritance objects, import them manually
    using require.
]] --
function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then
        current_room:destroy()
    end
    current_room = _G[room_type](...)
end

function printString(...)
    args = {...}
    finString = ""

    for i, v in ipairs(args) do
        finString = finString .. v
    end

    return finString
end

function love.load()
    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)

    input = Input()
    timer = Timer()
    fn = fn()

    resize(3)
    love.graphics.setDefaultFilter('nearest')
    love.graphics.setLineStyle('rough')

    slow_amount = 1
    flash_frames = nil

    camera = Camera()

    input:bind('1', function()
        print("Before collection: " .. collectgarbage("count") / 1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count") / 1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in ipairs(counts) do
            print(k, v)
        end
        print("-------------------------------------")
    end)

    input:bind('4', function()
        gotoRoom('Stage')
    end)

    input:bind('a', "left")
    input:bind('d', "right")
    input:bind('w', "up")
    input:bind("s", "down")

    current_room = nil
    gotoRoom('Stage')
end

function love.update(dt)
    timer:update(dt * slow_amount)

    if current_room then
        current_room:update(dt * slow_amount)
    end

    camera:update(dt * slow_amount)
end

function love.draw()
    if current_room then
        current_room:draw()
    end

    -- Display ship name in top-left corner
    if current_room and current_room.player and not current_room.player.dead then
        love.graphics.setColor(default_color)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print('Ship: ' .. current_room.player.ship, 10, 10)
        love.graphics.setColor(255, 255, 255)
    end

    if flash_frames then
        flash_frames = flash_frames - 1
        if flash_frames == -1 then
            flash_frames = nil
        end
    end
    if flash_frames then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', 0, 0, sx * gw, sy * gh)
        love.graphics.setColor(255, 255, 255)
    end
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, {
        slow_amount = 1
    }, 'in-out-cubic')
end

function flash(frames)
    flash_frames = frames
end

--[[
**********************************************
BELOW IS MEMORY TRACKING/GARBAGE COLLECTION IMPLEMENTATION
**********************************************
]] --
function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then
            return
        end
        f(t)
        seen[t] = true
        for k, v in pairs(t) do
            if type(v) == "table" then
                count_table(v)
            elseif type(v) == "userdata" then
                f(v)
            end
        end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function(o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
        for k, v in pairs(_G) do
            global_type_table[v] = k
        end
        global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end
