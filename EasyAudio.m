//
//  EasyAudio.m
//  iScrapbook
//
//  Created by Matthew Davidson on 12-05-04.
//  EasyAudio.h, EasyAudioManager.h, EasyAudio.m, EasyAudioManager.m - licensed under MIT License

#import "EasyAudio.h"



@implementation EasyAudio

@synthesize player = _player;

-(id) init:(NSString *)filename fileType: (NSString *)filetype
{
    return [self initWithFileName:filename type:filetype];
}
-(id) initWithFileName:(NSString *)filename type:(NSString *)filetype
{
    self = [super init];
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: filename
                                    ofType: filetype];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    self.player = newPlayer;
    [self.player prepareToPlay];
    return self;
}
-(void) play
{
    [self.player play];
}

    //will probably encapsulate the fades

-(void) playWithFadeIn

{
    if(_player.playing == NO) {
        _player.volume = 0;
        [_player play];
    }
    NSNumber *incr = [[NSNumber alloc] initWithFloat:0.1];
    while (_player.volume < 1) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeIn:) userInfo:incr repeats:NO];
    }
}
-(void) playWithFadeIn:(NSString *)speed
{
    if(_player.playing == NO) {
        _player.volume = 0;
        [_player play];
    }
    NSNumber *incr = [[NSNumber alloc] initWithFloat:[speed floatValue]];
    while (_player.volume < 1) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeIn:) userInfo:incr repeats:NO];
    }
}
-(void) adjustVolume: (int) increment
{
    _player.volume = _player.volume + increment;
}
-(void) pause
{
    [_player pause];
}
-(void) pauseWithFadeOut
{
    NSNumber *incr = [[NSNumber alloc] initWithFloat:0.1];
    while (_player.volume > 0.1) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeOut:) userInfo:incr repeats:NO];
    }
}
-(void)fadeIn: (NSTimer*) deleg
{   
    int incr = (int) [deleg userInfo];
    if (_player.volume > 0.1) {
        [self adjustVolume:incr];
    }
}
-(void)fadeOut: (NSTimer*) deleg
{   
    int incr = (int) [deleg userInfo];
    if (_player.volume > 0.1) {
        [self adjustVolume:-incr];
    }
    
}
-(void) pauseWithFadeOut:(NSString *)speed
{
    NSNumber *incr = [[NSNumber alloc] initWithFloat:[speed floatValue]];
    while (_player.volume > 0.1) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeOut:) userInfo:incr repeats:NO];
    }

    [self pause];
    
}
-(void) stop
{
    [_player stop];
}
-(void) stopWithFadeOut
{
    NSNumber *incr = [[NSNumber alloc] initWithFloat:0.1];
    while (_player.volume > 0.1) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeOut:) userInfo:incr repeats:NO];
    }
}
-(void) stopWithFadeOut:(NSString *)speed
{
    NSNumber *incr = [[NSNumber alloc] initWithFloat:[speed floatValue]];
    while (_player.volume > 0.1) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeOut:) userInfo:incr repeats:NO];
    }
    [self stop];
}
-(void) resume
{
    [self play];
}
-(void) resumeWithFadeIn
{
    [self playWithFadeIn];
}
-(void) resumeWithFadeIn:(NSString *)speed
{
    [self playWithFadeIn:speed];
}
@end
