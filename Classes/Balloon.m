//
//  Balloon.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Balloon.h"
#import "ResourceManager.h"
#import "PlayerBasket.h"
#import "PhysicsManager.h"
#import "chipmunk.h"
#import "cpSpace.h"
#define ROTATION_MODIFIER .0001

static CGFloat balloonSpeed = 1.0f;
static CGFloat accelMult = 10.0f;
static CGFloat accelMultY = 3.0f;
@implementation Balloon


+(id) balloonWithColor:(BalloonColor) bColor withPlayer:(id) pBasket atPoint:(CGPoint) placePoint
{
	ResourceManager* sharedResource = [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [sharedResource batchNodeForPath:@"balloonBatch"];
	
	
	return [[Balloon alloc] initWithBatchNode:batch rect:[sharedResource getSpritePositionWithBatch:batch
																						  imageName:stringForColor(bColor)]
									withColor:bColor
								   withPlayer:pBasket
									  atPoint:placePoint] ;
	

}
+(id) attachedBalloonWithColor:(BalloonColor) bColor withPlayer:(id) pBasket atPoint:(CGPoint) placePoint
{
	id bal = [Balloon balloonWithColor:bColor withPlayer:pBasket atPoint:placePoint];
	[bal attachBalloonToPlayerAtPoint:placePoint];
	return bal;
}


-(id) initWithBatchNode:(CCSpriteBatchNode *)batchNode rect:(CGRect) rect withColor:(BalloonColor)color withPlayer:(id) pBasket atPoint:(CGPoint) placePoint
{
	if((self =[super initWithBatchNode:batchNode rect:rect]))
	{
		
		[self initializeBalloon];
		bColor = color;
		objectController = pBasket;
		playerBasket = pBasket; 
		
		//[self setScale:.05];
		[self addBalloonToSpace:placePoint];
		bForce = cpv(0, [_physicsManager speed:1.0f]);
	}
	return self;
}
-(void) initializeBalloon
{
	//Want to initialize the chimpunkobject
	[self initChipmunkObject];
	
	isFloating = YES;
	//objectController = player;
	//playerBasket = player;
}
-(BalloonColor) balloonColor
{
	return bColor;
}
-(void) setCurrentAccel:(CGPoint) accel
{
	#define CLAMP(x,y,z) MIN(MAX(x,y),z)
	aVec = accel;
	bForce = cpv(-accel.x*accelMult, accel.y*accelMultY + [_physicsManager speed:balloonSpeed]);
	//NSLog(@"bForce %.2f,%.2f",  bForce.x, bForce.y);
	bForce.x = CLAMP(bForce.x, -5,5);
	bForce.y = CLAMP(bForce.y, -5,5);
	[self fixConstantVelocity:bForce];
}
-(void) addBalloonToSpace:(CGPoint) placePoint
{
	CGSize iSize = [_resourceManager spriteContentSize:stringForColor(bColor) fromPath:@"balloonBatch"];
	
	//CGFloat reduceSize = 1.0f;//.5;
	//iSize.width *= reduceSize;
	//iSize.height*= reduceSize;
	CGFloat inR = .5;CGFloat outR = .8f;
	CGFloat radius = cpvlength(cpv(iSize.width/2, iSize.height/2));
	
	
	
	imageControlBody = cpBodyNew(INFINITY, INFINITY);
	
	//this adds in a circle shape with a certain mass
	imageShape = [smgr addCircleAt:placePoint mass:10.0f radius:inR*radius];
	//imageShape->e = .9f; imageShape->u = .7f;
	imageShape->layers = BALLOONS_MASK_BIT;
	imageShape->collision_type = (unsigned int) @"BALLOON_TYPE";
	
	//imageShape->data = self;
	
	
	imageBody = imageShape->body;
	
	//cpCCSprite *ballSprite = //[cpCCSprite spriteWithShape:ball batchNode:batch rect:[_resourceManager getSpritePositionWithBatch:batch
//	imageName:stringForColor(bColor)]];
	
	CPCCNODE_MEM_VARS_INIT(imageShape)
	
	
	//[ballSprite shape
	//[self setScale:reduceSize];
	
	collisionShape = (cpCircleShape*)cpCircleShapeNew(imageBody, outR*radius, cpvzero);
	//Make sure to add the collision shape to the body or else!
	
	
	[smgr addShape:(cpShape*) collisionShape];
	collisionShape->shape.sensor = YES;
	collisionShape->shape.data =  self;
	collisionShape->shape.collision_type = (unsigned int)@"BALLOON_TYPE"; 
	
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	imageRotationJoint = (cpRotaryLimitJoint*) cpSpaceAddConstraint(physicsSpace, 
																	cpRotaryLimitJointNew(imageControlBody, imageBody, -M_PI/8, M_PI/8));
	
	imageGear = (cpGearJoint*)[smgr addGearToBody:imageControlBody fromBody:imageBody phase:0.0f ratio:1.0f];
	//imageGear = (cpGearJoint*)cpSpaceAddConstraint(physicsSpace, cpGearJointNew(imageControlBody, imageBody, 0.0f, 1.0f));
	
	imageGear->constraint.biasCoef = iM*0.01f;
	imageGear->constraint.maxBias = iM*1*ROTATION_MODIFIER;
	imageGear->constraint.maxForce = iM*1.0f;
	
	
	[self fixConstantVelocity:ccpMult(bForce,iM)];
	isFloating= YES;
}
-(BOOL)isFloating
{
	return isFloating;
}
-(void)setIsFloating:(BOOL)val
{
	isFloating = val;
}
//Assumed to have already created the balloon
-(void) attachBalloonToPlayerAtPoint:(cpVect)attachPoint
{
	isFloating = NO;
	imageBody->p = attachPoint;
	imageBody->v = cpvzero;
	cpBodyResetForces(imageBody);
	
	
	
	
	CGSize basketSize = [playerBasket basketSize];
	
	cpBody* body = [playerBasket playerBody];
	
	
	
	//cpVect tr = cpv(basketSize + body.pos.x , basketSize + body.pos.y);
	//	cpVect tl = cpv(-basketSize + body.pos.x , basketSize + body.pos.y);

	//CGFloat difVec = [playerBasket balloonMin];
	
	//cpvlength(cpv(basketSize.width/2,basketSize.height/2));
	
	[self fixConstantVelocity: bForce];
	
	//[self fixConstantVelocity: cpv(0, [_physicsManager speed:.01f])];
	leftSlideJoint = (cpSlideJoint*)[smgr addSlideToBody:body fromBody:imageBody toBodyAnchor:cpv(-basketSize.width/2 , basketSize.height/2) fromBodyAnchor:cpvzero 
											   minLength:[playerBasket balloonMin] maxLength:[playerBasket balloonMax]];
	rightSlideJoint = (cpSlideJoint*)[smgr addSlideToBody:body fromBody:imageBody toBodyAnchor:cpv(basketSize.width/2 , basketSize.height/2) fromBodyAnchor:cpvzero
												 minLength:[playerBasket balloonMin] maxLength:[playerBasket balloonMax]];
	
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	leftSlideJoint->constraint.maxForce = iM*350;
	rightSlideJoint->constraint.maxForce = iM*350;
	
	centerSlide = (cpSlideJoint*)[smgr addSlideToBody:body fromBody:imageBody toBodyAnchor:cpv(0, 5.0f*basketSize.height) fromBodyAnchor:cpvzero
											minLength:0 maxLength:(1/iM)*[playerBasket balloonMax]];
	centerSlide->constraint.maxForce = iM*1400;
	//centerSpring = (cpDampedSpring*) [smgr addSpringToBody:body fromBody:imageBody 
	//										  toBodyAnchor:cpv(0, 5.0f*basketSize.height) fromBodyAnchor:cpvzero 
	//											restLength:50.0f stiffness:0.0f damping:.2f];


}
-(void) removeBalloonFromSpace
{
	if (!collisionShape || !imageShape) 
		return;
	
	collisionShape->shape.data = nil;
	imageShape->data = nil;
	
	[smgr removeAndFreeShape:(cpShape*)collisionShape];
	[smgr removeAndFreeShape:imageShape];
	collisionShape = nil;
	imageShape = nil;
	self.shape = nil;
	[self unschedule:@selector(step:)];
	[self deactivateConstantVelocity];
	isFloating = YES;
    
	//cpSpaceRemoveBody(physicsSpace, imageBody);
//	cpSpaceRemoveConstraint(physicsSpace, (cpConstraint*)imageGear);
//	cpSpaceRemoveConstraint(physicsSpace, (cpConstraint*)imageRotationJoint);
//	cpSpaceRemoveConstraint(physicsSpace, (cpConstraint*)imageShape);
//	cpSpaceRemoveConstraint(physicsSpace, (cpConstraint*)collisionShape);
//	cpSpaceRemoveConstraint(physicsSpace, (cpConstraint*)leftSlideJoint);
//	cpSpaceRemoveConstraint(physicsSpace, (cpConstraint*)rightSlideJoint);
	
}
-(void) dealloc
{
    //NSLog(@"Dealloc balloon");
    if(imageControlBody)
        cpBodyFree(imageControlBody);
    imageControlBody = nil;
	[super dealloc];
}
@end
