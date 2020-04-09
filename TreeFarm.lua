slot_fuel = 1
slot_home = 2
slot_saplings = 3
slot_logs = 4

while true do
    while turtle.getFuelLevel() < 800 do
        print("Need fuel!")
        turtle.select(slot_fuel)
        turtle.refuel(turtle.getItemCount()-1)
    end

    turtle.select(slot_logs)
    while turtle.compare() == false do
        if turtle.detect() == false and turtle.getItemCount(slot_saplings) > 1 then
            turtle.select(slot_saplings)
            turtle.place()
            turtle.turnLeft()
            turtle.turnLeft()
            if turtle.detect() == false and turtle.getItemCount(slot_saplings) > 1 then
                turtle.select(slot_saplings)
                turtle.place()
            end
            turtle.turnLeft()
            turtle.turnLeft()
        end
        sleep(10)
        turtle.select(slot_logs)
    end
    while turtle.compare() do
        turtle.dig()
        turtle.digUp()
        turtle.attackUp()
        turtle.up()
    end
    turtle.turnLeft()
    turtle.turnLeft()
    while turtle.compare() do
        turtle.digUp()
        turtle.attackUp()
        turtle.up()
    end
    turtle.select(slot_home)
    while turtle.compareDown() == false do
        turtle.select(slot_logs)
        if turtle.compare() then
            turtle.dig()
        end
        turtle.digDown()
        turtle.attackDown()
        turtle.down()
        turtle.select(slot_home)
    end
    turtle.select(slot_logs)
    if turtle.compare() then
        turtle.dig()
    end
    if turtle.detect() == false and turtle.getItemCount(slot_saplings) > 1 then
        turtle.select(slot_saplings)
        turtle.place()
    end
    turtle.turnLeft()
    turtle.turnLeft()
    if turtle.detect() == false and turtle.getItemCount(slot_saplings) > 1 then
        turtle.select(slot_saplings)
        turtle.place()
    end
end