//
//  PBAudioPlayer.h
//  Shifter
//
//  Created by Purple on 2015. 5. 28..
//  Copyright (c) 2015년 Purple. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@class PBAudioPlayer;

@protocol PBAudioPlayerDelegate<NSObject>

-(void)audioPlayer:(PBAudioPlayer*)player currentPlayTimeInSeconds:(NSUInteger)seconds; //invoked when every seconds pass while playing
-(void)audioPlayerDidFinishPlaying:(PBAudioPlayer *)player;

@end


@interface PBAudioPlayer : NSObject


@property (weak, nonatomic) id<PBAudioPlayerDelegate> delegate;

@property (readonly) BOOL       isPlaying;
@property (readonly) NSUInteger durationInSeconds;
@property (readonly) NSUInteger currentPlayTimeInSeconds;

@property float pitch; // -2400 to 2400,  1 octave  = 1200 cents 1 musical semitone  = 100 cents


-(instancetype)init;

-(void)loadwithURL:(NSURL*)url error:(NSError**)error;


-(void)play;
-(void)pause;

-(void)seekToTimeInSeconds:(NSInteger)time; //if time is negative, move to the end



@end
