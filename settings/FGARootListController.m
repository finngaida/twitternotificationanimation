#include "FGARootListController.h"

@implementation FGARootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }
    
    return _specifiers;
}

- (void)respring {
    system("killall -9 SpringBoard");
}

- (void)twitter {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:[NSURL URLWithString:@"twitter://fga"]]) {
        [app openURL:[NSURL URLWithString:@"twitter://user?screen_name=fga"]];
    } else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot://fga/user_profile/fga"]]) {
        [app openURL:[NSURL URLWithString:@"tweetbot://fga/user_profile/fga"]];
    } else if ([app canOpenURL:[NSURL URLWithString:@"https://twitter.com/fga"]]) {
        [app openURL:[NSURL URLWithString:@"https://twitter.com/fga"]];
    }
}

- (void)github {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/finngaida"]];
}

- (void)mail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:f@fga.pw?subject=TwitterNotificationAnimation%20Feature%20Request"]];
}

@end
