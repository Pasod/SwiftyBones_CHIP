import Glibc

if let led = SBDigitalGPIO(name: "CSID0", direction: .OUT) {
	while(true) {
		if let oldValue = led.getValue() {
			print("Changing")
			var newValue = (oldValue == DigitalGPIOValue.HIGH) ? DigitalGPIOValue.LOW: DigitalGPIOValue.HIGH
			led.setValue(newValue)
			usleep(150000)
		}
	}
} else {
	print("error init pin")
}
