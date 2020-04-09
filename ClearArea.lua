-- *************************************************************** --
-- **                                                           ** --
-- **    Minecraft Mining Turtle ClearArea v0.0.5 by Dentsor    ** --
-- **    -----------------------------------------------        ** --
-- **                                                           ** --
-- **    This program will simply clear the given area          ** --
-- **                                                           ** --
-- **    Change Log:                                            ** --
-- **      28th Mar 2020: [v0.0.5] Adding negative height       ** --
-- **      19th Aug 2019: [v0.0.4] Rewrote and cleaned up code  ** --
-- **       7th Apr 2014: [v0.0.3] Added get fuel, return etc   ** --
-- **       7th Apr 2014: [v0.0.2] Added emptying inv.          ** --
-- **       5th Apr 2014: [v0.0.1] Initial Release              ** --
-- **                                                           ** --
-- *************************************************************** --
 
 
-- *************************************************************** --
-- **    Todo List:                                             ** --
-- **       - Add reason for returning to empty                 ** --
-- **       - Add autosave for process, so it can               ** --
-- **         continue after reboot                             ** --
-- **       - Add functionality to work like OreQuarry          ** --
-- **         - Mine every third layer                          ** --
-- **         - Filter which blocks to ignore                   ** --
-- *************************************************************** --
 
local diggingUp = true
 
local startX = 1
local startY = 1
local startZ = 1
 
local posX = 1
local posY = 1
local posZ = 1
local posD = 0

local maxX = 0
local maxY = 0
local maxZ = 0

local savedX = 0
local savedY = 0
local savedZ = 0
local savedD = 0

local collectedOre = 0
local collectedMob = 0
local finished = false

local invFromDrop = 1
local invToDrop = 15
local invDefault = 1
local invFuel = 16

local itemcount = 0

local programName = "ClearArea"
local logFile = "ClearArea_log.txt"
local statusMessage = nil

-- Retrieve arguments
local args = { ... }

-- If supplied with a "c" as first and only argument, clean up chests for replacing
if #args == 1 and args[1] == "c" then
	turtle.turnLeft()
	turtle.dig()
	turtle.turnLeft()
	turtle.dig()
end

-- Inform the user how to use the program if incorrect variables supplied
if #args ~= 2 then
	print( "Usage: "..programName.." <width> <height>" )
	return
end

-- Retrieve width and return if less than 1
local width = tonumber( args[1] )
if width < 1 then
	print( "Room width must be positive" )
	return
end

-- Retrieve height and return if less than 1
local height = tonumber( args[2] )

if height < 0 then
	diggingUp = false
	height = -1 * height
end

if height < 1 then
	print( "Room height must be positive" )
	return
end

-- Append string with new line and return
local function str_nl(str, append)
	if append == nil then
		append = ""
	end
	if str == nil then
		return append
	end
	return str.."\r\n"..append
end

-- Set and print statusMessage
local function status(str)
	statusMessage = str
	print( str )
end

-- Save text to file
function save(name, text)
	local file = fs.open(name, "w")
	file.write(text)
	file.close()
end

-- Load text from file
function load(name)
	local file = fs.open(name, "r")
	local data = file.readAll()
	file.close()
	return data
end

-- Append text to start of logFile
function logWrite(text)
	local old = load(logFile)
	local new = text.."\r\n".."\r\n".."\r\n".."\r\n"..old
	save(logFile, new)
end

local function screen(err)
	shell.run("clear")
	
	local str = nil
	
	if err then
		str = str_nl( str, "Error has occurred in "..programName..", please contact a system administrator and provide them this information:" )
		str = str_nl( str, "Error code: "..err )
	else
		str = str_nl( str, "Running: "..programName )
	end
	
	str = str_nl( str )
	str = str_nl( str, "Position: ("..posX..", "..posY..", "..posZ..")" )
	str = str_nl( str, "Direction: "..posD )
	
	if err then
		str = str_nl( str, "Maximum: ("..maxX..", "..maxY..", "..maxZ..")" )
		str = str_nl( str, "Saved: ("..savedX..", "..savedY..", "..savedZ..") with Direction: "..savedD )
	else
		str = str_nl( str )
	end
	
	str = str_nl( str, "Width x Height: "..width.." x "..height )
	str = str_nl( str, "Blocks mined: "..collectedOre )
	str = str_nl( str, "Mobs hit: "..collectedMob)
	str = str_nl( str, "Fuel level: "..turtle.getFuelLevel() )
	
	if statusMessage then
		str = str_nl( str )
		str = str_nl( str, "Last status: "..statusMessage )
	end

	-- Print string to screen
	print( str )
	
	if err then
		-- Save string to file
		logWrite(str)

		-- Sleep for a minute at a time...
		while true do
			sleep(60)
		end
	end
end

-- Get total itemcount in inventory
local function getInventoryCount(iStart, iEnd)
	itemcount = 0
	for i=iStart,iEnd do
		itemcount = itemcount + turtle.getItemCount(i)
	end
	return itemcount
end

-- Iterate mining counter
local function collectMine()
	collectedOre = collectedOre + 1
	screen()
