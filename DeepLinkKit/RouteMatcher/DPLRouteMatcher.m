#import "DPLRouteMatcher.h"
#import "DPLDeepLink_Private.h"
#import "NSString+DPLTrim.h"
#import "DPLRegularExpression.h"
#import "DPLRouteNormalizer.h"

@interface DPLRouteMatcher ()

@property (nonatomic, copy)   NSString *scheme;
@property (nonatomic, strong) DPLRegularExpression *regexMatcher;

@end

@implementation DPLRouteMatcher

+ (instancetype)matcherWithRoute:(NSString *)route {
    return [[self alloc] initWithRoute:route];
}


- (instancetype)initWithRoute:(NSString *)route {
    if (![route length]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        NSArray *parts = [route componentsSeparatedByString:@"://"];
        _scheme = parts.count > 1 ? [parts firstObject] : nil;
        _regexMatcher = [DPLRegularExpression regularExpressionWithPattern:[parts lastObject]];
    }
    
    return self;
}

- (DPLDeepLink *)deepLinkWithURL:(NSURL *)url {
    return [self deepLinkWithURL:url normalizer:nil];
}

- (DPLDeepLink *)deepLinkWithURL:(NSURL *)url normalizer:(DPLRouteNormalizer *)normalizer {
    DPLDeepLink *deepLink = [[DPLDeepLink alloc] initWithURL:url];

    if (self.scheme.length && ![self.scheme isEqualToString:deepLink.URL.scheme]) {
        return nil;
    }

    // use resource specifier because URL.path automatically decodes the value.
    // resourceSpecifier returns "//host/path?queryParams", so the first two forward slashes
    // need to be skipped.
    NSString *deepLinkString = [deepLink.URL.resourceSpecifier substringFromIndex:2];

    if (deepLinkString) {
        // ignore query parameters.
        deepLinkString = [[deepLinkString componentsSeparatedByString:@"?"] firstObject];

        // sanitize trailing slash if any.
        NSArray *components = [deepLinkString componentsSeparatedByString:@"/"];
        NSPredicate *nonEmptyStringsPredicate = [NSPredicate predicateWithFormat:@"length > 0"];
        NSArray *filtered = [components filteredArrayUsingPredicate:nonEmptyStringsPredicate];
        deepLinkString = [filtered componentsJoinedByString:@"/"];
    }

    if (normalizer) {
        deepLinkString = [normalizer normalizeRoute:(deepLinkString ?: @"") forDeepLink:deepLink];
    }

    DPLMatchResult *matchResult = [self.regexMatcher matchResultForString:deepLinkString];
    if (!matchResult.isMatch) {
        return nil;
    }

    deepLink.routeParameters = matchResult.namedProperties;

    return deepLink;
}

@end
