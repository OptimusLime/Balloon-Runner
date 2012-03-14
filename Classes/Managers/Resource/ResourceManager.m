//
//  ResourceManager.m
//  OGLGame
//
//  Created by Michael Daley on 16/05/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "ResourceManager.h"
#import "SynthesizeSingleton.h"

//#import "CurrentTextureList.h"
//static int debugCount  = 0;
//static NSDictionary* texDict = nil;
//#define DEBUG 0
#define TOTAL_SPRITE_SHEETS 5
#define DEFAULT_BATCH_CAPACITY 15
#define PIXEL_ART 1

@interface ResourceManager()

-(CGRect) addFileNameToCache:(NSString*) fileName withDict:(NSDictionary*) dict;

-(NSDictionary*) addPlistToCache:(NSString*) pathString;
@end


@implementation ResourceManager

//@synthesize textureDictionary;

SYNTHESIZE_SINGLETON_FOR_CLASS(ResourceManager);

- (void)dealloc {
    
    // Release the cachedTextures dictionary.
	[_cachedTextures release];
	[_cachedPlistDictionary release];
	[super dealloc];
}
-(id) init
{
	if((self = [super init]))
	{
		[self initResources];
	}
	return self;
}
+(BOOL) isPixelArt
{
	return (BOOL)(PIXEL_ART);
}
- (void)initResources
{
	// Initialize a dictionary with an initial size to allocate some memory, but it will 
    // increase in size as necessary as it is mutable.

	_cachedTextures = [[NSMutableDictionary dictionaryWithCapacity:TOTAL_SPRITE_SHEETS] retain];
	_cachedPlistDictionary = [[NSMutableDictionary dictionaryWithCapacity:TOTAL_SPRITE_SHEETS] retain];
	 
	_cachedBatchDictionary = [[NSMutableDictionary dictionaryWithCapacity:TOTAL_SPRITE_SHEETS] retain];
	_fileNameDictionary =  [[NSMutableDictionary dictionaryWithCapacity:TOTAL_SPRITE_SHEETS] retain];
	
	
	
	
	

}
-(void) initGameResources
{
	[self batchNodeForPath:@"backCloudBatch"];
	[self batchNodeForPath:@"balloonBatch"];
	[self batchNodeForPath:@"enemyBatch"];
	[self batchNodeForPath:@"projectileBatch"];
	[self batchNodeForPath:@"mainMenuBatch"];
}
-(CCSprite*) sprite:(NSString*) fileName withBatch:(CCSpriteBatchNode*)batch
{
	return [CCSprite spriteWithBatchNode:batch rect:[self getSpritePositionWithBatch:batch imageName:fileName]];
}
-(NSDictionary*) addPlistToCache:(NSString*) pathString
{
	if([[CCDirector sharedDirector] enableRetinaDisplay:YES] || (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		pathString = [pathString stringByAppendingString:@"-hd"];
	//NSLog(@"path %@", pathString );
	NSDictionary* dict;
	if( (dict = [_cachedPlistDictionary objectForKey:pathString]) )
	{
		
		//We already cached this
		return dict;
	}
	NSString *path = [[NSBundle mainBundle] pathForResource:pathString ofType:@"plist"];
	dict = [NSDictionary dictionaryWithContentsOfFile:path];
	[_cachedPlistDictionary setObject:dict forKey:pathString];
	
	return dict;
	
}
-(CGRect) addFileNameToCache:(NSString*) fileName withDict:(NSDictionary*) dict
{
	NSValue* value;
	if((value = [_fileNameDictionary objectForKey:fileName]))
	{
		//CGRect rectRet = [value CGRectValue];
		//return ([[CCDirector sharedDirector] enableRetinaDisplay:YES]) ? rectRet : CGRectMake(rectRet.origin.x,rectRet.origin.y, rectRet.size.width/2, rectRet.size.height/2);
		//we've already seen this value in the cache, just return it
		return [value CGRectValue];
	}
	//We haven't seen this file before, cache it, and return the rect 
	
	//Framedict is actually a dictionary of the textures contained in our texture atlas
	NSDictionary *frameDict = [[dict objectForKey:@"frames"] objectForKey:fileName];
	CGRect rectRet =  CGRectFromString([frameDict objectForKey:@"frame"]);
	rectRet = ([[CCDirector sharedDirector] enableRetinaDisplay:YES]) ?  CGRectMake(rectRet.origin.x/2,rectRet.origin.y/2, rectRet.size.width/2, rectRet.size.height/2) : rectRet;
	[_fileNameDictionary setObject:[NSValue valueWithCGRect:rectRet] forKey:fileName];
	
	//return ([[CCDirector sharedDirector] enableRetinaDisplay:YES]) ? rectRet : CGRectMake(rectRet.origin.x,rectRet.origin.y, rectRet.size.width/2, rectRet.size.height/2);
	
	
	return rectRet;
	
}

-(CGRect) getSpritePosition:(NSString*) pathString imageName:(NSString*) fileName
{

	id plist;
	//If we've seen this path before, we'll return it, otherwise we'll cache it
	if( (plist = [self addPlistToCache:pathString]) )
	{
		//find the file you're lokoing for,and convert the "frame" string to a CGRect
		//If we've seen it, we'll return the object from our cached dictionary, otherwise we'll create the rectangle and store it in the cache
		return [self addFileNameToCache:fileName withDict:plist];
		//CGRect rectRet =  [self addFileNameToCache:fileName withDict:plist];
		//return ([[CCDirector sharedDirector] enableRetinaDisplay:YES]) ? rectRet : CGRectMake(rectRet.origin.x,rectRet.origin.y, rectRet.size.width/2, rectRet.size.height/2);
		
	}
	//We haven't been able to find the plist, this I think should throw an error
	
	NSAssert(YES == NO, @"Caused an error by feeding an invalid path string or filename");
	
	return CGRectMake(-1, -1, -1, -1);
	//okay, so we want to be able to check the cached textures for 

	//NSDictionary *dict = [self addPlistToCache:pathString];	

	
	//return the rectangle while adding it to the cache
	//return [self addFileNameToCache:fileName withDict:dict];
		
}
-(CGSize) spriteContentSize:(NSString*) fileName fromPath:(NSString*) pathString
{
	//NSValue* value;
	
	id plist;
	//If we've seen this path before, we'll return it, otherwise we'll cache it
	if( (plist = [self addPlistToCache:pathString]) )
	{
	  return [self addFileNameToCache:fileName withDict:plist].size;
	}
	//
	
	NSAssert(plist != nil, @"You're requesting a sprite that hasn't been cached yet, make sure you've already loaded the batch node");
	
		return CGSizeMake(-1,-1);
	

	
}
-(CGRect) getSpritePositionWithBatch:(CCSpriteBatchNode*) batchNode imageName:(NSString*) fileName
{

	NSString* pString;
	//NSDictionary* plist;
	
	if((pString = [_cachedBatchDictionary objectForKey:[NSValue valueWithNonretainedObject: batchNode]]))
	   {
		   //We have a path name, now search the plist cache
		   
		   return [self addFileNameToCache:fileName withDict:[self addPlistToCache:pString]];
		   
	   }
	   //If we don't have a path name, there is nothing we can do
	   NSAssert(YES == NO, @"Error finding batch node, node doesn't exist");
	   return CGRectMake(-1,-1,-1,-1);
}

-(CCSpriteBatchNode*) batchNodeForPath:(NSString*) pathString 
{
			
	CCSpriteBatchNode* rBatch;
	
	
	NSString* pngString;
	
	if([[CCDirector sharedDirector] enableRetinaDisplay:YES] || (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		pngString = [pathString stringByAppendingString:@"-hd.png"];
	else
		pngString = [pathString stringByAppendingString:@".png"];

	if((rBatch = [_cachedBatchDictionary objectForKey:pngString]))
	{
		//Found rbath in the cache, simply return it
		return rBatch;
	}
	//we've never seen this path before, get ready to add a bunch of stuff
	
	 [self addPlistToCache:pathString];
//	NSLog(@"pngString %@", pngString);
	
	//The HD addition will automatically be taken care of for this	
	rBatch = [CCSpriteBatchNode batchNodeWithFile:pngString capacity:DEFAULT_BATCH_CAPACITY];
	
	//This might cause memory leak issues???
	
	[_cachedBatchDictionary setObject:rBatch forKey:pngString];

	
	
	[_cachedBatchDictionary setObject:pathString forKey:[NSValue valueWithNonretainedObject:rBatch]];
	
	return rBatch;
	
	
	
}

//
//- (void)releaseAllTextures {
//    if(DEBUG) NSLog(@"INFO - Resource Manager: Releasing all cached textures.");
//    [_cachedTextures removeAllObjects];
//}


@end
