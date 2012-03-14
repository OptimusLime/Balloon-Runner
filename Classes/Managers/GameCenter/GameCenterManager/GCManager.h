//
//  PhysicsManager.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>

@protocol GameKitHelperProtocol 
-(void) onLocalPlayerAuthenticationChanged; 
-(void) onFriendListReceived:(NSArray*)friends;
-(void) onPlayerInfoReceived:(NSArray*)players;
@end

@class SaveLoadManager;
@interface GCManager : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate,GameKitHelperProtocol> {
	
	SaveLoadManager* _saveLoadManager;
	NSString* cachedHighestScore;
	GameCenterManager* gameCenterManager;
	NSString* currentLeaderBoard;
	UIViewController* viewLeaderboard; 
	NSError* lastError;
	BOOL remainingAchievements;
	NSMutableDictionary* newAchievementDict;
	
	NSMutableDictionary* achievementCache;
	NSMutableDictionary* localValueCache;
	BOOL isAuthenticated;
	BOOL haveAchievementCache;
	int numberOfAttempts;
	UIViewController* openVC;
	CCScene* overlayScene;
	CCSprite* achievementLayer;
	BOOL actionSet;
	//	int achieveTag;
//	CCAction* achieveAction;
	//GKLeaderboardViewController* leaderboardController; 
}
@property (nonatomic, readonly) NSError* lastError;
+(id) sharedGCManager;
-(BOOL) isActive;
-(BOOL) gameCenterOpen;
-(UIViewController*) gcView;
-(void) achievementEarned:(NSString*) identifier percent:(CGFloat) percentComplete;
-(void) setAuthenticated:(BOOL) val;
-(void)resetLeaderboardsAndAchievements;
-(void) hideAchievementEarned;
-(NSMutableArray*) achievementKeys;
-(void) loadSavedCache;
-(void) saveLocalCache;
-(void) leavingApp;
-(void) returningToApp;
-(void) zeroOutAllSaveValues;
-(void) showLeaderboard;
-(void) showAchievements;
-(void)authenticateLocalUser;
-(UIViewController*) getRootViewController;	
-(void) presentViewController:(UIViewController*)vc;
-(void) dismissModalViewController;
-(void) clearCache;
- (NSMutableDictionary*) checkAchievements:(NSMutableDictionary*) achievementDict;
- (void) checkAndSendAchievements:(NSMutableDictionary*) achievementDict;
-(void) submitScore:(int) height;
-(void)localAchievementCache:(NSMutableDictionary*) localCache error:(NSError*)error;
- (void) showAlertWithTitle: (NSString*) title message: (NSString*) message;
@end
