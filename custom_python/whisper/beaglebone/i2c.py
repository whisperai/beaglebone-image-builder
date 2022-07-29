"""Class to interact with an I2C bus"""
from smbus import SMBus


class I2C:
    """Class to interact with an I2C bus"""

    def __init__(self, bus_id):
        self._smbus = SMBus(bus_id)

    def get_i2c_addresses(self, mux_ch):
        """Get all the i2c addresses with an attached devices"""
        # Poke each address
        addr_range = range(0x7F)
        addr_list = []
        for addr in addr_range:
            try:
                self._smbus.read_i2c_block_data(addr, 0x0, 0x2)
                addr_list.append(addr)
            except Exception:
                pass

        return addr_list

    def read_block_data(self, addr, reg, data, length=0x2):
        """Read I2C block data."""
        return self._smbus.read_i2c_block_data(addr, reg, length)

    def write_block_data(self, addr, reg, data, reverse=False):
        """Write I2C block data."""
        # Check / Reverse Bytes
        if data > 0xFFFF:
            raise ValueError("Data is all ones!")
        data = (
            [data >> 8 & 0xFF, data & 0xFF]
            if reverse
            else [data & 0xFF, data >> 8 & 0xFF]
        )

        self._smbus.write_i2c_block_data(addr, reg, data)

    def write_quick_word(self, addr, data, reverse=False):
        """Write I2C quick word without issuing an register address.

        * data[0] - bits [15:8] of 16 bit word
        * data[1] - bits [7:0] of 16 bit word
        """
        # Check / Reverse Bytes
        if data > 0xFFFF:
            return -1
        data = (
            [data >> 8 & 0xFF, data & 0xFF]
            if reverse
            else [data & 0xFF, data >> 8 & 0xFF]
        )
        self._smbus.write_i2c_block_data(addr, data[0], data[1:])
