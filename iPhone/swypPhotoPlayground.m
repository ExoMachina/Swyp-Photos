//
//  swypPhotoPlayground.m
//  swypPhotos
//
//  Created by Alexander List on 10/9/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import "swypPhotoPlayground.h"

@implementation swypPhotoPlayground


#pragma mark UIViewController
-(id) init{
	if (self = [super initWithNibName:nil bundle:nil]){
		_viewTilesByIndex =	[[NSMutableDictionary alloc] init];
	}
	return self;
}
-(void) viewDidLoad{
	[super viewDidLoad];
	[self.view setClipsToBounds:FALSE];
	
	_tiledContentViewController = [[exoTiledContentViewController alloc] initWithDisplayFrame:CGRectMake(0, 0, 320, 480) tileContentControllerDelegate:self withCenteredTilesSized:CGSizeMake(150, 150) andMargins:CGSizeMake(30, 35)];
	[_tiledContentViewController.view setClipsToBounds:FALSE];
	[self.view addSubview:_tiledContentViewController.view];
}

-(void) dealloc{
	SRELS(_tiledContentViewController);
	SRELS(_viewTilesByIndex);
	
	[super dealloc];
}

-(void)		setViewTile:(UIView*)view forTileIndex: (NSUInteger)tileIndex{
	if (view == nil){
		[_viewTilesByIndex removeObjectForKey:[NSNumber numberWithInt:tileIndex]];
	}else{
		[_viewTilesByIndex setObject:view forKey:[NSNumber numberWithInt:tileIndex]];
	}
}
-(UIView*)	viewForTileIndex:(NSUInteger)tileIndex{
	
	return 	[_viewTilesByIndex objectForKey:[NSNumber numberWithInt:tileIndex]];
}

#pragma mark delegation
#pragma mark gestures
-(void)		contentPanOccuredWithRecognizer: (UIPanGestureRecognizer*) recognizer{
	
	if ([recognizer state] == UIGestureRecognizerStateBegan){
		
	}else if ([recognizer state] == UIGestureRecognizerStateChanged){
		[[recognizer view] setFrame:CGRectApplyAffineTransform([[recognizer view] frame], CGAffineTransformMakeTranslation([recognizer translationInView:self.view].x, [recognizer translationInView:self.view].y))];
		[recognizer setTranslation:CGPointZero inView:self.view];
		
	}else if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateFailed || [recognizer state] == UIGestureRecognizerStateCancelled){
		
	}
}

#pragma mark exoTiledContentViewControllerContentDelegate
-(NSInteger)tileCountForTiledContentController:(exoTiledContentViewController*)tileContentController{
	return [_contentDisplayControllerDelegate totalContentCountInController:self];
}
-(UIView*)tileViewAtIndex:(NSInteger)tileIndex forTiledContentController:(exoTiledContentViewController*)tileContentController{
	UIImageView * photoTileView =	(UIImageView*)[self viewForTileIndex:tileIndex];
	if (photoTileView == nil){
		photoTileView	=	[[UIImageView alloc] initWithImage:[_contentDisplayControllerDelegate imageForContentAtIndex:tileIndex inController:self]];
		[photoTileView setUserInteractionEnabled:TRUE];
		UIPanGestureRecognizer * dragRecognizer		=	[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentPanOccuredWithRecognizer:)];
		[photoTileView addGestureRecognizer:dragRecognizer];
		SRELS(dragRecognizer);
		[self setViewTile:photoTileView forTileIndex:tileIndex];
		[photoTileView release];
	}
	
	return photoTileView;
}
										

#pragma mark swypContentDisplayViewController <NSObject>
-(void)	removeContentFromDisplayAtIndex:	(NSUInteger)removeIndex animated:(BOOL)animate{
	[_viewTilesByIndex removeAllObjects];
	[_tiledContentViewController reloadTileObjectData];
}
-(void)	insertContentToDisplayAtIndex:		(NSUInteger)insertIndex animated:(BOOL)animate{
	[_viewTilesByIndex removeAllObjects];
	[_tiledContentViewController reloadTileObjectData];
}

-(void)	setContentDisplayControllerDelegate: (id<swypContentDisplayViewControllerDelegate>)contentDisplayControllerDelegate{
	_contentDisplayControllerDelegate = contentDisplayControllerDelegate;
}
-(id<swypContentDisplayViewControllerDelegate>)	contentDisplayControllerDelegate{
	return _contentDisplayControllerDelegate;
}

-(void)	reloadAllData{
	[_viewTilesByIndex removeAllObjects];
	[_tiledContentViewController reloadTileObjectData];
}

-(void)	returnContentAtIndexToNormalLocation:	(NSInteger)index	animated:(BOOL)animate{
	if (animate){
		[UIView animateWithDuration:.5 animations:^{
			[[self tileViewAtIndex:index forTiledContentController:_tiledContentViewController] setFrame:[_tiledContentViewController frameForTileNumber:index]];
		}];
	}else{
		[[self tileViewAtIndex:index forTiledContentController:_tiledContentViewController] setFrame:[_tiledContentViewController frameForTileNumber:index]];		
	}
}

@end
