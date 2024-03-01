# Heartbeats-Counter
A heartbeats counter system composed of an ATmega328P microcontroller, a heartbeat sensor and an LCD display. The code is written in assembly language.
For reference, this is the link to datasheet of the ATmega328P from the official website: https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf
A PNG file is also attached in this reposotry to show the connections between the components in proteus if there was any issue encountered when opening the proteus file which is also attached here.
The library of the sensor used inside the proteus and the steps to download it are availabe at this link: https://www.theengineeringprojects.com/2017/11/heart-beat-sensor-library-v2-0-for-proteus.html
After connecting the components inside Proteus, all you have to do is to compile the .asm file in a compatible environment (Microchip Studio) and place the .hex file in proteus after clicking on the microcontroller inside the "Program File" section.
