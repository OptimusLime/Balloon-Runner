//
//  GameOverMenu.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameOverMenu.h"
#import "GameScene.h"
#import "ResourceManager.h"
#import "PlayerBasket.h"
#import "ScoresScene.h"
#import "SimpleAudioEngine.h"

static int goTextTag = 1;
static int tapTextTag = 2;

@implementation GameOverMenu


- (id) init {
    self = [super init];
    if (self != nil) {
        self.isTouchEnabled =YES;

		_resourceManager = [ResourceManager sharedResourceManager];
			
	CGFloat iM = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
		CGSize sSize = [[CCDirector sharedDirector] winSize];
		CGFloat swh = sSize.width/2;
		CGFloat shh = sSize.height/2;
		
		CGFloat quickShift = iM*20.0f;
		//need to write in the actual height here
        
       
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"gameOverMenuBatch"];
		gameOverText  =   [_resourceManager sprite:@"gameOverText.png" withBatch:batch] ;
        tapContinueText  =   [_resourceManager sprite:@"tapContinueText.png" withBatch:batch] ;
        [self addChild:gameOverText z:2];
        [self addChild:tapContinueText z:2];
        
	
		gameOverText.position = ccp(swh, 2*shh + [gameOverText contentSize].height/2);
        tapContinueText.position = ccp(swh, shh );//- [gameOverText contentSize].height);
        
		[tapContinueText setOpacity:0]; 
     //   [gameOverText setOpacity:0]; 
        
       // [CCMoveTo action];
		CCSequence* fadeAction = [CCSequence actions: [CCMoveTo actionWithDuration:1.5f position:ccp(swh, shh + [gameOverText contentSize].height)],//[CCFadeIn actionWithDuration:1.5f],// [CCFadeOut actionWithDuration:1.5f] 
                                   [CCCallFuncND actionWithTarget:self selector:@selector(gameOverFadeComplete) data:nil]
                                   ,nil] ;
		[fadeAction setTag:goTextTag];
		
		//If it's already in the scene, just run the action
		[gameOverText runAction:fadeAction];

        
        
      
        
		gameOverCloud = [_resourceManager sprite:@"feetCloud.png" withBatch:batch];
		gameOverCloud.position = ccp(swh-iM*20.0f + quickShift,shh+iM*20.0f);
		[self addChild:gameOverCloud z:2];
		

         
		
		CCSprite* normSprite = [_resourceManager sprite:@"tryB.png" withBatch:batch];
		CCSprite* selSprite = [_resourceManager sprite:@"tryR.png" withBatch:batch];
		
		
		tryAgainButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
														 target:self selector:@selector(tryAgainButton:)];
		
		normSprite = [_resourceManager sprite:@"menuGameOverB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"menuGameOverR.png" withBatch:batch];
		
		
		menuButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(returnToMenu:)];
		
		
		normSprite = [_resourceManager sprite:@"scoresGOB.png" withBatch:batch];
		selSprite = [_resourceManager sprite:@"scoresGOR.png" withBatch:batch];
		
		
		scoresButton = [CCMenuItemSprite itemFromNormalSprite:normSprite selectedSprite:selSprite 
													 target:self selector:@selector(scores:)];
		
		
		
       partialMenuOne = [CCMenu menuWithItems:menuButton, tryAgainButton, nil];
		//menu.position = ccp(-swh -3.0f + [[backButton normalImage] contentSize].width/2, -shh -3.0f + [[backButton normalImage ]contentSize].height/2);
		[partialMenuOne alignItemsHorizontally];
		
		
		
		tryAgainButton.position = ccp(iM*64.0f + quickShift,-iM*74.0f);
		//- 68.0f
		menuButton.position = ccp(-swh + [[menuButton normalImage] contentSize].width/2 , -shh + [[menuButton normalImage] contentSize].height/2 ); //-62.0f);
		
		//menu.position = ccpAdd(menu.position, ccp(-swh+ [[backButton normalImage] contentSize].width/2 , shh - [[backButton normalImage ]contentSize].height/2));
        //[menu alignItemsVertically];
		
        [self addChild:partialMenuOne z:5];
		
		 partialMenuTwo = [CCMenu menuWithItems:scoresButton, nil];
		
		
		scoresButton.position = ccp(-[gameOverCloud contentSize].width/2 , [gameOverCloud contentSize].height/2 - [normSprite contentSize].height/3);
		[self addChild:partialMenuTwo z:0];

		
		CGFloat gameScore = [PlayerBasket gameScore];
		
		scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%1.0f",gameScore] fontName:@"allMenuFont.otf" fontSize:iM*40.0f];
		//NSLog(@"Width %f",[scoreLabel contentSize].width);
		scoreLabel.color = ccBLACK;
		// + 10.0f*(1-log10f(MAX(1,gameScore/100)))
		scoreLabel.position = ccp(swh + iM*7.0f + iM*10.0f*log10f(MAX(1,gameScore/100)) - [scoreLabel contentSize].width/2, shh + iM*15.0f );//- [scoreLabel contentSize].height/2);//50.0f);//ccp( swh - 20.0f,shh+20.0f);
		
		[self addChild:scoreLabel z:5];
		
        [gameOverCloud setOpacity: 0]; 
        [partialMenuOne setOpacity: 0];
        [partialMenuTwo setOpacity: 0];
        [scoreLabel setOpacity: 0];
        [gameOverCloud setVisible: NO]; 
        [partialMenuOne setVisible: NO];
        [partialMenuTwo setVisible: NO];
        [scoreLabel setVisible: NO];
        
        isWaitingForTap = NO;
		
    }
    return self;
}
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}
-(void) keepBlinking
{
    if(![gameOverCloud visible])
    {
        
    CCSequence* blinkAction = [CCSequence actions:[CCFadeIn actionWithDuration:.75f], [CCFadeOut actionWithDuration:.75f] 
                               ,[CCCallFuncND actionWithTarget:self selector:@selector(keepBlinking) data:nil]
                               ,nil] ;
    [blinkAction setTag:tapTextTag];
        
    [tapContinueText runAction:blinkAction];
        
    }
}
-(void) gameOverFadeComplete
{
    [gameOverText stopActionByTag: goTextTag]; 
    //start blinking the tapecontinuetext
    //[CCBlink actionWithDuration:.5 blinks:0]
    CCSequence* blinkAction = [CCSequence actions:[CCFadeIn actionWithDuration:.75f], [CCFadeOut actionWithDuration:.75f] 
                               ,[CCCallFuncND actionWithTarget:self selector:@selector(keepBlinking) data:nil]
                               ,nil] ;
    [blinkAction setTag:tapTextTag];
    
    //If it's already in the scene, just run the action
    [tapContinueText runAction:blinkAction];
    isWaitingForTap = YES;
    
}
-(void) tapContinue:(id) sender
{
    [tapContinueText runAction:[CCFadeOut actionWithDuration:.5f]];
    [gameOverText runAction:[CCFadeOut actionWithDuration:.5f]];
    
    [gameOverCloud setVisible: YES]; 
    [partialMenuOne setVisible: YES];
    [partialMenuTwo setVisible: YES];
    [scoreLabel setVisible: YES];
    
    [gameOverCloud runAction: [CCFadeIn actionWithDuration:1.0f]];
    [partialMenuOne runAction: [CCFadeIn actionWithDuration:1.0f]];
    [partialMenuTwo runAction: [CCFadeIn actionWithDuration:1.0f]];
    [scoreLabel runAction: [CCFadeIn actionWithDuration:1.0f]];
}
-(void) tryAgainButton:(id)sender
{
	[(GameScene*)parent_ resetGame];
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
}
-(void) returnToMenu:(id)sender
{
	[(GameScene*)parent_ returnToGameMenu];
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
}
-(void)scores:(id)sender
{
	
	//[[CCDirector sharedDirector] popScene];
	[(GameScene*)parent_ exitScene];
	[[CCDirector sharedDirector] pushScene:[ScoresScene node]];
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if(isWaitingForTap)
    {
        isWaitingForTap = NO;
        [self tapContinue:self];
        
    }
		
    return NO;
}
-(void) ccTouchCancelled:(UITouch*) touch withEvent:(UIEvent*)event
{
    
   
    
}

-(void) ccTouchMoved:(UITouch*) touch withEvent:(UIEvent*)event
{
  
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	
  
    
	
}
@end
