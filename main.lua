-----------------------------------------------------------------------------------------
--
-- Created by: Aden Rao
-- Created on: April 29, 2019
--
-- This program lets the user control a character, shoot bullets left and right and make the character jump. There are also two characters 
--
-----------------------------------------------------------------------------------------

-- Gravity

local physics = require( "physics" )

physics.start()
physics.setGravity( 0, 25 ) -- ( x, y )
-- physics.setDrawMode( "hybrid" )   -- Shows collision engine outlines only

local playerBullets = {} -- Table that holds the players Bullets


-- Hides status bar
display.setStatusBar(display.HiddenStatusBar)

-- Cloud image 
-----------------------------
local cloud = display.newImageRect( "assets/sprites/clouds.jpg", 2500, 1500 )
cloud.x = display.contentCenterX
cloud.y = display.contentCenterY
cloud.id = "cloud"
----------------------------

-- Left wall
----------------
local leftWall = display.newRect( 0, display.contentHeight / 2, 1, display.contentHeight )
leftWall.alpha = 0.0
physics.addBody( leftWall, "static", { 
    friction = 0.5, 
    bounce = 0.3 
    } )
-----------------

-- The ground that the character stands on
-----------------
local theGround1 = display.newImageRect( "./assets/sprites/land.png", 2500, 400 )
theGround1.x = display.contentCenterX
theGround1.y = display.contentHeight
theGround1.id = "the ground"
physics.addBody( theGround1, "static", { 
    friction = 0.5, 
    bounce = 0.3 
    } )
----------------

-- Robot character
-------------------
local badCharacter = display.newImage( "./assets/sprites/enemy.png" )
badCharacter.x = 1520
badCharacter.y = display.contentHeight - 1000
badCharacter.id = "bad character"
physics.addBody( badCharacter, "dynamic", { 
    friction = 0.5, 
    bounce = 0.3 
    } )
-------------------

-- Ninga character
-------------------
local theCharacter = display.newImage( "./assets/sprites/character.png" )
theCharacter.x = display.contentCenterX - 200
theCharacter.y = display.contentCenterY
theCharacter.id = "the character"
physics.addBody( theCharacter, "dynamic", { 
    density = 3.0, 
    friction = 0.5, 
    bounce = 0.3 
    } )
theCharacter.isFixedRotation = true -- If you apply this property before the physics.addBody() command for the object, it will merely be treated as a property of the object like any other custom property and, in that case, it will not cause any physical change in terms of locking rotation.
-------------------

-- Dpad, up arrow, down arrow, left arrow and right arrow
---------------------------
local dPad = display.newImage( "./assets/sprites/d-pad.png" )
dPad.x = 150
dPad.y = display.contentHeight - 80
dPad.alpha = 0.50
dPad.id = "d-pad"

local upArrow = display.newImage( "./assets/sprites/upArrow.png" )
upArrow.x = 150
upArrow.y = display.contentHeight - 190
upArrow.id = "up arrow"

local downArrow = display.newImage( "./assets/sprites/downArrow.png" )
downArrow.x = 150
downArrow.y = display.contentHeight + 28
downArrow.id = "down arrow"

local leftArrow = display.newImage( "./assets/sprites/leftArrow.png" )
leftArrow.x = 40
leftArrow.y = display.contentHeight - 80
leftArrow.id = "left arrow"

local rightArrow = display.newImage( "./assets/sprites/rightArrow.png" )
rightArrow.x = 260
rightArrow.y = display.contentHeight - 80
rightArrow.id = "right arrow"
---------------------------

-- Jump button, shoot button for the left side and shoot button for the right side
---------------------------
local jumpButton = display.newImage( "./assets/sprites/jumpButton.png" )
jumpButton.x = display.contentWidth - 80
jumpButton.y = display.contentHeight - 80
jumpButton.id = "jump button"
jumpButton.alpha = 0.5

local shootButton = display.newImage( "./assets/sprites/jumpButton.png" )
shootButton.x = display.contentWidth - 250
shootButton.y = display.contentHeight - 80
shootButton.id = "shootButton"

local shootButtonTwo = display.newImage( "./assets/sprites/jumpButton.png" )
shootButtonTwo.x = display.contentWidth + 80
shootButtonTwo.y = display.contentHeight - 80
shootButtonTwo.id = "shootButton"
--------------------------- 

-- Collison for the character
local function characterCollision( self, event )
 
    if ( event.phase == "began" ) then
        print( self.id .. ": collision began with " .. event.other.id )
 
    elseif ( event.phase == "ended" ) then
        print( self.id .. ": collision ended with " .. event.other.id )
    end
end

-- if character falls off the end of the world, respawn back to where it came from
local function checkCharacterPosition( event )
    -- check every frame to see if character has fallen
    if theCharacter.y > display.contentHeight + 500 then
        theCharacter.x = display.contentCenterX - 200
        theCharacter.y = display.contentCenterY
    end
end

local function checkPlayerBulletsOutOfBounds()
    -- check if any bullets have gone off the screen
    local bulletCounter

    if #playerBullets > 0 then
        for bulletCounter = #playerBullets, 1 , -1 do
            if playerBullets[bulletCounter].x > display.contentWidth + 1000 then
                playerBullets[bulletCounter]:removeSelf()
                playerBullets[bulletCounter] = nil
                table.remove(playerBullets, bulletCounter)
                print("remove bullet")
            end
        end
    end
