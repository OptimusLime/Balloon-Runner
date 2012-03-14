//
//  PlayerBasket.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ChipmunkObject.h"
#import "chipmunk.h"
#import "AppProtocols.h"
@class RandomManager,Balloon,BB;
@interface PlayerBasket : ChipmunkObject <AchievementManager,SaveLoadState> {

	RandomManager* _rM;
	NSMutableArray* balloonObjects;
	NSMutableArray* bbObjects;
	NSMutableArray* unusedBBObjects;
	NSMutableArray* floatingBalloonObject;
	CGFloat reloadTime;

	CGFloat balloonTime;
	CGFloat maxBBDist;
	CGFloat nextIncreaseHeight;
	CGFloat maxPlayerHeight;
	CGFloat oneBalloonTimer;
	int shotCount;
	int maxBalloons;
	
}
-(void) addAchievementVariables:(NSMutableDictionary *)achieveDict;
-(NSMutableDictionary*) getAchievementVariables;
-(void) updateAchievementVariables:(ccTime) delta;
-(void) removeBalloonsAndBBs;
+(id) standardPlayerBasket:(CGPoint) startPoint withParent:(CCNode*)parentNode;
-(void)cleanUpPhysics;
+(CGFloat) gameScore;
-(CGFloat) gameHeight;
-(NSString*) append:(NSString*) a i:(int) i;
-(void) setGameScore;
-(void) pauseGame;
-(void) resumeGame;
-(void) resetGame;
-(void) attemptFireAt:(CGPoint) placeToAim;
-(void) populateBBs;
-(void) removeBB:(BB*) bb;
-(void) attachBalloon:(Balloon*)aBall;
-(CGPoint) balloonGenPoint;
//-(void) balloonWasAttached:(Balloon*) aBall;
-(void) addBBAtPoint:(CGPoint) point withVelocity:(CGPoint) velocity;
-(Balloon*) addBalloon:(CGPoint) placePoint withVelocity:(CGPoint) velocity withColor:(int) bColor;
-(Balloon*) floatBalloonAt:(CGPoint) placePoint withVelocity:(CGPoint) velocity withColor:(int) bColor;
-(Balloon*)floatAnyBalloonAt:(CGPoint)placePoint;
-(Balloon*) addAnyColorBalloon:(CGPoint) placePoint;
-(void) removeBalloon:(Balloon*) rBall;
-(void) removeFloatingBalloon:(Balloon*) aBall;
-(void) initBasket;
-(void) syncPhysics:(void*) callbackFunction;
-(CGSize) basketSize;
-(void) addPhysicalBodies;
-(void)setAcceleration:(CGPoint) aVec;
-(int) balloonCount;
-(cpBody*) playerBody;
-(CGFloat) balloonMin;
-(CGFloat) balloonMax;
-(CGRect) viableLeftRect;
-(CGRect) viableTopRect;
-(CGRect) viableTopCloudRect;
-(CGRect) viableRightRect;
-(CGRect) viableCenterRect;
-(CGRect) viableBottomRect;

@end
