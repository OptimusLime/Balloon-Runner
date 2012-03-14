//
//  EnemyManager.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnemyManager.h"
#import "ResourceManager.h"
#import "RandomManager.h"
#import "PhysicsManager.h"
#import "Enemy.h"
#import "SpaceManager.h"
#import "PlayerBasket.h"
#import "chipmunk.h"
#import "AppEnumerations.h"
#import "SaveLoadManager.h"
#import "Balloon.h"
#define kEMActiveEnemyCount @"em.activeEnemyCount"

#define kEMActivePositionX @"em.activePosX"
#define kEMActivePositionY @"em.activePosY"

#define kEMActiveVelocityX @"em.activeVelX"
#define kEMActiveVelocityY @"em.activeVelY"
#define kEMOriginalVelocityX @"em.originalVelX"
#define kEMOriginalVelocityY @"em.originalVelY"
#define kEMActiveAngle @"em.activeAngle"
#define kEMActiveType @"em.activeType"

#define kEMRespawnTime @"em.respawnTime"
#define kEMNextIncreaseDistance @"em.nextIncreaseDistance"
#define kEMMaxEnemyCount @"em.maxEnemyCount"
#define kEMTempEnemyKillCount @"em.tempEnemyKillCount"
#define kEMLocalTotalEnemyCount @"em.localTotalEnemyCount"

static CGPoint maxCDist = {1.5*480,1.5*320};
static CGFloat maxEDist = 1.5f*480;
//max cloud count
static int originalMaxCount = 14;
static int maxECount = 14;//4;
static CGFloat enemySpawnTime = .10f;
//static BOOL initializing = NO;
static int maxBirds = 15;
static int maxOwls = 15;
static int maxKites = 15;
static CGFloat difficultyIncreaseDistance = 500;

