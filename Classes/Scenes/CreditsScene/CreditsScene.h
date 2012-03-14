//
//  MenuScene.h
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "AppProtocols.h"
//#import "Scene.h"
@class SimpleAudioEngine;
@interface CreditsScene : CCScene<AppSwitchScene> {
	SimpleAudioEngine* _audioManager;
	
}

@end 

@class ResourceManager,PhysicsManager;
@interface CreditsLayer : CCLayer{
	ResourceManager *_resourceManager;
	PhysicsManager* _physicsManager;

	CCMenuItemSprite* backButton;
	
}
-(void) back:(id)sender;



@end
