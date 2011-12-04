//
//  grabPhotosViewController.h
//  swypPhotos
//
//  Created by Alexander List on 12/3/11.
//  Copyright (c) 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import <libswyp/libswyp.h>

@class grabPhotosViewController;
@interface grabPhotosViewController : UIViewController <swypWorkspaceDelegate,ELCImagePickerControllerDelegate> {
	
	ELCImagePickerController *		_imagePicker;
	
	swypWorkspaceViewController *	_swypWorkspace;
}
@property (nonatomic, readonly) swypWorkspaceViewController * swypWorkspace;

@end
