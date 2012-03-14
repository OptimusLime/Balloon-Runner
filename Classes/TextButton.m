//
//  TextButton.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextButton.h"
#import "ResourceManager.h"
@interface TextButton()
-(void) buttonPressed;
@end


@implementation TextButton

@synthesize parentBatch;
@synthesize textLabel = _label;

+(id)createAndAddTextButton:(CCNode*)initNode z:(int) zLevel withString:(NSString*) labelText
{
	//remember: set up some sort of resource manager, then querry the resource manager for information about the plist. The resource manager should simply story the plist information for all art assets. 
	//Cocos2D will retain the texture information and what have you
	ResourceManager* resourceManager = [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [resourceManager batchNodeForPath:@"pixelPaint"];
	
	CCSprite *whiteSquare =  [CCSprite spriteWithBatchNode:batch rect:  [resourceManager getSpritePositionWithBatch:batch imageName:@"whiteSquare.png"]];
	
							  //[self getSpritePosition:@"pixelPaint" imageName:@"WhiteSquare.png"]];
	CCSprite *blackSquare =  [CCSprite spriteWithBatchNode:batch rect: [resourceManager getSpritePositionWithBatch:batch imageName:@"blackSquare.png"]];
							  //[self getSpritePosition:@"pixelPaint" imageName:@"BlackSquare.png"]];
	if([ResourceManager isPixelArt])
	{
		[whiteSquare.texture setAliasTexParameters];
		[blackSquare.texture setAliasTexParameters];
	}
	
	id tButton = [[TextButton alloc] initFromNormalSprite:whiteSquare selectedSprite:blackSquare 
										   disabledSprite:nil target:nil selector:nil];
														 //: selectedSprite: ];//];
	
	CCLabelTTF* label = [CCLabelTTF labelWithString:labelText fontName:@"Helvetica" fontSize:16.0f];
	[label setColor: ccBLACK];
	
	//CCLabelTTF* label = [CCLabelTTF labelWithString:labelText dimensions:[ [ (CCSprite*)[tButton normalImage] displayedFrame] rectInPixels].size alignment:CCTextAlignmentLeft fontName:@"Helvetica" fontSize:10.0f];
	
	[tButton setTextLabel:label];
	
	CGSize labelSize =[label contentSize];
	
	CGSize size = [tButton contentSizeInPixels];

	[tButton setScaleX:1.5f*labelSize.width/(CGFloat)size.width];
	[tButton setScaleY:1.2f*labelSize.height/(CGFloat)size.height];
	
	[tButton unselected];
	
	[tButton setPosition:[tButton position]];
	

	[initNode addChild:tButton z:zLevel];
	[initNode addChild:label z:zLevel];
	
	
	return tButton;
}

-(void) buttonPressed
{
	
}
-(id) initFromNormalSprite:(CCNode <CCRGBAProtocol>*)normalSprite selectedSprite:(CCNode <CCRGBAProtocol>*)selectedSprite disabledSprite:(CCNode <CCRGBAProtocol>*)disabledSprite 
												   target:(id) target selector:(SEL) selector
{
	if((self = [super initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector]))
	{
		[self initManagers];
	}
	return self;
}

-(void) initManagers
{
	_resourceManager = [ResourceManager sharedResourceManager];
}
-(void) setPosition:(CGPoint) pos
{
	[_label setPosition:pos];
	[super setPosition:pos];
}
-(void) selected
{
	[_label setColor:ccWHITE];
	[super selected];
	
}
-(void) unselected
{
	[_label setColor:ccBLACK];
	[super unselected];
	[(CCSprite*)[self normalImage] setVisible:NO];
	
}
-(BOOL) ccTouchBegan:(UITouch*) touch withEvent:(UIEvent*)event
{
	
	
	CGPoint location = [touch locationInView:[touch view]];
	
		
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
	if(tBegan)
	{
		if([self containsTouchLocation:touch])
		{
			[self selected];
		}
		else {
			[self unselected];
		}

	}
	
}
@end
