side = "top"
status = "Starting up"
hits = 0

local function refreshScreen()
	term.clear()
	term.setCursorPos(1,1)
	print("Running Attack script...")
	print("Controlled by redstone signal: " .. side)
	print("Hits: " .. hits)
	print("Status: ".. status)
end

while true do
	if redstone.getInput(side) then
		status = "Active"
		if turtle.attack() then
			hits = hits + 1
		end
	else
		status = "Inactive"
	end
	refreshScreen()
	sleep(0.1)
end