end

-- Collison for if a bullet hits a the robot character
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.id == "bad character" and obj2.id == "bullet" ) or
             ( obj1.id == "bullet" and obj2.id == "bad character" ) ) then
            -- Removes the laser and asteroid
            display.remove( obj1 )
            display.remove( obj2 )
            
            -- removes the bullet
            local bulletCounter = nil
            
            for bulletCounter = #playerBullets, 1, -1 do
                if ( playerBullets[bulletCounter] == obj1 or playerBullets[bulletCounter] == obj2 ) then
                    playerBullets[bulletCounter]:removeSelf()
                    playerBullets[bulletCounter] = nil
                    table.remove( playerBullets, bulletCounter )
                    break
                end
            end

            --removes the robot character
            badCharacter:removeSelf()
            badCharacter = nil

            -- Creates an explosion sound effect and plays it
            local expolsionSound = audio.loadStream( "./assets/sounds/8bit_bomb_explosion.wav" )
            local explosionChannel = audio.play( expolsionSound )

            -- Explosion image that appears when bullet hits characther
            local explosionImage = display.newImageRect( "./assets/sprites/fire.png", 200, 200 )
            explosionImage.x = display.contentCenterX + 500
            explosionImage.y = display.contentCenterY + 200
            explosionImage.id = "explosionImage"

        end
    end
end

-- Up arrow, left arrow, down arrow and right arrow functions to make the ninga charcater move.
--------------------------
function upArrow:touch( event )
    if ( event.phase == "ended" ) then
        -- move the character up
        transition.moveBy( theCharacter, { 
            x = 0, -- move 0 in the x direction 
            y = -50, -- move up 50 pixels
            time = 100 -- move in a 1/10 of a second
            } )
    end

    return true
end

function downArrow:touch( event )
    if ( event.phase == "ended" ) then
        -- move the character up
        transition.moveBy( theCharacter, { 
            x = 0, -- move 0 in the x direction 
            y = 50, -- move up 50 pixels
            time = 100 -- move in a 1/10 of a second
            } )
    end

    return true
end

function leftArrow:touch( event )
    if ( event.phase == "ended" ) then
        -- move the character up
        transition.moveBy( theCharacter, { 
            x = -50, -- move 0 in the x direction 
            y = 0, -- move up 50 pixels
            time = 100 -- move in a 1/10 of a second
            } )
    end

    return true
end

function rightArrow:touch( event )
    if ( event.phase == "ended" ) then
        -- move the character up
        transition.moveBy( theCharacter, { 
            x = 50, -- move 0 in the x direction 
            y = 0, -- move up 50 pixels
            time = 100 -- move in a 1/10 of a second
            } )
    end

    return true
end

function jumpButton:touch( event )
    if ( event.phase == "ended" ) then
        -- make the character jump
        theCharacter:setLinearVelocity( 0, -750 )
    end

    return true
end
--------------------------

 -- Function for making the shoot button shoot a bullet right
----------------------
function shootButton:touch( event )
    if ( event.phase == "began" ) then
        -- make a bullet appear
        local aSingleBullet = display.newImage( "./assets/sprites/Kunai.png" )
        aSingleBullet.x = theCharacter.x
        aSingleBullet.y = theCharacter.y
        physics.addBody( aSingleBullet, 'dynamic' )
        -- Make the object a "bullet" type object
        aSingleBullet.isBullet = true
        aSingleBullet.isFixedRotation = true
        aSingleBullet.gravityScale = 0
        aSingleBullet.id = "bullet"
        aSingleBullet:setLinearVelocity( 1500, 0 )

        table.insert(playerBullets,aSingleBullet)
        print("# of bullet: " .. tostring(#playerBullets))
    end

    return true
end
----------------------

 -- Function for making the shoot button shoot a bullet left
-----------------------
function shootButtonTwo:touch( event )
    if ( event.phase == "began" ) then
        -- make a bullet appear
        local aSingleBullet = display.newImage( "./assets/sprites/Kunai.png" )
        aSingleBullet.x = theCharacter.x - 180 
        aSingleBullet.y = theCharacter.y
        physics.addBody( aSingleBullet, 'dynamic' )
        -- Make the object a "bullet" type object
        aSingleBullet.isBullet = true
        aSingleBullet.isFixedRotation = true
        aSingleBullet.gravityScale = 0
        aSingleBullet.id = "bullet"
        aSingleBullet:setLinearVelocity( 10000, 0 )

        table.insert(playerBullets,aSingleBullet)
        print("# of bullet: " .. tostring(#playerBullets))
    end

    return true
end
-----------------------

-- Up, left, right and down arrow event listeners
-------------------
upArrow:addEventListener( "touch", upArrow )
downArrow:addEventListener( "touch", downArrow )
leftArrow:addEventListener( "touch", leftArrow )
rightArrow:addEventListener( "touch", rightArrow )
-------------------

-- Jump and shoot buttons event listeners
jumpButton:addEventListener( "touch", jumpButton )
shootButton:addEventListener( "touch", shootButton )
shootButtonTwo:addEventListener( "touch", shootButtonTwo )

-- Event listners for checking the charcaters position, if they are out of the game and for the collisons
Runtime:addEventListener( "enterFrame", checkCharacterPosition )
Runtime:addEventListener( "enterFrame", checkPlayerBulletsOutOfBounds )
Runtime:addEventListener( "collision", onCollision )