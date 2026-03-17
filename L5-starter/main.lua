require("L5")
function setup()
    size(400, 400)
    windowTitle('404 Error')
    background('white')
    noStroke()
    describe('A basic drawing program in L5. A random fill color each mouse press.')
end

function mouseDragged()
    -- Draw a circle that follows the mouse when held down
    circle(mouseX, mouseY, 20)
end

function mousePressed()
    -- Pick a random color on mouse press
    fill(random(255), random(255), random(255))
end
