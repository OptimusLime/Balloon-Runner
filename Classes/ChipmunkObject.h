//
//  ChimpunkObject.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cpCCSprite.h"
#import "chipmunk.h"

@class PhysicsManager,SpaceManager,ResourceManager;
@interface ChipmunkObject : cpCCSprite {
	SpaceManager* smgr;
	ResourceManager* _resourceManager;
	PhysicsManager* _physicsManager;
	cpBody* imageBody;
	cpBody* imageControlBody;
	cpShape* imageShape;
	cpPivotJoint* imagePivot;
	cpGearJoint* imageGear;
	cpRotaryLimitJoint* imageRotationJoint;
	
	
	//ROTATION PROPERTIES
	CGFloat rotationSpeed;
	//Point to rotate to
	cpVect rotationPoint;
	
	cpVect fixedVelocity;
	BOOL hasFixedVelocity;
	
	cpSpace* physicsSpace;
	id objectController;
	BOOL inFlight;
	
	BOOL isPaused;
}
@property (nonatomic) BOOL inFlight;

@property (assign) cpShape* imageShape;
@property (assign) cpBody* imageBody;
@property (assign) cpBody* imageControlBody;
@property (assign) cpPivotJoint* imagePivot;
@property (assign) cpGearJoint* imageGear;
@property (assign) cpRotaryLimitJoint* imageRotationJoint;

@property (nonatomic) CGFloat rotationSpeed;
@property (nonatomic) cpVect rotationPoint;

-(void) pauseGame;
-(void) resumeGame;
-(void) initChipmunkObject;
-(void) step:(ccTime) delta;
-(void) fixRotationPoint:(cpVect) point;
-(void) fixConstantVelocity: (cpVect) velocity;
-(void) deactivateConstantVelocity;
-(void) reactivateConstantVelocity;

@end
