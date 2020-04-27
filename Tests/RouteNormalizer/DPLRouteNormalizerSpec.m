#import "DPLRouteNormalizer.h"
#import "DPLDeepLink.h"
#import "DPLDeepLink_Private.h"

SpecBegin(DPLRouteNormalizer)


describe(@"Deep Link Normalization", ^{

    __block NSURL *url = [NSURL URLWithString:@"dpl://foo/bar/12345"];
    __block DPLDeepLink *deepLink = [[DPLDeepLink alloc] initWithURL:url];
    __block NSString *route = @"foo/bar/12345";
    __block NSString *expectedRoute = @"/foo/bar/12345";

    context(@"WITHOUT extra host pattern", ^{

        __block DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] init];

        it(@"returns route WITH forward slash", ^{
            NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
            expect(result).to.equal(expectedRoute);
        });

    });

    context(@"WITH extra host pattern", ^{

        __block DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] initWithExtraHostPattern:@"site"];

        it(@"should NOT affect deep link routes", ^{
            NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
            expect(result).to.equal(expectedRoute);
        });

    });

});

describe(@"Universal Link Normalization", ^{

    __block NSURL *url = [NSURL URLWithString:@"https://dpl.io/sites/foo/site/12345"];
    __block DPLDeepLink *deepLink = [[DPLDeepLink alloc] initWithURL:url];
    __block NSString *route = @"dpl.io/sites/foo/site/12345";

    context(@"WITHOUT extra host pattern", ^{

        __block DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] init];

        it(@"returns route WITHOUT host", ^{
            NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
            expect(result).to.equal(@"/sites/foo/site/12345");
        });

    });

    context(@"with matching extra host pattern", ^{

        context(@"given NO start-of-string and NO trailing slash", ^{

            it(@"returns route excluding host and any matching host pattern", ^{
                NSString *pattern = @"sites";
                DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] initWithExtraHostPattern:pattern];
                NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
                expect(result).to.equal(@"/foo/site/12345");
            });

        });

        context(@"given NO start-of-string but with trailing slash", ^{

            it(@"returns route excluding host and any matching host pattern", ^{
                NSString *pattern = @"sites/";
                DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] initWithExtraHostPattern:pattern];
                NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
                expect(result).to.equal(@"/foo/site/12345");
            });

        });

        context(@"given start-of-string and NO trailing slash", ^{

            it(@"returns route excluding host and any matching host pattern", ^{
                NSString *pattern = @"^sites";
                DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] initWithExtraHostPattern:pattern];
                NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
                expect(result).to.equal(@"/foo/site/12345");
            });

        });

        context(@"given start of string and trailing slash", ^{

            it(@"returns route excluding host and any matching host pattern", ^{
                NSString *pattern = @"^sites/";
                DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] initWithExtraHostPattern:pattern];
                NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
                expect(result).to.equal(@"/foo/site/12345");
            });

        });

    });

    context(@"with non-matching extra host pattern", ^{

        it(@"returns route WITHOUT host and WITHOUT extra host pattern", ^{
            NSString *pattern = @"site";
            DPLRouteNormalizer *normalizer = [[DPLRouteNormalizer alloc] initWithExtraHostPattern:pattern];
            NSString *result = [normalizer normalizeRoute:route forDeepLink:deepLink];
            expect(result).to.equal(@"/sites/foo/site/12345");
        });
    });

});


SpecEnd
