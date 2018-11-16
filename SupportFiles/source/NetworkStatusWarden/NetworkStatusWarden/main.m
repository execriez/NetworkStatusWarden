//
//  main.m
//  NetworkStatusWarden
//  Version 1.0.7
//
//  by Mark J Swift
//
//  Calls external commands via bash when a network interface comes up or goes down
//  and when the primary network service comes up or goes down
//
//  External commands are
//    NetworkStatusWarden-InterfaceUp
//    NetworkStatusWarden-InterfaceDown
//    NetworkStatusWarden-NetworkUp
//    NetworkStatusWarden-NetworkDown

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface GlobalVars : NSObject
{
    NSString *_PrimaryServiceSetting;
    NSString *_PrimaryInterfaceSetting;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString *PrimaryServiceSetting;
@property(strong, nonatomic, readwrite) NSString *PrimaryInterfaceSetting;

@end

@implementation GlobalVars

@synthesize PrimaryServiceSetting = _PrimaryServiceSetting;
@synthesize PrimaryInterfaceSetting = _PrimaryInterfaceSetting;

+ (GlobalVars *)sharedInstance {
    static GlobalVars *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // Note not using _PrimaryInterfaceSetting = [[NSString alloc] init] as it doesnt return a useful object
        _PrimaryServiceSetting = nil;
        _PrimaryInterfaceSetting = nil;
    }
    return self;
}

@end


@interface NSString (ShellExecution)
- (NSString*)runAsCommand;
@end

@implementation NSString (ShellExecution)

- (NSString*)runAsCommand {
//  NSPipe* pipe = [NSPipe pipe];
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", self]]];
//  [task setStandardOutput:pipe];
    
//  NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
//  return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    return NULL;
}

@end

SCDynamicStoreRef PrimaryServiceSession;
SCDynamicStoreRef NetworkInterfaceSession;

void PrimaryServiceStateCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info)
{
    CFIndex         i;
    CFIndex         changedKeyCount;
    CFStringRef		state_network_global_ipv4_KeyName = NULL;
    
    NSString        *PrevPrimaryServiceValue = NULL;
    NSString        *PrevPrimaryInterfaceValue = NULL;
    
    NSString        *CurrPrimaryServiceValue = NULL;
    NSString        *CurrPrimaryInterfaceValue = NULL;
    
    NSString        * exepath = [[NSBundle mainBundle] executablePath];
    
    //    NSLog(@"DEBUG PrimaryServiceStateCallback:");
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    // The key that we are interested in "State:/Network/Global/IPv4"
    state_network_global_ipv4_KeyName = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompGlobal, kSCEntNetIPv4);
    
    // Run through the list of changed keys (there should only be one)
    changedKeyCount = CFArrayGetCount(changedKeys);
    for (i=0; i < changedKeyCount; i++) {
        CFStringRef changedKeyName = CFArrayGetValueAtIndex(changedKeys, i);
        
        // We are only interested in "State:/Network/Global/IPv4"
        if (CFStringCompare(changedKeyName, state_network_global_ipv4_KeyName, 0) == kCFCompareEqualTo) {
            
            // NSLog(@"DEBUG PrimaryServiceStateCallback: changedKeyName: %@", changedKeyName);
            
            // Get the previous primary interface settings from our global vars
            PrevPrimaryServiceValue=globals.PrimaryServiceSetting;
            if (PrevPrimaryServiceValue == NULL) {
                PrevPrimaryServiceValue = @"unset";
            }
            
            PrevPrimaryInterfaceValue=globals.PrimaryInterfaceSetting;
            if (PrevPrimaryInterfaceValue == NULL) {
                PrevPrimaryInterfaceValue = @"unset";
            }
            
            // NSLog(@"DEBUG PrimaryServiceStateCallback: PrevPrimaryServiceValue: %@", PrevPrimaryServiceValue);
            // NSLog(@"DEBUG PrimaryServiceStateCallback: PrevPrimaryInterfaceValue: %@", PrevPrimaryInterfaceValue);
            
            // Get the /Network/Global/IPv4 Key property
            CFPropertyListRef changedKeyProp = SCDynamicStoreCopyValue(store, (CFStringRef) changedKeyName);
            
            // Get the current primary interface from the Key property
            if (changedKeyProp != NULL) {
                CurrPrimaryServiceValue = [(__bridge NSDictionary *)changedKeyProp valueForKey:@"PrimaryService"];
                CurrPrimaryInterfaceValue = [(__bridge NSDictionary *)changedKeyProp valueForKey:@"PrimaryInterface"];
            }
            if (CurrPrimaryServiceValue == NULL) {
                CurrPrimaryServiceValue = @"unset";
            }
            if (CurrPrimaryInterfaceValue == NULL) {
                CurrPrimaryInterfaceValue = @"unset";
            }
            
            // Set the current primary interface globals
            globals.PrimaryServiceSetting = CurrPrimaryServiceValue;
            globals.PrimaryInterfaceSetting = CurrPrimaryInterfaceValue;
            
            //NSLog(@"DEBUG PrimaryServiceStateCallback: CurrPrimaryServiceValue: %@", CurrPrimaryServiceValue);
            //NSLog(@"DEBUG PrimaryServiceStateCallback: CurrPrimaryInterfaceValue: %@", CurrPrimaryInterfaceValue);
            
            // Only do something if the primary interface value has changed
            if ([CurrPrimaryServiceValue compare:PrevPrimaryServiceValue] != NSOrderedSame) {
                // if the previous service value was set, then this change means that the previous service has gone down
                if ([PrevPrimaryServiceValue compare:@"unset"] != NSOrderedSame) {
                    [[NSString stringWithFormat:@"%@-NetworkDown %@ %@", exepath, PrevPrimaryServiceValue, PrevPrimaryInterfaceValue] runAsCommand];
                    NSLog(@"Primary network service down: %@ (%@), [ new %@ (%@) ]", PrevPrimaryServiceValue, PrevPrimaryInterfaceValue, CurrPrimaryServiceValue, CurrPrimaryInterfaceValue);
                }
                // if the current service value is set, then this change means this service has just come up
                if ([CurrPrimaryServiceValue compare:@"unset"] != NSOrderedSame) {
                    [[NSString stringWithFormat:@"%@-NetworkUp %@ %@", exepath, CurrPrimaryServiceValue, CurrPrimaryInterfaceValue] runAsCommand];
                    NSLog(@"Primary network service up: %@ (%@), [ old %@ (%@) ]", CurrPrimaryServiceValue, CurrPrimaryInterfaceValue, PrevPrimaryServiceValue, PrevPrimaryInterfaceValue);
                }
            }
            
            continue;
        }
        
    }
    CFRelease(state_network_global_ipv4_KeyName);
    
}

void NetworkInterfaceStateCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info)
{
    CFIndex         i;
    CFIndex         changedKeyCount;
    CFStringRef		state_network_interface_KeyName = NULL;
    
    NSString        * exepath = [[NSBundle mainBundle] executablePath];
    
    CFArrayRef		cfarray;
    CFStringRef     interfaceName		= NULL;
    
    CFBooleanRef	LinkActiveValue = NULL;
    
    //    NSLog(@"DEBUG NetworkInterfaceStateCallback:");
    
    state_network_interface_KeyName = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompInterface);
    
    // Run through the list of changed keys (there should only be one)
    changedKeyCount = CFArrayGetCount(changedKeys);
    for (i=0; i < changedKeyCount; i++) {
        CFStringRef changedKeyName = CFArrayGetValueAtIndex(changedKeys, i);
        
        //        NSLog(@"DEBUG NetworkInterfaceStateCallback: changedKeyName: %@", changedKeyName);
        
        // The key that we are interested in "State:/Network/???/Link"
        if ((CFStringHasPrefix(changedKeyName, state_network_interface_KeyName)) && (CFStringHasSuffix(changedKeyName, kSCEntNetLink))){
            
            // changed key is something like this State:/Network/Interface/.../Link
            cfarray = CFStringCreateArrayBySeparatingStrings(NULL, changedKeyName, CFSTR("/"));
            if (cfarray) {
                interfaceName = CFArrayGetValueAtIndex(cfarray, 3);
                CFRelease(cfarray);
            }
            
            //           NSLog(@"DEBUG NetworkInterfaceStateCallback: interfaceName: %@", interfaceName);
            
            // Get the /Network/???/Link Key property
            CFPropertyListRef changedKeyProp = SCDynamicStoreCopyValue(store, (CFStringRef) changedKeyName);
            
            if (changedKeyProp != NULL) {
                LinkActiveValue = CFDictionaryGetValue(changedKeyProp, kSCPropNetLinkActive);
            }
            
            if (LinkActiveValue != NULL) {
                if (LinkActiveValue == kCFBooleanTrue) {
                    [[NSString stringWithFormat:@"%@-InterfaceUp %@", exepath, interfaceName] runAsCommand];
                    NSLog(@"Interface up: %@", interfaceName);
                }   else    {
                    [[NSString stringWithFormat:@"%@-InterfaceDown %@", exepath, interfaceName] runAsCommand];
                    NSLog(@"Interface down: %@", interfaceName);
                }
            }
            
        }
    }
    CFRelease(state_network_interface_KeyName);
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        CFStringRef         PrimaryInterfaceWatchKey;
        CFMutableArrayRef	PrimaryInterfaceTrackingKeys = NULL;
        CFMutableArrayRef	PrimaryInterfaceTrackingPatterns = NULL;
        CFRunLoopSourceRef	PrimaryServiceSessionRunLoopSource;
        
        CFStringRef         NetworkInterfaceWatchPattern;
        CFMutableArrayRef	NetworkInterfaceTrackingKeys = NULL;
        CFMutableArrayRef	NetworkInterfaceTrackingPatterns = NULL;
        CFRunLoopSourceRef	NetworkInterfaceSessionRunLoopSource;
        
        GlobalVars *globals = [GlobalVars sharedInstance];
        globals.PrimaryServiceSetting = @"unset";
        globals.PrimaryInterfaceSetting = @"unset";
        
        // --- track changes to the primary network service ---
        
        SCDynamicStoreContext PrimaryInterfaceContext = {0, NULL, NULL, NULL, NULL};
        PrimaryServiceSession = SCDynamicStoreCreate(NULL, CFSTR("NetworkStatusWarden-PrimaryInterface"), PrimaryServiceStateCallback, &PrimaryInterfaceContext);
        
        PrimaryInterfaceTrackingKeys = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        PrimaryInterfaceTrackingPatterns = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        
        // Key to track changes to State:/Network/Global/IPv4
        
        PrimaryInterfaceWatchKey = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompGlobal, kSCEntNetIPv4);
        
        CFArrayAppendValue(PrimaryInterfaceTrackingKeys, PrimaryInterfaceWatchKey);
        CFRelease(PrimaryInterfaceWatchKey);
        
        SCDynamicStoreSetNotificationKeys(PrimaryServiceSession, PrimaryInterfaceTrackingKeys, PrimaryInterfaceTrackingPatterns);
        CFRelease(PrimaryInterfaceTrackingKeys);
        CFRelease(PrimaryInterfaceTrackingPatterns);
        
        // Add callback to run loop
        
        PrimaryServiceSessionRunLoopSource = SCDynamicStoreCreateRunLoopSource(NULL, PrimaryServiceSession, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), PrimaryServiceSessionRunLoopSource, kCFRunLoopCommonModes);
        CFRelease(PrimaryServiceSessionRunLoopSource);
        
        // --- track changes to network interfaces ---
        
        SCDynamicStoreContext NetworkInterfaceContext = {0, NULL, NULL, NULL, NULL};
        NetworkInterfaceSession = SCDynamicStoreCreate(NULL, CFSTR("NetworkStatusWarden-NetworkInterface"), NetworkInterfaceStateCallback, &NetworkInterfaceContext);
        
        NetworkInterfaceTrackingKeys = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        NetworkInterfaceTrackingPatterns = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        
        // Pattern to track changes to State:/Network/Interface/[^/]+/Link
        
        NetworkInterfaceWatchPattern = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompInterface, kSCCompAnyRegex, kSCEntNetLink);
        
        CFArrayAppendValue(NetworkInterfaceTrackingPatterns, NetworkInterfaceWatchPattern);
        CFRelease(NetworkInterfaceWatchPattern);
        
        SCDynamicStoreSetNotificationKeys(NetworkInterfaceSession, NetworkInterfaceTrackingKeys, NetworkInterfaceTrackingPatterns);
        CFRelease(NetworkInterfaceTrackingKeys);
        CFRelease(NetworkInterfaceTrackingPatterns);
        
        // Add callback to run loop
        
        NetworkInterfaceSessionRunLoopSource = SCDynamicStoreCreateRunLoopSource(NULL, NetworkInterfaceSession, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), NetworkInterfaceSessionRunLoopSource, kCFRunLoopCommonModes);
        CFRelease(NetworkInterfaceSessionRunLoopSource);
        
        // ---
        
        // Run the RunLoop
        
        CFRunLoopRun();
        
    }
    return 0;
}
