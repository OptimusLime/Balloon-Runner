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

@interface ResourceManager : NSObject {
	
	
	
    NSMutableDictionary     *_cachedTextures;
	NSMutableDictionary		*_cachedBatchDictionary;
	NSMutableDictionary		*_fileNameDictionary;
	NSMutableDictionary		*_cachedPlistDictionary;
	
	
	//NSDictionary			*textureDictionary;
	
}

//@property (readonly, assign) NSDictionary* textureDictionary;

+ (ResourceManager *)sharedResourceManager;
-(void) initResources;
-(void) initGameResources;
// Selector returns a Texture2D which has a ket of |aTextureName|.  If a texture cannot be
// found with that key then a new Texture2D is created and added to the cache and a 
// reference to this new Texture2D instance is returned.
//-(CGSize) spriteContentSize:(NSString*) fileName;
-(CGSize) spriteContentSize:(NSString*) fileName fromPath:(NSString*) pathString;
-(CGRect) getSpritePosition:(NSString*) pathString imageName:(NSString*) fileName;
-(CGRect) getSpritePositionWithBatch:(CCSpriteBatchNode*) batch imageName:(NSString*) fileName;
-(CCSpriteBatchNode*) batchNodeForPath:(NSString*) pathString;
-(CCSprite*) sprite:(NSString*) fileName withBatch:(CCSpriteBatchNode*)batch;
+(BOOL) isPixelArt;
// Selector that releases a cached texture which has a matching key to |aTextureName|.
//- (BOOL)releaseTextureWithName:(int)aTextureName;

// Selector that releases all cached textures.
//- (void)releaseAllTextures;

@end
