Pole = require "srcs.pole"
Scenary = require "srcs.scenary"
Creature = require "srcs.creature"
Spawner = require "srcs.spawner"
Enemy = require "srcs.enemy"

local FRAMES = 60
local canJump = true

objects = {}

function beginContact(a, b, coll)
    if string.match(a:getUserData(), "team") and string.match(b:getUserData(), "floor") then
        canJump = true
    elseif string.match(b:getUserData(), "team") and string.match(a:getUserData(), "floor") then
        canJump = true
    end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end


function love.load()

    min_dt = 1 / FRAMES
    next_time = love.timer.getTime()

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    objects.spawners = {}
    objects.scenary = {}
    objects.creatures = {}
    objects.creatures.team = {}
    objects.creatures.enemies = {}

    table.insert(objects.spawners, Spawner.new(1, 60, love.graphics.getHeight() - 100, 5))
    table.insert(objects.spawners, Spawner.new(2, 140, love.graphics.getHeight() - 100, 13))

    pole = Pole.new(world, love.graphics.getWidth() - 100, love.graphics.getHeight() / 2)
    floor = Scenary.new(world, "floor", {x=love.graphics.getWidth() / 2, y=love.graphics.getHeight()}, love.graphics.getWidth(), 50)
    table.insert(objects.scenary, floor)
    objects.pole = pole

    --[[print(pole:getBody():getPosition())
    print("gravity: " .. pole:getBody():getGravityScale())
    print(pole:getAngle())
    print(pole:getWidth())
    print(pole:getHeight())
    print(pole:getColor()[1])
    print(pole:getColor()[2])
    print(pole:getColor()[3])]]--

    love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
    love.window.setMode(800, 600)
end

function love.update(dt)
    next_time = next_time + min_dt

    for k, v in pairs(objects.spawners) do
        v:update(min_dt)
    end

    for k, v in pairs(objects.creatures.enemies) do
        v:update(min_dt)
    end

    world:update(dt)

    --[[if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
        for k, v in pairs(objects.creatures) do
            v:getBody():applyForce(400, 0)
        end
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
        for k, v in pairs(objects.creatures) do
            v:getBody():applyForce(-400, 0)
        end
    elseif love.keyboard.isDown("r") then --press the up arrow key to set the ball in the air
        for k, v in pairs(objects.creatures) do
            v:getBody():setPosition(650/2, 650/2)
            v:getBody():setLinearVelocity(0, 0)
        end
    end]]--
end

function love.draw()
    for k, v in pairs(objects.scenary) do
        v:Draw()
    end
    for k, v in pairs(objects.creatures) do
        for x, y in pairs(v) do
            y:Draw()
        end
    end

    objects.pole:Draw()

    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep(next_time - cur_time)
end


function love.keypressed(key)
    if key == "up" then
        if canJump == true then
            canJump = false
            for k, v in pairs(objects.creatures.team) do
                v:getBody():applyForce(0, -20000)
            end
        end
    elseif key == "k" then
        local x, y = objects.pole:getBody():getPosition()
        local team = Creature.new(world, "team", x - math.random(30, 60), love.graphics.getWidth() / 2, 20)
        table.insert(objects.creatures.team, team)
    end
end
