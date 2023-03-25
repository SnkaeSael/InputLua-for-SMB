--------------------------- PianoRoll InputLua for SMB1/2J on FCEUX, NTSC -------------------------------

inputorder = {"up", "down", "left", "right", "start", "select", "B", "A"}

display = {A = "a", B = "b", select = "s", start = "t", up = "u", down = "d", left = "l", right = "r"}

charindex = {
   a = "010101111101101",
   b = "110101110101110",
   c = "011100100100011",
   d = "110101101101110",
   e = "111100111100111",
   f = "111100111100100",
   g = "011100101101011",
   h = "101101111101101",
   i = "111010010010111",
   j = "011001001101011",
   k = "101101110101101",
   l = "100100100100111",
   m = "101111101101101",
   n = "110101101101101",
   o = "010101101101010",
   p = "110101111100100",
   q = "010101101111011",
   r = "110101110101101",
   s = "011100010001110",
   t = "111010010010010",
   u = "101101101101111",
   v = "101101101101010",
   w = "101101101111101",
   x = "101101010101101",
   y = "101101010010010",
   z = "111001010100111",
   ["0"] = "111101101101111",
   ["1"] = "010110010010111",
   ["2"] = "110001010100111",
   ["3"] = "110001110001110",
   ["4"] = "101101111001001",
   ["5"] = "111100110001110",
   ["6"] = "111100111101111",
   ["7"] = "111001010010010",
   ["8"] = "111101111101111",
   ["9"] = "111101111001111",
   [" "] = "000000000000000",
   ["."] = "000000000000010",
   ["-"] = "000000111000000",
   [":"] = "000010000000010"
}

