//
//  ResourceManager.h
//  OGLGame
//
//  Created by Michael Daley on 16/05/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


// Class that is responsible for texture resources witihn the game.  This class should be
// used to load any texture.  The class will check to see if an instance of that Texture
// already exists and will return a reference to it if it does.  If not instance already
// exists then it will create a new instance and pass a reference back to this new instance.
// The filename of the texture is used as the key within this class.

@interface SaveLoadManager : NSObject {
	
	
	
	NSMutableDictionary     *_cachedSavedObjects;
	//NSMutableDictionary		*_cachedBatchDictionary;
	//NSMutableDictionary		*_fileNameDictionary;
	//NSMutableDictionary		*_cachedPlistDictionary;
	//NSDictionary			*textureDictionary;
	
}

//@property (readonly, assign) NSDictionary* textureDictionary;

+ (SaveLoadManager *)sharedSaveLoadManager;

-(BOOL) firstLaunch;
-(void) setNotFirstLaunch;
-(void) saveStateObjects:(NSMutableDictionary*) objects;
-(NSMutableDictionary*) loadNumbers:(NSMutableArray*) keys;
-(NSMutableDictionary*) loadStrings:(NSMutableArray*) keys;
-(NSNumber*) loadNumber:(id) key;
-(NSString*) loadString:(id)key;
-(void)clearCache;
-(void) saveValue:(id) saveObject forKey:(id) key;

@end
