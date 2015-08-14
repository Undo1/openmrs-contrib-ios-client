//
//  XFormImageCell.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormImageCell.h"
#import "Base64.h"
NSString * const XLFormRowDescriptorTypeImageInLine = @"ImageInLine";

@interface XFormImageCell ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIButton *gallery;
@property (nonatomic, strong) UIButton *camera;
@property (nonatomic, strong) UIButton *remove;
@property (nonatomic, strong) UIImageView *imageSelected;

@end

@implementation XFormImageCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XFormImageCell class] forKey:XLFormRowDescriptorTypeImageInLine];
}

- (void)update {
    [super update];
    self.title.text = self.rowDescriptor.title;

    if (self.rowDescriptor.sectionDescriptor.formDescriptor.isDisabled) {
        self.gallery.enabled = NO;
        self.camera.enabled = NO;
        self.remove.enabled = NO;
    } else {
        self.gallery.enabled = YES;
        self.camera.enabled = YES;
        self.remove.enabled = YES;
    }
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureView];
    [self configureConstraints];
}

- (void)configureView {
    self.title = [[UILabel alloc] init];
    self.title.text = self.rowDescriptor.title;
    self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.title sizeToFit];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.title];

    self.gallery = [[UIButton alloc] init];
    [self.gallery setTitle:NSLocalizedString(@"Gallery", @"Label gallery") forState:UIControlStateNormal];
    [self.gallery addTarget:self action:@selector(initCameraRoll) forControlEvents:UIControlEventTouchUpInside];
    self.gallery.translatesAutoresizingMaskIntoConstraints = NO;
    [self.gallery setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.gallery];
    
    self.camera = [[UIButton alloc] init];
    [self.camera setTitle:NSLocalizedString(@"Camera", @"Label camera") forState:UIControlStateNormal];
    [self.camera addTarget:self action:@selector(initCamera) forControlEvents:UIControlEventTouchUpInside];
    self.camera.translatesAutoresizingMaskIntoConstraints = NO;
    [self.camera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.camera];
    
    self.imageSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-image"]];
    self.imageSelected.contentMode = UIViewContentModeScaleAspectFit;
    self.imageSelected.translatesAutoresizingMaskIntoConstraints = NO;
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
                                @"title": self.title,
                                @"gallery": self.gallery,
                                @"camera": self.camera,
                                @"image": self.imageSelected,
                                @"remove": self.remove
                                };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[gallery]-0-[camera]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[image]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[title]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[title]-5-[gallery]-5-[image(150)]-5-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
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

- (void)setImage:(UIImage *)image {
    _image = image;
    if (image) {
        self.imageSelected.image = image;
    } else {
        self.imageSelected.image = [UIImage imageNamed:@"no-image"];
        self.rowDescriptor.value = nil;
        return;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    self.rowDescriptor.value = [XLFormOptionsObject formOptionsObjectWithValue:[NSString stringWithFormat:@"%@", [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]] displayText:@""];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self.formViewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)formDescriptorCellCanBecomeFirstResponder {
    if (self.rowDescriptor.sectionDescriptor.formDescriptor.isDisabled) {
        return false;
    } else {
        return true;
    }
}

@end
