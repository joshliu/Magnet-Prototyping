//
//  Magnet.h
//  MagnetStylus
//
//  Created by Sam Moore on 1/16/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

@import Foundation;
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CGGeometry.h>

@protocol MagnetDelegate <NSObject>

- (void)magnetDidUpdate;

@end

@interface Magnet : NSObject

#pragma mark - Properties

@property (weak, nonatomic) id<MagnetDelegate> delegate;

#pragma mark - Read Values

// the raw x/y/z values for the magnet
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;

// the current magnitude of the component vector
//    sqrt(x^2, y^2, z^2)
//@property (readonly, nonatomic) CGFloat magnitude;

@property (readonly, nonatomic) CGFloat radius;
@property (readonly, nonatomic) CGFloat calculatedMagnitude;
@property (readonly, nonatomic) CGFloat angle;

- (CGPoint)topRightPoint;
- (CGPoint)topLeftPoint;
- (CGPoint)bottomLeftPoint;
- (CGPoint)bottomRightPoint;

#pragma mark - Singleton

+ (instancetype)sharedMagnet;

#pragma mark - Calibration

- (void)setBaselineFromCurrentState;
- (void)setCalibrationForQuadrant:(NSUInteger)quadrant;
- (BOOL)isCalibrated;

@end