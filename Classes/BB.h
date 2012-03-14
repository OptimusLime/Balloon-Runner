//
//  BB.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChipmunkObject.h"
#import "cocos2d.h"
@class PlayerBasket;
@interface BB : ChipmunkObject {
	PlayerBasket* playerBasket;
	
	cpCircleShape* collisionShape;
}
+(id) bbWithPlayer:(id) pBasket;
-(id) initWithBatchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect) rect withPlayer:(id) pBasket;
-(void) initBB;
-(void) removeBBFromSpace;
-(void) fireBBTo:(CGPoint) destination;
-(void) fakeFireBBWith:(CGPoint) velocity andPosition:(CGPoint) pos;
@end
