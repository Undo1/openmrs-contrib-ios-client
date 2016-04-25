//
//  MBProgressExtension.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//

#import "MBProgressExtension.h"
#import "MBProgressHUD.h"

@implementation MBProgressExtension

+ (void)showBlockWithTitle:(NSString *)title inView:(UIView *)view {
    
    MBProgressHUD *hud =[MBProgressHUD HUDForView:view];
    [hud setLabelText:title];
    [hud setGraceTime:1];
    
    [hud show:YES];
    view.userInteractionEnabled = NO;
}

+ (void)showBlockWithDetailTitle:(NSString *)detailTitle inView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    [hud setDetailsLabelText:detailTitle];
    [hud setGraceTime:1];
    
    [hud show:YES];
    view.userInteractionEnabled = NO;
}

+ (void)hideActivityIndicatorInView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
    view.userInteractionEnabled = YES;
}

+ (void)showSucessWithTitle:(NSString *)title inView:(UIView *)view {
    return;
    
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
