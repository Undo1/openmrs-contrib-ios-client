//
//  MRSErrorHandler.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "MRSAlertHandler.h"
#import "Constants.h"

@implementation MRSAlertHandler

+ (UIAlertView *)alertViewForError:(id)sender error:(NSError *) error {
    NSLog(@"error: %@", error);
    NSLog(@"error userinfo(%ld): %@", (long)error.code,error.userInfo);
    if (error.code == errNoInternet || error.code == errNetWorkLost || error.code == errNetworkDown || error.code == errCanNotConnect) {
        return [MRSAlertHandler alertForNoInternet:sender];
    } else if (error.code == errBadRequest) {
        return [MRSAlertHandler alertViewForErrorBadRequest:sender error:error];
    } else if (error.code == errServerNotFound) {
        return [MRSAlertHandler alertForServerNotFound:sender];
    } else if (error.code == errTimeout) {
        return [MRSAlertHandler alertforTimeOut:sender];
    } else {
        return [MRSAlertHandler alertForNotRecoginzedError:sender];
    }
}

+ (UIAlertView *)alertForNoInternet:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error") message:NSLocalizedString(@"You are not connected to the internet", @"Warning message for no internet conneciton") delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertforTimeOut:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error") message:NSLocalizedString(@"Seems the Server is hanging up, Please check back later.", @"Warning request timed out") delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertForServerNotFound:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error") message:[NSString stringWithFormat:@"OpenMRS %@", NSLocalizedString(@"server not found", "Warning server not found")] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertForSucess:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sent", @"Label sent") message:@"" delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertForNotRecoginzedError:(id)sender {
    return [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error") message:NSLocalizedString(@"Oops! something went wrong!", @"Warning message for unrecognized error") delegate:sender cancelButtonTitle:@"OK" otherButtonTitles: nil];
}

+ (UIAlertView *)alertViewForErrorBadRequest:(id)sender error:(NSError *)error {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"]
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSLog(@"json: %@", [[NSString alloc] initWithData:[error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding]);
    NSLog(@"json message: %@", json);
    if (!json) {
        return [MRSAlertHandler alertForNotRecoginzedError:sender];
    }
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
    if ([errorDescription isEqualToString:@""]) {
        errorDescription = errorMessage;
    }
    UIAlertView *requestError = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Something went wrong", @"warning title something went wrong")
                                                           message:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Server error", @"Label server error"), errorDescription]
                                                          delegate:sender
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
    return requestError;
}

@end
