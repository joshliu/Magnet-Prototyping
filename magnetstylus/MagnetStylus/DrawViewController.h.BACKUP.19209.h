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

<<<<<<< HEAD
- (void)saveDrawing;
@property NSMutableArray *paths;

@end
=======
@property (strong, nonatomic) IBOutlet UILabel *menuTitle;
@property (strong, nonatomic) IBOutlet UIButton *backButtonOut;
@property (strong, nonatomic) IBOutlet UIButton *saveButtonOut;
- (IBAction)save:(id)sender;
@property (strong,nonatomic) NSString *drawingIdentifier;

@end
>>>>>>> 9940b2adf4d5f7049bfaf068f341e3b9a58126be
