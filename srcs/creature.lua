local Creature = {}
Creature.__index = Creature

-- CONSTRUCTOR
function Creature.new(world, x, y, radius, width, height, color)
    if world == nil then
        return nil
    end
    local cre = {}
    setmetatable(cre, Creature)

    cre.body = love.physics.newBody(world, x or 100, y or 100, "dynamic")
    if radius ~= nil and radius > 0 then
        cre.shape = love.physics.newCircleShape(radius)
    else
        cre.shape = love.physics.newRectangleShape(width or 10, height or 10)
    end
    cre.fixture = love.physics.newFixture(cre.body, cre.shape, 2)

    cre.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}

    return cre
end

--GETTER/SETTERS
function Creature:setBody(pos) self. body = body end

function Creature:getBody() return self.body end

function Creature:setShape(shape) self.shape = shape end

function Creature:getShape() return self.shape end

function Creature:setColor(color) self.color = color end

function Creature:getColor() return self.color end

function Creature:Draw()
    love.graphics.setColor(self.color)
    if self.shape:type() == "CircleShape" then
        love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
    else
        love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    end
end

return Creature
