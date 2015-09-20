//
//  Wrapper.m
//  opencv-playground
//
//  Created by Antonio Marino on 9/19/15.
//  Copyright (c) 2015 Team Goat. All rights reserved.
//

#import "Wrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/core/core_c.h>
#import <vector>
#import <unordered_map>
#import "opencv_playground-Swift.h"


using std::vector;
using namespace cv;

static UIImage *resultingImage = nil;

static std::unordered_map<int, UIView*> rectsMap;

@implementation Wrapper
static UIImage* cvMatToUIImage(const cv::Mat& m) {
    CV_Assert(m.depth() == CV_8U);
    NSData *data = [NSData dataWithBytes:m.data length:m.elemSize()*m.total()];
    CGColorSpaceRef colorSpace = m.channels() == 1 ?
    CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    
    CGImageRef imageRef = CGImageCreate(m.cols, m.rows, m.elemSize1()*8, m.elemSize()*8,
                                        m.step[0], colorSpace, kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef); CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace); return finalImage;
}

static void cvUIImageToMat(const UIImage* image, cv::Mat& m) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width, rows = image.size.height;
    m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGContextRef contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8, m.step[0], colorSpace, kCGImageAlphaNoneSkipLast |kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    //    CGColorSpaceRelease(colorSpace);
}

+(UIImage*)processImage:(UIImage*)image withVC:(ViewController*)instance {
    cv::Mat img;
    cv::Mat resultImg;
    cvUIImageToMat(image, img);
    cvUIImageToMat(image, resultImg);
    //resultImg = cvMatGrayFromUIImage(image);
    
    cv::cvtColor(img, resultImg, COLOR_BGR2GRAY);
    cv::threshold(resultImg, resultImg, 128, 255, THRESH_BINARY);

    //cv::Canny(resultImg, resultImg, 100, 110);
    
    vector<vector<cv::Point>> contours;
    vector<cv::Rect> rectangles;
    vector<Vec4i> hierarchy;
    std::unordered_map<int, int> typesForRectangles;

    //cv::bitwise_not(resultImg, resultImg);
    cv::findContours(resultImg, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    int biggestArea = -1;
    cv::Rect biggestRect;
    
    for (int i = 1; i < contours.size(); i++) {
        //cv::drawContours(resultImg, contours, i, cv::Scalar(arc4random() % 255,arc4random() % 255,arc4random() % 255), 2);
        cv::approxPolyDP(contours[i], contours[i], 0.03*cv::arcLength(contours[i], true), true);
        NSLog(@"contour size: %lu", contours[i].size());
        if (contours[i].size() == 4) {
            // it's a rectangle
            cv::Rect rect = cv::boundingRect(contours[i]);
            int firstChildIndex = hierarchy[i][2];
            if (firstChildIndex >= 0) {
                cv::Rect childRect = cv::boundingRect(contours[firstChildIndex]);
                if (rect.area() < childRect.area() + 300) {
                    continue;
                }
            }
            if (rect.area() > biggestArea) {
                biggestArea = rect.area();
                biggestRect = rect;
            } else if (rect.area() < 300) {
                // do nothing for very small rects
            }
            rectangles.push_back(rect);
            cv::rectangle(resultImg, rect, cvScalar(255,255,255), 1);
        }
        else if (contours[i].size() > 15) {
            // it's a circle
            cv::Rect parent = cv::boundingRect(contours[hierarchy[i][3]]);
            typesForRectangles[parent.area()] = 1;
        } else if (contours[i].size() == 8 || contours[i].size() == 9) {
            // half a circle
            cv::Rect parent = cv::boundingRect(contours[hierarchy[i][3]]);
            typesForRectangles[parent.area()] = 2;
        }

    }
    //return cvMatToUIImage(resultImg);
    //cv::Rect rc = cv::boundingRect(contours[contours.size()-1]);

    //cv::cvtColor(resultImg, resultImg, CV_BGR2GRAY);
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    for (int i = 0; i < rectangles.size(); i++) {

        if (rectsMap.find(rectangles[i].area()) != rectsMap.end()) {
             //rectangle already there, do nothing
        } else if (rectangles[i].area() == biggestArea) {
            // do not draw
            NSLog(@"asdf");
        } else {
            // new rectangle, track and create view
            
            if (typesForRectangles[rectangles[i].area()] == 2) {
                NSLog(@"yoooo");
                UIButton *btn = [[UIButton alloc] init];
                [btn setTitle:@"Button" forState:UIControlStateNormal];
                CGRect btFrame = btn.frame;
                btFrame.origin.x = (CGFloat)(rectangles[i].tl().x - biggestRect.tl().x);
                btFrame.origin.y = (CGFloat)(rectangles[i].tl().y - biggestRect.tl().y);
                btn.frame = btFrame;
                [btn setBackgroundColor:[UIColor brownColor]];
                [btn sizeToFit];
                //[instance.view addSubview:btn];
                [instance.view insertSubview:btn atIndex:[[instance.view subviews] count]];
            }
            else if (typesForRectangles[rectangles[i].area()] == 1) {
                NSLog(@"yolo");
                UITextField *btn = [[UITextField alloc] init];
                [btn setPlaceholder:@"Enter text"];
                CGRect btFrame = btn.frame;
                btFrame.origin.x = (CGFloat)(rectangles[i].tl().x - biggestRect.tl().x);
                btFrame.origin.y = (CGFloat)(rectangles[i].tl().y - biggestRect.tl().y);
                btn.frame = btFrame;
                [btn setBackgroundColor:[UIColor yellowColor]];
                [btn sizeToFit];
                //[instance.view addSubview:btn];
                [instance.view insertSubview:btn atIndex:[[instance.view subviews] count]];
            }
            else {
            
            CGRect rect = CGRectMake(0,0,//(CGFloat)(rectangles[i].tl().x - biggestRect.tl().x),
                                     //(CGFloat)(rectangles[i].tl().y - biggestRect.tl().y),
                                     (screenWidth*rectangles[i].width)/biggestRect.width,
                                     (screenHeight*rectangles[i].height)/biggestRect.height);
            
            UIGraphicsBeginImageContext(rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context,
                                           [[UIColor redColor] CGColor]);
            CGContextFillRect(context, rect);
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = img;
            [imageView sizeToFit];
            CGRect imgFrame = imageView.frame;
            imgFrame.origin.x = (CGFloat)(rectangles[i].tl().x - biggestRect.tl().x);
            imgFrame.origin.y = (CGFloat)(rectangles[i].tl().y - biggestRect.tl().y);
            imageView.frame = imgFrame;
            
            [instance.view addSubview:imageView];
            
            rectsMap[rectangles[i].area()] = imageView;
            }
        }
    }
    return cvMatToUIImage(resultImg);
}
@end
