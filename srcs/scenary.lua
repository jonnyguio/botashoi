local Scenary = {}
Scenary.__index = Scenary

-- CONSTRUCTOR
function Scenary.new(world, pos, width, height, color)
    if world == nil then
        return nil
    end
    local sce = {}
    setmetatable(sce, Scenary)

    sce.body = love.physics.newBody(world, pos.x or 100, pos.y or 100, "static")
    sce.shape = love.physics.newRectangleShape(width or 10, height or 10)
    sce.fixture = love.physics.newFixture(sce.body, sce.shape)

    sce.color = color or {math.random(0,255), math.random(0,255), math.random(0,255)}

    return sce
end

--GETTER/SETTERS
function Scenary:setBody(pos) self. body = body end

function Scenary:getBody() return self.body end

function Scenary:setShape(shape) self.shape = shape end

function Scenary:getShape() return self.shape end

function Scenary:setColor(color) self.color = color end

function Scenary:getColor() return self.color end

function Scenary:Draw()
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

return Scenary
