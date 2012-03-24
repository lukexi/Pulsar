#import "OSCZeroConfDomain.h"
#import <pthread.h>



@class OSCManager;
@interface OSCZeroConfManager : NSObject <NSNetServiceBrowserDelegate> {
	NSNetServiceBrowser		*domainBrowser;
	
	NSMutableDictionary		*domainDict;
	pthread_rwlock_t		domainLock;
	
	OSCManager *			oscManager;
}

- (id) initWithOSCManager:(OSCManager *)m;

- (void) serviceRemoved:(NSNetService *)s;
- (void) serviceResolved:(NSNetService *)s;

//	NSNetServiceBrowser delegate methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didFindDomain:(NSString *)d moreComing:(BOOL)m;
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didNotSearch:(NSDictionary *)err;

@end
