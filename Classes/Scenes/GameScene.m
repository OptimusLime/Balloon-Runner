//
//  GameScene.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MainMenuScene.h"
#import "CCTouchDispatcher.h"
#import "cocos2d.h"
#import "ResourceManager.h"
#import "TextButton.h"
#import "PlayerBasket.h"
#import "PhysicsManager.h"
#import "SpaceManagerCocos2d.h"
#import "CloudManager.h"
#import "EnemyManager.h"
#import "PauseMenu.h"
#import "GameOverMenu.h"
#import "GuiMenu.h"
#import "MainMenuScene.h"
#import "ScoresScene.h"
#import "SimpleAudioEngine.h"
#import "AppEnumerations.h"
#import "PauseMenu.h"
#import "GCManager.h"
#import "SaveLoadManager.h"
#define ARC4RANDOM_MAX 0x100000000

enum {
	kTagBatchNode = 1,
	kTagBatchBackNode,
};
static CGPoint scrollSpeed = {.3,.3};
static CGFloat scrollPercent = .4f;
static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.		
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}
enum  {
	kBRGameLayer,
	kBRGUILayer,
	kBRPauseLayer,
	kBRGameOverLayer
};
@implementation GameScene
- (id) init {
    self = [super init];
    if (self != nil) {
		CCSprite * bg ;
		
		if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		{
			CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"ipadBatch"];
			
			bg = [[ResourceManager sharedResourceManager] sprite:@"gameBackground.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
			
		}
		else {
		
		CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"backCloudBatch"];
        bg = [CCSprite spriteWithBatchNode:batch 
												 rect:[[ResourceManager sharedResourceManager] getSpritePositionWithBatch:batch 
		
																												imageName:@"croppedBackground.png" ]];
		}
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[bg setPosition:ccp(s.width/2,s.height/2)];
		
		//[bg.texture setAliasTexParameters];
       // [[bg setPosition:];//ccp(240, 160)];
        [self addChild:bg z:0];
		
		GUILayer* guiLayer = [GUILayer node]; 
		GameLayer* gameLayer = [GameLayer node];
		[guiLayer setPlayer:[gameLayer player] withParent:gameLayer];
		
		
        [self addChild:gameLayer z:0 tag:kBRGameLayer];
		[self addChild:guiLayer z:0 tag:kBRGUILayer];
		_audioManager = [SimpleAudioEngine sharedEngine];
		
		//[_audioManager setBackgroundMusicVolume:.6f];
		[_audioManager playBackgroundMusic:@"burtBR.mp3"];
	//	[_audioManager setMute:YES];
    }
    return self;
}
-(void) pauseGame
{
	//isPaused = YES;
	//[self unschedule:@selector(step:)];
	//[_audioManager pauseBackgroundMusic];
	
	if(![self getChildByTag:kBRPauseLayer])
	[self addChild:[PauseMenu node] z:0 tag:kBRPauseLayer];
	
	[(GameLayer*)[self getChildByTag:kBRGameLayer] pauseGame];
	[(GUILayer*)[self getChildByTag:kBRGUILayer] pauseGame];
	
	
}
-(void) justPauseTimers
{
	[(GameLayer*)[self getChildByTag:kBRGameLayer] pauseGame];
	[(GUILayer*)[self getChildByTag:kBRGUILayer] pauseGame];
}
-(void) justResumeTimers
{
	[(GameLayer*)[self getChildByTag:kBRGameLayer] resumeGame];
	[(GUILayer*)[self getChildByTag:kBRGUILayer] resumeGame];
	
	
}
-(void) resumeGame
{
	//isPaused = NO;
	//[self schedule:@selector(step:)];
	
	//[_audioManager resumeBackgroundMusic];
	[(GameLayer*)[self getChildByTag:kBRGameLayer] resumeGame];
	[(GUILayer*)[self getChildByTag:kBRGUILayer] resumeGame];
	//PauseMenu* pMenu = [self getChildByTag:kBRPauseLayer];
	//[self removeChild:pMenu cleanup:YES];
	
	
	[self removeChildByTag:kBRPauseLayer cleanup:YES];
}
-(void) resetGame
{
	[(GUILayer*)[self getChildByTag:kBRGUILayer] resetGame];
	[(GameLayer*)[self getChildByTag:kBRGameLayer] resetGame];
	[self justResumeTimers];
	
	[self removeChildByTag:kBRGameOverLayer cleanup:YES];
}
-(void) gameOver
{
	[(GUILayer*)[self getChildByTag:kBRGUILayer] gameOver];
	[(GameLayer*)[self getChildByTag:kBRGameLayer] gameOver];
	[self addChild:[GameOverMenu node] z:0 tag:kBRGameOverLayer];
	
}
-(void) exitScene
{
	[(GUILayer*)[self getChildByTag:kBRGUILayer] exitScene];
	[(GameLayer*)[self getChildByTag:kBRGameLayer] exitScene];
}
-(CGFloat) gameScore
{
	return 	[(GameLayer*)[self getChildByTag:kBRGameLayer] gameScore];
}
-(void) returnToGameMenu
{
	[(GameLayer*)[self getChildByTag:kBRGameLayer] quitGame];
}
-(void) leavingApp
{
	[(GameLayer*)[self getChildByTag:kBRGameLayer] leavingApp];
	//[self saveLocalCache];
}
-(void) returningToApp
{
	//[self loadSavedCache];
	}

