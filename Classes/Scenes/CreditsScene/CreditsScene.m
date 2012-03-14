//
//  MenuScene.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreditsScene.h"
#import "MainMenuScene.h"
#import "GameScene.h"
#import "ResourceManager.h"
#import "SimpleAudioEngine.h"
#import "CloudManager.h"
#import "PhysicsManager.h"

@implementation CreditsScene
- (id) init {
    self = [super init];
    if (self != nil) {
		//_audioManager = [SimpleAudioEngine sharedEngine];
		//[_audioManager playBackgroundMusic:@"burtMainBR.mp3"];
		//NSLog(@"STARTED MUTED, GET RID OF ME BEFORE RELEASE");
		//[_audioManager setMute:YES];
		
		CCSprite * bg;
		if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		{
			CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"ipadCreditsBatch"];
			
			bg = [[ResourceManager sharedResourceManager] sprite:@"iPadCredits.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
			
		}
		else {
		
		CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"creditsMenuBatch"];
		
		bg = [[ResourceManager sharedResourceManager] sprite:@"creditsBackground.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
       
		}
		CGSize s = [[CCDirector sharedDirector] winSize];
		
        [bg setPosition:ccp(s.width/2,s.height/2)];
		// [bg setPosition:ccp(240, 160)];
		//if(![[CCDirector sharedDirector] enableRetinaDisplay:YES])
		//{
			//[bg setScale:.5f];
		//}
		
        [self addChild:bg z:0];
		
        [self addChild:[CreditsLayer node] z:1];
    }
    return self;
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

@implementation CreditsLayer
- (id) init {
    self = [super init];
    if (self != nil) {
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];

		
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
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"creditsMenuBatch"];
		//[batch.texture setAliasTexParameters];
		//[self addChild:batch];
		
		CCSprite* normSprite = [_resourceManager sprite:@"backCreditsB.png" withBatch:batch];
		CCSprite* selSprite = [_resourceManager sprite:@"backCreditsR.png" withBatch:batch];
		
	
		backButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(back:)];
		
		backButton.position = ccp(-swh -3.0f + [[backButton normalImage] contentSize].width/2, -shh -3.0f + [[backButton normalImage ]contentSize].height/2);
        CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		
		
        //[menu alignItemsVertically];
		
		
        [self addChild:menu z:5];
		
		
    }
    return self;
}

-(void) back: (id)sender 
{ 
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	//[[CCDirector sharedDirector] replaceScene:[MainMenuScene node]];
	
	[[CCDirector sharedDirector] popScene];
	
//NSLog(@"play");
}

@end