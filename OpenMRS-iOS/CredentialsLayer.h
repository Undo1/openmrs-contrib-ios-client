//Credentials Layer. Taken from http://stackoverflow.com/a/12440149/1849664

#import "AFHTTPRequestOperationManager.h"

@interface CredentialsLayer : AFHTTPRequestOperationManager

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

+ (CredentialsLayer *)sharedManagerWithHost:(NSString *)host;

@end