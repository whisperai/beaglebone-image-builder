#!/bin/bash
#
# Do the extra whisper installation steps.
# This could be expanded to different BBB images in the future.

enable_i2c1_on_startup () {
  # Make the pin configuration script
  cat > configure_pins.sh <<-__EOF__
#!/bin/bash -e

# Config the i2c1 PINs
config-pin p9.24 i2c
config-pin p9.26 i2c
__EOF__
  sudo chmod +x configure_pins.sh
  sudo mv configure_pins.sh ${tempdir}/home/debian

  # Use systemctl to configure pins on startup
  cat > configure_pins.service <<-__EOF__
[Unit]
Description=Setup for BBB pins

[Service]
Type=simple
ExecStart=/bin/bash /home/debian/configure_pins.sh

[Install]
WantedBy=multi-user.target
__EOF__
  sudo mv configure_pins.service ${tempdir}/etc/systemd/system
  sudo chroot "${tempdir}" systemctl start configure_pins.service
  sudo chroot "${tempdir}" systemctl enable configure_pins.service
}

install_custom_python () {
  ${tempdir}/usr/bin/python3 -m pip install ${DIR}/custom_python
}

enable_i2c1_on_startup
install_custom_python
