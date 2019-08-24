local debug = true

-- background image
local bg = nil

-- player object
local player =  { x = 185, y = 710, speed = 250, img = nil}

local lives = 3

local score = 0

local gunshot_sound = nil

require 'bullet'
require 'enemy'
require 'collision'

function love.load(arg)
    bg = love.graphics.newImage('assets/bg.bmp')
    player.img = love.graphics.newImage('assets/plane.png')
    bulletImg = love.graphics.newImage('assets/bullet.png')
    enemyImg = love.graphics.newImage('assets/enemy.png')
    gunshot_sound = love.audio.newSource('assets/gun-sound.wav', 'static')
end

function love.update(dt)
    canShootTimer = canShootTimer - (1 * dt)
    if canShootTimer < 0 then
        canShoot = true
    end

    -- run collision detection
    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
                    bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
                        table.remove(bullets, j)
                        table.remove(enemies, i)
                        score = score + 1
            end
        end

        if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
        and lives > 0 then
            table.remove(enemies, i)
            lives = lives - 1
        end
    end
    
    if love.keyboard.isDown('escape') then
        love.event.quit()
    end
    
    createEnemyTimer = createEnemyTimer - (1 * dt)
    if createEnemyTimer < 0 then
        createEnemyTimer = createEnemyTimerMax
        
        rand = math.random(10, love.graphics.getWidth() - 10)
        newEnemy = { x = rand, y = -10, img = enemyImg, is_hit = false}
        table.insert(enemies, newEnemy)
    end
    
    if love.keyboard.isDown('space') and lives > 0 and canShoot then
        newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
        table.insert(bullets, newBullet)
        canShoot = false
        canShootTimer = canShootTimerMax
        gunshot_sound:play()
    end
    
    if love.keyboard.isDown('left', 'a') then
        player.x = math.max(0, player.x - (player.speed * dt))
    end

    if love.keyboard.isDown('right', 'd') then
        local bound = love.graphics.getWidth() - player.img:getWidth()
        player.x = math.min(bound, player.x + (player.speed * dt))
    end
    
    if love.keyboard.isDown('up', 'w') then
        local bound = love.graphics.getHeight() / 2
        player.y = math.max(bound, player.y - (player.speed * dt))
    end

    if love.keyboard.isDown('down', 's') then
        local bound = love.graphics.getHeight() - 55
        player.y = math.min(bound, player.y + (player.speed * dt))
    end

    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (200 * dt)
        
        if enemy.y > 850 then
            table.remove(enemies, i)
        end
    end

    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (250 * dt)
        
        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    if lives == 0 and love.keyboard.isDown('r') then
        bullets = {}
        enemies = {}

        canShootTimer = canShootTimerMax
        createEnemyTimer = createEnemyTimerMax

        player.x = 185
        player.y = 710

        score = 0
        lives = 3
    end
end
    
    
function love.draw(dt)
    love.graphics.draw(bg, 0, 0)

    if lives > 0 then
        love.graphics.draw(player.img, player.x, player.y)
    else
        love.graphics.print("Press R to restart the game!", love.graphics:getWidth()/2-85, love.graphics:getHeight()/2-10)
    end
    
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end

    for i, bullet in ipairs(bullets) do
        love.graphics.draw(bullet.img, bullet.x, bullet.y)
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.print("SCORE: " .. tostring(score), 400, 10)
    love.graphics.print("LIVES: " .. tostring(lives), 20, 10)
end