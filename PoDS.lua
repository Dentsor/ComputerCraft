-- Welcome to PoDS, the Power on Delivery System, developed by Dentsor and Popill in the Autumn of 2019

-- TODO
-- * Implement config-versioning
-- * Multi-threading on controller: Refresh screen every 10 seconds
-- * Drop messages on wrong channel/group more effectively?
-- * Add more commands to handlers
-- * - Add handlers to group from controller
-- * - Rename handlers from controller

-- ##################################################
-- # Local settings, you may change these variables #
-- ##################################################
local pods_config = {
	useExternalConfig = false, -- Change to true in order to use a config-file
	configFile = "pods.cfg", -- Config-file (only used if 'useExternalConfig' is true)
	tempFile = "pods.tmp", -- Temporary file used when necessary (like updates)
	tempStartupFile = "startup.tmp", -- Temporary startup-file while running update
	programFile = "podsbeta", -- The programs filepath
	side_rs_in = "back", -- Redstone input (handlers)
	side_rs_out = "back", -- Redstone output (controllers)
	task = nil, -- Task to perform => controller or handler
	group = 0, -- Group-ID to seperate multiple systems
	sleep = 10, -- Sleep timer for between operations (handlers: between sending updates)
	broadcast_channel = 73, -- PoDS broadcast channel
	threshold_upper = 14, -- Upper threshold, at which the system stops charging
	threshold_lower = 12, -- Lower threshold, at which the system starts charging
	label_default = "pods_noname%i", -- Default label of new Pods
}



-- #########################################
-- ## Programatic variables, don't change ##
-- #########################################
local debugging = true
local programVersion = "v1.1"
local programName = string.format("Power on Delivery System %s", programVersion)
local pods_static = {
	pastecode = "6nyy7ndU", -- Pastebin code for updates
	startupFile = "startup.lua",
	startupCommand = 'shell.run("%s %s %i")', -- pods <task> <group> / ie: pods handler
	tasks = {
		controller = "controller",
		handler = "handler",
	},
}
local pods_str = {
	updatePastebin = "pastebin get %s %s",
	updateCompleted = "Update completed!",
	updateInstallFailed = "Installation of update failed!",
	updateDownloadFailed = "Download of update failed!",
	modemMissing = "There's no modem installed!",
	monitorMissing = "Monitor not installed!",
	bootMessage = "%s booting as %s for group %i on ch. %i",
	controller_handlerUpdate = "Update from %s => %i/%i",
	controller_chargingStart = "Started charging as there are %i capacitors below the threshold",
	controller_chargingSuspended = "Suspended charging as there are %i capacitors below the threshold, and %i at max capacity",
	controller_chargingLimbo = "Current there are %i capacitors 'in limbo' (neither empty nor full)",
	controller_monitorState = "[%i] %s: %i",
	controller_monitorRunningProgram = "Running: %s",
	controller_monitor = {
		header_running = {
			x7 = programVersion, -- 7 char
			x18 = programVersion, -- 18 char
			default = programName, -- 14 char
		},
		title_handlersConnected = {
			x7 = "Han:%3d",
			x18 = "Handlers: %8d",
			default = "Handlers: %4d",
		},
		title_statePercentage = {
			x7 = "Cap:%3d",
			x18 = "Capacity: %8d",
			default = "Capacity: %3d%%",
		},
		title_stateChargingCount = {
			x7 = "Cha:%3d",
			x18 = "Charging: %8d",
			default = "Charging: %4d",
		},
		title_stateOutput = {
			x7 = "Out:%3s",
			x18 = "Output:   %8s",
			default = "Output:   %4s",
		},
		latestTitle = {
			default = "Latest:",
		},
		latestUpdate = {
			default = "[%3d] -> %3d%%",
		},
		alertTitle = {
			default = "Alerts:",
		},
		alertDuplicate = {
			x39 = "%d: DUPLICATE",
			x50 = "%d is duped in log",
			default = "ID %d seen %d times in log",
		},
		alertHandlerDisconnected = {
			x39 = "%d: OFFLINE",
			x50 = "%d may be offline",
			default = "ID %d not observed in a while, check connection",
		},
	},
	handler_commandsReceived = "Cmd from %i to %i: %s",
	jobUnspecified = "Job not specified!",
}
local pods_msgType = {
		handlerUpdate = "handlerUpdate",
	}
