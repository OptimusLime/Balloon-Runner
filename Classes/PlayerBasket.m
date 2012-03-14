//
//  PlayerBasket.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerBasket.h"
#import "ResourceManager.h"
#import "RandomManager.h"
#import "AppEnumerations.h"
#import "Balloon.h"
#import "SpaceManager.h"
#import "PhysicsManager.h"
#import "ChipmunkObject.h"
#import "BB.h"
#import "SaveLoadManager.h"


#define kPBBalloonCount @"pb.balloonCount"
#define kPBBalloonPrefixX @"pb.balloonNumberX"
#define kPBBalloonPrefixY @"pb.balloonNumberY"
#define kPBBalloonVelocityX @"pb.balloonVelocityX"
#define kPBBalloonVelocityY @"pb.balloonVelocityY"
#define kPBBalloonColorPrefix @"pb.balloonColor"


#define kPBFloatingBalloonCount @"pb.floatingBalloonCount"
#define kPBFloatingBalloonPrefixX @"pb.floatingBalloonNumberX"
#define kPBFloatingBalloonPrefixY @"pb.floatingBalloonNumberY"
#define kPBFloatingBalloonVelocityX @"pb.floatingBalloonVelocityX"
#define kPBFloatingBalloonVelocityY @"pb.floatingBalloonVelocityY"
#define kPBFloatingBalloonColorPrefix @"pb.floatingBalloonColor"

#define kPBBBCount @"pb.bbCount"
#define kPBBBPosX @"pb.bbPosX"
#define kPBBBPosY @"pb.bbPosY"
#define kPBBBVelocityX @"pb.bbVelX"
#define kPBBBVelocityY @"pb.bbVelY"
#define kPBBBReloadTime @"pb.bbReloadTime"

#define kPBPlayerBasketPosX @"pb.pbPosX"
#define kPBPlayerBasketPosY @"pb.pbPosY"
#define kPBPlayerBasketVelX @"pb.pbVelX"
#define kPBPlayerBasketVelY @"pb.pbVelY"
#define kPBPlayerBasketAngle @"pb.pbAngle"

static int maxBBCount = 30;
static CGFloat waitReload = .25f;
static CGFloat balloonRegenTimeAdd = .2f;
static CGFloat balloonRegenTime = 1.0f;
static CGFloat increaseRegenDist = 1500.0f;

static CGFloat maxXAccel= 3.0f;
static CGFloat minXAccel= -3.0f;
static CGFloat maxYAccel= 3.0f;
static CGFloat minYAccel= -3.0f;
static CGFloat GAME_SCORE = 0.0f;
@implementation PlayerBasket

