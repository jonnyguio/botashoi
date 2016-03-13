Pole = require "srcs.pole"
Scenary = require "srcs.scenary"
Creature = require "srcs.creature"
Spawner = require "srcs.spawner"
Enemy = require "srcs.enemy"
Animation = require "srcs.animation"

function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local FRAMES = 60
local canJump = true
local isControlling = false
local coolDown = 3
local now = 3

objects = {}
imgs = {}
animations = {}
randoms = {}
hangings = {}

function controlOne(now, coolDown, isControlling)
    if now >= coolDown and not isControlling then
        local x, y = objects.pole:getBody():getPosition()
        local team = Creature.new(world, animations["dog_standing"], "team", x - math.random(30, 60), teamY + animations["dog_standing"]:getHeight())
        table.insert(objects.creatures.team, team)
        now = 0
        isControlling = true
    end
    return isControlling
end

function beginContact(a, b, coll)
    -- Handling Jump
    if string.match(a:getUserData(), "team") and string.match(b:getUserData(), "floor") then
        canJump = true
    elseif string.match(b:getUserData(), "team") and string.match(a:getUserData(), "floor") then
        canJump = true
    end

    -- Handling enemies colliding
    if string.match(a:getUserData(), "enemy") and string.match(b:getUserData(), "pole") then
        for i, j in pairs(objects.creatures.enemies) do
            if a:getUserData() == j:getFixture():getUserData() then
                table.insert(hangings, {x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2, y = objects.pole:getBody():getY(), offset = objects.pole:getBody():getY()})
                j:destroy()
            end
        end
    elseif string.match(b:getUserData(), "enemy") and string.match(a:getUserData(), "pole") then
        for i, j in pairs(objects.creatures.enemies) do
            if b:getUserData() == j:getFixture():getUserData() then
                table.insert(hangings, {x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2, y = objects.pole:getBody():getY(), offset = objects.pole:getBody():getY() - j:getBody():getY()})
                --pole:getBody():setMass objects.pole:getBody():getMass() - 5)
                j:destroy()
            end
        end
    end

