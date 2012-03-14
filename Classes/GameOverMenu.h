//
//  GameOverMenu.h
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CCRadioMenu,ResourceManager;
@interface GameOverMenu : CCLayer {
	ResourceManager* _resourceManager;
	CCSprite* background;
	
	CCSprite* gameOverText;
	CCSprite* tapContinueText;
	
	CCMenuItemSprite* tryAgainButton;
	CCMenuItemSprite* menuButton;
	CCMenuItemSprite* scoresButton;
	
	CCLabelTTF* scoreLabel;
	CCSprite* gameOverCloud;
    CCMenu* partialMenuOne;
    CCMenu* partialMenuTwo;
    BOOL isWaitingForTap;
}
-(void) keepBlinking;
-(void) tryAgainButton:(id)sender;
-(void) returnToMenu:(id)sender;
-(void) scores:(id)sender;
-(void) gameOverFadeComplete;
-(void) tapContinue:(id) sender;
@end
