//
//  SharedNetworking.m
//  dis
//
//  Created by Robert Smith on 13/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 This shared networking file was created to reduce the amount of code that would need to be edited
 when changing the networking files and also to create some clarity with regards to ControlViewController and SetupDevicesViewControllers DeviceTableViewController
 since these files were getting too large.
 
 Putting the networking files in a centralised place essentially halfed the amount of networking code needed for the application.
 
 This file is split into 11 main sections:
 
 -1		initialising
 -2		createDatabaseFromFile
 -3		initialisingConnection
 -4		requestAvailableDevices
 -5		socketDidReadData
 -6		processArray
 -7		getTimeStamp
 -8		performType0DataSendWithSN
 -9		performType0DataUpdateWithSN
 -10	performType1DataSendWithSN
 -11	performType2DataSendWithSN
 
 type0-2 are a catorisation of the devices that I devised to simplify the process of communication
 type 0 = i/o device such as light
 type 1 = sensor device such as thermometer
 type 2 = ranged i/o device such as radiator
 
 This file takes advantage of the superb GCDAsyncSocket library which was developed by Robbie Hanson, see the GCDAsyncSocket header file for more information.
 
 
 */


#import "SharedNetworking.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DevicesManager.h"

//easy access way to change the IP and port used to connect to adapter
#define kIPADDR		@"192.168.0.146"
#define kPORT		2101

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation SharedNetworking

- (id)initWithDelegate:(id)aDelegate{
	if(self = [super init])
	{	
		delegate = aDelegate;
		//init with delegate is called by CVC or SDVC and sets itself as delegate
		// Execute the "checkAndCreateDatabase" function
		[self createDatabaseFromFile];
		[self initConnection];
		[self requestAvailableDevices];
	}
	return self;
}

- (void) createDatabaseFromFile{	
	// creates the database file on load from the sql file in the project folder- this means easy updating
	// Get the path to the documents directory and append the databaseName
	databaseName = @"deviceDatabase.sql";
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
}

