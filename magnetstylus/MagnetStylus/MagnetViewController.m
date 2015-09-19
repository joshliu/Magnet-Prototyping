//
//  MagnetViewController.m
//  MagnetStylus
//
//  Created by Sebastian Cain on 1/16/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

#import "MagnetViewController.h"
#import "CalibrationView.h"
#import "Magnet.h"

@interface MagnetViewController () <CalibrationDelegate, MagnetDelegate>

@property (strong, nonatomic) UIView *cursorView;
@property (strong, nonatomic) NSMutableArray *drawnPointsArray;
@property (strong, nonatomic) UILabel *statsLabel;
@property (strong, nonatomic) CalibrationView *calibrationView;
@property (weak, nonatomic) Magnet *magnet;

@end

@implementation MagnetViewController

#pragma mark - Boilerplate

- (void)awakeFromNib {
    [super awakeFromNib];

    self.magnet = [Magnet sharedMagnet];
    self.magnet.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([CLLocationManager headingAvailable] == NO) {
        
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass Available" message:@"Sorry brah." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Fuck", nil];
        
        [noCompassAlert show];
        
        // Do any additional setup after loading the view, if we don't want to do drawing.
        return; // so we don't set up drawing according to the compass.
    }
    
    // Do any additional setup after loading the view, and we want to do drawing.
    if ([self.magnet isCalibrated] == NO) {
        self.calibrationView.calibrationDelegate = self;
        [self.view addSubview:self.calibrationView];
    }
    
    [self.view addSubview:self.statsLabel];
    [self.view addSubview:self.cursorView];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.calibrationView.frame = self.view.frame;
    self.statsLabel.frame = CGRectMake(0, 0, UIScreen.mainScreen.applicationFrame.size.width, 50);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalibrationDelegate

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
            frame.origin = CGPointMake(CGRectGetMaxX(self.view.frame) - frame.size.width, 0);
            break;
        case 2:
            frame.origin = CGPointZero;
            break;
        case 3:
            frame.origin = CGPointMake(0, CGRectGetMaxY(self.view.frame) - frame.size.height);
            break;
        case 4:
            frame.origin = CGPointMake(
                CGRectGetMaxX(self.view.frame) - frame.size.width,
                CGRectGetMaxY(self.view.frame) - frame.size.height);
            break;
    }
    
    self.cursorView.frame = frame;
}

- (void)calibrationDidEnd {
    NSLog(@"calibration ended; points: \n\t topRight.x: %f topRight.y: %f \n\t topLeft.x: %f topLeft.y: %f \n\t bottomLeft.x: %f bottomLeft.y: %f \n\t bottomRight.x: %f bottomRight.y: %f \n\t",
        self.magnet.topRightPoint.x,
        self.magnet.topRightPoint.y,
        self.magnet.topLeftPoint.x,
        self.magnet.topLeftPoint.y,
        self.magnet.bottomLeftPoint.x,
        self.magnet.bottomLeftPoint.y,
        self.magnet.bottomRightPoint.x,
        self.magnet.bottomRightPoint.y);
    
    __weak typeof(self) welf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self) newSelf = welf;
        [newSelf.calibrationView removeFromSuperview];
    });
}

#pragma mark - MagnetDelegate

- (void)magnetDidUpdate {
    // MARK: this method only gets called if the -[magnet isCalibrated]
	NSLog(@"radius: %f", self.magnet.radius);
	
    // caused error?
    if (self.magnet.radius == NAN) return;
	
    CGRect newFrame = self.cursorView.frame;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (self.magnet.isCalibrated) {
        newFrame.origin = CGPointMake(
            screenSize.height *-1.3* ((self.magnet.angle - self.magnet.bottomLeftPoint.y)/(self.magnet.bottomLeftPoint.y- self.magnet.bottomRightPoint.y)),
  (screenSize.height*-2 * ((((self.magnet.radius - self.magnet.topLeftPoint.x) / (self.magnet.topLeftPoint.x-self.magnet.bottomLeftPoint.x)))))- screenSize.height);
    } else {
        newFrame.origin = CGPointMake(
            screenSize.height * ((self.magnet.angle + 100)/50),
            screenSize.height - (self.magnet.radius/2));
    }
    
    self.statsLabel.text = [NSString stringWithFormat:@"x: %f y: %f", newFrame.origin.x, newFrame.origin.y];
    self.cursorView.frame = newFrame;
    
    UIView *point = [[UIView alloc] initWithFrame:self.cursorView.frame];
    point.backgroundColor = UIColor.redColor;
    
    [self.drawnPointsArray insertObject:point atIndex:0];
    if (self.drawnPointsArray.count > 500) {
        UIView *pointView = (UIView *)self.drawnPointsArray.lastObject;
        [pointView removeFromSuperview];
        [self.drawnPointsArray removeObject:pointView];
    }
    
    [self.view addSubview:point];
}

#pragma mark - Properties

- (UILabel *)statsLabel {
    if (_statsLabel == nil) {
        _statsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statsLabel.textAlignment = NSTextAlignmentRight;
        _statsLabel.textColor = [UIColor blackColor];
    }
    return
    _statsLabel;
}

- (UIView *)cursorView {
    if (_cursorView == nil) {
        _cursorView = [[UIView alloc] initWithFrame:CGRectMake(-4, -4, 4, 4)];
        _cursorView.backgroundColor = [UIColor blackColor];
    }
    return _cursorView;
}

- (UIView *)calibrationView {
    if (_calibrationView == nil) {
        _calibrationView = [[CalibrationView alloc] initWithFrame:CGRectZero];
    }
    return _calibrationView;
}

- (NSMutableArray *)drawnPointsArray {
    if (_drawnPointsArray == nil) {
        _drawnPointsArray = [[NSMutableArray alloc] init];
    }
    return _drawnPointsArray;
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
