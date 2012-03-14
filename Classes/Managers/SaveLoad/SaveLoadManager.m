//
//  ResourceManager.m
//  OGLGame
//
//  Created by Michael Daley on 16/05/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "SaveLoadManager.h"
#import "SynthesizeSingleton.h"

//#import "CurrentTextureList.h"
//static int debugCount  = 0;
//static NSDictionary* texDict = nil;
//#define DEBUG 0



static NSString* FIRST_LAUNCH = @"FIRST_LAUNCH";


@interface SaveLoadManager()

-(void) initResources;
//-(CGRect) addFileNameToCache:(NSString*) fileName withDict:(NSDictionary*) dict;
-(void) updateCache:(id) dValue withKey:(id) keyValue;
-(id) checkCache:(id) key;
-(void) saveValue:(id) object key:(id) stringKey userDefault:(NSUserDefaults*) userDef;

-(NSString*) loadString:(id)key userDefault:(NSUserDefaults*) userDef;
-(NSNumber*) loadNumber:(id)key userDefault:(NSUserDefaults*) userDef;
-(BOOL) isNumber:(id) object;
-(BOOL) isString:(id) object;
//-(NSDictionary*) addPlistToCache:(NSString*) pathString;
@end


@implementation SaveLoadManager

//@synthesize textureDictionary;

SYNTHESIZE_SINGLETON_FOR_CLASS(SaveLoadManager);

- (void)dealloc {
    
    // Release the cachedTextures dictionary.
	[_cachedSavedObjects release];
	
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

- (void)initResources
{
	// Initialize a dictionary with an initial size to allocate some memory, but it will 
    // increase in size as necessary as it is mutable.

	_cachedSavedObjects = [[NSMutableDictionary dictionaryWithCapacity:15] retain];
	
	
	
	
		
}

-(BOOL) firstLaunch
{
	id num;
	if((num = [self checkCache:FIRST_LAUNCH]))
	{
		return [num boolValue];
	}
	//Grab the launched variable
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	
	BOOL ret =  ![userDef integerForKey:FIRST_LAUNCH];
	
	[self updateCache:[NSNumber numberWithBool:ret] withKey:FIRST_LAUNCH];
	
	return ret;
	
	
}
-(void) setNotFirstLaunch
{
	//Grab the variable used in firstlaunch and set it to false
	//Grab the launched variable
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	
	[userDef setInteger:1 forKey:FIRST_LAUNCH];
	
	[self updateCache:[NSNumber numberWithBool:NO] withKey:FIRST_LAUNCH];
	
	[userDef synchronize];
	
}
-(void) saveStateObjects:(NSMutableDictionary*) objects
{
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	
	
	id val;
	for (id key in objects) {
		val = [objects objectForKey:key];
		[self saveValue:val key:key userDefault:userDef];
	}
	[userDef synchronize]; 
	
}
-(NSMutableDictionary*) loadStrings:(NSMutableArray*) keys
{
	if([self firstLaunch])
		return nil;
	
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* stringDict = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
	id key;
	id retString;
	for (key in keys) {
		retString = [self checkCache:key];
		if(!retString)
		{
			retString = [self loadString:key userDefault:userDef];
		}
	
		[stringDict setObject:retString forKey:key];
	}
	return stringDict;
	
	
}
-(NSString*) loadString:(id)key
{
	if([self firstLaunch])
		return nil;
	//first check the cache for the object
	NSString* returnString = [self checkCache:key];
	if(returnString)
	{
		return returnString;
	}
	
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	
	return [self loadString:key userDefault:userDef];
	
		
	
	
	
}
-(NSMutableDictionary*) loadNumbers:(NSMutableArray*) keys
{
	if([self firstLaunch])
		return nil;
	
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* numberDict = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
	id key;
	id retNum;
	for (key in keys) {
		retNum = [self checkCache:key];
		if(!retNum)
		{
			retNum = [self loadNumber:key userDefault:userDef];
		}
		
		[numberDict setObject:retNum forKey:key];
	}
	return numberDict;
	
	
}
-(NSNumber*) loadNumber:(id) key
{
	if([self firstLaunch])
		return nil;
	
		//first check the cache for the object
	NSNumber* returnNumber = [self checkCache:key];
	if(returnNumber)
	{
		return returnNumber;
	}
	
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	
	return [self loadNumber:key userDefault:userDef];
	
	
}

-(id) checkCache:(id) key
{
	//if([self isNumber:key])
	//	key = [key stringValue];
	
	return [_cachedSavedObjects objectForKey:key];
}

//It is assumed you looked through the cache already
-(NSString*) loadString:(id)key userDefault:(NSUserDefaults*) userDef
{
	id returnString;
	id realKey = key;
	if([self isNumber:key])
	{
		realKey = [key stringValue];
	}
	
	returnString = [userDef objectForKey:realKey];
	
	//We shall update our cache! so next time we access this information, we don't have to grab the user defaults again
	[self updateCache:returnString withKey:key];
	
	return returnString;
	
	
}
-(NSNumber*) loadNumber:(id)key userDefault:(NSUserDefaults*) userDef
{
	id returnNumber;
	id realKey = key;
	
	if([self isNumber:key])
	{
		realKey = [key stringValue];
	}
	
	returnNumber = [NSNumber numberWithFloat:[userDef floatForKey:realKey]];
	
	//We shall update our cache! so next time we access this information, we don't have to grab the user defaults again
	[self updateCache:returnNumber withKey:key];
	
	return returnNumber;
	
}
//Save object can be an NSNumber of NSString
-(void) saveValue:(id) saveObject forKey:(id) key
{
	NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
	[self saveValue:saveObject key:key userDefault:userDef];
	[userDef synchronize];
	
	[self updateCache:saveObject withKey:key];
}

-(BOOL) isNumber:(id) object
	 {
		 return [object isKindOfClass:[NSNumber class]];
	 }
-(BOOL) isString:(id) object
{
	return [object isKindOfClass:[NSString class]];
}
	 
//Asumption, value is number
-(void) saveValue:(id) object key:(id) key userDefault:(NSUserDefaults*) userDef
{
	id realKey = key;
	//Assumption: Key is either NSNumber or NSString
	if([key isKindOfClass:[NSNumber class]])
	{
		realKey = [(NSNumber*)key stringValue]; 
	}
	
	BOOL isNumber;
	
	if(!(isNumber = [self isNumber:object]) && ![self isString:object])
	{
		NSLog(@"Error saving. Only able to save numbers and strings right now");
		return;
	}
	[userDef removeObjectForKey:realKey];
	if(isNumber)
	{
		
		[userDef setFloat:[object floatValue] forKey:realKey];
	}
	else {
		
		[userDef setObject:object forKey:realKey];
	
	}
	[self updateCache:object withKey:key];
	//Examples of userDef usage for different values. Pretty straightforward
	//[userDef setObject:object forKey:realKey];
	//[userDef setFloat:lastInteraction forKey:lastOpening];
	//[userDef setBool:birthdayCelebrated forKey:bdayCeleb];
	//[userDef setInteger:1 forKey:haveSaved];
}
-(void)clearCache
{
	[_cachedSavedObjects removeAllObjects];
}
-(void) updateCache:(id) dValue withKey:(id) keyValue
{
	[_cachedSavedObjects removeObjectForKey:keyValue];
	//Should overwrite any previous keys
	[_cachedSavedObjects setObject:dValue forKey:keyValue];
}
@end
