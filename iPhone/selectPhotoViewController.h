//
//  selectPhotoViewController.h
//  swypPhotos
//
//  Created by Alexander List on 10/11/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libSwyp/libSwyp.h>

typedef enum{
	selectPhotoViewContollerModeCamera,
	selectPhotoViewContollerModeCameraRoll
}selectPhotoViewContollerMode;

@interface selectPhotoViewController : UIViewController <UIImagePickerControllerDelegate, swypWorkspaceDelegate,UINavigationControllerDelegate>{
	selectPhotoViewContollerMode	_mode;
	
	swypWorkspaceViewController *	_swypWorkspace;
}
@property (nonatomic, readonly) swypWorkspaceViewController * swypWorkspace;

-(id)	initWithControllerMode:(selectPhotoViewContollerMode)mode;

@end