@implementation EnemyManager
-(id) enemyManagerWithParent:(CCNode*) parentNode andPlayer:(id) pBasket
{
	if ((self = [super init]))
	{
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];
		smgr = [_physicsManager spaceManager];
		_rM = [RandomManager sharedRandomManager];
		parent = parentNode;
		player = pBasket;
		enemyArray = [[NSMutableArray alloc]initWithCapacity:maxECount];
		unusedEnemies = [[NSMutableArray alloc]initWithCapacity:maxECount];
		enemyKillCount = 0;
		//This actuall sets up the collision handlers, and init times
		//[self resetGame];
		//start out at 2000
		nextIncreaseDistance = difficultyIncreaseDistance;
		CGSize p = [[CCDirector sharedDirector] winSize];
		
		maxCDist = ccpMult(ccp(p.width,p.height), 1.5f);
		maxEDist = cpvlength(ccpMult(ccp(p.width,p.height), 1.5f));
		[smgr addCollisionCallbackBetweenType:(unsigned int)@"BALLOON_TYPE" otherType:(unsigned int)@"ENEMY_TYPE" target:self selector:@selector(handleCollision:arbiter:space:)];
		[smgr addCollisionCallbackBetweenType:(unsigned int) @"BB_TYPE" otherType:(unsigned int) @"ENEMY_TYPE" target:self selector:@selector(handleBBEnemyCollision:arbiter:space:)];
		[self populateArrays];//[self initiallyPopulate];
		calledOnce = NO;
		regenTime = 0;
		totalEnemyKillCount = 0;
		localTotalEnemyCount = 0;
	}
	return self;
	
}
- (BOOL) handleCollision:(CollisionMoment)moment 
                 arbiter:(cpArbiter*)arb 
                   space:(cpSpace*)space
{
	CP_ARBITER_GET_SHAPES(arb, a, b);	

	cpSpaceAddPostStepCallback(space, &balloonRemove, player, a->data);
	cpSpaceAddPostStepCallback(space, &enemyRemove, self, b->data);
    
	if(![(Balloon*)a->data isFloating])
		[self singleCallBalloonPopAudio];
		//NSLog(@"type A %s, type B: %s", [[(id)a->data class] stringValue] ,[(id)b->data class] );

	return NO;
}
- (BOOL) handleBBEnemyCollision:(CollisionMoment)moment 
                 arbiter:(cpArbiter*)arb 
                   space:(cpSpace*)space
{
	CP_ARBITER_GET_SHAPES(arb, a, b);	

	cpSpaceAddPostStepCallback(space, &bbRemove, player, a->data);
	cpSpaceAddPostStepCallback(space, &enemyRemove, self, b->data);
	cpSpaceAddPostStepCallback(space, &incrementEnemyKilled, b->data , self);
	
	return NO;
}
-(void) enemyKilled
{
	if(!calledOnce)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"enemyDie.mp3"];
		
		
		enemyKillCount++;	
		
		totalEnemyKillCount++;
		//NSLog(@"localEnemy:%d", localTotalEnemyCount);
		localTotalEnemyCount++;
		maxEnemyKillCount = MAX(maxEnemyKillCount, enemyKillCount);
		
		calledOnce = YES;
	}
}
-(void) updateAchievementVariables:(ccTime) delta
{
	//I own enemy kill count, which doesn't need updated
	
}
-(void) singleCallBalloonPopAudio
{
	if(!singleAudio)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"balloonPopReal.mp3"];
		singleAudio = YES;
	}
}
-(void) addAchievementVariables:(NSMutableDictionary *)achieveDict
{
	//NSLog(@"enemies: %d",enemyKillCount);
	
	//We have access to the player height
	[achieveDict setObject:[NSNumber numberWithInt:totalEnemyKillCount] forKey:[NSNumber numberWithInt:kBREnemyKillCount]];
	
}
-(NSMutableDictionary*) getAchievementVariables
{
	NSMutableDictionary* tempDict= [NSMutableDictionary dictionaryWithCapacity:1];
	//We have access to total enemy kill count
	[tempDict setObject:[NSNumber numberWithInt:totalEnemyKillCount] forKey:[NSNumber numberWithInt:kBREnemyKillCount]];
	return tempDict;
}
-(void) populateArrays
{
	Enemy* eGen;
	for (int i=0; i < maxOwls; i++) {
		//[OwlEnemy emptyOwlWithPlay:player];
		eGen = [OwlEnemy owlWithPlayer:player];
		[eGen removeAndHideEnemy];
		[unusedEnemies addObject:eGen];
	}
	for (int i=0; i < maxBirds; i++) {
		eGen = [BirdEnemy birdWithPlayer:player];
		[eGen removeAndHideEnemy];
		[unusedEnemies addObject:eGen];
	}
	for (int i=0; i < maxKites; i++) {
		eGen = [KiteEnemy kiteWithPlayer:player];
		[eGen removeAndHideEnemy];
		[unusedEnemies addObject:eGen];
	}
}
-(Enemy*) getUnusedEnemy:(int)enemyType
{
	Enemy* search;
	for (int i =0; i< [unusedEnemies count]; i++) {
		search = [unusedEnemies objectAtIndex:i];
		//NSLog(@"EnemyType: %d, desired:%d", [search enemyType] , enemyType);
		if([search enemyType] == enemyType)
			return search;
	}
	return nil;
}
-(void) removeAndHideEnemies
{
	Enemy* anEnemy;
	//Add all enemies to unusued stockpile, clear the array
	for(anEnemy in enemyArray)
	{
		//[anEnemy removeAndHideEnemy];
		[unusedEnemies addObject:anEnemy];
	}
	[enemyArray removeAllObjects]; 
	//now hide all of the enemies
	for(anEnemy in unusedEnemies)
	{
		[anEnemy removeAndHideEnemy];
	}
}
-(void)cleanUpPhysics
{
	[self removeAndHideEnemies];
	//Now remove the collision handlers
	[smgr removeCollisionCallbackBetweenType:(unsigned int)@"BALLOON_TYPE" otherType:(unsigned int)@"ENEMY_TYPE"];
	[smgr removeCollisionCallbackBetweenType:(unsigned int) @"BB_TYPE" otherType:(unsigned int) @"ENEMY_TYPE"];
	enemyKillCount = 0;
	
}
-(void) resetGame
{
	//reset is called after you have cleaned up the physics, so add these back into the space
	[smgr addCollisionCallbackBetweenType:(unsigned int)@"BALLOON_TYPE" otherType:(unsigned int)@"ENEMY_TYPE" target:self selector:@selector(handleCollision:arbiter:space:)];
	[smgr addCollisionCallbackBetweenType:(unsigned int) @"BB_TYPE" otherType:(unsigned int) @"ENEMY_TYPE" target:self selector:@selector(handleBBEnemyCollision:arbiter:space:)];
	//player.position = cpp(player.position.x, 0);//player.position.y);
	
	maxECount = originalMaxCount;
	
	nextIncreaseDistance = difficultyIncreaseDistance;
	CGSize p = [[CCDirector sharedDirector] winSize];
	
	maxCDist = ccpMult(ccp(p.width,p.height), 1.5f);
	maxEDist = cpvlength(ccpMult(ccp(p.width,p.height), 1.5f));
	regenTime = 0;
	enemyKillCount = 0;
	calledOnce = NO;
}
-(void) pauseGame
{
	isPaused = YES;
	Enemy* anEnemy;
	for (anEnemy in enemyArray) {
		[anEnemy unschedule:@selector(step:)];
	}
	
}
-(void) resumeGame
{
	isPaused = NO;
	Enemy* anEnemy;
	for (anEnemy in enemyArray) {
		[anEnemy schedule:@selector(step:)];
	}
}

