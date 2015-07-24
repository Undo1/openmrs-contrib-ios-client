//
//  ImageTypeMenu.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/24/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageTypeMenu.h"

@interface ImageTypeMenu ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation ImageTypeMenu

@synthesize rowDescriptor = _rowDescriptor;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initForm];
    }
    return self;
}

- (void)initForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Choose Image", @"Title choose image")];
    
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ImageName" rowType:XLFormRowDescriptorTypeText title:@""];
    row.disabled = @YES;
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Camera" rowType:XLFormRowDescriptorTypeButton title:@"Camera"];
    row.action.formSelector = @selector(initCamera);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"CameraRoll" rowType:XLFormRowDescriptorTypeButton title:@"Camera Roll"];
    row.action.formSelector = @selector(initCameraRoll);
    [section addFormRow:row];
    
    self.form = form;
}

- (void)initCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self.navigationController pushViewController:imagePicker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                                        message:NSLocalizedString(@"Camera not available", @"Warning message camera not available")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button label")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)initCameraRoll {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)updateValues:(NSString *)filename {
    XLFormSectionDescriptor *section = self.form.formSections[0];
    XLFormRowDescriptor *row = section.formRows[0];
    row.value = filename;
    [self reloadFormRow:row];
    
    NSData *imageData = UIImagePNGRepresentation(self.image);
    _rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:[imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength] displayText:filename];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;

    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSString *filename = [imageRep filename];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateValues:filename];
        });
    };
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
