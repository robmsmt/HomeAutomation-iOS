//
//  HouseView.m
//  dis
//
//  Created by Robert Smith on 18/03/2012.
//

// This view is responsible for handling the user input when drawing the house shape only
// it connects only to the SetupHouseViewController which can communicate with the view
// through the public methods, the view can communicate to the VC via the protocol defined
// delegate. The view only has 1 peice of information to tell the VC and that is when a user has 
// finished drawing thus providing the VC with a fromPoint and toPoint.

#import "HouseView.h"
#import "HouseManager.h"

@implementation HouseView

@synthesize delegate = _delegate;

//define the constants needed in our program
const int step = 50; // Grid step size.
const int dash = 2;
const int startx = 150; //First x
const int starty = 100; //First y


-(id)initWithCoder:(NSCoder *)aDecoder {
    //called when init
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupVariables];
		[self setupBuffer];
		[self setupGrid];
    }
    
    return self;
}

-(void)reloadHousePoints{
	//invoked by VC when it detects points have changed
	HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    wallArray = [sharedHouseManager getHousePoints];
    [self rebuildContextImg];
    [self setNeedsDisplay];
	
}

-(void)resetAllClearButtonPressed{
	//invoked when reset button pressed
	[self setupVariables];
	[self reloadHousePoints];
}


-(void)setupVariables {
	// a simple method to setup our variables usually run at the start or on reset
    beginTouch = 0;
    beginTouchPoint.x = startx;
    beginTouchPoint.y = starty;
    toPoint.x = 0;
    toPoint.y = 0;
    fromPoint.x = 0;
    fromPoint.y = 0;
}


-(void)setupBuffer {
	
	/* this method sets up the offScreenBuffer which is a context defined as an instance variable
	 this method is vital as it allows us to draw very fast offscreen then
	 output this to the screen in drawRect */
	
	CGSize size = {1024, 704}; //sets the size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); //defines the colourspace
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast); //creates the context
    CGColorSpaceRelease(colorSpace); //releases colourspace
    CGContextTranslateCTM(context, 0, size.height); 
    CGContextScaleCTM(context, 1.0, -1.0); //these two lines ensure the translation is correct
										   //without these the mapping would be back to front
	offScreenBuffer = context; //we finally assign the newly created context to our instance variable
}


-(void)setupGrid{
	/*
	 setupGrid draws the grid onto the offScreenBuffer
	 it does this by using a line dash and the const values defined at the top of the page
	 since the default step distance is 50 and dash is 2 we create a 2px white dash
	 followed by 48px gap.
	 */
    CGContextSaveGState(offScreenBuffer);
    CGContextSetLineWidth(offScreenBuffer,2);
    CGColorRef col = [UIColor grayColor].CGColor;
    CGContextSetStrokeColorWithColor(offScreenBuffer, col);
    int p = step-dash;
    CGFloat dashArray[] = {dash,p};
    CGContextSetLineDash(offScreenBuffer, 0, dashArray, 2);
    CGContextMoveToPoint(offScreenBuffer,0 , 0);
    
    for(int y=step;y<self.bounds.size.height;y=y+step){
        CGContextMoveToPoint(offScreenBuffer, step, y);
        CGContextAddLineToPoint(offScreenBuffer, self.bounds.size.width, y);
    }
    CGContextStrokePath(offScreenBuffer);
    CGContextRestoreGState(offScreenBuffer);
    [self drawStartCircle:(startx):(starty)];
}

