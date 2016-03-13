require "srcs.creature"

Enemy = {}

Enemy.__index = Enemy

enemyCounter = 0

function Enemy.new(world, anim, type, x, y, orientation, angle, radius, width, height, color)
    local instance = {}
    setmetatable(instance, Enemy)

    instance.width = (anim and anim:getWidth()) or width or (radius and radius * 2) or 20
    instance.height = (anim and anim:getHeight()) or height or (radius and radius * 2) or 20
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
    instance.animation = deepCopy(anim)
    instance.animation:play()
    instance.angle = angle or 0
    instance.orientation = orientation or {x = 1, y = -1}

    return instance
end

setmetatable(Enemy,{__index = Creature})

function Enemy:destroy()
    self:__gc()
end

function Enemy:update(dt)
    self.now = self.now + dt
    self.animation:update(dt)
    local x, y = self.body:getLinearVelocity()

    if self.lastTime - self.now <= 0 and self.attacked == false then
        self:setAnimation(deepCopy(animations["dog_jumping"]))
        if self.type == 1 then
            self.body:applyForce(self.body:getMass() * 300, -self.body:getMass() * 25000)
            self.attacked = true
        elseif self.type == 2 then
            self.body:setLinearVelocity(x + 3, 6)
            self.body:applyForce(self.body:getMass() * 300, -self.body:getMass() * 33333)
            self.attacked = true
        elseif self.type == 3 then
            self.body:setLinearVelocity(x + 3, 7)
            self.body:applyForce(self.body:getMass() * 300, -self.body:getMass() * 50000)
            self.attacked = true
        end
    elseif self.attacked == false then
        self.body:applyForce(self.body:getMass() * 250, 0)
    end
    if self.disappearTime - self.now <= 0 then
        self:destroy()
    end
end

return Enemy
