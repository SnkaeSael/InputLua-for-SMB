--------------------------- Sleek InputLua for SMB1/2J on FCEUX, NTSC -------------------------------

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

controller = ""
framenumbers = {"h", "i", "j", "k", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g"}

blackscrninc = false
remainder = ""
frame = ""
framebool = true
colour = "white"

function inputstr()
   controller = ""

   for i = 1, 8 do
      controller = controller .. ((joypad.get(1)[inputorder[i]]) and display[inputorder[i]] or " ")
   end
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

function drawstats()
   drawtext(2, 2, "inp " .. controller)
   drawtext(2, 9, timecount())
   drawtext(56, 2, string.format("xp %02x%02x%02x xs %d:%02x", xpage, xpixel, xsubpx, xspd, xsubspd))
   drawtext(136, 2, "sx " .. scrnx)
   drawtext(56, 9, string.format("yp %02x%02x%02x ys %d:%02x", ypage, ypixel, ysubpx, yspd, ysubspd))
   drawtext(136, 9, "fr " .. math.floor((emu.framecount() - emu.lagcount() - 1) / 21) % 32767)
   drawtext(172, 2, "f " .. igframe)
   drawtext(172, 9, "r " .. remainder)
   drawtext(196, 2, "s " .. sock())
   drawtext(196, 9, "-" .. frame)
   drawtext(208, 9, "lag " .. emu.lagcount())

   if (enemyslot[1] == 45 or enemyslot[2] == 45 or enemyslot[3] == 45 or enemyslot[4] == 45 or enemyslot[5] == 45) then
      drawtext(232, 2, "bhp " .. bowserhp)
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
   return string.format("%02d:%02d:%02d.%03d", t / 3600, (t / 60) % 60, t % 60, (t * 1000) % 1000)
end

function round(n)
   return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function sock()
   local xpos = xpage * 65536 + xpixel * 256 + xsubpx
   xpos = xpos + bit.rshift(255 - ypixel, 2) * 640
   return string.format("%.6x", xpos)
end

function drawlua()
   inputstr()
   readmemory()
   updatetimers()
   drawstats()
end

gui.register(drawlua)

while (true) do
   emu.frameadvance()
end
