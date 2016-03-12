Pole = {}
Pole.__index = Pole

-- CONSTRUCTOR
function Pole.new(world, img, x, y, width, height, color)
    if world == nil then
        return nil
    end
    local instance = {}
    setmetatable(instance, Pole)

    if type(img) == "string" then
        instance.img = love.graphics.newImage(img)
    else
        instance.img = img
    end

    instance.body = love.physics.newBody(world, (x or love.graphics.getWidth() / 2), (y or love.graphics.getHeight() / 2), "dynamic")
    instance.shape = love.physics.newRectangleShape(width or 20, height or 300)
    instance.fixture = love.physics.newFixture(instance.body, instance.shape, 105)
    instance.fixture:setUserData("pole")
    --instance.pos = pos or {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}

    instance.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}
    return instance
end

-- GETTERS/SETTERS
function Pole:setBody(body) self.body = body end

function Pole:getBody() return self.body end

function Pole:setShape(shape) self.shape = shape end

function Pole:getShape() return self.shape end

function Pole:setColor(color) self.color = color end

function Pole:getColor() return self.color end

function Pole:getPos() return self.body:getPosition() end

--FUNCTIONS
function Pole:Draw(x, y)
    love.graphics.setColor(self.color)
    love.graphics.draw(self.img, self.body:getX() - self.img:getWidth() / 2, self.body:getY(), self.body:getAngle())
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
end

return Pole
