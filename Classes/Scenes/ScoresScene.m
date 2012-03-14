//
//  ScoresScene.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoresScene.h"
#import "SimpleAudioEngine.h"
#import "RandomManager.h"
#import "ResourceManager.h"
#import "SaveLoadManager.h"
#import "PhysicsManager.h"
#import "GCManager.h"
#import "AppEnumerations.h"
#import <GameKit/GameKit.h>
#import "GCManager.h"
@implementation ScoresScene
- (id) init {
    self = [super init];
    if (self != nil) {
		
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCSprite * bg;
		if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		{
			CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"ipadBatch"];
			CCSprite* realBack = [[ResourceManager sharedResourceManager] sprite:@"iPadBackground.png" withBatch:batch];
            [realBack setPosition:ccp(s.width/2,s.height/2)];
            [self addChild:realBack z:0];
            
			bg = [[ResourceManager sharedResourceManager] sprite:@"iPadScoresCloud.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
			
		}
		else {
			CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"scoresMenuBatch"];
		bg = [[ResourceManager sharedResourceManager] sprite:@"scoresCloud.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
        }
		
		
		
		
        [bg setPosition:ccp(s.width/2,s.height/2)];
		//[bg setPosition:ccp(240, 160)];
		
        [self addChild:bg z:0];
		
        [self addChild:[ScoresLayer node] z:1];
		
		if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
		{
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"burtMainBR.mp3"];
		}
		
		
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

@implementation ScoresLayer

- (id) init {
    self = [super init];
    if (self != nil) {
       // self.isTouchEnabled =YES;
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];
		_gcManager = [GCManager sharedGCManager];
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
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"scoresMenuBatch"];
		//[batch.texture setAliasTexParameters];
		//[self addChild:batch];
		
		CCSprite* normSprite = [_resourceManager sprite:@"backScoresB.png" withBatch:batch];
		CCSprite* selSprite = [_resourceManager sprite:@"backScoresR.png" withBatch:batch];
		
		
		backButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(back:)];
		
		backButton.position = ccp(-swh, -shh - iM*12.0);
		
		
		normSprite = [_resourceManager sprite:@"resetScoresB.png" withBatch:batch];
		 selSprite = [_resourceManager sprite:@"resetScoresR.png" withBatch:batch];
		resetButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(reset:)];
		resetButton.position = ccp(swh, shh);// - [normSprite contentSize].height/4  ); //ccp(-swh + 2.2*[normSprite contentSize].width, -shh - 2.0);
		
		normSprite = [_resourceManager sprite:@"achieveB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"achieveR.png" withBatch:batch];
		achieveButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													  target:self selector:@selector(achievements:)];
		achieveButton.position = ccp(swh - [normSprite contentSize].width/2.2, -shh + [normSprite contentSize].height/8 );
		
		
		//normSprite = [_resourceManager sprite:@"friendsB.png" withBatch:batch];
		//selSprite = [_resourceManager sprite:@"friendsR.png" withBatch:batch];
		//friendsButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
		//												target:self selector:@selector(friends:)];
		//friendsButton.position = ccp(swh - [normSprite contentSize].width/2, shh - [normSprite contentSize].height/4  );
		
		
		
		normSprite = [_resourceManager sprite:@"scoresButtonB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"scoresButtonR.png" withBatch:batch];
		scoresButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
														target:self selector:@selector(scores:)];
		scoresButton.position = ccp(-swh + [normSprite contentSize].width/8 , shh);
		
		
		
        CCMenu *menu = [CCMenu menuWithItems:backButton, resetButton, achieveButton, scoresButton, nil];
		
	
        //[menu alignItemsVertically];
		id target= self;
		
        [self addChild:menu z:5];

		CGFloat fontSize = iM*28.0f;
		CGFloat addAmt = iM*30 ;
		CGFloat adjustHeight = iM*55.0f;
		SaveLoadManager* _saveLoadManager = [SaveLoadManager sharedSaveLoadManager];
		
		NSNumber* num = [_saveLoadManager loadNumber:@"gs.maxCompletedHeight"];
		
		highestScore = [CCMenuItemLabel itemWithLabel: 
						[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d feet",[num intValue]] fontName:@"allMenuFont.otf" fontSize:fontSize]
						 target:target selector:@selector(labelSelect:) ];
		highestScore.color = ccBLACK;
		highestScore.position = ccp(swh, shh + adjustHeight);
		adjustHeight -= addAmt;//20.0f;
		
		 num = [_saveLoadManager loadNumber:@"gs.averageHeight"];
		NSNumber* div =  [_saveLoadManager loadNumber:@"gs.timesPlayed"];
		
		//num = [NSNumber numberWithInt:2000000];
		if([div intValue] >0)
			averageScore = [CCMenuItemLabel itemWithLabel: 
							[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d feet",(int)([num intValue]/[div intValue])] fontName:@"allMenuFont.otf" fontSize:fontSize]
							 target:target selector:@selector(labelSelect:) ];
		else
			averageScore = [CCMenuItemLabel itemWithLabel: 
							[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d feet",0] fontName:@"allMenuFont.otf" fontSize:fontSize] 
												   target:target selector:@selector(labelSelect:) ];	
		
		averageScore.color = ccBLACK;
		averageScore.position = ccp(swh, shh + adjustHeight);
		
		
		adjustHeight -= addAmt;//20.0f;		
			
		num  = [_saveLoadManager loadNumber:@"gs.mostRecentHeight"];
	//	num = [NSNumber numberWithInt:200000000];
		mostRecentScore = [CCMenuItemLabel itemWithLabel: 
						   [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d feet",[num intValue]] fontName:@"allMenuFont.otf" fontSize:fontSize]
		  target:target selector:@selector(labelSelect:) ];
		mostRecentScore.color = ccBLACK;
		mostRecentScore.position = ccp(swh, shh + adjustHeight);
		
		adjustHeight-= addAmt;//20.0f;
		num  = [_saveLoadManager loadNumber:@"em.tempEnemyKillCount"];
		//num = [NSNumber numberWithInt:2000000];
		mostEnemiesShot = [CCMenuItemLabel itemWithLabel: 
		[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[num intValue]] fontName:@"allMenuFont.otf" fontSize:fontSize]
						     target:target selector:@selector(labelSelect:) ];
		mostEnemiesShot.color = ccBLACK;
		mostEnemiesShot.position = ccp(swh, shh + adjustHeight);
		
		adjustHeight-= addAmt;//20.0f;
		num  = [_saveLoadManager loadNumber:@"em.localTotalEnemyCount"];
		totalEnemiesShot = [CCMenuItemLabel itemWithLabel: 
							[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[num intValue]] fontName:@"allMenuFont.otf" fontSize:fontSize] 
												   target:target selector:@selector(labelSelect:) ];
		totalEnemiesShot.color = ccBLACK;
		totalEnemiesShot.position = ccp(swh, shh + adjustHeight);
		addAmt = iM*90.0f;
		menuLabels = [CCMenu menuWithItems:highestScore,averageScore,mostRecentScore,mostEnemiesShot,totalEnemiesShot,nil];
		menuLabels.position = ccp(swh+addAmt, shh-iM*5.0f - (iM-1)*7.0);
		[menuLabels alignItemsVerticallyWithPadding:iM*2.0f + (iM-1)*4.0];
		[self addChild:menuLabels z:5];
		//
//		[self addChild:highestScore z:5];
//		[self addChild:averageScore z:5];
//		[self addChild:mostRecentScore z:5];
//		[self addChild:mostEnemiesShot z:5];
//		[self addChild:totalEnemiesShot z:5];
		
		
    }
    return self;
}



