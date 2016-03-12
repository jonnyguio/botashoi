Scenary = {}
Scenary.__index = Scenary

scenaryCounter = 0

-- CONSTRUCTOR
function Scenary.new(world, name, pos, width, height, color)
    if world == nil then
        return nil
    end
    local instance = {}
    setmetatable(instance, Scenary)

    instance.body = love.physics.newBody(world, pos.x or 100, pos.y or 100, "static")
    instance.shape = love.physics.newRectangleShape(width or 10, height or 10)
    instance.fixture = love.physics.newFixture(instance.body, instance.shape)
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
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Scenary
