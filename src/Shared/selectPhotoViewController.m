//
//  selectPhotoViewController.m
//  swypPhotos
//
//  Created by Alexander List on 10/11/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "selectPhotoViewController.h"
#import "swypPhotoPlayground.h"

NSString * const swypPhotosWorkspaceIdentifier = @"com.exomachina.swypphotos.main";

@implementation selectPhotoViewController
@synthesize swypWorkspace = _swypWorkspace;
#pragma mark - Delegation 
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	UIImage * selectedImage	=	[info valueForKey:UIImagePickerControllerEditedImage];
	
	if (selectedImage == nil){
		selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
		CGFloat smallestDemension = ([selectedImage size].width <[selectedImage size].height)? [selectedImage size].width:[selectedImage size].height;
		
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(smallestDemension, smallestDemension), NO, [[UIScreen mainScreen] scale]);
		[selectedImage drawInRect:CGRectMake(0,0,[selectedImage size].width,[selectedImage size].height)];
		selectedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	swypPhotoArrayDatasource * photoDataSource	= (swypPhotoArrayDatasource *)	[[[self swypWorkspace] contentManager] contentDataSource];
	//just trust that it still is
	[photoDataSource addPhotoData:UIImagePNGRepresentation(selectedImage) atIndex:0];
	
	if (_imagePickerPopover){
		[_imagePickerPopover dismissPopoverAnimated:TRUE];
	}else{
		[self dismissModalViewControllerAnimated:TRUE];
		[self.view addSubview:_swypWorkspace.view];
		[UIView animateWithDuration:.75 delay:.75 options:0 animations:^{
			[_swypWorkspace.view setAlpha:1];
		} completion:nil];		
	}
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	if (_imagePickerPopover){
		[_imagePickerPopover dismissPopoverAnimated:TRUE];
	}else{
		[self dismissModalViewControllerAnimated:TRUE];
		[self.view addSubview:_swypWorkspace.view];
		[UIView animateWithDuration:.75 delay:.75 options:0 animations:^{
			[_swypWorkspace.view setAlpha:1];
		} completion:nil];		
	}
}

#pragma mark swypWorkspaceDelegate
-(void)	delegateShouldDismissSwypWorkspace: (swypWorkspaceViewController*)workspace{
	

	UIImagePickerController * imagePicker	=	[[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	if (_mode == selectPhotoViewContollerModeCamera){
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[imagePicker setShowsCameraControls:TRUE];
		[imagePicker setAllowsEditing:TRUE];
	}else{
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
	}
	
	
	if (deviceIsPad){
		//ipads must display popover
		if (_imagePickerPopover == nil){
			_imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		}
		[_imagePickerPopover setContentViewController:imagePicker];
		[_imagePickerPopover presentPopoverFromRect:CGRectMake(_swypWorkspace.view.frame.size.width/2, 30, _swypWorkspace.view.frame.size.width/2, _swypWorkspace.view.frame.size.height/2) inView:_swypWorkspace.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:FALSE];
	}else{
		[UIView animateWithDuration:.75 animations:^{
			[_swypWorkspace.view setAlpha:0];
		}completion:^(BOOL completed){
			[_swypWorkspace.view removeFromSuperview];
				[self presentModalViewController:imagePicker animated:TRUE];					
		}];
	}

	
}


#pragma mark - NSObject
-(id)	initWithControllerMode:(selectPhotoViewContollerMode)mode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
		_mode	=	mode;
    }
    return self;
}
-(void)	dealloc{
	SRELS(_imagePickerPopover);
	SRELS(_swypWorkspace);
	
	[super dealloc];
}

#pragma mark - ViewController lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{	
    [super viewDidLoad];
	
	_swypWorkspace	=	[[swypWorkspaceViewController alloc] initWithWorkspaceDelegate:self];
	[_swypWorkspace.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[_swypWorkspace.view setFrame:self.view.bounds];
	
	[_swypWorkspace setShowContentWithoutConnection:TRUE];
	
	swypPhotoArrayDatasource	* mainPhotoDataSource	= nil;
	
	if (_mode == selectPhotoViewContollerModeCamera){
		mainPhotoDataSource =  [[swypPhotoArrayDatasource alloc] initWithImageDataArray:nil];//[NSArray arrayWithObject:UIImagePNGRepresentation([UIImage imageNamed:@"swypPhotosStylizedIconHuge.png"])]
	}else{
		mainPhotoDataSource	=	[[swypPhotoArrayDatasource alloc] initWithImageDataArray:[NSArray arrayWithObject:UIImagePNGRepresentation([UIImage imageNamed:@"swypPhotosIconHuge.png"])]];
	}

	[[[self swypWorkspace] contentManager] setContentDataSource:mainPhotoDataSource];
	SRELS(mainPhotoDataSource);
	
	swypPhotoPlayground *	contentDisplayController	=	[[swypPhotoPlayground alloc] initWithPhotoSize:CGSizeMake(225, 225)];
	//work on proper sizing soon
	
	CGRect contentRect	=	CGRectMake(0,0, [self.view bounds].size.width,[self.view bounds].size.height);
	[contentDisplayController.view setFrame:contentRect];
	[contentDisplayController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[[[self swypWorkspace] contentManager] setContentDisplayController:contentDisplayController];
	SRELS(contentDisplayController);


	//if you need to display the Swyp workspace immediately,
	//be careful that presenting a modal view before the app's view hiarchy
	//loads causes bugs like having no subviews appear in the modal view
	//here I've added the workspace as a subview
	
	//hint: if you *only* add as sub-*view* then it wont receive rotation events
	//		instead we also add as childviewcontroller
	[self addChildViewController:_swypWorkspace];
	[self.view addSubview:_swypWorkspace.view];
		
	//but you can also delay with the following cludge-ish code:
//	NSBlockOperation *	modalPresentOp	=	[NSBlockOperation blockOperationWithBlock:^{
//		[self presentModalViewController:_swypWorkspace animated:TRUE];
//	}];
//	[NSTimer scheduledTimerWithTimeInterval:.2 target:modalPresentOp selector:@selector(start) userInfo:nil repeats:NO];

}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
