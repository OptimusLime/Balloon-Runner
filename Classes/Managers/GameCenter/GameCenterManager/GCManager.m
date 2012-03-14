//
//  PhysicsManager.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GCManager.h"
#import "SynthesizeSingleton.h"
#import "AppEnumerations.h"
#import "ResourceManager.h"
#import "SaveLoadManager.h"

@interface GCManager()
-(void) ensureInit;
@end

static int MAX_GC_ATTEMPTS = 5;


@implementation GCManager
SYNTHESIZE_SINGLETON_FOR_CLASS(GCManager);

@synthesize lastError;
-(void)resetLeaderboardsAndAchievements
{
	[gameCenterManager resetAchievements];
	[newAchievementDict removeAllObjects];	
	
	//Delete the permanent record of things
	[NSUserDefaults resetStandardUserDefaults];
	[_saveLoadManager clearCache];	
	
	[achievementCache removeAllObjects];
	//[achievementCache release];
	//achievementCache = nil;
	
	[self zeroOutAllSaveValues];
	
	[self loadSavedCache];
	
	//We clear out the cache
	//[_saveLoadManager setNotFirstLaunch];
}
-(void) clearCache
{
	[localValueCache removeAllObjects];	
}
#pragma mark Score Handlers
-(int) savedUserInt:(int) saveName
{
	return 0;
}
-(CGFloat) savedUserFloat:(int) saveName
{
	return 0.0f;
}
-(void) submitScore:(int) height
{
	//NSLog(@"currentLeaderBord %@", currentLeaderBoard);
	if(isAuthenticated)
		[gameCenterManager reportScore:(int64_t)height forCategory:currentLeaderBoard];
	
	//Updating the local value cache for player height
	[localValueCache setObject:[NSNumber numberWithInt:height] forKey:[NSNumber numberWithInt:kBRPlayerHeight]];
	
	
}
//Returns a dictionary of floats indexed by identifier string
- (NSMutableDictionary*) checkAchievements:(NSMutableDictionary*) achievementDict 
{
	
	NSMutableDictionary* returnDict = [NSMutableDictionary dictionary];
	//NSString* identifier= NULL;
	
	//int playerHeight = [[achievementDict objectForKey:kBRPlayerHeight] intValue];
	//	int enemyCount = [[achievementDict objectForKey:kBREnemyKillCount] intValue];
	//	CGFloat playTime = [[achievementDict objectForKey:kBRTimePlayed] doubleValue];
	//	CGFloat survivalWithOne = [[achievementDict objectForKey:kBRTimeWithOneBalloon] doubleValue];
	//	int maxBalloons = [[achievementDict objectForKey:kBRMaxNumberOfBalloons]intValue];
	//	int numberOfShots = [[achievementDict objectForKey:kBRNumberOfShots]intValue];
	
	
	
	//We loop through any values we're checking right now
	//Then we check the local cache to see if the achievement was already unlocked
	//If it hasn't, we add it to our dictionary of achievements that we need to submit
	NSString* identifier;
	CGFloat percentComplete = 0.0f;
	int totalEnemyKill, maxBalloonCount, totalShotCount,playerHeight;
	CGFloat totalPlayTime, totalSurvivalTime;
	CGFloat sharpRatio;
	
	for(NSNumber* numberValue in achievementDict)
	{
		
		
		
		int brValueIdentifier = [numberValue intValue];
		
		NSNumber* achievementScore = [achievementDict objectForKey:numberValue];
		
		
		
		
		
		switch (brValueIdentifier) {
			case kBRPlayerHeight:
				
				//Save the player height here
				[localValueCache setObject:[NSNumber numberWithInt:[achievementScore intValue]] forKey:numberValue];
				
				break;
				
			case kBREnemyKillCount:
				
				 totalEnemyKill =  [self savedUserInt:brValueIdentifier] + [achievementScore intValue];
				
				[localValueCache setObject:[NSNumber numberWithInt:totalEnemyKill] forKey:numberValue];
				
				if(totalEnemyKill >= 500)
				{
					identifier = kAchievementFiveHundredDead;
					percentComplete = 100;
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
					//[gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
				}
				if(totalEnemyKill >= 100)
				{
					identifier = kAchievementOneHundredDead;
					percentComplete = 100;
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}				
					//[gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
				}
				if(totalEnemyKill >= 50)
				{
					identifier = kAchievementFiftyDead;
					percentComplete = 100;
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
					//[gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
				}
				
				if(totalEnemyKill >= 1)
				{
					identifier = kAchievementOneDead;
					percentComplete = 100;
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
					//[gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
					
				}
				
				break;
			case kBRTimePlayed:
				
				 totalPlayTime =  [self savedUserFloat:brValueIdentifier] + [achievementScore floatValue];
				
				[localValueCache setObject:[NSNumber numberWithFloat:totalPlayTime] forKey:numberValue];
				
				if(totalPlayTime >= 5*60*60)
				{
					identifier = kAchievementFiveHoursPlayed;
					percentComplete = 100;
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
					//	[gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
				}
				
				if(totalPlayTime >= 1*60*60)
				{
					identifier = kAchievementOneHourPlayed;
					percentComplete = 100;
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
					//[gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
				}	
				
				break;
			case kBRTimeWithOneBalloon:
				
				totalSurvivalTime =  [achievementScore floatValue];

				
					[localValueCache setObject:[NSNumber numberWithFloat:totalSurvivalTime] forKey:numberValue];
				if(totalSurvivalTime >= 60)
				{
					identifier = kAchievementSurviveSingleBalloon;
					percentComplete = 100;
					
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
				}
				
				
				break;
			case kBRMaxNumberOfBalloons:
				
				maxBalloonCount = [achievementScore intValue];
				[localValueCache setObject:[NSNumber numberWithInt:maxBalloonCount] forKey:numberValue];
				
				if(maxBalloonCount >= 15)
				{
					identifier = kAchievementFifteenBalloons;
					
					percentComplete = 100;
					
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
				}
				if(maxBalloonCount >= 20)
				{
					identifier = kAchievementTwentyBalloons;
					
					percentComplete = 100;
					
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
				}
				if(maxBalloonCount >= 40)
				{
					identifier = kAchievementFortyBalloons;
					
					percentComplete = 100;
					
					if (![achievementCache objectForKey:identifier]) {
						
						[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
						[self achievementEarned:identifier percent:percentComplete];
					}
				}
				
				break;
			case kBRNumberOfShots:
				
				totalShotCount = [achievementScore intValue];
				
				totalEnemyKill = [[achievementDict objectForKey:[NSNumber numberWithInt:kBREnemyKillCount]] intValue];
			
				
				[localValueCache setObject:[NSNumber numberWithInt:totalShotCount] forKey:numberValue];
				
				
				if(totalShotCount >= 50)
				{
					sharpRatio = (CGFloat)totalEnemyKill/((CGFloat)totalShotCount);
					if(sharpRatio > .8)
					{
						identifier = kAchievementSharpShooter;
						percentComplete = 100;
						
						if (![achievementCache objectForKey:identifier]) {
							
							[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
							[self achievementEarned:identifier percent:percentComplete];
						}
					}
				}
				
				if(totalShotCount == 0)
				{
					playerHeight = (int)[[achievementDict objectForKey:[NSNumber numberWithInt:kBRPlayerHeight]] floatValue];
					
					if(playerHeight >= 10000)
					{
						identifier = kAchievementPeacemaker;
						
						percentComplete = 100;
						
						if (![achievementCache objectForKey:identifier]) {
							
							[returnDict setObject:[NSNumber numberWithFloat:percentComplete] forKey:[NSString stringWithString:identifier]];
							[self achievementEarned:[NSString stringWithString: identifier] percent:percentComplete];
						}
						
					}
					
					
				}
				
				
				break;
			default:
				
				break;
		}
	}
	
	return returnDict;
		
		
	
}

static int achieveOverlayTag = 2020202;

-(void) achievementEarned:(NSString*) identifier percent:(CGFloat) percentComplete
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"achievementUnlocked.mp3"];
	   
	[achievementCache setObject:[NSNumber numberWithFloat:percentComplete] forKey:identifier];
	//NSLog(@"AChieve %d, ident%@", [achievementCache count], identifier);
		//Do a permanent save, when achievement earned
	[_saveLoadManager saveValue:[NSNumber numberWithFloat:percentComplete] forKey:identifier];
	
	CCScene* scene = [[CCDirector sharedDirector] runningScene];
	
	
	
	if(!achievementLayer)
	{
		CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
		ResourceManager* _resourceManager = [ResourceManager sharedResourceManager] ;
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"achievementsBatch"];
		achievementLayer  =   [[_resourceManager sprite:@"achieveUnlocked.png" withBatch:batch] retain];
		CGSize sSize = [[CCDirector sharedDirector] winSize];
		achievementLayer.position = ccp(sSize.width/2, [achievementLayer contentSize].height/2 + iM*10.0f);
		[achievementLayer setOpacity:0]; 
		CCSequence* achieveAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.5f],
									 [CCFadeOut actionWithDuration:1.5f],
									 [CCCallFuncND actionWithTarget:self selector:@selector(hideAchievementEarned) data:nil]
									 ,nil] ;
		[achieveAction setTag:achieveOverlayTag];
		actionSet = YES;
		//If it's already in the scene, just run the action
		[achievementLayer runAction:achieveAction];
		
	}
	
	
	if(!overlayScene)
	{
		overlayScene = scene;
		[scene addChild:achievementLayer z:25 tag:achieveOverlayTag];
	}
	else if(overlayScene != scene)
	{
		[scene addChild:achievementLayer z:25 tag:achieveOverlayTag];
		
		[overlayScene removeChildByTag:achieveOverlayTag cleanup:NO];
		overlayScene = scene;
		
		
	}

	if(!actionSet)
	{
	
		[achievementLayer resumeSchedulerAndActions];
		CCSequence* achieveAction = [CCSequence actions:[CCFadeIn actionWithDuration:.5f],
									 [CCFadeOut actionWithDuration:.5f],
									 [CCCallFuncND actionWithTarget:self selector:@selector(hideAchievementEarned) data:nil]
									 ,nil] ;
		[achieveAction setTag:achieveOverlayTag];
		actionSet = YES;
		//If it's already in the scene, just run the action
		[achievementLayer runAction:achieveAction];
		
		
		
		
	}
	
	//achieveTag = achieveAction.tag;
	

}
-(void) leavingApp
{
	[self saveLocalCache];
    if(openVC)
    [self dismissModalViewController];

	
}
-(void) returningToApp
{
	[self loadSavedCache];
	
}
-(void) hideAchievementEarned
{
	[achievementLayer pauseSchedulerAndActions];
	[achievementLayer stopActionByTag:achieveOverlayTag];	
	actionSet = NO;
}
- (void) checkAndSendAchievements:(NSMutableDictionary*) achievementDict
{
	//We're not authenticated, we can do something about this if we want, but it's probably a bad idea cause it
	//could be in the middle of the game
	
	if([achievementDict count] == 0)
		return;
	
	
	
	if(achievementDict)
		[newAchievementDict addEntriesFromDictionary:[self checkAchievements:achievementDict]];
	
	//Don't keep going if there is nothign to submit
	if([newAchievementDict count] == 0)
		return;
	
	
	NSString* achievementKey = nil;
	
	for(NSString* val in newAchievementDict)
	{
		achievementKey = val;
		
	//	NSLog(@"AchieveKey: %@",achievementKey);
		
		break;
	}
	//Cheat to test the system
	
	
		
	
	//Send the first value we find
	//When successful, we'll remove it from lastAchievement dict
	//Then send the next one
	if(!isAuthenticated)
		return;
	
	//NSLog(@"Attempting to send: %@ with percent: %.2f", achievementKey,[[newAchievementDict objectForKey:achievementKey] floatValue] );
	[gameCenterManager submitAchievement:achievementKey percentComplete:[[newAchievementDict objectForKey:achievementKey] floatValue]];
			
}