-(void) labelSelect:(id) sender
{
}
-(void) back: (id)sender 
{ 
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[CCDirector sharedDirector] popScene];	
}
-(void) setLabels
{
	//CGSize sSize = [[CCDirector sharedDirector] winSize];
	//CGFloat swh = sSize.width/2;
//	CGFloat shh = sSize.height/2;
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	
	CGFloat addAmt = iM*30;
	CGFloat adjustHeight = iM*55.0f;
	SaveLoadManager* _saveLoadManager = [SaveLoadManager sharedSaveLoadManager];
	
	NSNumber* num = [_saveLoadManager loadNumber:@"gs.maxCompletedHeight"];
	//NSLog(@"Num %d", [num intValue]);
	[highestScore setString:[NSString stringWithFormat:@"%d feet",[num intValue]]];// fontName:@"allMenuFont.otf" fontSize:30.0f];
	highestScore.color = ccBLACK;
	//highestScore.position = ccp(swh, shh + adjustHeight);
	adjustHeight -= addAmt;//20.0f;
	
	num = [_saveLoadManager loadNumber:@"gs.averageHeight"];
	NSNumber* div =  [_saveLoadManager loadNumber:@"gs.timesPlayed"];
	
	
	if([div intValue] >0)
		[averageScore  setString:[NSString stringWithFormat:@"%d feet",(int)([num intValue]/[div intValue])]];// fontName:@"allMenuFont.otf" fontSize:30.0f];
	else
		[averageScore setString:[NSString stringWithFormat:@"%d feet",0]];// fontName:@"allMenuFont.otf" fontSize:30.0f];	
	
	averageScore.color = ccBLACK;
	//averageScore.position = ccp(swh, shh + adjustHeight);
	
	
	adjustHeight -= addAmt;//20.0f;		
	
	num  = [_saveLoadManager loadNumber:@"gs.mostRecentHeight"];
	[mostRecentScore setString:[NSString stringWithFormat:@"%d feet",[num intValue]]];// fontName:@"allMenuFont.otf" fontSize:30.0f];
	mostRecentScore.color = ccBLACK;
	//mostRecentScore.position = ccp(swh, shh + adjustHeight);
	
	
	adjustHeight-= addAmt;//20.0f;
	num  = [_saveLoadManager loadNumber:@"em.tempEnemyKillCount"];
	
	[mostEnemiesShot setString:[NSString stringWithFormat:@"%d",[num intValue]]];// fontName:@"allMenuFont.otf" fontSize:30.0f];
	mostEnemiesShot.color = ccBLACK;
//	mostEnemiesShot.position = ccp(swh, shh + adjustHeight);
	
	adjustHeight-= addAmt;//20.0f;
	num  = [_saveLoadManager loadNumber:@"em.localTotalEnemyCount"];
	[totalEnemiesShot setString:[NSString stringWithFormat:@"%d",[num intValue]]];//= // fontName:@"allMenuFont.otf" fontSize:30.0f];
	totalEnemiesShot.color = ccBLACK;
//	totalEnemiesShot.position = ccp(swh, shh + adjustHeight);
	
	
}
-(void) reset:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	
	
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: @"WARNING!" 
													message: [NSString stringWithFormat: @"Are you sure you want to reset your local scores?"]
												   delegate:self cancelButtonTitle: @"OK" otherButtonTitles: @"Cancel",nil] autorelease];
	[alert show];
	
		//NSLog(@"reset");
}

