-- Install: pastebin get 4vaK9JYN botania

collected = 0
status = ""
version = "1.0"

while true do
	i = 0
	while turtle.getItemCount() == 0 do
		i = i + 1
		turtle.select(i)
		if i >= 16 and turtle.getItemCount() == 0 then
			break
		end
	end
	if turtle.getItemCount() == 0 then
		status = "Please insert more blocks..."
	elseif not turtle.compareUp() then
		redstone.setOutput("back", true)
		while true do
			sleep(1)
			if not turtle.detectUp() then
				collected = collected + 1
				redstone.setOutput("back", false)
				break
			end
		end

		if turtle.placeUp() then
			status = "Converting another..."
		else
			status = "Error occurred..."
		end
	else
		status = "Converting..."
	end
	
	term.clear()
	term.setCursorPos(1, 1)
	print(string.format("Running Botania Living-X collector v%s", version))
	print(string.format("Blocks converted: %d", collected))
	print(string.format("Status: %s", status))
	sleep(10)
end