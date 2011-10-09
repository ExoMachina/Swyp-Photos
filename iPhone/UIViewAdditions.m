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

#import "UIViewAdditions.h"
@implementation UIView (exoCategory)





+(void)performPageSwitchAnimationWithExistingView:(UIView*)existingView viewUpdateBlock:(void (^)(void))updateBlock nextViewGrabBlock:(UIView* (^)(void))nextViewGrabBlockOrNil direction:(UIViewAnimationDirection)animationDirection{
	
	CGPoint previousOrigin = existingView.frame.origin;
	
	CGSize layerSize = existingView.frame.size;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef previousImageContext = CGBitmapContextCreate(NULL, (int)layerSize.width, (int)layerSize.height, 8, (int)layerSize.width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	CGContextTranslateCTM(previousImageContext, 0, layerSize.height);
	CGContextScaleCTM(previousImageContext, 1.0, -1.0);
	
	[existingView.layer renderInContext:previousImageContext];	
	
	CGImageRef previousLayerImage = CGBitmapContextCreateImage(previousImageContext);
	
	UIGraphicsEndImageContext();	
	CGContextRelease(previousImageContext);
	CGColorSpaceRelease(colorSpace);
	
	UIImageView *animationImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:previousLayerImage]];
	
	CGImageRelease(previousLayerImage);
	
	
	[animationImageView setOrigin:previousOrigin];
		
	updateBlock();

	UIView *nextView = nil;
	if (nextViewGrabBlockOrNil != nil){
		nextView = nextViewGrabBlockOrNil();
	}
	
	if (nextView == nil)
		nextView = existingView;
	
	[nextView.superview insertSubview:animationImageView aboveSubview:nextView];
	
	if (animationDirection == UIViewAnimationDirectionRight){
		[nextView setOrigin:CGPointMake(-1*existingView.size.width, existingView.frame.origin.y)];

	}else if (animationDirection == UIViewAnimationDirectionLeft){
		[nextView setOrigin:CGPointMake(existingView.size.width, existingView.frame.origin.y)];
		
	}else if (animationDirection == UIViewAnimationDirectionDown){
		[nextView setOrigin:CGPointMake(existingView.frame.origin.x, -1* existingView.frame.size.height)];
		
	}else if (animationDirection == UIViewAnimationDirectionUp){
		[nextView setOrigin:CGPointMake(existingView.frame.origin.x, existingView.frame.size.height)];
		
	}
	
	
	[UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{ 
		[nextView setOrigin:previousOrigin];
		
		if (animationDirection == UIViewAnimationDirectionRight){
			[animationImageView setOrigin:CGPointMake(animationImageView.width, animationImageView.frame.origin.y)];	
			
		}else if (animationDirection == UIViewAnimationDirectionLeft){
			[animationImageView setOrigin:CGPointMake(-1*animationImageView.width, animationImageView.frame.origin.y)];	
			
		}else if (animationDirection == UIViewAnimationDirectionDown){
			[animationImageView setOrigin:CGPointMake(animationImageView.frame.origin.x, animationImageView.frame.size.height)];	
			
		}else if (animationDirection == UIViewAnimationDirectionUp){
			[animationImageView setOrigin:CGPointMake(animationImageView.frame.origin.x, -1* animationImageView.frame.size.height)];	
			
		}
	}
					 completion: ^(BOOL finnished){
						 [animationImageView removeFromSuperview];
					 }];
	
	SRELS(animationImageView);
	
}


+(CGSize)currentKeyboardSize{
	CGSize keyboardSize = [[UIView keyboardView] frame].size;
	
	return keyboardSize;
}


-(void)keyboardTransparencyPanGestureRecognized:(UIPanGestureRecognizer*)gestureRecognizer{
	if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
		CGPoint change = [gestureRecognizer translationInView:gestureRecognizer.view];
		
		UIView *keyboard = [UIView keyboardView];
		float existingTransparency = [keyboard alpha] * 100;
		float scalledTransparency = (change.x/40 + existingTransparency)/100;
		scalledTransparency = MIN(scalledTransparency, 0.99);
		scalledTransparency = MAX(scalledTransparency, 0.1);
		
		keyboard.alpha = scalledTransparency;
		
	}
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//	UIView *keyboard = [UIView keyboardView];
//	CGPoint touchPoint = [touch locationInView:keyboard];
//	CGRect spaceBarRect = CGRectMake(280, 270, 440, 60);
//	if(CGRectContainsPoint(spaceBarRect, touchPoint)){
//		return YES;
//	}
//	
//	return NO;
//}

+(void)setKeyboardSlideTransparencyEnable:(BOOL)enable{
	
	if ([[[UIApplication sharedApplication] windows] count] <= 1)
		return;
	
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboardHost = nil;
	UIView* keyboard = nil;
	for(keyboardHost in tempWindow.subviews)
	{
		
		//		NSLog(@"View Name: %@",[keyboardHost description]);
		
		if ([[keyboardHost description] hasPrefix:@"<UIPeripheralHostView"] == YES){
			
			for (keyboard in [keyboardHost subviews]){
				
				//				NSLog(@"Subview name: %@",[keyboard description]);
				
				if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES ){
					
					UIView *gestureView = [[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0];	
					
					if (enable){
							
						if ([[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers] count]==1){
							//						[gestureView setBackgroundColor:[UIColor redColor]];
							UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:gestureView action:@selector(keyboardTransparencyPanGestureRecognized:)];
//							[recognizer setDelegate:gestureView];
							[recognizer setMinimumNumberOfTouches:2];
							[recognizer requireGestureRecognizerToFail:[[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers] objectAtIndex:0]];
							[gestureView addGestureRecognizer:recognizer];
							SRELS(recognizer);
							
						}
					}else {
						
						if ([[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers] count]> 1){
							//						[gestureView setBackgroundColor:[UIColor redColor]];
							[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] setGestureRecognizers:[NSArray arrayWithObject:[[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers]objectAtIndex:0]]];
							
						}
					}

					
				}
			}
			
		}
		
		
	}			
	
}

