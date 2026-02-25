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
fn = require 'libraries/moses/moses'

require 'GameObject'
require 'utils'
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

    input:bind('d', 'delete')

    current_room = nil
    gotoRoom('Stage')
end

function love.update(dt)
    timer:update(dt)

    if current_room then
        current_room:update(dt)
    end
end

function love.draw()
    if current_room then
        current_room:draw()
    end
end

function love.keypressed(key)

end
