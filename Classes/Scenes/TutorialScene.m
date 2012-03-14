//
//  TutorialScene.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialScene.h"
#import "ResourceManager.h"
#import "SimpleAudioEngine.h"

enum  {
	kBRTutorialBack
};

@implementation TutorialScene

- (id) init {
    self = [super init];
    if (self != nil) {
		//CCSpriteBatchNode* batch = [[ResourceManager sharedResourceManager] batchNodeForPath:@"scoresMenuBatch"];
		
       // CCSprite * bg = [[ResourceManager sharedResourceManager] sprite:@"scoresCloud.png" withBatch:batch];//[CCSprite spriteWithFile:@"sunBack.png"];//
       // [bg setPosition:ccp(240, 160)];
		
      //  [self addChild:bg z:0];
		
        [self addChild:[TutorialLayer node] z:1];
		
		
		
	
		
    }
    return self;
}


@end



@implementation TutorialLayer


-(void) dealloc
{
	[imageArray release];
	[super dealloc];
}
- (id) init {
    self = [super init];
    if (self != nil) {
		
		_resourceManager = [ResourceManager sharedResourceManager];
		CGSize s = [[CCDirector sharedDirector]winSize];
		CGFloat swh = s.width/2;
		CGFloat shh = s.height/2;

		
		imageArray = [[NSMutableArray alloc] initWithCapacity:6];
		[imageArray addObject:@"leftTilt.png"];
		[imageArray addObject:@"rightTilt.png"];
		[imageArray addObject:@"tiltUpDown.png"];
		[imageArray addObject:@"bbShooting.png"];
		[imageArray addObject:@"balloonHealth.png"];
		
		currentImageIx = 0;
		
		
		
		CCSpriteBatchNode* batch = [_resourceManager batchNodeForPath:@"tutorialBatch"];
		
		CCSprite* backBSprite =[_resourceManager sprite:@"backTutW.png" withBatch:batch];
		CCSprite* bSelSprite = [_resourceManager sprite:@"backTutR.png" withBatch:batch];
		
		CCSprite* menuSprite = [_resourceManager sprite:@"menuTutW.png" withBatch:batch];
		CCSprite* mSelSprite = [_resourceManager sprite:@"menuTutR.png" withBatch:batch];
		
		backButton = [CCMenuItemSprite itemFromNormalSprite:backBSprite selectedSprite:bSelSprite target:self selector:@selector(back:)];
		menuButton = [CCMenuItemSprite itemFromNormalSprite:menuSprite selectedSprite:mSelSprite target:self selector:@selector(returnToMenu:)];
		
		backBSprite =[_resourceManager sprite:@"nextTutW.png" withBatch:batch];
		bSelSprite = [_resourceManager sprite:@"nextTutR.png" withBatch:batch];
		
		
		
		nextButton = [CCMenuItemSprite itemFromNormalSprite:backBSprite selectedSprite:bSelSprite target:self selector:@selector(next:)];
		
		
		//backMenuToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(backorMenuPressed:) items:menuButton,backButton,nil];
		
		//backMenuToggle.position = ccp( .75f*[pSrprite contentSize].width,.5f*[pSrprite contentSize].height);//ccp(-swh + [pSrprite contentSize].width/2, -shh + [pSrprite contentSize].height/2);
		
		backMenuMenu = [CCMenu menuWithItems:backButton,menuButton, nextButton, nil];
		
		[self addChild:backMenuMenu z:2];
		
		nextButton.position = ccp(swh - [[nextButton normalImage] contentSize].width/2, -shh + [[nextButton normalImage] contentSize].height/2);
		
		menuButton.position = ccp(-swh + [[menuButton normalImage] contentSize].width/2, -shh + [[menuButton normalImage] contentSize].height/2);
		backButton.position = ccp(-swh + [[backButton normalImage] contentSize].width/2, -shh + [[backButton normalImage] contentSize].height/2);
		//backMenuMenu.position = ccpAdd(backMenuMenu.position,ccp(-swh,-shh));
		
		
		[self setBackgroundTutorial];
		
	}
	return self;
}
-(void) setBackgroundTutorial
{
		if(backSprite)
			[self removeChildByTag:kBRTutorialBack cleanup:YES];

	
	backSprite =[_resourceManager sprite:[imageArray objectAtIndex:currentImageIx] withBatch:[_resourceManager batchNodeForPath:@"tutorialBatch"]];
	
	CGSize s = [[CCDirector sharedDirector]winSize];
	CGFloat swh = s.width/2;
	CGFloat shh = s.height/2;
	
	backSprite.position = ccp(swh, shh);
	[self addChild:backSprite z:0 tag:kBRTutorialBack];
	
	//Make the next button invisible at the end of the tutorial
	[nextButton setVisible:!(currentImageIx == [imageArray count]-1)];
		 
	[menuButton setVisible:(currentImageIx == 0)];
	[backButton setVisible:(currentImageIx != 0)];
	
}
-(void) next:(id)sender
{
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];

	currentImageIx = MIN(currentImageIx +1, [imageArray count]-1);
	[self setBackgroundTutorial];
	
}
-(void) returnToMenu:(id) sender
{
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];

	[[CCDirector sharedDirector] popScene];
}
-(void) back:(id)sender
{
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];

	currentImageIx = MAX(0, currentImageIx -1);
	[self setBackgroundTutorial];
}
-(void)backorMenuPressed:(id)sender {  
	
//	[[SimpleAudioEngine sharedEngine] playEffect:@"bClick.mp3"];
//	CCMenuItemToggle *toggleItem = (CCMenuItemToggle *)sender;
	//if (toggleItem.selectedItem == playButton) {
//	
//		//[toggleItem toggle
//		
//		//The button being pressed is the play button, i.e. we just clicked the pause button
//		//This should stop the physics being updated, but all of the balloons and the player are still being triggered
//		//[(GameScene*)parent_ pauseGame];
//		//NSLog(@"Play");
//		//[_label setString:@"Visible button: +"];    ccmen
//		
//	} else if (toggleItem.selectedItem == pauseButton) {
//		
//		
//		//The button clicked is the pause button, i.e. we just pressed the play button
		//[(GameScene*)parent_ resumeGame];
		//NSLog(@"PAUSE!");
		
		//[_label setString:@"Visible button: -"];
		
	//}  
	
}

@end