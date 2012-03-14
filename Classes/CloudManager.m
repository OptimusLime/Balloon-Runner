//
//  CloudManager.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CloudManager.h"
#import "Cloud.h"
#import "ChipmunkObject.h"
#import "RandomManager.h"
#import "SpaceManager.h"
#import "ResourceManager.h"
#import "PhysicsManager.h"
#import "AppEnumerations.h"
#import "PlayerBasket.h"
#import "MainMenuScene.h"
#import "CCDirector.h"
#import "SaveLoadManager.h"


#define kCMCloudCount @"cm.cloudCount"
#define kCMCloudPrefixX @"cm.cloudPosX"
#define kCMCloudPrefixY @"cm.cloudPosY"
#define kCMCloudType @"cm.cloudType"
//remove if you become more than a 1.5 times a screen away
static CGPoint maxCloudDist = {1.5*480,1.5*320};
//max cloud count
static CGFloat cloudSpeedX = .6f;
//static CGFloat cloudSpeedY = 1.0f;
static int maxCCount = 14;
static BOOL initializing = NO;



@implementation CloudManager

-(id) cloudManagerWithParent:(CCNode*) parentNode andPlayer:(id) pBasket
{
	if ((self = [super init]))
	{
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];
		smgr = [_physicsManager spaceManager];
		_rM = [RandomManager sharedRandomManager];
		parent = parentNode;
		player = pBasket;
		cloudArray = [[[NSMutableArray alloc]initWithCapacity:maxCCount] retain];
		[self resetGame];
			CGSize p = [[CCDirector sharedDirector] winSize];
		cloudZ = 2;
		maxCDist = ccpMult(ccp(p.width,p.height), 1.5f);
		maxCloudDist = maxCDist;
		maxClouds = maxCCount;
		[smgr addCollisionCallbackBetweenType:(unsigned int)@"CLOUD_TYPE" otherType:(unsigned int)@"CLOUD_TYPE" target:self selector:@selector(handleCollision:arbiter:space:)];
		collisionAdded = YES;
		[self initiallyPopulate];
	
		//windowSize = [[CCDirector sharedDirector] winSize];
	}
	return self;
}
-(id) movingCloudManagerWithParent:(CCNode*) parentNode z:(int) zLevel
{
	if ((self = [super init]))
	{
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];
		smgr = [_physicsManager spaceManager];
		_rM = [RandomManager sharedRandomManager];
		parent = parentNode;
	
		cloudArray = [[[NSMutableArray alloc]initWithCapacity:maxCCount]retain];
		CGSize p = [[CCDirector sharedDirector] winSize];
		cloudZ = zLevel;
		//regen closer
		maxCDist = ccpMult(ccp(p.width,p.height), 1.5f);
		//maxCDist = ccpMult(ccp(p.width,p.height), 1.5f);
		maxCloudDist = maxCDist;
		
		maxClouds = 16;
		
		cloudsMove = YES;
		//windowSize = [[CCDirector sharedDirector] winSize];
		//[smgr addCollisionCallbackBetweenType:(unsigned int)@"CLOUD_TYPE" otherType:(unsigned int)@"CLOUD_TYPE" target:self selector:@selector(handleCollision:arbiter:space:)];
		collisionAdded =NO;// YES;
		[self initiallyPopulate];
		
	
		
	}
	return self;
}
- (BOOL) handleCollision:(CollisionMoment)moment 
                 arbiter:(cpArbiter*)arb 
                   space:(cpSpace*)space
{
	CP_ARBITER_GET_SHAPES(arb, a, b);	
	//Data points to the chipmunkImage Object
	
	//Cloud* cloud = (Cloud*)b->data;
	cpSpaceAddPostStepCallback(space, &cloudMove, self, b->data);
	//[self repositionCloud:cloud];
	//[gameObject setRemoveFromSpace:YES];
	return NO;
}

