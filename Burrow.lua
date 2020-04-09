-- *************************************************************** --
-- **                                                           ** --
-- **    Minecraft Mining Turtle Burrow v0.0.4 by Dentsor       ** --
-- **    ------------------------------------------------       ** --
-- **                                                           ** --
-- **    This program is a more advanced tunneling program 3*3  ** --
-- **                                                           ** --
-- **    Change Log:                                            ** --
-- **       8th Apr 2014: [v0.0.1] Rerelease                    ** --
-- **      23rd Jun 2019: [v0.0.3] Added adjustable height      ** --
-- **                                                           ** --
-- *************************************************************** --
-- **    Todo:                                                  ** --
-- **       - Restart program / save state                      ** --
-- **       - Adjustable width (starting left corner)           ** --
-- **       - Refueling                                         ** --
-- *************************************************************** --

local tArgs = { ... }
if #tArgs ~= 2 then
	print( "Usage: burrow <length> <height>" )
	return
end

local length = tonumber( tArgs[1] )
local height = tonumber( tArgs[2] )
if length < 1 then
	print( "Tunnel length must be positive" )
	return
end
if height < 1 then
	print( "Tunnel height must be positive" )
	return
end

local xSave,ySave = 0,0
local xPos,yPos = 0,0
local xDir,yDir = 1,1
local torch,tSide,tNum = 0,0,1
local torchOn = false
local firstRun = true
local mined = 0

local done = false

local function digFront()
	while turtle.detect() do
		turtle.dig()
		sleep(0.5)
	end
end

local function digUp()
	while turtle.detectUp() do
		turtle.digUp()
		sleep(0.5)
	end
end

local function digDown()
	while turtle.detectDown() do
		turtle.digDown()
		sleep(0.5)
	end
end

local function moveFront()
	while turtle.forward() == false do
		turtle.dig()
		turtle.attack()
	end
	xPos = xPos + xDir
	torch = torch + tNum
end

local function moveBack()
	while turtle.forward() == false do
		turtle.dig()
		turtle.attack()
	end
	xPos = xPos - xDir
	torch = torch - tNum
end

local function moveUp()
	while turtle.up() == false do
		turtle.dig()
		turtle.attackUp()
	end
	yPos = yPos + yDir
end

local function moveDown()
	while turtle.down() == false do
		turtle.dig()
		turtle.attackDown()
	end
	yPos = yPos - yDir
end

local function refuel()
	turtle.select(16)
	
	if turtle.getFuelLevel() < 1 then
		print("Turtle now needs fuel to work")
	end
	
	if turtle.getItemCount(16) < 64 then
		print("Please put more fuel (coal or simular) into the 16th slot")
		for i = 1, 15 do
			turtle.select(i)
			if turtle.compareTo(16) then
				transfer = turtle.getItemSpace(16)
				turtle.transferTo(16, transfer)
			end
		end
	end
	
	while turtle.getFuelLevel() < 1280 do
		if turtle.getItemCount(16) < 64 then
			print("Please insert more fuel")
		end
		
		fuel = turtle.getFuelLevel()+80
		turtle.refuel(1)
		
		
		if turtle.getFuelLevel() < fuel then
			print("Please use coal as fuel")
		end
		
		if turtle.getItemCount(16) > 1 then
			amount = turtle.getItemCount(16) - 1
			turtle.refuel(amount)
		end
		
		for i = 1, 15 do
			turtle.select(i)
			if turtle.compareTo(16) then
				transfer = turtle.getItemSpace(16)
				turtle.transferTo(16, transfer)
			end
		end
	end
	turtle.select(1)
end

local function stepUp()
	digFront()
	digUp()
	moveUp()
	digFront()
end

local function stepDown()
	digFront()
	digDown()
	moveDown()
	digFront()
end

local function stepFront()
	digFront()
	moveFront()
end

local function emptyInventory()
	
	refuel()
	
	itemcount = turtle.getItemCount(13)
	if itemcount > 0 then
		print("Inventory almost full, returning to empty inventory!")
		
		xSave = xPos
		ySave = yPos
		
		turtle.turnLeft()
		turtle.turnLeft()
		
		while yPos > 0 do
			moveDown()
		end
		
		while xPos > 0 do
			moveBack()
		end
		
		for i=1,14 do
			turtle.select(i)
			turtle.drop()
		end

		if not torchOn then
			turtle.select(15)
			turtle.drop()
		end
		
		turtle.select(1)
		
		turtle.turnLeft()
		turtle.turnLeft()
		
		itemcount = turtle.getItemCount(14)
		if itemcount == 0 then
			print("Inventory empty!")
		end
		
		while xPos < xSave do
			moveFront()
		end
		
		while yPos < ySave do
			moveUp()
		end
	end
end

local function move()

	stepFront()
	
	turtle.turnLeft()

	digFront()

	for i = 1, height-1 do
		stepUp()
	end

	turtle.turnRight()
	emptyInventory()
	turtle.turnRight()
	
	for i = 1, height-1 do
		stepDown()
	end

	digFront()
	
	if torchOn then
		if torch == 4 then
			torch = 0
			
			if turtle.getItemCount(15) < 64 then
				print("Please put torches into the 15th slot")
				for i = 1, 14 do
					turtle.select(i)
					if turtle.compareTo(15) then
						transfer = turtle.getItemSpace(15)
						turtle.transferTo(15, transfer)
					end
				end
			end
			
			if turtle.getItemCount(15) > 1 then
				turtle.select(15)
				turtle.place()
				turtle.select(1)
			end
		end
	end
	
	turtle.turnLeft()
	
	mined = mined + 1
	print ("Mined " .. mined .. " of " .. length .. " layers.")
end

local function toStart()
	turtle.turnLeft()
	turtle.turnLeft()
	
	while yPos > 0 do
		moveDown()
	end
	
	while xPos > 0 do
		moveBack()
	end
	
	for i=1,14 do
		turtle.select(i)
		turtle.drop()
	end
	
	turtle.select(1)
	
	turtle.turnLeft()
	turtle.turnLeft()
end

while done == false do
	if firstRun == true then
		if turtle.getItemCount(15) > 0 then
			torchOn = true
		end
		
		firstRun = false
	end
	
	refuel()
	move()
	emptyInventory()
	
	if xPos >= length then
		toStart()
		done = true
		print("Finished mining!")
	end
end