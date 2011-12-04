//
//  grabPhotosViewController.m
//  swypPhotos
//
//  Created by Alexander List on 12/3/11.
//  Copyright (c) 2011 ExoMachina. All rights reserved.
//

#import "grabPhotosViewController.h"

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

		swypPhotoPlayground *	contentDisplayController	=	[[swypPhotoPlayground alloc] initWithPhotoSize:CGSizeMake(225, 225)];
		//work on proper sizing soon
		
		CGRect contentRect	=	CGRectMake(0,0, [self.view bounds].size.width,[self.view bounds].size.height);
		[contentDisplayController.view setFrame:contentRect];
		[contentDisplayController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		[[[self swypWorkspace] contentManager] setContentDisplayController:contentDisplayController];
		SRELS(contentDisplayController);
	}
	return _swypWorkspace;
}

-(void) activateSwyp{
	[self presentModalViewController:[self swypWorkspace] animated:TRUE];
}

#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad{
    [super viewDidLoad];
	
	ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
	_imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:_imagePicker];
	[_imagePicker setDelegate:self];
	
	[_imagePicker.view setOrigin:CGPointMake(0, -20)];
	
	[self.view addSubview:_imagePicker.view];
	[self addChildViewController:_imagePicker];
	
	UIButton *	activateSwypButton	=	[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[activateSwypButton setBackgroundColor:[UIColor grayColor]];
	[activateSwypButton setFrame:CGRectMake(0, self.view.size.height-40, self.view.size.width, 40)];
	[activateSwypButton addTarget:self action:@selector(activateSwyp) forControlEvents:UIControlEventTouchUpInside];
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
	
	swypPhotoArrayDatasource *	photoDatasource	= [[swypPhotoArrayDatasource alloc] init];	
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

@end
