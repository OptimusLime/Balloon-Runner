//
//  Enemy.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"
#import "ResourceManager.h"
#import "PhysicsManager.h"
#import "RandomManager.h"
#import "PlayerBasket.h"
#import "AppEnumerations.h"
#import "SpaceManager.h"
@implementation Enemy

static CGPoint leftBird = {-3.0f,0};
static CGPoint rightBird = {3.0f,0};
static CGPoint upOwl = {0,1.0f};
static CGPoint downOwl = {0,-1.0f};
static CGPoint upRightKite = {7.0f,0.0f};

@synthesize _eType;
@synthesize switchDistance, lastPoint;
+(id) enemyWithType:(EnemyType) eType withPlayer:(id) pBasket
{
	ResourceManager* _rManager= [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [_rManager batchNodeForPath:@"enemyBatch"] ;
	CGRect sAndDirection = [Enemy enemySpawnAndDirectionForType:eType withPlayer:pBasket];
	id enemy = [Enemy spriteWithShape:[Enemy shapeForEnemy:eType withManager:[[PhysicsManager sharedPhysicsManager] spaceManager] atPoint:sAndDirection.origin]
							batchNode:batch
															 rect:[_rManager getSpritePositionWithBatch:batch imageName:stringForEnemy(eType)]];
	[enemy setFixedVelocity:ccp(sAndDirection.size.width, sAndDirection.size.height)];
	
	[enemy setFlipX:(sAndDirection.size.width < 0)];
	//[enemy setScaleX:(sAndDirection.size.width >= 0) ? fabsf([enemy scaleX]) : -1.0f*fabsf([enemy scaleX])];
	[enemy set_eType:eType];
	[enemy schedule:@selector(step:)];
	[enemy shape]->collision_type = (unsigned int)@"ENEMY_TYPE";
	[enemy shape]->layers = ENEMY_MASK_BIT;
	[enemy shape]->sensor = YES;
	CGFloat reduceSize = [Enemy enemySize:eType];
	
	[enemy setScale:reduceSize];
	
	
	return enemy;
}
//This creates AND adds a shape to the spacemanager
+(cpShape*) shapeForEnemy:(EnemyType) eType withManager:(SpaceManager*) smgr atPoint:(CGPoint) startPoint
{
	
	CGSize halfSize = [[ResourceManager sharedResourceManager] spriteContentSize:stringForEnemy(eType) fromPath:@"enemyBatch"];
	halfSize.width *= .5f;
	halfSize.height *= .5f;
	
	CGFloat reduceSize = [Enemy enemySize:eType];
	
	switch (eType) {
		case bird:
			
			halfSize.width *= .8f*reduceSize;
			halfSize.height *= .8f*reduceSize;
			//something like a diamond shape works fine
			//diamond is (center, bottom), (left, center), (center, top), (right,center)
			return [smgr addPolyAt:startPoint mass:10.0f rotation:0.0f numPoints:4 
												points:ccp(0, -halfSize.height),ccp(-halfSize.width, 0),
					ccp(0, halfSize.height),ccp(halfSize.width, 0),nil];
			//return @"birg.png";
			
		case owl:
			//square works well with owl
			
			halfSize.width *= .8f*reduceSize;
			halfSize.height *= .8f*reduceSize;
			return [smgr addPolyAt:startPoint mass:10.0f rotation:0.0f numPoints:4 
		points:ccp(-halfSize.width, -halfSize.height),ccp(-halfSize.width, halfSize.height),
			ccp(halfSize.width, halfSize.height),ccp(halfSize.width, -halfSize.height),nil];
			
		case kite:
			
			halfSize.width *= reduceSize;
			halfSize.height *= reduceSize;
			//triangle works well with the kite
			//triangle is (bottom, left), (center, top), (bottom, right)
			return [smgr addPolyAt:startPoint mass:10.0f rotation:0.0f numPoints:3 
							points:ccp(-halfSize.width, -halfSize.height),ccp(0, halfSize.height),
					ccp(halfSize.width, -halfSize.height),nil];
			
			
			
		default:
			NSAssert(eType == bird, @"You are requesting an enemy type that doesn't exist! error");
			return nil;
			
	}
}
+(CGFloat) enemySize:(EnemyType) eType
{
	CGFloat reduceSize;
	switch (eType) {
		case bird:
			reduceSize = 1.0f;
			break;
		case owl:
			reduceSize = 1.0f;
			break;
		case kite:
			reduceSize = .8f;
			break;
		default:
            reduceSize = 1.0f;
			break;
	}
	return reduceSize;
}
//This returns a rectange with the origin the spawn point, and the size as the direction vector
+(CGRect) enemySpawnAndDirectionForType:(EnemyType) eType withPlayer:(id) player
{
	
	
	CGRect spawnArea;
	CGPoint fVel;
	RandomManager* _rM = [RandomManager sharedRandomManager] ;
	int rSpawn = [_rM intRand:12];
	int oS = rSpawn;
	BOOL mustSetDir = NO;
    CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	switch (eType) {
		case bird:
			rSpawn = rSpawn%4;
			//Random bird start on the left or right, mostly above,

			
			if(rSpawn == 0)
			{
				fVel = rightBird;
				spawnArea = [player viableLeftRect];
			}
			else if(rSpawn  == 1)
			{
				fVel = leftBird;
				spawnArea = [player viableRightRect];
			}
			else {
				fVel = rightBird;
				mustSetDir = YES;
				spawnArea = [player viableTopRect];
			}
		//	spawnArea = [player viableCenterRect];			
						break;
			
		case owl:
			rSpawn = rSpawn%3;
			//Random owl spawns are above or to the left/right
			if(rSpawn == 0)
			{
				spawnArea = [player viableLeftRect];
			}
			else if(rSpawn  == 1)
			{
				spawnArea = [player viableRightRect];
			}
			else {
				spawnArea = [player viableTopRect];
			}
			
			if(oS%2)
			{
				fVel = upOwl;
			}
			else {
				fVel = downOwl;
			}


			
			break;
		case kite:
			rSpawn = rSpawn % 4;
			//triangle works well with the kite
			//return @"kite.png";
			if(rSpawn == 0)
			{
				fVel = upRightKite;
				spawnArea = [player viableLeftRect];
			}
			else if(rSpawn  == 1)
			{
				fVel = ccpMult(upRightKite, -1.0f);
				spawnArea = [player viableRightRect];
			}
			else if(rSpawn == 2)
			{
				fVel =  ccpMult(upRightKite, 2*[_rM intRand:2] -1.0f );
				spawnArea = [player viableBottomRect];
			}
			else {
				fVel =  ccpMult(upRightKite, 2*[_rM intRand:2] -1.0f );
				spawnArea = [player viableTopRect];
			}
			
			
			//mustSetDir = YES;
			
			
			break;
		default:
			
			NSAssert(eType == kite, @"Invalied enemy type error in calculating gen point");
						break;
			//return @"";
			}
	
	cpVect test = [_rM frandInArea:spawnArea.origin max:ccpAdd(spawnArea.origin,ccp(spawnArea.size.width,spawnArea.size.height))];
	fVel = ccpMult(fVel, iM);
	if(mustSetDir)
	{
		//If you are left of the player position, make sure you're going RIGHT, otherwise, head left
		fVel.x = (test.x < [(CCNode*)player position].x) ? fabsf(fVel.x) : -1.0f*fabsf(fVel.x);
		//If you  are below the player position, start heading upwards! otherwise, head downwards
		if(eType!= kite)
		fVel.y = (test.y < [(CCNode*)player position].y) ? fabsf(fVel.y) : -1.0f*fabsf(fVel.y);
	}
	//width and height correspond to the correct direction of the object
	return CGRectMake(test.x, test.y,fVel.x ,fVel.y );
}
//This is kind of broken, it doesn't work to just  switch in new textures, have to modify the quads, don't feel like it, this is a hack to be clear :)
-(void) respawnEnemy:(EnemyType) eType withPlayer:(id) pBasket
{
	[self changeToEnemy:eType withSpaceManager:[[PhysicsManager sharedPhysicsManager] spaceManager] withStartAndDirection:[Enemy enemySpawnAndDirectionForType:eType withPlayer:pBasket]];
	
}
-(void) respawnEnemyPosition:(id) pBasket
{
	[self changeToEnemy:_eType withSpaceManager: [[PhysicsManager sharedPhysicsManager] spaceManager] withStartAndDirection:[Enemy enemySpawnAndDirectionForType:_eType withPlayer:pBasket]];
}
-(void) switchDirection:(CGPoint) multVect
{
	hasFixedVelocity = YES;
	fixedVelocity = ccp(fixedVelocity.x*multVect.x, fixedVelocity.y*multVect.y);
}
-(void) removeAndHideEnemy
{
	//if we're not visible, we don't need to go through the trouble of removing ourself as it's already been done
	//if(!visible_)
	//	return;
	
	
	if(!smgr)
		smgr = [[PhysicsManager sharedPhysicsManager] spaceManager];	
	
	
	if([self shape])
	{
		self.shape->data = nil;
		[smgr removeAndFreeShape:self.shape];//removeAndFreeShape:[self shape]];
	
	}
	
	
	self.shape = nil;
	
	
	
	[self setVisible:NO];
	[self unschedule:@selector(step:)];
	hasFixedVelocity = NO;
}
-(int) enemyType
{
	return _eType;
}
//Having added the shape, and generated the spawn point already, this is the simple task of 
-(void) changeToEnemy:(EnemyType)eType withSpaceManager:(SpaceManager*) smgr_ withStartAndDirection:(CGRect) sAndDirection
{
	[self setVisible:YES];
	
	if(eType != _eType)
	{
	_eType = eType;
	//if(eType == bird)
//	{
//		NSLog(@"Bird spawn");
//	}
	//Turn the sprite into the correct enemy

	
	[self setTextureRect:[[ResourceManager sharedResourceManager] getSpritePositionWithBatch:batchNode_ imageName:stringForEnemy(eType)]];
	
	CGFloat reduceSize = [Enemy enemySize:eType];
	[self setScale:reduceSize];
	}
	if(!smgr)
		smgr = smgr_;
	
	
	 //If you have a shape, remove the shape
	if([self shape])
	 {
		 [smgr removeAndFreeShape:[self shape]];
	 }
	
	
	[self setFixedVelocity:ccp(sAndDirection.size.width, sAndDirection.size.height)];
	
	//if you're heading right, keep scaleX, left needs to be flipped
	//[self setScaleX:(sAndDirection.size.width > 0) ? fabsf(scaleX_) : -1.0f*fabsf(scaleX_)];
	if(_eType == kite)
		[self setFlipY:(sAndDirection.size.width < 0)];
	//	[self setFlipX:copysign(1.0f, sAndDirection.size.width) == copysign(1.0f, sAndDirection.size.height)];
	else
	[self setFlipX:(sAndDirection.size.width < 0)];
	
	
	
	 //Add in a new shape
	self.position= sAndDirection.origin;
	cpShape* newShape = [Enemy shapeForEnemy: eType withManager: smgr atPoint: sAndDirection.origin];
	[self setShape:newShape ];
	newShape->collision_type = (unsigned int)@"ENEMY_TYPE";
	newShape->layers = ENEMY_MASK_BIT;
	newShape->sensor = YES;
	//Make sure we point to ourselves with the new shape
	newShape->data = self;
	//Start automatically with this direction
	newShape->body->v = ccp(sAndDirection.size.width, sAndDirection.size.height);
	if(_eType == kite)
	{
		[(KiteEnemy*)self addControlBody];
		
	}
	else {
		self.rotation = 0;
	}
	[self schedule:@selector(step:)];
}

-(void) setFixedVelocity:(CGPoint) vel
{
	fixedVelocity = vel;
	originalVelocity = vel;
	hasFixedVelocity = YES;
	lastAngle = 0;
}
-(CGPoint) fixedVelocity
{
	return fixedVelocity;
}
-(CGPoint) originalVelocity
{
	return originalVelocity;
}
-(void) step:(ccTime) delta
{
	
	if(visible_ && hasFixedVelocity)
	{
	
		[self applyImpulse:ccpMult(fixedVelocity, 100.0f*delta)];
	}

}
-(CGPoint) pushOffset
{
	if(!offsetSet)
	{
		offsetSet = YES;
		CGSize cSize = contentSize_;
		cSize.width *= .5f*scaleX_;
		cSize.height *= .5f*scaleY_ ;
		pushOffset = ccp(cSize.width,cSize.height);
	}
	return pushOffset;
}
-(void) dealloc
{
	[super dealloc];
}
@end

//Bird
@implementation BirdEnemy

+(id) birdWithPlayer:(id) pBasket
{
	EnemyType eType = bird;
	ResourceManager* _rManager= [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [_rManager batchNodeForPath:@"enemyBatch"] ;
	CGRect sAndDirection = [Enemy enemySpawnAndDirectionForType:eType withPlayer:pBasket];
	id enemy = [BirdEnemy spriteWithShape:[Enemy shapeForEnemy:eType withManager:[[PhysicsManager sharedPhysicsManager] spaceManager] atPoint:sAndDirection.origin]
								batchNode:batch
									 rect:[_rManager getSpritePositionWithBatch:batch imageName:stringForEnemy(eType)]];
	[enemy setFixedVelocity:ccp(sAndDirection.size.width, sAndDirection.size.height)];
	
	[enemy setFlipX:(sAndDirection.size.width < 0)];
	//[enemy setScaleX:(sAndDirection.size.width >= 0) ? fabsf([enemy scaleX]) : -1.0f*fabsf([enemy scaleX])];
	[enemy set_eType:eType];
	
	[enemy schedule:@selector(step:)];
	[enemy shape]->collision_type = (unsigned int)@"ENEMY_TYPE";
	[enemy shape]->layers = ENEMY_MASK_BIT;
	[enemy shape]->sensor = YES;
	CGFloat reduceSize = [Enemy enemySize:eType];
	
	[enemy setScale:reduceSize];
	
	
	return enemy;
	
}

@end

static CGFloat directionRotation = M_PI/4.0f;
//Kite
@implementation KiteEnemy

+(id) kiteWithPlayer:(id) pBasket
{
	EnemyType eType = kite;
	ResourceManager* _rManager= [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [_rManager batchNodeForPath:@"enemyBatch"] ;
	CGRect sAndDirection = [Enemy enemySpawnAndDirectionForType:eType withPlayer:pBasket];
	id enemy = [KiteEnemy spriteWithShape:[Enemy shapeForEnemy:eType withManager:[[PhysicsManager sharedPhysicsManager] spaceManager] atPoint:sAndDirection.origin]
							   batchNode:batch
									rect:[_rManager getSpritePositionWithBatch:batch imageName:stringForEnemy(eType)]];
	[enemy setFixedVelocity:ccp(sAndDirection.size.width, sAndDirection.size.height)];
	
	[enemy setFlipY:(sAndDirection.size.width < 0)];//copysign(1.0f, sAndDirection.size.width) == copysign(1.0f, sAndDirection.size.height)];
	//[enemy setScaleX:(sAndDirection.size.width >= 0) ? fabsf([enemy scaleX]) : -1.0f*fabsf([enemy scaleX])];
	[enemy set_eType:eType];

	[enemy schedule:@selector(step:)];
	[enemy shape]->collision_type = (unsigned int)@"ENEMY_TYPE";
	[enemy shape]->layers = ENEMY_MASK_BIT;
	[enemy shape]->sensor = YES;
	CGFloat reduceSize = [Enemy enemySize:eType];
	[enemy addControlBody];
	[enemy setScale:reduceSize];
	
	
	return enemy;
	//return [KiteEnemy enemyWithType:kite withPlayer:pBasket];	
}


-(void) setAngle:(CGFloat)a
{
	cpBodySetAngle(imageControlBody, imageControlBody->a);
}
-(void) setUniqueVelocity:(CGPoint) velocity
{
	fixedVelocity = velocity;	
}
-(void) step:(ccTime) delta
{
	
	if(visible_ && hasFixedVelocity)
	{
	
		//push offset is the half width/half height of the sprite size
		//this is just saying, push at 30% above the center
		[self applyImpulse:ccpMult(fixedVelocity, 100.0f*delta)];// offset:ccp(0, ccpMult(pushOffset,  .3f).y)];
	//[super step:delta];
	//now we change our velocity to cause us to move in circles
	//if it's going left, originally, then we rotate left, otherwise rotate right
		CGFloat theta =  copysign(directionRotation*delta, -originalVelocity.x);
		//	(copysign(1.0f, originalVelocity.x) == copysign(1.0f, originalVelocity.y)) ? directionRotation*delta : -directionRotation*delta;// copysign(directionRotation*delta, -originalVelocity.x);
	
		
	
		fixedVelocity = cpvrotate(fixedVelocity, cpvforangle(theta));
		
		CGFloat sAngle = cpvtoangle(fixedVelocity);
		CGFloat dAngle = sAngle - lastAngle;
		
		
		if(dAngle > M_PI)
			dAngle -= 2*M_PI;
		else if(dAngle <-M_PI)
		{
			dAngle += 2*M_PI;
		}
		//
//		if(imageControlBody->a > 2*M_PI)
//		{
//			dAngle -= 2*M_PI;
//		}
//		else if(imageControlBody->a < -2*M_PI)
//		{
//			dAngle += 2*M_PI;
//		}
		
		//NSLog(@"Angle %.2f d: %.2f", sAngle,CC_RADIANS_TO_DEGREES(sAngle));
		cpBodySetAngle(imageControlBody, imageControlBody->a + dAngle);//[self shape]->body->v));//[self shape]->body->a + theta);
	//	NSLog(@"Angle %.2f d: %.2f", imageControlBody->a,CC_RADIANS_TO_DEGREES(imageControlBody->a));
		//cpVect rot = [self shape]->body->rot;
		//imageControlBody->v = cpvrotate([self shape]->body->rot, ccp(1130.0f*cpvlength(originalVelocity)*copysign(delta,theta),0.0f));
		lastAngle = sAngle;
	//[self setRotation:self.rotation -150.0f*theta/originalVelocity.x];//cpvtoangle([self shape]->body->v)];
	
	}
}
-(void) addControlBody
{
	if(!imageControlBody)
	imageControlBody = cpBodyNew(INFINITY, INFINITY);
	
	if(!smgr)
		smgr = [[PhysicsManager sharedPhysicsManager] spaceManager];
	imageGear = (cpGearJoint*)[smgr addGearToBody:imageControlBody fromBody:[self shape]->body phase:0.0f ratio:1.0f];
	//imageGear = (cpGearJoint*)cpSpaceAddConstraint(physicsSpace, cpGearJointNew(imageControlBody, imageBody, 0.0f, 1.0f));
	
	imageGear->constraint.biasCoef = 1.0f;
	imageGear->constraint.maxBias = 1.0f;
	imageGear->constraint.maxForce = 500000.0f;
	
	cpBodySetAngle(imageControlBody, cpvtoangle(originalVelocity));
	//if(originalVelocity.x > 0)
//	{
//		//I'm in the bottom left corner, or top left corner, set my rotation to 90 degrees right
//		cpBodySetAngle(imageControlBody, -M_PI/2);
//	}
//	else {
//		//i'm in the bottom right ocner or the top right corner, set rotation to -90, or 90 deg left
//		cpBodySetAngle(imageControlBody, M_PI/2);
//	}

//	
//	if(fixedVelocity.x > 0 && fixedVelocity.y > 0)
//	{
//		//I'm in the bottom left corner, set my rotation to 90 degrees right
//		//cpBodySetAngle(imageControlBody, M_PI/2);
//	}
//	//I'm in the top left corner, set my rotation to 90 degrees right
//	else if(fixedVelocity.x > 0 && fixedVelocity.y <= 0)
//	{
//		//cpBodySetAngle(imageControlBody, M_PI/2);
//	}
//	//I'm in the bottom right corner, add 90
//	else if(fixedVelocity.x <=0 && fixedVelocity.y > 0)
//	{
//		cpBodySetAngle(imageControlBody, -M_PI);
//	}
//	else {
//		cpBodySetAngle(imageControlBody, -M_PI);
//	}
	lastAngle = imageControlBody->a;

}
-(void) removeAndHideEnemy
{
	[super removeAndHideEnemy];
	
	
	
}
-(void) dealloc
{
	if(imageControlBody)
	{
		cpBodyFree(imageControlBody);
	}
    imageControlBody = nil;
	[super dealloc];
}
@end
//Owl
static CGFloat owlSwitchDistance = 240.0f;
@implementation OwlEnemy

+(id) emptyOwlWithPlay:(id) pBasket
{
	EnemyType eType = owl;
	ResourceManager* _rManager= [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [_rManager batchNodeForPath:@"enemyBatch"] ;
	id enemy = [OwlEnemy spriteWithBatchNode:batch rect:[_rManager getSpritePositionWithBatch:batch imageName:stringForEnemy(eType)]];
	
	//[enemy setFixedVelocity:ccp(sAndDirection.size.width, sAndDirection.size.height)];

	[enemy set_eType:eType];
	[enemy initOwl];
	CGFloat reduceSize = [Enemy enemySize:eType];
	
	[enemy setScale:reduceSize];
	return enemy;
}
+(id) owlWithPlayer:(id) pBasket
{
	EnemyType eType = owl;
	ResourceManager* _rManager= [ResourceManager sharedResourceManager];
	CCSpriteBatchNode* batch = [_rManager batchNodeForPath:@"enemyBatch"] ;
	CGRect sAndDirection = [Enemy enemySpawnAndDirectionForType:eType withPlayer:pBasket];
	id enemy = [OwlEnemy spriteWithShape:[Enemy shapeForEnemy:eType withManager:[[PhysicsManager sharedPhysicsManager] spaceManager] atPoint:sAndDirection.origin]
							batchNode:batch
								 rect:[_rManager getSpritePositionWithBatch:batch imageName:stringForEnemy(eType)]];
	[enemy setFixedVelocity:ccp(sAndDirection.size.width, sAndDirection.size.height)];
	
	//[enemy setFlipX:(sAndDirection.size.width < 0)];
	//[enemy setScaleX:(sAndDirection.size.width >= 0) ? fabsf([enemy scaleX]) : -1.0f*fabsf([enemy scaleX])];
	[enemy set_eType:eType];
	[enemy initOwl];
	//[enemy setSwitchDistance:owlSwitchDistance];
	//[enemy setLastPoint:[enemy position]];
	[enemy schedule:@selector(step:)];
	[enemy shape]->collision_type = (unsigned int)@"ENEMY_TYPE";
	[enemy shape]->layers = ENEMY_MASK_BIT;
	[enemy shape]->sensor = YES;
	CGFloat reduceSize = [Enemy enemySize:eType];
	
	[enemy setScale:reduceSize];
	
	
	return enemy;
	
	
}

-(void) setOwlSwitchDistance:(CGFloat) dist
{
	owlSwitchDistance = dist;
}
-(void) initOwl
{
	switchDistance = owlSwitchDistance;
	lastPoint = position_;
}
-(void) step:(ccTime) delta
{
	if(!visible_)
		return;
	
	//don't do anything if not visible
	
	[super step:delta];
	
	switchDistance -= cpvdist(lastPoint, position_);
	if(switchDistance<0)
	{
		[self switchDirection:ccp(1,-1)];
		switchDistance = owlSwitchDistance;
	}
	lastPoint = position_;
	
}

@end



