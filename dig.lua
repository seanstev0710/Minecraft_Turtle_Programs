io.write("Enter current y-coord: ")
input1 = io.read()
io.write("\nEnter diameter of dig site.\n Up to 64: ")
diameter = tonumber(io.read())
upperLimit = 16 --upper Mining Limit. Turtle starts mining a square from after reaching this y-coord until the lower limit

xStart = 0
yStart = tonumber(input1)
zStart = 0
xCurrent = xStart
yCurrent = yStart
zCurrent = zStart
xLast = xStart
yLast = yStart
zLast = zStart

xDir = 1 --starting direction is "east"
zDir = 0
lastxDir = xDir
lastzDir = zDir

function EnoughFuel() --returns false if fuel is not enough to go back home
    if turtle.getFuelLevel() > 10 + (xCurrent + yCurrent + zCurrent) then
        return true
    else
        print("Fuel not enough. Returning")
        return false
    end
end

function FullItems()
    if turtle.getItemCount(16) >= 1 then
        return true
    else
        return false
    end
end

function DoResupply()
    if not EnoughFuel() or FullItems() then
        xLast = xCurrent
        yLast = yCurrent
        zLast = zCurrent
        lastxDir = xDir
        lastzDir = zDir
        print("lastxDir: ", lastxDir, "lastzDir: ", lastzDir)
        if not EnoughFuel() then
            print("not enough fuel. Returning Home")
            GoTo(xStart,yStart,zStart,1,0) --go home
            for n = 16, 1, -1 do    
                turtle.select(n)
                turtle.dropUp()
            end
            while not turtle.refuel() and turtle.getFuelLevel() < 500 do
                print("please refuel.")
                sleep(60)
                turtle.refuel()
            end
        end
        
        if FullItems() then
            print("Items Full. Returning Home ")    
            GoTo(xStart,yStart,zStart,1,0)
            for n = 16, 1, -1 do
                turtle.select(n)
                turtle.dropUp()
            end    
            while turtle.getFuelLevel() < 200 do
                print("Fuel Level Low. Please Refuel")
                sleep(60)
                turtle.refuel()
            end
        end

    print("Returning to Mine")    
    GoTo(xLast, yLast, zLast, lastxDir, lastzDir)
    end
end

function GoTo(x,y,z,xd,zd)
    if y > yCurrent then
        while yCurrent < upperLimit do
            MoveUp() 
        end
        if zCurrent ~= z then
            while zDir ~= -1 do
                TurnRight()
            end
            while z ~= zCurrent do
                MoveForward()
            end
        end
        while xCurrent ~= x do
            while xDir ~= -1 do
                TurnLeft()
            end
            MoveForward()
        end
        while yCurrent ~= y do
            MoveUp()
        end
        while zDir ~= zd and xDir ~= xd do
            TurnRight()
        end
        
    elseif y < yCurrent then
        while yCurrent ~= upperLimit do
            MoveDown()
        end
        while xDir ~= 1 do
            TurnRight()
        end
        while xCurrent ~= x do
            MoveForward()
        end
        while zDir ~= 1 do
            TurnLeft()
        end
        while zCurrent ~= z do
            MoveForward()
        end
        while y ~= yCurrent do
            MoveDown()
        end
        while xDir ~= xd or zDir ~= zd do
            print("Trying to face last dir")
            TurnLeft()
        end                   
    end
end

function TurnRight()
    turtle.turnRight()
    xDir, zDir = zDir, -xDir
end

function TurnLeft()
    turtle.turnLeft()
    xDir, zDir = -zDir, xDir
end

function MoveForward() --updates position coords
    if (xCurrent <= diameter and xCurrent >= 0) or (zCurrent <= diameter or zCurrent >= 0) then
        if turtle.forward() then
            if xDir == 1 then
                xCurrent = xCurrent + 1
            elseif xDir == -1 then
                xCurrent = xCurrent - 1
            elseif zDir == 1 then
                zCurrent = zCurrent + 1
            elseif zDir == -1 then
                zCurrent = zCurrent - 1
            end
        else
            turtle.dig()
            MoveForward()
        end
    else
        print("Outside the defined mining area")
        sleep(500)
    end
end

function MoveUp()
    if turtle.up() then
        yCurrent = yCurrent + 1
    else
        turtle.digUp()
    end
end

function MoveDown()
    if turtle.down() then
        yCurrent = yCurrent - 1
    else
        turtle.digDown()
        MoveDown()
    end    
end

function MineForward() --mines block in front and underneath for efficiency
    DoResupply()
    turtle.dig()
    turtle.digDown()
    MoveForward()
end

if turtle.getFuelLevel() < 100 then
    print("Current Fuel Level is too Low")
    print("please refuel")
end

--main function, excavates in a diameter from y = 16 to y = 11
while yCurrent > upperLimit do --go to y = upperLimit then start mining
    MoveDown()
end

while yCurrent > 11 do --mine for the given diameter until y = 11
    while zCurrent < diameter do
        while xDir ~= 1 do
            TurnLeft()
        end
        while xCurrent < diameter do
            MineForward()
        end
        while zDir ~= 1 do
            TurnLeft()
        end
        MineForward()
        while xDir ~= -1 do
            TurnLeft()
        end
        while xCurrent > 0 do
            MineForward()
        end
        while zDir ~= 1 do
            TurnRight()
        end
        if zCurrent < diameter then
            MineForward()
        end
    end
    
    MoveDown()
    MoveDown()
    while zCurrent > 0 and yCurrent > 11 do
        while xDir ~= 1 do
            TurnRight()
        end
        while xCurrent < diameter do
            MineForward()
        end
        while zDir ~= -1 do
            TurnRight()
        end
        MineForward()
        while xDir ~= -1 do
            TurnRight()
        end
        while xCurrent > 0 do
            MineForward()
        end
        while zDir ~= - 1 do
            TurnLeft()
        end
        if zCurrent > 0 then
            MineForward()
        end
    end
    if yCurrent > 11 then
        MoveDown()
        MoveDown()
    end
end
print("Done Mining, Returning Home")
GoTo(0,yStart,0,1,0)
