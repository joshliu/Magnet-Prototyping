//
//  Magnet.m
//  MagnetStylus
//
//  Created by Sam Moore on 1/16/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

#import "Magnet.h"
#import <UIKit/UIScreen.h>

@interface Magnet () <CLLocationManagerDelegate>

@property (assign, nonatomic) CGSize screenSize;
@property (strong, nonatomic) CLHeading *rawHeading;

@property (assign, nonatomic) NSInteger baselineMagnitude;
@property (assign, nonatomic) CGFloat calculatedMagnitude;

@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) CGFloat angle;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableDictionary *calibrationPoints;

@end

@implementation Magnet

+ (instancetype)sharedMagnet {
    static Magnet *sharedMagnet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedMagnet == nil) {
            sharedMagnet = [[Magnet alloc] init];
        }
    });
    return sharedMagnet;
}

- (CGPoint)calibratedPointAtIndex:(NSUInteger)index {
    CGPoint point;
    NSDictionary *dictPoint = self.calibrationPoints[@(index)];
    CFDictionaryRef dictRef = (CFDictionaryRef)CFBridgingRetain(dictPoint);
    CGPointMakeWithDictionaryRepresentation(dictRef, &point);
    CFRelease(dictRef);
    
    return point;
}

- (CGPoint)topRightPoint {
    if (self.calibrationPoints[@(1)] == nil) return CGPointZero;
    
    return [self calibratedPointAtIndex:1];
}

- (CGPoint)topLeftPoint {
    if (self.calibrationPoints[@(2)] == nil) return CGPointZero;

    return [self calibratedPointAtIndex:2];
}

- (CGPoint)bottomLeftPoint {
    if (self.calibrationPoints[@(3)] == nil) return CGPointZero;

    return [self calibratedPointAtIndex:3];
}

- (CGPoint)bottomRightPoint {
    if (self.calibrationPoints[@(4)] == nil) return CGPointZero;

    return [self calibratedPointAtIndex:4];
}

#pragma mark - Boilerplate

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
    
    // return nil if the compass isn't available
    if ([CLLocationManager headingAvailable] == NO) return nil;
    
    // start tracking data
    [self.locationManager startUpdatingHeading];
    
    return self;
}

