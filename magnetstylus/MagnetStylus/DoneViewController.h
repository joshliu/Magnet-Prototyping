//
//  DoneViewController.h
//  MagnetStylus
//
//  Created by Sebastian Cain on 1/17/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoneViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *doneLabel;
@property (strong, nonatomic) IBOutlet UIButton *backOut;
@property (strong, nonatomic) IBOutlet UIButton *homeOut;
- (IBAction)backPressed;
- (IBAction)homePressed;

@property (nonatomic, strong) UIImage *snapshotImage;

@property (strong, nonatomic) NSString *drawingIdentifier;

@end
