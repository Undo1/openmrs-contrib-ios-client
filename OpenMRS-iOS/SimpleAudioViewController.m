//
//  SimpleAudioViewController.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/24/15.
//

#import "SimpleAudioViewController.h"
#include <stdlib.h>

@interface SimpleAudioViewController () {
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
}

@property (nonatomic, strong) NSURL *outputFileURL;
@property (nonatomic, strong) UIButton *play;
@property (nonatomic, strong) UIButton *stop;
@property (nonatomic, strong) UIButton *record;
@property (nonatomic) BOOL recorded;

@end

@implementation SimpleAudioViewController

@synthesize rowDescriptor = _rowDescriptor;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setConstraints];
    [self setupAudio];
}

-(void)loadView {
    NSLog(@"load view");
    UIView *view = [[UIView alloc] init];
    
    self.play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.play setTitle:@"Play" forState:UIControlStateNormal];
    self.play.translatesAutoresizingMaskIntoConstraints = NO;
    [self.play addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.stop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.stop setTitle:@"Stop" forState:UIControlStateNormal];
    self.stop.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stop addTarget:self action:@selector(stopPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.record = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.record setTitle:@"Record" forState:UIControlStateNormal];
    self.record.translatesAutoresizingMaskIntoConstraints = NO;
    [self.record addTarget:self action:@selector(recordPressed) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:self.play];
    [view addSubview:self.stop];
    [view addSubview:self.record];
    view.backgroundColor = [UIColor whiteColor];

    self.view = view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.recorded) {
        NSData *data  = [NSData dataWithContentsOfURL:self.outputFileURL];
        _rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] displayText:self.outputFileURL.lastPathComponent];
    }
}

- (void)setConstraints {
    NSDictionary *views = @{
                            @"play": self.play,
                            @"stop": self.stop,
                            @"record": self.record
                            };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[record]-10-[stop]-10-[play]-50-|" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.play
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stop
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.record
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)setupAudio {
    self.play.enabled = NO;
    self.stop.enabled = NO;

    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"Audio%d.m4a", rand() % 1000],
                               nil];
    self.outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error opening session");
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];

    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    error = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:self.outputFileURL settings:recordSetting error:&error];
    if (error) {
        NSLog(@"Error opening recorder");
        [self.navigationController popViewControllerAnimated:YES];
    }
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)recordPressed {
    if (player.playing) {
        [player stop];
    }
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [recorder record];
        [self.record setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [recorder pause];
        [self.record setTitle:@"Record" forState:UIControlStateNormal];
    }
    self.stop.enabled = YES;
    self.play.enabled = NO;
}

- (void)stopPressed {
    self.recorded = YES;
    [recorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

- (void)playPressed {
    if (!recorder.recording) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        player.delegate = self;
        [player play];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.record setTitle:@"Record" forState:UIControlStateNormal];
    
    self.stop.enabled = NO;
    self.play.enabled = YES;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
