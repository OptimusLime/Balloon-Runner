//
//  RandomManager.h
//  SteamArmada
//
//  Created by Paul Szerlip on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#define _countRandomArray 1000

@interface RandomManager : NSObject {
	//1000 random numbers is arbirtarily chosen
	CGFloat randomFloatArray[_countRandomArray];
	
	
	int randomIntArray[_countRandomArray];
	int randomFloatCount;
	int randomIntCount;
}
+ (RandomManager *)sharedRandomManager;
-(void) ensureInitialized;
-(CGFloat) frand;
-(int) rand;
-(double) randDouble;
-(int) intRand:(int) min Max:(int) max;
-(int) intRand:(int) max;
//Higher level random function based on lower level things
-(CGFloat) frandInRange:(CGFloat) min max:(CGFloat) max;
-(CGPoint) frandInArea:(CGPoint) min  max:(CGPoint) max;
-(CGPoint) frandInAreaMinus:(CGPoint) min max:(CGPoint) max  avoidMin:(CGPoint) avoidMin avoidMax:(CGPoint) avoidMax;
-(CGPoint) frandInAreaMinusImageDimensions:(CGPoint) min max:(CGPoint) max  avoidMin: (CGPoint) avoidMin avoidMax:( CGPoint) avoidMax quadCpv: (CGPoint) quadCpv;
-(CGPoint) frandInAreaWithImageAndCenter:(CGPoint) playerCenter screenMin: (CGPoint) screenMin screenMax:(CGPoint) screenMax width:( CGFloat) width  quadCpv: (CGPoint) quadCpv;
@end
