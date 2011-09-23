//
//	PowerSource.m
//	ControlPlane
//
//	Created by David Jennes on 21/09/11.
//	Copyright 2011. All rights reserved.
//

#import "KVOAdditions.h"
#import "PowerSource.h"
#import "Rule.h"
#import "SourcesManager.h"
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>

static void sourceChange(void *info);

@implementation PowerSource

registerSource(PowerSource)
@synthesize status = m_status;

- (id) init {
	self = [super init];
	ZAssert(self, @"Unable to init super '%@'", NSStringFromClass(super.class));
	
	self.status = kPowerUnknown;
	m_runLoopSource = nil;
	
	return self;
}

#pragma mark - Required implementation of 'Source' class

- (void) addObserver: (Rule *) rule {
	SEL selector = NSSelectorFromString(@"statusChangedWithOld:andNew:");
	
	[self addObserver: rule
		   forKeyPath: @"status"
			  options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			 selector: selector];
}

- (void) removeObserver: (Rule *) rule {
	[self removeObserver: rule forKeyPath: @"status" selector: nil];
}

#pragma mark - CoreAudio stuff

- (void) registerCallback {
	// register
	m_runLoopSource = IOPSNotificationCreateRunLoopSource(sourceChange, self);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), m_runLoopSource, kCFRunLoopDefaultMode);
}

- (void) unregisterCallback {
	// Unregister listener
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), m_runLoopSource, kCFRunLoopDefaultMode);
	CFRelease(m_runLoopSource);
	
	self.status = kPowerUnknown;
}

- (void) checkData {
	BOOL onBattery = YES;
	CFTypeRef source;
	
	// get list of power sources
	CFTypeRef blob = IOPSCopyPowerSourcesInfo();
	NSArray *list = [(NSArray *) IOPSCopyPowerSourcesList(blob) autorelease];
	
	// loop through list
	NSEnumerator *en = [list objectEnumerator];
	while ((source = [en nextObject])) {
		NSDictionary *dict = (NSDictionary *) IOPSGetPowerSourceDescription(blob, source);
		
		if ([[dict valueForKey: @kIOPSPowerSourceStateKey] isEqualToString: @kIOPSACPowerValue])
			onBattery = NO;
	}
	CFRelease(blob);
	
	// store it
	self.status = (onBattery ? kPowerBattery : kPowerAC);
}

static void sourceChange(void *info) {
	PowerSource *src = (PowerSource *) info;
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[src checkData];
	[pool release];
}

@end