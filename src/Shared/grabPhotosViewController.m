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
		
		[_swypWorkspace setShowContentWithoutConnection:TRUE];

		swypPhotoPlayground *	contentDisplayController	=	[[swypPhotoPlayground alloc] initWithPhotoSize:CGSizeMake(200, 200)];
		//work on proper sizing soon
		
		CGRect contentRect	=	CGRectMake(0,0, [self.view bounds].size.width,[self.view bounds].size.height);
		[contentDisplayController.view setFrame:contentRect];
		[contentDisplayController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
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
	
	UIButton *	activateSwypButton	=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[activateSwypButton setBackgroundColor:[UIColor grayColor]];
	[activateSwypButton setFrame:CGRectMake(0, self.view.size.height-40, self.view.size.width, 40)];
	[activateSwypButton addTarget:self action:@selector(activateSwypButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:activateSwypButton];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{

    return YES;
}

#pragma mark - Delegate 
#pragma mark - PhotoArray
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
	
	if (ArrayHasItems(info) == FALSE)
		return;
	
	swypBackedPhotoDataSource *	photoDatasource	= [[swypBackedPhotoDataSource alloc] initWithBackingDelegate:self];	
	for(NSDictionary *dict in info) {
		UIImage *image =	[dict objectForKey:UIImagePickerControllerOriginalImage];
		[photoDatasource addUIImage:image atIndex:0];
	}
	
	[[[self swypWorkspace] contentManager] setContentDataSource:photoDatasource];
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
	[self.view addSubview:flashView];
	[flashView autorelease];
	[UIView animateWithDuration:.1 animations:^{
		[flashView setAlpha:1];
	}completion:^(BOOL completed){
		[UIView animateWithDuration:.1 animations:^{
			[flashView setAlpha:0];
		}completion:^(BOOL completed){
			[flashView removeFromSuperview];
		}];
	}];
}
@end
