//
//  MBProgressExtension.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MBProgressExtension.h"
#import "MBProgressHUD.h"

@implementation MBProgressExtension

+ (void)showBlockWithTitle:(NSString *)title inView:(UIView *)view {
    [[MBProgressHUD showHUDAddedTo:view animated:YES] setLabelText:title];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

+ (void)showBlockWithDetailTitle:(NSString *)detailTitle inView:(UIView *)view {
    [[MBProgressHUD showHUDAddedTo:view animated:YES] setDetailsLabelText:detailTitle];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

+ (void)hideActivityIndicatorInView:(UIView *)view {
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

+ (void)showSucessWithTitle:(NSString *)title inView:(UIView *)view {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = title;
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

@end
