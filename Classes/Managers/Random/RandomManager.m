//
//  RandomManager.m
//  SteamArmada
//
//  Created by Paul Szerlip on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RandomManager.h"
#import "SynthesizeSingleton.h"

//Variables for what we're generating around the player, we multiply left and right by the max of width and height, and the above and below by the same number
#define ABOVE_PLAYER 4.0f/3.0f
#define LEFT_OF_PLAYER 1.0f
#define RIGHT_OF_PLAYER 1.0f
#define BELOW_PLAYER 1.0f/3.0f

#define ARC4RANDOM_MAX 0x100000000

static BOOL randomInitialized = NO;

@implementation RandomManager

SYNTHESIZE_SINGLETON_FOR_CLASS(RandomManager);

- (void)dealloc {
	[super dealloc];
}


-(void) ensureInitialized
{
	
	//if(!randomInitialized)
//	{
//	for(int i=0; i < _countRandomArray; i++)
//	{
//		randomFloatArray[i] = frand();
//	}
//	for(int i=0; i < _countRandomArray; i++)
//	{
//		randomIntArray[i] = rand();
//	}
//	randomFloatCount = 0;
//	randomIntCount = 0;
//	}
	
	
	
}
-(double) randDouble
{
	return (((CGFloat)arc4random() / ARC4RANDOM_MAX) * 1.0f);//floorf(((double)arc4random() / ARC4RANDOM_MAX) * 1.0f);
}

-(int) intRand:(int) min Max:(int) max
{
	return arc4random() % (max-min) + min;
}
-(int) intRand:(int) max
{
	return arc4random()%max;
}


-(CGFloat) frand
{
	return (((CGFloat)arc4random() / ARC4RANDOM_MAX) * 1.0f);
	//CGFloat ret = randomFloatArray[randomFloatCount];
//	randomFloatCount = (randomFloatCount +1) % _countRandomArray;
//	return ret;
	//return frand();
}
-(int) rand
{
	return arc4random();
	//int ret = randomIntArray[randomIntCount];
	//randomIntCount = (randomIntCount +1) % _countRandomArray;
	//return ret;
	//return rand();
}

-(CGFloat) frandInRange:(CGFloat) min max:(CGFloat) max 
{return (max-min)*[self frand] + min;}

-(CGPoint) frandInArea:(CGPoint) min  max:(CGPoint) max
{	return ccp([self frandInRange:min.x max:max.x],[self frandInRange:min.y max:max.y]); }

-(CGPoint) frandInAreaMinus:(CGPoint) min max:(CGPoint) max  avoidMin:(CGPoint) avoidMin avoidMax:(CGPoint) avoidMax 
{
	CGFloat x;
	CGFloat y = [self frandInRange:min.y max:max.y];
	//If we're inside of where we shouldn't be, then the x value needs to be restricted
	if( y > avoidMin.y && y < avoidMax.y)
	{
		if([self rand] %2)
		{
			x = [self frandInRange:min.x max:avoidMin.x];
		}
		else
		{
			x =  [self frandInRange:avoidMax.x max:max.x];
		}
	}
	//Otherwise, we're already restricting our y, our x can be anything
	else
	{
		x = [self frandInRange:min.x max: max.x];
	}
	
	return ccp(x,y);
}
-(CGPoint) frandInAreaMinusImageDimensions:(CGPoint) min max:(CGPoint) max  avoidMin: (CGPoint) avoidMin avoidMax:( CGPoint) avoidMax quadCpv: (CGPoint) quadCpv
{
	
	return [self frandInAreaMinus:ccpAdd(min, quadCpv)  max:ccpSub(max, quadCpv) avoidMin: avoidMin avoidMax: avoidMax];
}

-(CGPoint) frandInAreaWithImageAndCenter:(CGPoint) playerCenter screenMin: (CGPoint) screenMin screenMax:(CGPoint) screenMax width:( CGFloat) width  quadCpv: (CGPoint) quadCpv
{
	CGPoint min = ccpAdd(ccpSub(playerCenter, ccp(width, BELOW_PLAYER*width)),quadCpv);
	CGPoint max = ccpSub(ccpAdd(playerCenter, ccp(width, ABOVE_PLAYER*width)), quadCpv);
	
	return [self frandInAreaMinusImageDimensions:min max:max  avoidMin:screenMin avoidMax:screenMax  quadCpv:quadCpv];
	
}



@end
