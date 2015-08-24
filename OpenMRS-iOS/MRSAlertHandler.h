//
//  MRSErrorHandler.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MRSAlertHandler : NSObject

+ (UIAlertView *)alertForNoInternet:(id)sender;
+ (UIAlertView *)alertForSucess:(id)sender;
+ (UIAlertView *)alertforTimeOut:(id)sender;
+ (UIAlertView *)alertForNotRecoginzedError:(id)sender;
+ (UIAlertView *)alertViewForError:(id)sender error:(NSError *) error;
+ (UIAlertView *)alertForServerNotFound:(id)sender;
+ (UIAlertView *)alertViewForErrorBadRequest:(id)sender error:(NSError *)error;
@end
