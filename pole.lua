local Pole = {}
Pole.__index = Pole

-- CONSTRUCTOR
function Pole.new(pos, angle, width, height, color)
    local ple = {}
    setmetatable(ple, Pole)
    ple.pos = pos or {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}
    ple.angle = angle or 90
    ple.width = width or 20
    ple.height = height or 100
    ple.color = color or {132, 123, 200}
    return ple
end

-- GETTERS/SETTERS
function Pole:Angle(angle) self.angle = angle end

function Pole:Angle() return self.angle end

function Pole:Pos(pos) self.pos = pos end

function Pole:Pos() return self.pos end

function Pole:Width(width) self.width = width end

function Pole:Width() return self.width end

function Pole:Height(pos) self.height = height end

function Pole:Height() return self.height end

function Pole:Color(color) self.color = color end

function Pole:Color() return self.color end

return Pole
