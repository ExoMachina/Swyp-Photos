//
// Copyright 2009 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#define SRELS RELEASE_SAFELY
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

typedef enum {
	UIViewAnimationDirectionRight = 1 << 0,
    UIViewAnimationDirectionLeft  = 1 << 1,
	UIViewAnimationDirectionUp    = 1 << 2,
    UIViewAnimationDirectionDown  = 1 << 3
} UIViewAnimationDirection;

@interface UIView (exoCategory)


/**animation**/

/*
 UpdatePushAnimation
 
 screenshots "existingView"
 updates view with exact function in "updateBlock"
 if "nextViewGrabBlockOrNil" is passed, it uses it to grab the view to make the transition with, otherwise it reuses "existingView"
 
 finally, it moves the views in the direction that you set in "animationDirection" to make the screenshot of the "existingView" look like it's being pushed
 */

+(void)performPageSwitchAnimationWithExistingView:(UIView*)existingView viewUpdateBlock:(void (^)(void))updateBlock nextViewGrabBlock:(UIView* (^)(void))nextViewGrabBlockOrNil direction:(UIViewAnimationDirection)animationDirection;


/**keyboard**/

+(BOOL)keyboardIsTransparent;
+(CGSize)currentKeyboardSize;
+(UIView*)keyboardView;
+(void)setKeyboardTransparent:(BOOL)transparent animated:(BOOL)animated;
+(void)makeKeyboardTransparent;


+(void)setKeyboardSlideTransparencyEnable:(BOOL)enable;
/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property(nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property(nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property(nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property(nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property(nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property(nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property(nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property(nonatomic) CGFloat centerY;

/**
 * Return the x coordinate on the screen.
 */
@property(nonatomic,readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property(nonatomic,readonly) CGFloat ttScreenY;

#ifdef DEBUG

/**
 * Return the x coordinate on the screen.
 *
 * This method is being rejected by Apple due to false-positive private api static analysis.
 *
 * @deprecated
 */
@property(nonatomic,readonly) CGFloat screenX __TTDEPRECATED_METHOD;

/**
 * Return the y coordinate on the screen.
 *
 * This method is being rejected by Apple due to false-positive private api static analysis.
 *
 * @deprecated
 */
@property(nonatomic,readonly) CGFloat screenY __TTDEPRECATED_METHOD;

#endif

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property(nonatomic,readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property(nonatomic,readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property(nonatomic,readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property(nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property(nonatomic) CGSize size;

/**
 * Return the width in portrait or the height in landscape.
 */
@property(nonatomic,readonly) CGFloat orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property(nonatomic,readonly) CGFloat orientationHeight;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;


/**
 * Calculates the offset of this view from another view in screen coordinates.
 *
 * otherView should be a parent view of this view.
 */
- (CGPoint)offsetFromView:(UIView*)otherView;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;

@end
