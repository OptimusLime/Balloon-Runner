//
//  MenuScene.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OptionsScene.h"
#import "GameScene.h"
#import "ResourceManager.h"
#import "SimpleAudioEngine.h"
#import "CloudManager.h"
#import "GCManager.h"
#import "PhysicsManager.h"
#import "CCRadioMenu.h"
#import "TutorialScene.h"
#import "AppEnumerations.h"
@implementation OptionsScene
- (id) init {
    self = [super init];
    if (self != nil) {
		_audioManager = [SimpleAudioEngine sharedEngine];
		[_audioManager playBackgroundMusic:@"burtMainBR.mp3"];
		//NSLog(@"STARTED MUTED, GET RID OF ME BEFORE RELEASE");
		//[_audioManager setMute:YES];
		CCSprite * bg;
		if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		{
			CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"ipadBatch"];
			
			bg = [[ResourceManager sharedResourceManager] sprite:@"iPadBackground.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
			
		}
		else {
			
		CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"optionsMenuBatch"];
		
        bg = [[ResourceManager sharedResourceManager] sprite:@"optionsBackground.png" withBatch:batch];
		//[CCSprite spriteWithFile:@"sunBack.png"];//
		}
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
        [bg setPosition:ccp(s.width/2,s.height/2)];//ccp(240, 160)];
		//if(![[CCDirector sharedDirector] enableRetinaDisplay:YES])
		//{
			//[bg setScale:.5f];
		//}
        [self addChild:bg z:0];
		
        [self addChild:[OptionsLayer node] z:1];
    }
    return self;
}


+(CGRect) genericLeftScreenRect
{
	//Generate a point left of the visible screen, i.e between (-480,0), (0,320)
	CGSize s = [[CCDirector sharedDirector] winSize];
	//CGPoint screen = ccp(480,320);
	
	return CGRectMake(-s.width, 0.0f, s.width/2, s.height);
}
+(CGRect) genericRightScreenRect
{
	//CGPoint screen = ccp(480,320);
	CGSize s = [[CCDirector sharedDirector] winSize];
	return CGRectMake(1.3*s.width, 0.0f, s.width/2,s.height);
}
+(CGRect) genericCenterScreenRect
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return CGRectMake(0.0f,s.height/4, s.width,s.height/2);
}
+(void) ShutOffMusic
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}
-(void) leavingApp
{
	//[self saveLocalCache];
	
}
-(void) returningToApp
{
	//[self loadSavedCache];
	
}

@end

