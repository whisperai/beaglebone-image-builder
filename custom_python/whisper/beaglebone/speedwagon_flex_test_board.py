"""Class to interact with the speedwagon flex test board"""
import time
from enum import Enum

import Adafruit_BBIO.ADC as ADC
from smbus import SMBus
from whisper.beaglebone.gpio import BbbGpioAbc
from whisper.beaglebone.i2c import I2C


class SpeedwagonFlexTestBoard:
    """Class to interact with the speedwagon flex test board"""

    I2C_BUS_ID = 1

    class GPIO(GpioEnumAbc):
        """Enum for GPIOs"""

        POWER_1V8 = "P8_46"
        POWER_3V3 = "P8_45"
        PASS_LED = "P8_4"
        FAIL_LED = "P8_3"

    def __init__(self):
        """Initialize the GPIO + ADC"""
        self.GPIO.setup_all()
        self.i2c = I2C(self.I2C_BUS_ID)
        ADC.setup()
