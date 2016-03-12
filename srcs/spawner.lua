Spawner = {}
Spawner.__index = Spawner

function Spawner.new(anim, type, x, y, delay)

    local instance = {}
    setmetatable(instance, Spawner)

    instance.x = x or 30
    instance.y = y or 100
    instance.delay = delay or 2
    instance.lastTime = delay or 2
    instance.now = 0
    instance.type = type or 1
    instance.animation = anim

    return instance
end

function Spawner:update(dt)
    if self.lastTime - self.now <= 0 then
        local enemy = Enemy.new(world, self.animation, self.type, self.x, self.y, {x = -1, y = 1})

        table.insert(objects.creatures.enemies, enemy)
        self.lastTime = self.delay
        self.now = 0
    else
        self.now = self.now + dt
    end
end

return Spawner
