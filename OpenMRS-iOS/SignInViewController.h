//
//  SignInViewController.h
//  OpenMRS-iOS
//
//  Created by Parker Erway on 12/1/14.
//  
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *hostTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@end
