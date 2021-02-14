# Console
This can be used as a replacement to windows crt unit.

## Difference

### ReadKey function
Its return value is determined by the following virtual key code list:  
https://docs.microsoft.com/en-gb/windows/win32/inputdev/virtual-key-codes  

> Tips: You can use $0D to represent the value 0x0D in Pascal.

Also, It will return only the key being pressed (key release event), meaning that distinguishing between typing a capital or lowercase letter is impossible with this function.