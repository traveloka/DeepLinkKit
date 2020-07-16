#import "DPLRouteNormalizer.h"
#import "DPLDeepLink.h"

@interface DPLRouteNormalizer ()

@property (nonatomic, strong) NSString *extraHostPattern;

@end

@implementation DPLRouteNormalizer

- (instancetype)init {
    return [self initWithExtraHostPattern:@""];
}

- (instancetype)initWithExtraHostPattern:(NSString *)patternString {
    self = [super init];

    _extraHostPattern = patternString ?: @"";

    return self;
}

- (NSString *)normalizeRoute:(NSString *)routeString forDeepLink:(DPLDeepLink *)deepLink {
    if (routeString.length == 0) {
        return @"/";
    }

    NSString *currentRoute = routeString;

    // process universal link host if needed.
    if (deepLink.isUniversalLink) {
        currentRoute = [self excludeHostFromRoute:routeString];
    }

    if (currentRoute.length == 0) {
        return @"/";
    }

    // check if the current route already contains forward slash.
    NSString *firstLetter = [currentRoute substringToIndex:1];

    if (![firstLetter isEqualToString:@"/"]) {
        currentRoute = [NSString stringWithFormat:@"/%@", currentRoute];
    }

    return currentRoute;
}

#pragma mark - Private

- (NSString *)excludeHostFromRoute:(NSString *)routeString {
    // remove host from universal links.
    NSMutableArray<NSString *> *segments = [routeString componentsSeparatedByString:@"/"].mutableCopy;
    [segments removeObjectAtIndex:0];

    // append forward slash to maintain consistency with the result when excludeHost option is off.
    NSString *resultString = [segments componentsJoinedByString:@"/"];

    if (self.extraHostPattern.length == 0) {
        return resultString;
    }

    // ensure that the pattern string contains start-of-string symbol or add if it doesn't exist.
    NSString *pattern = self.extraHostPattern;
    NSString *firstLetter = [pattern substringToIndex:1];
    if (![firstLetter isEqualToString:@"^"]) {
        pattern = [NSString stringWithFormat:@"^%@", pattern];
    }

    // ensure that the pattern ends with forward slash.
    NSString *lastLetter = [pattern substringFromIndex:pattern.length-1];
    if (![lastLetter isEqualToString:@"/"]) {
        pattern = [NSString stringWithFormat:@"%@/", pattern];
    }

    // convert pattern string to NSRegularExpression.
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (error) {
        // if the regex is invalid, then just return result string immediately.
        return resultString;
    }

    return [regex stringByReplacingMatchesInString:resultString
                                           options:0
                                             range:NSMakeRange(0, resultString.length)
                                      withTemplate:@""];
}

@end
