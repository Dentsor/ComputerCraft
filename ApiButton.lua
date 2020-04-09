-- CC_ApiButton
-- xnet/api/button

-- TODO
-- 1: update button[name]["active"] to button[name]["color"]
-- 2: use array to store the colors that can be used...

local mon = peripheral.wrap("right")
mon.setTextScale(1)
mon.setTextColor(colors.white)
local button={}
mon.setBackgroundColor(colors.black)
 
local colorOn   = colors.lime
local colorOff  = colors.red
local colorIdle = colors.yellow
 
function setColors(cIdle, cOff, cOn)
  colorIdle = cIdle
  colorOff = cOff
  colorOn = cOn
end
 
function clearTable()
   button = {}
end
               
function setTable(name, func, param, xmin, xmax, ymin, ymax)
   button[name] = {}
   button[name]["func"] = func
   button[name]["active"] = 0
   button[name]["param"] = param
   button[name]["xmin"] = xmin
   button[name]["ymin"] = ymin
   button[name]["xmax"] = xmax
   button[name]["ymax"] = ymax
end
 
function funcName()
   print("You clicked buttonText")
end
       
function fillTable()
   setTable("ButtonText", funcName, 5, 25, 4, 8)
end    
 
function fill(text, color, bData)
   mon.setBackgroundColor(color)
   local yspot = math.floor((bData["ymin"] + bData["ymax"]) /2)
   local xspot = math.floor((bData["xmax"] - bData["xmin"] - string.len(text)) /2) +1
   for j = bData["ymin"], bData["ymax"] do
      mon.setCursorPos(bData["xmin"], j)
      if j == yspot then
         for k = 0, bData["xmax"] - bData["xmin"] - string.len(text) +1 do
            if k == xspot then
               mon.write(text)
            else
               mon.write(" ")
            end
         end
      else
         for i = bData["xmin"], bData["xmax"] do
            mon.write(" ")
         end
      end
   end
   mon.setBackgroundColor(colors.black)
end
     
function screen()
   local currColor
   for name,data in pairs(button) do
      local state = data["active"]
      if state == 0 then
         currColor = colorIdle
      elseif state == 1 then
         currColor = colorOff
      elseif state == 2 then
         currColor = colorOn
      else
         currColor = colorIdle
      end
--    if on == true then currColor = colorOn else currColor = colorOff end
      fill(name, currColor, data)
   end
end

function setButtonState(name, state)
   if state >= 0 then
      if state <= 2 then
         button[name]["active"] = state
      end
   end
   screen()
end

function toggleButton(name)
   if button[name]["active"] == 1 then
      button[name]["active"] = 2
   elseif button[name]["active"] == 2 then
      button[name]["active"] = 1
   else
      button[name]["active"] = 1
   end
   --button[name]["active"] = not button[name]["active"]
   screen()
end    

function flash(name)
   toggleButton(name)
   screen()
   sleep(0.15)
   toggleButton(name)
   screen()
end
                                             
function checkxy(x, y)
   for name, data in pairs(button) do
      if y>=data["ymin"] and  y <= data["ymax"] then
         if x>=data["xmin"] and x<= data["xmax"] then
            if data["param"] == "" then
              data["func"]()
            else
              data["func"](data["param"])
            end
            return true
            --data["active"] = not data["active"]
            --print(name)
         end
      end
   end
   return false
end
     
function heading(text)
   w, h = mon.getSize()
   mon.setCursorPos((w-string.len(text))/2+1, 1)
   mon.write(text)
end
     
function label(w, h, text)
   mon.setCursorPos(w, h)
   mon.write(text)
end