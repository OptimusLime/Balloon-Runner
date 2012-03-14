//
//  RadioMenu.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RadioBackMenu.h"


@implementation RadioBackMenu

+(id) menuWithItems:(CCMenuItem *)item andBackground:(CCSprite*) back
{
	id menu = [RadioBackMenu menuWithItems:item,nil];
	[menu addChild:back z:0];
	return menu;
}

@end
