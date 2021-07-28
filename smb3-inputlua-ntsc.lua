--------------------------- InputLua for SMB3 on FCEUX, NTSC -------------------------------

colours = {
	on         = "yellow",
	off        = "grey",
	onCurrent  = "green",
	offCurrent = "white",
}

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
	"000010000000010"
}

blackscrninc = false

letterIndex = {a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8, i = 9, j = 10, k = 11, l = 12, m = 13, n = 14, o = 15, p = 16, q = 17, r = 18, s = 19, t = 20, u = 21, v = 22, w = 23, x = 24, y = 25, z = 26, 0 = 27}

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

hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
frameNumbers = {"h", "i", "j", "k", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g"}

remainder = ""
frame = ""
frameBool = ftrue

function drawLetter(x, y, letterData, on, current)
	local onColour  = current and colours.onCurrent  or colours.on
	local offColour = current and colours.offCurrent or colours.off
	for xo = 0, 2 do
		for yo = 0, 4 do
			local stringOffset = yo * 3 + xo + 1
			if (string.sub(letterData, stringOffset, stringOffset) == "1") then
				gui.pixel(x + xo, y + yo, on and onColour or offColour)
			end
		end
	end
end

function drawInput(x, y)
	local currentFrame = emu.framecount()
	for frame = 0, 33 do
		local tasEditorInput = taseditor.getinput(currentFrame - 8 + frame, 1)
		local xo = 0
		if (tasEditorInput >= 0) then
			for button, letterData in ipairs(display) do
				local on = (AND(tasEditorInput, BIT(button - 1)) > 0)
				drawLetter(x + xo, y + frame * 7, letterData, on, frame == 8)
				xo = xo + 5
			end
		end
	end
end

function drawStats(x, y)
	drawText(x, y, letterTable("position"))
	drawText(x, y +  7, letterTable("x " .. toHex2(memory.readbyte(0x75)) .. toHex(memory.readbyte(0x90)) .. toHex1(memory.readbyte(0x74d))))
	drawText(x, y + 14, letterTable("y " .. toHex2(memory.readbyte(0x87)) .. toHex(memory.readbyte(0xa2)) .. toHex1(memory.readbyte(0x75f))))
	--drawText(x, y + 21, letterTable("scrnx " .. memory.readbyte(0xab)))
	--
	drawText(x, y + 35, letterTable("speed"))
	drawText(x, y + 42, letterTable("x " .. memory.readbytesigned(0xbd)))
	drawText(x, y + 49, letterTable("y " .. memory.readbytesigned(0xcf)))
	--
	drawText(x, y + 63, letterTable("next p " .. math.floor(memory.readbyte(0x515)/8)))--/8 easier to read
	--
	drawText(x, y + 77, letterTable("frames"))
	drawText(x, y + 84, letterTable(tostring(emu.framecount())))
	drawText(x, y + 91, letterTable("lag"))
	drawText(x, y + 98, letterTable(tostring(emu.lagcount())))
	drawText(x, y +105, letterTable("time"))
	drawText(x, y +112, letterTable(timeCount()[2] .. ":" .. timeCount()[3]))
	--
	for i=0, 4, 1 do
		if(memory.readbyte(0x671+i) == 24 or memory.readbyte(0x671+i) == 75 or memory.readbyte(0x671+i) == 76) then
			drawText(x, y + 126, letterTable("hp " .. memory.readbyte(0x7cf6+i)))
		end
	end
end

function drawText(x, y, arr)
	local l = #arr
	for xo = 1, l do
		drawLetter(x + (xo - 1) * 4, y, nondisplay[arr[xo]], false, true)
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
	local t = 655171 * emu.framecount() / 39375000
	local h = math.floor(t / 3600)
	local m = doubleDigit(math.fmod(math.floor(t / 60), 60))
	local s = doubleDigit(round(math.fmod(t, 60) * 1000) / 1000)
	s = s .. string.rep(".", 3 - #s)
	s = s .. string.rep("0", 6 - #s)
	return {h, m, s}
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
	if (num <= 9) then
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
		gui.box(0, 0, 256, 240, "black", "black")
		drawInput(2, 2)
		drawStats(216, 2)
	end
	emu.frameadvance()
end
