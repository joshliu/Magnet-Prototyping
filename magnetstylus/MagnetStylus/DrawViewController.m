//
//  DrawViewController.m
//  MagnetStylus
//
//  Created by Sebastian Cain on 1/17/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

#import "DrawViewController.h"
#import "DoneViewController.h"

@interface DrawViewController ()

@end

@implementation DrawViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor darkGrayColor];
    // Do any additional setup after loading the view.
    if (self.paths) {
        for (UIView *view in [self.view subviews]) {
            if ([view isKindOfClass:[SmoothedBIView class]]) {
                [(SmoothedBIView *)view initalSetupWithPaths:self.paths];
            }
        }
    }
	self.backButtonOut.titleLabel.text = @"Back";
	[self.backButtonOut setTitleColor: [UIColor colorWithRed:44.0/255.0 green:232.0/255.0 blue:148.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	self.saveButtonOut.titleLabel.text = @"Save";
	[self.saveButtonOut setTitleColor: [UIColor colorWithRed:44.0/255.0 green:232.0/255.0 blue:148.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	self.menuTitle.font = [UIFont fontWithName:@"Avenir-Heavy" size:30];
	self.menuTitle.text = [self.title uppercaseString];
	
	
	
}

+ (UIImage *) imageWithView:(UIView *)view
{
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return img;
}

- (IBAction)done:(id)sender {
	[self saveDrawing];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	DoneViewController *myVC = (DoneViewController *)[storyboard instantiateViewControllerWithIdentifier:@"done"];
	for (UIView *view in [self.view subviews]) {
		if ([view isKindOfClass:[SmoothedBIView class]]) {
			UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0f);
			CGContextRef context = UIGraphicsGetCurrentContext();
			[view.layer renderInContext:context];
			self.snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
	}
	myVC.drawingIdentifier = self.drawingIdentifier;
	myVC.snapshotImage = self.snapshotImage;
	[self presentViewController:myVC animated:YES completion:nil];
}

- (void)saveDrawing {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[SmoothedBIView class]]) {
            [(SmoothedBIView *)view saveWithTitle:self.title];
        }
    }
}

- (IBAction)back:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *myVC = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"menu"];
    [self presentViewController:myVC animated:YES completion:nil];
}

- (IBAction)undo:(id)sender {
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[SmoothedBIView class]]) {
            [(SmoothedBIView *)view undo];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)backButtonAct:(id)sender {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	UIViewController *myVC = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"menu"];
	[self presentViewController:myVC animated:YES completion:nil];
}


@end