#include <ApplicationServices/ApplicationServices.h>
#include <CoreGraphics/CGEventTypes.h>
#include <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create a status bar item (tray item)
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // Load the app icon from the Resources folder using the correct path
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"WindowSwitchRemap" ofType:@"icns"];
    if (iconPath) {
        NSURL *iconURL = [NSURL fileURLWithPath:iconPath];
        NSImage *appIcon = [[NSImage alloc] initWithContentsOfURL:iconURL]; // Load from NSURL
        if (appIcon) {
            [appIcon setSize:NSMakeSize(18, 18)]; // Resize the icon
            self.statusItem.button.image = appIcon; // Set the icon for the status bar item
        } else {
            NSLog(@"Failed to load app icon from URL: %@", iconURL);
        }
    } else {
        NSLog(@"Icon file not found at expected path.");
    }
    
    self.statusItem.button.action = @selector(statusBarClicked:);
    
    // Optionally set a custom title if needed
    self.statusItem.button.title = @"CtrlTab"; // This is the text shown on the tray icon
    
    // Add a menu to the status bar item
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    self.statusItem.menu = menu;
}

- (void)statusBarClicked:(id)sender {
    // Handle the click event, for example, simulate key presses or show a menu
    NSLog(@"Status bar item clicked!");
}

@end

// Define key codes
#define kVK_Command 55  // Command key
#define kVK_Tab 48      // Tab key
#define kVK_Shift_L 56  // Left Shift key
#define kVK_Shift_R 60  // Right Shift key

// Function to send Command + Tab keypress event
void sendCommandTabEvent(const bool shift) {
    // Create the event source
    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);

    // Command key down
    CGEventRef commandDown = CGEventCreateKeyboardEvent(src, (CGKeyCode)kVK_Command, true);
    CGEventSetFlags(commandDown, kCGEventFlagMaskCommand);
    CGEventPost(kCGHIDEventTap, commandDown);
    CFRelease(commandDown);
    
    // Tab key down
    CGEventRef tabDown = CGEventCreateKeyboardEvent(src, (CGKeyCode)kVK_Tab, true);
    if (shift) {
        // Add Shift key flag to Tab key
        CGEventSetFlags(tabDown, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
    } else {
        CGEventSetFlags(tabDown, kCGEventFlagMaskCommand);
    }
    CGEventPost(kCGHIDEventTap, tabDown);
    CFRelease(tabDown);

    // Tab key up
    CGEventRef tabUp = CGEventCreateKeyboardEvent(src, (CGKeyCode)kVK_Tab, false);
    CGEventSetFlags(tabUp, kCGEventFlagMaskCommand);
    if (shift) {
        CGEventSetFlags(tabUp, kCGEventFlagMaskCommand | kCGEventFlagMaskShift);
    } else {
        CGEventSetFlags(tabUp, kCGEventFlagMaskCommand);
    }
    CGEventPost(kCGHIDEventTap, tabUp);
    CFRelease(tabUp);

    // Release the event source
    CFRelease(src);
}

// Event callback to intercept key events
CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userInfo) {
    // Check if the key pressed is Cmd + Tab
    if (type == kCGEventKeyDown) {
        CGEventFlags keyFlags = CGEventGetFlags(event);
        int keyCode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        
        // Keycode for Tab is 48
        if (keyFlags & kCGEventFlagMaskControl && keyCode == kVK_Tab) {
            // Simulate Command + Tab, optionally shift if pressed, too
            const bool isShift = keyFlags & kCGEventFlagMaskShift;
            sendCommandTabEvent(isShift);
            // Return NULL to prevent the default Ctrl + Tab behavior
            return NULL;
        }
    }
    return event;
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Initialize the Cocoa application
        NSApplication *app = [NSApplication sharedApplication];
        
        // Create and set the AppDelegate
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        [app setDelegate:appDelegate];
        
        // Create an event tap to listen to key events globally
        CGEventMask eventMask = (1 << kCGEventKeyDown);
        printf("Initializing event tap.\n");
        fflush(stdout);

        CFMachPortRef eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, eventCallback, NULL);
        
        if (!eventTap) {
            printf("Failed to create event tap.\n");
            fflush(stdout);
            return 1;
        }

        // Create a run loop to keep the event tap active
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(eventTap, true);
        
        // Start the Cocoa event loop
        [app run];  // This keeps the app alive and the tray item visible
    }

    return 0;
}
