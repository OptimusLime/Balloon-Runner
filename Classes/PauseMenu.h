//
//  PauseMenu.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class ResourceManager,CCRadioMenu;
@interface PauseMenu : CCLayer {

	ResourceManager* _resourceManager;
	CCSprite* background;
	
	CCRadioMenu* soundFXMenu;
	CCRadioMenu* musicMenu;
	
	CCMenuItemSprite* continueButton;
	CCMenuItemSprite* menuButton;
	CGFloat musicVol;
	CGFloat soundFXVol;
	
}

-(void) setSFXOn:(id) sender;
-(void) setSFXOff:(id) sender;
-(void) setMusicOn:(id)sender;
-(void) setMusicOff:(id)sender;
-(void) continueGame:(id)sender;
-(void) returnToMenu:(id)sender;

@end