@implementation OptionsLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];

		soundFXVol = DEFAULT_EFFECTS_VOLUME;
		musicVol = DEFAULT_MUSIC_VOLUME;
		
		
		
		
	  [CCMenuItemFont setFontSize:20];
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
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"optionsMenuBatch"];
		//[batch.texture setAliasTexParameters];
		//[self addChild:batch];
		CCSprite* backOptions;
		CGFloat iM = 1.0f;
		if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		{
			iM = 2.0f;
			backOptions = [_resourceManager sprite:@"iPadOptions.png" withBatch:[_resourceManager batchNodeForPath:@"ipadBatch"]];
		}
		else {
			backOptions = [_resourceManager sprite:@"optionsCloud.png" withBatch:batch];
		}

	
		backOptions.position = ccp(swh,shh);
		[self addChild:backOptions z:1];
		CCSprite* normSpriteOn = [_resourceManager sprite:@"onB.png" withBatch:batch];
		CCSprite* selSpriteOn = [_resourceManager sprite:@"onR.png" withBatch:batch];
		
		CCSprite* normSpriteOff = [_resourceManager sprite:@"offB.png" withBatch:batch];
		CCSprite* selSpriteOff = [_resourceManager sprite:@"offR.png" withBatch:batch];
		
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
		soundFXMenu.position = ccpAdd(soundFXMenu.position, ccp(iM*50.0, -iM*67.0f));
		[self addChild:soundFXMenu z:3];
		
		normSpriteOn = [_resourceManager sprite:@"onB.png" withBatch:batch];
		selSpriteOn =  [_resourceManager sprite:@"onR.png" withBatch:batch];
		
		normSpriteOff = [_resourceManager sprite:@"offB.png" withBatch:batch];
		selSpriteOff = [_resourceManager sprite:@"offR.png" withBatch:batch];
		
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
		musicMenu.position = ccpAdd(musicMenu.position, ccp(iM*50.0, -iM*7.0f));
		[self addChild:musicMenu z:3];
		
		
		CCSprite* normSprite = [_resourceManager sprite:@"backOptionsB.png" withBatch:batch];
		CCSprite* selSprite = [_resourceManager sprite:@"backOptionsR.png" withBatch:batch];
		
		
		backButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(back:)];
		
		
		normSprite = [_resourceManager sprite:@"tutB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"tutR.png" withBatch:batch];

		tutorialButton  =  [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
														   target:self selector:@selector(tutorial:)];
		
        CCMenu *menu = [CCMenu menuWithItems:backButton,tutorialButton, nil];
		//menu.position = ccp(-swh -3.0f + [[backButton normalImage] contentSize].width/2, -shh -3.0f + [[backButton normalImage ]contentSize].height/2);
		//[menu alignItemsHorizontally];
		//menu.position = ccpAdd(menu.position, ccp(-swh+ [[backButton normalImage] contentSize].width/2 , shh - [[backButton normalImage] contentSize].height/2));
        //[menu alignItemsVertically];
		backButton.position = ccp(-swh+ [[backButton normalImage] contentSize].width/2 , shh - [[backButton normalImage] contentSize].height/2);
		//- [[tutorialButton normalImage] contentSize].width/8
		tutorialButton.position = ccp(iM*40.0f,  -shh - [[tutorialButton normalImage] contentSize].height/5);// + [[tutorialButton normalImage] contentSize].height/2);
		
		
        [self addChild:menu z:5];
		
		
		
	//	playButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
//													 target:self selector:@selector(pressPlay:)];
//		
//		
//		playButton.position = ccp(-swh -30.0f + [[playButton normalImage] contentSize].width/2, -shh + [[playButton normalImage ]contentSize].height/2);
//		
//		normSprite = [_resourceManager sprite:@"creditsB.png" withBatch:batch];
//		selSprite = [_resourceManager sprite:@"creditsR.png" withBatch:batch];
//		
//		
//		creditsButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
//														target:self selector:@selector(pressCredits:)];
//		
//		creditsButton.position = ccp(-swh + 7.0f + [[creditsButton normalImage ]contentSize].width/2, -shh - 7.0f + sSize.height - [[creditsButton normalImage ] contentSize].height/2);
//		
//		normSprite = [_resourceManager sprite:@"scoresB.png" withBatch:batch];
//		selSprite = [_resourceManager sprite:@"scoresR.png" withBatch:batch];
//				
//		scoresButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
//													   target:self selector:@selector(pressScores:)];
//		
//		scoresButton.position = ccp(-swh - 15.0f + sSize.width - [[scoresButton normalImage] contentSize].width/2, -shh + 20.0f +[[scoresButton normalImage]contentSize].height/2);
//		
//		
//		normSprite = [_resourceManager sprite:@"optionsB.png" withBatch:batch];
//		selSprite = [_resourceManager sprite:@"optionsR.png" withBatch:batch];
//			
//		optionsButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
//														target:self selector:@selector(pressOptions:)];
//
//		optionsButton.position = ccp(-swh - 20.0f + sSize.width - [[optionsButton normalImage] contentSize].width/2, -shh +sSize.height - [[optionsButton normalImage ]contentSize].height/2);
//		
//        CCMenu *menu = [CCMenu menuWithItems:playButton,scoresButton,optionsButton,creditsButton, nil];
//		
//		
//        //[menu alignItemsVertically];
//		
//		
//        [self addChild:menu z:5];
//		
//		
//		normSprite = [_resourceManager sprite:@"balloonAndText.png" withBatch:batch];
//		
//		[normSprite setPosition:ccp(240, 160)];
//		
//		[self addChild:normSprite z:6];
//	
//		[self schedule:@selector(step:)];
    }
    return self;
}

-(void) tutorial:(id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[CCDirector sharedDirector] popScene];
	[[CCDirector sharedDirector] pushScene:[TutorialScene node]];
	
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
-(void) back: (id)sender 
{ 
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	//[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	//[[CCDirector sharedDirector] replaceScene:[GameScene node]];
	[[CCDirector sharedDirector] popScene];
//NSLog(@"play");
}

@end