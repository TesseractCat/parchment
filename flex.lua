local flex = {}

flex.currentTranslateX, flex.currentTranslateY = 0, 0

flex.cameraTranslateX, flex.cameraTranslateY = 0, 0

function flex:translate(x,y)
    love.graphics.translate(x,y)
    self.currentTranslateX = self.currentTranslateX + x
    self.currentTranslateY = self.currentTranslateY + y
end

function flex:origin()
    self.currentTranslateX, self.currentTranslateY = 0, 0
    love.graphics.origin()
    self:translate(self.cameraTranslateX, self.cameraTranslateY)
end

function flex:inverseTransformPoint(x,y)
    return x - self.currentTranslateX, y - self.currentTranslateY
end

function flex:setCameraPosition(x,y)
    self.cameraTranslateX = x
    self.cameraTranslateY = y
end

function flex:rotate(r)
    love.graphics.translate(-self.currentTranslateX, -self.currentTranslateY)
    love.graphics.rotate(r)
    love.graphics.translate(self.currentTranslateX, self.currentTranslateY)
end

return flex