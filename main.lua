local class = require 'middleclass'
local flex = require('flex')
local vector = require "hump.vector"
local color = require "colorize"
local player = require "player"

-- Initialization

territoryCanvas = nil

function love.load()
    love.graphics.setColor(0,0,0)
    love.mouse.setVisible(false)
    love.math.setRandomSeed(love.timer.getTime())
    love.window.setMode( 0, 0, {msaa=5,resizable=true} )

    territoryCanvas = love.graphics.newCanvas(1400,1400)
    
    test = player:new(0,0,color.randomHex(),25,5.5,territoryCanvas)
end

objectsToUpdate = {}
objectsToDraw = {}

-- Update

function love.update(dt)
    for i,v in ipairs(objectsToUpdate) do
        v:update(dt)
    end
end

-- Drawing

function drawGrid(lines)
    love.graphics.setLineWidth(3)
    love.graphics.setLineStyle("smooth")

    for i=0,lines do
        love.graphics.line(
            math.cos(math.acos(((i/lines)-0.5) * 2)) * 700, math.sin(math.acos(((i/lines)-0.5) * 2)) * 700,
            math.cos(math.acos(((i/lines)-0.5) * 2)) * 700, math.sin(math.acos(((i/lines)-0.5) * 2)) * -700)
    end
    for i=0,lines do
        love.graphics.line(
            math.sin(math.acos(((i/lines)-0.5) * 2)) * 700, math.cos(math.acos(((i/lines)-0.5) * 2)) * 700,
            math.sin(math.acos(((i/lines)-0.5) * 2)) * -700, math.cos(math.acos(((i/lines)-0.5) * 2)) * 700)
    end
end

function rotatedRectangle( mode, x, y, w, h, rx, ry, segments, r, ox, oy )
	-- Check to see if you want the rectangle to be rounded or not:
	if not oy and rx then r, ox, oy = rx, ry, segments end
	-- Set defaults for rotation, offset x and y
	r = r or 0
	ox = ox or w / 2
	oy = oy or h / 2
	-- You don't need to indent these; I do for clarity
	love.graphics.push()
		love.graphics.translate( x + ox, y + oy )
		love.graphics.push()
			love.graphics.rotate( -r )
			love.graphics.rectangle( mode, -ox, -oy, w, h, rx, ry, segments )
		love.graphics.pop()
	love.graphics.pop()
end

function love.draw()

    -- Init

    flex:origin()
    flex:translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)

    love.graphics.clear(0x00,0x80,0xff)

    -- Arena circles
    
    love.graphics.setColor(0xe2,0xdb,0xa0)
    love.graphics.circle("fill", 0, 0, 710)
    love.graphics.setColor(0xf2,0xee,0xcb)
    love.graphics.circle("fill", 0, 0, 700)

    -- Grid

    love.graphics.setColor(0xe2,0xdb,0xa0)
    drawGrid(50)

    -- Territory canvas

    --love.graphics.setCanvas(territoryCanvas)
     --   love.graphics.setColor(0,0,0,255)
     --   love.graphics.circle("fill",0,0,100)
    --love.graphics.setCanvas()

    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(200,200,200,255)
    love.graphics.draw(territoryCanvas, -700, -690, 0, 1, 1)
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(territoryCanvas, -700, -700, 0, 1, 1)

    -- Objects to draw

    for i,v in ipairs(objectsToDraw) do
        v:draw()
    end

    
    love.graphics.setColor(0,0,0,255)
    mouseX, mouseY = flex:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
    love.graphics.circle("fill", mouseX, mouseY, 5)
end
