//
//  ChimpunkObject.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChipmunkObject.h"
#import "PhysicsManager.h"
#import "ResourceManager.h"

#import "SpaceManagerCocos2d.h"
@implementation ChipmunkObject

@synthesize imageShape,imageControlBody, imageBody;
@synthesize imageRotationJoint, imageGear, imagePivot,inFlight,rotationPoint, rotationSpeed;

//+(id) spriteWithBatchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect)rect
//{
//	ChipmunkObject* ret = [super spriteWithBatchNode:batchNode rect:rect];
//	[ret initChipmunkObject];
//	
//	return ret;
//}
//
//+(id) spriteWithFile:(NSString *)filename
//{
//	ChipmunkObject* ret = [super spriteWithFile:filename];
//	[ret initChipmunkObject];
//
//	return ret;
//}

-(void) initChipmunkObject
{
	[self schedule:@selector(step:)];
	_resourceManager = [ResourceManager sharedResourceManager];
	_physicsManager = [PhysicsManager sharedPhysicsManager];
	physicsSpace = [_physicsManager space];
	smgr = [_physicsManager spaceManager];
	
	if([self shape]){
		imageShape = [self shape];
		imageBody = [self shape]->body;
		
	}
}
-(void) pauseGame
{
	[self unschedule:@selector(step:)];
}
-(void) resumeGame
{
	[self schedule:@selector(step:)];
}
-(void) fixRotationPoint:(cpVect) point
{
	rotationPoint = point;
	
}
-(void) fixConstantVelocity: (cpVect) velocity
{
	//if(fixedVelocity.x <0 )
//	{
//		NSLog(@"wtf");
//	}
	
	fixedVelocity = velocity;
	hasFixedVelocity = YES;
}
-(void) deactivateConstantVelocity
{
	hasFixedVelocity = NO;
}
-(void) reactivateConstantVelocity
{
	hasFixedVelocity = YES;
}
-(void) step:(ccTime) delta
{
	//[self synchronizePhysics];
	//NSLog(@"Delta %.2f", delta);
	if (hasFixedVelocity) {
		
		//[self applyImpulse:<#(cpVect)impulse#>
	//	cpVect m =ccpMult(fixedVelocity, 100.0f*delta) ;
	//	NSLog(@"Xvel %.2f, shape: %.2f,%.2f", m.x, [self shape]->body->p.x,[self shape]->body->p.y);
		
		[self applyImpulse:ccpMult(fixedVelocity, 100.0f*delta)];
		
		//cpBodyApplyImpulse(imageBody, fixedVelocity, cpvzero);
		//[imageBody applyImpulse:fixedVelocity offset:cpvzero];
		//imageControlBody.vel = fixedVelocity;
	}
	
	
}
@end
