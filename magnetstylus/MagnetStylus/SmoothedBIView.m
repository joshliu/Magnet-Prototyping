#import "SmoothedBIView.h"
#import "Magnet.h"
#import "CalibrationView.h"

@interface SmoothedBIView () <MagnetDelegate, CalibrationDelegate>

@property (strong, nonatomic) Magnet *magnet;
@property (strong, nonatomic) CalibrationView *calibrationView;
@property (strong, nonatomic) UIView *cursorView;
@property UILabel *x;
@property UILabel *y;
@property UILabel *mag;
@property UILabel *angle;

@end

@implementation SmoothedBIView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
    NSMutableArray *paths;
    BOOL needsRedraw;
	BOOL startedDrawing;
    BOOL isDrawing;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
		[self initialize];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initialize];
    }
    return self;
}

- (void)initialize {
	[self setMultipleTouchEnabled:NO];
	path = [UIBezierPath bezierPath];
	[path setLineWidth:10.0];
	paths = [NSMutableArray array];
    
    //    [NSTimer scheduledTimerWithTimeInterval:2.0
    //                                     target:self
    //                                   selector:@selector(targetMethod:)
    //                                   userInfo:nil
    //                                    repeats:NO];
    
    isDrawing = NO;
    

	needsRedraw = false;
	
	// set up magnet
	self.magnet = [Magnet sharedMagnet];
	self.magnet.delegate = self;
	
	
	// add cursor
	[self addSubview:self.cursorView];
}

- (void)layoutSubviews {
	self.calibrationView.frame = self.frame;
	
	self.x = [[UILabel alloc ]initWithFrame:CGRectMake(0, 100, 200, 50)];
	
	self.y = [[UILabel alloc ]initWithFrame:CGRectMake(0, 150, 200, 50)];
	
self.mag = [[UILabel alloc ]initWithFrame:CGRectMake(0, 200, 200, 50)];
	
	self.angle= [[UILabel alloc ]initWithFrame:CGRectMake(0, 250, 200, 50)];
	
		[self.superview addSubview:self.x];
		[self.superview addSubview:self.y];
		[self.superview addSubview:self.mag];
		[self.superview addSubview:self.angle];
	
}

#pragma mark - Delegates

#pragma mark -- Magnet Delegate

- (void)magnetDidUpdate {
	
	NSLog(@"magnetDidUpdate ran");
	CGRect newFrame = self.cursorView.frame;
	
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
    newFrame.origin = CGPointMake(
                                  ((cos(self.magnet.angle) * self.magnet.radius)),
                                  ((sin(self.magnet.angle) * self.magnet.radius))-200);
    
	self.cursorView.frame = newFrame;
	
	CGPoint pointToAdd = newFrame.origin;
	
	self.x.text = [NSString stringWithFormat:@"Xcoord : %.1f",pointToAdd.x];
	
	self.y.text = [NSString stringWithFormat:@"Ycoord : %.1f",pointToAdd.y];
	
	self.mag.text = [NSString stringWithFormat:@"Radius : %.1f",self.magnet.radius];
	
	self.angle.text = [NSString stringWithFormat:@"Angle : %.1f",self.magnet.angle];
	
//    NSLog(@"%f",self.magnet.z);
    if (!isDrawing) {
        return;
    }
    if (startedDrawing != YES) {
		[self beginPointsWithPoint:pointToAdd];
		startedDrawing = YES;
	} else {
		[self updatePointsWithPoint:pointToAdd];
	}
}

#pragma mark -- CalibrationViewDelegate

- (void)calibrationDidBegin {
	NSLog(@"calibration began");
	[self.magnet setBaselineFromCurrentState];
	[self updateCursorViewFrameForCalibrationWithQuadrant:1];
}

- (void)calibrateForQuadrant:(NSUInteger)quadrant {
	NSLog(@"calibration for quadrant %d", (int)quadrant);
	[self.magnet setCalibrationForQuadrant:quadrant];
	
	// quadrant is what we just calibrated so we start at 1 not 2
	[self updateCursorViewFrameForCalibrationWithQuadrant:++quadrant];
}

