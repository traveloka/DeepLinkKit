#import <Foundation/Foundation.h>

@class DPLDeepLink;

NS_ASSUME_NONNULL_BEGIN

@interface DPLRouteNormalizer : NSObject

/**
 Initialize normalizer instance with optional extra host pattern.
 */
- (instancetype)initWithExtraHostPattern:(nullable NSString *)patternString;

/**
 Normalize route strings before being matched with registered routes.
 @param routeString The route string processed from `DPLRouteMatcher`.
 @param deepLink The `DPLDeepLink` object containing original URL.

 @discussion The normalization ensures that routes coming from both deep links and universal
 links have the same format. Hosts from universal links are removed during normalization. Example:
 @code
 https://dpl.io/foo/12345 --> /foo/12345
 dpl://foo/12345          --> /foo/12345
 @endcode
 Additionally, if an extra host pattern is provided, normalization proceeds to trim the route
 further. For example, given universal link https://dpl.io/site/foo/12345 and additional host
 pattern `site`, then the normalization output will be /foo/12345.
 */
- (NSString *)normalizeRoute:(NSString *)routeString forDeepLink:(DPLDeepLink *)deepLink;

@end

NS_ASSUME_NONNULL_END
