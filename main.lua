Pole = require "pole"

function init()
    pole = Pole.new()
    print(pole:Pos().x)
    print(pole:Pos().y)
    print(pole:Angle())
    print(pole:Width())
    print(pole:Height())
    print(pole:Color()[1])
    print(pole:Color()[2])
    print(pole:Color()[3])
    success = love.window.setMode(800, 600, {fullscreen = false})
end

init()

function love.draw()
    love.graphics.setColor(pole:Color())
    love.graphics.rectangle( "fill", pole:Pos().x, pole:Pos().y, pole:Width(), pole:Height())
end


function love.keypressed(key)

end
