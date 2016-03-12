require "srcs.creature"

Enemy = {}

Enemy.__index = Enemy

enemyCounter = 0

function Enemy.new(world, type, x, y, radius, width, height, color)
    local instance = {}
    setmetatable(instance, Enemy)

    instance.width = width or (radius and radius * 2) or 20
    instance.height = height or (radius and radius * 2) or 20
    instance.radius = radius or 10
    instance.body = love.physics.newBody(world, x or 100, y or 100, "dynamic")
    if radius ~= nil and radius > 0 then
        instance.shape = love.physics.newCircleShape(instance.radius)
    else
        instance.shape = love.physics.newRectangleShape(instance.width, instance.height)
    end
    instance.fixture = love.physics.newFixture(instance.body, instance.shape, 2)
    instance.fixture:setUserData("enemy" .. enemyCounter)
    enemyCounter = enemyCounter + 1

    instance.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}

    instance.lastTime = 1.5
    instance.now = 0
    instance.attacked = false
    instance.type = type or 1
    instance.disappearTime = 10

    return instance
end

setmetatable(Enemy,{__index = Creature})

function Enemy:destroy()
    self:__gc()
end

function Enemy:update(dt)
    self.now = self.now + dt
    if self.type == 1 then
        if self.lastTime - self.now <= 0 and self.attacked == false then
            self.body:applyForce(1500 * self.fixture:getDensity() * (self.width / 4), -700 * self.fixture:getDensity() * self.width / 4)
            self.attacked = true
        end
    elseif self.type == 2 then
        if self.lastTime - self.now <= 0 and self.attacked == false then
            self.body:applyForce(1500 * self.fixture:getDensity() * (self.width / 4), -900 * self.fixture:getDensity() * self.width / 4)
            self.attacked = true
        end
    elseif self.type == 3 then
        if self.lastTime - self.now <= 0 and self.attacked == false then
            self.body:applyForce(1500 * self.fixture:getDensity() * (self.width / 4), -1400 * self.fixture:getDensity() * self.width / 4)
            self.attacked = true
        end
    end
    if self.disappearTime - self.now <= 0 then
        self:destroy()
    end
end

return Enemy
