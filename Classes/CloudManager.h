//
//  CloudManager.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppProtocols.h"

@class PlayerBasket,RandomManager,SpaceManager,PhysicsManager,Cloud;
@class ResourceManager;
@interface CloudManager : NSObject<SaveLoadState> {

	SpaceManager* smgr;
	ResourceManager* _resourceManager;
	PhysicsManager* _physicsManager;
	RandomManager* _rM;
	CCNode* parent;
	int cloudZ;
	PlayerBasket* player;
	NSMutableArray* cloudArray;
	BOOL cloudsMove;
	CGPoint maxCDist;
	int maxClouds;
	BOOL collisionAdded;
	BOOL isPaused;
	//CGPoint windowSize;
}

-(void) pauseGame;
-(void) resumeGame;
-(void) resetGame;
-(void)cleanUpPhysics;
-(void) removeCloudsFromArray;
-(void) removeCloud:(Cloud*) rCloud;
-(id) cloudManagerWithParent:(CCNode*) parentNode andPlayer:(id) pBasket;
-(id) movingCloudManagerWithParent:(CCNode*) parentNode z:(int) zLevel;
-(void) step:(ccTime) delta;
-(Cloud*) addCloud:(CGPoint) cloudPoint;
-(CGPoint) genCloudPoint;
-(CGRect) genLeftRightCloudRect;
-(Cloud*) addCloud:(CGPoint) cloudPoint cloudType:(int) cloudType;
-(void) repositionCloud:(Cloud*) cloud;
-(void) initiallyPopulate;
-(BOOL) insideClouds:(Cloud*) newCloud;
@end