-(void) step:(ccTime) delta
{
	calledOnce = NO;
	singleAudio = NO;
	regenTime -= delta;
	if(regenTime <= 0)
	{
		[self spawnEnemy];
		regenTime = enemySpawnTime; 
	}
	if([player position].y > nextIncreaseDistance)
	{
		//up to 30 enemies going on at the same time
		maxECount =MIN(maxECount+1, 30);
		nextIncreaseDistance += difficultyIncreaseDistance;
	}
	NSMutableArray* removeEnemies = [[[NSMutableArray alloc] initWithCapacity:[enemyArray count]+1] autorelease];
	CGFloat distAway;
	Enemy* enemy;
	for(enemy in enemyArray)
	{
		
		if( (distAway =  cpvdist([enemy position], [player position]))  > maxEDist)
		{
			//NSLog(@"Daway %f", distAway);
			[removeEnemies addObject:enemy];
			
		}
		
	}
	for(Enemy* rEnemy in removeEnemies)
	{
		[self removeEnemy:rEnemy];
	}
}
-(int) randomEnemyType
{
	//int rEnemy = 
	return  (EnemyType)[_rM intRand:_sEnemy+1 Max:_eEnemy];
	//if(rEnemy == bird)
	//	NSLog(@"Enemy %d",rEnemy);
//	return rEnemy;
	
}
-(void) spawnEnemy
{
	Enemy* eSelect;
	if([enemyArray count] <  maxECount)
	{
		if([unusedEnemies count] > 0)
		{
			//take one from here
			int rix = [_rM intRand:0 Max:[unusedEnemies count]];
			eSelect = [unusedEnemies objectAtIndex:rix];
			//[eSelect respawnEnemy:[self randomEnemyType] withPlayer:player];
			[eSelect respawnEnemyPosition:player];
			//if it doesn't have a parent, add it
			if(![eSelect parent])
				[parent addChild:eSelect z:4];
			
			[unusedEnemies removeObjectAtIndex:rix];
		}
		else
		{
			eSelect = [self addEnemy];
			[parent addChild:eSelect z:4];
		}
		
		[enemyArray addObject:eSelect];
					   

	}
}
-(Enemy*) addEnemy
{
	EnemyType eRan = [self randomEnemyType];
	if(eRan == bird)
	{
		return [BirdEnemy birdWithPlayer:player];
	}
	else if(eRan == owl)
	{
		return [OwlEnemy owlWithPlayer:player];
	}
	else {
		return [KiteEnemy kiteWithPlayer:player];
	}

	//return [Enemy enemyWithType:[self randomEnemyType] withPlayer:player];
	
}
#pragma mark -
#pragma mark SaveLoadState