@end
@implementation GUILayer
static CGFloat startLeftHeight = -1;
static CGFloat startLeftSpeed = -1;
-(id) init
{
	if( (self = [super init]))
	{
		self.isTouchEnabled = YES;
		
		CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
		
		_resourceManager = [ResourceManager sharedResourceManager];
		
		CGSize s = [[CCDirector sharedDirector]winSize];
		CCLabelTTF* staticSpeed = [CCLabelTTF labelWithString:@"Speed:" fontName:@"allMenuFont.otf" fontSize:iM*20.0f];
		staticSpeed.position = ccp(iM*35, s.height -iM*15);
		staticSpeed.color = ccBLACK;
		speedLabel = [CCLabelTTF labelWithString:@"0" fontName:@"allMenuFont.otf" fontSize:iM*20.0f];
		speedLabel.position = ccp(iM*25 + [staticSpeed contentSize].width, s.height - iM*15);
		speedLabel.color = ccBLACK;
		startLeftSpeed = speedLabel.position.x - [speedLabel contentSize].width/2;
		[self addChild:staticSpeed z:5];
		[self addChild:speedLabel z:5];
	//	CCLabelTTF* staticHeight = [CCLabelTTF labelWithString:@"Feet:" fontName:@"allMenuFont.otf" fontSize:iM*20.0f];
	//	staticHeight.position = ccp(s.width-iM*110, s.height - iM*15);
	//	staticHeight.color = ccBLACK;
		[speedLabel setVisible:NO];
		[staticSpeed setVisible:NO];
		heightLabel = [CCLabelTTF labelWithString:@"Feet: 0" fontName:@"allMenuFont.otf" fontSize:iM*20.0f];
		heightLabel.position = ccp(s.width - [heightLabel contentSize].width - iM*5.0f /* -iM*130 + [staticHeight contentSize].width*/, s.height - iM*15);
		heightLabel.color = ccBLACK;
		[heightLabel setAnchorPoint:ccp(0,.5f)];
		
		//feetLabel = [CCLabelTTF labelWithString:@"feet" fontName:@"allMenuFont.otf" fontSize:iM*20.0f];
		//feetLabel.color = ccBLACK;
		//feetLabel.position = ccp(heightLabel.position.x + [heightLabel contentSize].width + iM*23.0f, heightLabel.position.y);
		feetMove = iM*(int)log10f(10);
		startLeftHeight = heightLabel.position.x - [heightLabel contentSize].width/2;
		
		//[self addChild:feetLabel];
		//[self addChild:staticHeight z:5];
		[self addChild:heightLabel z:5];
		
		CGFloat swh = s.width/2;
		CGFloat shh = s.height/2;
		
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"pauseMenuBatch"];
		 
		CCSprite* pSrprite =[_resourceManager sprite:@"pauseButton.png" withBatch:batch];
		CCSprite* selpSprite = [_resourceManager sprite:@"pauseButton.png" withBatch:batch];
		CCSprite* psSprite = [_resourceManager sprite:@"playButton.png" withBatch:batch];
		CCSprite* selpsSprite = [_resourceManager sprite:@"playButton.png" withBatch:batch];

		playButton = [CCMenuItemSprite itemFromNormalSprite:psSprite selectedSprite:selpsSprite];
		pauseButton = [CCMenuItemSprite itemFromNormalSprite:pSrprite selectedSprite:selpSprite];
		
		
		
		playPauseToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(pausePlayButtonPressed:) items:pauseButton,playButton,nil];
		
		playPauseToggle.position = ccp( .75f*[pSrprite contentSize].width,.5f*[pSrprite contentSize].height);//ccp(-swh + [pSrprite contentSize].width/2, -shh + [pSrprite contentSize].height/2);
		
		playPauseMenu = [CCMenu menuWithItems:playPauseToggle, nil];
		
		[self addChild:playPauseMenu z:5];
		
		playPauseMenu.position = ccpAdd(playPauseMenu.position,ccp(-swh,-shh));
		
		[self schedule:@selector(step:)];
		
		
		//	
