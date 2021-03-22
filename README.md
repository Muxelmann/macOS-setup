# System Setup

These scripts will install all essential apps and tools that I want to use on my Mac and Raspberry Pi (RPi) computers.

Eventually, the scripts should be callable through:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Muxelmann/system-setup/main/macOS.sh)"
```

for my Mac and:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Muxelmann/system-setup/main/RPi.sh)"
```

for a RPi; a Yes/No wizard will query whether certain things should be set up on the RPi.


## Bug Fix

**Arduino** on macOS has an issue, where the COM-Ports cannot be written to with `esptool`. The fix seems to be as follows:

Open `~/Library/Arduino15/packages/esp8266/hardware/esp8266/2.7.4/tools/pyserial/serial/tools/list_ports_osx.py`.

Then comment out lines `29` and `30` and insert two lines below so it looks as follows<sup>1</sup>:

```
# iokit = ctypes.cdll.LoadLibrary(ctypes.util.find_library('IOKit'))
# cf = ctypes.cdll.LoadLibrary(ctypes.util.find_library('CoreFoundation'))
iokit = ctypes.cdll.LoadLibrary('/System/Library/Frameworks/IOKit.framework/IOKit')
cf = ctypes.cdll.LoadLibrary('/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation')
```

## Sources

1. [forum.arduino.cc](https://forum.arduino.cc/index.php?topic=702144.msg4793318#msg4793318), [github.com/pyserial](https://github.com/pyserial/pyserial/blob/master/serial/tools/list_ports_osx.py)