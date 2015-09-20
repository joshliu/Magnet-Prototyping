//
//  DrawViewController.h
//  MagnetStylus
//
//  Created by Sebastian Cain on 1/17/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SmoothedBIView.h"

@interface DrawViewController : UIViewController

- (void)saveDrawing;
@property NSMutableArray *paths;

@end
