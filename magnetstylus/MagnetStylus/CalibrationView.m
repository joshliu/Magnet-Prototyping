//
//  ToolbarView.m
//  MagnetStylus
//
//  Created by Sam Moore on 1/17/15.
//  Copyright (c) 2015 PennAppsTeam2015. All rights reserved.
//

#import "CalibrationView.h"

#define kBeginCalibrationText @"Calibrate"
#define kPositionCalibrationText @"Set Reference Point For Corner %d"

@interface CalibrationView ()

@property (strong, nonatomic) UIView *toolbarView;
@property (strong, nonatomic) UIButton *buttonView;
@property (strong, nonatomic) UIView *positionIdentifierView;

@property (readonly, nonatomic) NSUInteger quadrant;

@end

@implementation CalibrationView

#pragma mark - Boilerplate

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    // additional setup after initialization
    [self addSubview:self.toolbarView];
    [self addSubview:self.buttonView];
    
    return self;
}

- (void)layoutSubviews {
    CGRect frame = self.frame;
    
    int toolbarHeight = 80;
    CGSize buttonSize = CGSizeMake(150, 50);
    
    self.toolbarView.frame = (CGRect) {
        .origin = {
            0,
            frame.size.height - toolbarHeight
        },
        .size = {
            frame.size.width,
            toolbarHeight
        }
    };
    
    // we only want to set the origin and the default size before we change the text
    if (CGRectIsEmpty(self.buttonView.frame)) {
        self.buttonView.frame = (CGRect) {
            .origin = {
                CGRectGetMidX(self.toolbarView.frame) - buttonSize.width/2,
                CGRectGetMidY(self.toolbarView.frame) - buttonSize.height/2
            },
            .size = buttonSize
        };
    } else {
        // we want to preserve the frame.size, set by -[self updateButtonWithText:]
        self.buttonView.frame = (CGRect) {
            .origin = {
                CGRectGetMidX(self.toolbarView.frame) - self.buttonView.frame.size.width/2,
                CGRectGetMidY(self.toolbarView.frame) - self.buttonView.frame.size.height/2
            },
            .size = self.buttonView.frame.size
        };
    }
}

#pragma mark - Target/Action

- (void)buttonTapped {
    if ([self.buttonView.titleLabel.text isEqualToString:kBeginCalibrationText])
    // begin calibrating
    {
        [self.calibrationDelegate calibrationDidBegin];
        _quadrant = 1;
        [self updateButtonWithText:[NSString stringWithFormat:kPositionCalibrationText, (int)_quadrant, nil]];
    }
    else if (_quadrant == 4)
    // end calibrating
    {
		[self.buttonView setEnabled:NO];
        [self.calibrationDelegate calibrateForQuadrant:self.quadrant];
        [self updateButtonWithText:@"Start Drawing!"];
        [self.calibrationDelegate calibrationDidEnd];
    }
    else
    // next step
    {
        [self.calibrationDelegate calibrateForQuadrant:self.quadrant];
        _quadrant++;
        [self updateButtonWithText:[NSString stringWithFormat:kPositionCalibrationText, (int)_quadrant, nil]];
        
    }
}

#pragma mark - Subviews

- (UIView *)toolbarView {
    if (_toolbarView == nil) {
        _toolbarView = [[UIView alloc] initWithFrame:CGRectZero];
        _toolbarView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    return _toolbarView;
}

- (UIButton *)buttonView {
    if (_buttonView == nil) {
        _buttonView = [[UIButton alloc] initWithFrame:CGRectZero];
        _buttonView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        
        [_buttonView setTitle:@"Calibrate" forState:UIControlStateNormal];
        _buttonView.titleLabel.textColor = [UIColor blackColor];
        _buttonView.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_buttonView addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonView;
}

#pragma mark - Helpers

- (void)updateButtonWithText:(NSString *)text {
    if (text != nil) {
        [self.buttonView setTitle:text forState:UIControlStateNormal];
        CGRect frame = self.buttonView.frame;
        
        // attribute the string with the font we are using so we can calculate width
        NSAttributedString *string = [[NSAttributedString alloc]
            initWithString:text
            attributes:@{
                NSFontAttributeName: self.buttonView.titleLabel.font
            }];
        
        frame.size.width = string.size.width + 50;
        self.buttonView.frame = frame;
        
        [self setNeedsLayout];
    }
}

@end
