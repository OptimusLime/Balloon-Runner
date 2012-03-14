//
//  MenuScene.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"
#import "ResourceManager.h"
#import "SimpleAudioEngine.h"
#import "CloudManager.h"
#import "PhysicsManager.h"
#import "CreditsScene.h"
#import "OptionsScene.h"
#import "ScoresScene.h"
#import "SaveLoadManager.h"
#import "GCManager.h"
static BOOL resetGameScene = NO;

@implementation MainMenuScene
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
			CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"mainMenuBatch"];
			
			bg = [[ResourceManager sharedResourceManager] sprite:@"sunBack.png" withBatch:batch];
		}

		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[bg setPosition:ccp(s.width/2,s.height/2)];
		//[bg setPosition:ccp(240, 160)];
		//if(![[CCDirector sharedDirector] enableRetinaDisplay:YES])
		//{
			//[bg setScale:.5f];
		//}
        [self addChild:bg z:0];
        [self addChild:[MainMenuLayer node] z:1];
    }
    return self;
}

+(void) resetGameScene
{
	resetGameScene = YES;
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
	//[(GameScene*)parent_ pauseGame];	
}
-(void) returningToApp
{
	//[self loadSavedCache];
	
}
@end

@implementation MainMenuLayer
-(void) dealloc
{
	[_physicsManager popLastSpace];
	[super dealloc];
}
- (id) init {
    self = [super init];
    if (self != nil) {
		
		CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
		//isPaused = NO;
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];

		_audioManager = [SimpleAudioEngine sharedEngine];
		cloudManager = [[CloudManager alloc] movingCloudManagerWithParent:self z:1];
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
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"mainMenuBatch"];
		//[batch.texture setAliasTexParameters];
		[self addChild:batch];
		
		CCSprite* normSprite = [_resourceManager sprite:@"playB.png" withBatch:batch];
		CCSprite* selSprite = [_resourceManager sprite:@"playR.png" withBatch:batch];
		
	
		
		playButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(pressPlay:)];
		
		
		playButton.position = ccp(-swh -iM*30.0f + [[playButton normalImage] contentSize].width/2, -shh + [[playButton normalImage ]contentSize].height/2);
		
		normSprite = [_resourceManager sprite:@"creditsB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"creditsR.png" withBatch:batch];
		
		
		creditsButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
														target:self selector:@selector(pressCredits:)];
		
		creditsButton.position = ccp(-swh + iM*3.0f + [[creditsButton normalImage ]contentSize].width/2, -shh - iM*5.0f + sSize.height - [[creditsButton normalImage ] contentSize].height/2);
		
		normSprite = [_resourceManager sprite:@"scoresB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"scoresR.png" withBatch:batch];
				
		scoresButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													   target:self selector:@selector(pressScores:)];
		
		scoresButton.position = ccp(-swh + iM*8.0f + sSize.width - [[scoresButton normalImage] contentSize].width/2, -shh + iM*23.0f +[[scoresButton normalImage]contentSize].height/2);
		
		
		normSprite = [_resourceManager sprite:@"optionsB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"optionsR.png" withBatch:batch];
			
		optionsButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
														target:self selector:@selector(pressOptions:)];

		optionsButton.position = ccp(-swh /*- iM*20.0f*/ + sSize.width - [[optionsButton normalImage] contentSize].width/2, -shh +sSize.height - [[optionsButton normalImage ]contentSize].height/2);
		
        CCMenu *menu = [CCMenu menuWithItems:playButton,scoresButton,optionsButton,creditsButton, nil];
		
		
        //[menu alignItemsVertically];
		
		
        [self addChild:menu z:5];
		
		
		normSprite = [_resourceManager sprite:@"balloonAndText.png" withBatch:batch];
		
		
		[normSprite setPosition:ccp(sSize.width/2, sSize.height/2)];//ccp(240, 160)];
		
		[self addChild:normSprite z:6];
	
		[self schedule:@selector(step:)];
		
		
		
		
    }
    return self;
}
//-(void) draw
//{
//	///if(!resetGameScene)
//		[super draw];
//}
-(void) step:(ccTime) delta
{
	////if(resetGameScene)
	//{
	//	[[CCDirector sharedDirector] pushScene:[GameScene node]];
	//	resetGameScene = NO;
	//	return;
	//}
	
	if(![_audioManager isBackgroundMusicPlaying])
		[_audioManager playBackgroundMusic:@"burtMainBR.mp3"];
	
	[_physicsManager updatePhysics:delta withCallback:nil];
	[cloudManager step:delta];
}
-(void)startGame: (id)sender {
   // NSLog(@"start game");
	
	[[CCDirector sharedDirector] pushScene:[GameScene node]];
	
	
	
	
	
	
}
-(void)help: (id)sender {
   // NSLog(@"help");
}
-(void) pressPlay: (id)sender 
{ 
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
//	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[CCDirector sharedDirector] pushScene:[GameScene node]];
	
	if([[SaveLoadManager sharedSaveLoadManager] firstLaunch])
	{
		//This is no longer the first launch
		[[GCManager sharedGCManager] zeroOutAllSaveValues];
	}
//NSLog(@"play");
}
-(void) pressOptions: (id)sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	//NSLog(@"options");
	[[CCDirector sharedDirector] pushScene:[OptionsScene node]];
	
}
-(void) pressCredits: (id)sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
		[[CCDirector sharedDirector] pushScene:[CreditsScene node]];
}
-(void) pressScores: (id)sender 
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[CCDirector sharedDirector] pushScene:[ScoresScene node]];
}
@end