//
//  PhysicsManager.m
//  CocosBalloonRunner
//
//  Created by Paul Szerlip on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhysicsManager.h"
#import "SynthesizeSingleton.h"
#import "SpaceManagerCocos2d.h"
@interface PhysicsManager()
-(void) ensureInit;
@end


@implementation PhysicsManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PhysicsManager);


-(id) init
{
	if((self = [super init]))
	{
		physicsSpace = nil;
		[self ensureInit];
	}
	return self;
}
- (void)dealloc {
    

	[spaceManager release];
	[super dealloc];
}
-(void) ensureInit
{
	//if(physicsSpace)
	//	return;
	physicsSpaces = [[NSMutableArray alloc]initWithCapacity:4];
	spaceManagers = [[NSMutableArray alloc]initWithCapacity:4];
	
	//Change depending on the device

    speedMod = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0f : 1.0f;
	//speedMod = 1.0f;
	
	[self createNewSpace];
	
	//cpInitChipmunk();
	//physicsSpace = cpSpaceNew();
//	cpSpaceResizeStaticHash(physicsSpace, 400.0f, 40);
//	cpSpaceResizeActiveHash(physicsSpace, 100, 600);
//	
//	
//	//physicsSpace->elasticIterations = physicsSpace->iterations;
//	
//	spaceManager = [[SpaceManagerCocos2d alloc] initWithSpace:physicsSpace];
//	physicsSpace->gravity = ccp(0, 0);
//	physicsSpace->damping = .9;
//	[spaceManager setCleanupBodyDependencies:YES];
//	
//	[physicsSpaces addObject:physicsSpace];
//	[spaceManagers addObject:spaceManager];
	
}
-(void) createNewSpace
{
	physicsSpace = cpSpaceNew();
	cpSpaceResizeStaticHash(physicsSpace, 400.0f, 40);
	cpSpaceResizeActiveHash(physicsSpace, 100, 600);
	
	
	//physicsSpace->elasticIterations = physicsSpace->iterations;
	
	spaceManager = [[SpaceManagerCocos2d alloc] initWithSpace:physicsSpace];
	physicsSpace->gravity = ccp(0, 0);
	physicsSpace->damping = .9;
	//[spaceManager setCleanupBodyDependencies:YES];
	[physicsSpaces addObject:[NSValue valueWithPointer:physicsSpace]];
	[spaceManagers addObject:spaceManager];
}
-(void) popLastSpace
{
	
	[spaceManager release];
	physicsSpace = nil;
	
	[physicsSpaces removeLastObject];
	[spaceManagers removeLastObject];
	
	
	physicsSpace = (cpSpace*)[[physicsSpaces lastObject]pointerValue];
	spaceManager = [spaceManagers lastObject];
	
}
-(SpaceManager*) spaceManager
{
	return spaceManager;
}
-(CGFloat) speedModifier
{
	return speedMod;
}
-(CGFloat) speed:(CGFloat) oldSpeed
{
	return oldSpeed*speedMod;
}
-(void) updatePhysics:(ccTime) delta withCallback:(void*)cb
{
	//can do this smarter if we'd like
	//cpSpaceStep(physicsSpace, delta);
	if(delta > 0.0f)
	[spaceManager step:delta];
	//int steps = 2;
//	
//	
//	CGFloat dt = delta/(CGFloat)steps;
//	
//	for(int i=0; i<steps; i++){
//		cpSpaceStep(physicsSpace, dt);
//	}
//	cpSpaceHashEach(physicsSpace->activeShapes, cb, nil);
//	cpSpaceHashEach(physicsSpace->staticShapes, cb, nil);
}
-(cpSpace*) space
{
	if(!physicsSpace)
	{
		[self ensureInit];
	}
	return physicsSpace;
}
@end
