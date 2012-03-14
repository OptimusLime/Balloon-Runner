//
//  Balloon.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ChipmunkObject.h"
#import "chipmunk.h"
#import "cpCCSprite.h"
#import "AppEnumerations.h"
@class PlayerBasket;

@interface Balloon : ChipmunkObject {
	cpSlideJoint* leftSlideJoint;
	cpSlideJoint* rightSlideJoint;
	cpDampedSpring* centerSpring;
	cpSlideJoint* centerSlide;
	PlayerBasket* playerBasket;
	
	cpCircleShape* collisionShape;
	BalloonColor bColor;
	CGPoint aVec;
	CGPoint bForce;
	BOOL isFloating;
	
}
-(BalloonColor) balloonColor;
-(BOOL)isFloating;
-(void)setIsFloating:(BOOL)val;
-(void) initializeBalloon;
-(void)removeBalloonFromSpace;
-(void) setCurrentAccel:(CGPoint) accel;
-(void) addBalloonToSpace:(CGPoint) placePoint;
-(void) attachBalloonToPlayerAtPoint:(cpVect) attachPoint;
+(id) balloonWithColor:(BalloonColor) bColor withPlayer:(id) pBasket atPoint:(CGPoint) placePoint;
+(id) attachedBalloonWithColor:(BalloonColor) bColor withPlayer:(id) pBasket atPoint:(CGPoint) placePoint;
-(id) initWithBatchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect) rect withColor:(BalloonColor)color withPlayer:(id) pBasket atPoint:(CGPoint) placePoint;
@end
