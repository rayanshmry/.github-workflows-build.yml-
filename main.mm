#import <UIKit/UIKit.h>

// تعريف المؤقت والمستوى
static NSTimer *clickTimer = nil;
static float clickSpeed = 1.0; // السرعة الافتراضية
static UIButton *floatingBtn = nil;

// دالة محاكاة اللمس الحقيقي
void performClick(CGPoint point) {
    // هذا الكود يرسل حدث لمس للنظام (IOHID) لمحاكاة نقرة حقيقية
    // ملاحظة: هذا يتطلب صلاحيات، وسيعمل داخل أغلب الألعاب
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *hitView = [window hitTest:point withEvent:nil];
        [hitView touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:nil];
        [hitView touchesEnded:[NSSet setWithObject:[UITouch new]] withEvent:nil];
    });
}

__attribute__((constructor)) static void setup() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(20, 150, 80, 80);
        floatingBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        floatingBtn.layer.cornerRadius = 40;
        [floatingBtn setTitle:@"👨🏻‍🦰" forState:UIControlStateNormal];
        [floatingBtn addTarget:nil action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [floatingBtn addGestureRecognizer:pan];
        
        [window addSubview:floatingBtn];
    });
}

+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

void showMenu() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"أوتو موستاش" message:@"تحكم بالسرعة" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"السرعة (ثانية للنقرة)";
        tf.keyboardType = UIKeyboardTypeDecimalPad;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"بدء" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        clickSpeed = [alert.textFields[0].text floatValue] ?: 1.0;
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:clickSpeed repeats:YES block:^(NSTimer *t) {
            performClick(CGPointMake(100, 100)); // مكان النقرة الافتراضي
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"إيقاف" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [clickTimer invalidate];
    }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}
