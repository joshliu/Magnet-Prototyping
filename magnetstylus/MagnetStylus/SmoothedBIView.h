//
//  SmoothedBIView.h
//  FreehandDrawingTut
//
//  Created by A Khan on 12/10/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmoothedBIView : UIView

- (void)undo;
- (void)saveWithTitle:(NSString *)title;
- (void)initalSetupWithPaths:(NSMutableArray*)initPaths;

@end
