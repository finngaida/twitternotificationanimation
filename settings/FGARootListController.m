#include "FGARootListController.h"
#include <spawn.h>

@implementation FGARootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }
    
    return _specifiers;
}

//- (void)viewDidLoad {
//    UIBarButtonItem *test = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
//    self.navigationItem.rightBarButtonItem = test;
//}
//
//- (void)test {
//    BBBulletinRequest *bulletin = [[BBBulletinRequest alloc] init];
//    bulletin.sectionID =  @"com.apple.Preferences";
//    bulletin.title =  @"Test message";
//    bulletin.message  = @"Hey man, what's up? This is jsut a test message to let you know this stuff works.";
//    bulletin.date = [NSDate date];
//    SBBulletinBannerController *controller = [SBBulletinBannerController sharedInstance];
//    if ([controller respondsToSelector:@selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:)]) {
//        [controller observer:nil addBulletin:bulletin forFeed:2 playLightsAndSirens:YES withReply:nil];
//    } else if ([controller respondsToSelector:@selector(observer:addBulletin:forFeed:)]) {
//        [controller observer:nil addBulletin:bulletin forFeed:2];
//    }
//}

- (void)respring {
    pid_t pid;
    const char* args[] = {"killall", "-9", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
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

- (void)paypal {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/fga"]];
}

@end
