#import <UIKit/UIKit.h>

static NSTimer *clickTimer = nil;
static float clickInterval = 0.5; // السرعة الافتراضية
static UIButton *floatingBtn = nil;

__attribute__((constructor)) static void setup() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        // تصميم الزر العائم (الأسود والأزرق مع الشنب والتاج)
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(20, 150, 90, 90);
        floatingBtn.backgroundColor = [UIColor blackColor];
        floatingBtn.layer.cornerRadius = 45;
        floatingBtn.layer.borderWidth = 3;
        floatingBtn.layer.borderColor = [UIColor blueColor].CGColor;
        [floatingBtn setTitle:@"👑\n👨🏻‍🦰\nموستاش" forState:UIControlStateNormal];
        floatingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        floatingBtn.titleLabel.numberOfLines = 3;
        floatingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [floatingBtn addGestureRecognizer:pan];
        [floatingBtn addTarget:nil action:@selector(showAdvancedMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [window addSubview:floatingBtn];
    });
}

+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

void showAdvancedMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚙️ أوتو موستاش برو" 
                                                                    message:@"تحكم كامل بالنقرات" 
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    // شريط السرعة (Slider)
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 60, 230, 20)];
    slider.minimumValue = 0.1;
    slider.maximumValue = 2.0;
    slider.value = clickInterval;
    [slider addTarget:nil action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [alert.view addSubview:slider];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"▶️ تشغيل" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:clickInterval repeats:YES block:^(NSTimer *t) {
            // محاكاة النقرة في مركز الشاشة
            [[UIApplication sharedApplication].keyWindow sendEvent:[UIEvent new]]; 
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"⏹ إيقاف" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
    }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

void sliderChanged(UISlider *sender) {
    clickInterval = sender.value;
}
