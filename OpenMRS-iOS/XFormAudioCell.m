//
//  XFormAudioCell.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormAudioCell.h"
#import "Base64.h"

NSString * const XLFormRowDescriptorTypeAudioInLine = @"AudioInLine";

@interface XFormAudioCell () {
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
}

@property (nonatomic, strong) NSURL *outputFileURL;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIButton *record;
@property (nonatomic, strong) UIButton *play;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIButton *remove;
@property (nonatomic) BOOL recorded;

@property (nonatomic, strong) NSData *audioData;

@end

@implementation XFormAudioCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XFormAudioCell class] forKey:XLFormRowDescriptorTypeAudioInLine];
}

- (void)update {
    [super update];
    self.title.text = self.rowDescriptor.title;

    if (self.rowDescriptor.sectionDescriptor.formDescriptor.isDisabled) {
        self.record.enabled = NO;
        self.remove.enabled = NO;
    } else {
        self.record.enabled = YES;
        self.remove.enabled = YES;
    }
    if (self.rowDescriptor.value && !self.audioData) {
        XLFormOptionsObject *opObj = self.rowDescriptor.value;
        self.audioData = [NSData dataWithBase64EncodedString:opObj.valueData];
        if (self.audioData) {
            self.play.enabled = YES;
        }
    }
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureViews];
    [self configureContraints];
    [self setupAudio];
}

- (void)configureViews {
    self.title = [[UILabel alloc] init];
    self.title.text = self.rowDescriptor.title;
    self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.title sizeToFit];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.title];
    
    
    self.middleView = [[UIView alloc] init];
    
    self.record = [[UIButton alloc] init];
    [self.record addTarget:self action:@selector(recordPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.record setBackgroundImage:[UIImage imageNamed:@"reocrd_plain"] forState:UIControlStateNormal];
    [self.record setTitle:NSLocalizedString(@"Record", @"Label record") forState:UIControlStateNormal];
    [self.record setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.record setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.record.translatesAutoresizingMaskIntoConstraints = NO;
    [self.middleView addSubview:self.record];

    self.play = [[UIButton alloc] init];
    [self.play addTarget:self action:@selector(playPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.play setBackgroundImage:[UIImage imageNamed:@"play_button_active"] forState:UIControlStateNormal];
    [self.play setBackgroundImage:[UIImage imageNamed:@"play_button_disabled"] forState:UIControlStateDisabled];
    self.play.translatesAutoresizingMaskIntoConstraints = NO;
    self.play.enabled = NO;
    [self.middleView addSubview:self.play];
    
    self.middleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.middleView];
    
    self.remove = [[UIButton alloc] init];
    [self.remove addTarget:self action:@selector(removePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.remove setTitle:NSLocalizedString(@"Remove", @"Label remove") forState:UIControlStateNormal];
    [self.remove setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.remove setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    self.remove.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.remove];
}

- (void)configureContraints {
    NSDictionary *viewsDict = @{
                                @"title": self.title,
                                @"middleView": self.middleView,
                                @"record": self.record,
                                @"play": self.play,
                                @"remove": self.remove
                                };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[title(35)]-5-[middleView(100)]-10-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[record(100)]-20-[play(100)]-5-|" options:0 metrics:nil views:viewsDict]];
    [self.middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[record]-5-|" options:0 metrics:nil views:viewsDict]];
    [self.middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[play]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[title]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.middleView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
}


- (void)setupAudio {
    self.play.enabled = NO;
    
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
        [self.formViewController.navigationController popViewControllerAnimated:YES];
    }
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    error = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:self.outputFileURL settings:recordSetting error:&error];
    if (error) {
        NSLog(@"Error opening recorder");
        [self.formViewController.navigationController popViewControllerAnimated:YES];
    }
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)recordPressed {
    if (player.playing) {
        [player stop];
        self.play.enabled = NO;
    }
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [recorder record];
        [self.record setTitle:@"Stop" forState:UIControlStateNormal];
        self.recorded = YES;
        self.play.enabled = NO;
    } else {
        self.recorded = YES;
        [recorder stop];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
        self.play.enabled = YES;
        [self.record setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (void)playPressed {
    if (!recorder.recording) {
        if (self.audioData) {
            player = [[AVAudioPlayer alloc] initWithData:self.audioData error:nil];
        } else {
            if (!self.rowDescriptor.sectionDescriptor.formDescriptor.disabled) {
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
            }
        }
        if (!player) {
            return;
        }
        player.delegate = self;
        [player play];
        self.play.enabled = NO;
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.play.enabled = YES;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.record setTitle:@"Record" forState:UIControlStateNormal];
    
    NSData *data  = [NSData dataWithContentsOfURL:self.outputFileURL];
    self.rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] displayText:self.outputFileURL.lastPathComponent];
    self.play.enabled = YES;
}

- (void)removePressed {
    [[NSFileManager defaultManager] removeItemAtURL:self.outputFileURL error:nil];
    self.rowDescriptor.value = nil;
    self.recorded = NO;
    self.play.enabled = NO;
    [self setupAudio];
}

@end