+(id) standardPlayerBasket:(CGPoint) startPoint withParent:(CCNode*)parentNode
{
	ResourceManager* _rManager = [ResourceManager sharedResourceManager]; 
	CCSpriteBatchNode* batch = [_rManager batchNodeForPath:@"projectileBatch"];
	
	PhysicsManager* _pManager = [PhysicsManager sharedPhysicsManager];
	
	
	CGSize halfSize = [_rManager spriteContentSize:@"basketv5.png" fromPath:@"projectileBatch"];
	//CGFloat reduceSize = .2f;
	halfSize.width *= .5f;//reduceSize*.5f;
	halfSize.height *= .5f;//reduceSize*.5f;
	
	cpShape* spriteShape = [[_pManager spaceManager] addPolyAt:startPoint mass:30.0f rotation:0.0f numPoints:4 
													  points:ccp(-halfSize.width, -halfSize.height),ccp(-halfSize.width, halfSize.height),
						  ccp(halfSize.width, halfSize.height),ccp(halfSize.width, -halfSize.height),nil];
	
	//cpShape* spriteShape = [smgr addCircleAt:nil];
	
	id pBasket = [PlayerBasket spriteWithShape:spriteShape batchNode:batch
										  rect:[_rManager getSpritePositionWithBatch:batch imageName:@"basketv5.png"]];
	[parentNode addChild:pBasket z: 3];
	[pBasket initBasket];
	
	
	
	//[pBasket setScale:reduceSize];
	
	return pBasket;
}
- (BOOL) handleBalloonCollision:(CollisionMoment)moment 
                 arbiter:(cpArbiter*)arb 
                   space:(cpSpace*)space
{
	CP_ARBITER_GET_SHAPES(arb, a, b);	
	Balloon* aBall = (Balloon*)a->data;
	Balloon* bBall = (Balloon*)b->data;
	BOOL aFloat = [aBall isFloating];
	BOOL bFloat = [bBall isFloating];
	
	//NSLog(@"Afloat: %@, BFloat: %@", aFloat ? @"YES" : @"NO", bFloat ? @"YES" : @"NO");
	if((aFloat != bFloat))
	{
		if(aFloat)
		{
			cpSpaceAddPostStepCallback(space, &balloonAttach, self,a->data );
		}
		//a is not floating, implies b is floating
		else {
			cpSpaceAddPostStepCallback(space, &balloonAttach, self, b->data);
		}
		return NO;
		
		
	}
	
	
	//NSLog(@"type A %s, type B: %s", [[(id)a->data class] stringValue] ,[(id)b->data class] );
	
	return YES;
}
-(void) initBasket
{
	[self initChipmunkObject];
	[self addPhysicalBodies];
	_rM = [RandomManager sharedRandomManager];
	balloonObjects = [[[NSMutableArray alloc]initWithCapacity:30]retain];
	floatingBalloonObject = [[[NSMutableArray alloc]initWithCapacity:30]retain];

	bbObjects = [[[NSMutableArray alloc] initWithCapacity:30]retain];
	CGSize p = [[CCDirector sharedDirector] winSize];
	[smgr addCollisionCallbackBetweenType:(unsigned int)@"BALLOON_TYPE" otherType:(unsigned int)@"BALLOON_TYPE" 
								   target:self selector:@selector(handleBalloonCollision:arbiter:space:)];
	maxBBDist = cpvlength(ccpMult(ccp(p.width,p.height), 1.0f));
	unusedBBObjects = [[[NSMutableArray alloc] initWithCapacity:30] retain];
	[self populateBBs];
	shotCount = 0;
	nextIncreaseHeight = increaseRegenDist;
		
}
-(void) dealloc 
 { 
     if(imageControlBody)
         cpBodyFree(imageControlBody);
     imageControlBody = nil;
     
	 [floatingBalloonObject release];
	 [balloonObjects release];
	 [bbObjects release];
	 [unusedBBObjects release];
	 [super dealloc];
 }
