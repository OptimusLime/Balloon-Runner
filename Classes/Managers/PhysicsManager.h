//
//  PhysicsManager.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "SpaceManager.h"
	

@interface PhysicsManager : NSObject {
	SpaceManager* spaceManager;
	cpSpace* physicsSpace;
	CGFloat speedMod;
	NSMutableArray* physicsSpaces;
	NSMutableArray* spaceManagers;
}
+(PhysicsManager*) sharedPhysicsManager;
-(void) createNewSpace;
-(void) popLastSpace;
-(void) updatePhysics:(ccTime) delta withCallback:(void*)cb;
-(cpSpace*) space;
-(SpaceManager*) spaceManager;
-(CGFloat) speedModifier;
-(CGFloat) speed:(CGFloat) oldSpeed;
@end
