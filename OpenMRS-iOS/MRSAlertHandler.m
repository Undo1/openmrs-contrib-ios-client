//
//  MRSErrorHandler.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSAlertHandler.h"

@implementation MRSAlertHandler

+ (UIAlertView *)alertForNoInternet:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error") message:NSLocalizedString(@"You are not connected to the internet", @"Warning message for no internet conneciton") delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertForSucess:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sent", @"Label sent") message:@"" delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertForNotRecoginzedError:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error") message:NSLocalizedString(@"Oops! something went wrong!", @"Warning message for unrecognized error") delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertViewForError:(id)sender error:(NSError *) error {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"]
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSLog(@"json message: %@", json);
    NSString *errorMessage = json[@"error"][@"message"];
    NSString *errorDescription;
    NSDictionary *fieldErrors = json[@"error"][@"fieldErrors"];
    if (fieldErrors.count > 0) {
        NSMutableArray *messages = [NSMutableArray array];
        for (NSString *key in fieldErrors) {
            for (NSDictionary *dict in fieldErrors[key]) {
                [messages addObject:dict[@"message"]];
            }
        }
        errorDescription = [messages componentsJoinedByString:@", "];
    } else {
        NSDictionary *globalErrors = json[@"error"][@"globalErrors"];
        NSMutableArray *messages = [NSMutableArray array];
        for (NSDictionary *dict in globalErrors) {
            [messages addObject:dict[@"message"]];
        }
        errorDescription = [messages componentsJoinedByString:@", "];
    }
    UIAlertView *requestError = [[UIAlertView alloc] initWithTitle:errorMessage message:errorDescription delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
    return requestError;
}

@end