//		cameraButton = [CCMenuItemSprite itemFromNormalSprite:hSprite selectedSprite:hInvSprite];
//		//cameraButton.position = ccp(sSize.height/2, sSize.width/2);
//		
//		[[cameraButton selectedImage] setPosition:ccpAdd(cameraButton.selectedImage.position, ccp(-sSize.height/2 + [hSprite contentSize].width/2, -sSize.width/2 + [hSprite contentSize].height/2))];
//		
//		bBatch = [_resourceManager batchNodeForPath:@"buttonAssets"];
//		
//		hSprite = [CCSprite spriteWithBatchNode:bBatch rect:
//				   [_resourceManager getSpritePositionWithBatch:bBatch 
//													  imageName:@"help-01.png"]];
//		
//		hInvSprite = [CCSprite spriteWithBatchNode:bBatch rect:
//					  [_resourceManager getSpritePositionWithBatch:bBatch 
//														 imageName:@"help-01.png"]];
//		
//		[hSprite setScale:.55f];
//		[hInvSprite setScale:.55f];
//		[hInvSprite setColor:ccc3(190, 190, 190)];
//		
//		lifeSaverButton = [CCMenuItemSprite itemFromNormalSprite:hSprite selectedSprite:hInvSprite
//														  target:self selector:@selector(lifeSaverSelected)];
//		
//		CGSize rSize = [hInvSprite contentSize];
//		
//		lifeSaverButton.position =  ccp(-sSize.height/2 +rSize.width/2 , -sSize.width/2 + rSize.height/2);
//		_gameMenu = [GuiMenu menuWithItems:lifeSaverButton,cameraButton, nil];
//		
//		
//		[self addChild:_gameMenu z:10];
	}
	return self;
}
-(void)pausePlayButtonPressed:(id)sender {  
					
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
	CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
	if (toggleItem.selectedItem == playButton) {
		if(isPaused)
		{
			
			return;
		}
		
		//The button being pressed is the play button, i.e. we just clicked the pause button
		//This should stop the physics being updated, but all of the balloons and the player are still being triggered
		[(GameScene*)parent_ pauseGame];
		//NSLog(@"Play");
		//[_label setString:@"Visible button: +"];    ccmen
		
	} else if (toggleItem.selectedItem == pauseButton) {
	
		if(!isPaused)
			return;
		//The button clicked is the pause button, i.e. we just pressed the play button
		[(GameScene*)parent_ resumeGame];
		//NSLog(@"PAUSE!");
		
		//[_label setString:@"Visible button: -"];
		
	}  
	
}
-(void) pauseGame
{
	isPaused = YES;
	if (playPauseToggle.selectedItem != playButton)
	{
		[playPauseToggle setSelectedIndex:1];
	}
	[self unschedule:@selector(step:)];
	
	//Now pop up the pause menu
	
	
}
-(void) resumeGame
{
	
	isPaused = NO;
	if (playPauseToggle.selectedItem != pauseButton)
	{
		[playPauseToggle setSelectedIndex:0];
	}
	
	
	[self schedule:@selector(step:)];
	//Now hide the pause menu
	
	
	
}
-(void) exitScene
{
	//Any clean-up needed?
	
}
-(void) gameOver
{
	[playPauseMenu setIsTouchEnabled:NO];
	[self setHeightLabel:0];
	//Maybe set some stats?
	isGameOver = YES;
	//numberOfTimesPlayed++;
}
-(void) resetGame
{
	isGameOver = NO;
	[playPauseMenu setIsTouchEnabled:YES];
	lastBasketPoint = pBasket.position;
}
-(void) setPlayer:(id) playerBasket withParent:(id) parentBasket
{
	lastBasketPoint = [(CCNode*)playerBasket position];
	pBasket = playerBasket;
	pParent = parentBasket; 
}
-(void) step:(ccTime)delta
{
	[self updateLabels:delta];
	lastBasketPoint = pBasket.position;
}
-(void) updateLabels:(ccTime) delta 
{
	[self setHeightLabel:delta];
	//[self setSpeedLabel:delta];
}
-(void) setHeightLabel:(ccTime) delta 
{

    CGSize s = [[CCDirector sharedDirector] winSize];
	CGFloat height = [PlayerBasket gameScore];
	[heightLabel setString:[NSString stringWithFormat:@"Feet: %1.0f",height]];
    CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	heightLabel.position = ccp(MIN([heightLabel position].x , s.width - [heightLabel contentSize].width - iM*5.0f), heightLabel.position.y) ;
    
	//CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
//	if( iM*((int)log10f(height)) > feetMove)
	//{
		
	//	feetLabel.position = ccpAdd(feetLabel.position, ccp(iM*8.5f, 0));
	//	feetMove = iM*(int)log10f(height);
	//}
	
}
-(void) setSpeedLabel:(ccTime) delta 
{

	//speed = distance over time
	CGPoint bMove=  ccpSub(pBasket.position, lastBasketPoint);
	CGFloat  speed= cpvlength(bMove)/delta;
	[speedLabel setString:[NSString stringWithFormat:@"%1.0f",speed]];
	speedLabel.position =  ccp(startLeftSpeed + [speedLabel contentSize].width/2, speedLabel.position.y);
	
	
	
}
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}
-(void) lifeSaverSelected
{
	
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	//return [_gameMenu ccTouchBegan:touch withEvent:event];
	

	//For now, return no, so that the other layer can get the touches
    return NO;
}
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event
{
	//[_gameMenu ccTouchCancelled:touch withEvent:event];
}