#pragma mark -
#pragma mark Achievement Management
-(void) addAchievementVariables:(NSMutableDictionary *)achieveDict
{
	//We have access to the player height
	//BB shot count
	//Max balloons
	//Time with one balloon

	
	//CGFloat maxPlayerHeight
	//CGFloat oneBalloonTimer;
//	int shotCount;
//	int maxBalloons;
//	NSLog(@"MaxHeight: %f, Timer: %f, ShotCount: %d, MaxBal %d", maxPlayerHeight, oneBalloonTimer, shotCount, maxBalloons);
	[achieveDict setObject:[NSNumber numberWithInt:maxPlayerHeight] forKey:[NSNumber numberWithInt:kBRPlayerHeight]];
	[achieveDict setObject:[NSNumber numberWithInt:oneBalloonTimer] forKey:[NSNumber numberWithInt:kBRTimeWithOneBalloon]];
	[achieveDict setObject:[NSNumber numberWithInt:shotCount] forKey:[NSNumber numberWithInt:kBRNumberOfShots]];
	[achieveDict setObject:[NSNumber numberWithInt:maxBalloons] forKey:[NSNumber numberWithInt:kBRMaxNumberOfBalloons]];
	
}
-(NSMutableDictionary*) getAchievementVariables
{
	NSMutableDictionary* achieveDict= [NSMutableDictionary dictionaryWithCapacity:1];
	//We have access to the player height
	[achieveDict setObject:[NSNumber numberWithInt:maxPlayerHeight] forKey:[NSNumber numberWithInt:kBRPlayerHeight]];
	[achieveDict setObject:[NSNumber numberWithInt:oneBalloonTimer] forKey:[NSNumber numberWithInt:kBRTimeWithOneBalloon]];
	[achieveDict setObject:[NSNumber numberWithInt:shotCount] forKey:[NSNumber numberWithInt:kBRNumberOfShots]];
	[achieveDict setObject:[NSNumber numberWithInt:maxBalloons] forKey:[NSNumber numberWithInt:kBRMaxNumberOfBalloons]];
	return achieveDict;
	
}
#pragma mark -
#pragma mark SaveLoadState
-(void) addSaveStateValues:(NSMutableDictionary*) saveDict
{
//	[saveDict setObject:[NSNumber numberWithInt:[balloonObjects count]] forKey:kPBBalloonCount]; 
//	
//	//Save playerbasket information, very important
//	
////	NSLog(@"Position: %f,%f", position_.x,position_.y);
//	[saveDict setObject:[NSNumber numberWithFloat:[self position].x] forKey:kPBPlayerBasketPosX];//[ stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[saveDict setObject:[NSNumber numberWithFloat:[self position].y] forKey:kPBPlayerBasketPosY];// stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[saveDict setObject:[NSNumber numberWithFloat:[self shape]->body->v.x] forKey:kPBPlayerBasketVelX];// stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[saveDict setObject:[NSNumber numberWithFloat:[self shape]->body->v.y] forKey:kPBPlayerBasketVelY ];//stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[saveDict setObject:[NSNumber numberWithFloat:[self shape]->body->a] forKey:kPBPlayerBasketAngle];// stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	
//	Balloon* ball;
//	
//	//We need to save all of our balloons that are attached, and their color and position
//	for(int i=0; i < [balloonObjects count]; i++)
//	{
//		ball = [balloonObjects objectAtIndex:i];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball position].x] forKey:[kPBBalloonPrefixX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball position].y] forKey:[kPBBalloonPrefixY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball shape]->body->v.x] forKey:[kPBBalloonVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball shape]->body->v.y] forKey:[kPBBalloonVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithInt:[ball balloonColor]] forKey:[kPBBalloonColorPrefix stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
//	
//	//Save all the floating balloons, color and position,velocity
//	[saveDict setObject:[NSNumber numberWithInt:[floatingBalloonObject count]] forKey:kPBFloatingBalloonCount];
//	
//	for(int i=0; i <[floatingBalloonObject count]; i++)
//	{
//		ball = [floatingBalloonObject objectAtIndex:i];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball position].x] forKey:[kPBFloatingBalloonPrefixX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball position].y] forKey:[kPBFloatingBalloonPrefixY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball shape]->body->v.x] forKey:[kPBFloatingBalloonVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[ball shape]->body->v.y] forKey:[kPBFloatingBalloonVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithInt:[ball balloonColor]] forKey:[kPBFloatingBalloonColorPrefix stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//
//	}
//	//Now save the bbs being fired, their position and velocity
//	[saveDict setObject:[NSNumber numberWithInt:[bbObjects count]] forKey:kPBBBCount];
//	BB* bb;
//	for(int i=0; i <[bbObjects count]; i++)
//	{
//		bb = [bbObjects objectAtIndex:i];
//		[saveDict setObject:[NSNumber numberWithFloat:[bb position].x] forKey:[kPBBBPosX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[bb position].y] forKey:[kPBBBPosY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[bb shape]->body->v.x] forKey:[kPBBBVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[bb shape]->body->v.y] forKey:[kPBBBVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//			}
//	
//
//	
//	
	//Reload time for firing, to prevent types of cheating
	//[saveDict setObject:[NSNumber numberWithFloat:reloadTime] forKey:kPBBBReloadTime];//[NSNumber numberWithFloat:]]
	
	[saveDict addEntriesFromDictionary:[self getAchievementVariables]];
	//You want to grab the achievement variables as well
	//[array addObject:[NSNumber numberWithInt:kBRPlayerHeight]];
//	[array addObject:[NSNumber numberWithInt:kBRTimeWithOneBalloon]];
//	[array addObject:[NSNumber numberWithInt:kBRNumberOfShots]];
//	[array addObject:[NSNumber numberWithInt:kBRMaxNumberOfBalloons]];
//	
	//[saveDict setObject:[NSNumber numberWithInt:numberOfTimesPlayed] forKey:kGSTimesPlayed];
//	[saveDict setObject:[NSNumber numberWithFloat:maxHeight] forKey:kGSMaxHeight];
//	[saveDict setObject:[NSNumber numberWithFloat:averageHeight] forKey:kGSAverageHeight];
}



