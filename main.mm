#import <UIKit/UIKit.h>

static NSTimer *clickTimer = nil;
static float clickInterval = 0.5;

// تعريف دالة showAdvancedMenu مسبقاً لتجنب خطأ الـ Compiler
@interface MenuHandler : NSObject
+ (void)showAdvancedMenu;
+ (void)sliderChanged:(UISlider *)sender;
@end

@implementation MenuHandler
+ (void)sliderChanged:(UISlider *)sender {
    clickInterval = sender.value;
}

+ (void)showAdvancedMenu {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🤖 أوتو موستاش" 
                                                                    message:@"تحكم بالسرعة" 
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"▶️ تشغيل" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:clickInterval repeats:YES block:^(NSTimer *t) {
            // محاكاة نقرة
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"⏹ إيقاف" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
    }]];
    
    [window.rootViewController presentViewController:alert animated:YES completion:nil];
}
@end
