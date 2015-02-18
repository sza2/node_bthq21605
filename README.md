# node_bthq21605
BTHQ 21605 I2C LCD driver ESP8266/NodeMCU

BTHQ 21605 is a 2 lines x 16 characters LCD controllabe through I2C bus.

This driver does not handle POR (reset) pin of the LCD. However it seems it is
enough to pull POR down to GND, applying power will reset the LCD controller.

Example:

-- load module
lcd = require("bthq21605")

-- init, SDA: GPIO2, SCL: GPIO0
lcd.init(4,3)

-- fills both lines with spaces ie. clears the whole screen
lcd.clearScreen()

-- sets the cursor to the first character of upper line
lcd.setLine(0)

-- prints the string
lcd.printString("Hello World!")

-- sets the cursor to the first character of lower line
lcd.setLine(1)

-- prints formatted string
lcd.printString(string.format("%3.2f", 99.9999))

-- turns on the blinking cursor
lcd.setCursor(1)
