Class = require 'class'
push = require 'push'

require 'Player'
require 'Obstacle'
require 'Background'

GAME_STATE = 'home'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
R = 23
G = 32
B = 42

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

STATIC_V = 200
DISTANCE = 0
timer = 1
function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    bigFont = love.graphics.newFont('font.ttf', 20)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = true,
        vsync = true,
        canvas = false
    })

    player = Player()

    obstacles = {
        Obstacle(),
    }
    background = Background()
    
    music = love.audio.newSource("sounds/playingMusic.wav", 'stream')
    music:setVolume(0.5)
    fail = love.audio.newSource("sounds/fail.wav", 'static')
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if GAME_STATE == 'home' then
        if key == 'escape' then
            love.event.quit()
        elseif key == 'enter' or 'return' then
            GAME_STATE = 'playing'
            love.graphics.setFont(smallFont)
        end
    elseif GAME_STATE == 'playing' then
        if key == 'escape' then
            GAME_STATE = 'home'
            music:stop()
        elseif (key == 'enter' or key == 'return' or #love.touch.getTouches() > 0 )and player.player_state == 'dead' then
            fail:stop()
            player = Player()
            DISTANCE = 0
            STATIC_V = 200
            background.velocity = 100
            obstacles = {Obstacle()}
            timer = 1
        end
    end
end

function love.update(dt)
    if GAME_STATE == 'playing' then
        if player.player_state ~= 'dead' then
            DISTANCE = DISTANCE + 10 * dt 
            music:play()
            music:setLooping(true)
        else
            music:stop()
        end
        background:update(dt)
        timer = timer + dt
        player:update(dt)

        for x = 1, #obstacles do
            obstacles[x]:update(dt)
        end

        if  math.floor(timer) % 10 == 0 then
            timer = timer + 1
            obstacles[#obstacles + 1] = Obstacle()
        end


        if #obstacles > 1 then
            for x = 1, #obstacles - 1 do
                for y = x + 1, #obstacles do
                    if collides(obstacles[x], obstacles[y]) then
                        obstacles[y].y = math.random(player.ground_y - obstacles[y].width, 10)
                    end
                end
            end
        end

        for x = 1, #obstacles do 
            if collides(player, obstacles[x]) then
                fail:play()
                player.player_state = 'dead'
            end
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(R / 255 , G / 255, B / 255, 1)
    if GAME_STATE == 'playing' then
        background:render()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(" you have travelled " .. tostring(math.floor (DISTANCE)) .. ' meters')
        for x = 1, #obstacles do
        obstacles[x]:render()
        end
        player:render() 
        if player.player_state == 'dead' then
            love.graphics.setFont(bigFont)
            love.graphics.printf('you are dead \n Press enter to restart', 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
        end
    elseif GAME_STATE == 'home' then
        love.graphics.setFont(bigFont)
        love.graphics.printf('Press enter or touch the screen to play \n\n Press escape to quit', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    end

    push:finish()
end

function collides(a, b)
    if a.y + a.height < b.y or 
    a.y > b.y + b.height or 
    a.x > b.x + b.width or 
    a.x + a.width < b.x then
        return false
    else
        return true
    end
end