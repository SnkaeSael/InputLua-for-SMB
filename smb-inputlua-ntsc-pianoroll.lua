--------------------------- Sleek InputLua for SMB1/2J on FCEUX, NTSC -------------------------------

inputOrder = {
	"up",
	"down",
	"left",
	"right",
	"start",
	"select",
	"B",
	"A"
}

display = {A = "a", B = "b", select = "s", start = "t", up = "u", down = "d", left = "l", right = "r"}

charIndex = {
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
	z = "111001010100111"
}

charIndex["0"] = "111101101101111"
charIndex["1"] = "010110010010111"
charIndex["2"] = "110001010100111"
charIndex["3"] = "110001110001110"
charIndex["4"] = "101101111001001"
charIndex["5"] = "111100110001110"
charIndex["6"] = "111100111101111"
charIndex["7"] = "111001010010010"
charIndex["8"] = "111101111101111"
charIndex["9"] = "111101111001111"
charIndex[" "] = "000000000000000"
charIndex["."] = "000000000000010"
charIndex["-"] = "000000111000000"
charIndex[":"] = "000010000000010"

--hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
frameNumbers = {"h", "i", "j", "k", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g"}

blackscrninc = false
remainder = ""
frame = ""
frameBool = true

colours = {
	on = "yellow",
	off = "grey",
	onCurrent = "green",
	offCurrent = "white"
}

colour = "white"

function drawLetter(x, y, letterData)
	for xo = 0, 2 do
		for yo = 0, 4 do
			local stringOffset = yo * 3 + xo + 1
			if (string.sub(letterData, stringOffset, stringOffset) == "1") then
				gui.pixel(x + xo, y + yo, colour)
			end
		end
	end
end

function drawInput(x, y)
	local currentFrame = emu.framecount() - 1
	for frame = 0, 33 do
		if (currentFrame - 8 + frame > -2) then
			local tasEditorInput = taseditor.getinput(currentFrame - 8 + frame, 1)
			local input = {A = getBit(tasEditorInput, 0), B = getBit(tasEditorInput, 1), select = getBit(tasEditorInput, 2), start = getBit(tasEditorInput, 3), up = getBit(tasEditorInput, 4), down = getBit(tasEditorInput, 5), left = getBit(tasEditorInput, 6), right = getBit(tasEditorInput, 7)}
			
			if (currentFrame - 8 + frame == -1) then
				input = {A = false, B = false, select = false, start = false, up = false, down = false, left = false, right = false}
			end
			
			for i = 1, 8 do
				colour = input[inputOrder[i]] and ((frame == 8) and colours.onCurrent or colours.on) or ((frame == 8) and colours.offCurrent or colours.off)
				drawLetter(x + (5 * (i - 1)), y + frame * 7, charIndex[display[tostring(inputOrder[i])]])
			end
		end
	end
end

function readmemory()
	state = memory.readbyte(14)
	framerule = memory.readbyte(1919)
	levelendtimer = {memory.readbyte(1942), memory.readbyte(1943), memory.readbyte(1944), memory.readbyte(1945), memory.readbyte(1946)}
	blackscreentimer = memory.readbyte(1952)
	castletimer = memory.readbyte(1953)
	
	xpage = memory.readbyte(109)
	xpixel = memory.readbyte(134)
	xsubpx = memory.readbyte(1024)
	xspd = memory.readbytesigned(87)
	xsubspd = memory.readbyte(1797)
	
	scrnx = memory.readbyte(941)
	
	ypage = memory.readbyte(181)
	ypixel = memory.readbyte(206)
	ysubpx = memory.readbyte(1046)
	yspd = memory.readbytesigned(159)
	ysubspd = memory.readbyte(1075)
	
	igframe = memory.readbyte(9)
	
	bowserhp = memory.readbyte(1155)
	
	enemyslot = {memory.readbyte(22), memory.readbyte(23), memory.readbyte(24), memory.readbyte(25), memory.readbyte(26)}
end

function updateTimers()
	if (state == 0) then
		if (blackscreentimer == 7 and blackscreeninc) then
			remainder = doubleDigit(framerule)
			blackscreeninc = false
		end
		
		if (frameBool) then
			frame = frameNumbers[framerule + 1]
			frameBool = false
		end
	else
		frameBool = true
		
		if (state == 3) then
			blackscreeninc = true
		end
		
		if (state == 5 and (levelendtimer[1] == 6 or levelendtimer[2] == 6 or levelendtimer[3] == 6 or levelendtimer[4] == 6 or levelendtimer[5] == 6) and remainder == "") then
			remainder = doubleDigit(framerule)
			blackscreeninc = true
		end
		
		if (castletimer == 6) then
			remainder = doubleDigit(framerule)
		end
		
		if (state == 7) then
			remainder = ""
		end
		
		if (state == 8) then
			blackscreeninc = false
		end
	end
end

function drawStats(x, y)
	colour = "white"
	
	drawText(x, y, "position")
	drawText(x, y + 7, "x " .. toHex(xpage) .. toHex(xpixel) .. toHex(xsubpx))
	drawText(x, y + 14, "y " .. toHex(ypage) .. toHex(ypixel) .. toHex(ysubpx))
	drawText(x, y + 21, "scrnx " .. scrnx)
	drawText(x, y + 35, "speed")
	drawText(x, y + 42, "x " .. xspd .. ":" .. toHex(xsubspd))
	drawText(x, y + 49, "y " .. yspd .. ":" .. toHex(ysubspd))
	drawText(x, y + 63, "fr " .. math.fmod(math.floor((emu.framecount() - emu.lagcount() - 1) / 21), 32767))
	drawText(x, y + 70, "f " .. igframe)
	drawText(x, y + 77, "r " .. remainder)
	drawText(x, y + 84, "-" .. frame)
	drawText(x, y + 98, "sock")
	drawText(x, y + 105, sock())
	drawText(x, y + 119, "fcount")
	drawText(x, y + 126, tostring(emu.framecount()))
	drawText(x, y + 140, "time")
	drawText(x, y + 147, "h " .. timeCount()[1])
	drawText(x, y + 154, "m " .. timeCount()[2])
	drawText(x, y + 161, "s " .. timeCount()[3])
	drawText(x, y + 175, "lag " .. emu.lagcount())
	
	if (memory.readbyte(22) == 45 or memory.readbyte(23) == 45 or memory.readbyte(24) == 45 or memory.readbyte(25) == 45 or memory.readbyte(26) == 45) then
		drawText(x, y + 189, "bowser " .. bowserhp)
	end
end

function drawText(x, y, lt)
	local arr = letterTable(lt)
	local l = #arr
	for xo = 1, l do
		drawLetter(x + (xo - 1) * 4, y, arr[xo])
	end
end

function letterTable(str)
	local l = #str
	local t = {}
	for i = 1, l do
		t[i] = charIndex[string.sub(str, i, i)]
	end
	return t
end

function toHex(num)
	return string.format('%02x', num)
end

function timeCount()
	local t = 655171 * emu.framecount() / 39375000
	local h = math.floor(t / 3600)
	local m = math.fmod(math.floor(t / 60), 60)
	local s = round(math.fmod(t, 60) * 1000) / 1000
	return {h, m, s}
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

function getBit(num, pos)
	if (AND(bit.rshift(num, pos), 1) == 1) then
		return true
	else
		return false
	end
end

function drawLua()
	if taseditor.engaged() then
		gui.box(0, 0, 256, 240, "black", "black")
		readmemory()
		updateTimers()
		drawInput(2, 2)
		drawStats(216, 2)
	end
end

while (true) do
	gui.register(drawLua)
	emu.frameadvance()
end
