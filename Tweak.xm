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
static _UIViewControllerOneToOneTransitionContext *tc;

%hook SBBannerContainerViewController

-(void)animateTransition:(id)trc {
    
    tc = trc;
    BOOL outgoing = MSHookIvar<UIView *>(tc, "_toView") == nil;
    
    if(!enabled || outgoing) { %orig; return; }
    
    _UIBackdropView *bg = [[self bannerContextView] backdrop];
    SBDefaultBannerView *contentView = MSHookIvar<SBDefaultBannerView *>([self bannerContextView], "_contentView");
    UIImageView *icon = MSHookIvar<UIImageView *>(contentView, "_iconImageView");
    SBDefaultBannerTextView *title = MSHookIvar<SBDefaultBannerTextView *>(contentView, "_textView");
    UIView *grabber = MSHookIvar<UIView *>([self bannerContextView], "_grabberView");
    CGFloat iconWidth = 20;
    CGFloat width = bg.frame.size.width / 2;
    
    %orig;
    
    CGRect origTitle = title.frame;
    CGRect origIcon = icon.frame;
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(width * 2, 0, width, bg.frame.size.height)];
    right.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    [self.view insertSubview:right aboveSubview:bg];
    
    bg.alpha = 0;
    bg.frame = CGRectMake(-bg.frame.size.width, bg.frame.origin.y, bg.frame.size.width, bg.frame.size.height);
    
    [icon removeFromSuperview];
    [self.view addSubview:icon];
    icon.alpha = 0;
    
    title.alpha = 0;
    title.frame = CGRectMake(origTitle.origin.x + iconWidth * 2, origTitle.origin.y + iconWidth, origTitle.size.width - iconWidth * 4, origTitle.size.height - iconWidth * 2);
    
    [self bannerContextView].grabberVisible = NO;
    grabber.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        right.frame = CGRectMake(width, right.frame.origin.y, right.frame.size.width, right.frame.size.height);
        right.alpha = 0.5;
        
        bg.frame = CGRectMake(0, bg.frame.origin.y, bg.frame.size.width, bg.frame.size.height);
        bg.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [right removeFromSuperview];
        icon.frame = CGRectMake(bg.frame.size.width / 2, bg.frame.size.height / 2, 0, 0);
        
        [UIView animateWithDuration:0.2 animations:^{
            icon.frame = CGRectMake(bg.frame.size.width / 2 - iconWidth / 2, bg.frame.size.height / 2 - iconWidth / 2, iconWidth, iconWidth);
            icon.alpha = 1;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                //                icon.frame = CGRectMake(iconWidth / 2, icon.frame.origin.y, iconWidth, iconWidth);
                icon.frame = origIcon;
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    title.frame = origTitle;
                    title.alpha = 1;
                    grabber.alpha = 1;
                } completion:^(BOOL finished) {
                    [self bannerContextView].grabberVisible = YES;
                }];
            }];
        }];
    }];
}

-(double)transitionDuration:(id)duration {
    BOOL outgoing = NO; //MSHookIvar<UIView *>(tc, "_toView") == nil;
    
    return (outgoing) ? %orig : 0;
}

%end


%hook _UIViewControllerOneToOneTransitionContext

- (void)completeTransition:(BOOL)arg1 {
    %orig;
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