-(CGPoint) genCloudPoint
{
	//We're going to need to take into account the cloud size when generating these! not yet though, test first
	int r = [_rM intRand:5];
	CGRect rect ;
	if(r == 0)
	{
		//return from the left gen point
		 rect = [player viableLeftRect];
		//return [_rM frandInArea:rect.origin max:ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height))];
	
	}
	else if(r == 1)
	{
			 rect = [player viableRightRect];
			
	}
	else {
		if(initializing && (r % 2) == 0)
		{
			rect = [player viableCenterRect];
		}
		else {
			rect = [player viableTopCloudRect];//[player viableTopRect];
		}

			 
	}

	cpVect test = [_rM frandInArea:rect.origin max:ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height))];
	
	
	return test; 
}
-(CGRect) genLeftRightCloudRect
{
	//We're going to need to take into account the cloud size when generating these! not yet though, test first
	int r = [_rM intRand:2];
	CGRect rect;
	CGRect retRect = CGRectZero;
	if(r == 0)
	{
		//return from the left gen point
		if(initializing && [_rM intRand:2])
			rect = [MainMenuScene genericCenterScreenRect];
		else
			rect = [MainMenuScene genericLeftScreenRect];
		//return [_rM frandInArea:rect.origin max:ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height))];
		
		//retrect size is actuall the direction of the cloud
		retRect.size.width = cloudSpeedX;
		retRect.size.height = 0;
	}
	else 
	{
		
		if(initializing && [_rM intRand:2])
			rect = [MainMenuScene genericCenterScreenRect];
		else
			rect = [MainMenuScene genericRightScreenRect];
	
		
		retRect.size.width = -cloudSpeedX;
		retRect.size.height = 0;
	}
	
	cpVect test = [_rM frandInArea:rect.origin max:ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height))];
	retRect.origin = test;
	
	return retRect; 
}

