//
//  AppEnumerations.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//




@protocol AchievementManager

-(void) addAchievementVariables:(NSMutableDictionary*) achieveDict;
-(NSMutableDictionary*) getAchievementVariables;
-(void) updateAchievementVariables:(ccTime) delta;

@end

@protocol AppSwitchScene
-(void)returningToApp;
-(void) leavingApp;
@end

@protocol SaveLoadState

-(void) addSaveStateValues:(NSMutableDictionary*) saveDict;

-(NSMutableArray*) saveStateKeys;
-(void) loadFromSaveStateValues:(NSMutableDictionary*) dict;

@end