framenumbers = {"h", "i", "j", "k", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g"}

blackscrninc = false
remainder = ""
frame = ""
frameBool = true

colours = {on = "yellow", off = "grey", oncurrent = "green", offcurrent = "white"}

colour = "white"

function drawinput(x, y)
   local currentFrame = emu.framecount() - 1
   for frame = 0, 33 do
      if (currentFrame - 8 + frame > -2) then
         local taseditorinput = taseditor.getinput(currentFrame - 8 + frame, 1)
         local input = {A = getbit(taseditorinput, 0), B = getbit(taseditorinput, 1), select = getbit(taseditorinput, 2), start = getbit(taseditorinput, 3), up = getbit(taseditorinput, 4), down = getbit(taseditorinput, 5), left = getbit(taseditorinput, 6), right = getbit(taseditorinput, 7)}

         if (currentFrame - 8 + frame == -1) then
            input = {A = false, B = false, select = false, start = false, up = false, down = false, left = false, right = false}
         end

         for i = 1, 8 do
            colour = input[inputorder[i]] and ((frame == 8) and colours.oncurrent or colours.on) or ((frame == 8) and colours.offcurrent or colours.off)
            drawletter(x + (5 * (i - 1)), y + frame * 7, charindex[display[tostring(inputorder[i])]])
         end
      end
   end
end

function getbit(num, pos)
   if (AND(bit.rshift(num, pos), 1) == 1) then
      return true
   end

   return false
end

function readmemory()
   state = memory.readbyte(0xe)
   framerule = memory.readbyte(0x77f)
   levelendtimer = {memory.readbyte(0x796), memory.readbyte(0x797), memory.readbyte(0x798), memory.readbyte(0x799), memory.readbyte(0x79a), memory.readbyte(0x79b)}
   blackscreentimer = memory.readbyte(0x7a0)
   castletimer = memory.readbyte(0x7a1)

   xpage = memory.readbyte(0x6d)
   xpixel = memory.readbyte(0x86)
   xsubpx = memory.readbyte(0x400)
   xspd = memory.readbytesigned(0x57)
   xsubspd = memory.readbyte(0x705)

   scrnx = memory.readbyte(0x3ad)

   ypage = memory.readbyte(0xb5)
   ypixel = memory.readbyte(0xce)
   ysubpx = memory.readbyte(0x416)
   yspd = memory.readbytesigned(0x9f)
   ysubspd = memory.readbyte(0x433)

   igframe = memory.readbyte(0x9)

   bowserhp = memory.readbyte(0x483)

   enemyslot = {memory.readbyte(0x16), memory.readbyte(0x17), memory.readbyte(0x18), memory.readbyte(0x19), memory.readbyte(0x1a)}
end

function updatetimers()
   if (state == 0) then
      if (blackscreentimer == 7 and blackscreeninc) then
         remainder = string.format("%02d", framerule)
         blackscreeninc = false
      end

      if (framebool) then
         frame = framenumbers[framerule + 1]
         framebool = false
      end
   else
      framebool = true

      if (state == 3) then
         blackscreeninc = true
      end

      if (state == 5 and (levelendtimer[1] == 6 or levelendtimer[2] == 6 or levelendtimer[3] == 6 or levelendtimer[4] == 6 or levelendtimer[5] == 6 or levelendtimer[6] == 6) and remainder == "") then
         remainder = string.format("%02d", framerule)
         blackscreeninc = true
      end

      if (castletimer == 6 and remainder == "") then
         remainder = string.format("%02d", framerule)
      end

      if (state == 7) then
         remainder = ""
      end

      if (state == 8) then
         blackscreeninc = false
      end
   end
end

function drawstats(x, y)
   colour = "white"

   drawtext(x, y, "position")
   drawtext(x, y + 7, string.format("x %02x%02x%02x", xpage, xpixel, xsubpx))
   drawtext(x, y + 14, string.format("y %02x%02x%02x", ypage, ypixel, ysubpx))
   drawtext(x, y + 21, "scrnx " .. scrnx)
   drawtext(x, y + 35, "speed")
   drawtext(x, y + 42, string.format("x %d:%02x", xspd, xsubspd))
   drawtext(x, y + 49, string.format("y %d:%02x", yspd, ysubspd))
   drawtext(x, y + 63, "fr " .. math.floor((emu.framecount() - emu.lagcount() - 1) / 21) % 32767)
   drawtext(x, y + 70, "f " .. igframe)
   drawtext(x, y + 77, "r " .. remainder)
   drawtext(x, y + 84, "-" .. frame)
   drawtext(x, y + 98, "sock")
   drawtext(x, y + 105, sock())
   drawtext(x, y + 119, "fcount")
   drawtext(x, y + 126, tostring(emu.framecount()))
   local time = timecount()
   drawtext(x, y + 140, "time")
   drawtext(x, y + 147, "h " .. time[1])
   drawtext(x, y + 154, "m " .. time[2])
   drawtext(x, y + 161, "s " .. time[3])
   drawtext(x, y + 175, "lag " .. emu.lagcount())

   if (memory.readbyte(22) == 45 or memory.readbyte(23) == 45 or memory.readbyte(24) == 45 or memory.readbyte(25) == 45 or memory.readbyte(26) == 45) then
      drawtext(x, y + 189, "bowser " .. bowserhp)
   end
end

function drawtext(x, y, str)
   local l = #str
   for i = 1, l do
      drawletter(x + (i - 1) * 4, y, charindex[str:sub(i, i)])
   end
end

function drawletter(x, y, letterdata)
   for i = 0, 2 do
      for j = 0, 4 do
         local stringoffset = j * 3 + i + 1
         if (letterdata:sub(stringoffset, stringoffset) == "1") then
            gui.pixel(x + i, y + j, colour)
         end
      end
   end
end

function timecount()
   local t = round(655171 * emu.framecount() / 39375) / 1000
   local h = math.floor(t / 3600)
   local m = math.floor((t / 60) % 60)
   local s = t % 60
   return {h, m, s}
end

function round(n)
   return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function sock()
   local xpos = xpage * 65536 + xpixel * 256 + xsubpx
   xpos = xpos + (255 - ypixel) * 160
   return string.format("%.6x", xpos)
end

function drawlua()
   if taseditor.engaged() then
      gui.box(0, 0, 256, 240, "black", "black")
      readmemory()
      updatetimers()
      drawinput(2, 2)
      drawstats(216, 2)
   end
end

gui.register(drawlua)

while (true) do
   emu.frameadvance()
end
