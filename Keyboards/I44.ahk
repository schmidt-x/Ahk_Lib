#Include <RawHID\HidDevices>
#Include <RawHID\HidDevice>
#Include <Common\StopWatch>
#Include <Keyboards\HidConstants>

class I44 {
	static _vendorID  := 0xFEED
	static _productID := 0x0003
	
	static _usageID   := 0x61
	static _usagePage := 0xFF60
	
	/**
	 * @type {HidDeviceInfo}
	 */
	static _deviceInfo := unset
	
	static __New() {
		deviceInfo := HidDevices.Find(this._vendorID, this._productID, this._usageID, this._usagePage, &err)
		if err {
			throw err
		}
		
		this._deviceInfo := deviceInfo
	}
	
	static EnableAhk(&err) {
		this._NewDevice().Write([HID_AHK, 1], &err)
	}
	
	static DisableAhk(&err) {
		this._NewDevice().Write([HID_AHK, 0], &err)
	}
	
	/**
	 * Checks if a keyboard is resposive and measures the ReadWrite time by simply sending `HID_PING`
	 * output to the keyboard and waiting for the response.
	 * @param {&Integer} ms On success, the measured time (in milliseconds) is stored. -1 otherwise.
	 * @returns {Boolean} `True` if the keyboard is responsive. `False` if not or timed out.
	 */
	static Ping(&ms) {
		ms := -1
		
		sw := StopWatch()
		sw.Start()
		
		device := this._NewDevice()
		
		device.Open(&err)
		if err {
			return false
		}
		
		try {
			device.Write([HID_PING], &err)
			if err {
				return false
			}
			
			_ := device.Read(1000, &err)
			if err {
				return false
			}
		} finally {
			device.Close()
		}
		
		sw.Stop()
		
		ms := sw.ElapsedMilliseconds
		return true
	}
	
	
	static _NewDevice() => HidDevice(this._deviceInfo)
}