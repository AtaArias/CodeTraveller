Player = Class{}
Jet_power = 500
GRAVITY = 100

require 'Util'
require 'Animation'

function Player:init()
    self.width = 16
    self.height = 16

    self.engine_sound = love.audio.newSource("sounds/jetpack.wav", 'static')
    self.steps = love.audio.newSource("sounds/steps.wav", 'static')
    self.steps:setVolume(3)

    self.ground_y = VIRTUAL_HEIGHT - self.height 

    self.x =  self.width * 5
    self.y = self.ground_y  - self.height

    self.texture = love.graphics.newImage('graphics/player.png')
    self.frames = generateQuads(self.texture, self.width, self.height)

    self.dx = 0
    self.dy = 0

    self.player_state = 'running'

    self.time_in_states = 0

    self.animations = {
        ['flying'] = Animation {
            texture = self.texture,
            frames = {self.frames[1], self.frames[2], self.frames[3]},
            interval = 0.15
        },
        ['running'] = Animation {
            texture = self.texture,
            frames = {
                 self.frames[4], self.frames[5]
            },
            interval = 0.01
        },
        ['falling'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[6]
            },
            interval = 1
        },
        ['dead'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[6]
            },
            interval = 1
        }
    }

    self.behaviors = {
        ['flying'] = function(dt)
            self.time_in_states = self.time_in_states + dt
            self.engine_sound:play()
            if self.y < 10 then 
                self.y = 10
            elseif self.y > self.ground_y - self.height then
                self.y = self.ground_y - self.height
                self.dy = -1 * dt
            end
            if love.keyboard.isDown('space') or #love.touch.getTouches() > 0 then
                self.dy = math.max(self.dy - Jet_power * dt, -100)
            else
                self.time_in_states = 0
                self.player_state = 'falling'
                self.engine_sound:stop()
            end
        end,
        ['falling'] = function(dt)
            self.time_in_states = self.time_in_states + dt
            if love.keyboard.isDown('space') or #love.touch.getTouches() > 0 then
                self.time_in_states = 0
                self.player_state = 'flying'
            elseif self.y >= self.ground_y - self.height then
                self.time_in_states = 0
                self.player_state = 'running'
            else
                self.dy = GRAVITY 
            end
        end,
        ['running'] = function(dt)
            self.y = self.ground_y - self.height
            self.dy = 0 
            self.steps:setPitch(math.random(50, 200) / 100 )
            self.steps:play()
            if love.keyboard.isDown('space') or #love.touch.getTouches() > 0 then
                self.player_state = 'flying'
            end
        end,
        ['dead'] = function(dt)
            self.engine_sound:stop()
            background.velocity = 0

            for x = 1, #obstacles do
                obstacles[x].dx = 0
            end
            if self.y < self.ground_y - self.height then
                self.dy = GRAVITY 
            else
                self.y = self.ground_y - self.height
            end
        end
    }
end

function Player:update(dt)
    self.behaviors[self.player_state](dt)
    self.animations[self.player_state]:update(dt)
    self.y = self.y + self.dy * dt
end

function Player:render()
    love.graphics.draw(self.texture, self.animations[self.player_state]:getCurrentFrame(), math.floor(self.x), math.floor(self.y))
end