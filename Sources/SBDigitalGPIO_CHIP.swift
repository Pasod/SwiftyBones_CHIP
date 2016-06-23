                                          
#if arch(arm) && os(Linux)                
    import Glibc                          
#else                                     
    import Darwin                         
#endif                                    

/**                                       
 The list of available GPIO.              
 */                                       
var DigitalGPIOPins:[String: String] = [  
    "PWM0"     :"gpio34",                     
    "AP-EINT3" :"gpio35",                     
    "TWI1-SCK" :"gpio47",                     
    "TWI1-SDA" :"gpio48",                     
    "TWI2-SCK" :"gpio49",                     
    "TWI2-SDA" :"gpio50",                     
    "LCD-D2"   :"gpio98",                     
    "LCD-D3"	 :"gpio99",                     
    "LCD-D4"	 :"gpio100",                    
    "LCD-D5"	 :"gpio101",                    
    "LCD-D6"	 :"gpio102",                    
    "LCD-D7"	 :"gpio103",                    
    "LCD-D10"	 :"gpio106",                    
    "LCD-D11"	 :"gpio107",                    
    "LCD-D12"	 :"gpio108",                    
    "LCD-D13"	 :"gpio109",                    
    "LCD-D14"	 :"gpio110",                    
    "LCD-D15"	 :"gpio111",                    
    "LCD-D18"	 :"gpio114",                    
    "LCD-D19"	 :"gpio115",                    
    "LCD-D20"	 :"gpio116",                    
    "LCD-D21"	 :"gpio117",                    
    "LCD-D22"	 :"gpio118",                    
    "LCD-D23"	 :"gpio119",                    
    "LCD-CLK"	 :"gpio120",                    
    "LCD-DE"  :"gpio121",                    
    "LCD-HSYNC":"gpio122",                    
    "LCD-VSYNC":"gpio123",                    
    "CSIPCK"	 :"gpio128",                    
    "CSICK"	   :"gpio129",                    
    "CSIHSYNC" :"gpio130",                    
    "CSIVSYNC" :"gpio131",                    
    "CSID0"    :"gpio132",                    
    "CSID1"    :"gpio133",                    
    "CSID2"    :"gpio134",                    
    "CSID3"    :"gpio135",                    
    "CSID4"    :"gpio136",                    
    "CSID5"    :"gpio137",                    
    "CSID6"    :"gpio138",                    
    "CSID7"    :"gpio139",                    
    "AP-EINT1" :"gpio193",                    
    "UART1-TX" :"gpio195",                    
    "UART1-RX" :"gpio196",                    
    "XIO-P0"   :"gpio1016",                    
    "XIO-P1"   :"gpio1017",                    
    "XIO-P2"   :"gpio1018",                    
    "XIO-P3"   :"gpio1019",                    
    "XIO-P4"   :"gpio1020",                    
    "XIO-P5"   :"gpio1021",                    
    "XIO-P6"   :"gpio1022",                    
    "XIO-P7"   :"gpio1023"                     
]                                         
                                          
/**                                       
 Direction that pin can be configured for 
 */                                       
enum DigitalGPIODirection: String {       
    case IN="in"                          
    case OUT="out"                        
}                                         
                                          
/**                                       
 The value of the digitial GPIO pins      
 */                                       
enum DigitalGPIOValue: String {           
    case HIGH="1"                         
    case LOW="0"                          
}                                         
                                          
/**                                       
 Type that represents a GPIO pin on the Beaglebone Black
 */                                       
struct SBDigitalGPIO: GPIO {              
                                          
    /**                                   
     Variables and paths needed           
     */                                   
    private static let GPIO_BASE_PATH = "/sys/class/gpio/"
    private static let GPIO_EXPORT_PATH = GPIO_BASE_PATH + "export"
    private static let GPIO_DIRECTION_FILE = "/direction"
    private static let GPIO_VALUE_FILE = "/value"
                                          
    private var name: String                  
    private var id: String                
    private var direction: DigitalGPIODirection
                                          
    /**                                   
     Failable initiator which will fail if an invalid ID is entered
     - Parameter id:  The ID of the pin.  The ID starts with gpio and then contains the gpio number
     - Parameter direction:  The direction to configure the pin for
     */                                   
    init?(name: String, direction: DigitalGPIODirection) {
        if let id = DigitalGPIOPins[name] {
            self.id = id                      
            self.name = name           
            self.direction = direction    
            if !initPin() {               
                return nil                
            }                             
        } else {                          
            return nil                    
        }                                 
    }                                     
                                          
                 
                                          
    /**                                   
     This method configures the pin for Digital I/O
     - Returns:  true if the pin was successfully configured for digitial I/O
     */                                   
    func initPin() -> Bool {              
        let range = id.startIndex.advancedBy(4)..<id.endIndex.advancedBy(0)
        let gpioId = id[range]            
        let gpioSuccess = writeStringToFile(gpioId, path: SBDigitalGPIO.GPIO_EXPORT_PATH)
        let directionSuccess = writeStringToFile(direction.rawValue, path: getDirectionPath())
        if !gpioSuccess || !directionSuccess {
            return false                  
        }                                 
        return true                       
    }                                     
                                          
    /**                                   
     This function checks to see if the pin is configured for Digital I/O
     - Returns: true if the pin is already configured otherwise false
     */                                   
    func isPinActive() -> Bool {          
        if let _ = getValue() {           
            return true                   
        } else {                          
            return false                  
        }                                 
    }                                     
                                          
    /**                                   
     Gets the present value from the pin  
     - Returns:  returns the value for the pin eith .HIGH or .LOW
     */                                   
    func getValue() -> DigitalGPIOValue? {
        if let valueStr = readStringFromFile(getValuePath()) {
            return valueStr == DigitalGPIOValue.HIGH.rawValue ? DigitalGPIOValue.HIGH : DigitalGPIOValue.LOW
        } else {                          
            return nil                    
        }                                 
    }                                     
                                          
    /**                                   
     Sets the value for the pin           
     - Parameter value:  The value for the pin either .HIGH or .LOW
    */                                    
    func setValue(value: DigitalGPIOValue) -> Bool {
        return writeStringToFile(value.rawValue, path: getValuePath())
    }                                     
                                          
    /**                                   
     Determines the path to the file for this particular digital pin direction file
     - Returns:  Path to file             
     */                                   
    private func getDirectionPath() -> String {
        return SBDigitalGPIO.GPIO_BASE_PATH + id + SBDigitalGPIO.GPIO_DIRECTION_FILE
    }                                     
                                          
    /**                                   
     Determines the path to the file for this particular digital pin
     - Returns:  Path to file             
     */                                   
    private func getValuePath() -> String {
        return SBDigitalGPIO.GPIO_BASE_PATH + id + SBDigitalGPIO.GPIO_VALUE_FILE
    }                                     
}                                         
