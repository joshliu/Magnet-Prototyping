//
//  Wrapper.h
//  opencv-playground
//
//  Created by Antonio Marino on 9/19/15.
//  Copyright (c) 2015 Team Goat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ViewController;

@interface Wrapper : NSObject

+(UIImage*)processImage:(UIImage*)image withVC:(ViewController*)instance;



@end