-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event
{
	//[_gameMenu ccTouchMoved:touch withEvent:event];
	
	
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	
	//[_gameMenu ccTouchEnded:touch withEvent:event];
	
	
	
}


@end


#define kGSMaxHeight @"gs.maxHeight"
#define kGSMaxCompletedHeight @"gs.maxCompletedHeight"
#define kGSAverageHeight @"gs.averageHeight"
#define kGSTimesPlayed @"gs.timesPlayed"
#define kGSMostRecentHeight @"gs.mostRecentHeight"

static CGFloat CHECK_ACHIEVE_TIME = .5f;

@implementation GameLayer
-(void) dealloc
{
	[cloudManager release];
	[enemyManager release];
	//[playerBasket release];
	[super dealloc];	
}
- (id) init {
    self = [super init];
    if (self != nil) {
		isPaused = NO;

		//ignore above test
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];
		_saveLoadManager = [SaveLoadManager sharedSaveLoadManager];
		[_physicsManager createNewSpace];
		//CGSize wins = [[CCDirector sharedDirector] winSize];
		//cpInitChipmunk();
		achieveCheck  = 0;
		
		//cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = [_physicsManager space];//cpSpaceNew();
		//	cpSpaceResizeStaticHash(space, 400.0f, 40);
		//	cpSpaceResizeActiveHash(space, 100, 600);
		
		//	space->gravity = ccp(0, 0);
		//	space->elasticIterations = space->iterations;
		
		//cpShape *shape;
		
		// bottom
		//shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(wins.width,0), 0.0f);
		//shape->e = 1.0f; shape->u = 1.0f;
		//cpSpaceAddStaticShape(space, shape);
		
		
		// top
		//shape = cpSegmentShapeNew(staticBody, ccp(0,wins.height), ccp(wins.width,wins.height), 0.0f);
		//shape->e = 1.0f; shape->u = 1.0f;
		//cpSpaceAddStaticShape(space, shape);
		
		// left
		//shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
		//shape->e = 1.0f; shape->u = 1.0f;
		//cpSpaceAddStaticShape(space, shape);
		
		// right
		//shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
		//shape->e = 1.0f; shape->u = 1.0f;
		//cpSpaceAddStaticShape(space, shape);
		
		CCSpriteBatchNode *batch = [_resourceManager batchNodeForPath:@"balloonBatch"];//[CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:100];
		
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		desiredPlayerPoint = ccp(s.width*.5, s.height*.15);
		
		//desiredPlayerPoint = ccp(240,50);
		
		playerBasket = [PlayerBasket standardPlayerBasket:desiredPlayerPoint withParent:self];
		
		[self resetTimer];
		[self startTimer];
		
		lastBasketPoint = playerBasket.position;//[playerBasket convertToWorldSpace:playerBasket.position];
		
	//NSLog(@"TESTING NO BALLLOONS");
		
		
		[self createBalloonBunch];
		
		[self schedule: @selector(step:)];	
		
		cloudManager = [[CloudManager alloc] cloudManagerWithParent:self andPlayer:playerBasket];
		enemyManager = [[EnemyManager alloc] enemyManagerWithParent:self andPlayer:playerBasket];
		
		
		[self loadState];
		
		
		//id cameraMove = [CCFollow actionWithTarget:playerBasket];
		//[self runAction:cameraMove];
		
    }
    return self;
}
-(void) createBalloonBunch
{	
	
	CGSize bSize = [_resourceManager spriteContentSize:@"blue3.png" fromPath:@"balloonBatch"];
	
	//TEMPORARY:
//	int i =0,j=0,  div=4;
//	[self addNewSpriteX: desiredPlayerPoint.x  + bSize.width*1.5*(2*(i%2)-1) y:desiredPlayerPoint.y +[playerBasket balloonMax]+ bSize.height/2*(j%div)];
//	return;
	
	
	
	int startBalloon = 10;
	int div = 3;
	for(int i=0; i < startBalloon/div; i++)
	{
		for(int j=0; j < startBalloon/div; j++)
		{
			[self addNewSpriteX: desiredPlayerPoint.x - bSize.width/2  + bSize.width*(i%2) y:desiredPlayerPoint.y +[playerBasket balloonMax]+ bSize.height/2*(j%div)];
			
			if(j%div != 0 && j%div != div-1)
			{
				[self addNewSpriteX: desiredPlayerPoint.x  + bSize.width*1.5*(2*(i%2)-1) y:desiredPlayerPoint.y + .75*[playerBasket balloonMax]+ bSize.height/2*(j%div)];
			}
			
		}
	}
}
-(void) pauseGame
{
	isPaused = YES;
	[self unschedule:@selector(step:)];
	[playerBasket pauseGame];
	[cloudManager pauseGame];
	[enemyManager pauseGame];
	[self pauseTimer];
}
-(void) resumeGame
{
	isPaused = NO;
	[self schedule:@selector(step:)];
	[cloudManager resumeGame];
	[enemyManager resumeGame];
	[playerBasket resumeGame];
	[self startTimer];
	
}
-(void) saveState
{
	NSMutableDictionary* saveDictionary = [NSMutableDictionary dictionary];
	[self addSaveStateValues:saveDictionary];
	[cloudManager addSaveStateValues:saveDictionary];
	[enemyManager addSaveStateValues:saveDictionary];
	[playerBasket addSaveStateValues:saveDictionary];	
	[_saveLoadManager saveStateObjects:saveDictionary];
	[[NSUserDefaults standardUserDefaults]synchronize];
	//int saveChk = [[_saveLoadManager loadNumber:@"pb.balloonCount"] intValue];
	//NSLog(@"saveChk %d",saveChk);
	
}
-(void) loadState
{
	//If this is the first time we are launch, nothing could have been saved
	if([_saveLoadManager firstLaunch])
	{
		//Start up the game normally
		//[self createBalloonBunch];
	}
	else {
		[self loadFromSaveStateValues:[_saveLoadManager loadNumbers:[self loadStateKeys]]];
	}
	
	//[_saveLoadManager loadNumber:
	
}
-(void) addSaveStateValues:(NSMutableDictionary*) saveDict
{
	
	[saveDict setObject:[NSNumber numberWithInt:numberOfTimesPlayed] forKey:kGSTimesPlayed];
	[saveDict setObject:[NSNumber numberWithFloat:maxHeight] forKey:kGSMaxHeight];
	[saveDict setObject:[NSNumber numberWithFloat:averageHeight] forKey:kGSAverageHeight];
	[saveDict setObject:[NSNumber numberWithFloat:mostRecentHeight] forKey:kGSMostRecentHeight];
	[saveDict setObject:[NSNumber numberWithFloat:maxCompletedHeight] forKey:kGSMaxCompletedHeight];
}

