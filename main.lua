local class = require 'middleclass'
local flex = require('flex')
local vector = require "hump.vector" 

-- Initialization

function love.load()
    love.graphics.setColor(0,0,0)
    love.mouse.setVisible(false)

    love.window.setMode( 0, 0, {msaa=5,resizable=true} )
end

objectsToUpdate = {}
objectsToDraw = {}

-- Update

function love.update(dt)
    for i,v in ipairs(objectsToUpdate) do
        v:update(dt)
    end
end

-- Player

local player = class('player')

function player:initialize(x,y)
    self.positionX = x
    self.positionY = y
    self.rotation = 0

    table.insert(objectsToUpdate, self)
    table.insert(objectsToDraw, self)
end

function player:update(dt)
    mouseX, mouseY = flex:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())

    direction = -vector(self.positionX - mouseX,self.positionY - mouseY):normalized() * dt * 170
    self.positionX = self.positionX + direction.x
    self.positionY = self.positionY + direction.y

    self.rotation = math.atan(
        vector(self.positionX - mouseX,self.positionY - mouseY):normalized().x,
        vector(self.positionX - mouseX,self.positionY - mouseY):normalized().y)

    flex:setCameraPosition(-self.positionX, -self.positionY)
end

function player:draw()
    x, y = self.positionX, self.positionY

    love.graphics.setColor(255,0,0,255)
    love.graphics.circle("fill", x, y, 20)

    love.graphics.line(x,y,x+math.cos(self.rotation)*50,y+math.sin(self.rotation)*50)
end

local test = player:new(0,0)

-- Drawing

function drawGrid(lines)
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
    flex:origin()
    flex:translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)

    love.graphics.clear(0x00,0x80,0xff)

    
    love.graphics.setColor(0xe2,0xdb,0xa0)
    love.graphics.circle("fill", 0, 0, 710)
    love.graphics.setColor(0xf2,0xee,0xcb)
    love.graphics.circle("fill", 0, 0, 700)

    love.graphics.setColor(0xe2,0xdb,0xa0)
    drawGrid(50)

    for i,v in ipairs(objectsToDraw) do
        v:draw()
    end

    
    love.graphics.setColor(0,0,0,255)
    mouseX, mouseY = flex:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
    love.graphics.circle("fill", mouseX, mouseY, 5)
end
