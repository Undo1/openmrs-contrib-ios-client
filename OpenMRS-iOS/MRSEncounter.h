//
//  MRSEncounter.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/2/14.
//

#import <Foundation/Foundation.h>

@interface MRSEncounter : NSObject <NSCoding>
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSArray *obs;
@end