# HomeAutomation-iOS

##What is it?
A home automation iOS App that works in conjunction with ZigBee home automation devices. It is a custom implementation that uses quartz2D to draw out a user interface of the house and control the devices inside.

##What version does this work on?
 - This was tested on iOS 5.1 on an iPad2 - no reason why this wouldn't work on later versions.

##What can it do?
 - Intuitively draw a birds eye view of house interface, including rooms and multiple floors
 - Place and easily move devices anywhere in house
 - Control many ZigBee lights and radiator devices and use information from light, tempurature and humidity sensors
 - Use time or sensor triggers for ITTT style programming
 - Display energy usage and graphing capability (see [HomeAutomation-SERVER](https://github.com/rmsmith88/HomeAutomation-SERVER) repo)

##What software or libraries does it use?
 - Apple Framework – UIKit, Foundation, CoreGraphics and libsqlite3.
 - GCDAsyncSocket – [https://github.com/robbiehanson/CocoaAsyncSocket](iOS Networking library) 

##How do I use it?
 1. Load the Xcode library and run in a simulator to get a feel of how the application works. It has been designed to be intuitative to use and should guide the user through the setup wizard. Sample devices are shown even if you do not have ZigBee devices to control.

##Screenshot examples

###Setup1 - Designing your house
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/setup1.PNG)

###Setup2 - Adding your floors
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/setup2.PNG)

###Setup3 - Adding rooms
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/setup3.PNG)
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/setup4.PNG)
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/setup5.PNG)

###Setup6 - Adding Devices
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/setup6.PNG)

###Control1 - The interface
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/control.PNG)

###Control2 - Clicking on a device
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/control2.PNG)
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/control3.PNG)
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/control4.PNG)

###Advanced1 - ITTT style control
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/zADV.PNG)
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/zADV2.PNG)

###Advanced2 - Displaying energy usage graphs
![alt tag](https://raw.githubusercontent.com/rmsmith88/HomeAutomation-iOS/master/img/zADV3.PNG)


