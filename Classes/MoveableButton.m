//
//  MoveableButton.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoveableButton.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "ResourceManager.h"
@implementation MoveableButton

-(id) init
{
	if( (self = [super init]) )
	{
		
	}
	return self;
}
+(id) itemFromNormalSprite:(CCNode <CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode <CCRGBAProtocol>*)selectedSprite target:(id)target selector:(SEL) selector
{
	
	CCMenuItemSprite* ret = [super itemFromNormalSprite:normalSprite selectedSprite:selectedSprite target:target selector:selector];
	
	if([ResourceManager isPixelArt])
	{
		[[ (CCSprite*)[ret normalImage] texture] setAliasTexParameters];
		[[ (CCSprite*)[ret selectedImage]texture] setAliasTexParameters];
	}
	return ret;
}

-(BOOL) ccTouchBegan:(UITouch*) touch withEvent:(UIEvent*)event
{
	
	
	CGPoint location = [touch locationInView:[touch view]];
	
	[touch tapCount];
	
	lastTouch = [[CCDirector sharedDirector] convertToGL:location];
	tBegan = [self containsTouchLocation:touch];
	
	if(tBegan) [self selected];
	//if touches happen outside you, and you're selected, deselect yourself
	else {
		if([self isSelected])
		{
			[self unselected];
		}
	}

	//lastTouch = [self convertTouchToNodeSpace: touch];
	//NSLog(@"LTouch: (%f,%f)", lastTouch.x, lastTouch.y);
	return YES;
	
	//[super ccTouchBegan:touch withEvent:event];
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p;
	CGRect r;
	if(isSelected_)
	{
	 p = [[self selectedImage] convertTouchToNodeSpaceAR:touch];
	//	CCSprite* spriteImage = (CCSprite*)[self normalImage];
	 r = [ [ (CCSprite*)[self selectedImage] displayedFrame] rectInPixels];
		
		p.x += r.origin.x;
		p.y += r.origin.y;
	return CGRectContainsPoint(r, p);
	}
	else {
		r =  [ [ (CCSprite*)[self normalImage] displayedFrame] rectInPixels];
		p = [[self normalImage] convertTouchToNodeSpaceAR:touch];
		p.x += r.origin.x;
		p.y += r.origin.y;
		
		return CGRectContainsPoint(r, p);
	}

}
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event
{
	tBegan = NO;
	//[super cc
}
-(void) ccTouchEnded:(UITouch*) touch withEvent:(UIEvent*)event
{
	tBegan = NO;


}
-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event
{
	
//	CGPoint thisTouch =  [self convertTouchToNodeSpace: touch];
	
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint thisTouch = [[CCDirector sharedDirector] convertToGL:location];
	
	//NSLog(@"ThisTouch: (%f,%f) LTouch (%f,%f)", thisTouch.x, thisTouch.y, lastTouch.x, lastTouch.y);
	
	
	if(tBegan)
	{

		CGPoint dif = ccp(thisTouch.x - lastTouch.x, thisTouch.y - lastTouch.y);//  ccp(thisTouch.x - lastTouch.x, thisTouch.y - lastTouch.y);
		CGPoint pos = self.position;
		self.position = ccp(pos.x + dif.x, pos.y + dif.y);
	//	NSLog(@"Dif (%f,%f)", dif.x,dif.y);
		
	}
	lastTouch = thisTouch;
}


@end