end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function love.load()
    love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
    love.window.setMode(600, 480)

    local filename_dog_standing, filename_dog_jumping, filename_dog_running, filename_dog_hanging, filename_pole, filename_floor = "images/dog_standing.png", "images/dog_jumping.png", "images/dog_running.png", "images/dog_hanging.png", "images/pole.png", "images/floor.png"
    local framewidth_standing, frameheight_standing = 51, 55
    local framewidth_jumping, frameheight_jumping = 71, 60
    local framewidth_running, frameheight_running = 78, 40
    local framewidth_hanging, frameheight_hanging = 43, 50

    animations["dog_standing"] = Animation.new("dog_standing", filename_dog_standing, framewidth_standing, frameheight_standing)
    animations["dog_jumping"] = Animation.new("dog_jumping", filename_dog_jumping, framewidth_jumping, frameheight_jumping)
    animations["dog_running"] = Animation.new("dog_running", filename_dog_running, framewidth_running, frameheight_running)
    animations["dog_hanging"] = Animation.new("dog_hanging", filename_dog_hanging, framewidth_hanging, frameheight_hanging)

    for row = 1, 6 do
        animations["dog_standing"]:addFrame(row, 1)
    end

    for row = 1, 4 do
        animations["dog_jumping"]:addFrame(row, 1)
    end

    for row = 1, 5 do
        animations["dog_running"]:addFrame(row, 1)
    end

    for row = 1, 2 do
        animations["dog_hanging"]:addFrame(row, 1)
    end

    animations["dog_standing"]:play()
    animations["dog_jumping"]:play()
    animations["dog_running"]:play()
    animations["dog_hanging"]:play()

    min_dt = 1 / FRAMES
    next_time = love.timer.getTime()

    love.physics.setMeter(50)
    world = love.physics.newWorld(0, 9.81 * 50, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    objects.spawners = {}
    objects.scenary = {}
    objects.creatures = {}
    objects.creatures.team = {}
    objects.creatures.enemies = {}

    for rnd = 1, 7 do
        randoms[rnd] = math.random(1, 3)
    end

    table.insert(objects.spawners, Spawner.new(animations["dog_running"], 1, 60, love.graphics.getHeight() - animations["dog_running"]:getHeight(), 1, 5))
    table.insert(objects.spawners, Spawner.new(animations["dog_running"], 2, 140, love.graphics.getHeight() - 25, 10, 13))

    pole = Pole.new(world, filename_pole, love.graphics.getWidth() - 100, love.graphics.getHeight() / 2)
    objects.pole = pole

    floor = Scenary.new(world, "dynamic", filename_floor, "floor", {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight()}, love.graphics.getWidth(), 50)
    realFloor = Scenary.new(world, nil, filename_floor, "realFloor", {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() + 50}, love.graphics.getWidth(), 50)
    table.insert(objects.scenary, floor)
    table.insert(objects.scenary, realFloor)

    teamX = objects.pole:getPos() - objects.pole:getImg():getWidth() - 5
    teamY = love.graphics.getHeight() - 52
end

function love.update(dt)
    next_time = next_time + min_dt
    now = now + min_dt

    for k, v in pairs(objects.spawners) do
        v:update(min_dt)
    end

    for i, j in pairs(objects.creatures) do
        for k, v in pairs(j) do
            v:update(min_dt)
        end
    end

    for k, v in pairs(hangings) do
        v.x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2
        v.y = objects.pole:getBody():getY() --- v.offset
    end

    for k, v in pairs(animations) do
        v:update(min_dt)
    end

    world:update(dt)

    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
        isControlling = controlOne(now, coolDown, isControlling)
        for k, v in pairs(objects.creatures.team) do
            v:getBody():applyForce(v:getBody():getMass() * 4, 0)
        end
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
        isControlling = controlOne(now, coolDown, isControlling)
        for k, v in pairs(objects.creatures.team) do
            v:getBody():applyForce(v:getBody():getMass() * -4, 0)
        end
    elseif love.keyboard.isDown("up") and canJump then
        isControlling = controlOne(now, coolDown, isControlling)
        for k, v in pairs(objects.creatures.team) do
            v:getBody():applyForce(0, v:getBody():getMass() * -500)
        end
    elseif love.keyboard.isDown("r") then --press the up arrow key to set the ball in the air
        for k, v in ipairs(objects.creatures) do
            v:getBody():setPosition(650/2, 650/2)
            v:getBody():setLinearVelocity(0, 0)
        end
    end
end

function love.draw()
    for k, v in pairs(objects.scenary) do
        v:Draw()
    end

    objects.pole:Draw()

    for k, v in pairs(animations) do
        if k == "dog_standing" then
            for i = 1, 7 do
                v:Draw(teamX - i * 8, teamY - randoms[i], randoms[i])
            end
        elseif k == "dog_hanging" then
            for i = 1, #hangings do
                v:Draw(hangings[i].x, hangings[i].y, nil, objects.pole:getBody():getAngle(), nil, nil, hangings[i].offset)
            end
        end
    end

    for k, v in pairs(objects.creatures) do
        for x, y in pairs(v) do
            y:Draw()
        end
    end


    love.graphics.print("Frame Rate: "..love.timer.getFPS(), 0, 0)

    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep(next_time - cur_time)
end


--[[function love.keypressed(key)
    if key == "up" then
        if canJump == true then
            canJump = false
            for k, v in ipairs(objects.creatures.team) do
                v:getBody():applyForce(0, -20000)
            end
        end
    elseif key == "k" then
        local x, y = objects.pole:getBody():getPosition()
        local team = Creature.new(world, animations["dog_standing"], "team", x - math.random(30, 60), teamY + animations["dog_standing"]:getHeight())
        table.insert(objects.creatures.team, team)
    end
end]]--
