//
//  grabPhotosViewController.m
//  swypPhotos
//
//  Created by Alexander List on 12/3/11.
//  Copyright (c) 2011 ExoMachina. All rights reserved.
//

#import "grabPhotosViewController.h"
#import "cameraEnabledAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

@implementation grabPhotosViewController
@synthesize swypWorkspace = _swypWorkspace;

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(swypWorkspaceViewController*)swypWorkspace{
	if (_swypWorkspace == nil){
		_swypWorkspace	=	[[swypWorkspaceViewController alloc] initWithWorkspaceDelegate:self];
		[_swypWorkspace.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
		[_swypWorkspace.view setFrame:self.view.bounds];
		
		//this just makes it so your photos appear in background before you swyp to another device
		//otherwise you'll be swyping to create a connection, then swyping the image
		[_swypWorkspace setShowContentWithoutConnection:TRUE];

		//this data source will link to the contentdisplayview controller through the content manager
		//We're set as a delegate so we can can save photos we receive in a very simple way,
		//but see the protocols that swypPhotoArrayDatasource conforms to if you want to create custom data sources; EG, for core data
		swypBackedPhotoDataSource *	photoDatasource	= [[swypBackedPhotoDataSource alloc] initWithBackingDelegate:self];	
		//make sure to set the data-source! If there are bugs, you should submit a pull-request!
		[[[self swypWorkspace] contentManager] setContentDataSource:photoDatasource];
		
		//we create our favorite content display controller
		//we'll be adding data later see (elcImagePickerController:didFinishPickingMediaWithInfo:)
		swypPhotoPlayground *	contentDisplayController	=	[[swypPhotoPlayground alloc] initWithPhotoSize:CGSizeMake(140, 200)];

		[[[self swypWorkspace] contentManager] setContentDisplayController:contentDisplayController];
		SRELS(contentDisplayController);
	}
	return _swypWorkspace;
}

-(void) activateSwypButtonPressed:(id)sender{
	if ([[_imagePicker topViewController] isKindOfClass:[ELCAssetTablePicker class]]){
		[(ELCAssetTablePicker*)[_imagePicker topViewController] doneAction:self];
	}
	
	[self presentModalViewController:[self swypWorkspace] animated:TRUE];
}

#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad{
    [super viewDidLoad];
	
	cameraEnabledAlbumPickerController *albumController = [[cameraEnabledAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
	_imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:_imagePicker];
	[_imagePicker setDelegate:self];
	
	[_imagePicker.view setOrigin:CGPointMake(0, -20)];
	
	[self.view addSubview:_imagePicker.view];
	[self addChildViewController:_imagePicker];
	SRELS(albumController);
	
	UIButton *	activateSwypButton	=	[UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *	swypActivateImage	=	[UIImage imageNamed:@"swypPhotosHud"];
	[activateSwypButton setBackgroundImage:swypActivateImage forState:UIControlStateNormal];
	[activateSwypButton setFrame:CGRectMake((self.view.size.width-[swypActivateImage size].width)/2, self.view.size.height-[swypActivateImage size].height, [swypActivateImage size].width, [swypActivateImage size].height)];
	[activateSwypButton addTarget:self action:@selector(activateSwypButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:activateSwypButton];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{

    return YES;
}

#pragma mark - Image resizing for high-speed
-(UIImage*)	constrainImage:(UIImage*)image toSize:(CGSize)maxSize{
	if (image == nil)
		return nil;
	
	CGSize oversize = CGSizeMake([image size].width - maxSize.width, [image size].height - maxSize.height);
	
	CGSize iconSize			=	CGSizeZero;
	
	if (oversize.width > 0 || oversize.height > 0){
		if (oversize.height > oversize.width){
			double scaleQuantity	=	maxSize.height/ image.size.height;
			iconSize		=	CGSizeMake(scaleQuantity * image.size.width, maxSize.height);
		}else{
			double scaleQuantity	=	maxSize.width/ image.size.width;	
			iconSize		=	CGSizeMake(maxSize.width, scaleQuantity * image.size.height);		
		}
	}else{
		return image;
	}
	
	UIGraphicsBeginImageContextWithOptions(iconSize, NO, 1);
	[image drawInRect:CGRectMake(0,0,iconSize.width,iconSize.height)];
	UIImage* constrainedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return constrainedImage;
}

#pragma mark - Delegate 
#pragma mark - PhotoArray
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
	
	if (ArrayHasItems(info) == FALSE)
		return;
	
	//we set the datasource above, see where we init a backed photo datasource
	swypBackedPhotoDataSource *	photoDatasource	= (swypBackedPhotoDataSource*) [[[self swypWorkspace] contentManager] contentDataSource];
	
	[photoDatasource removeAllPhotos];
	for(NSDictionary *dict in info) {
		UIImage *image =	[dict objectForKey:UIImagePickerControllerOriginalImage];
		[photoDatasource addUIImage:[self constrainImage:image toSize:CGSizeMake(1000, 1000)] atIndex:0];
	}
	
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
	
}
#pragma mark - Swyp
-(void)	delegateShouldDismissSwypWorkspace: (swypWorkspaceViewController*)workspace{
	[self dismissModalViewControllerAnimated:TRUE];
}

-(void) swypBackedPhotoDataSourceRecievedPhoto: (UIImage*) photo withDataSource: (swypBackedPhotoDataSource*)dataSource{
	UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
	
	UIView * flashView	= [[UIView alloc] initWithFrame:[self swypWorkspace].view.frame];
	[flashView setBackgroundColor:[UIColor whiteColor]];
	[flashView setAlpha:0];
	[self.swypWorkspace.view addSubview:flashView];
	[flashView autorelease];
	[UIView animateWithDuration:.3 animations:^{
		[flashView setAlpha:1];
	}completion:^(BOOL completed){
		[UIView animateWithDuration:.3 animations:^{
			[flashView setAlpha:0];
		}completion:^(BOOL completed){
			[flashView removeFromSuperview];
		}];
	}];
}


@end
