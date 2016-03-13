Pole = require "srcs.pole"
Scenary = require "srcs.scenary"
Creature = require "srcs.creature"
Spawner = require "srcs.spawner"
Enemy = require "srcs.enemy"
Animation = require "srcs.animation"

function protect(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function(t, key, value)
            error("attempting to change constant " ..
                   tostring(key) .. " to " .. tostring(value), 2)
        end
    })
end

CONSTANTS = {
    PLAYING = 1000,
    GAME_OVER = 1001,
    MENU = 1002,
    ENEMY = 12,
    ENEMY_DEAD = -11,
    POLE = -10
}

CONSTANTS = protect(CONSTANTS)

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
local state = 0

objects = {}
imgs = {}
animations = {}
randoms = {}
hangings = {}

function controlOne(now, coolDown, isControlling)
    --print (now, coolDown, isControlling)
    if now >= coolDown and not isControlling then
        local x, y = objects.pole:getBody():getPosition()
        local team = Creature.new(world, animations["dog_standing"], "team", x - math.random(30, 60), love.graphics.getHeight() - 50)
        table.insert(objects.creatures.team, team)
        now = 0
        isControlling = true
    end
    return isControlling
end

function beginContact(a, b, coll)

    -- Handling Jump
    if ((string.match(a:getUserData(), "team") and not canJump)) and string.match(b:getUserData(), "floor") then
        for i, j in pairs(objects.creatures.team) do
            if a:getUserData() == j:getFixture():getUserData() then
                j:destroy()
            end
        end
        isControlling = false
        canJump = true
    elseif ((string.match(b:getUserData(), "team") and not canJump)) and string.match(a:getUserData(), "floor") then
        for i, j in pairs(objects.creatures.team) do
            if b:getUserData() == j:getFixture():getUserData() then
                j:destroy()
            end
        end
        isControlling = false
        canJump = true
    end

    -- Handling enemies colliding
    if string.match(a:getUserData(), "enemy") then
        if string.match(b:getUserData(), "pole") then
            for i in a:getMask() do
                if i == b:getCategory() then
                    return
                end
            end
            for i, j in pairs(objects.creatures.enemies) do
                if a:getUserData() == j:getFixture():getUserData() and j:isAlive() then
                    table.insert(hangings, {x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2, y = objects.pole:getBody():getY(), offset = objects.pole:getBody():getY()})
                    j:destroy()
                end
            end
        elseif string.match(b:getUserData(), "team") then
            for i, j in pairs(objects.creatures) do
                for k, v in pairs(j) do
                    if v:getFixture():getUserData() == b:getUserData() or v:getFixture():getUserData() == a:getUserData() then
                        if not v:isAlive() then
                            return
                        end
                    end
                end
            end
            for i, j in pairs(objects.creatures) do
                for k, v in pairs(j) do
                    if v:getFixture():getUserData() == a:getUserData() or v:getFixture():getUserData() == b:getUserData() then
                        v:startFade()
                        v:getFixture():setMask(CONSTANTS.ENEMY)
                        v:getFixture():setCategory(CONSTANTS.ENEMY)
                        v:getFixture():setGroupIndex(CONSTANTS.ENEMY_DEAD)
                        v:prepareChange("dog_falling")
                        v:kill()
                    end
                end
            end
        elseif string.match(b:getUserData(), "floor") then
            for i, j in pairs(objects.creatures.enemies) do
                if a:getUserData() == j:getFixture():getUserData() and j:hasAttacked() then
                    j:destroy()
                end
            end
        end
    elseif string.match(b:getUserData(), "enemy") then
        if string.match(a:getUserData(), "pole") then
            for i, j in pairs(objects.creatures.enemies) do
                if b:getUserData() == j:getFixture():getUserData() and j:isAlive() then
                    table.insert(hangings, {x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2, y = objects.pole:getBody():getY(), offset = objects.pole:getBody():getY() - j:getBody():getY()})
                    --pole:getBody():setMass objects.pole:getBody():getMass() - 5)
                    j:destroy()
                end
            end
        elseif string.match(a:getUserData(), "team") then

            for i, j in pairs(objects.creatures) do
                for k, v in pairs(j) do
                    if v:getFixture():getUserData() == a:getUserData() or v:getFixture():getUserData() == b:getUserData() then
                        if not v:isAlive() then
                            return
                        end
                    end
                end
            end
            for i, j in pairs(objects.creatures) do
                for k, v in pairs(j) do
                    if v:getFixture():getUserData() == a:getUserData() or v:getFixture():getUserData() == b:getUserData() then
                        v:startFade()
                        v:getFixture():setMask(CONSTANTS.ENEMY)
                        v:getFixture():setCategory(CONSTANTS.ENEMY)
                        v:getFixture():setGroupIndex(CONSTANTS.ENEMY_DEAD)
                        v:prepareChange("dog_falling")
                        v:kill()
                    end
                end
            end
        elseif string.match(a:getUserData(), "floor") then
            for i, j in pairs(objects.creatures.enemies) do
                if b:getUserData() == j:getFixture():getUserData() and j:hasAttacked() and not j:isAlive() then
                    j:destroy()
                end
            end
        end
    end

end