- (void)initConnection{
	//creates connection to the adapter
	//NSLog(@"init connection");

    [DDLog removeAllLoggers];
    if(!asyncSocket){
        NSLog(@"no socket --> creating one");
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    if([asyncSocket isDisconnected]){
        NSError *error = nil;
        NSString *host = kIPADDR;
        uint16_t port = kPORT; 
		
        if (![asyncSocket connectToHost:host onPort:port error:&error])
        {
            DDLogError(@"Unable to connect to due to invalid configuration: %@", error);
        }
        else
        {
            DDLogVerbose(@"Connecting to \"%@\" on port %hu...", host, port);
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
	//logs connection to adapter in console
	DDLogVerbose(@"socket:didConnectToHost:%@ port:%hu", host, port);
}

- (void)requestAvailableDevices{
	//this command is very simple and won't change
	//it requests connected devices on the adapter
	Byte bytes[4] = {2,10,8,13};
    NSData* data = [NSData dataWithBytes:bytes length:sizeof (bytes)];
    [asyncSocket writeData:data withTimeout:-1.0 tag:0];
	DDLogVerbose(@"Sending Request:\n%@", data);
	[asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
	
	//responsible for handling the communication to and from the adapter
	//it detects the command::start as the first and command::out as the last
	//it strips these values and stores the actual data in an array called receivedArray
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *eol = @"command::out";
	
	//we trim the response then output
	response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    DDLogInfo(@"R:%@", response);
	
	if(!receivedArray) receivedArray = [[NSMutableArray alloc] init];
    
	if ([response isEqualToString:eol]){ //last rec
		DDLogInfo(@"end");
        //last peice of info recieved
        [self processArray:tag];
	}else if([response isEqualToString:@"command::start"]){
        [asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:-1.0 tag:0];
    }else {
        [receivedArray addObject:response]; 
		// Read the next line of the header
		[asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:-1.0 tag:0];
	}
	
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
	// causes a log when the adapter disconnects in error
	DDLogVerbose(@"socketDidDisconnect:withError: \"%@\"", err);
	//[self initConnection];
}

- (void)processArray:(float)tag{

	//here we handle all received data.
    
    if([[receivedArray objectAtIndex:1] intValue] == 11){
		//TYPE 11 is response from adapter listing availble devices
		
		// Setup the database object
		sqlite3 *database;
		// Init the Array
		NSMutableArray *deviceID = [[NSMutableArray alloc] init];
		NSMutableArray *deviceName = [[NSMutableArray alloc] init];
		NSMutableArray *deviceImg = [[NSMutableArray alloc] init];
		NSMutableArray *deviceSN = [[NSMutableArray alloc] init];
		NSMutableArray *deviceZone = [[NSMutableArray alloc]init];
		NSMutableArray *deviceType = [[NSMutableArray alloc]init];

		// Open the database from the users filessytem

        for(int i=3;i<[receivedArray count]-1;i=i+2){
            
			//we will do db lookup to determine which devices have been found.
			//returning name,imgname,sn,zn,devtype
			//we organise this based on what is found, which comprises of servicename (id) and zone
			
			
			if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
				// Setup the SQL Statement and compile it for faster access
				
				int serviceName = [[receivedArray objectAtIndex:i]intValue];
				int zone = [[receivedArray objectAtIndex:i+1]intValue];
				
				NSString *statmentSQL = [NSString stringWithFormat: @"SELECT id,DevName,imgName,devType FROM deviceTable WHERE serviceName = %i AND zone = %i", serviceName, zone];
				const char *sqlStatement = [statmentSQL UTF8String];
				
				sqlite3_stmt *compiledStatement;
				if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
					// Loop through the results and add them to the feeds array
					while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
						// Read the data from the result row
						NSNumber *aID = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)];
						NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
						NSString *aImgName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
						NSNumber *aDevType = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 3)];
						NSNumber *aServiceName = [NSNumber numberWithInt:serviceName];
						NSNumber *aZone = [NSNumber	numberWithInt:zone];
						
						//add the found values to array
						[deviceID addObject:aID];
						[deviceName addObject:aName];
						[deviceImg addObject:aImgName];
						[deviceSN addObject:aServiceName];
						[deviceZone addObject:aZone];
						[deviceType addObject:aDevType];
						
					}
				}
				// Release the compiled statement from memory
				sqlite3_finalize(compiledStatement);
				sqlite3_close(database);
			}
		}
		
		NSLog(@"id:%@", deviceID);
		NSLog(@"devices:%@", deviceName);
		NSLog(@"imgname:%@", deviceImg);	
		NSLog(@"devT:%@", deviceType);
		
		[delegate networkResponseDevID:deviceID andDevName:deviceName andDevImg:deviceImg andServiceName:deviceSN andZone:deviceZone andDevType:deviceType];
		
  }    
	
	else if([[receivedArray objectAtIndex:1] intValue] == 13 || [[receivedArray objectAtIndex:1] intValue] == 15){
		//TYPE 13 & 15 are updates received from device
		//we must process this data then send meaningful results back to the vc
		
		
		DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
		deviceArray = [sharedDevicesManager deviceObjectsArray];
		
		//declare variables up here because obj-c is problematic about declarations inside switches
		NSString *str = [[NSString alloc]init];
		NSString *timestamp = [self getTimeStamp];
		
		NSNumber* serviceName;
		NSNumber* zone;
		
		int tagInt = tagNum;
		int byteHigh;
		int byteLow;
		int batteryLevel;
		int temp;
		int lightlvl;
		int humid;
		NSString* batteryStr = @"";
		
		
		switch([[receivedArray objectAtIndex:2] intValue]){
				
			case 162: //jennic sensor
				
				
				//get battery levels
				byteHigh = [[receivedArray objectAtIndex:6]intValue];
				byteLow = [[receivedArray objectAtIndex:7] intValue];
				batteryLevel = 0;
				batteryLevel = batteryLevel << 8;
				batteryLevel = batteryLevel | byteHigh;
				batteryLevel = batteryLevel << 8;
				batteryLevel = batteryLevel | byteLow;
				
				
				
				int powerPercentage = 100;
				int batt = batteryLevel;
				float batteryFloat = 0.0;
				
					if(batt >= 2000 && batt<3000){
						powerPercentage = (batt-2000)*100/1000;
					}else if(batt < 2000)
					{
						powerPercentage=-1;
					}
					
					if(powerPercentage >=0)
					{	batteryStr = [NSString stringWithFormat:@"%i%%",powerPercentage];
						batteryFloat = (float)((float)powerPercentage/100);
					}else{
						batteryStr = [NSString stringWithFormat:@"Error"];
					}
				[delegate networkUpdateWithBatteryValue:batteryStr andBatteryFloat:batteryFloat];
				//send battery data to delegate
				
				
				//temp
				temp = [[receivedArray objectAtIndex:4] intValue];
				humid = [[receivedArray objectAtIndex:5] intValue];
				lightlvl = [[receivedArray objectAtIndex:3] intValue];
				

				if ([[deviceArray objectAtIndex:tagInt] respondsToSelector:@selector(isDevice)]) {
					NSLog(@"TAG=====%i",tagInt);
					
					serviceName = [[deviceArray objectAtIndex:tagInt] performSelector: @selector(returnServiceName)];
					zone = [[deviceArray objectAtIndex:tagInt] performSelector: @selector(returnZone)];
	
					
					
					if([serviceName intValue] == 1){
						//if SN = 1 its themometer
						str = [NSString stringWithFormat:@"%i°C",temp];
						[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addNotification:) withObject:str];	
						NSNumber* val = [NSNumber numberWithInt:temp];
						[delegate networkUpdateToTriggerWithVal:val andSensorSN:serviceName	andSensorZone:zone];
						
						//add to db
						NSString *content = [NSString stringWithFormat:@"name=%@&sensorvalue=%i&sn=%i&zn=%i", @"Thermometer", temp, [serviceName intValue], [zone intValue]];
						NSLog(@"%@", content);
						NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://co-project.lboro.ac.uk/users/cors2/FYP/addsensor.php"]];
						[request setHTTPMethod:@"POST"];
						[request setHTTPBody:[content dataUsingEncoding:NSISOLatin1StringEncoding]];
						[NSURLConnection connectionWithRequest:request delegate:self];
						
					} else if([serviceName intValue] == 3){
						//if SN=3 its humidity
						str = [NSString stringWithFormat:@"%i%%",humid];
						[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addNotification:) withObject:str];
						NSNumber* val = [NSNumber numberWithInt:humid];
						[delegate networkUpdateToTriggerWithVal:val andSensorSN:serviceName	andSensorZone:zone];
						
						//add to db
						NSString *content = [NSString stringWithFormat:@"name=%@&sensorvalue=%i&sn=%i&zn=%i", @"Humidity", humid, [serviceName intValue], [zone intValue]];
						NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://co-project.lboro.ac.uk/users/cors2/FYP/addsensor.php"]];
						[request setHTTPMethod:@"POST"];
						[request setHTTPBody:[content dataUsingEncoding:NSISOLatin1StringEncoding]];
						[NSURLConnection connectionWithRequest:request delegate:self];
						
					} else if([serviceName intValue] == 4){
						//if SN=4 its light levels
						str = [NSString stringWithFormat:@"%i/6",lightlvl];
						[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addNotification:) withObject:str];
						NSNumber* val = [NSNumber numberWithInt:lightlvl];
						[delegate networkUpdateToTriggerWithVal:val andSensorSN:serviceName	andSensorZone:zone];
						
						//add to db
						NSString *content = [NSString stringWithFormat:@"name=%@&sensorvalue=%i&sn=%i&zn=%i", @"Light Level", lightlvl, [serviceName intValue], [zone intValue]];
						NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://co-project.lboro.ac.uk/users/cors2/FYP/addsensor.php"]];
						[request setHTTPMethod:@"POST"];
						[request setHTTPBody:[content dataUsingEncoding:NSISOLatin1StringEncoding]];
						[NSURLConnection connectionWithRequest:request delegate:self];
					}
					
					//adds notification to correct device object
					
					[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addTimeStamp:) withObject:timestamp];
					[delegate networkUpdateWithDataValue:str forDeviceIndex:tagInt];
					
					//we save the notifications to disk now so that there are persistant
					[sharedDevicesManager saveSettingsToDisk];
					
				
				}
				
	
				break;
				
			case 169: //CO sensor
				break;
				
			case 137: //light status
				//switches don't like declarations at start 
				NSLog(@"Light info recieved"); //required :/
				float kwh = 0.6;
				bool boolstatus = 1;

				
				if ([[deviceArray objectAtIndex:tagInt] respondsToSelector:@selector(isDevice)]) {
					NSLog(@"TAG=====%i",tagInt);
					
					
					serviceName = [[deviceArray objectAtIndex:tagInt] performSelector: @selector(returnServiceName)];
					zone = [[deviceArray objectAtIndex:tagInt] performSelector: @selector(returnZone)];
								
					if([[receivedArray objectAtIndex:5]intValue] == 1){
						str = @"On";
					
					}else {
						str = @"Off";
						boolstatus = 0;
					}
					
					//SEND VARS TO DB FOR ENERGY LOGGING
					//USES POST to send values to php script
					NSString *content = [NSString stringWithFormat:@"name=%@&status=%i&kwh=%f&sn=%i&zn=%i", @"Light", boolstatus, kwh, [serviceName intValue], [zone intValue]];
					NSLog(@"%@", content);
					
					NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://co-project.lboro.ac.uk/users/cors2/FYP/add.php"]];
					[request setHTTPMethod:@"POST"];
					[request setHTTPBody:[content dataUsingEncoding:NSISOLatin1StringEncoding]];
					
					// generates an autoreleased NSURLConnection
					[NSURLConnection connectionWithRequest:request delegate:self];

					int type = [[self returnDevTypeOfDeviceWithSN:serviceName andZone:zone] intValue];
					
					if(type == 0){ //ensures we are only saving light devices- fixes trigger bug p1
					//adds notification to correct device object
						NSLog(@"type:%i", type);
						[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addNotification:) withObject:str];
						[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addTimeStamp:) withObject:timestamp];
						[delegate networkUpdateWithDataValue:str forDeviceIndex:tagInt];
					
						//we save the notifications to disk now so that there are persistant
					[sharedDevicesManager saveSettingsToDisk];
					} else if(type == 1){
						//wrong tagint get real for 8,1
						int testZN = [[receivedArray objectAtIndex:3]intValue];
						int testSN = [[receivedArray objectAtIndex:4]intValue];
						int aSN;
						int aZN;
						
						for(int t = 0; t<[deviceArray count]; t++){
				
							aSN = [[[deviceArray objectAtIndex:t] performSelector: @selector(returnServiceName)]intValue];
							aZN = [[[deviceArray objectAtIndex:t] performSelector: @selector(returnZone)] intValue];
							
							if((aSN == testSN) && (aZN == testZN)){
								tagInt = t;
								NSLog(@"match");
								[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addNotification:) withObject:str];
								[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addTimeStamp:) withObject:timestamp];
								//update just map img.
								[delegate triggerNetworkUpdateWithDataValue:str forDeviceIndex:tagInt];
								
								break;
							}
							
							
						}
						
						
					}
				}

				
				break;
				
			case 173: //valve response
				break;
				
			case 172: //power meter data
				
				NSLog(@"Power meter recieved info");
				
				int voltage = 0;
				int current=0;
				
				//works out voltage
				int voltage1=[[receivedArray objectAtIndex:3]intValue];
				int voltage2=[[receivedArray objectAtIndex:4]intValue];
				int voltage3=[[receivedArray objectAtIndex:5]intValue];
				int voltage4=[[receivedArray objectAtIndex:6]intValue];
				voltage  = voltage << 8;
				voltage  = voltage | voltage4;
				voltage  = voltage << 8;
				voltage  = voltage | voltage3;
				voltage  = voltage << 8;
				voltage  = voltage | voltage2;
				voltage  = voltage << 8;
				voltage  = voltage | voltage1;
				
				//works out current
				int current1 = [[receivedArray objectAtIndex:7]intValue];
				int current2 = [[receivedArray objectAtIndex:8]intValue];
				int current3 = [[receivedArray objectAtIndex:9]intValue];
				int current4 = [[receivedArray objectAtIndex:10]intValue];
				current = current << 8;
				current = current | current4;
				current = current << 8;
				current = current | current3;
				current = current << 8;
				current = current | current2;
				current = current << 8;
				current = current | current1;
				
				current = abs(current);
				
				NSLog(@"VOLTAGE:%i", voltage);
				NSLog(@"CURRENT:%i", current);	
								
				str = [NSString stringWithFormat:@"Volt:%i, Curr:%i", voltage, current];
				
				[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addNotification:) withObject:str];
				[[deviceArray objectAtIndex:tagInt] performSelector:@selector(addTimeStamp:) withObject:timestamp];
				
				[delegate networkUpdateWithDataValue:str forDeviceIndex:tagInt];
				
				//we save the notifications to disk now so that there are persistant
				[sharedDevicesManager saveSettingsToDisk];
				
				break;
				
				
			default: break;
				
				
		}
			
	}
	
    [receivedArray removeAllObjects];
}

