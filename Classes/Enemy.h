//
//  Enemy.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cpCCSprite.h"
#import "AppEnumerations.h"


@interface Enemy : cpCCSprite {

	SpaceManager* smgr;
	CGPoint fixedVelocity;
	BOOL hasFixedVelocity;
	EnemyType _eType;
	CGPoint originalVelocity;
	CGPoint lastPoint;
	CGFloat lastAngle;
	CGFloat switchDistance; 
	CGPoint pushOffset;
	BOOL offsetSet;
}
@property (nonatomic) EnemyType _eType;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGFloat switchDistance;
+(id) enemyWithType:(EnemyType) eType withPlayer:(id) pBasket;
+(CGRect) enemySpawnAndDirectionForType:(EnemyType) eType withPlayer:(id) pBasket;
+(cpShape*) shapeForEnemy:(EnemyType) eType withManager:(SpaceManager*) smgr atPoint:(CGPoint) startPoint;
+(CGFloat) enemySize:(EnemyType) eType;
-(void) respawnEnemy:(EnemyType) eType withPlayer:(id) pBasket;
-(void) respawnEnemyPosition:(id) pBasket;
-(void) step:(ccTime) delta;
-(void) setFixedVelocity:(CGPoint) vel;
-(CGPoint) fixedVelocity;
-(CGPoint) originalVelocity;
-(void) changeToEnemy:(EnemyType)eType withSpaceManager:(SpaceManager*) smgr_ withStartAndDirection:(CGRect) sAndDirection;
-(CGPoint) pushOffset;
-(int) enemyType;
-(void) removeAndHideEnemy;
@end

@interface BirdEnemy: Enemy{} 
+(id) birdWithPlayer:(id) pBasket;
//-(void) step:(ccTime) delta;
@end

@interface OwlEnemy: Enemy{
	
}
+(id) emptyOwlWithPlay:(id) pBasket;
+(id) owlWithPlayer:(id) pBasket;
-(void) step:(ccTime) delta;
-(void) initOwl;
-(void) setOwlSwitchDistance:(CGFloat) dist;
@end

@interface KiteEnemy: Enemy{
	cpBody* imageControlBody;
	cpGearJoint* imageGear;
}
-(void) setAngle:(CGFloat)a;
-(void) setUniqueVelocity:(CGPoint) velocity;
-(void) step:(ccTime) delta;
+(id) kiteWithPlayer:(id) pBasket;
-(void) addControlBody;
@end