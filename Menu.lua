-- *************************************************************** --
-- **                                                           ** --
-- **    Minecraft ComputerCraft GUI Menu v0.0.1 by Dentsor     ** --
-- **    -----------------------------------------------        ** --
-- **                                                           ** --
-- **    This program gives the user a graphical menu to use    ** --
-- **                                                           ** --
-- **    Change Log:                                            ** --
-- **       8th Apr 2014: [v0.0.1] Initial start on project     ** --
-- **                                                           ** --
-- *************************************************************** --


-- *************************************************************** --
-- **    Todo List:                                             ** --
-- **       - Mouse integration (if possible)                   ** --
-- *************************************************************** --

local keys = { ESC=1, ONE=2, TWO=3, THREE=4, FOUR=5, FIVE=6, SIX=7, SEVEN=8, EIGHT=9, NINE=10, ZERO=11, NULL=11, MINUS=12, EQUALS=13, EQUAL=13, BACKSPACE=14, BACK=14, TAB=15, Q=16, W=17, E=18, R=19, T=20, Y=21, U=22, I=23, O=24, P=25, BRACKETLEFT=26, BRACKETRIGHT=27, ENTER=28, NUMENTER=28, CONTROLLEFT=29, CTRLLEFT=29, A=30, S=31, D=32, F=33, G=34, H=35, J=36, K=37, L=38, SEMICOLON=39, APOSTROPHE=40, PARAGRAPH=41, SHIFTLEFT=42, BACKSLASH=43, Z=44, X=45, C=46, V=47, B=48, N=49, M=50, COMMA=51, FULLSTOP=52, PERIOD=52, FORWARDSLASH=53, SLASH=53, SHIFTRIGHT=54, NUMSTAR=55, ALTLEFT=56, SPACE=57, SPACEBAR=57, CAPS=58, CAPSLOCK=58, F1=59, F2=60, F3=61, F4=62, F5=63, F6=64, F7=65, F8=66, F9=67, F10=68, NUMLOCK=69,SCROLLOCK=70, SCROLLOCK=70, NUM7=71, NUM8=72, NUM9=73, NUMMINUS=74, NUM4=75, NUM5=76, NUM6=77, NUMPLUS=78, NUM1=79, NUM2=80, NUM3=81, NUM0=82, NUMCOMMA=83, F11=87, F12=88, CONTROLRIGHT=157, CTRLRIGHT=157, NUMSLASH=181, PRINTSCREEN=183, PRNTSCRN=183, ALTRIGHT=184, PAUSE=197, BREAK=197, PAUSEBREAK=197, HOME=199, UP=200, PGUP=201, PAGEUP=201, LEFT=203, RIGHT=205, END=207, DOWN=208, PGDOWN=209, PAGEDOWN=209, INSERT=210, INS=210, DELETE=211, DEL=211, WINLEFT=219, WINRIGHT=220, MENU=221, RMB=221 }

msglvl = { DEBUG=0, INFO=1, WARNING=2, ERROR=3, FATAL=4 }
menuItems = { "Burrow", "Clear", "Jaffa", "OQuarry" }
programs  = { "burrow", "cleararea", "jaffa", "OreQuarry" }

local loopkey = true
local posMenu = 1
local messageLevel = msglvl.INFO

local args = { ... }

local function writeMsg(msg, lvl)
	if lvl >= messageLevel then
		if messageLevel == msglvl.DEBUG then
			term.write("["..string.upper(lvl).."] - ")
		end
		print(msg)
	end
end

local function clearScreen()
	shell.run("clear")
end

local function screenEmpty()
	clearScreen()
	print("***************************************************")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("***************************************************")
end

local function screenAll()
	clearScreen()
	print("***************************************************")
	print("**         ________            _________         **")
	print("**        | Burrow |          |  Clear  |        **")
	print("**        |________|          |_________|        **")
	print("**                                               **")
	print("**         ________            _________         **")
	print("**        | Jaffa  |          | OQuarry |        **")
	print("**        |________|          |_________|        **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("***************************************************")
end

-- 0
local function screenTopLeft()
	clearScreen()
	print("***************************************************")
	print("**         ________                              **")
	print("**        | Burrow |             Clear           **")
	print("**        |________|                             **")
	print("**                                               **")
	print("**                                               **")
	print("**          Jaffa               OQuarry          **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("***************************************************")
end

-- 1
local function screenTopRight()
	clearScreen()
	print("***************************************************")
	print("**                             _________         **")
	print("**          Burrow            |  Clear  |        **")
	print("**                            |_________|        **")
	print("**                                               **")
	print("**                                               **")
	print("**          Jaffa               OQuarry          **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("***************************************************")
end

-- 2
local function screenBottomLeft()
	clearScreen()
	print("***************************************************")
	print("**                                               **")
	print("**          Burrow               Clear           **")
	print("**                                               **")
	print("**                                               **")
	print("**         ________                              **")
	print("**        | Jaffa  |            OQuarry          **")
	print("**        |________|                             **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("***************************************************")
end

-- 4
local function screenBottomRight()
	clearScreen()
	print("***************************************************")
	print("**                                               **")
	print("**          Burrow               Clear           **")
	print("**                                               **")
	print("**                                               **")
	print("**                             _________         **")
	print("**          Jaffa             | OQuarry |        **")
	print("**                            |_________|        **")
	print("**                                               **")
	print("**                                               **")
	print("**                                               **")
	print("***************************************************")
end

local function updateScreen()
	clearScreen()
	
	if posMenu == 1 then
		screenTopLeft()
	elseif posMenu == 2 then
		screenTopRight()
	elseif posMenu == 3 then
		screenBottomLeft()
	elseif posMenu == 4 then
		screenBottomRight()
	end
end

while loopkey do
	updateScreen()
	
	local sEvent, param = os.pullEvent("key")
	if sEvent == "key" then
		if param == keys.DOWN then
			posMenu = posMenu + 2
		elseif param == keys.UP then
			posMenu = posMenu - 2
		elseif param == keys.RIGHT then
			posMenu = posMenu + 1
		elseif param == keys.LEFT then
			posMenu = posMenu - 1
		elseif param == keys.ENTER then
			loopkey=false
			
			if posMenu >= 1 and posMenu <= 4 then
				shell.run(programs[posMenu])
			else
				writeMsg("Cursor position not valid!", msglvl.FATAL)
				writeMsg("Cursor pos: "..posMenu, msglvl.DEBUG)
			end
		end
	end
end