-(NSString*) getTimeStamp{
	//returns a timestamp in the form
	//dayofweek hours:minutes
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"E HH:mm"];	
	return [format stringFromDate:[NSDate date]];
}

- (void)disconnect{
	//disconnect from adapter
	receivedArray=nil;
    [asyncSocket setDelegate:nil];
    [asyncSocket disconnect];
    asyncSocket=nil;	
}

-(NSNumber *)returnDevTypeOfDeviceWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone{
	
	sqlite3 *database;
	NSNumber *aDevType = [[NSNumber alloc]init];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		
		
		NSString *statmentSQL = [NSString stringWithFormat: @"SELECT devType FROM deviceTable WHERE serviceName = %@ AND zone = %@", serviceName, zone];
		const char *sqlStatement = [statmentSQL UTF8String];
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				//aDevType = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)];
				aDevType = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)];
				
			}	
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		sqlite3_close(database);
	}
	
	return aDevType;
	
}


-(void)performType0DataSendWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andSetStatus:(bool)status andBtnId:(int)btnid{
	
	//type 0 is i/o such as light
	//we here send it data by supplying SN and ZN with a status of what we want 0/1
	//we use the sqlite database to lookup the needed network values for this
	//the btnid is the where we want the data to return to
	
	tagNum = btnid;
	sqlite3 *database;
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		
		int pSize;
		int pMsgType;
		int pCmdName;
		int pInstr;
		bool result = 0;
		
		NSString* statusStr = @"instrOn";
		if(!status) {
			statusStr = @"instrOff";
		}

		NSString *statmentSQL = [NSString stringWithFormat: @"SELECT pSize,msgType,cmdName,%@ FROM deviceTable WHERE serviceName = %i AND zone = %i", statusStr, [serviceName intValue], [zone intValue]];
		const char *sqlStatement = [statmentSQL UTF8String];
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				result = 1;
				pSize = sqlite3_column_int(compiledStatement, 0);
				pMsgType = sqlite3_column_int(compiledStatement, 1);
				pCmdName = sqlite3_column_int(compiledStatement, 2);
				pInstr = sqlite3_column_int(compiledStatement, 3);

			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		sqlite3_close(database);
		
		//{6,14,1,8,1,ON/OFF inst,-102,13};
		if(result){
		
				Byte bytes[8] =	{(1+pSize),
								pMsgType,
								pCmdName,
								[serviceName intValue],
								[zone intValue],
								pInstr,
								-102,
								13};
			
				
			 
			NSData* data = [NSData dataWithBytes:bytes length:sizeof (bytes)];
			[asyncSocket writeData:data withTimeout:-1.0 tag:0];
			NSLog(@"Sending Request:%@", data);  
			[asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:-1.0 tag:0];
			
		}
		
	}

					
}

