//
//  AppDelegate.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AFHTTPRequestOperation *currentSearchOperation;

@end

