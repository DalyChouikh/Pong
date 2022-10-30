--Window measures
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

push = require "push"
Class = require 'class'
require 'Ball'
require 'Paddle'

sounds = {
    ['paddle_hit'] = love.audio.newSource('Sounds/paddle_hit.wav','static'),
    ['wall_hit'] = love.audio.newSource('Sounds/wall_hit.wav','static'),
    ['score'] = love.audio.newSource('Sounds/score.wav','static'),
    ['win'] = love.audio.newSource('Sounds/win.wav' , 'static'),
    ['background'] = love.audio.newSource('Sounds/background.wav', 'static')
}

--SETTING UP VIRTUAL RESOLUTION VALUES
VIRTUAL_WIDTH=432
VIRTUAL_HEIGHT = 234

--PADDLE SPEED
PADDLE_SPEED = 200

--INITIALIZINNG SCORE & SERVING PLAYER
player1Score = 0
player2Score = 0
servingPlayer = 1

--DISPLAY FPS FUNCTION
function displayFPS()
    love.graphics.setFont(smallFont)
    if(love.timer.getFPS() >= 30) then
        love.graphics.setColor(0,255,0,255)
    else
        love.graphics.setColor(255,0,0,255)
    end
    love.graphics.printf(
        'FPS : ' .. tostring(love.timer.getFPS()),
        0,
        10,
        VIRTUAL_WIDTH,
        'center'
        )
end


function love.load()
    --SETTING WINDOW TITLE
    love.window.setTitle('Pong')
    --INITIALIZING PLAYERS
    player1 = Paddle(10,10,5,40)
    player2 = Paddle(VIRTUAL_WIDTH - 20,VIRTUAL_HEIGHT-50,5,40)

    --SETTING MATH.RANDOMSEED
    math.randomseed(os.time())

    --INITIALIZING BALL 
    ball = Ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,5,5)

    --SETTING GAMESTATE
    gameState = 'serve'

    --SETTING FILTER
    love.graphics.setDefaultFilter('nearest','nearest')
    --LOADING FONTS
    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf',32)
    largeFont = love.graphics.newFont('font.ttf', 16)
    --SETTING UP VIRTUAL RESOLUTION
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)
    --PLAYER 1 MOVEMENT
    if love.keyboard.isDown("d") then
        player1.dy = PADDLE_SPEED
    elseif love.keyboard.isDown("q") then
        player1.dy = -PADDLE_SPEED
    else
        player1.dy = 0
    end

    --PLAYER 2 MOVEMENT
    if love.keyboard.isDown("right") then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("left") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    --LAUNCHING THE BALL
    if gameState == 'serve' then
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then
            ball.dx = math.random(140,200)
        else
            ball.dx = -math.random(140,200)
        end
    elseif gameState == 'play' then
        --IF THE BALL COLLIDES IT GOES THE OPPOSITE DIRECTION
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.10
            ball.x = player1.x + 6 
            --MAINTAINING THE BALL DIRCTION
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end

            sounds['paddle_hit']:play()
        end
        --IF THE BALL COLLIDES IT GOES THE OPPOSITE DIRECTION
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.10
            ball.x = player2.x - 5

            --MAINTAINING THE BALL DIRCTION
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end

        if ball.y <=0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 5 then
            ball.y = VIRTUAL_HEIGHT - 5
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            if player2Score == 5 then
                winner = 2
                gameState = 'done'
                sounds['win']:play()
            else
                ball:reset()
                gameState = 'serve'
            end
        end
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            if player1Score == 5 then
                winner = 1
                gameState = 'done'
                sounds['win']:play()
            else
                ball:reset()
                gameState = 'serve'
            end
        end
        ball:update(dt)
    end
    player1:update(dt)
    player2:update(dt)
end

--ADDING A PLAY & QUIT BUTTON
function love.keypressed(key)
    if key == 'escape' then
    love.event.quit()
    elseif key == 'return' or key == 'enter' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'serve'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winner == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
    --STARTING THE VIRTUAL RESOLUTION
    push:start()
    --SETTING GAME COLOR
    love.graphics.setColor(255,255,255,255)
    --SETTING SMALL FONT FOR HELLO PONG! AND PRINTING IT
    if gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf(
            string.format('Hello Pong! \n Player %d is serving',servingPlayer),
            0,
            20,
            VIRTUAL_WIDTH,
            'center'
        ) 
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' wins',0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press Enter to restart', 0,40,VIRTUAL_WIDTH,'center')
    end
    --SETTING SCORE FONT AND PRINTING IT
    love.graphics.setFont(scoreFont)
    love.graphics.print(
        tostring(player1Score),
        VIRTUAL_WIDTH/2-50,
        VIRTUAL_HEIGHT/3  
    ) 

    love.graphics.print(
        tostring(player2Score),
        VIRTUAL_WIDTH/2+30,
        VIRTUAL_HEIGHT/3
    ) 
    
    --RENDERING PADDLES
    player1:render()
    player2:render()

    --RENDERING BALL
    ball:render()

    --CALLING THE DISPLAY FPS FUNCTION
    displayFPS()
    
    --FINISHING THE VIRTUAL RESOLUTION
    push:finish()


    
end
