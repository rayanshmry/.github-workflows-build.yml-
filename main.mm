#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#include <mach/mach_time.h>

// --- تعريف الدوال ديناميكياً لضمان عدم حدوث خطأ البناء ---
typedef void* (*IOHIDEventSystemClientCreate_t)(CFAllocatorRef);
typedef void (*IOHIDEventSystemClientDispatchEvent_t)(void *, void *);
typedef void* (*IOHIDEventCreateDigitizerFingerEvent_t)(CFAllocatorRef, uint64_t, uint32_t, uint32_t, uint32_t, float, float, float, float, bool, bool);

static void* get_iohid_func(const char* name) {
    void* handle = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_GLOBAL);
    return dlsym(handle, name);
}

// --- واجهة الأداة ---
@interface MoustashAutoClicker : NSObject
+ (void)renderMenu;
@end

@implementation MoustashAutoClicker

+ (void)renderMenu {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    
    // القائمة المربعة
    UIView *menu = [[UIView alloc] initWithFrame:CGRectMake(50, 200, 320, 280)];
    menu.backgroundColor = [UIColor whiteColor];
    menu.layer.cornerRadius = 20;
    menu.layer.borderWidth = 2;
    menu.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    // 1. الأزرار العلوية (كما طلبت)
    NSArray *icons = @[@"❌", @"⚙️", @"⬇️", @"⬆️", @"🔄", @"🔴"];
    for (int i = 0; i < icons.count; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(15 + (i * 48), 10, 40, 40);
        [b setTitle:icons[i] forState:UIControlStateNormal];
        [menu addSubview:b];
    }
    
    // 2. زر التشغيل الفعلي
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    startBtn.frame = CGRectMake(80, 150, 160, 60);
    [startBtn setTitle:@"ابدأ النقرات (Auto Tap)" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startTapping) forControlEvents:UIControlEventTouchUpInside];
    [menu addSubview:startBtn];
    
    [win addSubview:menu];
}

+ (void)startTapping {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        void* client = ((IOHIDEventSystemClientCreate_t)get_iohid_func("IOHIDEventSystemClientCreate"))(kCFAllocatorDefault);
        auto CreateEvent = (IOHIDEventCreateDigitizerFingerEvent_t)get_iohid_func("IOHIDEventCreateDigitizerFingerEvent");
        auto DispatchEvent = (IOHIDEventSystemClientDispatchEvent_t)get_iohid_func("IOHIDEventSystemClientDispatchEvent");
        
        // محاكاة نقرات مستمرة عند (500, 500)
        while(true) {
            uint64_t ts = mach_absolute_time();
            void* down = CreateEvent(kCFAllocatorDefault, ts, 1, 1, 1, 500, 500, 1.0, 1.0, true, true);
            void* up = CreateEvent(kCFAllocatorDefault, ts, 1, 1, 1, 500, 500, 0.0, 1.0, false, true);
            DispatchEvent(client, down);
            DispatchEvent(client, up);
            [NSThread sleepForTimeInterval:0.1]; // سرعة النقرات
        }
    });
}
@end

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MoustashAutoClicker renderMenu];
    });
}
