//
//  MRSPatientIdentifiertype.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/11/14.
//

#import <Foundation/Foundation.h>

@interface MRSPatientIdentifierType : NSObject <NSCoding>
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *typeDescription;
@end
