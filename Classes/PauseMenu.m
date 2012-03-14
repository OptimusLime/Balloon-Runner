//
//  PauseMenu.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PauseMenu.h"
#import "GameScene.h"
#import "ResourceManager.h"
#import "SimpleAudioEngine.h"
#import "CCRadioMenu.h"
#import "AppEnumerations.h"
@implementation PauseMenu

- (id) init {
    self = [super init];
    if (self != nil) {
		_resourceManager = [ResourceManager sharedResourceManager];
		
		
		soundFXVol = DEFAULT_EFFECTS_VOLUME;
		musicVol = DEFAULT_MUSIC_VOLUME;
		CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
		
		[CCMenuItemFont setFontSize:iM*20];
        [CCMenuItemFont setFontName:@"Helvetica"];
		CGSize sSize = [[CCDirector sharedDirector] winSize];
		CGFloat swh = sSize.width/2;
		CGFloat shh = sSize.height/2;
		// CCMenuItem *start = [CCMenuItemFont itemFromString:@"Start Game"
		//			target:self
		//			  selector:@selector(startGame:)];
        //CCMenuItem *help = [CCMenuItemFont itemFromString:@"Help"
		//				   target:self
		//				 selector:@selector(help:)];
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"pauseMenuBatch"];
		//[batch.texture setAliasTexParameters];
		//[self addChild:batch];
		
		CCSprite* backOptions = [_resourceManager sprite:@"pauseCloud.png" withBatch:batch];
		backOptions.position = ccp(swh,shh);
		[self addChild:backOptions z:1];
		CCSprite* normSpriteOn = [_resourceManager sprite:@"onPauseB.png" withBatch:batch];
		CCSprite* selSpriteOn = [_resourceManager sprite:@"onPauseR.png" withBatch:batch];
		
		CCSprite* normSpriteOff = [_resourceManager sprite:@"offPauseB.png" withBatch:batch];
		CCSprite* selSpriteOff = [_resourceManager sprite:@"offPauseR.png" withBatch:batch];
		
		CCMenuItemSprite* soundFXOn =  [CCMenuItemSprite itemFromNormalSprite:normSpriteOn selectedSprite:selSpriteOn target:self selector:@selector(setSFXOn:)];
		CCMenuItemSprite* soundFXOff = [CCMenuItemSprite itemFromNormalSprite:normSpriteOff selectedSprite:selSpriteOff target:self selector:@selector(setSFXOff:)];
		if([[SimpleAudioEngine sharedEngine] effectsVolume] > 0.0)
			[soundFXOn selected];
		else
		{
			[soundFXOff selected];
		}
		
		
		soundFXMenu = [CCRadioMenu menuWithItems:soundFXOn,soundFXOff,nil];
		[soundFXMenu alignItemsHorizontallyWithPadding:iM*55.0f];
		soundFXMenu.position = ccpAdd(soundFXMenu.position, ccp(iM*50.0, -iM*20.0f));
		[self addChild:soundFXMenu z:3];
		
		normSpriteOn = [_resourceManager sprite:@"onPauseB.png" withBatch:batch];
		selSpriteOn =  [_resourceManager sprite:@"onPauseR.png" withBatch:batch];
		
		normSpriteOff = [_resourceManager sprite:@"offPauseB.png" withBatch:batch];
		selSpriteOff = [_resourceManager sprite:@"offPauseR.png" withBatch:batch];
		
		CCMenuItemSprite* musicOn =  [CCMenuItemSprite itemFromNormalSprite:normSpriteOn selectedSprite:selSpriteOn target:self selector:@selector(setMusicOn:)];
		CCMenuItemSprite* musicOff = [CCMenuItemSprite itemFromNormalSprite:normSpriteOff selectedSprite:selSpriteOff target:self selector:@selector(setMusicOff:)];
		if([[SimpleAudioEngine sharedEngine] backgroundMusicVolume] > 0.0)
			[musicOn selected];
		else
		{
			[musicOff selected];
		}
		musicMenu = [CCRadioMenu menuWithItems:musicOn,musicOff,nil];
		[musicMenu alignItemsHorizontallyWithPadding:iM*55.0f];
		musicMenu.position = ccpAdd(musicMenu.position, ccp(iM*50.0, +iM*20.0f));
		[self addChild:musicMenu z:3];
		
		
		CCSprite* normSprite = [_resourceManager sprite:@"returnB.png" withBatch:batch];
		CCSprite* selSprite = [_resourceManager sprite:@"returnR.png" withBatch:batch];
		
		
		continueButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(continueGame:)];
		
		normSprite = [_resourceManager sprite:@"menuB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"menuR.png" withBatch:batch];
		
		
		menuButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
														 target:self selector:@selector(returnToMenu:)];
		
        CCMenu *menu = [CCMenu menuWithItems:menuButton, continueButton, nil];
		//menu.position = ccp(-swh -3.0f + [[backButton normalImage] contentSize].width/2, -shh -3.0f + [[backButton normalImage ]contentSize].height/2);
		[menu alignItemsHorizontally];
		continueButton.position = ccp(iM*54.0f,-iM*68.0f);
		menuButton.position = ccp(-iM*68.0f,-iM*62.0f);
		//menu.position = ccpAdd(menu.position, ccp(-swh+ [[backButton normalImage] contentSize].width/2 , shh - [[backButton normalImage ]contentSize].height/2));
        //[menu alignItemsVertically];
		
		
        [self addChild:menu z:5];

    }
    return self;
}


-(void) setSFXOn:(id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:soundFXVol];
	
}
-(void) setSFXOff:(id) sender
{
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	//We make sure that we aren't setting our sound effects volume to zero forever, accidentally
	CGFloat tmp = [[SimpleAudioEngine sharedEngine] effectsVolume];
	if(tmp != 0.0f)
		soundFXVol = tmp;
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0f];
	
}
-(void) setMusicOn:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:musicVol];
}
-(void) setMusicOff:(id)sender
{
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	CGFloat tmp = [[SimpleAudioEngine sharedEngine] backgroundMusicVolume];
	if(tmp != 0.0f)
		musicVol = tmp;
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0f];
	
}

-(void) continueGame:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[(GameScene*)parent_ resumeGame];
}
-(void) returnToMenu:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[(GameScene*)parent_ returnToGameMenu];
}
@end
