//
//  RotateVedio.m
//  ActingAppointment
//
//  Created by invoker on 2018/3/1.
//
#define degreesToRadians(x) (M_PI*(x)/180.0)
#import "RotateVedio.h"

@implementation RotateVedio
{
    AVMutableComposition *mutableComposition;
    AVMutableVideoComposition *mutableVideoComposition;
}

-(AVMutableVideoComposition *)getAVMutableVideoComposition:(AVAsset *)asset degress:(CGFloat)degress
{
    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    CGAffineTransform t1;
    CGAffineTransform t2;
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    // Step 1
    // Create a composition with the given asset and insert audio and video tracks into it from the asset
    if (!mutableComposition) {
        // Check whether a composition has already been created, i.e, some other tool has already been applied
        // Create a new composition
        mutableComposition = [AVMutableComposition composition];
        // Insert the video and audio tracks from AVAsset
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
        }
    }
    //    // Step 2
    //    // Translate the composition to compensate the movement caused by rotation (since rotation would cause it to move out of frame)
    //    t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.height, 0.0);
    //    // Rotate transformation
    //    t2 = CGAffineTransformRotate(t1, degreesToRadians(90));
    if (degress == 0) {
        t1 = CGAffineTransformMakeTranslation(0.0, 0.0);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(0));
    }else if (degress == 90){
        t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.height, 0.0);
       t2 = CGAffineTransformRotate(t1, M_PI_2);
    }else if (degress == 180){
        t1 = CGAffineTransformMakeTranslation(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(180));
    }else if (degress == 270){
        t1 = CGAffineTransformMakeTranslation(0,assetVideoTrack.naturalSize.height*1.78);
        t2 = CGAffineTransformRotate(t1, degreesToRadians(-90));
    }
    if (!mutableVideoComposition) {
        // Create a new video composition
        mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        if (degress == 0 || degress == 180) {
            mutableVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.width,assetVideoTrack.naturalSize.height);
        }else{
            mutableVideoComposition.renderSize = CGSizeMake(assetVideoTrack.naturalSize.height,assetVideoTrack.naturalSize.width);
        }
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
        // The rotate transform is set on a layer instruction
        instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mutableComposition duration]);
        layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:(mutableComposition.tracks)[0]];
        [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    }
    // Step 4
    // Add the transform instructions to the video composition
    instruction.layerInstructions = @[layerInstruction];
    mutableVideoComposition.instructions = @[instruction];
    return mutableVideoComposition;
}
static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};
-(CGFloat)videoOrientationWithAsset:(AVAsset *)asset
{
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] == 0) {
        return LBVideoOrientationNotFound;
    }
    
    AVAssetTrack* videoTrack    = [videoTracks objectAtIndex:0];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    CGFloat videoAngleInDegree  = RadiansToDegrees(atan2(txf.b, txf.a));
    
    LBVideoOrientation orientation = 0;
    switch ((int)videoAngleInDegree) {
        case 0:
            orientation = LBVideoOrientationRight;
            break;
        case 90:
            orientation = LBVideoOrientationUp;
            break;
        case 180:
            orientation = LBVideoOrientationLeft;
            break;
        case -90:
            orientation     = LBVideoOrientationDown;
            break;
        default:
            orientation = LBVideoOrientationNotFound;
            break;
    }
    NSLog(@"%f",videoAngleInDegree);
    return videoAngleInDegree;
}


+(AVMutableVideoComposition *) getVideoComposition:(AVAsset *)asset composition:( AVMutableComposition*)composition{
    BOOL isPortrait_ = [self isVideoPortrait:asset];
    
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionLayerInstruction *layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    CGAffineTransform transform = videoTrack.preferredTransform;
    [layerInst setTransform:transform atTime:kCMTimeZero];
    
    
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    
    CGSize videoSize = videoTrack.naturalSize;
    if(isPortrait_) {
        NSLog(@"video is portrait ");
        
    }
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMake(1,30);
    videoComposition.renderScale = 1.0;
    return videoComposition;
}
+(BOOL) isVideoPortrait:(AVAsset *)asset{
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = FALSE;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = FALSE;
        }
    }
    return isPortrait;
}

@end
