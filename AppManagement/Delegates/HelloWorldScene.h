//
//  HelloWorldScene.m
//  dbag
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Importing Chipmunk headers
#import "chipmunk.h"

// HelloWorld Layer
@class ResourceManager,PhysicsManager,PlayerBasket;
@interface HelloWorld : CCLayer
{
	PhysicsManager*  _physicsManager;
	ResourceManager* _resourceManager;
	cpSpace *space;
	PlayerBasket* playerBasket;
	CGPoint lastBasketPoint;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void) step: (ccTime) dt;
-(void) addNewSpriteX:(float)x y:(float)y;

@end
