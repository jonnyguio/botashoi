Pole = require "srcs.pole"
Scenary = require "srcs.scenary"
Creature = require "srcs.creature"

objects = {}

function love.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)
    objects.scenary = {}
    objects.creatures = {}
    pole = Pole.new(world)
    floor = Scenary.new(world, {x=love.graphics.getWidth() / 2, y=love.graphics.getHeight()}, love.graphics.getWidth(), 50)
    table.insert(objects.scenary, floor)
    table.insert(objects.scenary, pole)
    table.insert(objects.creatures, enemy)

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
    world:update(dt)

    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
        for k, v in pairs(objects.creatures) do
            v:getBody():applyForce(400, 0)
        end
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
        for k, v in pairs(objects.creatures) do
            v:getBody():applyForce(-400, 0)
        end
    elseif love.keyboard.isDown("up") then --press the up arrow key to set the ball in the air
        for k, v in pairs(objects.creatures) do
            v:getBody():setPosition(650/2, 650/2)
            v:getBody():setLinearVelocity(0, 0)
        end
    elseif love.keyboard.isDown("k") then
        local enemy = Creature.new(world, nil, nil, 20)
        table.insert(objects.creatures, enemy)
    end
end

function love.draw()
    for k, v in pairs(objects.scenary) do
        v:Draw()
    end
    for k, v in pairs(objects.creatures) do
        v:Draw()
    end
end


function love.keypressed(key)

end
