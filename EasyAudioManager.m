//
//  GameAudioManager.m
//  iScrapbook
//
//  Created by Matthew Davidson on 13-06-22.
//  GameAudio.h, GameAudioManager.h, GameAudio.m, GameAudioManager.m - licensed under MIT License

#include <stdio.h>
#import "GameAudioManager.h"

@implementation GameAudioManager 

@synthesize soundList = _soundList;
@synthesize repeater = _repeater;
@synthesize nowPlaying = _nowPlaying;
@synthesize player = _player;
- (id)init
{
    self = [super init];
    if (self) {
        
        _soundList = [[NSMutableDictionary alloc] init];
        _nowPlaying = [[NSMutableArray alloc] init];
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
        NSPredicate *fltrMP3 = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mp3'"];
        NSPredicate *fltrAIF = [NSPredicate predicateWithFormat:@"self ENDSWITH '.aif'"];
        NSPredicate *fltrCAF = [NSPredicate predicateWithFormat:@"self ENDSWITH '.caf'"];
        NSArray *onlyMP3s = [dirContents filteredArrayUsingPredicate:fltrMP3];
        NSArray *onlyCAFs = [dirContents filteredArrayUsingPredicate:fltrCAF];
        NSArray *onlyAIFs = [dirContents filteredArrayUsingPredicate:fltrAIF];
        for (id object in onlyMP3s) {
            NSString * desc = [object description];
            NSString * name = [desc stringByDeletingPathExtension];
            NSMutableDictionary * resourceDic = [[NSMutableDictionary alloc]init];
            [resourceDic setValue:desc forKey:@"path"];
            [resourceDic setValue:@"mp3" forKey:@"type"];
            [_soundList setValue:resourceDic forKey:name];
        }
        for (id object in onlyAIFs) {
            NSString * desc = [object description];
            NSString * name = [desc stringByDeletingPathExtension];
            NSMutableDictionary * resourceDic = [[NSMutableDictionary alloc]init];
            [resourceDic setValue:desc forKey:@"path"];
            [resourceDic setValue:@"aif" forKey:@"type"];
            [_soundList setValue:resourceDic forKey:name];
        }
        for (id object in onlyCAFs) {
            NSString * desc = [object description];
            NSString * name = [desc stringByDeletingPathExtension];
            NSMutableDictionary * resourceDic = [[NSMutableDictionary alloc]init];
            [resourceDic setValue:desc forKey:@"path"];
            [resourceDic setValue:@"caf" forKey:@"type"];
            [_soundList setValue:resourceDic forKey:name];
        }
    }
    return self;
}
-(BOOL) soundExists:(NSString *) key
{
    return [_soundList objectForKey:key] != 0;
}
-(GameAudio *) getSound:(NSString *) key
{
    if ([self soundExists:key]) {
        NSMutableDictionary * resource = [_soundList objectForKey:key];
        NSString * type = [resource objectForKey:@"type"];
        return [[GameAudio alloc]init:key fileType:type];
    }
    else
    {
        NSLog(@"Couldn't find %@",key);
        return nil;
    }
    
}
- (void) control: (NSString *) key method:(NSString *) method
{
    NSArray * allowedMethods = [NSArray arrayWithObjects:@"play",@"stop",@"resume",@"pause",@"playWithFadeIn",@"resumeWithFadeIn",@"stopWithFadeOut", @"pauseWithFadeOut",nil];
    if ([allowedMethods containsObject:method]) {
        SEL doThis = NSSelectorFromString(method);
        GameAudio * sound = [self getSound: key];
        [self.nowPlaying addObject:sound];

        if(sound != nil)
        {
            [sound performSelector:doThis];
        }
    }
    else
    {
        NSLog(@"That method isn't allowed.");
    }
}
- (void) control: (NSString *) key method:(NSString *) method speed:(NSString *) speed
{
    NSArray * allowedMethods = [NSArray arrayWithObjects:@"play",@"stop",@"resume",@"pause",@"playWithFadeIn",@"resumeWithFadeIn",@"stopWithFadeOut", @"pauseWithFadeOut",nil];
    if ([allowedMethods containsObject:method]) {
        
        SEL doThis = NSSelectorFromString(method);
        GameAudio * sound = [self getSound: key];
        [self.nowPlaying addObject:sound];
        if(sound != nil)
        {
            NSLog(@"Got the sound.  %@",sound);
            [sound performSelector:doThis withObject:speed];
        }
        else{
            NSLog(@"The sound is nil.");
        }
    }
    else
    {
        NSLog(@"That method isn't allowed.");
    }
}
-(void) fadeLoop:(NSString *) key speed: (float) speed initVolume:(float) volume
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setValue:key forKey:@"key"];
    [params setValue:[[NSNumber alloc] initWithFloat:volume] forKey:@"volume"];
    _repeater = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(playWithDecay:) userInfo:params repeats:YES];
    [_repeater fire];
}
-(void) playWithDecay:(NSTimer *) timer
{
    NSMutableDictionary * userdata = [timer userInfo];
    NSString * key = [userdata objectForKey:@"key"];
    NSNumber * volume = [userdata objectForKey:@"volume"];
    float vol = [volume floatValue] - 0.9;
    if (vol < 0) {
        [timer invalidate];
        return;
    }
    volume = [[NSNumber alloc] initWithFloat:vol];
    [userdata setValue:volume forKey:@"volume"];
    GameAudio * sound = [self getSound:key];
    [sound.player setDelegate:self];
    [sound.player setVolume:vol];
    [_nowPlaying addObject:sound.player];
    [sound.player play];
}
-(void) intervalControl:(NSString *) key method:(NSString *) method speed: (int) speed repeat:(BOOL) repeat
{
    method = [method stringByAppendingString:@":"];
    _repeater = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:NSSelectorFromString(method) userInfo:key repeats:repeat];
    [_repeater fire];
}
-(void) playSound:(NSTimer *) timer
{
    NSString * userdata = [timer userInfo];
    GameAudio * sound = [self getSound:userdata];
    [sound.player setDelegate:self];
    [_nowPlaying addObject:sound.player];
    [sound.player play];
    
}

-(IBAction) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.nowPlaying removeObject:player];
}
-(IBAction)viewDidUnload:(id)sender
{
    
}
@end
