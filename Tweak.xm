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
@end


static BOOL enabled = YES;
static BOOL switcher = NO;

%hook SBBannerContainerViewController

-(void)animateTransition:(_UIViewControllerOneToOneTransitionContext*)tc {
    
    if(!enabled || switcher) { %orig; return; }
    switcher = !switcher;
    
    _UIBackdropView *bg = [[self bannerContextView] backdrop];
    SBDefaultBannerView *contentView = MSHookIvar<SBDefaultBannerView *>([self bannerContextView], "_contentView");
    UIImageView *icon = MSHookIvar<UIImageView *>(contentView, "_iconImageView");
    SBDefaultBannerTextView *title = MSHookIvar<SBDefaultBannerTextView *>(contentView, "_textView");
    UIView *grabber = MSHookIvar<UIView *>([self bannerContextView], "_grabberView");
    CGFloat iconWidth = 20;
    CGFloat width = bg.frame.size.width / 2;
    
    %orig;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(-width, 0, width, bg.frame.size.height)];
    left.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    [self.view addSubview:left];
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, bg.frame.size.height)];
    right.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.view addSubview:right];
    
    bg.alpha = 0;
    icon.alpha = 0;
    icon.frame = CGRectMake(icon.superview.frame.size.width / 2, icon.superview.frame.size.height / 2, 0, 0);
    
    CGRect orig = title.frame;
    title.alpha = 0;
    title.frame = CGRectMake(orig.origin.x + iconWidth * 2, orig.origin.y + iconWidth, orig.size.width - iconWidth * 4, orig.size.height - iconWidth * 2);
    
    grabber.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        left.frame = CGRectMake(0, left.frame.origin.y, left.frame.size.width, left.frame.size.height);
        left.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        right.frame = CGRectMake(width, right.frame.origin.y, right.frame.size.width, right.frame.size.height);
        right.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        bg.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [left removeFromSuperview];
        [right removeFromSuperview];
        
        [UIView animateWithDuration:0.2 animations:^{
            icon.frame = CGRectMake(icon.superview.frame.size.width / 2 - iconWidth / 2, icon.superview.frame.size.height / 2 - iconWidth / 2, iconWidth, iconWidth);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                icon.alpha = 1;
                icon.frame = CGRectMake(iconWidth / 2, icon.frame.origin.y, iconWidth, iconWidth);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    title.frame = orig;
                    title.alpha = 1;
                    grabber.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }];
}

%end


static void loadPrefs() {
    CFPreferencesAppSynchronize(CFSTR("de.finngaida.twitternotificationanimation"));
    
    // TODO:  enabled = !CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.finngaida.twitternotificationanimation")) ? NO : [(__bridge id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.finngaida.twitternotificationanimation")) boolValue];
    
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("de.finngaida.twitternotificationanimation/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    loadPrefs();
}