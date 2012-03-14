//
//  Cloud.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "ChipmunkObject.h"


@interface Cloud : ChipmunkObject {

	int cloudType;
}
+(id) moveableCloudWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect)rect;
-(void) repositionCloud:(CGPoint) newPos;
-(void)cloudInit;
-(void)moveCloudInit;
-(void) removeCloudShape;
-(CGPoint) topLeftPoint;
-(CGPoint) bottomRightPoint;
-(CGPoint) leftCloudPoint;
-(CGPoint) rightCloudPoint;
-(int) cloudType;
-(void) setCloudType:(int)cType;
-(BOOL) isInsideCloud:(CGPoint) checkPoint;
-(BOOL) isMovingRight;
-(BOOL) is:(CGFloat) c between:(CGFloat)x and:(CGFloat) y;
//-(void) step:(ccTime) delta;
@end