local pods_state = {} -- Controller: Table for containing the connected pods' state

local listFilling = {} -- Controller: Array containing the currently filling pods
local listLatest = {} -- Controller: Array of latest updates
local modem, monitor



-- #######################
-- ## General functions ##
-- #######################

-- Print help information
local function printHelp()
    print("Usage:")
    print(" pods <task> <group>")
end

-- Save text to file (will overwrite!)
local function saveFile(filename, text)
    local file = fs.open(filename, "w")
    file.write(text)
    file.close()
end
 
-- Read text from file
local function readFile(filename)
    local file = fs.open(filename, "r")
    local data = file.readAll()
    file.close()
    return data
end

-- Check if table contains value
local function hasValue (tab, val)
    for index, value in pairs(tab) do
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

-- Check if element exists, and returns position/index
local function hasPos(tab, val)
	for i,v in pairs(tab) do
		if v == val then
			return i
		end
	end
	return nil
end

-- Check for duplicates in table
function findDuplicates(tab)
    seen = {} --keep record of elements we've seen
    duplicated = {} --keep a record of duplicated elements
    for i = 1, #tab do
        element = tab[i]
        if seen[element] then  --check if we've seen the element before
            duplicated[element] = true --if we have then it must be a duplicate! add to a table to keep track of this
        else
            seen[element] = true -- set the element to seen
        end
    end
    return duplicated
end

-- Check for duplicates in table
function countDuplicates(tab)
    seen = {} --keep record of elements we've seen
    duplicated = {} --keep a record of duplicated elements
    for i = 1, #tab do
        element = tab[i]
        if seen[element] then  --check if we've seen the element before
            duplicated[element] = (duplicated[element] or 1) +1 --if we have then it must be a duplicate! add to a table to keep track of this
        else
            seen[element] = true -- set the element to seen
        end
    end
    return duplicated
end

-- Print textstring to attached monitor
local function mon_print(text, pos_x, pos_y)
	if monitor ~= nil then
		-- Retrieve current cursor position
		local cur_x,cur_y = monitor.getCursorPos()

		-- Set cursor position (if pos_x/y is provided, else use current)
		monitor.setCursorPos(pos_x or cur_x, pos_y or cur_y)

		-- Print text to screen
		monitor.write(text)
	end
end

-- Print textstring to attached monitor, then start a new line
local function mon_println(text, pos_x, pos_y)
	if monitor ~= nil then
		-- Print the text to screen, passing pos_x/y along incase they're provided
		mon_print(text, pos_x, pos_y)

		-- Retrieve current cursor position
		local cur_x,cur_y = monitor.getCursorPos()

		-- Go to new line (using pos_x if provided, else do carriage return aka. x = 1)
		monitor.setCursorPos(pos_x or 1, cur_y+1)
	end
end



-- ###################################
-- ## Retrieve and handle arguments ##
-- ###################################

-- Retrieve arguments
local args = { ... }

