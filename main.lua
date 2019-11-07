local class = require 'middleclass'
local flex = require('flex')
local vector = require "hump.vector"
local color = require "colorize"

-- Initialization

function love.load()
    love.graphics.setColor(0,0,0)
    love.mouse.setVisible(false)
    love.math.setRandomSeed(love.timer.getTime())
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

function player:initialize(x,y,color,size,border)
    self.positionX = x
    self.positionY = y
    self.rotation = 0
    self.color = color
    self.size = size
    self.border = border

    self.canvas = love.graphics.newCanvas(1400,1400)

    table.insert(objectsToUpdate, self)
    table.insert(objectsToDraw, self)
end

function player:update(dt)
    mouseX, mouseY = flex:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())

    direction = -vector(self.positionX - mouseX,self.positionY - mouseY):normalized() * dt * 190
    self.positionX = self.positionX + direction.x
    self.positionY = self.positionY + direction.y

    self.rotation = vector(self.positionX - mouseX, self.positionY - mouseY):normalized():angleTo(vector(-1,0))

    flex:setCameraPosition(-self.positionX, -self.positionY)
end

function player:draw()
    x, y = self.positionX, self.positionY
    
    --love.graphics.circle("fill", x, y, 20)
    
    love.graphics.setLineWidth(self.border)
    love.graphics.setLineStyle("smooth")

    -- *** Trail ***
    love.graphics.setCanvas(self.canvas)
        love.graphics.setColor(color.hex(self.color, 100))
        invX,invY= flex:inverseTransformPoint(x,y)
        love.graphics.circle("fill",invX+700,invY+700,10)
    love.graphics.setCanvas()

    love.graphics.setBlendMode("alpha")
    love.graphics.draw(self.canvas, -700, -700, 0, 1, 1)
    -- ******

    love.graphics.translate(x,y)

    -- *** Player ***
    -- Shadow
    love.graphics.translate(0,6)
    love.graphics.rotate(self.rotation)
    love.graphics.setColor(color.hex(self.color)[1] - 100,color.hex(self.color)[2] - 100,color.hex(self.color)[3] - 100,255)
    love.graphics.rectangle("fill",-(self.size/2),-(self.size/2),self.size,self.size)
    love.graphics.rectangle("line",-(self.size/2),-(self.size/2),self.size,self.size)
    love.graphics.rotate(-self.rotation)
    love.graphics.translate(0,-6)

    love.graphics.rotate(self.rotation)
    
    -- Body
    love.graphics.setColor(color.hex(self.color))
    love.graphics.rectangle("fill",-(self.size/2),-(self.size/2),self.size,self.size)

    -- Outline
    love.graphics.setColor(color.hex(self.color)[1] - 60,color.hex(self.color)[2] - 60,color.hex(self.color)[3] - 60,255)
    love.graphics.rectangle("line",-(self.size/2),-(self.size/2),self.size,self.size)

    love.graphics.rotate(-self.rotation)
    love.graphics.translate(-x,-y)
    -- ******
end

local test = player:new(0,0,color.randomHex(),30,5)

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
