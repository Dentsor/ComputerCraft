-- CC_Comp_Liquids

-- ***** TODO *****
-- 1: Save Contents in array, so you don't have to always remove all endertanks when emptying one tank

-- ***** Settings *****
msgLvl = 0
monitorSide = "right"
rednetSide = "left"
controllerComputerLabel = "XnetLiquidsController"
tankPrefix = "XnetLiquidsEmpty" -- Changing to XnetLiquidsTank
turtleLabel = "XnetLiquidsTurtle"

-- Loads APIs
os.loadAPI("xnet/api/button")
os.loadAPI("xnet/api/msg")

-- temp
--msg.debug()

shell.run("label set "..controllerComputerLabel)

mon = peripheral.wrap(monitorSide)
mon.clear()

rednet.open(rednetSide)

button.setColors(colors.blue, colors.green, colors.lime)

openTank = nil

liquids = {}
  liquids[1] = "Aluminum"
  liquids[2] = "Tin"
  liquids[3] = "Copper"
  liquids[4] = "Alu. Brass"
  liquids[5] = "Bronze"
  liquids[6] = "Cobalt"
  liquids[7] = "Ardite"
  liquids[8] = "Gold"
  liquids[9] = "Manyullyn"

tankState = {}
  tankState[1] = "Empty"
  tankState[2] = "Empty"
  tankState[3] = "Empty"
  tankState[4] = "Empty"
  tankState[5] = "Empty"
  tankState[6] = "Empty"
  tankState[7] = "Empty"

tankName = {}
  tankName[1] = "Tank 1"
  tankName[2] = "Tank 2"
  tankName[3] = "Tank 3"
  tankName[4] = "Tank 4"
  tankName[5] = "Tank 5"
  tankName[6] = "Tank 6"
  tankName[7] = "Tank 7"

function refreshValues()
  command = "status"
  rednet.broadcast(tankPrefix.."All "..command) -- return format: "XnetLiquidCentral statusResponse %tank %val"
  cont = 0
  repeat
    msgArray = msg.getMsgArray(controllerComputerLabel)
    if string.lower(msgArray[2]) == "statusresponse" then
      tank = tonumber(msgArray[3])
      value = msgArray[4]
      acceptedValues = "empty content"
      if string.find(acceptedValues, value) then
        tankState[tank] = value
        cont = cont +1
      else
        msg.echo(msg.getMsgLvl("debug"), tank.." & "..value.." are not accepted arguments..")
      end
    end
  until cont >= 7
  msg.echo(msg.getMsgLvl("debug"), "refreshValues: Left repeat loop")
  return tankState
end

function getState(tank)
  if tankState[tank] == "empty" then
    return 1
  elseif tankState[tank] == "content" then
    return 2
  else
    return 0
  end
end

function fillMenu(state)
  if state == "fillTable" then
    button.setTable("Empty all", emptyTank, "all", 2,12,19,20)
  elseif state == "fillTable2" then
    button.setTable("Empty", emptyTank, openTank, 2,12,19,20)
  end
  if state == "fillTable" then
    button.setTable("Refresh", refresh, "", 14,24,19,20)
  end
  button.setTable("Reboot", reboot, "", 26,36,19,20)

  if state == "fillTable2" then
    button.setTable("Back", fillTable, "", 38,48,19,20)
  end
end

function fillTable()
  mon.clear()
  button.clearTable()

  button.heading("Regulate Taks")

  button.setTable("Tank 1", regulateTank, "1",  2, 12, 3, 8)
  button.setTable("Tank 2", regulateTank, "2", 14, 24, 3, 8)
  button.setTable("Tank 3", regulateTank, "3", 26, 36, 3, 8)
  button.setTable("Tank 4", regulateTank, "4", 38, 48, 3, 8)

  button.setTable("Tank 5", regulateTank, "5",  2, 12, 12, 17)
  button.setTable("Tank 6", regulateTank, "6", 14, 24, 12, 17)
  button.setTable("Tank 7", regulateTank, "7", 26, 36, 12, 17)

  fillMenu("fillTable")

  for i=1,7 do
    button.setButtonState(tankName[i], getState(i))
  end

  button.screen()
end

