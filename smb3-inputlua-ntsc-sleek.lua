--------------------------- Sleek InputLua for SMB3 on FCEUX, NTSC -------------------------------

inputOrder = {
	"up",
	"down",
	"left",
	"right",
	"start",
	"select",
	"A",
	"B"
}

display = {A = "010101111101101", B = "110101110101110", select = "011100010001110", start = "111010010010010", up = "101101101101111", down = "110101101101110", left = "100100100100111", right = "110101110101101"}

nondisplay = {
	"010101111101101",
	"110101110101110",
	"011100100100011",
	"110101101101110",
	"111100111100111",
	"111100111100100",
	"011100101101011",
	"101101111101101",
	"111010010010111",
	"011001001101011",
	"101101110101101",
	"100100100100111",
	"101111101101101",
	"110101101101101",
	"010101101101010",
	"110101111100100",
	"010101101111011",
	"110101110101101",
	"011100010001110",
	"111010010010010",
	"101101101101111",
	"101101101101010",
	"101101101111101",
	"101101010101101",
	"101101010010010",
	"111001010100111",
	"111101101101111",
	"010110010010111",
	"110001010100111",
	"110001110001110",
	"101101111001001",
	"111100110001110",
	"111100111101111",
	"111001010010010",
	"111101111101111",
	"111101111001111",
	"000000000000000",
	"000000000000010",
	"000000111000000",
	"000010000000010",
	"001001010100100"
}

letterIndex = {a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8, i = 9, j = 10, k = 11, l = 12, m = 13, n = 14, o = 15, p = 16, q = 17, r = 18, s = 19, t = 20, u = 21, v = 22, w = 23, x = 24, y = 25, z = 26}

letterIndex["0"] = 27
letterIndex["1"] = 28
letterIndex["2"] = 29
letterIndex["3"] = 30
letterIndex["4"] = 31
letterIndex["5"] = 32
letterIndex["6"] = 33
letterIndex["7"] = 34
letterIndex["8"] = 35
letterIndex["9"] = 36
letterIndex[" "] = 37
letterIndex["."] = 38
letterIndex["-"] = 39
letterIndex[":"] = 40
letterIndex["/"] = 41

hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
frameNumbers = {"h", "i", "j", "k", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g"}

remainder = ""
frame = ""
pkill=0
levelcount=0
backtomap=0
tempint=0

function drawLetter(x, y, letterData, on)
	for xo = 0, 2 do
		for yo = 0, 4 do
			local stringOffset = yo * 3 + xo + 1
			if (string.sub(letterData, stringOffset, stringOffset) == "1" and on) then
				gui.pixel(x + xo, y + yo, "white")
			end
		end
	end
end

function drawInput(x, y)
	for i = 1, 8 do
		if (input[inputOrder[i]]) then
			drawLetter(x + (4 * (i - 1)), y, display[tostring(inputOrder[i])], true, false)
		end
	end
end

function drawStats(x, y)
	drawText(x, y, letterTable("pos "))
	drawText(x+16, y, letterTable("x " .. toHex2(memory.readbyte(0x75)) .. toHex(memory.readbyte(0x90)) .. toHex1(memory.readbyte(0x74d))))
	drawText(x+16, y +7, letterTable("y " .. toHex2(memory.readbyte(0x87)) .. toHex(memory.readbyte(0xa2)) .. toHex1(memory.readbyte(0x75f))))
	if(memory.readbyte(0x5fc) > 0 and memory.readbyteunsigned(0x5fc) < 2) then
		drawText(x+216, y, letterTable("scrnx " .. memory.readbyte(0xab)))
	end
	
	drawText(x + 44, y, letterTable("spd "))
	tempint = memory.readbytesigned(0xbd)
	
	if (tempint < 0) then
		drawText(x + 60, y, letterTable("x" .. tempint))
	else
		drawText(x + 60, y, letterTable("x " .. tempint))
	end
	
	tempint = memory.readbytesigned(0xcf)
	
	if (tempint < 0)then
		drawText(x + 60, y + 7, letterTable("y" .. tempint))
	else
		drawText(x + 60, y + 7, letterTable("y " .. tempint))
	end
	
	if (memory.readbytesigned(0x3dd) > 1) then
		drawText(x+80, y, letterTable("next p " .. math.floor(memory.readbyte(0x515)/8) .. math.fmod(memory.readbyte(0x515), 8)))
	end
	
	if(memory.readbyteunsigned(0x3dd) > 63) then
	
	--if(memory.readbyteunsigned(0x56e) == 128) then
	--	pkillsub = 0
	--end
	--if(memory.readbyteunsigned(0x56e) == 0) then
	--	pkillsub = 1
	--end
	
	if (memory.readbyteunsigned(0x56e) == pkill and memory.readbyteunsigned(0x56e) > 0) then
		tempint = -1
	else
		tempint = 0
	end
	
	if (memory.readbyteunsigned(0x56e) == 255) then
		tempint = -511
	end
		drawText(x + 80, y + 7, letterTable("p kill " .. memory.readbyteunsigned(0x56e) * 2 + tempint))
	end
	
	pkill = memory.readbyteunsigned(0x56e)
	drawText(x + 124, y, letterTable("frm " .. tostring(emu.framecount())))
	drawText(x + 124, y + 7, letterTable("lag " .. tostring(emu.lagcount())))
	--drawText(x, y +105, letterTable("time"))
	drawText(x + 168, y, letterTable(timeCount()))
	
	for i = 0, 4 do
		if ((memory.readbyte(0x671+i) == 14 or memory.readbyte(0x671+i) == 24 or memory.readbyte(0x671+i) == 75 or memory.readbyte(0x671+i) == 76) and memory.readbyte(0x661+i) > 0) then
			drawText(x+216, y, letterTable("hp " .. memory.readbyte(0x7cf6+i)))
		end
	end
	
	if (memory.readbyte(0x14) == 1 and backtomap == 0) then
		backtomap = 1
		if (not(memory.readbyte(0x675) == 37 or (memory.readbyte(0x675) == 14 and memory.readbyte(0x7a01) == 0))) then
			levelcount = levelcount + 1
		end
	end
	
	if (memory.readbyte(0x14) == 0 and backtomap == 1) then
		backtomap = 0
	end
	
	drawText(x + 216, y + 7, letterTable("lvl " .. tostring(levelcount) .. "/104"))
end

function drawText(x, y, arr)
	local l = #arr
	for xo = 1, l do
		drawLetter(x + (xo - 1) * 4, y, nondisplay[arr[xo]], true, false)
	end
end

function letterTable(str)
	local l = #str
	local t = {}
	for i = 1, l do
		t[i] = letterIndex[string.sub(str, i, i)]
	end
	return t
end

function toHex(num)
	return string.format('%02x', num)
end

function toHex1(num)
	return hexNumbers[math.floor(num / 16) + 1]
end

function toHex2(num)
	return hexNumbers[math.fmod(num, 16) + 1]
end

function timeCount()
	local t = 655171 * emu.framecount() / 39375000
	local h = math.floor(t / 3600)
	local m = math.fmod(math.floor(t / 60), 60)
	local s = doubleDigit(round(math.fmod(t, 60) * 1000) / 1000)
	s = s .. string.rep(".", 3 - #s)
	s = s .. string.rep("0", 6 - #s)
	if(h > 0)then
	return h .. ":" .. doubleDigit(m) .. ":" .. s
	else
	return m .. ":" .. s
	end
end

function doubleDigit(num)
	if (num < 10) then
		return "0" .. num
	else
		return tostring(num)
	end
end

function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function drawLua()
	gui.box(0, 224, 256, 240, "black")
	drawInput(170, 233)
	drawStats(2, 226)
end

while (true) do
	gui.register(drawLua)
	emu.frameadvance()
end
