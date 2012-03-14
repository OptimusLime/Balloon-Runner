//
//  ScoresScene.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppProtocols.h"
@class SimpleAudioEngine;
@interface ScoresScene : CCScene<AppSwitchScene> {
	SimpleAudioEngine* _audioManager;
	
}

@end 

@class ResourceManager,PhysicsManager,GCManager;
@interface ScoresLayer : CCLayer<UIAlertViewDelegate>{
	ResourceManager *_resourceManager;
	PhysicsManager* _physicsManager;
	GCManager* _gcManager;
	CCMenuItemSprite* backButton;
	CCMenuItemSprite* resetButton;
	CCMenuItemSprite* achieveButton;
	CCMenuItemSprite* friendsButton;
	CCMenuItemSprite* scoresButton;
	
	CCMenu* menuLabels;
	CCMenuItemLabel* highestScore;
	CCMenuItemLabel* averageScore;
	CCMenuItemLabel* mostRecentScore;
	CCMenuItemLabel* mostEnemiesShot;
	CCMenuItemLabel* totalEnemiesShot;
}
//Junk call from menu
-(void) labelSelect:(id) sender;
-(void) back:(id)sender;
-(void) reset:(id)sender;
-(void) resetValuesAndLabels;
-(void) achievements:(id)sender;
-(void) friends:(id)sender;
-(void) scores:(id)sender;
@end