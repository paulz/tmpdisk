//
//  TmpDiskStatusBarListener.m
//  TmpDisk
//
//  Created by Timothy Marks on 10/10/11.
//  Copyright (c) 2011 Ink Scribbles Pty Ltd.
//
//  This file is part of TmpDisk.
// 
//  TmpDisk is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  TmpDisk is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with TmpDisk.  If not, see <http://www.gnu.org/licenses/>.

#import "TmpDiskStatusBarListener.h"

@implementation TmpDiskStatusBarListener


- (void)awakeFromNib {
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
        UInt32 seedValue;
        //Retrieve the list of Login Items and cast them to
        // a NSArray so that it will be easier to iterate.
        NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
        
        for(int i = 0 ; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)loginItemsArray[i];
            //Resolve the item with URL
            url = LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL);
            if (url) {
                NSString * urlPath = [(__bridge NSURL*)url path];
                if ([urlPath compare:appPath] == NSOrderedSame){
                    
                    // We have a login startup item so set the menu to checked
                    [startLoginMenuItem setState:NSOnState];
                    
                }
            }
        }
    }

    CFRelease(loginItems);
    
}

- (IBAction)newTmpDisk:(id)sender {
    
    if ([ntdwc window] == nil) {
        
        ntdwc = [[NSWindowController alloc] initWithWindowNibName:@"NewTmpDisk"];
        
        
    }
    
    [[ntdwc window] makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    
}

- (IBAction)quit:(id)sender {
    
    [NSApp terminate:nil];
    
}

- (void )runModalAlertWithMessageText:(NSString *)message informativeText:(NSString *)info {
    NSAlert *alert = [NSAlert new];
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = message;
    alert.informativeText = info;
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (IBAction)about:(id)sender {
    [self runModalAlertWithMessageText:@"About TmpDisk"
                       informativeText:@"TmpDisk was created by @imothee of Ink Scribbles Pty Ltd to help easily create and manage Ram Disks."];
}

- (IBAction)helpCenter:(id)sender {
    [self runModalAlertWithMessageText:@"TmpDisk Help"
                       informativeText:@"Ram Disks are temporary disks that use your RAM (Memory) for storage. They are incredibly fast and can be very useful when used for performance or temporary files."];
}


/***
 Show the AutoCreate Window
 */
- (IBAction)manageAutoCreate:(id)sender {
    
    if ([acmwc window] == nil) {
        
        acmwc = [[NSWindowController alloc] initWithWindowNibName:@"AutoCreateManager"];
        
    }
    
    [[acmwc window] makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    
}

/***
 Toggle whether the Application should start on Login
 */
- (IBAction)startLogin:(id)sender {
    
    NSMenuItem *button = (NSMenuItem*) sender;
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
    if (button.state == NSOffState) {
        
        // Button is off, so switch to on and add to LoginItems
        [button setState:NSOnState];
        
        if (loginItems) {
            
            //Insert an item to the list.
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                         kLSSharedFileListItemLast, NULL, NULL,
                                                                         url, NULL, NULL);
            if (item){
                CFRelease(item);
            }
            
        }
    } else {
        
        // Button is on, so switch to on and remove entry from LoginItems
        [button setState:NSOffState];
        
        // Remove the login startup item
        if (loginItems) {
            UInt32 seedValue;
            //Retrieve the list of Login Items and cast them to
            // a NSArray so that it will be easier to iterate.
            NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
            
            for(int i = 0 ; i< [loginItemsArray count]; i++){
                LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)loginItemsArray[i];
                //Resolve the item with URL
                url = LSSharedFileListItemCopyResolvedURL(itemRef, 0, NULL);
                if (url) {
                    NSString * urlPath = [(__bridge NSURL*)url path];
                    if ([urlPath compare:appPath] == NSOrderedSame){
                        LSSharedFileListItemRemove(loginItems,itemRef);
                    }
                }
            }
        }
        
        
    }
    
    CFRelease(loginItems);
}

@end
