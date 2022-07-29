#!/bin/bash
#
# Do the extra whisper installation steps.
# This could be expanded to different BBB images in the future.

enable_i2c1_on_startup () {
  cat > ${tempdir}/usr/local/src/set_pins.sh <<-__EOF__
    #!/bin/bash -e

    # Config the i2c1 PINs
    config-pin p9.24 i2c
    config-pin p9.26 i2c
  __EOF__
  sudo chmod +x ${tempdir}/usr/local/src/set_pins.sh
  cat > ${tempdir}/etc/systemd/system/set_pins.service <<-__EOF__
    [Unit]
    Description=Setup for BBB pins

    [Service]
    Type=simple
    ExecStart=/bin/bash /usr/local/src/set_pins.sh

    [Install]
    WantedBy=multi-user.target
  __EOF__

  sudo chroot "${tempdir}" systemctl start set_pins.service
  sudo chroot "${tempdir}" systemctl enable set_pins.service
}

enable_i2c1_on_startup
