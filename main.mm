#import <UIKit/UIKit.h>

// المتغيرات
static UIButton *floatingBtn = nil;
static UIView *menuView = nil;
static NSTimer *clickTimer = nil;
static float clickSpeed = 0.5;

@interface MoustashFix : NSObject
+ (void)renderAll;
+ (void)toggleMenu;
@end

@implementation MoustashFix

+ (void)renderAll {
    UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [[UIApplication sharedApplication].windows firstObject];
    
    // الزر العائم مع نظام "إعادة الظهور"
    if (!floatingBtn) {
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(30, 150, 60, 60);
        floatingBtn.backgroundColor = [UIColor blackColor];
        floatingBtn.layer.cornerRadius = 30;
        floatingBtn.layer.borderWidth = 2;
        floatingBtn.layer.borderColor = [UIColor blueColor].CGColor;
        [floatingBtn setTitle:@"👑" forState:UIControlStateNormal];
        [floatingBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBtn:)];
        [floatingBtn addGestureRecognizer:pan];
        [window addSubview:floatingBtn];
    }
    [window bringSubviewToFront:floatingBtn];

    // القائمة (المربعة القابلة للتحريك)
    if (!menuView) {
        menuView = [[UIView alloc] initWithFrame:CGRectMake(100, 150, 200, 250)];
        menuView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
        menuView.layer.cornerRadius = 20;
        menuView.userInteractionEnabled = YES; // تفعيل اللمس
        
        // إمكانية تحريك القائمة
        UIPanGestureRecognizer *panMenu = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        [menuView addGestureRecognizer:panMenu];
        
        // شريط السرعة
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 50, 160, 30)];
        slider.minimumValue = 0.1; slider.maximumValue = 2.0; slider.value = clickSpeed;
        [slider addTarget:self action:@selector(updateSpeed:) forControlEvents:UIControlEventValueChanged];
        [menuView addSubview:slider];
        
        // زر التشغيل
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(50, 120, 100, 40);
        [btn setTitle:@"تشغيل/إيقاف" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toggleClick) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:btn];
        
        menuView.hidden = YES;
        [window addSubview:menuView];
    }
}

+ (void)dragBtn:(UIPanGestureRecognizer *)p { [p.view setCenter:[p locationInView:p.view.superview]]; }
+ (void)dragMenu:(UIPanGestureRecognizer *)p { [p.view setCenter:[p locationInView:p.view.superview]]; }
+ (void)toggleMenu { menuView.hidden = !menuView.hidden; }
+ (void)updateSpeed:(UISlider *)s { clickSpeed = s.value; }

+ (void)toggleClick {
    if (clickTimer) { [clickTimer invalidate]; clickTimer = nil; }
    else {
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:clickSpeed repeats:YES block:^(NSTimer *t) {
            // نقرات حقيقية
            CGPoint pos = CGPointMake(200, 400); 
            [[UIApplication sharedApplication].keyWindow hitTest:pos withEvent:nil];
        }];
    }
}
@end

__attribute__((constructor)) static void init() {
    // رادار لإعادة رسم الزر كل 2 ثانية لضمان عدم اختفائه
    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer *t) {
        [MoustashFix renderAll];
    }];
}
