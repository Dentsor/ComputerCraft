-- CC_ApiTurtleMovement
-- xnet/api/turtlemv

posX = 0
posY = 0
posZ = 0
posD = 0

collectedOre = 0
collectedMob = 0

function screen()
	--print("Running..")
	--shell.run("clear")
	term.clear()
	term.setCursorPos(1,1)
	print("Running..")
	print("Fuellevel: "..turtle.getFuelLevel())
end

function collectMine()
	collectedOre = collectedOre + 1
	screen()
end

function collectAttack()
	collectedMob = collectedMob + 1
	screen()
end

function getPosX()
	return posX
end

function getPosY()
	return posY
end

function getPosZ()
	return posZ
end

function tryDig()
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

function tryDigUp()
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

function tryDigDown()
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

function refuel()
	fuelLevel = turtle.getFuelLevel()
	if fuelLevel == "unlimited" or fuelLevel > 0 then
		return
	end
	
	function tryRefuel()
		for n=16,16 do
			if turtle.getItemCount(n) > 0 then
				turtle.select(n)
				if turtle.refuel(1) then
					turtle.select(1)
					return true
				end
			end
		end
		turtle.select(1)
		return false
	end
	
	if not tryRefuel() then
		print( "Add more fuel to continue." )
		while not tryRefuel() do
			sleep(1)
		end
		print( "Resuming "..programName )
	end
end

function changeToX()
	posX = posX +1
	--if posX > maxX then
	--	maxX = posX
	--end
end

function changeToY()
	posY = posY +1
	--if posY > maxY then
	--	maxY = posY
	--end
end

function changeToZ()
	posZ = posZ +1
	--if posZ > maxZ then
	--	maxZ = posZ
	--end
end

function changeFromX()
	posX = posX -1
end

function changeFromY()
	posY = posY -1
end

function changeFromZ()
	posZ = posZ -1
end

function changeXYZ(direction)
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

function tryUp()
	refuel()
	while not turtle.up() do
		if turtle.detectUp() then
			if not tryDigUp() then
				return false
			end
		elseif turtle.attackUp() then
			collectAttack()
		else
			sleep( 0.5 )
		end
	end
	changeXYZ("-y")
	screen()
	return true
end

function tryDown()
	refuel()
	while not turtle.down() do
		if turtle.detectDown() then
			if not tryDigDown() then
				return false
			end
		elseif turtle.attackDown() then
			collectAttack()
		else
			sleep( 0.5 )
		end
	end
	changeXYZ("y")
	screen()
	return true
end

function tryForward(dir)
	refuel()
	while not turtle.forward() do
		if turtle.detect() then
			if not tryDig() then
				return false
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

function turnLeft()
	if turtle.turnLeft() then
		posD = posD - 1
	end
	screen()
end

function turnRight()
	if turtle.turnRight() then
		posD = posD + 1
	end
	screen()
end

function setDir(dir)
	while posD > dir do
		turnLeft()
	end
	while posD < dir do
		turnRight()
	end
end

function gotoCoords(xCoord, yCoord)
  if posX < xCoord then
    setDir(0)
    while posX < xCoord do
      tryForward("x")
    end
  elseif posX > xCoord then
    setDir(2)
    while posX > xCoord do
      tryForward("-x")
    end
  end

  if posZ < yCoord then
    setDir(1)
    while posZ < yCoord do
      tryForward("z")
    end
  elseif posZ > yCoord then
    setDir(-1)
    while posZ > yCoord do
      tryForward("-z")
    end
  end
end