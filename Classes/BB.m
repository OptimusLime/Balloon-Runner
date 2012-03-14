//
//  BB.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BB.h"
#import "ResourceManager.h"
#import "chipmunk.h"
#import "AppEnumerations.h"

@implementation BB

static CGFloat bbForce = 3000.0f;
+(id) bbWithPlayer:(id) pBasket
{
	ResourceManager* sharedResource = [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [sharedResource batchNodeForPath:@"projectileBatch"];
	
	
	return [[BB alloc] initWithBatchNode:batch rect:[sharedResource getSpritePositionWithBatch:batch
																						  imageName:@"BB.png"]
									
								   withPlayer:pBasket];
	
	
}

-(id) initWithBatchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect) rect withPlayer:(id) pBasket
{
	if((self =[super initWithBatchNode:batchNode rect:rect]))
	{
		
		[self initBB];
		
		objectController = pBasket;
		playerBasket = pBasket; 
		[self setVisible:NO];
		//[self setScale:.05];
		
//		bForce = cpv(0, [_physicsManager speed:1.0f]);
	}
	return self;
}
-(void) removeBBFromSpace
{
	self.visible = NO;
	
	if([self shape])
	{
		self.shape->data = nil;
		[smgr removeAndFreeShape:self.shape];
		self.shape = nil;
		
	}
	[self unschedule:@selector(step:)];
}
-(void) fakeFireBBWith:(CGPoint) velocity andPosition:(CGPoint) pos
{
	
	[self setVisible:YES];
	//a quick set of position
	//self.position = [playerBasket position];
	CGSize halfSize = contentSize_;
	halfSize.width*=.5f;
	halfSize.height*=.5f;
	//CGPoint worldPoint = [playerBasket convertToWorldSpace:[playerBasket position]];
	//CGPoint pPos = [[CCDirector sharedDirector] convertToUI:worldPoint];
	//NSLog(@"pPos: (%f,%f)",pPos.x,pPos.y);
	//add shape to smgr
	collisionShape = (cpCircleShape*)[smgr addCircleAt:pos mass:5.0f radius:halfSize.width];
	imageShape = &collisionShape->shape;
	imageShape->layers = ENEMY_MASK_BIT;
	imageShape->sensor = YES;
	imageShape->collision_type =(unsigned int) @"BB_TYPE";
	imageBody = collisionShape->shape.body;
	CPCCNODE_MEM_VARS_INIT(imageShape)
	
	[self shape]->body->v = velocity;
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	[self applyForce:cpv(0, -iM*8)];
	//[self fixConstantVelocity:fixedVel];
	[self schedule:@selector(step:)];
	
}
-(void) fireBBTo:(CGPoint) destination
{
		//instantiate a shape here, then apply a force to it (gravity) and an impulse
	//Make us visible again, the shape will handle our movement
	
	[self setVisible:YES];
	//a quick set of position
	//self.position = [playerBasket position];
	CGSize halfSize = contentSize_;
	halfSize.width*=.5f;
	halfSize.height*=.5f;
	//CGPoint worldPoint = [playerBasket convertToWorldSpace:[playerBasket position]];
	//CGPoint pPos = [[CCDirector sharedDirector] convertToUI:worldPoint];
	//NSLog(@"pPos: (%f,%f)",pPos.x,pPos.y);
	//add shape to smgr
	collisionShape = (cpCircleShape*)[smgr addCircleAt: [playerBasket position] mass:5.0f radius:halfSize.width];
	imageShape = &collisionShape->shape;
	imageShape->layers = ENEMY_MASK_BIT;
	imageShape->sensor = YES;
	imageShape->collision_type =(unsigned int) @"BB_TYPE";
	imageBody = collisionShape->shape.body;
	CPCCNODE_MEM_VARS_INIT(imageShape)
	
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
 
	cpVect dif = cpvsub(destination,[playerBasket position] );
	//CGFloat totalDist = cpvlength(dif);
	
	dif = cpvnormalize(dif);
	dif = ccpMult(dif, iM*bbForce);
	[self applyForce:cpv(0, -iM*8)];
	[self applyImpulse:dif ];//ccpMult(dif, totalDist)];
	//[self fixConstantVelocity:dif];
	[self schedule:@selector(step:)];
}
-(void) initBB
{
	//Want to initialize the chimpunkobject
	[self initChipmunkObject];
	[self unschedule:@selector(step:)];
	//isFloating = YES;
	//objectController = player;
	//playerBasket = player;
}
@end
