"""Install the whisper.beaglebone package."""
from setuptools import find_packages, setup

setup(
    name="whisper-beaglebone",
    version="0.0.1",
    zip_safe=False,
    package_dir={"": "."},
    packages=find_packages(),
    include_package_data=True,
    namespace_packages=["whisper"],
    entry_points={"console_scripts": []},
)
