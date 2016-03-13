Scenary = {}
Scenary.__index = Scenary

scenaryCounter = 0

-- CONSTRUCTOR
function Scenary.new(world, mode, img, name, pos, width, height, color)
    if world == nil then
        return nil
    end
    local instance = {}
    setmetatable(instance, Scenary)

    if type(img) == "string" then
        instance.img = love.graphics.newImage(img)
    else
        instance.img = img
    end

    instance.body = love.physics.newBody(world, pos.x or 100, pos.y or 100, mode or "static")
    instance.shape = love.physics.newRectangleShape(width or (instance.img and instance.img:getWidth()) or 10, height or (instance.img and instance.img:getHeight()) or 10)
    instance.fixture = love.physics.newFixture(instance.body, instance.shape, 1000)
    instance.fixture:setUserData((name .. scenaryCounter) or ("scenary" .. scenaryCounter))
    scenaryCounter = scenaryCounter + 1

    instance.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}

    return instance
end

--GETTER/SETTERS
function Scenary:setBody(pos) self. body = body end

function Scenary:getBody() return self.body end

function Scenary:setShape(shape) self.shape = shape end

function Scenary:getShape() return self.shape end

function Scenary:setFixture(fixture) self.fixture = fixture end

function Scenary:getFixture() return self.fixture end

function Scenary:setColor(color) self.color = color end

function Scenary:getColor() return self.color end

function Scenary:Draw()
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(self.img, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
    --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Scenary