-(void) addSaveStateValues:(NSMutableDictionary*) saveDict
{
//	[saveDict setObject:[NSNumber numberWithInt:[enemyArray count]] forKey:kEMActiveEnemyCount]; 
//	
//	Enemy* enemy;
//	
//	//We need to save all of our balloons that are attached, and their color and position
//	for(int i=0; i < [enemyArray count]; i++)
//	{
//		enemy = [enemyArray objectAtIndex:i];
//		
//		//if(i==0)
//		//	NSLog(@"posPoint %.2f,%.2f, Vel %.2f, %.2f", [enemy position].x, [enemy position].y, [enemy originalVelocity].x, [enemy originalVelocity].y);
//		//NSLog(@"Enemey pos: %f,%f", [enemy position].x,[enemy position].y);
//	
//		
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy position].x] forKey:[kEMActivePositionX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy position].y] forKey:[kEMActivePositionY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy originalVelocity].x] forKey:[kEMActiveVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy originalVelocity].y] forKey:[kEMActiveVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy fixedVelocity].x] forKey:[kEMOriginalVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy fixedVelocity].y] forKey:[kEMOriginalVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//		[saveDict setObject:[NSNumber numberWithFloat:[enemy shape]->body->a] forKey:[kEMActiveAngle stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	//	NSLog(@"Saved e Type: %d", [enemy enemyType]);
//		[saveDict setObject:[NSNumber numberWithInt:[enemy enemyType]] forKey:[kEMActiveType stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
	
		//Reload time for firing, to prevent types of cheating
	//[saveDict setObject:[NSNumber numberWithFloat:regenTime] forKey:kEMRespawnTime];//[NSNumber numberWithFloat:]]
	//[saveDict setObject:[NSNumber numberWithFloat:nextIncreaseDistance] forKey:kEMNextIncreaseDistance];
	//[saveDict setObject:[NSNumber numberWithInt:maxECount] forKey:kEMMaxEnemyCount];
	
	//NSLog(@"Save kill count: %d", maxEnemyKillCount);
	
	//NSLog(@"maxEnemyKill %d, maxEnemy %d", maxEnemyKillCount, totalEnemyKillCount);
	[saveDict setObject:[NSNumber numberWithInt:maxEnemyKillCount] forKey:kEMTempEnemyKillCount];
	[saveDict setObject:[NSNumber numberWithInt:localTotalEnemyCount] forKey:kEMLocalTotalEnemyCount];
	[saveDict addEntriesFromDictionary:[self getAchievementVariables]];

}


-(NSString*) append:(NSString*) a i:(int) i
{
	return [a stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]];
}
-(NSMutableArray*) saveStateKeys
{
	NSMutableArray* array = [NSMutableArray array];
	
	//[array addObject:kEMActiveEnemyCount]; 
//	int enemyCount = [[[SaveLoadManager sharedSaveLoadManager] loadNumber:kEMActiveEnemyCount] intValue];
//	
//	//NSLog(@"enemyCount: %d",enemyCount);
//	
//	//We need to save all of our balloons that are attached, and their color and position
//	for(int i=0; i < enemyCount; i++)
//	{
//	
//		[array addObject:[kEMActivePositionX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kEMActivePositionY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//		[array addObject:[kEMActiveVelocityX stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		[array addObject:[kEMActiveVelocityY stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//		
//		[array addObject:[self append:kEMOriginalVelocityX i:i]];
//		[array addObject:[self append:kEMOriginalVelocityY i:i]];
//		[array addObject:[kEMActiveAngle stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//		
//		[array addObject:[kEMActiveType stringByAppendingString:[[NSNumber numberWithInt:i] stringValue]]];
//	}
//	
//	//Reload time for firing, to prevent types of cheating
//	[array addObject:kEMRespawnTime];//[NSNumber numberWithFloat:]]
//	[array addObject:kEMNextIncreaseDistance];
//	[array addObject:kEMMaxEnemyCount];
	
	[array addObject:kEMLocalTotalEnemyCount];
	[array addObject:kEMTempEnemyKillCount];
	[array addObject:[NSNumber numberWithInt:kBREnemyKillCount]];
	
	return array;
	
	
}



