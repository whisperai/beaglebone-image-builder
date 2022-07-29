"""Abstract enum class to wrap an enum with Adafruit_BBIO.GPIO"""
from enum import Enum
from typing import Union

import Adafruit_BBIO.GPIO as ada_gpio
from abstract import ABC


class GpioEnumAbc(Enum, ABC):
    """Abstract class for GPIOs"""

    @classmethod
    def setup_all(cls):
        for attr in cls:
            ada_gpio.setup(attr.value, ada_gpio.OUT)

    def set(self, value):
        ada_gpio.output(self.value, value)

    def get(self):
        return ada_gpio.input(self.value)

    def wait_for_edge(
        self, direction: Union[ada_gpio.RISING, ada_gpio.FALLING] = ada_gpio.RISING
    ):
        ada_gpio.wait_for_edge(self.value, direction)

    def add_event_detect(
        self, direction: Union[ada_gpio.RISING, ada_gpio.FALLING] = ada_gpio.RISING
    ):
        ada_gpio.add_event_detect(self.value, direction)

    def event_detected(self):
        ada_gpio.event_detected(self.value)