function fillTable2()
  mon.clear()
  button.clearTable()

  button.heading("Regulating Tank #"..openTank)

  button.setTable(liquids[1], fillTank, "1",  2, 12, 3, 8)
  button.setTable(liquids[2], fillTank, "2", 14, 24, 3, 8)
  button.setTable(liquids[3], fillTank, "3", 26, 36, 3, 8)
  button.setTable(liquids[4], fillTank, "4", 38, 48, 3, 8)

  button.setTable(liquids[5], fillTank, "5",  2, 12, 12, 17)
  button.setTable(liquids[6], fillTank, "6", 14, 24, 12, 17)
  button.setTable(liquids[7], fillTank, "7", 26, 36, 12, 17)
  button.setTable(liquids[8], fillTank, "8", 38, 48, 12, 17)

  for i=1,8 do
    button.setButtonState(liquids[i], 1)
  end

  fillMenu("fillTable2")

  button.screen()
end

function getClick()
  event,side,x,y = os.pullEvent("monitor_touch")
  button.checkxy(x,y)
end

function regulateTank(tank)
  openTank = tank
  print("Opening GUI for: Tank "..openTank)
  fillTable2()
end

function fillTank(material)
  button.flash(liquids[tonumber(material)])
  tank = openTank
--  emptyTank(tank)
  rednet.broadcast(turtleLabel.." add "..tank.." "..material)
  cont = 0
  repeat
    msgArr = msg.getMsgArray(controllerComputerLabel)
    if msgArr[2] == "turtleresponse" then
      cont = 1
    end
  until cont > 0
  sleep(1)
  refreshValues()
  sleep(1)
  fillTable()
end

function reboot()
  button.toggleButton("Reboot")
  print("Rebooting..")
  sleep(3)
  os.reboot()
end

function refresh()
  button.toggleButton("Refresh")
  refreshValues()
  button.toggleButton("Refresh")
  sleep(3)
  fillTable()
end

function emptyTank(tank)
  if tank == "all" then
--    button.toggleButton("Empty all")
    button.setButtonState("Empty all", 2)
  else
--    button.toggleButton("Empty")
    button.setButtonState("Empty", 2)
  end
  command = "empty"

  rednet.broadcast(turtleLabel.." remove all") -- format: receiver command argument(s)

  cont = 0
  repeat
    msgArr = msg.getMsgArray(controllerComputerLabel)
    if string.lower(msgArr[2]) == "turtleresponse" then
      cont = 1
    end
  until cont > 0

  if tank == "all" then
    -- Deprecated
    --rednet.broadcast(tankPrefix.."One "..command)
    --rednet.broadcast(tankPrefix.."Two "..command)
    --rednet.broadcast(tankPrefix.."Three "..command)
    --rednet.broadcast(tankPrefix.."Four "..command)
    --rednet.broadcast(tankPrefix.."Five "..command)
    --rednet.broadcast(tankPrefix.."Six "..command)
    --rednet.broadcast(tankPrefix.."Seven "..command)
 
    -- New lines for same as above
    rednet.broadcast(tankPrefix.."All "..command)
  elseif tank == "1" then
    rednet.broadcast(tankPrefix.."One "..command)
  elseif tank == "2" then
    rednet.broadcast(tankPrefix.."Two "..command)
  elseif tank == "3" then
    rednet.broadcast(tankPrefix.."Three "..command)
  elseif tank == "4" then
    rednet.broadcast(tankPrefix.."Four "..command)
  elseif tank == "5" then
    rednet.broadcast(tankPrefix.."Five "..command)
  elseif tank == "6" then
    rednet.broadcast(tankPrefix.."Six "..command)
  elseif tank == "7" then
    rednet.broadcast(tankPrefix.."Seven "..command)
  end
--  sleep(1) --15
--  refreshValues()
--  if tank == "all" then
--    button.toggleButton("Empty all")
--  else
--    button.toggleButton("Empty")
--  end
  if tank == "all" then
--    button.toggleButton("Empty all")
    button.setButtonState("Empty all", 0)
  else
--    button.toggleButton("Empty")
    button.setButtonState("Empty", 0)
  end
end

msg.echo(msg.getMsgLvl("notice"), "Controller starting...")
refreshValues()
sleep(3)
fillTable()

while true do
  getClick()
end