-(void) initiallyPopulate
{
	initializing = YES;
	Cloud* gCloud ;
//	CGPoint newPoint;
	CGRect cloudMove;
	while([cloudArray count] < maxClouds)
	{
		if(cloudsMove)
		{
			
			 cloudMove = [self genLeftRightCloudRect];
			gCloud = [self addCloud:cloudMove.origin];
			[gCloud fixConstantVelocity:ccp(cloudMove.size.width,cloudMove.size.height)];
			
			
			
			
		}
		else {
		
			gCloud = [self addCloud:[self genCloudPoint]];
		}
		
		
		while ([self insideClouds:gCloud]) {
			[self repositionCloud:gCloud];

		}
		
		[cloudArray addObject:gCloud];
		
		
		
	}
	initializing = NO;

}
-(BOOL) insideClouds:(Cloud*) newCloud
{
	CGPoint lPoint, rPoint, tlPoint,brPoint;
	lPoint = [newCloud leftCloudPoint];
	rPoint = [newCloud rightCloudPoint];
	tlPoint =[newCloud topLeftPoint];
	brPoint = [newCloud bottomRightPoint];
	for (Cloud* cloud in cloudArray) {
		if(cloud == newCloud)
			continue;
		if([cloud isInsideCloud:lPoint] || [cloud isInsideCloud:rPoint]||[cloud isInsideCloud:tlPoint] || [cloud isInsideCloud:brPoint] || [cloud isInsideCloud:[newCloud position]])
		{
			return YES;
		}
	}
	return NO;
}
-(void) repositionCloud:(Cloud*) cloud
{
	
	if(cloudsMove)
	{
		CGRect newMove = [self genLeftRightCloudRect];
		[cloud shape]->body->v = cpvzero;
		cpBodyResetForces([cloud shape]->body);
		
		[cloud setPosition:newMove.origin];
		[cloud fixConstantVelocity:ccp(newMove.size.width,newMove.size.height)];
		
	}
	else 
		[cloud setPosition:[self genCloudPoint]];
}
-(Cloud*) addCloud:(CGPoint) cloudPoint cloudType:(int) cloudType
{
	if([cloudArray count] == maxClouds)
		return nil;
	
	CloudType cType = (CloudType)cloudType;
	
	
	CGSize halfSize = [_resourceManager spriteContentSize:stringForCloud(cType) fromPath:@"backCloudBatch"];
	//CGFloat reduceSize = .4f;
	halfSize.width *= .5f;//reduceSize*.5f;
	halfSize.height *= .5f;//reduceSize*.5f;
	
	
	cpShape* shape = [smgr addPolyAt:cloudPoint mass:10.0f rotation:0.0f numPoints:4 points:ccp(-halfSize.width, -halfSize.height),ccp(-halfSize.width, halfSize.height),
					  ccp(halfSize.width, halfSize.height),ccp(halfSize.width, -halfSize.height),nil] ;
	
	CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"backCloudBatch"];
	
	Cloud* nCloud = (cloudsMove) ?  
	[Cloud moveableCloudWithShape:shape batchNode:batch
					  rect:[_resourceManager getSpritePositionWithBatch:batch 
															  imageName:stringForCloud(cType)]]
	:[Cloud spriteWithShape:shape batchNode:batch
									  rect:[_resourceManager getSpritePositionWithBatch:batch 
																			  imageName:stringForCloud(cType)]];
	//[nCloud setScale:reduceSize];
	[nCloud setCloudType:cType];
	
	[parent addChild:nCloud z:cloudZ];
	
	
	return nCloud;
	
}
-(Cloud*) addCloud:(CGPoint)cloudPoint
{
	if([cloudArray count] == maxClouds)
		return nil;
	
	CloudType cType = (cloudsMove) ? (CloudType)[_rM intRand:c3 Max:_eCloud] :(CloudType)[_rM intRand:_sCloud +1 Max:_eCloud];
	
	
	CGSize halfSize = [_resourceManager spriteContentSize:stringForCloud(cType) fromPath:@"backCloudBatch"];
	//CGFloat reduceSize = .4f;
	halfSize.width *= .5f;//reduceSize*.5f;
	halfSize.height *= .5f;//reduceSize*.5f;
	
	
	cpShape* shape = [smgr addPolyAt:cloudPoint mass:10.0f rotation:0.0f numPoints:4 points:ccp(-halfSize.width, -halfSize.height),ccp(-halfSize.width, halfSize.height),
					  ccp(halfSize.width, halfSize.height),ccp(halfSize.width, -halfSize.height),nil] ;
	
	CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"backCloudBatch"];
	
	Cloud* nCloud = (cloudsMove) ?  
	[Cloud moveableCloudWithShape:shape batchNode:batch
							 rect:[_resourceManager getSpritePositionWithBatch:batch 
																	 imageName:stringForCloud(cType)]]
	:[Cloud spriteWithShape:shape batchNode:batch
					   rect:[_resourceManager getSpritePositionWithBatch:batch 
															   imageName:stringForCloud(cType)]];
	//[nCloud setScale:reduceSize];
	[nCloud setCloudType:cType];
	
	[parent addChild:nCloud z:cloudZ];
	
	
	return nCloud;
	
}
-(void) removeCloudsFromArray
{
	while([cloudArray count] != 0)
	{
		[self removeCloud:[cloudArray objectAtIndex:0]];
	}
	
}
-(void)cleanUpPhysics
{
	
	[self removeCloudsFromArray];
	
	if(collisionAdded)
		[smgr removeCollisionCallbackBetweenType:(unsigned int)@"CLOUD_TYPE" otherType:(unsigned int)@"CLOUD_TYPE"];
	
	collisionAdded = NO;
	
}
-(void) pauseGame
{
	isPaused = YES;
	//[self unschedule:(
}
-(void) resumeGame
{
	isPaused = NO;
	//[self schedule:@selector(step:)];
}
-(void) resetGame
{
	CGSize p = [[CCDirector sharedDirector] winSize];
	cloudZ = 2;
	maxCDist = ccpMult(ccp(p.width,p.height), 1.5f);
	maxCloudDist = maxCDist;
	maxClouds = maxCCount;
	[smgr addCollisionCallbackBetweenType:(unsigned int)@"CLOUD_TYPE" otherType:(unsigned int)@"CLOUD_TYPE" target:self selector:@selector(handleCollision:arbiter:space:)];
	collisionAdded = YES;
	//When resetting, we should initialized the population for the cloud maanager specifically
	[self initiallyPopulate];
}
-(void) step:(ccTime) delta
{
//	CGFloat xCDist, yCDist;
	Cloud* cCloud;
	CGPoint tDist;
	CGSize wSize = [[CCDirector sharedDirector] winSize];
	
	
	
	for(int i=0; i < [cloudArray count]; i++)
	{
		cCloud= [cloudArray objectAtIndex:i];
		
		
		if(cloudsMove)
		{
			if(wSize.width == 0)
			{
				wSize.width = 480;
				wSize.height = 320;
			}
			BOOL right = [cCloud isMovingRight];
			
			tDist = [cCloud position];
			
			if((right && tDist.x > 1.3*wSize.width ) || (!right && tDist.x < -.33f*wSize.width))
			{
				[self repositionCloud:cCloud];
				while ([self insideClouds:cCloud]) {				
				//somebody is further out than they should be, which means you're off the screen in terms of x or y, remove!
				[self repositionCloud:cCloud];
				}
			}
		}
		else {
			

		tDist = ccpSub([cCloud position], [player position]);
		tDist = ccp(fabsf(tDist.x), fabsf(tDist.y));
		if(tDist.x > maxCDist.x || tDist.y > maxCDist.y)
		{
			[self repositionCloud:cCloud];
			while ([self insideClouds:cCloud]) {
			//somebody is further out than they should be, which means you're off the screen in terms of x or y, remove!
			[self repositionCloud:cCloud];
			}
			
		}
		}
		
	}
	
	//if(!cloudsMove)
//	{
//		for(Cloud* cloud in cloudArray)
//		{
//			[cloud step:delta];
//		}
//	}
	


}

