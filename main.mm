#import <UIKit/UIKit.h>

// متغيرات عامة
static UIButton *floatingBtn = nil;
static NSTimer *clickTimer = nil;
static float clickInterval = 0.5;

@interface ClickerManager : NSObject
+ (void)createFloatingButton;
+ (void)showMenu;
@end

@implementation ClickerManager

+ (void)createFloatingButton {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) window = [[UIApplication sharedApplication].windows firstObject];
    
    // زر متوسط الحجم (60x60)
    floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatingBtn.frame = CGRectMake(20, 200, 60, 60);
    floatingBtn.backgroundColor = [UIColor blackColor];
    floatingBtn.layer.cornerRadius = 30;
    floatingBtn.layer.borderWidth = 2;
    floatingBtn.layer.borderColor = [UIColor blueColor].CGColor;
    floatingBtn.layer.masksToBounds = YES;
    
    // شكل الزر (تاج واسم)
    [floatingBtn setTitle:@"👑\nم" forState:UIControlStateNormal];
    floatingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    floatingBtn.titleLabel.numberOfLines = 2;
    floatingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // تفعيل التحريك (سحب الزر)
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [floatingBtn addGestureRecognizer:pan];
    
    // تفعيل الضغط
    [floatingBtn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [window addSubview:floatingBtn];
    [window bringSubviewToFront:floatingBtn];
}

+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

+ (void)showMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🤖 أوتو موستاش" 
                                                                    message:@"السرعة (ثانية/نقرة)" 
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"0.5";
        tf.keyboardType = UIKeyboardTypeDecimalPad;
        tf.text = [NSString stringWithFormat:@"%.1f", clickInterval];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"▶️ تشغيل" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        clickInterval = [alert.textFields[0].text floatValue];
        [clickTimer invalidate];
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:clickInterval repeats:YES block:^(NSTimer *t) {
            // تنفيذ النقرة
            [[UIApplication sharedApplication] sendEvent:[UIEvent new]];
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"⏹ إيقاف" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
    }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ClickerManager createFloatingButton];
    });
}
