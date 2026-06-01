#import <UIKit/UIKit.h>

// الكود الاحترافي مع قائمة منبثقة
__attribute__((constructor)) static void setup() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 70, 70);
        [btn setTitle:@"👨🏻‍🦰" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blackColor];
        btn.layer.cornerRadius = 35;
        [btn addTarget:nil action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:btn];
    });
}

void showMenu() {
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"موستاش برو" message:@"اختر سرعة النقرات" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"سريع جداً" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"إيقاف" style:UIAlertActionStyleCancel handler:nil]];
    
    [w.rootViewController presentViewController:alert animated:YES completion:nil];
}