-(NSMutableArray*) saveStateKeys
{
	NSMutableArray* array = [NSMutableArray array];
	[array addObject:kGSMaxHeight];
	[array addObject:kGSAverageHeight];
	[array addObject:kGSTimesPlayed];
	[array addObject:kGSMostRecentHeight];
	[array addObject:kGSMaxCompletedHeight];
	return array;
	
	
}
-(void) loadFromSaveStateValues:(NSMutableDictionary*) dict
{
	[self loadFromDict:dict];
	[cloudManager loadFromSaveStateValues: dict];
	[enemyManager loadFromSaveStateValues: dict];
	[playerBasket loadFromSaveStateValues: dict];
	
}

-(void) loadFromDict:(NSMutableDictionary*)loadDict
{
	maxHeight = [[loadDict objectForKey:kGSMaxHeight] floatValue];
	averageHeight = [[loadDict objectForKey:kGSAverageHeight]floatValue];
	numberOfTimesPlayed = [[loadDict objectForKey:kGSTimesPlayed] intValue];
	mostRecentHeight = [[loadDict objectForKey:kGSMostRecentHeight]floatValue];
	maxCompletedHeight = MAX(maxCompletedHeight, [[loadDict objectForKey:kGSMaxCompletedHeight]floatValue]);
}
-(NSMutableArray*) loadStateKeys
{
	NSMutableArray* array = [NSMutableArray array];
	
	[array addObjectsFromArray: [self saveStateKeys]];
	[array addObjectsFromArray: [cloudManager saveStateKeys]];
	[array addObjectsFromArray: [enemyManager saveStateKeys]];
	[array addObjectsFromArray: [playerBasket saveStateKeys]];
	return array; 
	
}

