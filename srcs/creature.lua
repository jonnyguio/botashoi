Creature = {}
Creature.__index = Creature
Creature.__gc = function(self)
    for i, x in pairs(objects.creatures) do
        for j, y in pairs(x) do
            if y:getFixture():getUserData() == self.fixture:getUserData() then
                table.remove(x, j)
            end
        end
    end
    self.fixture:destroy()
    --self.shape:destroy()
    self.body:destroy()
end

creatureCounter = 0

-- CONSTRUCTOR/DESTRUCTOR
function Creature.new(world, anim, name, x, y, orientation, angle, radius, width, height, color)
    if world == nil then
        return nil
    end
    local instance = {}
    setmetatable(instance, Creature)

    instance.body = love.physics.newBody(world, x or 100, y or 100, "dynamic")
    if radius ~= nil and radius > 0 then
        instance.shape = love.physics.newCircleShape(radius)
    else
        instance.shape = love.physics.newRectangleShape((anim and anim:getWidth()) or width or 10, (anim and anim:getHeight()) or height or 10)
    end
    instance.fixture = love.physics.newFixture(instance.body, instance.shape, 2)
    instance.fixture:setUserData((name .. creatureCounter) or ("creature" .. creatureCounter))
    creatureCounter = creatureCounter + 1

    instance.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}
    instance.animation = deepCopy(anim)

    instance.angle = angle or 0
    instance.orientation = orientation or {x = 1, y = 1}

    return instance
end

function Creature:destroy()
end

--GETTER/SETTERS
function Creature:setName(name) self.name = name end

function Creature:getName() return self.name end

function Creature:setBody(pos) self.body = body end

function Creature:getBody() return self.body end

function Creature:setShape(shape) self.shape = shape end

function Creature:getShape() return self.shape end

function Creature:setFixture(fixture) self.fixture = fixture end

function Creature:getFixture() return self.fixture end

function Creature:setColor(color) self.color = color end

function Creature:getColor() return self.color end

function Creature:getAnimation() return self.animation end

function Creature:setAnimation(anim)
    self.animation = anim
    self.width = (anim and anim:getWidth()) or self.width
    self.height = (anim and anim:getHeight()) or self.height
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    local data = self.fixture:getUserData()
    self.fixture = love.physics.newFixture(self.body, self.shape, 2)
    self.fixture:setUserData(data)
end

function Creature:update(dt)
    self.animation:update(dt)
end

function Creature:Draw()
    if self.animation then
        love.graphics.setColor({255, 255, 255})
        self.animation:Draw(self.body:getX(), self.body:getY(), 0, self.angle, self.orientation)
        love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
    else
        love.graphics.setColor(self.color)
        if self.shape:type() == "CircleShape" then
            love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
        else
            love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
        end
    end
end

return Creature