- (void)updateCursorViewFrameForCalibrationWithQuadrant:(NSUInteger)quadrant {
	CGRect frame = self.cursorView.frame;
	
	switch (quadrant) {
		case 1:
			frame.origin = CGPointMake(CGRectGetMaxX(self.frame) - frame.size.width, 0);
			break;
		case 2:
			frame.origin = CGPointZero;
			break;
		case 3:
			frame.origin = CGPointMake(0, CGRectGetMaxY(self.frame) - frame.size.height);
			break;
		case 4:
			frame.origin = CGPointMake(
									   CGRectGetMaxX(self.frame) - frame.size.width,
									   CGRectGetMaxY(self.frame) - frame.size.height);
			break;
	}
	
	self.cursorView.frame = frame;
}

- (void)calibrationDidEnd {
	NSLog(@"calibration ended");
	
	__weak typeof(self) welf = self;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		__strong typeof(self) newSelf = welf;
		[newSelf.calibrationView removeFromSuperview];
	});
}

#pragma mark - Original Code + idk

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    [path stroke];
}

#pragma mark - Stylus Drawing Method

- (void)beginPointsWithPoint:(CGPoint)point {
	ctr = 0;
	pts[0] = point;
}

- (void)updatePointsWithPoint:(CGPoint)point {
	ctr ++;
	pts[ctr] = point;
	if (ctr == 4) {
		pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
		
		[path moveToPoint:pts[0]];
		[path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
		
		[self setNeedsDisplay];
		// replace points and get ready to handle the next segment
		pts[0] = pts[3];
		pts[1] = pts[4];
		ctr = 1;
	}
}

- (void)endPointsWithPoint:(CGPoint)point {
	NSLog(@"endpoint method ran");
	if (!path.empty) {
		[paths addObject:[path copy]];
	}
	[self drawBitmap];
	[self setNeedsDisplay];
	[path removeAllPoints];
	ctr = 0;
}

#pragma mark - Touches Drawing Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isDrawing) {
        isDrawing = NO;
    } else {
        startedDrawing = NO;
        isDrawing = YES;
    }
}

/*


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4) 
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment 
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];

        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3]; 
        pts[1] = pts[4]; 
        ctr = 1;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!path.empty) {
		[paths addObject:[path copy]];
	}
	[self drawBitmap];
	[self setNeedsDisplay];
	[path removeAllPoints];
	ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}
 */

- (void)initalSetupWithPaths:(NSMutableArray *)initPaths {
    NSLog(@"READY");
    paths = [@[] mutableCopy];
    NSLog(@"%@", initPaths);
    [paths addObjectsFromArray:initPaths];
    [paths addObject:[UIBezierPath bezierPath]];
    [self undo];
}

- (void)saveWithTitle:(NSString *)title {
    [self setUserInteractionEnabled:NO];
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([filePaths count] > 0) ? [filePaths objectAtIndex:0] : nil;
    NSString *location = [basePath stringByAppendingPathComponent:[@"/Drawings" stringByAppendingPathComponent:title]];
    NSString *dataPath = [basePath stringByAppendingPathComponent:@"/Drawings"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:location]) {
        NSLog(@"CREATING FOLDER!");
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"%@",error);
    }

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:@{@"title": title, @"paths": paths} forKey:@"drawing"];
    NSLog(@"Title: %@", title);
    [archiver finishEncoding];
    [data writeToFile:location atomically:YES];
    NSLog(@"%@",location);
    }

- (void)undo {
    path = nil;
    path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
    [paths removeLastObject];
    needsRedraw = true;
    [self drawBitmap];
    [self setNeedsDisplay];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    if (needsRedraw) {
        incrementalImage = nil;
    }
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    if (needsRedraw) {
        for (UIBezierPath *oldPath in paths) {
            [oldPath stroke];
        }
        needsRedraw = false;
    } else {
        [path stroke];
    }
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    //[self openCVFunction:incrementalImage];
    UIGraphicsEndImageContext();
}

#pragma mark - Properties

- (CalibrationView *)calibrationView {
	if (_calibrationView == nil) {
		_calibrationView = [[CalibrationView alloc] initWithFrame:CGRectZero];
	}
	return _calibrationView;
}

- (UIView *)cursorView {
	if (_cursorView == nil) {
		_cursorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
		_cursorView.backgroundColor = [UIColor redColor];
	}
	return _cursorView;
}

@end