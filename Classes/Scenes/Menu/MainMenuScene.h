//
//  MenuScene.h
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "AppProtocols.h"
#import "SimpleAudioEngine.h"
//#import "Scene.h"

@class SimpleAudioEngine;

@interface MainMenuScene : CCScene<AppSwitchScene> {
	SimpleAudioEngine* _audioManager;
	
}
+(void) resetGameScene;
+(void) ShutOffMusic;
+(CGRect) genericLeftScreenRect;
+(CGRect) genericRightScreenRect;
+(CGRect) genericCenterScreenRect;
@end 
@class ResourceManager,CloudManager,SimpleAudioEngine,PhysicsManager;

@interface MainMenuLayer : CCLayer{
	ResourceManager *_resourceManager;
	PhysicsManager* _physicsManager;
	SimpleAudioEngine*_audioManager;
	CCMenuItemSprite* playButton;
		CCMenuItemSprite* scoresButton;
		CCMenuItemSprite* creditsButton;
		CCMenuItemSprite* optionsButton;
	CloudManager* cloudManager;
}

-(void) startGame:(id)sender;
-(void) help:(id)sender;

-(void) pressPlay:(id)sender;
-(void) pressOptions:(id)sender;
-(void) pressCredits:(id)sender;
-(void) pressScores:(id)sender;

@end
