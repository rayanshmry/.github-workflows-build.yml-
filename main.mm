#import <UIKit/UIKit.h>

// تعريفات المتغيرات
static UIWindow *overlayWindow = nil;
static UIButton *floatingBtn = nil;
static NSTimer *clickTimer = nil;
static float clickInterval = 0.5;

@interface OverlayManager : NSObject
+ (void)showOverlay;
+ (void)handlePan:(UIPanGestureRecognizer *)p;
+ (void)showMenu;
@end

@implementation OverlayManager

+ (void)showOverlay {
    // إنشاء نافذة مستقلة للأداة لضمان الظهور الدائم
    overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    overlayWindow.hidden = NO;
    overlayWindow.backgroundColor = [UIColor clearColor];

    // إنشاء الزر
    floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatingBtn.frame = CGRectMake(20, 200, 90, 90);
    floatingBtn.backgroundColor = [UIColor blackColor];
    floatingBtn.layer.cornerRadius = 45;
    floatingBtn.layer.borderWidth = 3;
    floatingBtn.layer.borderColor = [UIColor blueColor].CGColor;
    
    // التاج والشنب والاسم
    [floatingBtn setTitle:@"👑\n👨🏻‍🦰\nموستاش" forState:UIControlStateNormal];
    floatingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    floatingBtn.titleLabel.numberOfLines = 3;
    floatingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // تفعيل التحريك
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [floatingBtn addGestureRecognizer:pan];
    
    // تفعيل الضغط
    [floatingBtn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [overlayWindow addSubview:floatingBtn];
    [overlayWindow makeKeyAndVisible];
}

+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

+ (void)showMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🤖 أوتو موستاش" message:@"تحكم بالنقرات الحقيقية" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"▶️ تشغيل" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:clickInterval repeats:YES block:^(NSTimer *t) {
            // محاكاة نقرة حقيقية
            [[UIApplication sharedApplication] sendEvent:[UIEvent new]];
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"⏹ إيقاف" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
    }]];
    
    [overlayWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end

// تفعيل الأداة عند تشغيل اللعبة
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [OverlayManager showOverlay];
    });
}