-(void) resetValuesAndLabels
{
//NSLog(@"WARNING: You're erasing your leaderboard and achievements");
	
	//[[GCManager sharedGCManager] resetLeaderboardsAndAchievements];
	SaveLoadManager* _saveLoadManager = [SaveLoadManager sharedSaveLoadManager];
	
	[_saveLoadManager saveValue:[NSNumber numberWithInt:0] forKey:@"em.tempEnemyKillCount"];
	[_saveLoadManager saveValue:[NSNumber numberWithInt:0] forKey:@"gs.mostRecentHeight"];
	[_saveLoadManager saveValue:[NSNumber numberWithInt:0] forKey:@"gs.timesPlayed"];
	[_saveLoadManager saveValue:[NSNumber numberWithInt:0] forKey:@"gs.averageHeight"];
	[_saveLoadManager saveValue:[NSNumber numberWithInt:0] forKey:@"gs.maxCompletedHeight"];
	[_saveLoadManager saveValue:[NSNumber numberWithInt:0] forKey:@"em.localTotalEnemyCount"];
	
	[self setLabels];
	
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		//NSLog(@"ok");
		[self resetValuesAndLabels];
	}
	else
	{
		
		//[self resetValuesAndLabels];
		//NSLog(@"cancel");
	}
}
-(void) achievements:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[GCManager sharedGCManager] showAchievements];
}


