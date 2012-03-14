//
//  EnemyManager.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppProtocols.h"


@class SpaceManager, ResourceManager, PhysicsManager,RandomManager;
@class PlayerBasket,Enemy;
@interface EnemyManager : NSObject<AchievementManager,SaveLoadState> {
	SpaceManager* smgr;
	ResourceManager* _resourceManager;
	PhysicsManager* _physicsManager;
	RandomManager* _rM;
	CCNode* parent;
	PlayerBasket* player;
	NSMutableArray* enemyArray;
	NSMutableArray* unusedEnemies;
	int totalEnemyCount;
	CGFloat regenTime;
	CGFloat nextIncreaseDistance;
	BOOL isPaused;
	int enemyKillCount;
	int totalEnemyKillCount;
	int maxEnemyKillCount;
	int localTotalEnemyCount;
	BOOL calledOnce;
	BOOL singleAudio;
	
	
}
-(void) singleCallBalloonPopAudio;
-(void) removeAndHideEnemies;
-(void) addAchievementVariables:(NSMutableDictionary *)achieveDict;
-(NSMutableDictionary*) getAchievementVariables;
-(void)cleanUpPhysics;
-(void) resetGame;
-(void) pauseGame;
-(void) resumeGame;
-(void)enemyKilled;
-(id) enemyManagerWithParent:(CCNode*) parentNode andPlayer:(id) pBasket;
-(void) step:(ccTime) delta;
-(int) randomEnemyType;
-(void) spawnEnemy;
-(Enemy*) addEnemy;
-(Enemy*) getUnusedEnemy:(int)enemyType;
-(void) removeEnemy:(Enemy*) remEnemy;
-(void) populateArrays;
@end
