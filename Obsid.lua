x=0
y=0
turns=0



while true do
  while turtle.detectDown() do
    turtle.digDown()
  end
  while turtle.detect() do
    turtle.dig()
  end
  turtle.forward()
  x=x+1
  if x==2 then
    turtle.turnRight()
    x=0
    turns=turns+1
  end
  if turns==4 then
    turtle.digDown()
    turtle.down()
    turns=0
    y=y+1
  end
end