//
//  RotateVedio.h
//  DemoSwiftyCam
//
//  Created by invoker on 2018/3/1.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface RotateVedio : NSObject


typedef enum {
    LBVideoOrientationUp,               //Device starts recording in Portrait
    LBVideoOrientationDown,             //Device starts recording in Portrait upside down
    LBVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
    LBVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
    LBVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} LBVideoOrientation;

-(CGFloat)videoOrientationWithAsset:(AVAsset *)asset;
-(AVMutableVideoComposition *)getAVMutableVideoComposition:(AVAsset *)asset degress:(CGFloat)degress;
+(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset composition:( AVMutableComposition*)composition;
@end
