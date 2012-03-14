//
//  main.m
//  CocosSteve
//
//  Created by Paul Szerlip on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil,
								   @"CocosBalloonRunnerAppDelegate");
	[pool release];
	return retVal;
}
