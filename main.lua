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
    LOADING = 1005,
    TIME_TO_LOAD = 2.5,
    ENEMY = 12,
    ENEMY_DEAD = -11,
    POLE = -10,
    POLE_DENSITY = 50
}

CONSTANTS = protect(CONSTANTS)

local FRAMES = 60
local canJump = true
local isControlling = false
local coolDown = 3
local controlFade = 0
local now = 3
local state = 0
local score = 0

objects = {}
imgs = {}
animations = {}
randoms = {}
hangings = {}
buttons = {}

function isInRange(a, b, size)
    return (b >= a - size and b <= a + size) or (a >= b - size and a <= b + size)
end

function isClose(a, b)
    local c = 10
    return (a + c >= b and a - c <= b) or (b + c >= a and b - c <= a)
end

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

function addScore(points)
    score = score + points
end

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
                if a:getUserData() == j:getFixture():getUserData() then
                    if j:isAlive() then
                        table.insert(hangings, {x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2, y = objects.pole:getBody():getY(), offset = objects.pole:getBody():getY()})
                    end
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
                        if v:getFixture():getUserData() == a:getUserData() then
                            v:prepareChange("dog_falling_blue")
                        else
                            v:prepareChange("dog_falling")
                        end
                        addScore(1)
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
                if b:getUserData() == j:getFixture():getUserData() then
                    if j:isAlive() then
                        table.insert(hangings, {x = objects.pole:getBody():getX() - objects.pole:getImg():getWidth() / 2, y = objects.pole:getBody():getY(), offset = objects.pole:getBody():getY() - j:getBody():getY()})
                    end
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
                        if v:getFixture():getUserData() == b:getUserData() then
                            v:prepareChange("dog_falling_blue")
                        else
                            v:prepareChange("dog_falling")
                        end
                        addScore(1)
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
    love.graphics.setBackgroundColor(0, 0, 0) -- BURAKIRU
    love.window.setMode(600, 480)

    local filename_dog_standing, filename_dog_jumping, filename_dog_running, filename_dog_hanging, filename_dog_space_jump, filename_dog_falling = {"images/dog_standing.png", "images/dog_standing_blue.png"}, {"images/dog_jumping.png", "images/dog_jumping_blue.png"}, {"images/dog_running.png", "images/dog_running_blue.png"}, {"images/dog_hanging.png", "images/dog_hanging_blue.png"}, {"images/dog_space_jump.png", "images/dog_space_jump_blue.png"}, {"images/dog_falling.png", "images/dog_falling_blue.png"}
    local filename_pole, filename_floor, filename_bg, filename_logo, filename_press_start, filename_quit = "images/pole.png", "images/floor.png", "images/bg.png", "images/logo.png", "images/press_start.png", "images/quit.png"
    local fw_standing, fh_standing = 51, 55
    local fw_jumping, fh_jumping = 71, 60
    local fw_running, fh_running = 78, 40
    local fw_hanging, fh_hanging = 43, 50
    local fw_space_jump, fh_space_jump = 37, 33
    local fw_falling, fh_falling = 51, 47

    -- Initialize menu/bgs
    background = love.graphics.newImage(filename_bg)
    logo = love.graphics.newImage(filename_logo)
    logoColor = {255, 255, 255, 0}
    state = CONSTANTS.LOADING

    min_dt = 1 / FRAMES
    next_time = love.timer.getTime()

    love.physics.setMeter(50)
    world = love.physics.newWorld(0, 9.81 * 50, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- Creating animations
    animations["dog_standing"] = Animation.new("dog_standing", filename_dog_standing[1], fw_standing, fh_standing)
    animations["dog_jumping"] = Animation.new("dog_jumping", filename_dog_jumping[1], fw_jumping, fh_jumping)
    animations["dog_running"] = Animation.new("dog_running", filename_dog_running[1], fw_running, fh_running)
    animations["dog_hanging"] = Animation.new("dog_hanging", filename_dog_hanging[1], fw_hanging, fh_hanging)
    animations["dog_space_jump"] = Animation.new("dog_space_jump", filename_dog_space_jump[1], fw_space_jump, fh_space_jump)
    animations["dog_falling"] = Animation.new("dog_falling", filename_dog_falling[1], fw_falling, fh_falling)

    animations["dog_standing_blue"] = Animation.new("dog_standing_blue", filename_dog_standing[2], fw_standing, fh_standing)
    animations["dog_jumping_blue"] = Animation.new("dog_jumping_blue", filename_dog_jumping[2], fw_jumping, fh_jumping)
    animations["dog_running_blue"] = Animation.new("dog_running_blue", filename_dog_running[2], fw_running, fh_running)
    animations["dog_hanging_blue"] = Animation.new("dog_hanging_blue", filename_dog_hanging[2], fw_hanging, fh_hanging)
    animations["dog_falling_blue"] = Animation.new("dog_falling_blue", filename_dog_falling[2], fw_falling, fh_falling)

    for row = 1, 6 do
        animations["dog_standing"]:addFrame(row, 1)
        animations["dog_standing_blue"]:addFrame(row, 1)
    end
    for row = 1, 4 do
        animations["dog_jumping"]:addFrame(row, 1)
        animations["dog_jumping_blue"]:addFrame(row, 1)
    end
    for row = 1, 5 do
        animations["dog_running"]:addFrame(row, 1)
        animations["dog_running_blue"]:addFrame(row, 1)
    end
    for row = 1, 2 do
        animations["dog_hanging"]:addFrame(row, 1)
        animations["dog_hanging_blue"]:addFrame(row, 1)
    end
    for row = 1, 2 do
        animations["dog_space_jump"]:addFrame(row, 1)
    end
    for row = 1, 5 do
        animations["dog_falling"]:addFrame(row, 1)
        animations["dog_falling_blue"]:addFrame(row, 1)
    end

    animations["dog_standing"]:play()
    animations["dog_jumping"]:play()
    animations["dog_running"]:play()
    animations["dog_hanging"]:play()
    animations["dog_falling"]:play()
    animations["dog_standing_blue"]:play()
    animations["dog_jumping_blue"]:play()
    animations["dog_running_blue"]:play()
    animations["dog_hanging_blue"]:play()
    animations["dog_falling_blue"]:play()
    animations["dog_space_jump"]:play()

    -- Objects
    objects.spawners = {}
    objects.scenary = {}
    objects.creatures = {}
    objects.creatures.team = {}
    objects.creatures.enemies = {}

    for rnd = 1, 7 do
        randoms[rnd] = math.random(1, 3)
    end

    table.insert(objects.spawners, Spawner.new(animations["dog_running_blue"], 1, 60, love.graphics.getHeight() - animations["dog_running"]:getHeight(), 1, 5))
    table.insert(objects.spawners, Spawner.new(animations["dog_running_blue"], 2, 140, love.graphics.getHeight() - 25, 8, 13))

    pole = Pole.new(world, filename_pole, love.graphics.getWidth() - 100, love.graphics.getHeight() / 2)
    objects.pole = pole

    floor = Scenary.new(world, "dynamic", filename_floor, "floor", {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight()}, love.graphics.getWidth(), 40)
    realFloor = Scenary.new(world, nil, filename_floor, "realFloor", {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() + 50}, love.graphics.getWidth() * 3, 70)
    table.insert(objects.scenary, floor)
    table.insert(objects.scenary, realFloor)

    teamX = objects.pole:getPos() - objects.pole:getImg():getWidth() - 5
    teamY = love.graphics.getHeight() - 52

    -- Buttons
    buttons.menu = {}
    buttons.menu.play = {img = love.graphics.newImage(filename_press_start),
        x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 3,
        onClick = function()
            state = CONSTANTS.PLAYING
        end}
    buttons.menu.quit = {img = love.graphics.newImage(filename_quit),
        x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() * 2 / 3,
        onClick = function()
            love.event.quit(0)
        end}

end

function love.update(dt)
    if state == CONSTANTS.LOADING then
        controlFade = controlFade + dt
        logoColor[4] = logoColor[4] + (CONSTANTS.TIME_TO_LOAD - controlFade) * 3
        if controlFade >= CONSTANTS.TIME_TO_LOAD * 2 then
            state = CONSTANTS.MENU
        end
    elseif state == CONSTANTS.PLAYING then
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

        objects.pole:getBody():setMass(objects.pole:getBaseMass() - #hangings * 2)

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
                    v:getBody():setMass(v:getBody():getMass() - 10)
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
    if state == CONSTANTS.MENU then
        love.graphics.setColor({255, 255, 255})
        love.graphics.draw(background, 0, 0)
        if buttons.menu.play.img then
            love.graphics.draw(buttons.menu.play.img, buttons.menu.play.x, buttons.menu.play.y, 0, 1, 1, buttons.menu.play.img:getWidth() / 2, buttons.menu.play.img:getHeight() / 2)
            --love.graphics.printf("PLAY", buttons.menu.play.x, buttons.menu.play.y, 50, "center")
        else
            love.graphics.printf("PLAY", buttons.menu.play.x, buttons.menu.play.y, 50, "center")
        end
        if buttons.menu.quit.img then
            love.graphics.draw(buttons.menu.quit.img, buttons.menu.quit.x, buttons.menu.quit.y, 0, 1, 1, buttons.menu.quit.img:getWidth() / 2, buttons.menu.quit.img:getHeight() / 2)
        else
            love.graphics.printf("EXIT", buttons.menu.quit.x, buttons.menu.quit.y, 50, "center")
        end
    elseif state == CONSTANTS.LOADING then
        love.graphics.setColor(logoColor)
        love.graphics.draw(logo, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, 1, 1, logo:getWidth() / 2, logo:getHeight() / 2)
    elseif state == CONSTANTS.PLAYING then
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
            elseif k == "dog_hanging_blue" then
                for i = 1, #hangings do
                    love.graphics.setColor({255, 255, 255})
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
        love.graphics.printf("Perdeu :(\nPlacar: " .. score, love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 -50, 100, "center")
    end
end

function love.mousepressed(x, y, button, isTouch)
    if state == CONSTANTS.MENU then
        for k, v in pairs(buttons.menu) do
            if v.img then
                if isInRange(x, v.x, v.img:getWidth() / 2) and isInRange(y, v.y, v.img:getHeight() / 2) then
                    v.onClick()
                end
            else
                if isClose(x, v.x + 5) and isClose (y, v.y + 5) then
                    v.onClick()
                end
            end
        end
    end
end
