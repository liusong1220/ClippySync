//
//  AppDelegate.m
//  ClippyMacClient
//
//  Created by Al Pascual on 12/12/12.
//  Copyright (c) 2012 Esri. All rights reserved.
//

#import "AppDelegate.h"
#import "JSONRepresentation.h"
#import "CJSONSerializer.h"

@implementation AppDelegate

- (void) awakeFromNib
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSBundle *bundle = [NSBundle mainBundle];
    
    self.statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"sync-image" ofType:@"png"]];
    self.statusHighlighImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"sync-image_red" ofType:@"png"]];
    
    [self.statusItem setImage:self.statusImage];
    [self.statusItem setAlternateImage:self.statusHighlighImage];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setToolTip:@"Sync the clipboard"];
    
    self.bPaused = NO;
    self.clipboardTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerRunning:)  userInfo:nil repeats:YES];
    
    
}

- (void) timerRunning:(id)sender
{
    if ( self.bPaused == NO)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ( [defaults objectForKey:UsernameKey] != nil)
        {
            ServerProtocol *protocol = [[ServerProtocol alloc] init];
            NSString *clipboardText = [protocol getTextFromClipboard:[defaults objectForKey:UsernameKey] withPassword:[defaults objectForKey:PasswordKey] andSequenceNumber:self.lastNumber];
            
            NSError *error;
            NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:clipboardText error:&error];
            
            //todo
            NSDictionary *data = [theDictionary objectForKey:@"data"];
            NSArray *currentDictionaty = [data objectForKey:@"current_condition"];
            NSDictionary *temp = [currentDictionaty objectAtIndex:0];
            // F tempeture
            NSString *fTempeture = [temp objectForKey:@"temp_F"];
            id weatherDesc = [temp objectForKey:@"weatherDesc"];
            NSDictionary *weatherValues = [weatherDesc objectAtIndex:0];            // We are enable, start sync
            // Check on the server
//            string clipBoardText = protocol.GetTextFromClipboard(CredentialsStorage.Username, CredentialsStorage.Password, CredentialsStorage.LastNumber);
//            try
//            {
//                SyncItem item = JSONHelper.Deserialize<SyncItem>(clipBoardText);
//                
//                CredentialsStorage.LastNumber = item.SyncID;
//                CredentialsStorage.ClipboardData = item.ClipboardData;
//            }
//            catch { }
        }
    }
}


- (IBAction)loginPressed:(id)sender
{
    self.login = [[LoginWindowController alloc] initWithWindowNibName:@"LoginWindowController"];
    
    [self.login showWindow:self];
}
- (IBAction)pausePressed:(id)sender
{
    self.bPaused = !self.bPaused;
}
- (IBAction)optionsPressed:(id)sender
{
    self.options = [[OptionsWindowController alloc] initWithWindowNibName:@"OptionsWindowController"];
    
    [self.options showWindow:self];
}
- (IBAction)quitPresses:(id)sender
{
    // Hope this is how to close an app in Mac as well.
    exit(1);
}


@end
