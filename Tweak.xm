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
-(void)completeTransition:(BOOL)b;
-(BOOL)isPresenting;
-(void)setupAnimatedBanner;
-(void)setupTransitionBanner;
-(void)setupFashionMenuBanner;
-(void)displayAnimatedBanner;
-(void)displayStaticBanner:(NSInteger)val;
-(void)hideStaticBanner:(NSInteger)val;
-(void)hideTransitionBanner;
-(void)setupHidingTransitionBanner;
-(void)displayTransitionBanner;
-(void)displayFashionMenuBanner;
-(void)setupHidingMaterialBanner;
-(void)hideMaterialBanner;
-(UIImage*)rotateImage:(UIImage*)img byDegrees:(CGFloat)deg;
@end

@interface SBBulletinBannerController
-(id)sharedInstance;
+(void)_showTestBanner:(BOOL)val;
@end

@interface SBLockScreenManager
-(id)sharedInstance;
-(BOOL)isUILocked;
@end

@interface SBNotificationCenterController
-(id)sharedInstance;
-(BOOL)isVisible;
@end


static BOOL enabled = NO;

%hook SBBannerContainerViewController

-(void)animateTransition:(_UIViewControllerOneToOneTransitionContext*)tc {
    
    %log(@"This is the main method with arg: %@, view: %@", tc, [self bannerContextView]);
    
    if(!enabled) { %orig; return; }
    
    _UIBackdropView *bgleft = [[self bannerContextView] backdrop];
    _UIBackdropView *bgright = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:bgleft]];
    SBDefaultBannerView *contentView = MSHookIvar<SBDefaultBannerView *>([self bannerContextView], "_contentView");
    UIImageView *icon = MSHookIvar<UIImageView *>(contentView, "_iconImageView");
    SBDefaultBannerTextView *title = MSHookIvar<SBDefaultBannerTextView *>(contentView, "_textView");
    UIView *grabber = MSHookIvar<UIView *>([self bannerContextView], "_grabberView");
    CGFloat iconWidth = 20;
    
    %orig;
    
    bgleft.frame = CGRectMake(-bgleft.frame.size.width, bgleft.frame.origin.y, bgleft.frame.size.width / 2, bgleft.frame.size.height);
    bgright.frame = CGRectMake(bgright.frame.size.width, bgright.frame.origin.y, bgright.frame.size.width / 2, bgright.frame.size.height);
    icon.alpha = 0;
    title.alpha = 0;
    grabber.alpha = 0;
    CGRect orig = title.frame;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        icon.frame = CGRectMake(contentView.frame.size.width / 2, contentView.frame.size.height / 2, 0, 0);
        
        [UIView animateWithDuration:0.5 animations:^{
            title.frame = CGRectMake(orig.origin.x + iconWidth, orig.origin.y + iconWidth / 2, orig.size.width - iconWidth * 2, orig.size.height - iconWidth);
            icon.frame = CGRectMake(contentView.frame.size.width / 2, contentView.frame.size.height / 2, 0, 0);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                bgleft.frame = CGRectMake(0, bgleft.frame.origin.y, bgleft.frame.size.width, bgleft.frame.size.height);
                bgright.frame = CGRectMake(bgright.superview.frame.size.width / 1.5, bgright.frame.origin.y, bgright.frame.size.width, bgright.frame.size.height);
                icon.frame = CGRectMake(contentView.frame.size.width / 2, contentView.frame.size.height / 2, 0, 0);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
                    icon.alpha = 1;
                    icon.frame = CGRectMake(contentView.frame.size.width / 2 - iconWidth / 2, contentView.frame.size.height / 2 - iconWidth / 2, iconWidth, iconWidth);
                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:0.75 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:0 animations:^{
                        icon.frame = CGRectMake(iconWidth / 2, icon.frame.origin.y, iconWidth, iconWidth);
                        
                        title.frame = orig;
                        title.alpha = 1;
                        grabber.alpha = 1;
                    } completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.4 animations:^{
                            
                        }];
                    }];
                }];
            }];
        }];
    });
    
}

%end


static void loadPrefs() {
    CFPreferencesAppSynchronize(CFSTR("de.finngaida.twitternotificationanimation"));
    
    enabled = YES; // TODO:  !CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.finngaida.twitternotificationanimation")) ? NO : [(__bridge id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.finngaida.twitternotificationanimation")) boolValue];
    
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("de.finngaida.twitternotificationanimation/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    loadPrefs();
}