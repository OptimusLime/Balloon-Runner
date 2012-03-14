/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCRadioMenu.h"
#import "CCDirector.h"
#import "cocos2d.h"

@implementation CCRadioMenu

@synthesize selectedItemIndex;

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( state_ != kCCMenuStateWaiting ) return NO;
	
	selectedItem_ = [self itemForTouch:touch];
	
	if( selectedItem_ ) 
	{
		[selectedItem_ selected];
		state_ = kCCMenuStateTrackingTouch;
		return YES;
	}
	return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
	for( CCMenuItem* item in children_ ) 
	{
		[item unselected];	
	}
	
	if (selectedItem_)
	{
		[selectedItem_ selected];
		[selectedItem_ activate];
		fallBackItemIndex = selectedItemIndex;
	}
	else
	{
		self.selectedItemIndex = fallBackItemIndex;
	}	
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	for( CCMenuItem* item in children_ ) 
	{
		[item unselected];	
	}
	
	self.selectedItemIndex = fallBackItemIndex;
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem * currentItem = [self itemForTouch:touch];
	CCMenuItem * fallBackItem = (CCMenuItem *) [children_ objectAtIndex:fallBackItemIndex];
	if (currentItem != selectedItem_ && currentItem != fallBackItem) 
	{				
		[selectedItem_ unselected];
		selectedItem_ = currentItem;
		
		if (selectedItem_)
		{		
			[selectedItem_ selected];
		}
		else
		{
			[[children_ objectAtIndex:fallBackItemIndex]selected];
		}
		
	}
}

-(CCMenuItem *) itemForTouch: (UITouch *) touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	int idx = -1;
	
	for( CCMenuItem* item in children_ ) 
	{
		idx++;
		CGPoint local = [item convertToNodeSpace:touchLocation];
		
		CGRect r = [item rect];
		r.origin = CGPointZero;
		
		if( CGRectContainsPoint( r, local ) )
		{
			selectedItemIndex = idx;
			return item;
		}
	}
	
	return nil;
}

-(int) selectedItemIndex
{
	return selectedItemIndex;
}

- (void)setSelectedItemIndex:(int) value 
{
	for( CCMenuItem* item in children_ ) 
	{
		[item unselected];	
	}
	
	selectedItemIndex = value;	
	selectedItem_ = [children_ objectAtIndex:selectedItemIndex];
	
	fallBackItemIndex = selectedItemIndex;
	
	[selectedItem_ selected];      
}

@end
