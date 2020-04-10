cont = 0
if os.getComputerLabel() == nil then
  cont = 1
else
  print("This computer already has it's own label.")
  print("Current label: '"..os.getComputerLabel().."'")
  print("Do you want to overwrite? (y/n)")
  repeat
    ans = string.lower(read())
    if ans == "y" then
      cont = 1
    elseif ans == "n" then
      cont = 2
    end
  until cont > 0
  print()
end
 
if cont == 1 then
  print("Naming computer:")
  print("ID: '#"..os.getComputerID().."'")
  if os.getComputerLabel() ~= nil then
--    print("Current Name: <name missing>")
--  else
    print("Current Name: '"..os.getComputerLabel().."'")
  end
  print("Prefix: '".."XnetLiquidsEmpty".."'")
  print("Please enter a suffix!")
  suffix = read()
  shell.run("label set XnetLiquidsEmpty"..suffix)
  print()
end
 
cont = 0
repeat
  print("Copying files to computer")
  print("Do you want to proceed? (y/n)")
  ans = string.lower(read())
 
  if ans == "y" then
    cont = 1
  elseif ans == "n" then
    cont = 2
  end
until cont > 0
 
if cont == 1 then
  shell.run("cp disk/start startup")
  shell.run("cp disk/run run")
--  shell.run("cp disk/liquid liquid")
end
 
print("Script finished, please remove computer from diskdrive!")