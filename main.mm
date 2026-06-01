#import <UIKit/UIKit.h>

static UIButton *floatingBtn = nil;
static UIView *menuView = nil;
static NSTimer *clickTimer = nil;

@interface MoustashController : NSObject
+ (void)setup;
@end

@implementation MoustashController

+ (void)setup {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    // الزر العائم
    floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatingBtn.frame = CGRectMake(20, 100, 60, 60);
    floatingBtn.backgroundColor = [UIColor blackColor];
    floatingBtn.layer.cornerRadius = 10;
    floatingBtn.layer.borderWidth = 2;
    floatingBtn.layer.borderColor = [UIColor blueColor].CGColor;
    [floatingBtn setTitle:@"👑\nموستاش" forState:UIControlStateNormal];
    floatingBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    floatingBtn.titleLabel.numberOfLines = 2;
    [floatingBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:floatingBtn];
    
    // القائمة المربعة (مخفية في البداية)
    menuView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 180)];
    menuView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    menuView.hidden = YES;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 30, 160, 30)];
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(20, 80, 70, 40);
    [startBtn setTitle:@"تشغيل" forState:UIControlStateNormal];
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    stopBtn.frame = CGRectMake(110, 80, 70, 40);
    [stopBtn setTitle:@"إيقاف" forState:UIControlStateNormal];
    
    [menuView addSubview:slider];
    [menuView addSubview:startBtn];
    [menuView addSubview:stopBtn];
    [keyWindow addSubview:menuView];
}

+ (void)toggleMenu {
    menuView.hidden = !menuView.hidden;
}
@end

__attribute__((constructor)) static void load() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MoustashController setup];
    });
}
