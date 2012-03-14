//
//  AppEnumerations.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cloud.h"
#import "CloudManager.h"
//#import "Balloon.h"
//#import "Enemy.h"
#import "BB.h"
#import "EnemyManager.h"
#import "SimpleAudioEngine.h"
#import "PlayerBasket.h"
#define GRAVITY (-.00001)


#pragma mark -
#pragma mark Achieve/Leaderboards

//From the example apple stuff:
//These constants are defined in iTunesConnect, and will function as long
//  as this sample is built/run with the existing bundle identifier
//  (com.appledts.GKTapper).  If you want to experiment with this sample and
//  iTunesConnect, you'll need to define you're own bundle ID and iTunes
//  Connect configurations.  This sample uses reverse DNS for Leaderboards
//  and Achievement IDs, but this is not a requirement.  Any string that
//  iTunes Connect will accept will work fine.

//Leaderboard Category IDs
#define kBRHeightLeaderboard @"com.bangarangi.BRHeightLeaderboard"
#define kBRiPadLeaderboard @"com.bangarangi.BRiPadLeaderboard"

//Achievement IDs
#define kAchievementFiftyDead @"com.bangarangi.fifty_enemies"
#define kAchievementOneDead @"com.bangarangi.one_enemy"
#define kAchievementFiveHundredDead @"com.bangarangi.fivehundred_enemies"
#define kAchievementOneHundredDead @"com.bangarangi.onehundred_enemies"
#define kAchievementOneHourPlayed @"com.bangarangi.one_hour_played"
#define kAchievementFiveHoursPlayed @"com.bangarangi.five_hours_played"
#define kAchievementSharpShooter @"com.bangarangi.sharpshooter"
#define kAchievementPeacemaker @"com.bangarangi.peacemaker"
#define kAchievementFifteenBalloons @"com.bangarangi.fifteen_balloons"
#define kAchievementTwentyBalloons @"com.bangarangi.twenty_balloons"
#define kAchievementFortyBalloons @"com.bangarangi.forty_balloons"
#define kAchievementSurviveSingleBalloon @"com.bangarangi.minute_survival"


//These are the save numbers for these guys too
//could have done an enum here 
#define kBRStartInt 0
#define kBRPlayerHeight 0 //owned by PlayerBasket
//@"playerHeight"
#define kBREnemyKillCount 1   //owned by EnemyManager
//@"enemyKillCount"
#define kBRTimePlayed 2  //owned by GameScene
//@"timePlayed"
#define kBRNumberOfShots 3 //owned by PlayerBasket
//@"numberOfShots"
#define kBRTimeWithOneBalloon 4 //owned by PlayerBasket
//@"oneBalloonTime"
#define kBRMaxNumberOfBalloons 5 //owned by PlayerBasket
//@"maxBalloons"
#define kBRFinishCount 6 //equals the last index + 1

#pragma mark -
#pragma mark Macros

//Chipmunk Layers for collision detection
#define GRABABLE_MASK_BIT (1<<31)
#define WEAPONS_MASK_BIT (2 << 31)
#define BALLOONS_MASK_BIT (3 << 28)
#define BASKET_MASK_BIT (3 << 14)
#define RULER_MASK_BIT (3 << 4)
#define ENEMY_MASK_BIT (3)
#define BACKGROUND_MASK_BIT (~(BALLOONS_MASK_BIT | BASKET_MASK_BIT | ENEMY_MASK_BIT | RULER_MASK_BIT) )
#define NOT_GRABABLE_MASK (~GRABABLE_MASK_BIT)

#define DEFAULT_MUSIC_VOLUME 1.0f
#define DEFAULT_EFFECTS_VOLUME 1.0f

typedef enum 
{
	_sBalloon,
	blue,
	green,
	orange, 
	red, 
	pink,
	_eBalloon,
	
} BalloonColor;

typedef enum 
{
	_sCloud,
	c1,
	c2,
	c3, 
	c4, 
	c5,
	c6,
	c7,
	_eCloud,
	
} CloudType;

typedef enum
{
	_sEnemy,
	bird,
	owl,
	kite,
	_eEnemy
} EnemyType;

static inline NSString* stringForEnemy(EnemyType eType)
{
	switch (eType) {
		case bird:
			return @"bird.png";
			
		case owl:
			return @"owl.png";
			
		case kite:
			return @"kite.png";
			
			
		default:
			return @"";
			break;
	}
}

static inline NSString* stringForColor( BalloonColor bColor)
{
	switch (bColor) {
		case blue:
		return @"blue3.png";
			
		case green:
		return @"green3.png";
			
		case red:
		return @"red3.png";
			
		case pink:
		return @"pink3.png";			
			
		case orange:
		return @"orange3.png";
			
		default:
			return @"";
			break;
	}
}
static inline NSString* stringForCloud( CloudType cType)
{
	switch (cType) {
		case c1:
			return @"cloud1.png";
			
		case c2:
			return @"cloud2.png";
			
		case c3:
			return @"cloud3.png";
			
		case c4:
			return @"cloud4.png";			
			
		case c5:
			return @"cloud5.png";
		case c6:
			return @"cloud6.png";
		case c7:
			return @"cloud7.png";
			
		default:
			return @"";
			break;
	}
}
static inline void
cloudMove(cpSpace *space, void* cMgrPtr, void* cPtr)
{
	CloudManager* cManager = (CloudManager*) cMgrPtr;
	Cloud* cloud  = (Cloud*) cPtr;
	if(cloud && cManager)
	[cManager repositionCloud:cloud];
	
}
static inline void
balloonRemove(cpSpace *space, void* pMgrPtr, void* bPtr)
{
	PlayerBasket* pManager = (PlayerBasket*) pMgrPtr;
	Balloon* balloon  = (Balloon*) bPtr;
	if(balloon && pManager)
	[pManager removeBalloon:balloon];
	
}

static inline void
balloonAttach(cpSpace *space, void* pMgrPtr, void* bPtr)
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"balloonAttached.mp3"];
	
	PlayerBasket* pManager = (PlayerBasket*) pMgrPtr;
	Balloon* balloon  = (Balloon*) bPtr;
	if(balloon && pManager)
	[pManager attachBalloon:balloon];
}
static inline void
bbRemove(cpSpace *space, void* pMgrPtr, void* bbPtr)
{
	PlayerBasket* pManager = (PlayerBasket*) pMgrPtr;
	BB* bb  = (BB*) bbPtr;
	if(bb && pManager)
	[pManager removeBB:bb];
	
}
@class Enemy;
static inline void
enemyRemove(cpSpace *space, void* eMgrPtr, void* ePtr)
{
	EnemyManager* eManager = (EnemyManager*) eMgrPtr;
	Enemy* enemy  = (Enemy*) ePtr;
	if(enemy && eManager)
	[eManager removeEnemy:enemy];
	
}
static inline void
incrementEnemyKilled(cpSpace *space, void* eMgrPtr, void* ePtr)
{
	EnemyManager* eManager = (EnemyManager*) ePtr;
	[eManager enemyKilled];
	
}


static inline cpVect cpvmidPoint(cpVect v1, cpVect v2)
{
	return cpv((v1.x + v2.x)/2,(v1.y + v2.y)/2);
}