-(void) loadFromSaveStateValues:(NSMutableDictionary*) dict
{
	//This will
	//[self removeAndHideEnemies];
//	
//	int arraySize = [[dict objectForKey:kEMActiveEnemyCount] intValue]; 
//	CGPoint posPoint;
//	CGPoint velPoint,fixedVel;
//	CGFloat angle;
//	
//	//Balloon* aBall;
//	//BB* bb;
//	EnemyType eType;
//	Enemy* enemy;
//	//We need to load all of our balloons that are attached, and their color and position
//	for(int i=0; i < arraySize; i++)
//	{
//		
//		posPoint = ccp([[dict objectForKey:[self append:kEMActivePositionX i:i]]floatValue],[[dict objectForKey:[self append:kEMActivePositionY i:i]]floatValue]);
//		velPoint = ccp([[dict objectForKey:[self append:kEMActiveVelocityX i:i]] floatValue],[[dict objectForKey:[self append:kEMActiveVelocityY i:i]] floatValue]);
//		if(i==0)
//		NSLog(@"posPoint %.2f,%.2f, Vel %.2f, %.2f", posPoint.x, posPoint.y, velPoint.x, velPoint.y);
//		eType  = (EnemyType)[[dict objectForKey:[self append:kEMActiveType i:i]] intValue];
//		
//		enemy = [self getUnusedEnemy:eType];
//		[enemy changeToEnemy:eType withSpaceManager:[[PhysicsManager sharedPhysicsManager] spaceManager] withStartAndDirection:CGRectMake(posPoint.x, posPoint.y, velPoint.x, velPoint.y)];
//		if(eType == kite)
//		{
//			angle =[[dict objectForKey:[self append:kEMActiveAngle i:i]] floatValue]; 
//			//These are actually swapped above, so original  = fixedVelocity
//			fixedVel = ccp([[dict objectForKey:[self append:kEMOriginalVelocityX i:i]] floatValue],[[dict objectForKey:[self append:kEMOriginalVelocityY i:i]] floatValue]);
//			[(KiteEnemy*)enemy setAngle:angle];
//			[(KiteEnemy*)enemy setUniqueVelocity:fixedVel];
//			
//		}
//		else 			
//			[enemy shape]->body->a = angle;
//	}
//	
//	regenTime = [[dict objectForKey:kEMRespawnTime]floatValue];//[NSNumber numberWithFloat:]]
//	nextIncreaseDistance =[[dict objectForKey:kEMNextIncreaseDistance] floatValue];
//	maxECount =[[dict objectForKey:kEMMaxEnemyCount]intValue];
	
	//NSLog(@"maxEnemyKill %d, maxEnemy %d", maxEnemyKillCount, totalEnemyKillCount);
	//This is the number of enemies killed in the round (NOT FOREVEREVER
	
	
	maxEnemyKillCount = MAX(maxEnemyKillCount, [[dict objectForKey:kEMTempEnemyKillCount] intValue]);
	
	totalEnemyKillCount =  [[dict objectForKey:[NSNumber numberWithInt:kBREnemyKillCount]] intValue];
	localTotalEnemyCount = [[dict objectForKey:kEMLocalTotalEnemyCount] intValue];
	
	
}

-(void) removeEnemy:(Enemy*) remEnemy
{
	//if not visible, return, you're already been removed from the space
	
	if([enemyArray containsObject:remEnemy])
		[enemyArray removeObject:remEnemy];
	
	[remEnemy removeAndHideEnemy];
	
	if(![unusedEnemies containsObject:remEnemy])
		[unusedEnemies addObject:remEnemy];
}
-(void) dealloc
{
	[unusedEnemies release];
	[enemyArray release];
	[super dealloc];
}

@end
