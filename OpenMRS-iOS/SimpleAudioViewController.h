//
//  SimpleAudioViewController.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/24/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XLForm.h"

@interface SimpleAudioViewController : UIViewController <UINavigationControllerDelegate, XLFormRowDescriptorViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@end
