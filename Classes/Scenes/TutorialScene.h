//
//  TutorialScene.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class SimpleAudioEngine;
@interface TutorialScene : CCScene {
	SimpleAudioEngine* _audioEngine;
}
@end


@class ResourceManager;
@interface TutorialLayer : CCLayer{
	ResourceManager* _resourceManager;
	NSMutableArray* imageArray;
	int currentImageIx;
	CCMenuItemSprite*	nextButton;
	CCMenuItemSprite*	backButton;
	CCMenuItemSprite*	menuButton;
	
	CCSprite* backSprite;
	CCMenuItemToggle* backMenuToggle;
	CCMenu* backMenuMenu;
}

-(void) setBackgroundTutorial;
-(void) backorMenuPressed:(id)sender;
-(void) next:(id)sender;
-(void) returnToMenu:(id) sender;
-(void) back:(id)sender;
@end
