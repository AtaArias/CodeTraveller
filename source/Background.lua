Background = Class{}

function Background:init()
    smallFont = love.graphics.newFont('font.ttf', 8)
    love.graphics.setFont(smallFont)

    self.velocity = 100

    self.str1X = VIRTUAL_WIDTH
    self.str2X = 2 * VIRTUAL_WIDTH
    self.str3X = 3 * VIRTUAL_WIDTH
    self.string1 = [[
        function generateQuads(atlas, tilewidth, tileheight)
            local sheetWidth = atlas:getWidth() / tilewidth
            local sheetHeight = atlas:getHeight() / tileheight
        
            local sheetCounter = 1
            local quads = {}
        
            for y = 0, sheetHeight - 1 do
                for x = 0, sheetWidth - 1 do
                    quads[sheetCounter] = love.graphics.newQuad(x * tilewidth, y  * tileheight, tilewidth, tileheight, atlas:getDimensions())
                    sheetCounter = sheetCounter + 1
                end
            end
        
            return quads
        end
    ]]

    self.string2 = [[
        function Animation:init(params)

            self.texture = params.texture
        
            -- quads defining this animation
            self.frames = params.frames or {}
        
            -- time in seconds each frame takes (1/20 by default)s
            self.interval = params.interval or 0.05
        
            -- stores amount of time that has elapsed
            self.timer = 0
        
            self.currentFrame = 1
        end
        
        function Animation:getCurrentFrame()
            return self.frames[self.currentFrame]
        end
        
        function Animation:restart()
            self.timer = 0
            self.currentFrame = 1
        end
        
        function Animation:update(dt)
            self.timer = self.timer + dt
        
            -- iteratively subtract interval from timer to proceed in the animation,
            -- in case we skipped more than one frame
            -- also shortcut if we only have 1 frame
            if #self.frames == 1 then
                return self.currentFrame
            else
                while self.timer > self.interval do
                    self.timer = self.timer - self.interval
        
                    -- modulo on frames + 1 so we can increment to the last frame without
                    -- wrapping around (and skipping the last frame)
                    self.currentFrame = (self.currentFrame + 1) % (#self.frames + 1)
        
                    -- Lua tables start at 1, not 0; so after modulo to 0, increment
                    if self.currentFrame == 0 then self.currentFrame = 1 end
                end
            end
        end
    ]]

    self.string3 = [[
        ['running'] = function(dt)
            self.y = self.ground_y - self.height
            self.dy = 0 
            if love.keyboard.isDown('space') then
                self.player_state = 'flying'
            end
        end,
        ['dead'] = function(dt)
    
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
    ]]

end

function Background:update(dt)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    self.str1X = self.str1X - self.velocity * dt
    self.str2X = self.str2X - self.velocity * dt
    self.str3X = self.str3X - self.velocity * dt

    if self.str1X < -VIRTUAL_WIDTH then
        self.str1X = 2 * VIRTUAL_WIDTH
    elseif self.str2X < -VIRTUAL_WIDTH then
        self.str2X = 2 * VIRTUAL_WIDTH
    elseif self.str3X < -VIRTUAL_WIDTH then
        self.str3X = 2 * VIRTUAL_WIDTH
    end
end

function Background:render()
    love.graphics.printf(self.string1, self.str1X, 10, VIRTUAL_WIDTH - 10)
    love.graphics.printf(self.string2, self.str2X, 10, VIRTUAL_WIDTH - 10)
    love.graphics.printf(self.string3, self.str3X, 10, VIRTUAL_WIDTH - 10)
    love.graphics.line(0, player.ground_y, VIRTUAL_WIDTH, player.ground_y)
    love.graphics.line(0, 10, VIRTUAL_WIDTH, 10)
end