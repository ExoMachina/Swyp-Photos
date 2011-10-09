//
//  exoTiledContentViewController.h
//  Fibromyalgia
//
//  Created by Alexander List on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class exoTiledContentViewController;

@protocol exoTiledContentViewControllerContentDelegate<NSObject>
-(NSInteger)tileCountForTiledContentController:(exoTiledContentViewController*)tileContentController;
-(UIView*)tileViewAtIndex:(NSInteger)tileIndex forTiledContentController:(exoTiledContentViewController*)tileContentController;
@end


@interface exoTiledContentViewController : UIViewController {

	id<exoTiledContentViewControllerContentDelegate> _delegate;
	
	CGSize	_tileSize;
	CGSize	_tileMarginSize;
	double	_maxTileRows;
	double	_maxTileColumns;
	CGPoint	_layoutStartPoint;
	CGRect	_tileDisplayFrame; 
	
	NSRange		_displayedTiles;
	NSInteger	_currentPage;
	
	UIView*		_loadingStatusView;
	
	NSMutableSet*	_displayedTileViews;
}
@property (nonatomic, assign) id<exoTiledContentViewControllerContentDelegate>	delegate;

@property (nonatomic, assign) CGSize	tileSize;
@property (nonatomic, assign) CGSize	tileMarginSize;
@property (nonatomic, assign) double	maxTileRows;
@property (nonatomic, assign) double	maxTileColumns;
@property (nonatomic, assign) CGPoint	layoutStartPoint;

//for setting margins & overall size
@property (nonatomic, assign) CGRect	tileDisplayFrame; 

@property (nonatomic, assign) NSRange	displayedTiles;
@property (nonatomic, assign) NSInteger currentPage;


//set hidden as needed, and will create nice spinny loading indicator
//the default is hidden
@property (nonatomic, readonly) UIView*	loadingStatusView;
-(void)		layoutTilePageNumber:(NSInteger)startTilePage;
-(void)		reloadTileObjectData;

-(void)		viewPreviousTilePageAnimated:(BOOL)animate;
-(void)		viewNextTilePageAnimated:(BOOL)animate;

-(id)		initWithDisplayFrame:(CGRect)tileDisplayFrame tileContentControllerDelegate:(id<exoTiledContentViewControllerContentDelegate>)delegate;
-(id)		initWithDisplayFrame:(CGRect)tileDisplayFrame tileContentControllerDelegate:(id<exoTiledContentViewControllerContentDelegate>)delegate withCenteredTilesSized:(CGSize)tileSize andMargins:(CGSize)tileMargins;
-(id)		initWithDisplayFrame:(CGRect)tileDisplayFrame tileContentControllerDelegate:(id<exoTiledContentViewControllerContentDelegate>)delegate withCenteredTilesSized:(CGSize)tileSize withMaxRows:(double)maxRows maxColumns:(double)maxColumns;

-(void)		showLoadingStatusViewWithLabelText:(NSString*)labelText withIndicatorAnimating:(BOOL)animate;

//privateish
-(CGRect)	frameForTileNumber:(NSInteger)tileNumber;

-(NSRange)		tileRangeForPage:(NSInteger)pageNumber needsForwardPagination:(BOOL*)forwardPaginationNeeded needsBackwardPagination:(BOOL*)backwardPaginationNeeded;


-(NSInteger)	tilePageCount;

@end