function endContact(a, b, coll)
    if string.match(a:getUserData(), "team") and string.match(b:getUserData(), "floor") and canJump and isControlling then
        canJump = false
    elseif string.match(b:getUserData(), "team") and string.match(a:getUserData(), "floor") and canJump and isControlling then
        canJump = false
    end
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function love.load()
    love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
    love.window.setMode(600, 480)

    local filename_dog_standing, filename_dog_jumping, filename_dog_running, filename_dog_hanging, filename_pole, filename_floor, filename_bg, filename_dog_space_jump, filename_dog_falling = "images/dog_standing.png", "images/dog_jumping.png", "images/dog_running.png", "images/dog_hanging.png", "images/pole.png", "images/floor.png", "images/bg.png", "images/dog_space_jump.png", "images/dog_falling.png"
    local fw_standing, fh_standing = 51, 55
    local fw_jumping, fh_jumping = 71, 60
    local fw_running, fh_running = 78, 40
    local fw_hanging, fh_hanging = 43, 50
    local fw_space_jump, fh_space_jump = 37, 33
    local fw_falling, fh_falling = 51, 47

    background = love.graphics.newImage(filename_bg)
    state = CONSTANTS.PLAYING

    animations["dog_standing"] = Animation.new("dog_standing", filename_dog_standing, fw_standing, fh_standing)
    animations["dog_jumping"] = Animation.new("dog_jumping", filename_dog_jumping, fw_jumping, fh_jumping)
    animations["dog_running"] = Animation.new("dog_running", filename_dog_running, fw_running, fh_running)
    animations["dog_hanging"] = Animation.new("dog_hanging", filename_dog_hanging, fw_hanging, fh_hanging)
    animations["dog_space_jump"] = Animation.new("dog_space_jump", filename_dog_space_jump, fw_space_jump, fh_space_jump)
    animations["dog_falling"] = Animation.new("dog_falling", filename_dog_falling, fw_falling, fh_falling)

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

    for row = 1, 2 do
        animations["dog_space_jump"]:addFrame(row, 1)
    end

    for row = 1, 5 do
        animations["dog_falling"]:addFrame(row, 1)
    end

    animations["dog_standing"]:play()
    animations["dog_jumping"]:play()
    animations["dog_running"]:play()
    animations["dog_hanging"]:play()
    animations["dog_space_jump"]:play()
    animations["dog_falling"]:play()

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

    floor = Scenary.new(world, "dynamic", filename_floor, "floor", {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight()}, love.graphics.getWidth(), 40)
    realFloor = Scenary.new(world, nil, filename_floor, "realFloor", {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() + 50}, love.graphics.getWidth() * 3, 70)
    table.insert(objects.scenary, floor)
    table.insert(objects.scenary, realFloor)

    teamX = objects.pole:getPos() - objects.pole:getImg():getWidth() - 5
    teamY = love.graphics.getHeight() - 52
end

function love.update(dt)
    if state == CONSTANTS.PLAYING then
        next_time = next_time + min_dt
        now = now + min_dt

        if math.abs(objects.pole:getBody():getAngle()) > math.pi / 3 then
            state = CONSTANTS.GAME_OVER
        end

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

        for i, j in pairs(objects.creatures) do
            for k, v in pairs(j) do
                if v:mustChange() then
                    v:setAnimation(deepCopy(animations[v:newAnimation()]))
                    v:prepareChange(false)
                end
            end
        end


        if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
            isControlling = controlOne(now, coolDown, isControlling)

            for k, v in pairs(objects.creatures.team) do
                v:getBody():applyForce(v:getBody():getMass() * 150, -1)
            end
        elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
            isControlling = controlOne(now, coolDown, isControlling)
            for k, v in pairs(objects.creatures.team) do
                v:getBody():applyForce(v:getBody():getMass() * -150, -1)
            end
        elseif love.keyboard.isDown("up") and canJump then
            isControlling = controlOne(now, coolDown, isControlling)
            for k, v in pairs(objects.creatures.team) do
                v:setAnimation(deepCopy(animations["dog_jumping"]))
                v:getBody():applyForce(0, v:getBody():getMass() * -10000)
            end
        elseif love.keyboard.isDown("r") then --press the up arrow key to set the ball in the air
            for k, v in ipairs(objects.creatures) do
                v:getBody():setPosition(650/2, 650/2)
                v:getBody():setLinearVelocity(0, 0)
            end
        end
    end
end

function love.draw()
    if state == CONSTANTS.PLAYING then
        love.graphics.setColor({255, 255, 255})
        love.graphics.draw(background, 0, 0)

        for k, v in pairs(objects.scenary) do
            v:Draw()
        end

        objects.pole:Draw()

        for k, v in pairs(animations) do
            if k == "dog_standing" then
                for i = 1, 7 do
                    love.graphics.setColor({255, 255, 255})
                    v:Draw(teamX - i * 8, teamY - randoms[i], randoms[i])
                end
            elseif k == "dog_hanging" then
                for i = 1, #hangings do
                    love.graphics.setColor({0, 100, 200})
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
    elseif state == CONSTANTS.GAME_OVER then
        love.graphics.setColor({255, 255, 255})
        love.graphics.draw(background, 0, 0)
        love.graphics.print("Perdeu, infelizmente. Continue tentando!", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    end
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
