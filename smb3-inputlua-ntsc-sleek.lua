--------------------------- Sleek InputLua for SMB3 on FCEUX, NTSC -------------------------------

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
charIndex["/"] = "001001010100100"

input = ""
--hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}

frame = ""
pkill = 0
levelcount = 0
pbacktomap = 0
tempint = 0
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
	xpage = memory.readbyte(0x75)
	xmain = memory.readbyte(0x90)
	xsub = memory.readbyte(0x74d)
	xpos = toHex(xpage, 1) .. toHex(xmain) .. toHex(xsub, 0)
	
	ypage = memory.readbyte(0x87)
	ymain = memory.readbyte(0xa2)
	ysub = memory.readbyte(0x75f)
	ypos = toHex(ypage, 1) .. toHex(ymain) .. toHex(ysub, 0)
	
	isautoscroll = memory.readbyte(0x5fc) > 0 and memory.readbyte(0x7a01) < 2
	scrnx = memory.readbyte(0xab)
	
	xspeed = memory.readbytesigned(0xbd)
	
	yspeed = memory.readbytesigned(0xcf)
	
	pmeter = memory.readbytesigned(0x3dd)
	nextp = memory.readbyte(0x515)
	pkill = memory.readbyteunsigned(0x56e)
	
	backtomap = memory.readbyte(0x14)
	
	enemytypes = {memory.readbyte(0x671), memory.readbyte(0x672), memory.readbyte(0x673), memory.readbyte(0x674), memory.readbyte(0x675)}
	enemystates = {memory.readbyte(0x661), memory.readbyte(0x662), memory.readbyte(0x663), memory.readbyte(0x664), memory.readbyte(0x665)}
	
	ispipetransition = memory.readbyte(0x675) == 37
	iswand = (memory.readbyte(0x675) == 14 and memory.readbyte(0x7a01) == 0)
end

function updateTimers()
	if (pmeter > 63) then
		if (pkill == pkilllast and pkill > 0) then --only works when playing forward
			tempint = -1
		else
			tempint = 0
		end
		
		pkilllast = pkill
	
		if (pkill == 255) then --pwing
			tempint = -511
		end
	end
	
	if (backtomap == 1 and pbacktomap == 0) then
		pbacktomap = 1
		if (not(ispipetransition or iswand)) then
			levelcount = levelcount + 1
		end
	end
	
	if (backtomap == 0 and pbacktomap == 1) then
		pbacktomap = 0
	end
end

function drawStats()
	drawText(10, 226, "inp " .. input)
	drawText(10, 233, doubleDigit(timeCount()[1]) .. ":" .. doubleDigit(timeCount()[2]) .. ":" .. doubleDigit(timeCount()[3]))
	drawText(62, 226, "xpos " .. xpos)
	drawText(62, 233, "ypos " .. ypos)
	drawText(218, 226, "scrnx " .. scrnx)
	drawText(102, 226, "xspd " .. xspeed)
	drawText(102, 233, "yspd " .. yspeed)
	
	if (pmeter > 1) then
		drawText(138, 226, "next p " .. math.floor(nextp/8) .. math.fmod(nextp, 8)) --8s digit can tell p state: charging -> 0, have -> 0/1, losing -> 0/1/2
	end
	
	if (pmeter > 63) then
		drawText(138, 233, "p kill " .. pkill * 2 + tempint)
	end
	
	drawText(178, 226, "lag " .. tostring(emu.lagcount()))
	
	for i = 1, 5 do
		if ((enemytypes[i] == 14 or enemytypes[i] == 24 or enemytypes[i] == 75 or enemytypes[i] and enemystates[i] > 0)) then
			drawText(182, 233, "hp " .. memory.readbyte(0x7cf6 + i - 1))
		end
	end
	
	drawText(210, 233, "lvl " .. tostring(levelcount) .. "/104") --104 for 100%
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

function toHex(num, nibble)
	if nibble then
		return string.sub(string.format('%02x', num), nibble + 1, nibble + 1)
	else
		return string.format('%02x', num)
	end
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
