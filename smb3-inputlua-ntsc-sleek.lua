--------------------------- Sleek InputLua for SMB3 on FCEUX, NTSC -------------------------------

display = {
	"010101111101101",
	"110101110101110",
	"011100010001110",
	"111010010010010",
	"101101101101111",
	"110101101101110",
	"100100100100111",
	"110101110101101",
}

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

blackscrninc = false;

letterIndex = {}
letterIndex["a"] = 1
letterIndex["b"] = 2
letterIndex["c"] = 3
letterIndex["d"] = 4
letterIndex["e"] = 5
letterIndex["f"] = 6
letterIndex["g"] = 7
letterIndex["h"] = 8
letterIndex["i"] = 9
letterIndex["j"] = 10
letterIndex["k"] = 11
letterIndex["l"] = 12
letterIndex["m"] = 13
letterIndex["n"] = 14
letterIndex["o"] = 15
letterIndex["p"] = 16
letterIndex["q"] = 17
letterIndex["r"] = 18
letterIndex["s"] = 19
letterIndex["t"] = 20
letterIndex["u"] = 21
letterIndex["v"] = 22
letterIndex["w"] = 23
letterIndex["x"] = 24
letterIndex["y"] = 25
letterIndex["z"] = 26
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
frameBool = ftrue
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
	local currentFrame = emu.framecount()
	local tasEditorInput = taseditor.getinput(currentFrame - 1, 1)
	local xo = 0
	if (tasEditorInput >= 0) then
		for button, letterData in ipairs(display) do
			local on = (AND(tasEditorInput, BIT(button - 1)) > 0)
			drawLetter(x + xo, y, letterData, on, true)
			xo = xo + 4
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
	--
	drawText(x+44, y, letterTable("spd "))
	tempint=memory.readbytesigned(0xbd)
	if(tempint<0)then
	drawText(x+60, y, letterTable("x" .. tempint))
	else
	drawText(x+60, y, letterTable("x " .. tempint))
	end
	tempint=memory.readbytesigned(0xcf)
	if(tempint<0)then
	drawText(x+60, y+7, letterTable("y" .. tempint))
	else
	drawText(x+60, y+7, letterTable("y " .. tempint))
	end
	--
	if(memory.readbytesigned(0x3dd) > 1) then
		drawText(x+80, y, letterTable("next p " .. math.floor(memory.readbyte(0x515)/8) .. math.fmod(memory.readbyte(0x515), 8)))
	end
	if(memory.readbyteunsigned(0x3dd) > 63) then
	--if(memory.readbyteunsigned(0x56e) == 128) then
	--pkillsub = 0
	--end
	--if(memory.readbyteunsigned(0x56e) == 0) then
	--pkillsub = 1
	--end
	if(memory.readbyteunsigned(0x56e) == pkill and memory.readbyteunsigned(0x56e) > 0) then
	tempint = -1
	else
	tempint = 0
	end
	if(memory.readbyteunsigned(0x56e) == 255) then
	tempint = -511
	end
	drawText(x+80, y + 7, letterTable("p kill " .. memory.readbyteunsigned(0x56e) * 2 + tempint))
	end
	pkill = memory.readbyteunsigned(0x56e)
	--
	drawText(x+124, y, letterTable("frm " .. tostring(emu.framecount())))
	drawText(x+124, y + 7, letterTable("lag " .. tostring(emu.lagcount())))
	--drawText(x, y +105, letterTable("time"))
	drawText(x+168, y, letterTable(timeCount()))
	--
	for i=0, 4, 1 do
		if((memory.readbyte(0x671+i) == 14 or memory.readbyte(0x671+i) == 24 or memory.readbyte(0x671+i) == 75 or memory.readbyte(0x671+i) == 76) and memory.readbyte(0x661+i) > 0) then
			drawText(x+216, y, letterTable("hp " .. memory.readbyte(0x7cf6+i)))
		end
	end
	if(memory.readbyte(0x14) == 1 and backtomap == 0) then
		backtomap = 1
		if(not(memory.readbyte(0x675) == 37 or (memory.readbyte(0x675) == 14 and memory.readbyte(0x7a01) == 0))) then
			levelcount = levelcount + 1
		end
	end
	if(memory.readbyte(0x14) == 0 and backtomap == 1) then
		backtomap = 0
	end
	drawText(x+216, y+7, letterTable("lvl " .. tostring(levelcount) .. "/104"))
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
	local digit1 = hexNumbers[math.floor(num / 16) + 1]
	local digit2 = hexNumbers[math.fmod(num, 16) + 1]
	return digit1 .. digit2
end

function toHex1(num)
	local digit1 = hexNumbers[math.floor(num / 16) + 1]
	return digit1
end

function toHex2(num)
	local digit2 = hexNumbers[math.fmod(num, 16) + 1]
	return digit2
end

function timeCount()
	local t = emu.framecount() / 60.098813897441
	local h = math.floor(t / 3600)
	local m = math.fmod(math.floor(t / 60), 60)
	local s = doubleDigit(round(math.fmod(t, 60) * 1000) / 1000)
	s = s .. string.rep(".", 3 - #s)
	s = s .. string.rep("0", 6 - #s)
	if(h>0)then
	return h .. ":" .. doubleDigit(m) .. ":" .. s
	else
	return m .. ":" .. s
	end
end

function updateTimers()
	if (memory.readbyte(14) == 0) then
		if(memory.readbyte(1952) == 7 and blackscreeninc) then
			remainder = doubleDigit(memory.readbyte(1919))
			blackscreeninc = false
		end
		
		if (frameBool) then
			frame = frameNumbers[memory.readbyte(1919) + 1]
			frameBool = false
		end
	else
		frameBool = true
		
		if (memory.readbyte(14) == 3 and remainder == "") then
			remainder = doubleDigit(memory.readbyte(1919))
		end
		
		if (memory.readbyte(14) == 5 and (memory.readbyte(1942) == 6 or memory.readbyte(1943) == 6 or memory.readbyte(1944) == 6 or memory.readbyte(1945) == 6 or memory.readbyte(1946) == 6) and remainder == "") then
			remainder = doubleDigit(memory.readbyte(1919))
			blackscreeninc = true
		end
		
		if (memory.readbyte(1953) == 6) then
			remainder = doubleDigit(memory.readbyte(1919))
		end
		
		if (memory.readbyte(14) == 7) then
			remainder = ""
		end
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

while (true) do
	if taseditor.engaged() then
		updateTimers()
		gui.box(0, 224, 256, 240, "black")
		drawInput(170, 233)
		drawStats(2, 226)
	end
	emu.frameadvance()
end
