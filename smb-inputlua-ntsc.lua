--------------------------- InputLua for SMB1/2J on FCEUX, NTSC -------------------------------

colours = {
	on = "yellow",
	off = "grey",
	onCurrent = "green",
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
}

blackscrninc = false

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

hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
frameNumbers = {"h", "i", "j", "k", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g"}

remainder = ""
frame = ""
frameBool = true

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
	drawText(x, y + 7, letterTable("x " .. toHex(memory.readbyte(109)) .. toHex(memory.readbyte(134)) .. toHex(memory.readbyte(1024))))
	drawText(x, y + 14, letterTable("y " .. toHex(memory.readbyte(181)) .. toHex(memory.readbyte(206)) .. toHex(memory.readbyte(1046))))
	drawText(x, y + 21, letterTable("scrnx " .. memory.readbyte(941)))
	drawText(x, y + 35, letterTable("speed"))
	drawText(x, y + 42, letterTable("x " .. memory.readbytesigned(87) .. "." .. memory.readbyte(1797)))
	drawText(x, y + 49, letterTable("y " .. memory.readbytesigned(159) .. "." .. memory.readbyte(1075)))
	drawText(x, y + 63, letterTable("fr " .. math.fmod(math.floor((emu.framecount() - emu.lagcount() - 1) / 21), 32767)))
	drawText(x, y + 70, letterTable("f " .. memory.readbyte(9)))
	drawText(x, y + 77, letterTable("r " .. remainder))
	drawText(x, y + 84, letterTable("-" .. frame))
	drawText(x, y + 98, letterTable("sock"))
	drawText(x, y + 105, letterTable(sock()))
	drawText(x, y + 119, letterTable("fcount"))
	drawText(x, y + 126, letterTable(tostring(emu.framecount())))
	drawText(x, y + 140, letterTable("time"))
	drawText(x, y + 147, letterTable("h " .. timeCount()[1]))
	drawText(x, y + 154, letterTable("m " .. timeCount()[2]))
	drawText(x, y + 161, letterTable("s " .. timeCount()[3]))
	drawText(x, y + 175, letterTable("lag " .. emu.lagcount()))
	if (memory.readbyte(22) == 45 or memory.readbyte(23) == 45 or memory.readbyte(24) == 45 or memory.readbyte(25) == 45 or memory.readbyte(26) == 45) then
		drawText(x, y + 189, letterTable("bowser " .. memory.readbyte(1155)))
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

function timeCount()
	local t = 655171 * emu.framecount() / 39375000
	local h = math.floor(t / 3600)
	local m = math.fmod(math.floor(t / 60), 60)
	local s = round(math.fmod(t, 60) * 1000) / 1000
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

function sockcalc(xp, yp)
	xp = xp + bit.rshift(255 - yp, 2) * 640
	return string.format('%.6x', xp)
end

function sock()
	local xp1 = memory.readbyte(109)
	local xp2 = memory.readbyte(134)
	local xp3 = memory.readbyte(1024)
	local yp = memory.readbyte(206)
	local xpos = bit.lshift(xp1, 16) + bit.lshift(xp2, 8) + xp3
	return sockcalc(xpos, yp)
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
