//
//  main.m
//  NetworkStatusWarden
//  Version 1.0.4
//
//  by Mark J Swift
//
//  Calls an external commands via bash when network state changes between up and down
//  External commands are NetworkStateWarden-NetworkUp and NetworkStateWarden-NetworkDown

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface GlobalVars : NSObject
{
    NSString *_networkInterface;
}

+ (GlobalVars *)sharedInstance;

@property(strong, nonatomic, readwrite) NSString *networkInterface;

@end

@implementation GlobalVars

@synthesize networkInterface = _networkInterface;

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
        // Note not using _networkInterface = [[NSString alloc] init] as it doesnt return a useful object
        _networkInterface = nil;
    }
    return self;
}

@end


@interface NSString (ShellExecution)
- (NSString*)runAsCommand;
@end

@implementation NSString (ShellExecution)

- (NSString*)runAsCommand {
    NSPipe* pipe = [NSPipe pipe];
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", self]]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

@end

SCDynamicStoreRef session;

void NetworkStateCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info)
{
    CFIndex         i;
    CFIndex         changedKeyCount;
    CFStringRef		state_network_global_ipv4_KeyName = NULL;
    NSString        *primaryInterface = @"none";
    NSString        *previousInterface = @"none";
    
    NSString        * exepath = [[NSBundle mainBundle] executablePath];
    
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    // The key that we are interested in "State:/Network/Global/IPv4"
    state_network_global_ipv4_KeyName = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompGlobal, kSCEntNetIPv4);
    
    // Run through the list of changed keys (there should only be one - "State:/Network/Global/IPv4")
    changedKeyCount = CFArrayGetCount(changedKeys);
    for (i=0; i < changedKeyCount; i++) {
        CFStringRef changedKeyName = CFArrayGetValueAtIndex(changedKeys, i);
        
        // We are only interested in "State:/Network/Global/IPv4"
        if (CFStringCompare(changedKeyName, state_network_global_ipv4_KeyName, 0) == kCFCompareEqualTo) {
            
            // Get the previous primary interface from our global vars
            previousInterface=globals.networkInterface;
            
            // Get the /Network/Global/IPv4 Key property
            CFPropertyListRef changedKeyProp = SCDynamicStoreCopyValue(store, (CFStringRef) changedKeyName);
            
            // Get the current primary interface from the Key property
            if (changedKeyProp) {
                primaryInterface = [(__bridge NSDictionary *)changedKeyProp valueForKey:@"PrimaryInterface"];
            } else {
                primaryInterface = @"none";
            }
            
            // Set the current primary interface
            globals.networkInterface = primaryInterface;
            
            // Only do something if the primary interface value has changed
            if ([previousInterface compare:primaryInterface] != NSOrderedSame) {
                if ([primaryInterface compare:@"none"] == NSOrderedSame) {
                    [[NSString stringWithFormat:@"%@-NetworkDown %@", exepath, previousInterface] runAsCommand];
                    NSLog(@"Primary interface down: old %@, new %@", previousInterface, primaryInterface);
                } else {
                    [[NSString stringWithFormat:@"%@-NetworkUp %@", exepath, primaryInterface] runAsCommand];
                    NSLog(@"Primary interface up: old %@, new %@", previousInterface, primaryInterface);
                }
            }
            
            continue;
        }
        
    }
    CFRelease(state_network_global_ipv4_KeyName);
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        CFStringRef         key;
        CFMutableArrayRef	keys = NULL;
        CFMutableArrayRef	patterns = NULL;
        CFRunLoopSourceRef	rls;
        
        GlobalVars *globals = [GlobalVars sharedInstance];
        globals.networkInterface = @"none";
        
        SCDynamicStoreContext context = {0, NULL, NULL, NULL, NULL};
        session = SCDynamicStoreCreate(NULL, CFSTR("NetworkStateWarden"), NetworkStateCallback, &context);
        
        keys = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        patterns = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
        
        // Key to track changes to State:/Network/Global/IPv4
        
        key = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompGlobal, kSCEntNetIPv4);
        
        CFArrayAppendValue(keys, key);
        CFRelease(key);
        
        // If we were tracking changes via patterns, we would do something like this:
        //
        /* Pattern to track changes to State,/Network/Interface/[^/]+/Link */
        //key = SCDynamicStoreKeyCreate(NULL, CFSTR("%@/%@/%@/%@/%@"), kSCDynamicStoreDomainState, kSCCompNetwork, kSCCompInterface, kSCCompAnyRegex, kSCEntNetLink);
        //
        //CFArrayAppendValue(patterns, key);
        //CFRelease(key);
        
        SCDynamicStoreSetNotificationKeys(session, keys, patterns);
        CFRelease(keys);
        CFRelease(patterns);
        
        rls = SCDynamicStoreCreateRunLoopSource(NULL, session, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopCommonModes);
        CFRelease(rls);
        
        // Run the RunLoop
        
        CFRunLoopRun();
        
    }
    return 0;
}
