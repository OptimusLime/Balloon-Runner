//
//  MoveableButton.h
//  CocosSteve
//
//  Created by Paul Szerlip on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MoveableButton : CCMenuItemSprite {

	
	CGPoint lastTouch;
	bool tBegan;
}


-(BOOL) ccTouchBegan:(UITouch*) touch withEvent:(UIEvent*)event;
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event;
-(void) ccTouchEnded:(UITouch*) touch withEvent:(UIEvent*)event;
-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event;
- (BOOL)containsTouchLocation:(UITouch *)touch;
@end