-(void) showLeaderboard
{
	if(!isAuthenticated)
	{
		[self authenticateLocalUser];
		return;
	}
	GKLeaderboardViewController* leaderboardController = [[[GKLeaderboardViewController alloc]init] autorelease];

	if(leaderboardController)
	{
		//NSLog(@"Showing up");
		leaderboardController.category = currentLeaderBoard;
		leaderboardController.leaderboardDelegate = self;
        leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
      
		[self presentViewController:leaderboardController];
		
	//[[[CCDirector sharedDirector] openGLView] addSubview:viewLeaderboard.view];
	//[viewLeaderboard presentModalViewController: leaderboardController animated: YES];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	
//	NSLog(@"Dismissed");
	[self dismissModalViewController];
  //  [viewLeaderboard dismissModalViewControllerAnimated:YES];
	//[viewLeaderboard.view.superview removeFromSuperview];
	
}

-(void) showAchievements {
	
	if(!isAuthenticated)
	{
		[self authenticateLocalUser];
		return;
	}
	
	GKAchievementViewController* achievementsVC = [[[GKAchievementViewController alloc] init] autorelease];
	
	if (achievementsVC != nil) {
		achievementsVC.achievementDelegate = self; 
		[self presentViewController:achievementsVC];
	}
}
-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewControl {
	[self dismissModalViewController]; 
	//[delegate onAchievementsViewDismissed];
}


-(UIViewController*) getRootViewController
{ 
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}
-(void) presentViewController:(UIViewController*)vc
{
	UIViewController* rootVC = [self getRootViewController]; 
    [rootVC presentModalViewController:vc animated:YES];
    openVC = vc;
}
-(void) dismissModalViewController
{
	UIViewController* rootVC = [self getRootViewController]; 
	[rootVC dismissModalViewControllerAnimated:YES];
    openVC = nil;
}
-(BOOL) gameCenterOpen
{
    if(openVC)return YES;
    else return NO;
}
-(UIViewController*) gcView
{
    return openVC;
}

-(void) registerForLocalPlayerAuthChange {
	
	if ([GameCenterManager isGameCenterAvailable] == NO) return;
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter]; [nc addObserver:self
																			selector:@selector(onLocalPlayerAuthenticationChanged)
																				name:GKPlayerAuthenticationDidChangeNotificationName
																			  object:nil];
	
	
}