-(void) leavingApp
{
	//[self saveLocalCache];
	
	[self saveState];
	
	if(!isGameOver)
		[(GameScene*)parent_ pauseGame];
	
	
}
-(void) returningToApp
{
	//[self loadSavedCache];
	
	//[self loadState];
}

-(void) resetGame
{
	
	isGameOver = NO;

	//[self exitScene];
	//[MainMenuScene resetGameScene];
	
	[self cleanUpPhysics];
	
//	[_physicsManager popLastSpace];
	
	//[cloudManager release];
//	[enemyManager release];
//	[playerBasket release];
//	
//	[_physicsManager createNewSpace];
	//space = [_physicsManager space];
//	
//	
//	playerBasket = [PlayerBasket standardPlayerBasket:desiredPlayerPoint withParent:self];
//	
//	
//	lastBasketPoint = playerBasket.position;//[playerBasket convertToWorldSpace:playerBasket.position];
//	//[self createBalloonBunch];
//	
//	[self schedule: @selector(step:)];	
//	cloudManager = [[CloudManager alloc] cloudManagerWithParent:self andPlayer:playerBasket];
//	enemyManager = [[EnemyManager alloc] enemyManagerWithParent:self andPlayer:playerBasket];
	
	[enemyManager resetGame];
	[playerBasket resetGame];
	[cloudManager resetGame];
	//reset the player position
	//playerBasket.position= desiredPlayerPoint;
	//now add the initial balloon bunch
	[self createBalloonBunch];
	[self resetTimer];
	[self startTimer];
}
-(CGFloat) gameScore
{
	return 	[PlayerBasket gameScore];//[playerBasket gameHeight];
}
-(PlayerBasket*) player
{
	return playerBasket;
}

-(void) addNewSpriteX: (float)x y:(float)y
{
	[playerBasket addAnyColorBalloon:ccp(x,y)];//ccp(x,y)];
}
-(void) addFloatingBalloonX: (float)x y:(float)y
{
	[playerBasket floatAnyBalloonAt:ccp(x,y)];//ccp(x,y)];
}
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
//Quit != game over. Quit means return to menu occurred
-(void) quitGame
{
	[self saveState];
	[self exitScene];
}
//Game over is that you lost, and your score came up (or was registered)
-(void) gameOver
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"gameOverPops.mp3"];
	isGameOver = YES;
	//We save all our achievement variables, and positions
	
	numberOfTimesPlayed++;
	averageHeight += [PlayerBasket gameScore];
	mostRecentHeight =[PlayerBasket gameScore];
	maxCompletedHeight = MAX(maxCompletedHeight,[PlayerBasket gameScore]);
	//NSLog(@"averageHeight %f", averageHeight);
	
	[self saveState];
	[self pauseTimer];
	
	[[GCManager sharedGCManager] submitScore:(int)[PlayerBasket gameScore]];
	//This will remove all items from the physics space
	//[self cleanUpPhysics];
	//[_physicsManager popLastSpace];
	
	[(GameScene*)parent_ justPauseTimers];
	//[(GameScene*)parent_ pauseGame];
	//[self unschedule:@selector(step:)];
	//[self exitScene];
	//[[CCDirector sharedDirector] replaceScene:[MainMenuScene node]]; 
	return;
}
-(void) balloonsGone
{
	[(GameScene*)parent_ gameOver];
}
-(void) resetTimer
{
	timePlayed = 0;
}
-(void) startTimer
{
	isTiming = YES;
}
-(void) pauseTimer
{
	isTiming = NO;
}
-(void) updateAchievementVariables:(ccTime) delta
{
	//I own time played, update it
	if(isTiming)
		timePlayed += delta;
	
	
	//Here we're seeing if we want to check and submit these achievements to game center
	//We do this every (CHECK_ACHIEVE_TIME) amount of time, default: .5
	achieveCheck += delta;
	if(achieveCheck > CHECK_ACHIEVE_TIME)
	{
		//Every step, we check for achievements, in the future we can be more efficient about this
		//We could probably check every half second
		[[GCManager sharedGCManager] checkAndSendAchievements:[self getAchievementVariables]];
		achieveCheck = 0;
		
	}
}
-(void) addAchievementVariables:(NSMutableDictionary *)achieveDict
{
	//NSLog(@"TimePlayed %.2f", timePlayed);
	//NSLog(@"Add some things to the achieve dict");
	[achieveDict setObject:[NSNumber numberWithFloat:timePlayed] forKey:[NSNumber numberWithInt:kBRTimePlayed]];
	
}

