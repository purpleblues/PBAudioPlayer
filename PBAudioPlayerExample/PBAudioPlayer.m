//
//  PBAudioPlayer.m
//  Shifter
//
//  Created by Purple on 2015. 5. 28..
//  Copyright (c) 2015년 Purple. All rights reserved.
//

#import "PBAudioPlayer.h"

@interface PBAudioPlayer ()

@property (strong, nonatomic) AVAudioEngine* engine;
@property AVAudioPlayerNode* playerNode;
@property AVAudioUnitTimePitch* pitchNode;
@property AVAudioFile* currentAudioFile;
@property NSUInteger pausedTime;

@property NSUInteger seekedTime;
@property NSTimer* timer;


@end

@implementation PBAudioPlayer

@synthesize pitch = _pitch;
@synthesize currentPlayTimeInSeconds = _currentPlayTimeInSeconds;

-(NSUInteger)durationInSeconds{


    double sampleRate = _currentAudioFile.fileFormat.sampleRate;
    if(sampleRate == 0)
        return 0;
    return (((NSTimeInterval)_currentAudioFile.length/sampleRate));// sampleRate;


}
-(NSUInteger)currentPlayTimeInSeconds{

    if(_isPlaying){

        double sampleRate = _currentAudioFile.fileFormat.sampleRate;

        if(sampleRate == 0)
        {
            return 0;
        }

        NSTimeInterval currentTime = ((NSTimeInterval)[_playerNode playerTimeForNodeTime:_playerNode.lastRenderTime].sampleTime / sampleRate);

        return currentTime + _seekedTime;

    }else{

        return _pausedTime;
    }
}

-(float)pitch{return _pitch;}
-(void)setPitch:(float)pitch{

    if(pitch >= -2400 && pitch <= 2400){
        _pitch = pitch;


        _pitchNode.pitch = _pitch;

    }
}

-(instancetype)init{

    self = [super init];

    if(self){

        _engine = [[AVAudioEngine alloc] init];
        _playerNode = [[AVAudioPlayerNode alloc] init];
        _pitchNode = [[AVAudioUnitTimePitch alloc] init];

        [_engine attachNode:_playerNode];
        [_engine attachNode:_pitchNode];


        [_engine connect:_playerNode to:_pitchNode format:nil];
        [_engine connect:_pitchNode to:_engine.mainMixerNode format:nil];

    }

    return self;
}

-(void)loadwithURL:(NSURL*)url error:(NSError**)error{

    _currentAudioFile = [[AVAudioFile alloc] initForReading:url error:error];

    if(error == nil){

        [self stop];
        [_playerNode scheduleFile:_currentAudioFile atTime:nil completionHandler:nil];
        [_engine startAndReturnError:error];


    }
}

-(void)play{

    if(_playerNode.isPlaying){
        return;
    }

    [_playerNode play];
    _isPlaying = YES;

    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(didEverySecondPassed:) userInfo:nil repeats:YES];
    [_timer fire];





}
-(void)didEverySecondPassed:(id)sender{

    if([_delegate respondsToSelector:@selector(audioPlayer:currentPlayTimeInSeconds:)]){

        NSUInteger currentTime = self.currentPlayTimeInSeconds;
        NSUInteger duration = self.durationInSeconds;
        [_delegate audioPlayer:self currentPlayTimeInSeconds:self.currentPlayTimeInSeconds];
        if(currentTime >= duration){
            [self stop];
            if([_delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)]){
                [_delegate audioPlayerDidFinishPlaying:self];
            }
        }
    }

}
-(void)stop{

    [_playerNode stop];
    [_timer invalidate];
    _timer = nil;

    _seekedTime = 0;
    _pausedTime = 0;
    _pitch = 1.0;


}
-(void)pause{

    if(_playerNode.isPlaying == NO){
        return;
    }
    _pausedTime = self.currentPlayTimeInSeconds;

    [_timer invalidate];
    _timer = nil;

    [_playerNode pause];
    _isPlaying = NO;

}

-(void)seekToTimeInSeconds:(NSInteger)time{

    if(time >= 0 && time <= self.durationInSeconds && _currentAudioFile){
        BOOL wasPlaying = _isPlaying;
        [self stop];
        _pausedTime = time;
        _currentPlayTimeInSeconds = time;
        _seekedTime = time;

        [_engine startAndReturnError:nil];
        [_playerNode scheduleSegment:_currentAudioFile
                       startingFrame:time * _currentAudioFile.fileFormat.sampleRate
                          frameCount:_currentAudioFile.length - time * _currentAudioFile.fileFormat.sampleRate
                              atTime:nil
                   completionHandler:nil];
        
        if(wasPlaying)
            [self play];
    }
    
}
@end