+(UIView*)keyboardView{
	
	if ([[[UIApplication sharedApplication] windows] count] <= 1)
		return nil;
	
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboardHost = nil;
	UIView* keyboard = nil;
	for(keyboardHost in tempWindow.subviews)
	{
		
		//		NSLog(@"View Name: %@",[keyboardHost description]);
		
		if ([[keyboardHost description] hasPrefix:@"<UIPeripheralHostView"] == YES){
			
			for (keyboard in [keyboardHost subviews]){
				
				//				NSLog(@"Subview name: %@",[keyboard description]);
				
				if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES ){
					
//					NSLog(@"Test view:%@",[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers]);
//					UIView *gestureView = [[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0];
//					
//					if ([[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers] count]==1){
////						[gestureView setBackgroundColor:[UIColor redColor]];
//						UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:gestureView action:@selector(keyboardTransparencyPanGestureRecognized:)];
//						[recognizer requireGestureRecognizerToFail:[[[[[[keyboard subviews] objectAtIndex:0] subviews] objectAtIndex:0] gestureRecognizers] objectAtIndex:0]];
//						[gestureView addGestureRecognizer:recognizer];
//						SRELS(recognizer);
//						
//					}
					
					return keyboard;
				}
			}
			
		}
		
		
	}		
	return nil;
}

+(BOOL)keyboardIsTransparent{
	return ([[UIView keyboardView] alpha] != 1);
}

+(void)makeKeyboardTransparent{
	[[UIView keyboardView] setAlpha:.4];
	[self setKeyboardSlideTransparencyEnable:TRUE];
}
						  
+(void)setKeyboardTransparent:(BOOL)transparent animated:(BOOL)animated{
	if (animated){		
		[UIView beginAnimations:@"changeKeyboardTransparent" context:nil];
		[UIView setAnimationBeginsFromCurrentState:TRUE];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:.3];	
	}
	if (transparent){
		UIView *keyboard = [UIView keyboardView];
		if (keyboard != nil){
			[UIView makeKeyboardTransparent];
		}else {
			[[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:.1 target:self selector:@selector(makeKeyboardTransparent) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
		 };

	}else {
		[[UIView keyboardView] setAlpha:1];
	}
	
	if (animated){
		[UIView commitAnimations];
	}
}

- (CGFloat)left {
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}

- (CGFloat)top {
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}

- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
  CGRect frame = self.frame;
  frame.origin.x = right - frame.size.width;
  self.frame = frame;
}

- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
  CGRect frame = self.frame;
  frame.origin.y = bottom - frame.size.height;
  self.frame = frame;
}

- (CGFloat)centerX {
  return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
  self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
  return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
  self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}

/**
 * Return the x coordinate on the screen.
 */
- (CGFloat)ttScreenX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
    x += view.left;
  }
  return x;
}

/**
 * Return the y coordinate on the screen.
 */
- (CGFloat)ttScreenY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;
  }
  return y;
}

#ifdef DEBUG

/**
 * Return the x coordinate on the screen.
 *
 * This method is being rejected by Apple due to false-positive private api static analysis.
 *
 * @deprecated
 */
- (CGFloat)screenX {
  return [self ttScreenX];
}

/**
 * Return the y coordinate on the screen.
 *
 * This method is being rejected by Apple due to false-positive private api static analysis.
 *
 * @deprecated
 */
- (CGFloat)screenY {
  return [self ttScreenY];
}

#endif

- (CGFloat)screenViewX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
      x += view.left;

    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      x -= scrollView.contentOffset.x;
    }
  }
  
  return x;
}

- (CGFloat)screenViewY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;

    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      y -= scrollView.contentOffset.y;
    }
  }
  return y;
}

- (CGRect)screenFrame {
  return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}

- (CGPoint)origin {
  return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
  CGRect frame = self.frame;
  frame.origin = origin;
  self.frame = frame;
}

- (CGSize)size {
  return self.frame.size;
}

- (void)setSize:(CGSize)size {
  CGRect frame = self.frame;
  frame.size = size;
  self.frame = frame;
}

- (CGFloat)orientationWidth {
  return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
    ? self.height : self.width;
}

- (CGFloat)orientationHeight {
  return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
    ? self.width : self.height;
}

- (UIView*)descendantOrSelfWithClass:(Class)cls {
  if ([self isKindOfClass:cls])
    return self;
  
  for (UIView* child in self.subviews) {
    UIView* it = [child descendantOrSelfWithClass:cls];
    if (it)
      return it;
  }
  
  return nil;
}

- (UIView*)ancestorOrSelfWithClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else if (self.superview) {
    return [self.superview ancestorOrSelfWithClass:cls];
  } else {
    return nil;
  }
}

- (void)removeAllSubviews {
  while (self.subviews.count) {
    UIView* child = self.subviews.lastObject;
    [child removeFromSuperview];
  }
}


- (CGPoint)offsetFromView:(UIView*)otherView {
  CGFloat x = 0, y = 0;
  for (UIView* view = self; view && view != otherView; view = view.superview) {
    x += view.left;
    y += view.top;
  }
  return CGPointMake(x, y);
}

- (UIViewController*)viewController {
  for (UIView* next = [self superview]; next; next = next.superview) {
    UIResponder* nextResponder = [next nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController*)nextResponder;
    }
  }
  return nil;
}

@end
