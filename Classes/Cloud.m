//
//  Cloud.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cloud.h"
#import "ChipmunkObject.h"
#import "PhysicsManager.h"
#import "AppEnumerations.h"
@implementation Cloud


+(id) spriteWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect)rect
{
	id ret = [super spriteWithShape:shape batchNode:batchNode rect:rect];
	[ret cloudInit];
	[ret setSpaceManager:[[PhysicsManager sharedPhysicsManager] spaceManager]];
	//[ret setAutoFreeShape:YES];
	return ret;
}
+(id) moveableCloudWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect)rect
{
	id ret = [super spriteWithShape:shape batchNode:batchNode rect:rect];
	[ret setSpaceManager:[[PhysicsManager sharedPhysicsManager] spaceManager]];
	[ret moveCloudInit];
	//[ret setAutoFreeShape:YES];
	return ret;
}
-(CGPoint) leftCloudPoint
{
	return ccpAdd(self.position, ccp(-scaleX_*contentSize_.width/2, -scaleY_*contentSize_.height/2));
}
-(CGPoint) rightCloudPoint
{
	return ccpAdd(self.position, ccp(scaleX_*contentSize_.width/2, scaleY_*contentSize_.height/2));
}
-(CGPoint) topLeftPoint
{
	return ccpAdd(self.position, ccp(-scaleX_*contentSize_.width/2, scaleY_*contentSize_.height/2));
	
}
-(CGPoint) bottomRightPoint
{
	return ccpAdd(self.position, ccp(scaleX_*contentSize_.width/2, -scaleY_*contentSize_.height/2));
}
-(BOOL) isInsideCloud:(CGPoint) checkPoint
{
	CGPoint rightPoint = [self rightCloudPoint];
	CGPoint leftPoint = [self leftCloudPoint];
//	CGPoint tl = [self leftCloudPoint];
	//CGPoint br = [self leftCloudPoint];
	return ([self is:checkPoint.x between:leftPoint.x and:rightPoint.x] && [self is:checkPoint.y between:leftPoint.y and:rightPoint.y]);
	
	//(checkPoint.x <=  rightPoint.x && checkPoint.y <= rightPoint.y && checkPoint.x >= leftPoint.x && checkPoint.y >= leftPoint.y);
}

-(BOOL) is:(CGFloat) c between:(CGFloat)x and:(CGFloat) y
{
	return (c >= x && c <= y);
}
-(void) repositionCloud:(CGPoint) newPos
{
	//Perhaps perform other functions here
	[self setPosition:newPos];
}
-(void) moveCloudInit
{
	[self initChipmunkObject];
	imageShape->sensor = YES;
	imageShape->layers = BACKGROUND_MASK_BIT;
	imageShape->collision_type = (unsigned int)@"MOVE_CLOUD_TYPE";
}
-(void)cloudInit
{
	
	[self initChipmunkObject];
	imageShape->sensor = YES;
	imageShape->layers = BACKGROUND_MASK_BIT;
	imageShape->collision_type = (unsigned int)@"CLOUD_TYPE";
	//imageShape->data = self;
}
-(void) removeCloudShape
{
	if([self shape])
	{
		//self.shape->data = nil;
		//imageShape->data = nil;
		[smgr removeAndFreeShape:self.shape];
		self.shape = nil;
	}
	[self setVisible:NO];
	[self unschedule:@selector(step:)];
}
-(void) step:(ccTime) delta
{

	if (hasFixedVelocity) {
		
	
		self.position = ccpAdd(ccpMult(fixedVelocity, 10.0f*delta), self.position);

	}
	
	
}
-(void) setCloudType:(int) cType
{
	cloudType = cType;
}
-(int) cloudType
{
	return cloudType;
}
-(BOOL) isMovingRight
{
	return (fixedVelocity.x >= 0);	
}
-(void) dealloc
{
	[super dealloc];
}
@end
