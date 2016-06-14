#import <substrate.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Quartzcore/Quartzcore.h>
#import <Foundation/Foundation.h>

@interface SBBannerContainerView : UIView
@end

@interface SBDefaultBannerTextView : UIView
@end

@interface _UIBackdropView : UIView
@end

@interface SBDefaultBannerView : UIView
-(CGRect)_contentFrame;
-(CGRect)frame;
-(UIImageView*)iconImageView;
-(SBDefaultBannerTextView*)textView;
@end

@interface SBBannerContextView : UIView
-(CGRect)frame;
-(UIView*)_vibrantContentView;
-(UIView*)testBlur;
-(_UIBackdropView*)backdrop;
-(SBDefaultBannerView*)contentView;
@property(nonatomic) _Bool grabberVisible;
@end

@interface SBBannerController : UIViewController
-(UIViewController*)_bannerViewController;
@end

@interface SBBannerContainerViewController : UIViewController
-(CGFloat)transitionDuration:(id)tc;
-(SBBannerContextView *)bannerContextView;
@end

@interface _UIViewControllerOneToOneTransitionContext
-(UIView*)containerView;
-(SBBannerContainerViewController*)presentedViewController;
- (void)completeTransition:(BOOL)arg1;
@end


static BOOL enabled = YES;
static BOOL showGrabber = YES;
static CGFloat speed = 1.0;
static BOOL outgoing = NO;

static void loadPrefs() {
    //    CFPreferencesAppSynchronize(CFSTR("de.finngaida.twitternotificationanimation"));
    //
    //    enabled = CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.finngaida.twitternotificationanimation")) ? YES : [(__bridge id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.finngaida.twitternotificationanimation")) boolValue];
    //    showGrabber = CFPreferencesCopyAppValue(CFSTR("showGrabber"), CFSTR("de.finngaida.twitternotificationanimation")) ? YES : [(__bridge id)CFPreferencesCopyAppValue(CFSTR("showGrabber"), CFSTR("de.finngaida.twitternotificationanimation")) boolValue];
    //    speed = CFPreferencesCopyAppValue(CFSTR("speed"), CFSTR("de.finngaida.twitternotificationanimation")) ? 1.0 : [(__bridge id)CFPreferencesCopyAppValue(CFSTR("speed"), CFSTR("de.finngaida.twitternotificationanimation")) floatValue];
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/de.finngaida.twitternotificationanimation.plist"];
    
    enabled = [settings objectForKey:@"enabled"] ? [[settings objectForKey:@"enabled"] boolValue] : YES;
    showGrabber = [settings objectForKey:@"showGrabber"] ? [[settings objectForKey:@"showGrabber"] boolValue] : YES;
    speed = ([settings objectForKey:@"speed"] ? [[settings objectForKey:@"speed"] floatValue] : 100) / 100;
}

#ifdef THEOS
%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("de.finngaida.twitternotificationanimation/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    loadPrefs();
}
#endif

#ifdef THEOS
%hook SBBannerContainerViewController
#else
@implementation SBBannerContainerViewController
#endif
-(void)animateTransition:(id)tc {

    NSString *ide = MSHookIvar<NSString *>(MSHookIvar<id>(MSHookIvar<id>(MSHookIvar<id>(self, "_bannerContext"), "_item"), "_seedBulletin"), "_sectionID");
    
    NSLog(@"TwitterNotificationAnimation: The hooked app is: %@", ide);
    
    outgoing = MSHookIvar<UIView *>(tc, "_toView") == nil;
    loadPrefs();
    
    if(!enabled || outgoing || [ide isEqualToString:@"com.apple.Maps"]) { %orig; return; }
    
    _UIBackdropView *bg = [[self bannerContextView] backdrop];
    SBDefaultBannerView *contentView = MSHookIvar<SBDefaultBannerView *>([self bannerContextView], "_contentView");
    UIImageView *icon = MSHookIvar<UIImageView *>(contentView, "_iconImageView");
    SBDefaultBannerTextView *title = MSHookIvar<SBDefaultBannerTextView *>(contentView, "_textView");
    UIView *grabber = MSHookIvar<UIView *>([self bannerContextView], "_grabberView");
    
    %orig;
    
    CGRect origTitle = title.frame;
    CGRect origIcon = icon.frame;
    UIView *origIconView = icon.superview;
    CGFloat iconWidth = [self bannerContextView].frame.size.height / 2.5;
    
    if (origIcon.origin.x == 0) {
        origIcon = CGRectMake(5, origIcon.origin.y, origIcon.size.width, origIcon.size.height);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *subs = [[self bannerContextView] subviews];
        if (subs.count >= 3) {
            UIView *supr = subs[2];
            origIcon = CGRectMake(supr.frame.origin.x, origIcon.origin.y, origIcon.size.width, origIcon.size.height);
        }
    }
    
    bg.alpha = 0;
    bg.frame = CGRectMake(-bg.frame.size.width, bg.frame.origin.y, bg.frame.size.width, bg.frame.size.height);
    
    icon.alpha = 0;
    [icon removeFromSuperview];
    
    title.alpha = 0;
    title.frame = CGRectMake(origTitle.origin.x + iconWidth * 2, origTitle.origin.y + iconWidth, origTitle.size.width - iconWidth * 4, origTitle.size.height - iconWidth * 2);
    
    [self bannerContextView].grabberVisible = NO;
    grabber.alpha = 0;
    
    [UIView animateWithDuration:0.3 * speed animations:^{
        
        bg.frame = CGRectMake(0, bg.frame.origin.y, bg.frame.size.width, bg.frame.size.height);
        bg.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        icon.frame = CGRectMake(bg.frame.size.width / 2, bg.frame.size.height / 2, 0, 0);
        [self.view addSubview:icon];
        
        [UIView animateWithDuration:0.2 * speed delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:nil animations:^{
            icon.frame = CGRectMake(bg.frame.size.width / 2 - iconWidth / 2, bg.frame.size.height / 2 - iconWidth / 2, iconWidth, iconWidth);
            icon.alpha = 1;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 * speed animations:^{
                icon.frame = origIcon;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 * speed animations:^{
                    icon.frame = origIcon;
                    title.frame = origTitle;
                    title.alpha = 1;
                    grabber.alpha = 1;
                } completion:^(BOOL finished) {
                    
                    if (showGrabber) {
                        [self bannerContextView].grabberVisible = YES;
                    }
                    
                    [icon removeFromSuperview];
                    [origIconView addSubview:icon];
                }];
            }];
        }];
    }];
}

-(double)transitionDuration:(id)duration {
    if (enabled) {
        return (outgoing) ? %orig : 0;
    } else {
        return %orig;
    }
}

#ifdef THEOS
%end
#else
@end
#endif