//-(void) registerForLocalPlayerAuthChange {
//	
//	if ([GameCenterManager isGameCenterAvailable] == NO) 
//		return;
//	
//	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter]; [nc addObserver:self
//																			selector:@selector(onLocalPlayerAuthenticationChanged)
//																				name:GKPlayerAuthenticationDidChangeNotificationName
//																			  object:nil];
//}
-(void) onLocalPlayerAuthenticationChanged {
	
	//NSLog(@"Authentication changed");
	
	isAuthenticated= [GKLocalPlayer localPlayer].authenticated;
	if(!isAuthenticated)
		return;
	//[gameCenterManager reloadHighScoresForCategory: currentLeaderBoard];
	//Here we load up any achievements that may have been already earned
	
	//This will create a temporary NSDictionary
	//[self loadSavedCache];
	
	[gameCenterManager loadAchievementCache];
	
	//[delegate onLocalPlayerAuthenticationChanged];
}
-(void) authenticateLocalPlayer
{
GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer]; 
	
	if (localPlayer.authenticated == NO) 
	{
	[localPlayer authenticateWithCompletionHandler:^(NSError* error) {
		//[self setLastError:error];
	}];
	}
}

#pragma mark -
#pragma mark Init/Dealloc
-(id) init
{
	if((self = [super init]))
	{
		
		[self ensureInit];
	}
	return self;
}
- (void)dealloc {
    
	if(achievementLayer)
		[achievementLayer release];
	[localValueCache release];
	[newAchievementDict release];
	[viewLeaderboard release];
	//[leaderboardController release];
	[gameCenterManager release];
	[super dealloc];
}
#pragma mark -
#pragma mark GameCenterManager Protocol
//Here we receive information about authorization
- (void) processGameCenterAuth: (NSError*) error
{
	if(error == NULL)
	{
		isAuthenticated= [GKLocalPlayer localPlayer].authenticated;
		if(!isAuthenticated)
			return;
		//[gameCenterManager reloadHighScoresForCategory: currentLeaderBoard];
		//Here we load up any achievements that may have been already earned
		
		//This will create a temporary NSDictionary
		//[self loadSavedCache];
		
		[gameCenterManager loadAchievementCache];
	
	}
	else
	{
	//	NSLog(@"Auth failure");
		isAuthenticated= [GKLocalPlayer localPlayer].authenticated;
		//UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: @"Error Authorizing Game Center Account" 
		//												message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]
		//											   delegate:self cancelButtonTitle: @"Try Again..." otherButtonTitles: NULL] autorelease];
		//[alert show];
		
		
	}
	
}
- (void) scoreReported: (NSError*) error
{
	if(error == NULL)
	{
		//[gameCenterManager reloadHighScoresForCategory: currentLeaderBoard];
//		[self showAlertWithTitle: @"High Score Reported!"
//						 message: [NSString stringWithFormat: @"", [error localizedDescription]]];
	}
	else
	{
		//[self showAlertWithTitle: @"Score Report Failed!"
					//	 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
	
}
-(NSMutableArray*) achievementKeys
{
	NSMutableArray* achieveArray = [NSMutableArray arrayWithCapacity:12];  
	[achieveArray addObject:kAchievementFiftyDead];
	[achieveArray addObject:kAchievementOneDead];
	[achieveArray addObject:kAchievementFiveHundredDead];
	[achieveArray addObject:kAchievementOneHundredDead];
	[achieveArray addObject:kAchievementOneHourPlayed];
	[achieveArray addObject:kAchievementFiveHoursPlayed];
	[achieveArray addObject:kAchievementSharpShooter];
	[achieveArray addObject:kAchievementPeacemaker];
	[achieveArray addObject:kAchievementFifteenBalloons];
	[achieveArray addObject:kAchievementTwentyBalloons];
	[achieveArray addObject:kAchievementFortyBalloons];
	[achieveArray addObject:kAchievementSurviveSingleBalloon];
	return achieveArray;
}
	
	
-(void) zeroOutAllSaveValues
{
	NSMutableDictionary* achieveDict = [NSMutableDictionary dictionary];
	NSMutableArray* keys =  [self achievementKeys];
	for(NSString* s in keys)
	{
		[achieveDict setObject:[NSNumber numberWithFloat:0] forKey:s];
	}
	for(int i= kBRStartInt; i < kBRFinishCount; i++)
	{
		[achieveDict setObject:[NSNumber numberWithFloat:0] forKey:[NSNumber numberWithInt:i]];
	}
		
	[_saveLoadManager saveStateObjects:achieveDict];
	
	
	[_saveLoadManager setNotFirstLaunch];
}
-(void) loadSavedCache
{
	//if(!achievementCache)
	//{
		
		
		NSMutableDictionary* permanentDict = [_saveLoadManager loadNumbers:[self achievementKeys]];
		
		if(permanentDict)
		{
			//If the value is greater than 0%, add it to the achievement cache
			for (id key in permanentDict) {
				if([[permanentDict objectForKey:key] floatValue] > 0)
				{
					[achievementCache setObject:[permanentDict objectForKey:key] forKey:key];
				}
			}
			
		}
	
	
	NSMutableArray* keys = [NSMutableArray array];
	
	for(int i= kBRStartInt; i < kBRFinishCount; i++)
	{
		[keys addObject:[NSNumber numberWithInt:i]];
	}
	permanentDict = [_saveLoadManager loadNumbers:keys];
	if(permanentDict)
	{
		for (id key in permanentDict) {
			
			//int brValueIdentifier = [key intValue];
			
			//Set the value from the permanent values
			[localValueCache setObject:[NSNumber numberWithFloat:[[permanentDict objectForKey:key] floatValue]] forKey:key];
			// NSLog(@"Permanent number: %.2f", [[permanentDict objectForKey:key]floatValue]);
			//switch (brValueIdentifier) {
//				case kBRPlayerHeight:
//
//					
//					break;
//					
//				case kBREnemyKillCount:
//					
//
//					
//					break;
//				case kBRTimePlayed:
//					
//
//					
//					break;
//				case kBRTimeWithOneBalloon:
//	
//					
//					break;
//				case kBRMaxNumberOfBalloons:
//					
//			
//					break;
//				case kBRNumberOfShots:
//					
//
//					break;
//				default:
//					
//					break;
//			}
//		
			
		
		}
	}

	
	
				
	//}
	//else {
	//	//There already is an achievement cache
	//	NSLog(@"Loading an already started achievement cache");
	//}

	
}
-(void) saveLocalCache
{
	[_saveLoadManager saveStateObjects:achievementCache];
	[_saveLoadManager saveStateObjects:localValueCache];
	
}
-(void)localAchievementCache:(NSMutableDictionary*) localCache
{
	if(localCache != nil)
	{
		
		
		//achievementCache = localCache;
		
		//If we had a local cache before the load
		//if(tempAchieve)
//		{
		//First check if we have any achievements we should save locally
		
		
		for(id key in localCache)
		{
			
			//If we don't have the achievement, add it
			if(![achievementCache objectForKey:key])
			{
				GKAchievement* achieve = [localCache objectForKey:key];
				[achievementCache setObject:[NSNumber numberWithFloat:achieve.percentComplete] forKey:key];
			}
			//If we do have teh achievement, we keep the local copy, so do nothing
			
		}
		//Now for all achievements, check if they're not global, if not, then submit them
			for(id key in achievementCache)
			{
				//If it wasn't acknowledged we have this achievement
				if (![localCache objectForKey:key]) {
					//Add this to the list, so next time it will be submitted, this gets submitted as well
					[newAchievementDict setObject:[achievementCache objectForKey:key] forKey:key];
				}
				
			}
			
		//}
		
		haveAchievementCache = YES;
	}
	
}
-(void)localAchievementCache:(NSMutableDictionary*) localCache error:(NSError*)error
{
	//[self showAlertWithTitle: @"Error loading cache:"
	//				 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
}
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error
{
	if(error == NULL)
	{
		//int64_t personalBest= leaderBoard.localPlayerScore.value;
		//personalBestScoreDescription= @"Your Best:";
		//personalBestScoreString= [NSString stringWithFormat: @"%ld", personalBest];
		
		if([leaderBoard.scores count] >0)
		{
	
			GKScore* allTime= [leaderBoard.scores objectAtIndex: 0];
			
			cachedHighestScore= allTime.formattedValue;
			
			[gameCenterManager mapPlayerIDtoPlayer: allTime.playerID];
		}
	}
	else
	{
		//personalBestScoreDescription= @"GameCenter Scores Unavailable";
//		personalBestScoreString=  @"-";
//		leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
//		leaderboardHighScoreDescription=  @"-";
		[self showAlertWithTitle: @"Score Reload Failed!"
						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
	
}
- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error
{
	if((error == NULL) && (ach != NULL))
	{
		
		numberOfAttempts = 0;
		
		//We already added to the real cache, which is stored permanently
		//Add to the real cache 
		//[achievementCache setObject:ach forKey:ach.identifier];
		//remove this object from the send list
		[newAchievementDict removeObjectForKey:ach.identifier];
		
		
		if(ach.percentComplete == 100.0)
		{
		//	[self achievementEarned];
		//	NSLog(@"Achievement earned %@ ",[NSString stringWithFormat: @"Great job!  You earned an achievement: \"%@\"", NSLocalizedString(ach.identifier, NULL)]);
			
		//	[self showAlertWithTitle: @"Achievement Earned!"
				//			 message: [NSString stringWithFormat: @"Great job!  You earned an achievement: \"%@\"", NSLocalizedString(ach.identifier, NULL)]];
		}
		else
		{
			
			if(ach.percentComplete > 0)
			{
				//NSLog(@"Achievement Progress! %@ ", [NSString stringWithFormat: @"Great job!  You're %.0f\%% of the way to: \"%@\"",ach.percentComplete, NSLocalizedString(ach.identifier, NULL)]);
				//[self showAlertWithTitle: @"Achievement Progress!"
					//			 message: [NSString stringWithFormat: @"Great job!  You're %.0f\%% of the way to: \"%@\"",ach.percentComplete, NSLocalizedString(ach.identifier, NULL)]];
			}
		}
		
		if([newAchievementDict count] > 0)
		{
			id key;
			for(id val in newAchievementDict)
			{
				key = val;
				break;
			}
			//Submit the next achievement
			[gameCenterManager submitAchievement:key percentComplete:[[newAchievementDict objectForKey:key] floatValue]];
			
		}
		[ach release];
	}
	else
	{
	
		//NSLog(@"Failed with achievement: %@", ach.identifier);
		//[self showAlertWithTitle: @"Achievement Submission Failed!"
		//				 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
		
		if(numberOfAttempts < MAX_GC_ATTEMPTS)
		{

			
		//if([newAchievementDict count] > 0)
//		{
//			id key;
//			for(id val in newAchievementDict)
//			{
//				key = val;
//				break;
//			}
//			//Submit the next achievement
//			[gameCenterManager submitAchievement:key percentComplete:[[newAchievementDict objectForKey:key] floatValue]];
//			
//		}
		
					//Submit the same achievement
			//[gameCenterManager submitAchievement:ach.identifier percentComplete:ach.percentComplete];
			numberOfAttempts++;
		}
		
	}
	
}
- (void) achievementResetResult: (NSError*) error
{
	NSLog(@"Achievemetns reset");
	cachedHighestScore = nil;
	
	if(error != NULL)
	{
		NSLog(@"Error during reset");
		//[self showAlertWithTitle: @"Achievement Reset Failed!"
//						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
	
	haveAchievementCache = NO;
	
	//achievementCache = nil;
	
	
}
- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error
{
	if((error == NULL) && (player != NULL))
	{
		//leaderboardHighScoreDescription= [NSString stringWithFormat: @"%@ got:", player.alias];
		
		if(cachedHighestScore != NULL)
		{
			//leaderboardHighScoreString= self.cachedHighestScore;
		}
		else
		{
			//self.leaderboardHighScoreString= @"-";
		}
		
	}
	else
	{
		//self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
	//	self.leaderboardHighScoreDescription=  @"-";
	}
	
}
-(void)authenticateLocalUser
{
	if(gameCenterManager)
		[gameCenterManager authenticateLocalUser];
}
-(BOOL) isActive
{
	return isAuthenticated;
}
#pragma mark -
#pragma mark Initialization

-(void) ensureInit
{
	if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
	{
		currentLeaderBoard = kBRiPadLeaderboard;
	}
	else {
		currentLeaderBoard = kBRHeightLeaderboard;
	}

	_saveLoadManager = [SaveLoadManager sharedSaveLoadManager];  
	//Init with # of achievements
	achievementCache = [[NSMutableDictionary alloc]initWithCapacity:12];
	localValueCache = [[NSMutableDictionary alloc]initWithCapacity:12];
	
	if([GameCenterManager isGameCenterAvailable])
	{
	//	leaderboardController = [[GKLeaderboardViewController alloc]init];
		
		[self registerForLocalPlayerAuthChange];
		viewLeaderboard = [[UIViewController alloc]init];
		newAchievementDict = [[NSMutableDictionary alloc] init];
		gameCenterManager= [[GameCenterManager alloc] init];
		[gameCenterManager setDelegate: self];
		[gameCenterManager authenticateLocalUser];
		
		[self loadSavedCache];
		//[self updateCurrentScore];
	}
	else
	{
		[self showAlertWithTitle: @"Game Center Support Required!"
						 message: @"The current device does not support Game Center, sorry!"];
	}
	
}
#pragma mark -
#pragma mark Helper Functions
- (void) showAlertWithTitle: (NSString*) title message: (NSString*) message
{
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: title message: message 
												   delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] autorelease];
	[alert show];
	
}

@end
