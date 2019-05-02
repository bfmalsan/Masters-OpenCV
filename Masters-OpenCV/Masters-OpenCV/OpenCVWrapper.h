//
//  OpenCVWrapper.h
//  Masters-OpenCV
//
//  Created by Brian Malsan on 5/1/19.
//  Copyright © 2019 Brian Malsan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (UIImage *) makeGray: (UIImage *) image;

+ (UIImage *) doCanny: (UIImage *) image;

@end

NS_ASSUME_NONNULL_END
