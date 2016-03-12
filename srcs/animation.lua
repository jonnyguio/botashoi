local Animation = {}
Animation.__index = Animation

animationCounter = 0

function Animation.new(name, img, w, h, x, y)
  local instance = {}
  setmetatable(instance, Animation)

  instance.name, instance.w, instance.h = name or "anim" .. animationCounter, w, h

 -- print(img)
  if type(img) == "string" then
      instance.img = love.graphics.newImage(img)
  else
      instance.img = img
  end
--  print(instance.img)

  instance.x = x or 100
  instance.y = y or 100
  instance.delay = 0.1
  instance.playing = false
  animationCounter = animationCounter + 1
  instance.frames = {}
  instance.currentFrame = 1
  instance.elapsed = 0

  return instance
end

function Animation:Draw(x, y, drawingVarious, angle, orientation)
    local quad = self.frames[(self.currentFrame + (drawingVarious or 0)) % #self.frames + 1]
    if quad then
        love.graphics.setColor({255, 255, 255})
        love.graphics.draw(self.img, quad, x or self.x, y or self.y, angle, orientation and orientation.x, orientation and orientation.y)
    end
end

function Animation:update(dt)
    if #self.frames == 0 or not self.playing then return end

    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.delay then
        self.elapsed = self.elapsed - self.delay
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > #self.frames then
            self.currentFrame = 1
        end
    end
end

function Animation:play()
  self.playing = true
end

function Animation:stop()
  self.playing = false
  self.currentFrame = 1
  self.elapsed = 0
end

function Animation:pause()
  self.playing = false
end

function Animation:getWidth() return self.w end

function Animation:getHeight() return self.h end

function Animation:addFrame(col, row)
    --[[print (self.w)
    print (self.h)
    print (self.img:getWidth())
    print (self.img:getHeight())]]--
    local quad = love.graphics.newQuad((col - 1) * self.w, (row - 1) * self.h, self.w, self.h, self.img:getWidth(), self.img:getHeight())
    self.frames[#self.frames + 1] = quad
    return self
end

return Animation