#pragma mark -
#pragma mark SaveLoadState



-(void) addSaveStateValues:(NSMutableDictionary*) saveDict
{
		
//	[saveDict setObject:[NSNumber numberWithInt:[cloudArray count]] forKey:kCMCloudCount]; 
//	
//	Cloud* cloud;
//	
//	//We need to save all of our balloons that are attached, and their color and position
//	for(int i=0; i < [cloudArray count]; i++)
//	{
//		cloud = [cloudArray objectAtIndex:i];
//		[saveDict setObject:[NSNumber numberWithFloat:[cloud position].x] forKey:[kCMCloudPrefixX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[cloud position].y] forKey:[kCMCloudPrefixY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithInt:[cloud cloudType]] forKey:[kCMCloudType stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
	
	
}



-(NSMutableArray*) saveStateKeys
{
	NSMutableArray* array = [NSMutableArray array];
	
//	[array addObject:kCMCloudCount]; 
//	int cloudCount = [[[SaveLoadManager sharedSaveLoadManager] loadNumber:kCMCloudCount] intValue];
//	//We need to save all of our balloons that are attached, and their color and position
//	for(int i=0; i < cloudCount; i++)
//	{
//		[array addObject:[kCMCloudPrefixX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kCMCloudPrefixY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kCMCloudType stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
	
	return array;	
}
-(NSString*) append:(NSString*) a i:(int) i
{
	return [a stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
}
-(void) loadFromSaveStateValues:(NSMutableDictionary*) dict
{
	//This will
//	[self removeCloudsFromArray];
//	
//	int arraySize = [[dict objectForKey:kCMCloudCount] intValue]; 
//	CGPoint posPoint;
//	//Balloon* aBall;
//	//BB* bb;
//	//Cloud* cloud;
//	int cloudType;
//	//We need to load all of our balloons that are attached, and their color and position
//	for(int i=0; i < arraySize; i++)
//	{
//		posPoint = ccp([[dict objectForKey:[self append:kCMCloudPrefixX i:i]]floatValue],[[dict objectForKey:[self append:kCMCloudPrefixY i:i]]floatValue]);
//		cloudType = (BalloonColor)[[dict objectForKey:[self append:kCMCloudType i:i]] intValue];
//		
//		[self addCloud:posPoint cloudType:cloudType];
//	}
	
	

	
	
	
	
}


-(void) removeCloud:(Cloud*) rCloud
{
	[rCloud removeCloudShape];
	[cloudArray removeObject:rCloud];
	
}
-(void) dealloc
{
	//if(collisionAdded)
//	[smgr removeCollisionCallbackBetweenType:(unsigned int)@"CLOUD_TYPE" otherType:(unsigned int)@"CLOUD_TYPE"];
//	while([cloudArray count] != 0)
//	{
//		[self removeCloud:[cloudArray objectAtIndex:0]];
//	}
	[self cleanUpPhysics];
	[cloudArray release];
	
	[super dealloc];
}


@end