-- Handle arguments
if #args ~= 0 and args[1] ~=nil then
		-- Run script update
		if args[1] == "u" or args[1] == "update" then
			if fs.exists(pods_config.tempFile) then
			fs.delete(pods_config.tempFile)
		end
		shell.run(string.format(pods_str.updatePastebin, pods_static.pastecode, pods_config.tempFile))
		if fs.exists(pods_config.tempFile) then
			fs.delete(pods_config.programFile)
			fs.move(pods_config.tempFile, pods_config.programFile)
			if fs.exists(pods_config.programFile) then
				print(pods_str.updateCompleted)
			else
				print(pods_str.updateInstallFailed)
			end
		else
			print(pods_str.updateDownloadFailed)
		end
		if fs.exists(pods_config.tempStartupFile) then
			if fs.exists(pods_static.startupFile) then
				fs.delete(pods_static.startupFile)
			end
			fs.move(pods_config.tempStartupFile, pods_static.startupFile)
			os.reboot()
		end
		return
	end

	-- Loop through pods_static.tasks and find the one corresponding to the argument
	for i,v in pairs(pods_static.tasks) do
		if args[1] == v then
			pods_config.task = v
		end
	end

	-- If given retrieves group-number, otherwise standard value declared above is used
	if args[2] ~= nil and tonumber(args[2]) ~= nil then
		pods_config.group = tonumber(args[2])
	end
end

-- If a task has not been set, print the manual and suspend the script
if pods_config.task == nil then
	printHelp()
	return
end



-- ######################
-- ## Script functions ##
-- ######################

local function setStartup(update)
	saveFile(pods_static.startupFile, string.format(pods_static.startupCommand, pods_config.programFile, pods_config.task, pods_config.group))
end

-- Save configuration to external file
local function saveConfig()
	if pods_config.useExternalConfig then
		-- Serialize pods_config and save to file
		local t = textutils.serialize(pods_config)
		saveFile(pods_config.configFile, t)
	end
end

-- Load configuration from external file
local function loadConfig()
	if fs.exists(pods_config.configFile) then
		-- Load config from file and parse it
		local t = readFile(pods_config.configFile)
		local q = textutils.unserialize(t)
	
		-- Loop through and asign values
		for i,v in pairs(q) do
			pods_config[i] = v
		end
	end
end

