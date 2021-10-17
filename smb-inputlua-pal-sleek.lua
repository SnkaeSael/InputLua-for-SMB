--------------------------- Sleek InputLua for SMB1/2J on FCEUX, PAL -------------------------------

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

input = ""
--hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
frameNumbers = {"e", "f", "g", "h", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d"}

blackscrninc = false
remainder = ""
frame = ""
frameBool = true
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

function inputStr()
	input = ""
	
	for i = 1, 8 do
		if (joypad.get(1)[inputOrder[i]]) then
			input = input .. display[inputOrder[i]]
		else
			input = input .. " "
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

function drawStats()
	drawText(2, 2, "inp " .. input)
	drawText(2, 9, doubleDigit(timeCount()[1]) .. ":" .. doubleDigit(timeCount()[2]) .. ":" .. doubleDigit(timeCount()[3]))
	drawText(56, 2, "xp " .. toHex(xpage) .. toHex(xpixel) .. toHex(xsubpx) .. " xs " .. xspd .. ":" .. toHex(xsubspd))
	drawText(136, 2, "sx " .. scrnx)
	drawText(56, 9, "yp " .. toHex(ypage) .. toHex(ypixel) .. toHex(ysubpx) .. " ys " .. yspd .. ":" .. toHex(ysubspd))
	drawText(136, 9, "fr " .. math.fmod(math.floor((emu.framecount() - emu.lagcount() - 1) / 18), 32767))
	drawText(172, 2, "f " .. igframe)
	drawText(172, 9, "r " .. remainder)
	drawText(196, 2, "s " .. sock())
	drawText(196, 9, "-" .. frame)
	drawText(208, 9, "lag " .. emu.lagcount())
	
	if (enemyslot[1] == 45 or enemyslot[2] == 45 or enemyslot[3] == 45 or enemyslot[4] == 45 or enemyslot[5] == 45) then
		drawText(232, 2, "bhp " .. bowserhp)
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
	local t = 6448 * emu.framecount() / 322445
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

function sock()
	local xpos = bit.lshift(xpage, 16) + bit.lshift(xpixel, 8) + xsubpx
	xpos = xpos + math.floor((255 - ypixel) / 5) * 768
	return string.format('%.6x', xpos)
end

function drawLua()
	inputStr()
	readmemory()
	updateTimers()
	drawStats()
end

while (true) do
	gui.register(drawLua)
	emu.frameadvance()
end