end

-- Iterate attack counter
local function collectAttack()
	collectedMob = collectedMob + 1
	screen()
end

-- Try digging in front, wait in case of sand, gravel etc.
local function tryDig()
	while turtle.detect() do
		if turtle.dig() then
			collectMine()
			sleep(0.5)
		else
			return false
		end
	end
	screen()
	return true
end

-- Try digging up, wait in case of sand, gravel etc.
local function tryDigUp()
	while turtle.detectUp() do
		if turtle.digUp() then
			collectMine()
			sleep(0.5)
		else
			return false
		end
	end
	screen()
	return true
end

-- Try digging down, wait in case of sand, gravel etc.
local function tryDigDown()
	while turtle.detectDown() do
		if turtle.digDown() then
			collectMine()
			sleep(0.5)
		else
			return false
		end
	end
	screen()
	return true
end

-- Make sure there's always a stacks worth of coal in the internal buffer
-- Refuel when necessary
local function refuel()
	local fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" or fuelLevel > 5120 then
		return
	end

	-- If there's more than one item in slot 16, select it and consume all except 1, leaving one to reserve the slot
	local function tryRefuel()
		if turtle.getItemCount(16) > 1 then
		turtle.select(16)
		turtle.refuel( turtle.getItemCount(16) - 1 )
		turtle.select(1)
		return true
		end

		turtle.select(1)
		return false
	end
       
	if not tryRefuel() then
		status( "Add more fuel to continue." )
		while not tryRefuel() do
			sleep(1)
		end
		status( "Resuming "..programName )
	end
end

-- 
local function changeToX()
	posX = posX +1
	if posX > maxX then
		maxX = posX
	end
end
 
local function changeToY()
	posY = posY +1
	if posY > maxY then
		maxY = posY
	end
end
 
local function changeToZ()
	posZ = posZ +1
	if posZ > maxZ then
		maxZ = posZ
	end
end
 
local function changeFromX()
	posX = posX -1
end
 
local function changeFromY()
	posY = posY -1
end
 
local function changeFromZ()
	posZ = posZ -1
end
 
local function changeXYZ(direction)
	if direction == "x" then
		changeToX()
	elseif direction == "y" then
		changeToY()
	elseif direction == "z" then
		changeToZ()
	elseif direction == "-x" then
		changeFromX()
	elseif direction == "-y" then
		changeFromY()
	elseif direction == "-z" then
		changeFromZ()
	end
end

-- Try to move up, if necessary dig or attack
local function tryUp()
	refuel()
	if diggingUp then
		while not turtle.up() do
			if turtle.detectUp() then
				if not tryDigUp() then
					-- return false -- ToDelete
					-- Sleep instead of proceeding with faulty movement!
					sleep( 0.5 )
				end
			elseif turtle.attackUp() then
				collectAttack()
			else
				sleep( 0.5 )
			end
		end
	else
		while not turtle.down() do
			if turtle.detectDown() then
				if not tryDigDown() then
					sleep( 0.5 )
				end
			elseif turtle.attackDown() then
				collectAttack()
			else
				sleep( 0.5 )
			end
		end
	end
	changeXYZ("y")
	screen()
	return true
end

-- Try to move down, if necessary dig or attack
local function tryDown()
	refuel()
	if diggingUp then
		while not turtle.down() do
			if turtle.detectDown() then
				if not tryDigDown() then
					-- return false -- ToDelete
					-- Sleep instead of proceeding with faulty movement!
					sleep( 0.5 )
				end
			elseif turtle.attackDown() then
				collectAttack()
			else
				sleep( 0.5 )
			end
		end
	else
		while not turtle.up() do
			if turtle.detectUp() then
				if not tryDigUp() then
					sleep( 0.5 )
				end
			elseif turtle.attackUp() then
				collectAttack()
			else
				sleep( 0.5 )
			end
		end
	end
	changeXYZ("-y")
	screen()
	return true
end

-- Try to move forward, if necessary dig or attack
local function tryForward(dir)
	refuel()
	while not turtle.forward() do
		if turtle.detect() then
			if not tryDig() then
				-- return false -- ToDelete
				-- Sleep instead of proceeding with faulty movement!
				sleep( 0.5 )
			end
		elseif turtle.attack() then
			collectAttack()
		else
			sleep( 0.5 )
		end
	end
	changeXYZ(dir)
	screen()
	return true
end

-- Turn left and de-iterate directional variable
local function turnLeft()
	if turtle.turnLeft() then
		posD = posD - 1
	end
	screen()
end

-- Turn right and iterate directional variable
local function turnRight()
	if turtle.turnRight() then
		posD = posD + 1
	end
	screen()
end

-- Turn until direction is equal to the specified direction variable
local function setDir(dir)
	-- Find amount of turns required to see if more effective to turn the other direction, else iterate until direction is correct
	local diff = posD - dir
	if diff == 3 then
		turnRight()
		posD = dir
	elseif diff == -3 then
		turnLeft()
		posD = dir
	else
		while posD > dir do
			turnLeft()
		end
		while posD < dir do
			turnRight()
		end
	end
end
 
