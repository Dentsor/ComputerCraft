-- CC_SetupLiquids

-- Settings
pathXnet = "/xnet/"
pathApi = pathXnet.."api/"

pathApiMsg = pathApi.."msg"
pathApiButton = pathApi.."button"
pathApiTurtleMV = pathApi.."turtlemv"
pathController = pathXnet.."run"
pathTank = pathXnet.."run"
pathTurtle = pathXnet.."run"
pathStartup = "/startup"

pastebinCodeApiMsg = "XWs4tnft"
pastebinCodeApiButton = "Xs06L7QP"
pastebinCodeApiTurtleMV = "NtaLPLr7"
pastebinCodeController = "EfDbqT1d"
pastebinCodeTank = "CyT8bzcS"
pastebinCodeTurtle = "GC9dgCGe"
pastebinCodeStartup = "8PqQh5XT"

labelTankPrefix = "XnetLiquidsEmpty"
sleepTime = 3
menuitem = 0

local keys = { ESC=1, ONE=2, TWO=3, THREE=4, FOUR=5, FIVE=6, SIX=7, SEVEN=8, EIGHT=9, NINE=10, ZERO=11, NULL=11, MINUS=12, EQUALS=13, EQUAL=13, BACKSPACE=14, BACK=14, TAB=15, Q=16, W=17, E=18, R=19, T=20, Y=21, U=22, I=23, O=24, P=25, BRACKETLEFT=26, BRACKETRIGHT=27, ENTER=28, NUMENTER=28, CONTROLLEFT=29, CTRLLEFT=29, A=30, S=31, D=32, F=33, G=34, H=35, J=36, K=37, L=38, SEMICOLON=39, APOSTROPHE=40, PARAGRAPH=41, SHIFTLEFT=42, BACKSLASH=43, Z=44, X=45, C=46, V=47, B=48, N=49, M=50, COMMA=51, FULLSTOP=52, PERIOD=52, FORWARDSLASH=53, SLASH=53, SHIFTRIGHT=54, NUMSTAR=55, ALTLEFT=56, SPACE=57, SPACEBAR=57, CAPS=58, CAPSLOCK=58, F1=59, F2=60, F3=61, F4=62, F5=63, F6=64, F7=65, F8=66, F9=67, F10=68, NUMLOCK=69,SCROLLOCK=70, SCROLLOCK=70, NUM7=71, NUM8=72, NUM9=73, NUMMINUS=74, NUM4=75, NUM5=76, NUM6=77, NUMPLUS=78, NUM1=79, NUM2=80, NUM3=81, NUM0=82, NUMCOMMA=83, F11=87, F12=88, CONTROLRIGHT=157, CTRLRIGHT=157, NUMSLASH=181, PRINTSCREEN=183, PRNTSCRN=183, ALTRIGHT=184, PAUSE=197, BREAK=197, PAUSEBREAK=197, HOME=199, UP=200, PGUP=201, PAGEUP=201, LEFT=203, RIGHT=205, END=207, DOWN=208, PGDOWN=209, PAGEDOWN=209, INSERT=210, INS=210, DELETE=211, DEL=211, WINLEFT=219, WINRIGHT=220, MENU=221, RMB=221 }


if fs.exists(pathXnet) then
  fs.delete(pathXnet)
end
if fs.exists(pathStartup) then
  fs.delete(pathStartup)
end
fs.makeDir(pathApi)

print("Now downloading 'msg API' by Xnet..")
shell.run("pastebin get "..pastebinCodeApiMsg.." "..pathApiMsg)

if fs.exists(pathApiMsg) then
  os.loadAPI(pathApiMsg)
else
  print("'msg Api' not found.. please restart computer..")
  return
end

function menu()
  term.clear()
  term.setCursorPos(1,1)
  msg.printCenter("Choose your menuitems")
  print()
  print()
  if menuitem == 0 then msg.printCenter(">>> Install Controller <<<") else msg.printCenter("Install Controller") end
  if menuitem == 1 then msg.printCenter(">>> Install Tank Computer <<<") else msg.printCenter("Install Tank Computer") end
  if menuitem == 2 then msg.printCenter(">>> Install Turtle <<<") else msg.printCenter("Install Turtle") end
  if menuitem == 3 then msg.printCenter(">>> Reboot <<<") else msg.printCenter("Reboot") end
  if menuitem == 4 then msg.printCenter(">>> Exit <<<") else msg.printCenter("Exit") end
end

function installUniversals()
  shell.run("pastebin get "..pastebinCodeStartup.." "..pathStartup)
  shell.run("pastebin get "..pastebinCodeApiButton.." "..pathApiButton)
  shell.run("pastebin get "..pastebinCodeApiTurtleMV.." "..pathApiTurtleMV)
end

function installController()
  shell.run("pastebin get "..pastebinCodeController.." "..pathController)
  installUniversals()
end

function installTank()
  shell.run("pastebin get "..pastebinCodeTank.." "..pathTank)
  installUniversals()
  print("Now setting computer label. Please provide a suffix:")
  suffix = read()
  shell.run("label set "..labelTankPrefix..suffix)
  sleep(sleepTime)
end

function installTurtle()
  shell.run("pastebin get "..pastebinCodeTurtle.." "..pathTurtle)
  installUniversals()
end

sleep(sleepTime)
menu()

while true do
  menu()
  local sEvent, param = os.pullEvent("key")
  if sEvent == "key" then
    if param == keys.DOWN and menuitem < 4 then
      menuitem = menuitem +1
    elseif param == keys.UP and menuitem > 0 then
      menuitem = menuitem -1
    elseif param == keys.ENTER then
      if menuitem == 0 then
        installController()
      elseif menuitem == 1 then
        installTank()
      elseif menuitem == 2 then
        installTurtle()
      elseif menuitem == 3 then
        os.reboot()
      elseif menuitem == 4 then
      	term.clear()
      	term.setCursorPos(1,1)
      	return
      end
    end
  end
end