-(void) friends:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	NSMutableDictionary* achievementDict = [NSMutableDictionary dictionary];
	
	NSLog(@"CHEATING TO CHECK THE SYSTEM");
	[achievementDict setObject:[NSNumber numberWithInt:1000] forKey:[NSNumber numberWithInt:kBREnemyKillCount]];	
	[achievementDict setObject:[NSNumber numberWithFloat:10.0f] forKey:[NSNumber numberWithInt:kBRTimePlayed]];	
	[achievementDict setObject:[NSNumber numberWithInt:50000] forKey:[NSNumber numberWithInt:kBRPlayerHeight]];	
	[achievementDict setObject:[NSNumber numberWithFloat:100] forKey:[NSNumber numberWithInt:kBRTimeWithOneBalloon]];	
	[achievementDict setObject:[NSNumber numberWithFloat:1000] forKey:[NSNumber numberWithInt:kBRNumberOfShots]];	
	
	
	//	[cheatDict setObject:[NSNumber numberWithInt:1000] forKey:kBREnemyKillCount];
	//	[cheatDict setObject:[NSNumber numberWithFloat:10.0f] forKey:kBRTimePlayed];
	[[GCManager sharedGCManager] checkAndSendAchievements:achievementDict];
	
	achievementDict = [NSMutableDictionary dictionary];
	[achievementDict setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:kBREnemyKillCount]];	
	[achievementDict setObject:[NSNumber numberWithFloat:10.0f] forKey:[NSNumber numberWithInt:kBRTimePlayed]];	
	[achievementDict setObject:[NSNumber numberWithInt:50000] forKey:[NSNumber numberWithInt:kBRPlayerHeight]];	
	[achievementDict setObject:[NSNumber numberWithFloat:100] forKey:[NSNumber numberWithInt:kBRTimeWithOneBalloon]];	
	[achievementDict setObject:[NSNumber numberWithFloat:0] forKey:[NSNumber numberWithInt:kBRNumberOfShots]];	
	[achievementDict setObject:[NSNumber numberWithFloat:100] forKey:[NSNumber numberWithInt:kBRMaxNumberOfBalloons]];
	
	[[GCManager sharedGCManager] checkAndSendAchievements:achievementDict];
	
	//NSLog(@"friends");
}
-(void) scores:(id)sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	[[GCManager sharedGCManager] showLeaderboard];
	//NSLog(@"Scores");
}
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {


	if([_gcManager gameCenterOpen])
    {
    
        [[_gcManager gcView] touchesBegan:[NSSet setWithObject:touch] withEvent:event];
        
    }
	
    return NO;
}
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event
{

    if([_gcManager gameCenterOpen])
    {
        
        [[_gcManager gcView] touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
        
    }
    
}

-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event
{
    if([_gcManager gameCenterOpen])
    {
        
        [[_gcManager gcView] touchesMoved:[NSSet setWithObject:touch] withEvent:event];
        
    }

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	
    if([_gcManager gameCenterOpen])
    {
        
        [[_gcManager gcView] touchesEnded:[NSSet setWithObject:touch] withEvent:event];
        
    }

	
}



@end