-- Determine if turtle is finished and ready to proceed
-- Different conditions depending on even and odd width
local function layerFinished()
	if width % 2 == 0 then
		-- even
		-- if posX <= startX and maxX >= width and maxZ >= width then -- ToDelete
		if posX == startX and maxX == width and maxZ == width then
			return true
		elseif posX <= startX and maxX >= width and maxZ >= width then
			screen("LayerFinished_maxValueMissmatch_Even")
		else
			return false
		end
	else
		-- odd
		-- if posX >= width and maxX >= width and maxZ >= width then -- ToDelete
		if posX == width and maxX == width and maxZ == width then
			return true
		elseif posX >= width and maxX >= width and maxZ >= width then
			screen("LayerFinished_maxValueMissmatch_Odd")
		else
			return false
		end
	end
end

-- Return home and empty inventory
local function returnHome(reason)
	status( "Returning home ["..reason.."]" )

	savedX = posX
	savedY = posY
	savedZ = posZ
	savedD = posD

	-- Return home
	if posZ > startZ then
		setDir(-1)
		while posZ > startZ do
			tryForward("-z")
		end
	end
	if posX > startX then
		setDir(-2)
		while posX > startX do
			tryForward("-x")
		end
	end
	while posY > startY do
		tryDown()
	end
	
	-- Empty inventory
	setDir(-2)
	for i=invFromDrop,invToDrop do
		turtle.select(i)
		--if not turtle.compareTo(invFuel) then
		turtle.drop()
		--end
	end
	
	-- If there is room for more fuel in fuel slot or fuel left elsewhere in inventory, empty inventory and refill fuel slot
	if turtle.getItemSpace(invFuel) > 0 or getInventoryCount(invFromDrop, invToDrop) > 0 then
		-- Turn towards fuel chest
		setDir(-1)
		
		-- Empty inventory of fuel stuck in other slots
		for i=invFromDrop,invToDrop do
			turtle.select(i)
			turtle.drop()
		end
		
		-- Refill fuel slot
		turtle.select(invFuel)
		turtle.suck()
	end
	
	-- If there's not enough fuel in the chest, wait for player intervention
	if turtle.getItemCount(invFuel) < 64 then
		status( "Apply more fuel to continue..." )
		setDir(-1)
		turtle.select(invFuel)
		while turtle.getItemCount(invFuel) < 64 do
			sleep(1)
			turtle.suck()
		end
		if turtle.getItemSpace(invFuel) == 0 then
			for i=invFromDrop,invToDrop do
				turtle.select(i)
				turtle.drop()
			end
		else
			screen("EmptyInventory_invFuelItemSpace_notEqualZero")
		end
	end
	turtle.select(invDefault)
	
	setDir(0)
	
	-- If returned 'cause finished
	if reason == "finished" then
		finished = true
		-- Todo: Proper finish screen
		status( "Finished mining" )
	elseif reason == "layer" then -- Return to last layer, then continue on the next one
		while posY < savedY do
			tryUp()
		end
	else -- Return to mining
		while posY < savedY do
			tryUp()
		end
		while posX < savedX do
			tryForward("x")
		end
		if posZ < savedZ then
			turnRight()
			while posZ < savedZ do
				tryForward("z")
			end
		end
	
		setDir(savedD)
	end
	
	savedX = 0
	savedY = 0
	savedZ = 0
	savedD = 0
end


-- Evaluate whether to return or not
local function evalReturn()
	if turtle.getItemCount(invToDrop) > 0 then
		returnHome("inventory")
	elseif turtle.getItemCount(invFuel) < 64 then
		returnHome("fuel")
	end
end


-- Procedure for mining out a layer
local function layer()
	setDir(0)
	-- While layer not finished -> go back and forth along X and mine
	while not layerFinished() do
		-- If not long enough
		if posX < width then
			-- Mine forth along the length
			while posX < width do
				tryForward("x")
				evalReturn()
			end
			-- If not wide enough, turn and prepare for next length
			if posZ < width then
				turnRight()
				tryForward("z")
				turnRight()
			end
		-- If long enough, go back along X and prepare for new row if not wide enough
		elseif posX == width then
			-- Mine back along the length
			while posX > 1 do
				tryForward("-x")
				evalReturn()
			end
			-- If not wide enough, turn and prepare for next length
			if posZ < width then
				turnLeft()
				tryForward("z")
				turnLeft()
			end
		end
	end
	
	-- If finished, turn 
	--[[ -- ToDelete
	if layerFinished() then
		-- Set direction and move towards home along Z
		setDir(-1)
		while posZ > startZ do
			tryForward("-z")
			-- evalReturn() -- ToDelete - Already returning home
		end
		
		-- Set direction and move towards home along X
		setDir(-2)
		while posX > startX do
			tryForward("-x")
			-- evalReturn() -- ToDelete - Already returning home
		end
	end
	]]--
	if posY == height then
		returnHome("finished")
	else
		returnHome("layer")
	end
end

-- Run
layer()
while posY < height and not finished do
	maxX = 0
	maxY = 0
	maxZ = 0

	tryUp()
	layer()
end