-(NSMutableDictionary*) getAchievementVariables
{
	NSMutableDictionary* achieveDict = [NSMutableDictionary dictionary];
	[self addAchievementVariables:achieveDict];
	[enemyManager addAchievementVariables:achieveDict];
	[playerBasket addAchievementVariables:achieveDict];
	
	return achieveDict;
	
}
-(void) cleanUpPhysics
{
	[enemyManager cleanUpPhysics];
	[playerBasket cleanUpPhysics];
	[cloudManager cleanUpPhysics];
}
-(void) exitScene
{
	[self cleanUpPhysics];
		[_physicsManager popLastSpace];
	
	//Exit scene
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[CCDirector sharedDirector] popScene];
	
	
}
-(void) step: (ccTime) delta
{
	//ccTime cpy = delta;
	
	if([playerBasket balloonCount] == 0)
	{
		[self balloonsGone];
		return;
	}
	[_physicsManager updatePhysics:delta withCallback:&eachShape];
	[cloudManager step:delta];
	[enemyManager step:delta];
	
	CGPoint correctPos = ccpSub( desiredPlayerPoint, playerBasket.position );
	CGPoint dif = ccpSub(correctPos,self.position);
	
	CGPoint scrollAmount = ccp(MAX(-scrollSpeed.x,  MIN(scrollSpeed.x, dif.x)), MAX(-scrollSpeed.y, MIN(scrollSpeed.y, dif.y)));

	dif = ccpSub(dif, scrollAmount);
	scrollAmount = ccpAdd(scrollAmount, ccpMult(dif, scrollPercent));
	
	[self setPosition:correctPos];//ccpAdd(self.position, scrollAmount)];
	
	//[self updateLabels:delta];
	
	lastBasketPoint = playerBasket.position;
	
	[self updateAchievementVariables:delta];
	
	
	//CGPoint chk = [self convertToNodeSpace:playerBasket.position];
//	CGPoint pos = playerBasket.position;
//	CGPoint afterPoint = pos;//[self convertToNodeSpace:[playerBasket convertToWorldSpace:playerBasket.position]];
//	
//	CGPoint dif = ccpSub(desiredPlayerPoint, afterPoint);//ccpAdd(moveOverflow, ccpSub(lastBasketPoint,afterPoint));
//	
//	moveOverflow = ccpAdd(moveOverflow, dif);
//	CGPoint scrollAmount = ccp(MAX(-scrollSpeed.x,  MIN(scrollSpeed.x, moveOverflow.x)), MAX(-scrollSpeed.y, MIN(scrollSpeed.y, moveOverflow.y)));
//	
//	
//	self.position = ccpSub(self.position, scrollAmount);
//	
//	moveOverflow = ccpSub(moveOverflow, scrollAmount);
//	//CGPoint fDif = ccp(floorf(fabs(dif.x)),floorf(fabs(dif.y)));
//	
//	//fDif.x *= (dif.x >= 0) ? 1.0 : -1.0f ;
//	//fDif.y *= (dif.y >= 0) ? 1.0 : -1.0f ;
//	
//	//moveOverflow = ccpAdd(moveOverflow, ccpSub(dif, fDif));
//	
//	//moveOverflow = ccpSub(moveOverflow, fDif);
//	
//	NSLog(@"Dif %f, %f", chk.x,chk.y);
		
	//self.position = ccpAdd(self.position, ccpSub(lastBasketPoint,afterPoint));//fDif);
	
	//moveOverflow = ccpSub(moveOverflow, fDif);
	
	//lastBasketPoint = afterPoint;
	
}
//-(void) setPosition:(CGPoint) newPos
//{
//	position_ = newPos;
//}

