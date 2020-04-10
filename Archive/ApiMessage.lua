-- CC_ApiMsg
-- xnet/api/msg
 
-- This determines the importance of the message
msgLvl = { DEBUG=0, INFO=1, WARNING=2, ERROR=3, FATAL=4 }
 
-- Message Output Level
msgOutLvl = msgLvl.INFO
 
-- Sets message output level based on String input
function setMsgLvl(lvl)
   lvl = string.lower(lvl)
   if     lvl == "debug"   then msgOutLvl = msgLvl.DEBUG
   elseif lvl == "info"    then msgOutLvl = msgLvl.INFO
   elseif lvl == "warning" then msgOutLvl = msgLvl.WARNING
   elseif lvl == "error"   then msgOutLvl = msgLvl.ERROR
   elseif lvl == "fatal"   then msgOutLvl = msgLvl.FATAL
   else                         msgOutLvl = msgLvl.INFO
   end
end

function debug()
  setMsgLvl("debug")
end

function getMsgLvl(lvl)
   lvl = string.lower(lvl)
   if     lvl == "debug"   then return msgLvl.DEBUG
   elseif lvl == "info"    then return msgLvl.INFO
   elseif lvl == "warning" then return msgLvl.WARNING
   elseif lvl == "error"   then return msgLvl.ERROR
   elseif lvl == "fatal"   then return msgLvl.FATAL
   else                         return msgLvl.INFO
   end
end
 
function echo(lvl, msg)
  if msgOutLvl <= lvl then
    print(msg)
  end
end
 
function split(array, devider)
  arr = {}
  j = 1
  for i in string.gmatch(array, "%S+") do
    arr[j] = i
    echo(msgLvl.DEBUG, "split: "..j.." "..i)
    j = j+1
  end
  return arr
end
 
function getMsg(requirement)
  echo(msgLvl.DEBUG, "Entered getMsg()")
  cont = 0
  msg = ""
 
  reqArray = split(string.lower(requirement), " ")
  if reqArray[1] == "&" then
    requirement = "& array"
  end
 
  repeat
    echo(msgLvl.DEBUG, "getMsg: Entered repeat loop")
    a,b,c = rednet.receive()
    msg = string.lower(b)
    echo(msgLvl.DEBUG, "getMsg: "..msg)
    if requirement == nil then
      cont = 1
    elseif requirement == "& array" then
      if string.find(msg, reqArray[2]) then
        cont = 1
      elseif string.find(msg, reqArray[3]) then
        cont = 1
      else
        echo(msgLvl.DEBUG, msg.."does not contain "..reqArray[2].." or "..reqArray[3])
      end
    elseif string.find(msg, string.lower(requirement)) then
      cont = 1
    end
  until cont > 0
  return msg
end

function getMsgArray(requirement)
  msg = getMsg(requirement)
  echo(msgLvl.DEBUG, "getMsgArray: "..msg)
  msgArr = split(msg, " ")
  return msgArr
end
 
function getMsgCmd(requirement)
  msgArr = getMsgArray(requirement)
  echo(msgLvl.DEBUG, "getMsgCmd: "..msgArr[1].." "..msgArr[2])
  return msgArr[2]
end

function printCenter(msg)
  msgLen = string.len(msg)
  screenWidth,_ = term.getSize()
  xCoords = tonumber(math.ceil((screenWidth / 2) - (msgLen / 2)))
  _,termY = term.getCursorPos()
  term.setCursorPos(xCoords,termY)
  print(msg)
  _,termY = term.getCursorPos()
  term.setCursorPos(1,termY)
  return xCoords
end