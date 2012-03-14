//
//  HelloWorldScene.m
//  dbag
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"
#import "AppEnumerations.h"
#import "ResourceManager.h"
#import "PhysicsManager.h"
#import "Balloon.h"
#import "RandomManager.h"
#import "SpaceManager.h"
#import "cpCCSprite.h"
#import "PlayerBasket.h"

//#import "drawSpace.h"
enum {
	kTagBatchNode = 1,
};



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

// HelloWorld implementation
@implementation HelloWorld

//drawSpaceOptions options = {
//	0,//Draw Hash
//	0,//Draw BBoxes
//	1,//Draw Shapes
//	4.0f,//Collision Point Size
//	0.0f,//Body Point Size
//	1.5f//Line Thickness
//};

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//-(void) draw {
	//drawSpace(space, &options);
//}
-(void) addNewSpriteX: (float)x y:(float)y
{
	[playerBasket addAnyColorBalloon:ccp(x,y)];
	//int posx, posy;
	
//	CCSpriteBatchNode *batch = [_resourceManager batchNodeForPath:@"balloonBatch"];//(CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	//posx = (CCRANDOM_0_1() * 200);
	//posy = (CCRANDOM_0_1() * 200);
	
	//posx = (posx % 4) * 85;
	//posy = (posy % 3) * 121;
	//SpaceManager* smgr = [_physicsManager spaceManager];
//	BalloonColor bColor = (BalloonColor)[[RandomManager sharedRandomManager] intRand:blue Max:pink];
//	CGSize iSize = [_resourceManager spriteContentSize:stringForColor(bColor) fromPath:@"balloonBatch"];
//	
//	CGFloat reduceSize = .5;
//	iSize.width *= reduceSize;
//	iSize.height*= reduceSize;
//	CGFloat inRadius = .5;
//	
//	cpShape *ball = [smgr addCircleAt:cpv(x,y) mass:5.0 radius:inRadius*cpvlength(cpv(iSize.width/2, iSize.height/2))];
//	
//
//	
//	
//	cpCCSprite *ballSprite = [cpCCSprite spriteWithShape:ball batchNode:batch rect:[_resourceManager getSpritePositionWithBatch:batch
//																										 imageName:stringForColor(bColor)]];
//	//[ballSprite shape
//	[ballSprite setScale:reduceSize];
	
	
	//BalloonColor bColor = (BalloonColor)[[RandomManager sharedRandomManager] intRand:_sBalloon+1 Max:_eBalloon];
	//[self addChild:[Balloon balloonWithColor:bColor withPlayer:nil atPoint:ccp(x,y)]];   
	
}

	
	
//	CCSprite *sprite = [Balloon balloonWithColor:bColor withPlayer:nil atPoint:ccp(x,y)];//[CCSprite spriteWithBatchNode:batch rect:[_resourceManager getSpritePositionWithBatch:batch 
//																							//	   imageName:@"orange2.png"]];//CGRectMake(posx, posy, 85, 121)];
//	
//	[batch addChild: sprite z:1];
//	
//	
//	
//	
//	
//	
//	sprite.position = ccp(x,y);
//	
//	int num = 4;
//	CGFloat xBot, yBot;
//	CGFloat sScale =  [sprite scale];
//	CGFloat scaleDown = .5f;
//	//xBot = 24; yBot = 54;
//	xBot = scaleDown*(sScale*[sprite contentSize].width)/2;
//	yBot = scaleDown*(sScale*[sprite contentSize].height)/2;
//	CGPoint verts[] = {
//		ccp(-xBot,-yBot),
//		ccp(-xBot, yBot),
//		ccp( xBot, yBot),
//		ccp( xBot,-yBot),
//	};
//	
//	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));
//	
//	// TIP:
//	// since v0.7.1 you can assign CGPoint to chipmunk instead of cpVect.
//	// cpVect == CGPoint
//	body->p = ccp(x, y);
//	cpSpaceAddBody(space, body);
//	
//	cpShape* shape = cpCircleShapeNew(body, xBot, CGPointZero);//cpPolyShapeNew(body, num, verts, CGPointZero);
//	shape->e = 0.5f; shape->u = 0.5f;
//	shape->data = sprite;
//	cpSpaceAddShape(space, shape);
//	
//}
-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		_resourceManager = [ResourceManager sharedResourceManager];
		_physicsManager = [PhysicsManager sharedPhysicsManager];
		CGSize wins = [[CCDirector sharedDirector] winSize];
		//cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = [_physicsManager space];//cpSpaceNew();
	//	cpSpaceResizeStaticHash(space, 400.0f, 40);
	//	cpSpaceResizeActiveHash(space, 100, 600);
		
	//	space->gravity = ccp(0, 0);
	//	space->elasticIterations = space->iterations;
		
		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(wins.width,0), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(0,wins.height), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		CCSpriteBatchNode *batch = [_resourceManager batchNodeForPath:@"balloonBatch"];//[CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:100];
		
		[self addChild:batch z:0 tag:kTagBatchNode];
		
		playerBasket = [PlayerBasket standardPlayerBasket:ccp(240,50) withParent:self];
		lastBasketPoint = [playerBasket convertToWorldSpace:playerBasket.position];	
		[self addNewSpriteX: 200 y:200];
		
		[self schedule: @selector(step:)];
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

-(void) step: (ccTime) delta
{
	//ccTime cpy = delta;

	[_physicsManager updatePhysics:delta withCallback:&eachShape];

	
	CGPoint afterPoint = [playerBasket convertToWorldSpace:playerBasket.position];	
	self.position = ccpAdd(self.position, ccpSub(lastBasketPoint,afterPoint));
	
	lastBasketPoint = afterPoint;
	
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteX: location.x y:location.y];
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	CGPoint v = ccp( accelX, accelY);
	
	space->gravity = ccpMult(v, 200);
}
@end
