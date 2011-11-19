//
//  swypPhotoPlayground.h
//  swypPhotos
//
//  Created by Alexander List on 10/9/11.
//  Copyright 2011 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libSwyp/libSwyp.h>
#import "exoTiledContentViewController.h"

@interface swypPhotoPlayground : UIViewController <exoTiledContentViewControllerContentDelegate,swypContentDisplayViewController>{
	exoTiledContentViewController *					_tiledContentViewController;
	
	id<swypContentDisplayViewControllerDelegate>	_contentDisplayControllerDelegate;	
	
	NSMutableDictionary *							_viewTilesByIndex;
	
	CGSize											_photoSize;
}
-(id)		initWithPhotoSize:(CGSize)imageSize;

-(UIView*)	viewForTileIndex:(NSUInteger)tileIndex;
-(void)		setViewTile:(UIView*)view forTileIndex: (NSUInteger)tileIndex;
@end
