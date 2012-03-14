//
//  TextButton.h
//  CocosSteve
//
//  Created by Paul Szerlip on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class ResourceManager;
@interface TextButton : CCMenuItemSprite {
	ResourceManager		*_resourceManager;
	CCSpriteBatchNode* parentBatch;
	CGPoint lastTouch;
	CCLabelTTF *_label;
	bool tBegan;
}
@property (assign) CCSpriteBatchNode* parentBatch;
@property (retain) CCLabelTTF* textLabel;
+(id)createAndAddTextButton:(CCNode*)initNode z:(int) zLevel withString:(NSString*) labelText;
-(void) initManagers;
-(BOOL) ccTouchBegan:(UITouch*) touch withEvent:(UIEvent*)event;
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event;
-(void) ccTouchEnded:(UITouch*) touch withEvent:(UIEvent*)event;
-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event;
- (BOOL)containsTouchLocation:(UITouch *)touch;
@end
