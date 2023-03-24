Obstacle = Class{}

function Obstacle:init()
    math.randomseed(os.time())

    self.width = 54
    self.height = 8

    self.y = math.random(10, VIRTUAL_HEIGHT - self.width)
    self.x = VIRTUAL_WIDTH

    self.dx = STATIC_V
    self.state = 'screen'

    self.timer = 0
    local interval = math.random(100, 300) / 100

    self.behaviors = {
        ['screen'] = function(dt)
            if self.x <  -self.width then
                self.state = 'out'
            end
        end,
        ['out'] = function(dt)
            self.timer = self.timer + dt
            if self.timer < interval then
                self.timer = self.timer + dt
            else
                self.x = VIRTUAL_WIDTH
                self.y = math.random(player.ground_y - self.width, 10)
                self.timer = 0
                interval = math.random(100, 300) / 100
                self.state = 'screen'
            end
        end
    }
end

function Obstacle:update(dt)
    self.behaviors[self.state](dt)
    self.x = self.x - self.dx * dt
end

function Obstacle:render()
    if self.state == 'screen' then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y), self.width, self.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print('syntax error', self.x, self.y)
    end
end

function reset_obstacle()
    self.x = VIRTUAL_WIDTH
    self.y = math.random(VIRTUAL_HEIGHT - self.width)
    self.timer = 0
    local interval = math.random(100, 300) / 10
end