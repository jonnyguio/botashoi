Pole = {}
Pole.__index = Pole

-- CONSTRUCTOR
function Pole.new(world, x, y, angle, width, height, color)
    if world == nil then
        return nil
    end
    local instance = {}
    setmetatable(instance, Pole)

    instance.body = love.physics.newBody(world, (x or love.graphics.getWidth() / 2), (y or love.graphics.getHeight() / 2), "dynamic")
    instance.shape = love.physics.newRectangleShape(width or 20, height or 300)
    instance.fixture = love.physics.newFixture(instance.body, instance.shape, 15)
    instance.fixture:setUserData("pole")
    --instance.pos = pos or {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

    instance.angle = angle or 90
    instance.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}
    return instance
end

-- GETTERS/SETTERS
function Pole:getAngle(angle) self.angle = angle end

function Pole:setAngle() return self.angle end

function Pole:setBody(body) self.body = body end

function Pole:getBody() return self.body end

function Pole:setShape(shape) self.shape = shape end

function Pole:getShape() return self.shape end

function Pole:setColor(color) self.color = color end

function Pole:getColor() return self.color end

--FUNCTIONS
function Pole:Draw()
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Pole
