-- CC_LiquidsTurtle

-- ***** Settings *****
controllerComputerLabel = "XnetLiquidsController"
tankPrefix = "XnetLiquidsEmpty" -- Changing to XnetLiquidsTank
turtleLabel = "XnetLiquidsTurtle"

rednet.open("right")
os.loadAPI("xnet/api/msg")
os.loadAPI("xnet/api/turtlemv")

-- temp
msg.debug()

shell.run("label set "..turtleLabel)

location = {}
  location[1] = {0,0}
  location[2] = {0,2}
  location[3] = {0,4}
  location[4] = {1,1}
  location[5] = {1,3}
  location[6] = {2,0}
  location[7] = {2,2}
  location[8] = {2,4}
  location[9] = {3,1}

function fillTank(tank, material) -- tank number (string), material number (string)
  tank = tonumber(tank) -- String to Number
  material = tonumber(material) -- String to Number
  if turtle.getItemCount(tank) < 1 then
    removeTank(tank)
  end

  turtlemv.gotoCoords(location[material][1], location[material][2])

  turtle.select(tank)
  while turtle.placeUp() == false do
    msg.echo(msg.getMsgLvl("debug"), "Can't place, digging..")
    turtle.digUp()
  end
    msg.echo(msg.getMsgLvl("debug"), "Tank placed successfully!")

  turtlemv.gotoCoords(0,0)
  while turtle.getItemCount(16) < 64 do
    msg.echo(msg.getMsgLvl("debug"), "Getting more fuel")
    turtle.select(16)
    turtlemv.setDir(2)
    turtle.drop()
    turtle.suck()
    turtle.select(12)
  end
  turtlemv.setDir(0)
  rednet.broadcast(controllerComputerLabel.." turtleresponse")
end

function removeTank(tank)
  for n=1,9 do
    turtle.select(12)
    turtlemv.gotoCoords(location[n][1], location[n][2])
    turtle.select(n)
    turtle.digUp()
  end
  turtle.select(12)
  turtlemv.gotoCoords(0,0)
  while turtle.getItemCount(16) < 64 do
    msg.echo(msg.getMsgLvl("debug"), "Getting more fuel")
    turtle.select(16)
    turtlemv.setDir(2)
    turtle.drop()
    turtle.suck()
    turtle.select(12)
  end
  turtlemv.setDir(0)
  rednet.broadcast(controllerComputerLabel.." turtleresponse")
end

while true do
  msg.echo(msg.getMsgLvl("debug"), "In while true loop")

  msgArr = msg.getMsgArray(os.getComputerLabel())
  msgCmd = msgArr[2]
  acceptedCommands = "add remove"
  if string.find(acceptedCommands, msgCmd) then
    if       msgCmd == "add"   then
      fillTank(msgArr[3], msgArr[4])
    elseif   msgCmd == "remove" then
      removeTank(msgArr[3])
    end
  end
end