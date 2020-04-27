@import Foundation;

@class DPLDeepLink;
@class DPLRouteNormalizer;

@interface DPLRouteMatcher : NSObject

/**
 Initializes a route matcher.
 @param route The route to match.
 @return An route matcher instance.
 */
+ (instancetype)matcherWithRoute:(NSString *)route;


/**
 Matches a URL against the route and returns a deep link.
 @param url The url to be compared with the route.
 @return A DPLDeepLink instance if the URL matched the route, otherwise nil.
 */
- (DPLDeepLink *)deepLinkWithURL:(NSURL *)url;

/**
 Matches a URL against the route and returns a deep link. Additionally, an instance of
 DPLRoutePreprocessor may be passed to further normalize URL paths before being matched
 against the registered routes.
 @param url The url to be compared with the route.
 @param normalizer The URL normalizer to be run before the URL is matched against registered routes.
 @return A DPLDeepLink instance if the URL matched the route, otherwise nil.
*/
- (DPLDeepLink *)deepLinkWithURL:(NSURL *)url normalizer:(DPLRouteNormalizer *)normalizer;

@end
