//
//  SUUpdateAlert.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	SUInstallUpdateChoice,
	SURemindMeLaterChoice,
	SUSkipThisVersionChoice
} SUUpdateAlertChoice;

@class WebView, SUAppcastItem, SUUtilities;
@interface SUUpdateAlert : NSWindowController {
	SUAppcastItem *updateItem;
	SUUtilities *utilities;
	id delegate;
	
	IBOutlet WebView *releaseNotesView;
	IBOutlet NSTextField *description;
	NSProgressIndicator *releaseNotesSpinner;
	BOOL webViewFinishedLoading;
}

- initWithAppcastItem:(SUAppcastItem *)item andUtilities:(SUUtilities *)aUtility;
- (void)setDelegate:delegate;

- (IBAction)installUpdate:sender;
- (IBAction)skipThisVersion:sender;
- (IBAction)remindMeLater:sender;

@end

@interface NSObject (SUUpdateAlertDelegate)
- (void)updateAlert:(SUUpdateAlert *)updateAlert finishedWithChoice:(SUUpdateAlertChoice)updateChoice;
@end