-(void)performType0DataUpdateWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andBtnId:(int)btnid{
	
	//this function is similar to the above but it doesn't supply an instruction to set status
	//rather it is requesting the current status of the light
	
	tagNum = btnid;
	
		//		Byte bytes[7] = {5,12,2, y, x, 14,13};
		
			
			Byte bytes[7] =	{(5),
				12,
				2,
				[serviceName intValue],
				[zone intValue],
				-102,
				13};
			
			
			NSData* data = [NSData dataWithBytes:bytes length:sizeof (bytes)];
			[asyncSocket writeData:data withTimeout:-1.0 tag:0];
			NSLog(@"Sending Request:%@", data);  
			[asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:-1.0 tag:0];
		
	
}

-(void)performType1DataSendWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andBtnId:(int)btnid{
	
	//type 1 devices are those such as thermometers which only return a value
	//this function simply requests the current readings based on only SN&ZN and will
	//report that value back to a btnID
	
	tagNum = btnid;
	
	sqlite3 *database;
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		
		int pSize;
		int pMsgType;
		int pCmdName;
		bool result = 0;
			
		
		NSString *statmentSQL = [NSString stringWithFormat: @"SELECT pSize,msgType,cmdName FROM deviceTable WHERE serviceName = %i AND zone = %i", [serviceName intValue], [zone intValue]];
		const char *sqlStatement = [statmentSQL UTF8String];
		
		
		NSLog(@"SQL statement:%@", statmentSQL);
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				result = 1;
				pSize = sqlite3_column_int(compiledStatement, 0);
				pMsgType = sqlite3_column_int(compiledStatement, 1);
				pCmdName = sqlite3_column_int(compiledStatement, 2);	
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		sqlite3_close(database);
		
		
//		Byte bytes[7] = {5,12,2, y, x, 14,13};

		if(result){
			
			Byte bytes[7] =	{(1+pSize),
				pMsgType,
				pCmdName,
				[serviceName intValue],
				[zone intValue],
				-102,
				13};
			
			
			NSData* data = [NSData dataWithBytes:bytes length:sizeof (bytes)];
			[asyncSocket writeData:data withTimeout:-1.0 tag:0];
			NSLog(@"Sending Request:\n%@", data);  
			[asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:-1.0 tag:0];
		}
		
	}

	
	
}

-(void)performType2DataSendWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andSetStatus:(NSNumber *)value andBtnId:(int)btnid{
	
	tagNum = btnid;
	//for the radiator
	//this would work the same as performType0DataSendWithSN... but since I don't have this device
	//I'm unable to complete. It is included for completeness.
	//lookup val in DB and check val is between min & max (instOn and instOff)
	
}



@end
