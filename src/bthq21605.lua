--
--    Copyright (C) 2014 Tamas Szabo <sza2trash@gmail.com>
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

local moduleName = ...
local M = {}
_G[moduleName] = M

local ADDR = 0x3b --I2C device address

local init = false

-- i2c interface ID
local id = 0

-- initialize module
-- sda: SDA pin
-- scl SCL pin
function M.init(sda, scl)
	i2c.setup(id, sda, scl, i2c.SLOW)
	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x00) -- CMD = 0;RS = 0 : command
	i2c.write(id, 0x25) -- set 2 lines, enable extra function set (M=1, H=1)
	i2c.write(id, 0xa9) -- set Va
	i2c.write(id, 0x24) -- function set: two lines, standard function set
	i2c.write(id, 0x0c) -- display control: ON, no cursor, no blink
	i2c.write(id, 0x06) -- Entry mode set: increment, display freeze(no shift)
	i2c.stop(id)
	init = true
end

-- set the curso visible (1) or invisible (0)
function M.setCursor(cursor)
	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x00) -- CMD = 0;RS = 0 : command
	if (cursor == 0) then
		i2c.write(id, 0x0c) -- no cursor, no blink
	else
		i2c.write(id, 0x0f) -- cursor ON, blink ON
	end
	i2c.stop(id)
end

-- set the active line
function M.setLine(line)
	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x00) -- CMD = 0;RS = 0 : command
	if (line == 1) then
		i2c.write(id, 0xc0) -- set cursor to start of line 1
	else
		i2c.write(id, 0x80) -- set cursor to start of line 0
	end
	i2c.stop(id)
end

-- clear the whole screen (both lines)
function M.clearScreen()
	M.setLine(0)

	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x40) -- CMD = 0;RS = 0 : command
	for cnt = 1, 16 do
		i2c.write(id, 0x80 + 0x20) -- add 0x80 due to the character set of LCD
	end
	i2c.stop(id)

	M.setLine(1)

	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x40) -- CMD = 0;RS = 0 : command
	for cnt = 1, 16 do
		i2c.write(id, 0x80 + 0x20) -- add 0x80 due to the character set of LCD
	end
	i2c.stop(id)

	M.setLine(0)
end

-- print a character at the current cursor position
function M.putChar(chr)
	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x40) -- CMD = 0;RS = 0 : command
	i2c.write(id, 0x80 + string.byte(chr, 1)) -- add 0x80 due to the character set of LCD
	i2c.stop(id)
end

-- print a string from the current cursor position (no check for line end)
function M.printString(str)
	i2c.start(id)
	i2c.address(id, ADDR, i2c.TRANSMITTER)
	i2c.write(id, 0x40) -- CMD = 0;RS = 0 : command
	for cnt = 1, string.len(str) do
		i2c.write(id, 0x80 + string.byte(str, cnt))
	end
	i2c.stop(id)
end

return M
