//
//  GuiMenu.h
//  CocosSeaLife
//
//  Created by Paul Szerlip on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GuiMenu : CCMenu {
	int selectedItemIndex;
	int fallBackItemIndex;
}
@property int selectedItemIndex;

-(CCMenuItem *) itemForTouch: (UITouch *) touch;
@end