-(NSMutableArray*) saveStateKeys
{
	NSMutableArray* array = [NSMutableArray array];
	
	
//	
//	[array addObject:kPBPlayerBasketPosX];//[ stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[array addObject: kPBPlayerBasketPosY];//[ stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[array addObject:kPBPlayerBasketVelX ];//];
//	[array addObject:kPBPlayerBasketVelY];//[ stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	[array addObject:kPBPlayerBasketAngle];//[ stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	
//	
//	
//	[array addObject:kPBBalloonCount]; 
//		
//	int savedArrayCount = [[[SaveLoadManager sharedSaveLoadManager] loadNumber:kPBBalloonCount] intValue];
//	//We need to save all of our balloons that are attached, and their color and position
//	for(int i=0; i < savedArrayCount; i++)
//	{
//		[array addObject:[kPBBalloonPrefixX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBalloonPrefixY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBalloonVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBalloonVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBalloonColorPrefix stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
//	
//	//Save all the floating balloons, color and position,velocity
//	[array addObject:kPBFloatingBalloonCount];
//	savedArrayCount = [[[SaveLoadManager sharedSaveLoadManager] loadNumber:kPBFloatingBalloonCount] intValue];
//	for(int i=0; i <savedArrayCount; i++)
//	{
//		[array addObject:[kPBFloatingBalloonPrefixX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBFloatingBalloonPrefixY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBFloatingBalloonVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBFloatingBalloonVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBFloatingBalloonColorPrefix stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
//	//Now save the bbs being fired, their position and velocity
//	[array addObject:kPBBBCount];
//	savedArrayCount = [[[SaveLoadManager sharedSaveLoadManager] loadNumber:kPBBBCount] intValue];
//	for(int i=0; i <savedArrayCount; i++)
//	{
//
//		[array addObject:[kPBBBPosX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBBPosY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBBVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kPBBBVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
//	//Reload time for firing, to prevent types of cheating
//	[array addObject:kPBBBReloadTime];//[NSNumber numberWithFloat:reloadTime]]
//	
//	
	//You want to grab the achievement variables as well
	[array addObject:[NSNumber numberWithInt:kBRPlayerHeight]];
	[array addObject:[NSNumber numberWithInt:kBRTimeWithOneBalloon]];
	[array addObject:[NSNumber numberWithInt:kBRNumberOfShots]];
	[array addObject:[NSNumber numberWithInt:kBRMaxNumberOfBalloons]];
	
//	[array addObject:kGSMaxHeight];
//	[array addObject:kGSAverageHeight];
//	[array addObject:kGSTimesPlayed];
	return array;
	
	
}
-(NSString*) append:(NSString*) a i:(int) i
{
	return [a stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
}
-(void) loadFromSaveStateValues:(NSMutableDictionary*) dict
{
	//This will
	//[self removeBalloonsAndBBs];
//	
//	int arraySize = [[dict objectForKey:kPBBalloonCount] intValue]; 
//	CGPoint posPoint;
//	CGPoint velPoint;
//	//Balloon* aBall;
//	//BB* bb;
//	BalloonColor bColor;
//	
//	posPoint = ccp([[dict objectForKey:kPBPlayerBasketPosX ]floatValue],[[dict objectForKey:kPBPlayerBasketPosY ]floatValue]);
//	velPoint = ccp([[dict objectForKey:kPBPlayerBasketVelX ] floatValue],[[dict objectForKey:kPBPlayerBasketVelY ] floatValue]);
//	CGFloat angle = [[dict objectForKey:kPBPlayerBasketAngle] floatValue];
//
//	//NSLog(@"loading pos: %f,%f", posPoint.x, posPoint.y);
//	[self setPosition: posPoint];
//	//[[self shape] setPosition:posPoint];
//	[self shape]->body->a = angle;
//	[self shape]->body->v = velPoint;
//	
//	
//	
//	
//	//We need to load all of our balloons that are attached, and their color and position
//	for(int i=0; i < arraySize; i++)
//	{
//		posPoint = ccp([[dict objectForKey:[self append:kPBBalloonPrefixX i:i]]floatValue],[[dict objectForKey:[self append:kPBBalloonPrefixY i:i]]floatValue]);
//		velPoint = ccp([[dict objectForKey:[self append:kPBBalloonVelocityX i:i]] floatValue],[[dict objectForKey:[self append:kPBBalloonVelocityY i:i]] floatValue]);
//		bColor = (BalloonColor)[[dict objectForKey:[self append:kPBBalloonColorPrefix i:i]] intValue];
//		
//		[self addBalloon:posPoint withVelocity:velPoint withColor:bColor];
//	}
//	
//	
//	//Now load in the floating balloons
//	arraySize = [[dict objectForKey:kPBFloatingBalloonCount] intValue]; 
//
//	
//	for(int i=0; i <arraySize; i++)
//	{
//		posPoint = ccp([[dict objectForKey:[self append:kPBFloatingBalloonPrefixX i:i]]floatValue],[[dict objectForKey:[self append:kPBFloatingBalloonPrefixY i:i]]floatValue]);
//		velPoint = ccp([[dict objectForKey:[self append:kPBFloatingBalloonVelocityX i:i]]floatValue],[[dict objectForKey:[self append:kPBFloatingBalloonVelocityY i:i]]floatValue]);
//		bColor = (BalloonColor)[[dict objectForKey:[self append:kPBFloatingBalloonColorPrefix i:i]] intValue];
//		
//		[self floatBalloonAt:posPoint withVelocity:velPoint withColor:bColor];
//	}
//	
//	//Now load the bbs being fired, their position and velocity
//	arraySize= [[dict objectForKey:kPBBBCount] intValue]; 
//	for(int i=0; i <arraySize; i++)
//	{
//		posPoint = ccp([[dict objectForKey:[self append:kPBBBPosX i:i]]floatValue],[[dict objectForKey:[self append:kPBBBPosY i:i]]floatValue]);
//		velPoint = ccp([[dict objectForKey:[self append:kPBBBVelocityX i:i]]floatValue],[[dict objectForKey:[self append:kPBBBVelocityY i:i]]floatValue]);
//
//		
//		[self addBBAtPoint:posPoint withVelocity:velPoint];
//	}
//	 reloadTime = [[dict objectForKey:kPBBBReloadTime] floatValue]; 

	//You want to grab the achievement variables as well
	maxPlayerHeight = [[dict objectForKey:[NSNumber numberWithInt:kBRPlayerHeight]]floatValue];
	oneBalloonTimer = [[dict objectForKey:[NSNumber numberWithInt:kBRTimeWithOneBalloon]] floatValue];
	shotCount = [[dict objectForKey:[NSNumber numberWithInt:kBRNumberOfShots]] intValue];
	maxBalloons = [[dict objectForKey:[NSNumber numberWithInt:kBRMaxNumberOfBalloons]] intValue];
	

	
	
}
//This is our score
+(CGFloat) gameScore
{
	return GAME_SCORE;
	
	//This was for testing various numbers
	//return (CGFloat) powf(10, [[RandomManager sharedRandomManager] intRand:5]);//return GAME_SCORE;
}
-(CGFloat) gameHeight
{
	return GAME_SCORE;
}
-(void) setGameScore
{
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	GAME_SCORE = position_.y/(iM*4);
}

-(void) populateBBs
{
	BB* cBB;
	//create a bunch of invisible BBs
	//for (int i=0; i < maxBBCount; i++) {
	while([unusedBBObjects count] < maxBBCount)
	{
	cBB = [BB bbWithPlayer:self];
		[unusedBBObjects addObject:cBB];
		[parent_ addChild:cBB z:10];
	}
	//}
}
-(void) addPhysicalBodies
{
	imageBody = [self shape]->body;
	imageShape = [self shape];
	imageShape->e = 0.9f; imageShape->u = .7f;
	imageShape->layers = BASKET_MASK_BIT;
	imageControlBody = cpBodyNew(INFINITY, INFINITY);
														 

	[smgr addRotaryLimitToBody:imageControlBody fromBody:imageBody min:-M_PI/8 max:M_PI/8];
	//cpBodyApplyForce(imageBody, cpv(0, -101) , cpvzero);
	imageControlBody->a = 0;
	
}
-(Balloon*) addAnyColorBalloon:(CGPoint) placePoint
{
	BalloonColor bColor = (BalloonColor)[_rM intRand:_sBalloon+1 Max:_eBalloon];
	
	Balloon* aBall = [Balloon attachedBalloonWithColor:bColor withPlayer:self atPoint:placePoint];
    [aBall setIsFloating:NO];
	[balloonObjects addObject:aBall];
	[parent_ addChild:aBall z:4];
	
	return aBall;

}
		 
		 -(Balloon*) addBalloon:(CGPoint) placePoint withVelocity:(CGPoint) velocity withColor:(int) bColor
		{
			
			Balloon* aBall = [Balloon attachedBalloonWithColor:bColor withPlayer:self atPoint:placePoint];
			[aBall shape]->body->v = velocity;
            [aBall setIsFloating:NO];
			[balloonObjects addObject:aBall];
			[parent_ addChild:aBall z:4];
			
			return aBall;
			
		}
		 -(Balloon*) floatBalloonAt:(CGPoint) placePoint withVelocity:(CGPoint) velocity withColor:(int) bColor
		 {
			 
			 Balloon* aBall = [Balloon balloonWithColor:bColor withPlayer:self atPoint:placePoint];
			 [aBall setIsFloating:YES];
			 [aBall shape]->body->v = velocity;
			 
			 [floatingBalloonObject addObject:aBall];
			 [parent_ addChild:aBall z:4];
			 
			 return aBall;
			 
			 
		 }
		 
		 
		 
-(Balloon*)floatAnyBalloonAt:(CGPoint)placePoint
{
	BalloonColor bColor = (BalloonColor)[_rM intRand:_sBalloon+1 Max:_eBalloon];
	
	Balloon* aBall = [Balloon balloonWithColor:bColor withPlayer:self atPoint:placePoint];
	[aBall setIsFloating:YES];
	[floatingBalloonObject addObject:aBall];
	[parent_ addChild:aBall z:4];
	
	return aBall;
}
-(void) attachBalloon:(Balloon*)aBall
{
	[aBall attachBalloonToPlayerAtPoint:[aBall position]];
	[balloonObjects addObject:aBall];
	[floatingBalloonObject removeObject:aBall];
}
-(void) pauseGame
{
	
	[self unschedule:@selector(step:)];
	Balloon* aBall;
	for(aBall in balloonObjects)
	{
		[aBall pauseGame];
	}
	
}
-(void) resumeGame
{
	[self schedule:@selector(step:)];
	Balloon* aBall;
	for(aBall in balloonObjects)
	{
		[aBall resumeGame];
	}
}
-(void) resetGame
{
	//we only need to make sure there are BBs to fire, everything else is generated on demand
	[self populateBBs];
	
	CGSize halfSize = [[ResourceManager sharedResourceManager] spriteContentSize:@"basketv5.png" fromPath:@"projectileBatch"];
	//CGFloat reduceSize = .2f;
	halfSize.width *= .5f;//reduceSize*.5f;
	halfSize.height *= .5f;//reduceSize*.5f;
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGPoint desiredPlayerPoint = ccp(s.width*.5, s.height*.15);
	
	cpShape* spriteShape = [[[PhysicsManager sharedPhysicsManager] spaceManager] addPolyAt:desiredPlayerPoint mass:30.0f rotation:0.0f numPoints:4 
														points:ccp(-halfSize.width, -halfSize.height),ccp(-halfSize.width, halfSize.height),
							ccp(halfSize.width, halfSize.height),ccp(halfSize.width, -halfSize.height),nil];
	
	CPCCNODE_MEM_VARS_INIT(spriteShape)
	
	[self addPhysicalBodies];
	
	
	[smgr addCollisionCallbackBetweenType:(unsigned int)@"BALLOON_TYPE" otherType:(unsigned int)@"BALLOON_TYPE" 
								   target:self selector:@selector(handleBalloonCollision:arbiter:space:)];
	
	maxPlayerHeight = 0;
	shotCount = 0;
	oneBalloonTimer = 0;
	maxBalloons = 0;
	
	
}
//override chipmunkobject step
-(void) step:(ccTime)delta
{
	reloadTime -= delta;
	balloonTime -= delta;
	
	[self setGameScore];
	
	//if we have any active bbs
	if([bbObjects count] >0)
	{
		NSMutableArray* removeBBs = [[[NSMutableArray alloc] initWithCapacity:[bbObjects count]+1] autorelease];
		CGFloat distAway;
		BB* bb;
		for(bb in bbObjects)
		{
			
			if( (distAway =  cpvdist([bb position], [self position]))  > maxBBDist)
			{
				//NSLog(@"Daway %f", distAway);
				[removeBBs addObject:bb];
				
			}
			
		}
		
		for(bb in removeBBs)
		{
			[self removeBB:bb];
		}
		[removeBBs removeAllObjects]; 
	}
	if(position_.y > nextIncreaseHeight)
	{
		balloonRegenTime += balloonRegenTimeAdd;
		nextIncreaseHeight += increaseRegenDist;
	}
	if(balloonTime <0)
	{
		[self floatAnyBalloonAt:[self balloonGenPoint]];
		balloonTime = balloonRegenTime;
	}

	[self updateAchievementVariables:delta];
	
}
-(void) updateAchievementVariables:(ccTime) delta
{
	
	//Basically, while we have only one balloon, increment a timer
	//if you have more than one balloon, zero out the timer
	//WE ARE NOT IMPRESSED
	int bCount = [balloonObjects count];
	if(bCount == 1)
		oneBalloonTimer += delta;
	else {
		oneBalloonTimer = 0;
	}

	maxBalloons = MAX(bCount, maxBalloons);
	maxPlayerHeight = MAX([PlayerBasket gameScore], maxPlayerHeight);
}
-(void) removeFloatingBalloon:(Balloon*) aBall
{
    if(aBall)
    {
	//Remove the shape from the world
	[aBall removeBalloonFromSpace];	
	
	//We can make this more elegant later, with a whole bin of balloons to pick from
	[floatingBalloonObject removeObject:aBall];
	
	[parent_ removeChild:aBall cleanup:YES];
        
        if(aBall)
            [aBall release];
        
        aBall = nil;
    }
	
}
-(void) removeBalloonsAndBBs
{
	while([balloonObjects count] != 0)
	{
		[self removeBalloon:[balloonObjects objectAtIndex:0]];
	}
	while([floatingBalloonObject count] != 0)
	{
		[self removeFloatingBalloon:[floatingBalloonObject objectAtIndex:0]];
	}
	//this will add all the BBs into the unsusedbb array, which will remove their spaces
	while([bbObjects count] != 0)
	{
		[self removeBB:[bbObjects objectAtIndex:0]];
	}
	shotCount = 0;
}
-(void)cleanUpPhysics
{
	[self removeBalloonsAndBBs];	
	
	if([self shape])
	{
		[smgr removeAndFreeShape:[self shape]];
		self.shape = nil;
	}
	shotCount = 0;
	
	[smgr removeCollisionCallbackBetweenType:(unsigned int)@"BALLOON_TYPE" otherType:(unsigned int)@"BALLOON_TYPE"];
}
-(void) addBBAtPoint:(CGPoint) point withVelocity:(CGPoint) velocity
{
	BB* bbToThrow;
	bbToThrow = [unusedBBObjects objectAtIndex:0];
	[bbObjects addObject:bbToThrow];
	[unusedBBObjects removeObjectAtIndex:0];
	
	[bbToThrow fakeFireBBWith:velocity andPosition:point];
	//shotCount++;
	
}
-(void) attemptFireAt:(CGPoint) placeToAim
{
	if(reloadTime < 0 && [unusedBBObjects count] > 0)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"bbFire.mp3"];
		//CGPoint pointConvert = [self convertToNodeSpace:placeToAim];
		BB* bbToThrow;
		bbToThrow = [unusedBBObjects objectAtIndex:0];
		[bbObjects addObject:bbToThrow];
		[unusedBBObjects removeObjectAtIndex:0];
		[bbToThrow fireBBTo:placeToAim];
		reloadTime = waitReload;
		shotCount++;
		
	}
}
-(void) removeBB:(BB*) bb
{
	//if the bb is invisible, it has already been removed from the space, and this is not an issue
	if([bb shape])
	{
		[bb removeBBFromSpace];
		
		//if(![unusedBBObjects containsObject:bb])
		[unusedBBObjects addObject:bb];
        
        //if([bbObjects containsObject:bb])
		[bbObjects removeObject:bb];
        
	}
	//[parent_ removeChild:bb cleanup:YES];
	
}
-(void) removeBalloon:(Balloon*) rBall
{
	
	if(rBall)
    {
	//Remove the shape from the world
	[rBall removeBalloonFromSpace];	
	
	//We can make this more elegant later, with a whole bin of balloons to pick from
	[balloonObjects removeObject:rBall];
	//If the balloon happens to have been floating, remove it for good measure
	[floatingBalloonObject removeObject:rBall];
	
	
	[parent_ removeChild:rBall cleanup:YES];
        rBall = nil;
	}
}
-(void) setAcceleration:(CGPoint) aVec
{
	#define CLAMP(x,y,z) MIN(MAX(x,y),z)
	
	aVec = ccp(CLAMP(aVec.x, minXAccel, maxXAccel), CLAMP(aVec.y, minYAccel, maxYAccel));
	
	for(Balloon* aBall in balloonObjects)
	{
		[aBall setCurrentAccel:aVec];
	}
}
-(void) syncPhysics:(void*) callbackFunction
{
	
}
-(CGPoint) balloonGenPoint
{
	CGRect rect = [self viableTopRect];
		
	return  [_rM frandInArea:rect.origin max:ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height))];
		
}
-(CGFloat) balloonMin
{
	//set to 1/4 the height of the screen
	return .25f*[[CCDirector sharedDirector] winSize].height;
}
-(CGFloat) balloonMax
{
	return .32f*[[CCDirector sharedDirector] winSize].height;
}

