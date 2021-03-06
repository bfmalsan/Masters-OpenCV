//
//  OpenCVWrapper.m
//  Masters-OpenCV
//
//  Created by Brian Malsan on 5/1/19.
//  Copyright © 2019 Brian Malsan. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc.hpp>
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

+ (cv::Mat) cvMatFromUIImage: (UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (cv::Mat) cvMatGrayFromUIImage: (UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (UIImage *) UIImageFromCVMat: (cv::Mat) cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+(UIImage *) makeGray: (UIImage *) image {
    cv::Mat matrix = [OpenCVWrapper cvMatFromUIImage:image];
    
    cv::Mat resultMatrix;
    
    cv::cvtColor(matrix, resultMatrix, CV_BGR2GRAY);
    
    return  [OpenCVWrapper UIImageFromCVMat:resultMatrix];
}


//Will do background subtraction and Canny edge detection
bool first = false;
cv::Mat prevFrame;
+ (UIImage *) doCanny: (UIImage *) image{
    
    cv::Mat matrix = [OpenCVWrapper cvMatFromUIImage:image];
    
    cv::Mat gray;
    cv::cvtColor(matrix, gray, CV_BGR2GRAY);
    
    if(first){
        matrix.copyTo(prevFrame);
        first = false;
        return [OpenCVWrapper UIImageFromCVMat:prevFrame];
    }
    
    //do background subtraction
    cv::Mat backSub;
    backSub = matrix - prevFrame;
    matrix.copyTo(prevFrame); //set current matrix to the previousFrame
    
    cv::Mat blur;
    GaussianBlur(backSub,blur,cv::Size(3,3),0);
    
    cv::Mat edges;
    Canny(blur, edges, 50, 150, 3);
    
    return  [OpenCVWrapper UIImageFromCVMat:edges];
}


@end
