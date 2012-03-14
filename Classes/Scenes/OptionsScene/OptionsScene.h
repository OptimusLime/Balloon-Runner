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
//#import "Scene.h"
@class SimpleAudioEngine;
@interface OptionsScene : CCScene<AppSwitchScene> {
	SimpleAudioEngine* _audioManager;
	
}

@end 
@class ResourceManager,CloudManager,PhysicsManager,CCRadioMenu;
@interface OptionsLayer : CCLayer{
	ResourceManager *_resourceManager;
	PhysicsManager* _physicsManager;
	
	CCRadioMenu* soundFXMenu;
	CCRadioMenu* musicMenu;
	
//	CCMenuItemSprite* musicButton;
//	CCMenuItemSprite* sfxButton;
	CCMenuItemSprite* tutorialButton;
	CCMenuItemSprite* backButton;
	CGFloat musicVol;
	CGFloat soundFXVol;
	
}


-(void) back:(id)sender;
-(void) tutorial:(id)sender;
-(void) setSFXOn:(id) sender;
-(void) setSFXOff:(id) sender;
-(void) setMusicOn:(id)sender;
-(void) setMusicOff:(id)sender;

@end