-(void)drawStartCircle:(NSInteger)x:(NSInteger)y{
	//this method draws the original white start circle at the start point
	CGContextSaveGState(offScreenBuffer);
    CGContextSetLineWidth(offScreenBuffer,5);
    CGColorRef col = [UIColor blackColor].CGColor;
    CGContextSetStrokeColorWithColor(offScreenBuffer, col);
    CGRect rectangle = CGRectMake(x-4,y-4,8,8);
    CGContextAddEllipseInRect(offScreenBuffer, rectangle);
    CGContextFillPath(offScreenBuffer);
    
    CGColorRef col2 = [UIColor whiteColor].CGColor;
    CGContextSetStrokeColorWithColor(offScreenBuffer, col2);
    CGRect rectangle2 = CGRectMake(x-4,y-4,10,10);
    CGContextAddEllipseInRect(offScreenBuffer, rectangle2);
    CGContextStrokePath(offScreenBuffer);
	CGContextRestoreGState(offScreenBuffer);
}

-(void)rebuildContextImg {
    
    //rebuild context image releases old buffer and creates new one
	//we then setup grid and draw existing walls.
    CGContextRelease(offScreenBuffer);
    [self setupBuffer];
    [self setupGrid];
    CGContextSaveGState(offScreenBuffer);
	
    //load points from array
    for(int i=0; i<[wallArray count]; i=i+2){
		NSValue *val1 = [wallArray objectAtIndex:i];
        NSValue *val2 = [wallArray objectAtIndex:i+1];
        CGPoint recFromPoint = [val1 CGPointValue];
        CGPoint recToPoint = [val2 CGPointValue];
        
        CGContextSetLineWidth(offScreenBuffer,10);
        CGColorRef col = [UIColor redColor].CGColor;
        CGContextSetStrokeColorWithColor(offScreenBuffer, col);
        CGFloat dashArray[] = {2,1};
        CGContextSetLineDash(offScreenBuffer, 0, dashArray, 2);
        CGContextMoveToPoint(offScreenBuffer,recFromPoint.x , recFromPoint.y);
        CGContextAddLineToPoint(offScreenBuffer, recToPoint.x, recToPoint.y);
        CGContextStrokePath(offScreenBuffer);
    }
    CGContextRestoreGState(offScreenBuffer);
	
}

