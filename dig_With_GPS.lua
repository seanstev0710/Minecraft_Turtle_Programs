-- Sean Alcantara
-- dig_With_GPS.lua
-- A program for Minecraft's ComputerCraft Mining Turtles

----------------------------------*Variables*-------------------------------

local gps_isOpen = false
local start = vector.new(0,0,0)
local current = start
local last = start

-------------------------------*Setup Functions*-------------------------------


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

--will only work if a working GPS server is properly setup
--returns false if gps.locate() fails
function Get_Actual_Coordinates()
    local x, y, z = gps.locate()
    if x ~= nil and y ~= nil and z ~= nil then
        local start = vector.new(x,y,z)
        return true, start
    else
        return false, start
    end
end

--Uses the point x = 0, z = 0 and y = userInput of actual y-coordinate
function Get_Relative_Coordinates()
    x , y, z = 0, nil, 0
    while assert( tonumber(y) ) do
        print("Enter Current y-coordinate: ")
        io.read(y)
    end
end


-------------------------------*Miscellaneous*-------------------------------


--broadcasts "computer label" and location to channel 65535 
function Broadcast_Location()
    rednet.broadcast(os.getComputerLabel() .. " at " .. current.x .. " " .. current.y .. " " .. current.z)
end

--checks if fuel is enough to return to starting point.
--returns true if fuel is not enough
function Fuel_isNotEnough()

end

--Saves_Location to 
function Save_Location()

end

-------------------------------*Movement Functions*-------------------------------


--Go To Designated location facing the specified direction
function GoTo(x, y, z)

end

--Mines forward and moves forward if successful returns true
function MineForward()
    turtle.digDown()
    turtle.dig()
    if(turtle.forward) then
        current.x = current.x + xDir
        current.z = current.z + zDir
    end
end

--Mines Downward and moves Downward if successful returns true
function MineDown()

end

--Mines Upward and moves Upward if successful returns true
function MineUp()

end

-------------------------------*MAIN FUNCTION*-------------------------------
if Open_Rednet then
    gps_isOpen = true
end

if gps_isOpen then
    gps_isOpen, start = Get_Actual_Coordinates
