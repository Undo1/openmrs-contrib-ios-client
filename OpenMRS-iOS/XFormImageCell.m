//
//  XFormImageCell.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormImageCell.h"
NSString * const XLFormRowDescriptorTypeImageInLine = @"ImageInLine";

@interface XFormImageCell ()

@property (nonatomic, strong) UIButton *gallery;
@property (nonatomic, strong) UIButton *camera;
@property (nonatomic, strong) UIButton *remove;
@property (nonatomic, strong) UIImageView *imageSelected;

@end

@implementation XFormImageCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XFormImageCell class] forKey:XLFormRowDescriptorTypeImageInLine];
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureView];
    [self configureConstraints];
}

- (void)configureView {
    self.gallery = [[UIButton alloc] init];
    [self.gallery setTitle:NSLocalizedString(@"Gallery", @"Label gallery") forState:UIControlStateNormal];
    [self.gallery addTarget:self action:@selector(initCameraRoll) forControlEvents:UIControlEventTouchUpInside];
    self.gallery.translatesAutoresizingMaskIntoConstraints = NO;
    [self.gallery setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.gallery.layer.borderWidth = 0.25;
    self.gallery.layer.borderColor = [UIColor grayColor].CGColor;
    [self.contentView addSubview:self.gallery];
    
    self.camera = [[UIButton alloc] init];
    [self.camera setTitle:NSLocalizedString(@"Camera", @"Label camera") forState:UIControlStateNormal];
    [self.camera addTarget:self action:@selector(initCamera) forControlEvents:UIControlEventTouchUpInside];
    self.camera.translatesAutoresizingMaskIntoConstraints = NO;
    [self.camera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.camera.layer.borderWidth = 0.25;
    self.camera.layer.borderColor = [UIColor grayColor].CGColor;
    [self.contentView addSubview:self.camera];
    
    self.imageSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-image"]];
    self.imageSelected.contentMode = UIViewContentModeScaleAspectFit;
    self.imageSelected.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageSelected.backgroundColor = [UIColor colorWithRed:235.0/256 green:235.0/256 blue:241.0/256 alpha:1];
    [self.contentView addSubview:self.imageSelected];
    
    self.remove = [[UIButton alloc] init];
    [self.remove setTitle:NSLocalizedString(@"Remove", @"Label remove") forState:UIControlStateNormal];
    [self.remove setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.remove addTarget:self action:@selector(removeImage) forControlEvents:UIControlEventTouchUpInside];
    self.remove.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.remove];
}

- (void)configureConstraints {
    NSDictionary *viewsDict = @{
                                @"gallery": self.gallery,
                                @"camera": self.camera,
                                @"image": self.imageSelected,
                                @"remove": self.remove
                                };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[gallery]-0-[camera]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[image]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[gallery]-0-[image(150)]-5-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.gallery attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.camera attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

- (void)initCameraRoll {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self.formViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)initCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self.formViewController presentViewController:imagePicker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                                        message:NSLocalizedString(@"Camera not available", @"Warning message camera not available")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button label")
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)removeImage {
    self.image = nil;
    self.imageSelected.image = [UIImage imageNamed:@"no-image"];
}

- (void)update {
    [super update];
}

- (void)setImage:(UIImage *)image {
    if (image) {
        self.imageSelected.image = image;
    } else {
        self.imageSelected.image = [UIImage imageNamed:@"no-image"];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    self.rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:[imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] displayText:@""];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;

    [self.formViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
