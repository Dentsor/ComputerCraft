-- ****************************************************************** --
-- **                                                              ** --
-- **    Flann Packaging Tool (fpt) v0.0.5 by Dentsor              ** --
-- **    ---------------------------------------------             ** --
-- **                                                              ** --
-- **    Simplifies installation and updating of certain scripts   ** --
-- **                                                              ** --
-- **    Change Log:                                               ** --
-- **      10th Apr 2020: [v0.0.5] Redoing for GitHub              ** --
-- **      09th Apr 2020: [v0.0.4] Added additional programs       ** --
-- **      21th Aug 2019: [v0.0.3] Added confirmation to upgrades  ** --
-- **      20th Aug 2019: [v0.0.2] Added Upgrade command           ** --
-- **      20th Aug 2019: [v0.0.1] Initial Release                 ** --
-- **                                                              ** --
-- ****************************************************************** --

local thisName = "FlannPackagingTool"
local tmpfile = "fpt_tempfile"

-- URL Table for installable programs
local progs = {
	ClearArea = {"ca", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/ClearArea.lua"},
	Burrow = {"burrow", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/Burrow.lua"},
	Attack = {"attack", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/Attack.lua"},
	OreQuarry = {"quarry", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/OreQuarry.lua"},
	GuiMenu = {"gui_menu", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/Menu.lua"},
	FlannPackagingTool = {"fpt", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/FlannPackagingTool.lua"},
	ApiButton = {"apiButton", "https://raw.githubusercontent.com/Dentsor/ComputerCraft/master/ApiButton.lua"}
	}

local keys = { ESC=1, ONE=2, TWO=3, THREE=4, FOUR=5, FIVE=6, SIX=7, SEVEN=8, EIGHT=9, NINE=10, ZERO=11, NULL=11, MINUS=12, EQUALS=13, EQUAL=13, BACKSPACE=14, BACK=14, TAB=15, Q=16, W=17, E=18, R=19, T=20, Y=21, U=22, I=23, O=24, P=25, BRACKETLEFT=26, BRACKETRIGHT=27, ENTER=28, NUMENTER=28, CONTROLLEFT=29, CTRLLEFT=29, A=30, S=31, D=32, F=33, G=34, H=35, J=36, K=37, L=38, SEMICOLON=39, APOSTROPHE=40, PARAGRAPH=41, SHIFTLEFT=42, BACKSLASH=43, Z=44, X=45, C=46, V=47, B=48, N=49, M=50, COMMA=51, FULLSTOP=52, PERIOD=52, FORWARDSLASH=53, SLASH=53, SHIFTRIGHT=54, NUMSTAR=55, ALTLEFT=56, SPACE=57, SPACEBAR=57, CAPS=58, CAPSLOCK=58, F1=59, F2=60, F3=61, F4=62, F5=63, F6=64, F7=65, F8=66, F9=67, F10=68, NUMLOCK=69,SCROLLOCK=70, SCROLLOCK=70, NUM7=71, NUM8=72, NUM9=73, NUMMINUS=74, NUM4=75, NUM5=76, NUM6=77, NUMPLUS=78, NUM1=79, NUM2=80, NUM3=81, NUM0=82, NUMCOMMA=83, F11=87, F12=88, CONTROLRIGHT=157, CTRLRIGHT=157, NUMSLASH=181, PRINTSCREEN=183, PRNTSCRN=183, ALTRIGHT=184, PAUSE=197, BREAK=197, PAUSEBREAK=197, HOME=199, UP=200, PGUP=201, PAGEUP=201, LEFT=203, RIGHT=205, END=207, DOWN=208, PGDOWN=209, PAGEDOWN=209, INSERT=210, INS=210, DELETE=211, DEL=211, WINLEFT=219, WINRIGHT=220, MENU=221, RMB=221 }

-- Retrieve arguments
local args = { ... }

-- Print help information
local function printHelp()
	shell.run("clear")
	print("Usage: (abbreviation/command)")
	print(" * fpt upd/update")
	print(" * fpt ls/list")
	print(" * fpt i/install <scriptname>")
	print(" * fpt rm/remove <scriptname>")
	print(" * fpt upg/upgrade")
end

-- Check if table contains value
local function hasValue (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Count elements in array/table
local function countArr(tab)
	Count = 0
	for Index, Value in pairs( tab ) do
		Count = Count + 1
	end
	return Count
end

-- Wait for user to press a key specified in array
local function playerProceed(str, keyArr)
	-- If str == nil, set default question-string
	if str == nil then
		str = "Continue? (Y/n)"
	
	-- If str == "", skip printing question
	elseif str == "" then
		str = nil
	end
	
	-- Array of positive keys (returning true when pressed)
	if keyArr == nil then
		keyArr = {keys.Y}
	end
	
	-- Print question, if defined
	if str ~= nil then
		print(str)
	end
	
	while true do
		local sEvent, param = os.pullEvent("key")
		if sEvent == "key" then
			if hasValue(keyArr, param) then
				return true
			else
				return false
			end
		end
	end
end

local function downloadFile(filename, source)
	shell.run("wget "..source.." "..filename)

	if fs.exists(filename) then
		return true
	else
		return false
	end
end

local function installFile(filename, source, programname, update)
	if programname ~= nil and update ~= nil and update == 1 then
		print("Updating "..programname)
	elseif programname ~= nil then
		print("Installing "..programname.." as "..filename)
	else
		print("Installing '"..filename.."'")
	end
	
	if downloadFile(tmpfile, source) then
		if fs.exists(filename) then
			print("Deleting old file '"..filename.."'")
			shell.run("rm "..filename)
		end
		shell.run("mv "..tmpfile.." "..filename)
		if fs.exists(filename) then
			print("Finished installation of "..programname.." as '"..filename.."'")
		else
			print("Error occurred while finishing installation of "..programname.." as '"..filename.."'")
		end
	else
		print("Error occurred while downloading program..")
	end
end

local function installProg(programname, filename, update)
	if progs[programname] ~= nil then
		local file = progs[programname][1]
		if filename ~= nil then
			file = filename
		end
		local u = 0
		if update ~= nil then
			u = update
		end
		
		installFile(file, progs[programname][2], programname, u)
	else
		print("Error: Program '"..programname.."' not found!")
	end
end

if #args == 0 then
	printHelp()
elseif #args > 0 then
	-- Update the FPT-tool
	if args[1] == "upd" or args[1] == "update" then
		installProg(thisName, nil, 1)
		return
	
	-- List all available programs
	elseif args[1] == "ls" or args[1] == "list" then
		print("")
		for k, v in pairs(progs) do
			print(" * "..k)
		end
		return

	-- Install a program from the table at the start
	elseif args[1] == "i" or args[1] == "install" then
		if progs[args[2]] ~= nil then
			local filename = progs[args[2]][1]
			if args[3] ~= nil then
				filename = args[3]
			end
			installProg(args[2], filename)
			return
		else
			print("Program not found: "..args[2])
			print("Make sure to use the correct casing!")
			print("Use 'fpt list' to view available programs")
			return
		end

	-- Remove a program from the system
	elseif args[1] == "rm" or args[1] == "remove" then
		if args[2] ~= nil then
			local filename = ""
			if progs[args[2]] ~= nil then
				filename = progs[args[2]][1]
				print("Removing program "..args[2].." with filename '"..filename.."'")
			else
				filename = args[2]
				print("Removing program with filename '"..filename.."'")
			end
			
			shell.run("rm "..filename)
			return
		end
	
	-- Check if programs in list is installed and upgrades them
	elseif args[1] == "upg" or args[1] == "upgrade" then
		if args[2] ~= nil then
			print("If you want to upgrade a specific script, just rerun the install script.")
			return
		else
			local arr = {}
			for k, v in pairs(progs) do
				if fs.exists(v[1]) then
					arr[k] = v
				end
			end
			if countArr(arr) > 0 then
				print("The following programs will be upgraded:")
				for k, v in pairs(arr) do
					print(" * "..k.." as file '"..v[1].."'")
				end

				if playerProceed() then
					for k, v in pairs(arr) do
						installProg(k, v[1], 1)
					end
				end
			else
				print("No upgradable programs found..")
			end
			return
		end
	end
	
	-- Script should return before here, else help should be provided.
	printHelp()
end