-(void) onEnter
{
	[super onEnter];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	if(isPaused)
		return;
	
	static float prevX=0, prevY=0, prevZ = 0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	float accelZ = (float) acceleration.z * kFilterFactor + (1- kFilterFactor)*prevY;
	prevX = accelX;
	prevY = accelY;
	prevZ = accelZ;
	
	
	
//	if([[CCDirector sharedDirector] deviceOrientation] == kCCDeviceOrientationLandscapeRight)
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft)
	{
		accelY *= -1.0f;
		accelX *= -1.0f;
	}
	//NSLog(@"A x:%.2f, y:%.2f, z:%.2f", accelY, accelX + .5f, accelZ);
	
	[playerBasket setAcceleration:ccp(accelY,accelX + .5f)];
	
	//CGPoint v = ccp( accelX, accelY);
	
	//space->gravity = ccpMult(v, 200);
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	//[steveButton ccTouchBegan:touch withEvent:event];
//	[fileButton ccTouchBegan:touch withEvent:event];

	if(isPaused)
		return NO;
	
	
	
	CGPoint location = [touch locationInView: [touch view]];
	//NSLog(@"TL (%f,%f)", location.x, location.y);
	
	//location = [[CCDirector sharedDirector] convertToGL: location];	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	location.y  = s.height - location.y;
	
	location = ccpSub(location, position_);
	//[self addNewSpriteX: location.x y:location.y];

	//FIRE!
	[playerBasket attemptFireAt:location];
	
	
	
    return YES;
}
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event
{
	if(isPaused)
		return;
	//[steveButton ccTouchCancelled:touch withEvent:event];
//	[fileButton ccTouchCancelled:touch withEvent:event];
}

-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event
{
	if(isPaused)
		return;
	//[steveButton ccTouchMoved:touch withEvent:event];
//	[fileButton ccTouchMoved:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	
	if(isPaused)
		return;
	//[steveButton ccTouchEnded:touch withEvent:event];
//	[fileButton ccTouchEnded:touch withEvent:event];
	
	//for( UITouch *touch in touches ) {
//	CGPoint location = [touch locationInView: [touch view]];
//	//NSLog(@"TL (%f,%f)", location.x, location.y);
//	
//	
//	
//	
//	
//	
//	//location = [[CCDirector sharedDirector] convertToGL: location];	
//	CGSize s = [[CCDirector sharedDirector] winSize];
//	
//	
//	
//	location.y  = s.height - location.y;
//	
//	location = ccpSub(location, position_);
//	//[self addNewSpriteX: location.x y:location.y];
//	
//	
//	//FIRE!
//	[playerBasket attemptFireAt:location];
	//Add balloon!
	//[self addFloatingBalloonX:location.x y:location.y];
	
	//[[CCDirector sharedDirector] convertToGL: location];
	//location = ccpSub(location, self.position);
		//s.height - 
	//location.y = s.height - location.y;
	//CGPoint correctPos = ccpSub( desiredPlayerPoint, playerBasket.position );
	//CGPoint dif = ccpSub(correctPos,self.position);
	//location = ccpAdd(location, dif);
	
	
	//Screen location = world space location - layer position
	//original = location - position_;
	
	//NSLog(@"LocT (%f,%f)", location.x,location.y);//, pos: (%f,%f) dif:(%f,%f)", location.x, location.y);//, position_.x, position_.y, fabs(location.x- position_.x), fabs(location.y - position_.y));
	//CGPoint con = [self convertToNodeSpace:ccp(location.x,location.y)];
	//NSLog(@"Convert (%f,%f)", con.x,con.y);
	//[self addNewSpriteX: location.x y:location.y];
	//}
	//
//	CGPoint location = [self convertTouchToNodeSpace: touch];
//	
//	CCSpriteBatchNode* cBatch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
//	
//	NSMutableArray* array = [self autoArrayFromImageDictionary:@"steveFaces"];
//	int sIx = [self intRand:[array count]];
	//CCSprite *sprite = [CCSprite spriteWithBatchNode:cBatch rect:[self getSpritePosition:@"steveFaces" imageName:[array objectAtIndex:sIx]]];
//	
//	
//	[cBatch addChild: sprite];
//	
//	sprite.position = location;
	
    //MenuScene * ms = [MenuScene node];
    //[[CCDirector sharedDirector] replaceScene:ms];
	
	
}

@end