-(void)drawRect:(CGRect)rect{
	/*draw rect is responsible for the drawing of a UIVIEW
	it is invoked by calling setNeedsDisplay
	first thing this method does is create an image based on the offscreenbuffer
	the next task is draw on the line based on the from and to points
	*/ 
	
	//create image from offscreenbuffer
    CGImageRef cgImage = CGBitmapContextCreateImage(offScreenBuffer);
    uiImage1 = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    [uiImage1 drawInRect:self.bounds]; //draw image to view
    
	//draw current line
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
    CGContextSetLineWidth(context,10);
    CGColorRef col = [UIColor whiteColor].CGColor;
    CGContextSetStrokeColorWithColor(context, col);
    CGFloat dashArray[] = {2,1};
    CGContextSetLineDash(context, 0, dashArray, 2);
    CGContextMoveToPoint(context,fromPoint.x , fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
	CGContextStrokePath(context);
	
	if(fromPoint.x != 0 && fromPoint.y != 0){ //only draw if not at starting position
		//draw black eol dot
		CGContextSetLineWidth(context,6);
		col = [UIColor blackColor].CGColor;
		CGContextSetStrokeColorWithColor(context, col);
		CGRect rectangle = CGRectMake(toPoint.x-6,toPoint.y-6,12,12);
		CGContextAddEllipseInRect(context, rectangle);
		CGContextFillPath(context);
		//green eol dot
		CGContextRestoreGState(context);
		CGContextSetLineWidth(context,10);
		col = [UIColor greenColor].CGColor;
		CGContextSetStrokeColorWithColor(context, col);
		CGRect rectangle2 = CGRectMake(toPoint.x-7,toPoint.y-7,15,15);
		CGContextAddEllipseInRect(context, rectangle2);
		CGContextStrokePath(context);
	}
	
}

-(bool)isPointWithinRange:(CGPoint)point{
	/* isPointWithinRange tests a point to see if it is 
		within 49 points of the dot, if it is it will return yes
	*/
	int maxX = beginTouchPoint.x+(step-1);
	int minX = beginTouchPoint.x-(step-1);
	int maxY = beginTouchPoint.y+(step-1);
	int minY = beginTouchPoint.y-(step-1);
	
	if(point.x > minX && point.x < maxX){
		if(point.y > minY && point.y < maxY){
			return 1;
		}
	}
	return 0;
}

-(bool)isPointNearExistingWall:(CGPoint)point{
	//example for documentation
	/*
	//attempt at stopping line crossing over itself
	//this is currently unused it does slightly work but
	//has too many bugs to be used right now
	
	 //add this to touches moved
	 //trying to stop line cross over itself
	 //		if([self isPointNearExistingWall:toPoint]){
	 //			toPoint = beginTouchPoint;
	 //		}else{
	 //			beginTouchPoint=point;
	 //		}
	
    CGPoint points[[wallArray count]];
    for(int i=0; i<[wallArray count]; i++){
        NSValue *val1 = [wallArray objectAtIndex:i];
        CGPoint recFromPoint = [val1 CGPointValue];
        points[i]=recFromPoint;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines (path, NULL, points, [wallArray count]);
    CGContextAddPath(offScreenBuffer, path);
    CGPathRelease(path);
    
    if(CGContextPathContainsPoint(offScreenBuffer,point,kCGPathFillStroke)){
        return true;
    }
    */
    return false;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	/* touchesBegan is called when the user touches the screen anywhere
		we take the point and test if it is in range of the needed point
	 
		if it is then we turn beginTouch ON and set the points and then
		force the screen to update itself
	*/
	CGPoint point = [[touches anyObject] locationInView:self];
	if([self isPointWithinRange:point]){
		beginTouch = 1;  
		toPoint	= beginTouchPoint;
		fromPoint = beginTouchPoint;
		[self rebuildContextImg];
		[self setNeedsDisplay];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (beginTouch){
		//if started properly (in beginTouch) this will allow us to track
		//the movements of the finger and update the display accordingly
    CGPoint point = [[touches anyObject] locationInView:self];
        point.x = step * floor((point.x / step) );
        point.y = step * floor((point.y / step) );   
		toPoint = point;
		[self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	//this is called when a touch event ends, we are only interested in the ones
	//which have been started properly by beginTouch
	//we take the end point and send the data to the viewcontroller
	//then refresh screen and reset beginTouch to 0.
    if(beginTouch){
        CGPoint point = [[touches anyObject] locationInView:self];
        point.x = step * floor((point.x / step) );
        point.y = step * floor((point.y / step) );   
		
        toPoint = point;
        [_delegate wallSetStart:fromPoint andSetFinish:toPoint];

        [self setNeedsDisplay];
        beginTouchPoint = toPoint;
        beginTouch = 0;
		
    }
}

-(void)completeHouseShape{
	//is called by VC when it detects a completed house shape
	//by creating a method we have power to do additional tasks with the view in the future
	[self fillShape];
}

-(void)fillShape{
    //this is called by completeHouseShape, when the VC detects a whole shape
	//we create a path using the house points and fill the path
    CGPoint points[[wallArray count]];
    
    for(int i=0; i<[wallArray count]; i++){
        NSValue *val1 = [wallArray objectAtIndex:i];
        CGPoint recFromPoint = [val1 CGPointValue];
        points[i]=recFromPoint;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines (path, NULL, points, [wallArray count]);
    CGContextAddPath(offScreenBuffer, path);
    CGPathRelease(path);
    CGContextFillPath(offScreenBuffer);
    [self setNeedsDisplay];
    
}

-(void)dealloc{
	//called when deallocating, here we release everything as it should no longer be needed
	_delegate = nil;
    beginTouch = nil;
    uiImage1 = nil;
    wallArray = nil;
    CGContextRelease(offScreenBuffer);
	offScreenBuffer = nil;
}


@end
