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
	xscreen = memory.readbyte(0xab)
	
	xspeed = memory.readbytesigned(0xbd)
	
	yspeed = memory.readbytesigned(0xcf)
	
	pmeter = memory.readbytesigned(0x3dd) -- aka peter
	nextp = memory.readbyte(0x515)
	pkill = memory.readbyteunsigned(0x56e)
	
	backtomap = memory.readbyte(0x14)
end

display = {A = "a", B = "b", select = "s", start = "t", up = "u", down = "d", left = "l", right = "r"}

letterIndex = {
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
letterIndex["0"] = "111101101101111"
letterIndex["1"] = "010110010010111"
letterIndex["2"] = "110001010100111"
letterIndex["3"] = "110001110001110"
letterIndex["4"] = "101101111001001"
letterIndex["5"] = "111100110001110"
letterIndex["6"] = "111100111101111"
letterIndex["7"] = "111001010010010"
letterIndex["8"] = "111101111101111"
letterIndex["9"] = "111101111001111"
letterIndex[" "] = "000000000000000"
letterIndex["."] = "000000000000010"
letterIndex["-"] = "000000111000000"
letterIndex[":"] = "000010000000010"
letterIndex["/"] = "001001010100100"

--hexNumbers = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}

frame = ""
pkill = 0
levelcount = 0
backtompa = 0
tempint = 0
colour = "white"

function drawLetter(x, y, letterData, on)
	for xo = 0, 2 do
		for yo = 0, 4 do
			local stringOffset = yo * 3 + xo + 1
			if (string.sub(letterData, stringOffset, stringOffset) == "1" and on) then
				gui.pixel(x + xo, y + yo, colour)
			end
		end
	end
end

function inputStr()
	inbuttemp = ""
	for i = 1, 8 do
		if (joypad.get(1)[inputOrder[i]]) then
			inbuttemp = inbuttemp .. display[inputOrder[i]]
			--drawLetter(x + (4 * (i - 1)), y, display[tostring(inputOrder[i])], true, false)
		else
			inbuttemp = inbuttemp .. " "
		end
	end
	return inbuttemp
end

function drawStats()
	drawText(42, 1, inputStr())

	drawText(0, 0, "pos ")
	--colour="#8000ff" -- purple
	drawText(4, 0, "x " .. xpos)
	--colour="white"
	drawText(4, 1, "y " .. ypos)
	if (isautoscroll) then
		drawText(54, 0, "scrnx " .. xscreen)
	end
	
	drawText(11, 0, "spd ")
	
	if (xspeed < 0) then
		drawText(15, 0, "x" .. xspeed)
	else
		drawText(15, 0, "x " .. xspeed)
	end
	
	if (yspeed < 0) then
		drawText(15, 1, "y" .. yspeed)
	else
		drawText(15, 1, "y " .. yspeed)
	end
	
	if (pmeter > 1) then
		drawText(20, 0, "next p " .. math.floor(nextp/8) .. math.fmod(nextp, 8)) --8s digit can tell p state: charging -> 0, have -> 0/1, losing -> 0/1/2
	end
	
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
		drawText(20, 1, "p kill " .. pkill * 2 + tempint)
	end
	
	drawText(31, 0, "frm " .. tostring(emu.framecount()))
	drawText(31, 1, "lag " .. tostring(emu.lagcount()))
	drawText(42, 0, timeCount())
	
	--idk how to improve this
	--enemytypes = 0x671
	--enemyhps = 0x7cf6
	--enemystates = 0x661
	
	for i = 0, 4 do
		if ((memory.readbyte(0x671+i) == 14 or memory.readbyte(0x671+i) == 24 or memory.readbyte(0x671+i) == 75 or memory.readbyte(0x671+i) == 76) and memory.readbyte(0x661+i) > 0) then
			drawText(54, 0, "hp " .. memory.readbyte(0x7cf6+i))
		end
	end
	
	if (backtomap == 1 and backtompa == 0) then
		backtompa = 1
		if (not(memory.readbyte(0x675) == 37 or (memory.readbyte(0x675) == 14 and memory.readbyte(0x7a01) == 0))) then --pipe transition object or wand
			levelcount = levelcount + 1
		end
	end
	
	if (backtomap == 0 and backtompa == 1) then
		backtompa = 0
	end
	
	drawText(54, 1, "lvl " .. tostring(levelcount) .. "/104") --104 for 100%
end

function drawText(x, y, lt)
	x = x * 4 + 2
	y = y * 7 + 226 --
	local arr = letterTable(lt)
	local l = #arr
	for xo = 1, l do
		drawLetter(x + (xo - 1) * 4, y, arr[xo], true, false)
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

function toHex(num, nibble)
	if(nibble)then
		return string.sub(string.format('%02x', num), nibble+1, nibble+1)
	else
		return string.format('%02x', num)
	end
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
	readmemory()
	--drawInput(170, 233)
	drawStats()
end

while (true) do
	gui.register(drawLua)
	emu.frameadvance()
end
