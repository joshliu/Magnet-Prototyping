//
//  ToolbarView.h
//  MagnetStylus
//
//  Created by Sam Moore on 1/17/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

@import UIKit;

@protocol CalibrationDelegate <NSObject>

- (void)calibrationDidBegin;
- (void)calibrateForQuadrant:(NSUInteger)quadrant; // a la cartesian quadrants, i.e. 1 = top right
- (void)calibrationDidEnd;

@end

@interface CalibrationView : UIView

@property (weak, nonatomic) id<CalibrationDelegate> calibrationDelegate;

@end