- (void)dealloc {
    [self.locationManager stopUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.rawHeading = newHeading;
    
    // MARK: Magnitude / Radius
    CGFloat rawMagnitude = [self magnitudeWithHeading:newHeading];
    if (rawMagnitude < 0.0001) {
        return;
    }
    
    self.x = newHeading.x;
    self.y = newHeading.y;
    self.z = newHeading.z;
    
    // ABS will return an integer, and will round the calculated value to the nearest int.
    self.calculatedMagnitude = ABS(rawMagnitude - self.baselineMagnitude);
    self.radius = [self radiusFromCalculatedMagnitude:self.calculatedMagnitude];
    
    // MARK: Calculating Angle
    self.angle = [self angleWithHeading:newHeading];
    
//    NSLog(@"polar coordinates: \n\t radius: %f \n\t angle: %f \n\t mag: %f", self.radius, self.angle, (float)self.calculatedMagnitude);
    
    //NSLog(@"Magnitude %f , Radius %f , mag %f, angle %f", rawMagnitude, self.radius, (double)self.calculatedMagnitude, self.angle);
    //NSLog(@"X - %f,  Y - %f,  Z - %f  ",newHeading.x,newHeading.y ,newHeading.z);
//    if ([self isCalibrated] == YES)
        [self.delegate magnetDidUpdate];
}

#pragma mark - Geometry

// MARK: returns a ratio, from 0.0-1.0, of the distance down the screen...
- (CGFloat)magnitudeWithHeading:(CLHeading *)heading {
    return [self magnitudeFromX:heading.x y:heading.y z:heading.z];
}

- (CGFloat)magnitudeFromX:(double)x y:(double)y z:(double)z {
    return (CGFloat) sqrt(x*x + y*y + z*z);
}

- (CGFloat)radiusFromCalculatedMagnitude:(NSInteger)calculatedMagnitude {
    double magCubedRoot = pow(ABS(calculatedMagnitude), 1.0/3.0);
    double adjustedCubedRoot = 30.0 * magCubedRoot - 76.0;
    double radius = ABS(MAX(0, adjustedCubedRoot) + calculatedMagnitude/8);
    
    return radius;
}

- (CGFloat)angleWithHeading:(CLHeading *)heading {
    return [self angleFromX:heading.x y:heading.y z:heading.z];
}

- (CGFloat)angleFromX:(double)x y:(double)y z:(double)z {
    CGFloat angle = 0;
    angle = atan(y/ x);
    return angle;
}

#pragma mark - Calibration

/*
- (CGPoint)calibrateCartesianPoint:(CGPoint)point {
    CGPoint topLeft = [self topLeftPoint];
    CGPoint bottomLeft = [self bottomLeftPoint];
    CGPoint topRight = [self topRightPoint];
    CGPoint bottomRight = [self bottomRightPoint];
    
    CGPoint minValues = CGPointMake((topLeft.x+bottomLeft.x)/2.0, (topLeft.y+topRight.y)/2.0);
    CGPoint maxValues = CGPointMake((topRight.x+bottomRight.x)/2.0, (bottomLeft.y+bottomRight.y)/2.0);
    
    NSLog(@"min: \n\t x: %f \n\t y: %f", minValues.x, minValues.y);
    NSLog(@"max: \n\t x: %f \n\t y: %f", maxValues.x, maxValues.y);
    
    NSLog(@"position: \n\t x: %f \n\t y: %f", point.x, point.y);
    
    CGPoint positionBasedOnMin = CGPointMake(
        point.x - minValues.x,
        point.y - minValues.y);

// Last I checked, this code outputes the SAME as positionBasedOnMax; we need a new way to find the position from max
//    CGPoint positionBasedOnMax = CGPointMake(
//        (maxValues.x - minValues.x) - (maxValues.x - point.x),
//        (maxValues.y - minValues.y) - (maxValues.y - point.y));
//    

    NSLog(@"position based on min: \n\t x: %f \n\t y: %f", positionBasedOnMin.x, positionBasedOnMin.y);
//    NSLog(@"position based on max: \n\t x: %f \n\t y: %f", positionBasedOnMax.x, positionBasedOnMax.y);

    CGPoint diffValues = CGPointMake(abs(maxValues.x-minValues.x), abs(maxValues.y-minValues.y));

    NSLog(@"diff values: \n\t x: %f \n\t y: %f", diffValues.x, diffValues.y);
//
    CGPoint averagePoint = CGPointMake(
        (positionBasedOnMin.x)/diffValues.x,
        (positionBasedOnMin.y)/diffValues.y
    );
    
    NSLog(@"average: \n\t x: %f \n\t %f", averagePoint.x, averagePoint.y);
//
    return averagePoint;
}

- (CGPoint)makeCartesianPointFromPolarPoint:(CGPoint)polarPoint {
    CGPoint point = CGPointZero;
    
    point.x = (int)polarPoint.x * cos((int)polarPoint.y) * 1.0;
    point.y = (int)polarPoint.x * sin((int)polarPoint.y) * 1.0;
    
    return point;
}
*/

- (BOOL)isCalibrated {
    return (self.calibrationPoints.count < 4) ? NO : YES;
}

- (void)setBaselineFromCurrentState {
    self.baselineMagnitude = [self magnitudeWithHeading:self.rawHeading];
}

// stores the polar coordinates in the array
- (void)setCalibrationForQuadrant:(NSUInteger)quadrant {
    CGPoint cartesianCoordiantes = CGPointMake(self.calculatedMagnitude, self.angle);
//    CGPoint polarCoordinates = CGPointMake(_magnitude, _angle);
//    CGPoint cartesianCoordiantes = [self makeCartesianPointFromPolarPoint:polarCoordinates];
    NSDictionary *dictionaryRepresentation =
        CFBridgingRelease(CGPointCreateDictionaryRepresentation(cartesianCoordiantes));
    
    [self.calibrationPoints
        setObject:dictionaryRepresentation
        forKey:@(quadrant)];
}

#pragma mark - Properties

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = 0.01;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = kCLHeadingFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSMutableDictionary *)calibrationPoints {
    if (_calibrationPoints == nil) {
        _calibrationPoints = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _calibrationPoints;
}

@end