local function controller_refreshScreen()
	if monitor ~= nil then
		monitor.clear()
		monitor.setCursorPos(1,1)
		monitor.setTextScale(1)
	
		local size_x, size_y = monitor.getSize()
		local mon_x = string.format("x%i", size_x)

		-- Initialize local variables
		local handlerCount, stateCurrent, stateMax, statePercentage, stateChargingCount, stateOutput, stateOutputStr = 0,0,0,0,0,0,""
	
		-- Local variables before output
		for i,v in pairs(pods_state) do
			handlerCount = handlerCount + 1
			stateCurrent = stateCurrent + v.analogState
		end
		stateMax = 15 * handlerCount
		statePercentage = stateCurrent / stateMax * 100
		stateChargingCount = countArr(listFilling)
		stateOutput = rs.getOutput(pods_config.side_rs_out)
		stateOutputStr = stateOutput and "On" or "Off"

		-- Print primary info (if string defined for [mon_x], use that, else use default)
		mon_println(pods_str.controller_monitor.header_running[mon_x] or pods_str.controller_monitor.header_running.default)
		mon_println(string.format(pods_str.controller_monitor.title_handlersConnected[mon_x] or pods_str.controller_monitor.title_handlersConnected.default, handlerCount))
		mon_println(string.format(pods_str.controller_monitor.title_statePercentage[mon_x] or pods_str.controller_monitor.title_statePercentage.default, statePercentage))
		mon_println(string.format(pods_str.controller_monitor.title_stateChargingCount[mon_x] or pods_str.controller_monitor.title_stateChargingCount.default, stateChargingCount))
		mon_println(string.format(pods_str.controller_monitor.title_stateOutput[mon_x] or pods_str.controller_monitor.title_stateOutput.default, stateOutputStr))
	
		if size_x > 18 then
			local pos_x, pos_y = 17, 2
			mon_println(pods_str.controller_monitor.latestTitle[mon_x] or pods_str.controller_monitor.latestTitle.default, pos_x, pos_y)
			for i=1,size_y-2,1 do
				local latest_id = listLatest[#listLatest+1-i]
				if latest_id ~= nil then
					mon_println(string.format(pods_str.controller_monitor.latestUpdate[mon_x] or pods_str.controller_monitor.latestUpdate.default, latest_id, pods_state[latest_id].analogState/15*100), pos_x)
				end
			end
		end
		
		if size_x > 29 then
			local pos_x, pos_y = 32, 2
			mon_println(pods_str.controller_monitor.alertTitle[mon_x] or pods_str.controller_monitor.alertTitle.default, pos_x, pos_y)
			
			-- Check for offlines
			for i,v in pairs(pods_state) do
				if hasValue(listLatest, i) == false then
					mon_println(string.format(pods_str.controller_monitor.alertHandlerDisconnected[mon_x] or pods_str.controller_monitor.alertHandlerDisconnected.default, i), pos_x)
				end
			end
			
			-- Check for duplicates in log
			local dupes = countDuplicates(listLatest)
			for i,v in pairs(dupes) do
				mon_println(string.format(pods_str.controller_monitor.alertDuplicate[mon_x] or pods_str.controller_monitor.alertDuplicate.default, i, v), pos_x)
			end
		end
	else
		if debugging then print(pods_str.monitorMissing) end
	end
end

local function controller_waitForUpdates() -- TODO
	local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
	local q = textutils.unserialize(message)

	-- If sucessfully parsed, and correct messageType => Handle update
	if q ~= nil and senderChannel == pods_config.broadcast_channel and q.msgType == pods_msgType.handlerUpdate and q.podsGroup == pods_config.group then
		-- Update controller table
		pods_state[q.senderID] = {
				computerLabel = q.senderLabel,
				analogState = q.analogState
			}
		-- Limit amount of entries in listLatest to be the amount of handlers connected to the controller
		while #listLatest >= countArr(pods_state) do
			table.remove(listLatest, 1)
		end
		-- Append the latest sender to listLatest
		table.insert(listLatest, q.senderID)
	
		-- Logging
		if debugging then print(string.format(pods_str.controller_handlerUpdate, q.senderLabel, q.analogState, 15)) end
	end
end

local function controller_handleUpdates()
	-- Wait for updates
	controller_waitForUpdates()

	-- Variables to hold which ones have free space, are currently filling, and which ones are full
	local listFree, listLimbo, listFull = {},{},{}

	-- Loop through retrieved state of all handlers
	for i,v in pairs(pods_state) do
		-- If state is less than (or equal to) the lower threshold, add to list of "to be filled"-handlers
		if v.analogState <= pods_config.threshold_lower then
			table.insert(listFree, i)
			-- If not already in the "charging"-list, then add it
			if hasValue(listFilling, i) == false then
				table.insert(listFilling, i)
			end
		-- Elseif state is larger than (or equal to) the upper threshold, add to list of "full"-handlers
		elseif v.analogState >= pods_config.threshold_upper then
			table.insert(listFull, i)
			-- If still in the "charging"-list, then remove it
			if hasValue(listFilling, i) then
				local index = hasPos(listFilling, i)
				table.remove(listFilling, index)
			end
		-- Else: The handler has not been sorted into either of the other lists, so add to "limbo-list" so it may be checked for errors
		else
			table.insert(listLimbo, i)
		end
	end

	-- If list of "to be filled"-handlers has more than 0 entries, set redstone output to true
	if #listFree > 0 then
		if rs.getOutput(pods_config.side_rs_out) == false then
			rs.setOutput(pods_config.side_rs_out, true)
			local t = string.format(pods_str.controller_chargingStart, #listFree)
			print(t)
			--monitor.write(t)
		end
	-- Elseif list of "charging"-handlers has 0 entries, set redstone output to false
	elseif #listFilling == 0 then
		if rs.getOutput(pods_config.side_rs_out) then
			rs.setOutput(pods_config.side_rs_out, false)
			local t = string.format(pods_str.controller_chargingSuspended, #listFree, #listFull)
			print(t)
			--monitor.write(t)
		end
	end

	-- If "limbo-list" has more than 0 entries, print message on the controller-screen
	if #listLimbo > 0 then
		local t = string.format(pods_str.controller_chargingLimbo, #listLimbo)
		print(t)
		--monitor.write(t)
	end

	controller_refreshScreen()
end

local function handler_sendUpdate()
	while true do
		local i = rs.getAnalogInput(pods_config.side_rs_in)
		local q = {
				msgType=pods_msgType.handlerUpdate,
				senderID=os.getComputerID(),
				senderLabel=os.getComputerLabel(),
				podsGroup=pods_config.group,
				analogState=i
			}
		modem.transmit(pods_config.broadcast_channel, pods_config.broadcast_channel, textutils.serialize(q))
		if debugging then print(string.format("Sending: %s", textutils.serialize(q))) end
		sleep(pods_config.sleep)
	end
end

local function handler_retrieveCommands() -- TODO
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
		if event ~= nil and event == "modem_message" then
			local q = textutils.unserialize(message)
			if q ~= nil and senderChannel == pods_config.broadcast_channel and q.targetID ~= nil and q.targetID == os.getComputerID() then
				if debugging then print(string.format(pods_str.handler_commandsReceived, q.senderID, q.targetID, q.command)) end
				if q.command == "update" then
					setStartup()
					if fs.exists(pods_config.tempStartupFile) then
						fs.delete(pods_config.tempStartupFile)
					end
					fs.move(pods_static.startupFile, pods_config.tempStartupFile)
					saveFile(pods_static.startupFile, string.format(pods_static.startupCommand, "update", 0))
					os.reboot()
				end
			end
		end
	end
end



-- ##########
-- ## Boot ##
-- ##########

-- Load config from file
loadConfig()

-- Save config to file
saveConfig()

-- Create startup script
if fs.exists(pods_static.startupFile) == false then
	setStartup()
end

-- If not set, set computerlabel
if os.getComputerLabel() == nil then
	os.setComputerLabel(string.format(pods_config.label_default, os.getComputerID()))
end

-- Initiate modem and monitor
for i,v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		modem = peripheral.wrap(v)
		modem.open(pods_config.broadcast_channel)
	elseif peripheral.getType(v) == "monitor" then
		monitor = peripheral.wrap(v)
	end
end
if modem == nil then
	print(pods_str.modemMissing)
	return
end

-- #########
-- ## Run ##
-- #########

-- Boot message
if pods_config.task ~= nil then
	print(string.format(pods_str.bootMessage, os.getComputerLabel(), pods_config.task, pods_config.group, pods_config.broadcast_channel))
end

-- Run script based on task
if pods_config.task == pods_static.tasks.controller then
	-- local controllerRoutine01 = coroutine.create(controller_handleUpdates)
	-- local event = {}
	-- while true do
		-- if debugging then print("Event: "..textutils.serialize(event)) end

		-- local ok, err = coroutine.resume(controllerRoutine01, unpack(event))
		-- if ok ~= true then print(err) end

		-- if debugging then print(string.format("Loop: %s", coroutine.status(controllerRoutine01))) end

		-- event = { os.pullEvent() }
	-- end
	while true do
		controller_handleUpdates()
	end
elseif pods_config.task == pods_static.tasks.handler then -- Handler
	local handlerRoutine01 = coroutine.create(handler_sendUpdate)
	local handlerRoutine02 = coroutine.create(handler_retrieveCommands)
	local event = {}
	while true do
		if debugging then print("Event: "..textutils.serialize(event)) end

		local ok, err = coroutine.resume(handlerRoutine01, unpack(event))
		if ok ~= true then print(err) end
		local ok, err = coroutine.resume(handlerRoutine02, unpack(event))
		if ok ~= true then print(err) end

		if debugging then print(string.format("Loop: %s - %s", coroutine.status(handlerRoutine01), coroutine.status(handlerRoutine02))) end

		event = { os.pullEvent() }
	end
else
	print(pods_str.jobUnspecified)
	printHelp()
	return
end