//
//  GuiMenu.m
//  CocosSeaLife
//
//  Created by Paul Szerlip on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GuiMenu.h"


@implementation GuiMenu
@synthesize selectedItemIndex;
-(void) registerWithTouchDispatcher
{
	//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:YES];
}
-(id) selectedItem
{
	return selectedItem_;
}
-(void) setSelectedItem:(id) val
{
	selectedItem_ = val;
}
-(void) selectItem:(id) selItem ix:(int) index
{
	[selItem selected];
}
-(void) unselectItem:(id) unItem ix:(int) index
{
	[unItem unselected];
}
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( state_ != kCCMenuStateWaiting ) return NO;
	
	
	id prevItem = selectedItem_;
	int selIx = selectedItemIndex;
	
	selectedItem_ = [self itemForTouch:touch];
	
	if(prevItem && prevItem != selectedItem_)
	{
		//If we have a previous item, and it's no the selected item
		[self unselectItem:prevItem ix:selIx];
		//[prevItem unselected];
	}
	
	if( selectedItem_ ) 
	{
		//[selectedItem_ selected];
		[self selectItem:selectedItem_ ix:selectedItemIndex];
		state_ = kCCMenuStateTrackingTouch;
		return YES;
	}
	return NO;
}
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	if(state_ == kCCMenuStateWaiting)return;
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	int ix= 0;
	for( CCMenuItem* item in children_ ) 
	{
		[self unselectItem:item ix:ix++];
		//[item unselected];
	}
	
	selectedItem_ = [self itemForTouch:touch];
	
	if (selectedItem_)
	{
		//[self selectItem:selectedItem_ ix:selectedItemIndex];
		//[selectedItem_ selected];
		
		//[selectedItem_ activate];
		fallBackItemIndex = selectedItemIndex;
	}
	else
	{
		//self.selectedItemIndex = fallBackItemIndex;
	}	
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(state_ == kCCMenuStateWaiting) return;
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	int ix = 0;
	for( CCMenuItem* item in children_ ) 
	{
		[self unselectItem:item ix:ix++];
		//[item unselected];	
	}
	
	//self.selectedItemIndex = fallBackItemIndex;
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(state_ == kCCMenuStateWaiting) return;
	
	
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	int selIx = selectedItemIndex;
	CCMenuItem * currentItem = [self itemForTouch:touch];
	//CCMenuItem * fallBackItem = (CCMenuItem *) [children_ objectAtIndex:fallBackItemIndex];
	//if (currentItem != selectedItem_ && currentItem != fallBackItem) 
	//{				
	
	[self unselectItem:selectedItem_ ix:selIx];
	//[selectedItem_ unselected];
	
	selectedItem_ = currentItem;
	
	if (selectedItem_)
	{		
		//[self selectItem:selectedItem_ ix:selectedItemIndex];
		//[selectedItem_ selected];
	}
	else
	{
		//[[children_ objectAtIndex:fallBackItemIndex]selected];
	}
	
	//}
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
		
		CGPoint location = [item position];
		location = [item convertToWorldSpace:location];
		CGPoint selfLoc = [self position];
		selfLoc = [self convertToWorldSpace:selfLoc];
		
		
		CGRect r = [item rect];
		r.origin = CGPointZero;
		if([item respondsToSelector:@selector(normalImage)])
		{
			CGFloat xStuff= [[(CCMenuItemSprite*)item normalImage] scaleX];
			CGFloat yStuff = [[(CCMenuItemSprite*)item normalImage] scaleY];
			
		r.size = [[(CCMenuItemSprite*)item normalImage] contentSize];
			r.size.width*= xStuff;
			r.size.height *= yStuff;
			
		}
		
		
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
	int ix =0;
	for( CCMenuItem* item in children_ ) 
	{
		//[item unselected];	
		[self unselectItem:item ix:ix++];
		
	}
	
	selectedItemIndex = value;	
	selectedItem_ = [children_ objectAtIndex:selectedItemIndex];
	
	fallBackItemIndex = selectedItemIndex;
	
	[self selectItem:selectedItem_ ix:selectedItemIndex];
	//[selectedItem_ selected];      
}

@end