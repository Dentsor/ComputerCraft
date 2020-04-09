-- CC_CompEmpty
 
-- ***** Settings *****
rednetSide = "back"
refreshSideIn = "top"
emptySideOut = "front"
controllerComputerID = 5
controllerComputerLabel = "XnetLiquidsController"
emptyComputerLabelPrefix = "XnetLiquidsEmpty"
tankIDModifier = 14 -- First Turtle ID -1 (turtle #8 for tank 1: (turtle id #)8 - (tankIDModifier)7 = (tankID)1)
 
-- Open rednet connection
rednet.open(rednetSide)

os.loadAPI("xnet/api/msg")
msg.debug()
function emptyTank()
  redstone.setOutput(emptySideOut, true)
  cont = 0
  repeat
    if redstone.getInput(refreshSideIn) then
      cont = 1
    else
      sleep(2)
    end
  until cont > 0
  redstone.setOutput(emptySideOut, false)
--  rednet.send(controllerComputerID, "Emptied "..os.getComputerLabel())
end
 
function refresh()
  if redstone.getInput(refreshSideIn) then
    -- return format: "XnetLiquidCentral statusResponse %tank %val"
    rednet.send(controllerComputerID, controllerComputerLabel.." statusResponse "..(os.getComputerID() - tankIDModifier).." empty")
    msg.echo(msg.getMsgLvl("debug"), controllerComputerLabel.." statusResponse "..(os.getComputerID() - tankIDModifier).." empty")
  else
    rednet.send(controllerComputerID, controllerComputerLabel.." statusResponse "..(os.getComputerID() - tankIDModifier).." content")
    msg.echo(msg.getMsgLvl("debug"), controllerComputerLabel.." statusResponse "..(os.getComputerID() - tankIDModifier).." content")
  end
end
 
while true do
  msg.echo(msg.getMsgLvl("debug"), "In while true loop")
  
  msgArr = msg.getMsgArray("& "..os.getComputerLabel().." "..emptyComputerLabelPrefix.."All")
  msgCmd = msgArr[2]
  acceptedCommands = "empty status"
  if string.find(acceptedCommands, msgCmd) then
    msg.echo(msg.getMsgLvl("debug"), "Command: '"..msgCmd.."'")
    if       msgCmd == "empty"   then
      emptyTank()
    elseif   msgCmd == "status" then
      refresh()
    else
      msg.echo(msg.getMsgLvl("debug"), "No known commands found..")
    end
  else
    msg.echo(msg.getMsgLvl("debug"), "'"..msgCmd.."' not in 'acceptedCommands'")
  end
end