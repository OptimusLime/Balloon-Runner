//
//  GameScene.h
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "AppProtocols.h"
#import "MoveableButton.h"
@class SimpleAudioEngine;

@interface GameScene : CCScene<AppSwitchScene> {
	SimpleAudioEngine* _audioManager;
}
-(void) pauseGame;
-(void) resumeGame;
-(void) resetGame;
-(void)justPauseTimers;
-(void)justResumeTimers;
-(void) returnToGameMenu;
-(CGFloat) gameScore;
-(void) exitScene;

@end

@class ResourceManager,GuiMenu,PlayerBasket,PauseMenu;
@interface GUILayer : CCLayer
{
	ResourceManager		*_resourceManager;
	
	//CCMenuItemSprite*	cameraButton;
	//CCMenuItemSprite*	lifeSaverButton;
	CCMenuItemSprite*	pauseButton;
	CCMenuItemSprite*	playButton;
	CCMenuItemToggle*	playPauseToggle;
	
	PauseMenu* pauseMenu;
	//SimpleAudioEngine*	_audioManager;
	PlayerBasket* pBasket;
	CCNode* pParent;
	CCMenu* playPauseMenu;
	CGPoint lastBasketPoint;
	CCLabelTTF* speedLabel;
	CCLabelTTF* heightLabel;
	CCLabelTTF* feetLabel;
	int feetMove;
	GuiMenu				*_gameMenu;
	BOOL isPaused;
	BOOL isGameOver;
}
-(void) setPlayer:(id) playerBasket withParent:(id) parentBasket;
-(void) lifeSaverSelected;
-(void) step:(ccTime)delta;
-(void) updateLabels:(ccTime) delta ;
-(void) setHeightLabel:(ccTime) delta ;
-(void) setSpeedLabel:(ccTime) delta ;
-(void) pauseGame;
-(void) resumeGame;
-(void) resetGame;
-(void) gameOver;
-(void) exitScene;
@end

@class ResourceManager, PhysicsManager,CloudManager,EnemyManager,SaveLoadManager;
@interface GameLayer : CCLayer<AchievementManager, AppSwitchScene,SaveLoadState> {

	PhysicsManager*  _physicsManager;
	ResourceManager* _resourceManager;
	SaveLoadManager* _saveLoadManager;
	cpSpace *space;
	PlayerBasket* playerBasket;
	CloudManager* cloudManager;
	EnemyManager* enemyManager;
	CGPoint lastBasketPoint;
	CGPoint moveOverflow;
	CGPoint desiredPlayerPoint;
	BOOL isPaused;
	BOOL isTiming;
	BOOL isGameOver;
	CGFloat timePlayed;
	CGFloat achieveCheck;
	
	int numberOfTimesPlayed;
	
	
	
	CGFloat maxCompletedHeight;
	CGFloat maxHeight;
	CGFloat averageHeight;
	CGFloat mostRecentHeight;
}
-(void) loadFromDict:(NSMutableDictionary*)loadDict;
-(NSMutableArray*) loadStateKeys;
-(void) startTimer;
-(void) pauseTimer;
-(void) resetTimer;
-(void) saveState;

-(void) loadState;
-(CGFloat) gameScore;
-(void) balloonsGone;
-(void) cleanUpPhysics;
-(void) gameOver;
-(void) quitGame;
-(void) exitScene;
-(PlayerBasket*) player;
-(void) step: (ccTime) delta;
-(void) addNewSpriteX:(float)x y:(float)y;
-(void) resetGame;
-(void) createBalloonBunch;
-(void) pauseGame;
-(void) resumeGame;
//-(CGRect) getSpritePosition:(NSString*) pathString imageName:(NSString*) fileName;
//-(NSMutableArray*) autoArrayFromImageDictionary:(NSString*) dictPath;
@end