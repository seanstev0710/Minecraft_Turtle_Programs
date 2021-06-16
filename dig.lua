gps_Is_On = false
rednet_Is_On = false

io.write("Enter current y-coord: ")
local yCoordinate = io.read()
io.write("\nEnter diameter of dig site.\n Up to 64: ")
diameter = tonumber(io.read())
upperLimit = 16 --upper Mining Limit. Turtle starts mining a square from after reaching this y-coord until the lower limit

start = vector.new(0,0,0)
start.y = tonumber(yCoordinate)
current = vector.new(start.x, start.y, start.z)
last = vector.new(start.x, start.y, start.z)

xDir = 1 --starting direction is "east"
zDir = 0
lastxDir = xDir
lastzDir = zDir

counter = 1
----------------------------------*Location Functions*----------------------------

--tests if there is a working gps server within range.
--Returns false if there is none
function GPS_IsWorking()
    local x,y,z = gps.locate()
    if x == nil or y == nil or z == nil then
        return false
    end
    return true
end

--Opens rednet if modem is attached to turtle
function Open_Rednet() 
    local modem_Side
    local sides_With_Peripherals = peripheral.getNames()
    for key, side in pairs(sides_With_Peripherals) do
        if peripheral.getType(side) == "modem" then
            rednet.open(side)
            modem_Side = side
            break
        end
    end
    return rednet.isOpen(modem_Side)
end

--broadcasts "computer label" and location to channel 65535 
function Broadcast_Location()
    x, y, z = gps.locate()
    if counter == 5 then
        rednet.broadcast(os.getComputerID() .. " at " .. x .. " " .. y .. " " .. z)
        counter = 0
    end
    counter = counter + 1
end


----------------------------------*Misc Functions*----------------------------


--returns false if fuel is not enough to go back home
function EnoughFuel()
    if turtle.getFuelLevel() > 10 + (current.x + current.y + current.z) then
        return true
    else
        print("Fuel not enough. Returning")
        return false
    end
end

--returns true if all 16 slots of inventory has at least 1 item
function FullItems()
    if turtle.getItemCount(16) >= 1 then
        return true
    else
        return false
    end
end

--If Fuel is low or items are full. The turtle will go back to starting point
--If fuel is needed the turtle will stop moving until fuel is at least 500
--If items are full, the turtle will throw item above or into a container on top of its initial starting point
function DoResupply()
    if not EnoughFuel() or FullItems() then
        last.x = current.x
        last.y = current.y
        last.z = current.z
        lastxDir = xDir
        lastzDir = zDir
        if not EnoughFuel() then
            print("not enough fuel. Returning Home")
            GoTo(start.x,start.y,start.z,1,0) --go home
            for n = 16, 1, -1 do    
                turtle.select(n)
                turtle.dropUp()
            end
            while not turtle.refuel() and turtle.getFuelLevel() < 500 do
                for n = 16, 1, -1 do
                    turtle.select(n)
                    turtle.dropUp()
                end 
                print("please refuel.")
                sleep(60)
                for n = 16, 1, -1 do
                    turtle.select(n)
                    turtle.refuel()
                end 
            end
        end
        
        if FullItems() then
            print("Items Full. Returning Home ")    
            GoTo(start.x,start.y,start.z,1,0)
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
    GoTo(last.x, last.y, last.z, lastxDir, lastzDir)
    end
end


----------------------------------*Move Functions*----------------------------


function GoTo(x,y,z,xd,zd)
    if y > current.y then
        while current.y < upperLimit do
            MoveUp() 
        end
        if current.z ~= z then
            while zDir ~= -1 do
                TurnRight()
            end
            while z ~= current.z do
                MoveForward()
            end
        end
        while current.x ~= x do
            while xDir ~= -1 do
                TurnLeft()
            end
            MoveForward()
        end
        while current.y ~= y do
            MoveUp()
        end
        while zDir ~= zd and xDir ~= xd do
            TurnRight()
        end
        
    elseif y < current.y then
        while current.y ~= upperLimit do
            MoveDown()
        end
        while xDir ~= 1 do
            TurnRight()
        end
        while current.x ~= x do
            MoveForward()
        end
        while zDir ~= 1 do
            TurnLeft()
        end
        while current.z ~= z do
            MoveForward()
        end
        while y ~= current.y do
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
    if gps_Is_On then
        Broadcast_Location()
    end
    if (current.x <= diameter and current.x >= 0) or (current.z <= diameter or current.z >= 0) then
        if turtle.forward() then
            current.x = current.x + xDir
            current.z = current.z + zDir
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
        current.y = current.y + 1
    else
        turtle.digUp()
    end
end

function MoveDown()
    if turtle.down() then
        current.y = current.y - 1
    else
        turtle.digDown()
        MoveDown()
    end    
end

--mines block in front and underneath for efficiency
function MineForward() 
    DoResupply()
    turtle.dig()
    turtle.digDown()
    MoveForward()
end


----------------------------------*Main Function*----------------------------

io.write("Activate Location Broadcast?(Y/N): ")
local userInput = io.read()
if userInput == "Y" or userInput == "y" then
    rednet_Is_On = Open_Rednet()
    if rednet_Is_On == true then
        gps_Is_On = GPS_IsWorking
        print("GPS has been turned on")
    else
        print("GPS not functioning properly")
    end
end

if rednet_Is_On == true then
    Open_Rednet()
end

if turtle.getFuelLevel() < 100 then
    print("Current Fuel Level is too Low")
    print("please refuel")
end

--main function, excavates in a diameter from y = 16 to y = 11
while current.y > upperLimit do --go to y = upperLimit then start mining
    MoveDown()
end

while current.y > 11 do --mine for the given diameter until y = 11
    while current.z < diameter do
        while xDir ~= 1 do
            TurnLeft()
        end
        while current.x < diameter do
            MineForward()
        end
        while zDir ~= 1 do
            TurnLeft()
        end
        MineForward()
        while xDir ~= -1 do
            TurnLeft()
        end
        while current.x > 0 do
            MineForward()
        end
        while zDir ~= 1 do
            TurnRight()
        end
        if current.z < diameter then
            MineForward()
        end
    end
    
    MoveDown()
    MoveDown()
    while current.z > 0 and current.y > 11 do
        while xDir ~= 1 do
            TurnRight()
        end
        while current.x < diameter do
            MineForward()
        end
        while zDir ~= -1 do
            TurnRight()
        end
        MineForward()
        while xDir ~= -1 do
            TurnRight()
        end
        while current.x > 0 do
            MineForward()
        end
        while zDir ~= - 1 do
            TurnLeft()
        end
        if current.z > 0 then
            MineForward()
        end
    end
    if current.y > 11 then
        MoveDown()
        MoveDown()
    end
end
print("Done Mining, Returning Home")
GoTo(0,start.y,0,1,0)