-(int) balloonCount
{
	return [balloonObjects count];
}
-(CGRect) viableLeftRect
{
	//location = [[CCDirector sharedDirector] convertToGL: location];	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	
	//Generate a point left of the visible screen, i.e between (-480,0), (0,320)
	CGPoint bl = ccp(-s.width,0);
	bl.y  = s.height - bl.y;
	bl = ccpSub(bl, parent_.position);
	//CGPoint tr = ccp(0, s.height);
	//tr.y  = s.height - tr.y;
	//tr = ccpSub(tr, parent.position);
	return CGRectMake(bl.x, bl.y, s.width, s.height);
	
}

-(CGRect) viableCenterRect
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	return CGRectMake(0, 0, s.width, s.height);
}
-(CGRect) viableTopCloudRect
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	//Generate a point on top of the visible screen, i.e between (-240,320), (720,640)
	CGPoint bl = ccp(-s.width/2,1.4*s.height);
	//bl.y  = s.height - bl.y;
	bl = ccpSub(bl, parent_.position);
	//CGPoint tr = ccp(0, s.height);
	//tr.y  = s.height - tr.y;
	//tr = ccpSub(tr, parent.position);
	return CGRectMake(bl.x, bl.y, 2*s.width, s.height);
}
-(CGRect) viableTopRect
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	//Generate a point on top of the visible screen, i.e between (-240,320), (720,640)
	CGPoint bl = ccp(-s.width/2,s.height);
	//bl.y  = s.height - bl.y;
	bl = ccpSub(bl, parent_.position);
	//CGPoint tr = ccp(0, s.height);
	//tr.y  = s.height - tr.y;
	//tr = ccpSub(tr, parent.position);
	return CGRectMake(bl.x, bl.y, 2*s.width, s.height);
}
-(CGRect) viableBottomRect
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	//Generate a point on bottom of the visible screen, close to the screen, i.e between (-240,-160), (720,0)
	CGPoint bl = ccp(-s.width/2,-s.height/2);
	bl = ccpSub(bl, parent_.position);
	return CGRectMake(bl.x, bl.y, 2*s.width, s.height/2);
}
-(CGRect) viableRightRect
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	//Generate a point right of the visible screen, i.e between (480,0), (960,320)
	CGPoint bl = ccp(s.width,0);
	bl.y  = s.height - bl.y;
	bl = ccpSub(bl, parent_.position);
	//CGPoint tr = ccp(0, s.height);
	//tr.y  = s.height - tr.y;
	//tr = ccpSub(tr, parent.position);
	return CGRectMake(bl.x, bl.y, s.width, s.height);
}
-(CGSize) basketSize
{
	return CGSizeMake(contentSize_.width * scaleX_, contentSize_.height*scaleY_);
}
-(cpBody*) playerBody
{
	return imageBody;
}
@end
