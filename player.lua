local class = require 'middleclass'
local flex = require('flex')
local vector = require "hump.vector"
local color = require "colorize"

-- PolyPoint

local polyPoint = class('polyPoint')

function polyPoint:initialize(x,y,connections)
    self.x = x
    self.y = y
    self.connections = connections or {}

    for i,conn in ipairs(self.connections) do
        table.insert(conn.connections, self)
    end
end

-- Player

local player = class('player')

function player:initialize(x,y,bodyColor,size,border)
    self.positionX = x
    self.positionY = y
    self.rotation = 0
    self.color = bodyColor
    self.size = size
    self.border = border
    self.onTerritory = true

    self.canvas = love.graphics.newCanvas(1400,1400)
    self.polyPoints = {polyPoint:new(0,0)}

    love.graphics.setCanvas(territoryCanvas)
        love.graphics.setColor(color.hex(self.color,255))
        invX, invY = flex:inverseTransformPoint(0,0)
        love.graphics.circle("fill",invX+700,invY+700,100)
    love.graphics.setCanvas()

    table.insert(objectsToUpdate, self)
    table.insert(objectsToDraw, self)
end

function player:update(dt)
    mouseX, mouseY = flex:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())

    direction = -vector(self.positionX - mouseX,self.positionY - mouseY):normalized() * dt * 240
    self.positionX = self.positionX + direction.x
    self.positionY = self.positionY + direction.y

    self.rotation = vector(self.positionX - mouseX, self.positionY - mouseY):normalized():angleTo(vector(-1,0))

    flex:setCameraPosition(-self.positionX, -self.positionY)

    if not self.onTerritory then
        lastPolyPoint = self.polyPoints[#self.polyPoints]
        if (vector(lastPolyPoint.x, lastPolyPoint.y) - vector(self.positionX, self.positionY)):len() > 25 then
            table.insert(self.polyPoints, polyPoint:new(self.positionX, self.positionY, {lastPolyPoint}))
        end
    end
end

function player:getPolygon()
    vertices = {}

    for i, polyPoint in ipairs(self.polyPoints) do
        x, y = flex:inverseTransformPoint(polyPoint.x, polyPoint.y)
        table.insert(vertices, x+700)
        table.insert(vertices, y+700)
    end

    return vertices
end

function player:draw()
    x, y = self.positionX, self.positionY

    -- *** Check if on territory ***
    r,g,b,a = 0,0,0,0
    if pcall(function () 
        r,g,b,a = territoryCanvas:newImageData(x+700, y+700, 1, 1):getPixel(0,0)
    end) then
    end
    
    if r+g+b == 0 and self.onTerritory then
        self.onTerritory = false
        love.graphics.setCanvas(self.canvas)
            love.graphics.clear()
        love.graphics.setCanvas()
    elseif r+g+b ~= 0 and not self.onTerritory then
        self.onTerritory = true

        love.graphics.setCanvas(self.canvas)

            trailImageData = self.canvas:newImageData(0,0,1400,1400)
            trailImageData:mapPixel(function (x, y, r, g, b, a)
                if r ~= 0 then
                    r = 255
                    g = 255
                    b = 255
                    a = 255
                end
                return r,g,b,a
            end)
            trailImage = love.graphics.newImage(trailImageData)

            love.graphics.clear()

        love.graphics.setCanvas()

        -- Draw territory
        love.graphics.setCanvas(territoryCanvas)
            love.graphics.setColor(color.hex(self.color, 255))
            vertices = self:getPolygon()
            love.graphics.polygon("fill",vertices)
            
            invX,invY= flex:inverseTransformPoint(0,0)
            love.graphics.draw(trailImage,invX,invY)
        love.graphics.setCanvas()
    end
    -- ******
    
    love.graphics.setLineWidth(self.border)
    love.graphics.setLineStyle("smooth")

    -- *** Poly Points ***

    for i,point in ipairs(self.polyPoints) do
        love.graphics.setColor(0,0,0,255)
        --love.graphics.circle("fill",point.x,point.y,3)
    end

    -- *** Trail ***
    if not self.onTerritory then
        love.graphics.setCanvas(self.canvas)
            love.graphics.setColor(color.hex(self.color, 100))
            invX,invY= flex:inverseTransformPoint(x,y)
            love.graphics.circle("fill",invX+700,invY+700,10)
        love.graphics.setCanvas()

        love.graphics.setBlendMode("alpha")
        love.graphics.draw(self.canvas, -700, -700, 0, 1, 1)
    end
    -- ******

    love.graphics.translate(x,y)

    -- *** Player ***
    -- Shadow
    love.graphics.translate(0,6)
    love.graphics.rotate(self.rotation)
    love.graphics.setColor(color.hex(self.color)[1] - 60,color.hex(self.color)[2] - 60,color.hex(self.color)[3] - 60,255)
    love.graphics.rectangle("fill",-(self.size/2),-(self.size/2),self.size,self.size)
    love.graphics.rectangle("line",-(self.size/2),-(self.size/2),self.size,self.size,2,2,20)
    love.graphics.rotate(-self.rotation)
    love.graphics.translate(0,-6)

    love.graphics.rotate(self.rotation)
    
    -- Body
    love.graphics.setColor(color.hex(self.color))
    love.graphics.rectangle("fill",-(self.size/2),-(self.size/2),self.size,self.size)

    -- Outline
    love.graphics.setColor(color.hex(self.color)[1] - 60,color.hex(self.color)[2] - 60,color.hex(self.color)[3] - 60,255)
    love.graphics.rectangle("line",-(self.size/2),-(self.size/2),self.size,self.size,2,2,20)

    love.graphics.rotate(-self.rotation)
    love.graphics.translate(-x,-y)
    -- ******
end

return player