#import <UIKit/UIKit.h>
#import <substrate.h>
#import <pthread.h>

// واجهات النظام المخفية والأساسية لمحاكاة اللمس الفيزيائي الحقيقي 100%
@interface UIEvent (MoustacheClicker)
- (void)_clearTouches;
- (void)_addTouch:(UITouch *)touch forRawEvent:(id)event;
@end

@interface UIApplication (MoustacheEvent)
- (UIEvent *)_touchesEvent;
@end

// كلاس الهدف العائم الذكي (Target Object)
@interface MoustacheTargetView : UIView
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation MoustacheTargetView
- (instancetype)initWithFrame:(CGRect)frame count:(NSInteger)count {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor colorWithRed:0.00 green:1.00 blue:0.80 alpha:1.0] colorWithAlphaComponent:0.6];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.borderWidth = 3;
        self.layer.borderColor = [UIColor colorWithRed:0.00 green:1.00 blue:0.80 alpha:1.0].CGColor;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:self.numberLabel];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}
@end

// كلاس إدارة المود منيو والنقر التلقائي
@interface MoustacheModMenu : NSObject
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) NSMutableArray<MoustacheTargetView *> *targets;

@property (nonatomic, strong) dispatch_source_t clickTimer; // استخدام ميكانيكية نظام منخفضة المستوى لمنع التعليق والكراش
@property (nonatomic, assign) float clickSpeedMs;
@property (nonatomic, assign) BOOL isClicking;

+ (instancetype)sharedInstance;
- (void)initMenu;
@end

@implementation MoustacheModMenu

+ (instancetype)sharedInstance {
    static MoustacheModMenu *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MoustacheModMenu alloc] init];
    });
    return instance;
}

- (void)initMenu {
    self.clickSpeedMs = 500.0;
    self.isClicking = NO;
    self.targets = [[NSMutableArray alloc] init];
    
    // إنشاء نافذة شفافة تغطي الشاشة بالكامل لتمرير اللمسات بدون تجميد الخلفية
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.menuWindow = [[UIWindow alloc] initWithFrame:screenBounds];
    self.menuWindow.windowLevel = UIWindowLevelAlert + 1;
    self.menuWindow.backgroundColor = [UIColor clearColor];
    
    // منع النافذة من حجب اللمسات عن اللعبة الخلفية
    self.menuWindow.userInteractionEnabled = YES;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                self.menuWindow.windowScene = scene;
                break;
            }
        }
    }
    
    [self createFloatingButton];
    [self createModMenu];
    
    self.menuWindow.hidden = NO;
}

// 1. الزر العائم المستمر مع السحب وتحكم كامل
- (void)createFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(40, 150, 85, 85);
    self.floatingButton.titleLabel.numberOfLines = 0;
    self.floatingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    
    // الألوان المطلوبة (بنفسجي نيون فخم + إطار فيروزي مضيء)
    self.floatingButton.backgroundColor = [UIColor colorWithRed:0.09 green:0.04 blue:0.17 alpha:1.0];
    self.floatingButton.layer.cornerRadius = 42.5;
    self.floatingButton.layer.borderWidth = 3;
    self.floatingButton.layer.borderColor = [UIColor colorWithRed:0.00 green:1.00 blue:0.80 alpha:1.0].CGColor;
    
    [self.floatingButton setTitle:@"👑\n👨🏻\nMoustache" forState:UIControlStateNormal];
    [self.floatingButton setTitleColor:[UIColor colorWithRed:0.00 green:1.00 blue:0.80 alpha:1.0] forState:UIControlStateNormal];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtonPan:)];
    [self.floatingButton addGestureRecognizer:panGesture];
    [self.floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuWindow addSubview:self.floatingButton];
}

- (void)handleButtonPan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.menuWindow];
    self.floatingButton.center = CGPointMake(self.floatingButton.center.x + translation.x, self.floatingButton.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.menuWindow];
}

// 2. تصميم قائمة المود المتحركة بالكامل (ألوان نيون وردية ملكية)
- (void)createModMenu {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 390)];
    self.menuView.center = CGPointMake(screenBounds.size.width / 2, screenBounds.size.height / 2);
    
    // خلفية غامقة وإطار وردي نيون حاد
    self.menuView.backgroundColor = [UIColor colorWithRed:0.06 green:0.02 blue:0.13 alpha:0.95];
    self.menuView.layer.cornerRadius = 25;
    self.menuView.layer.borderWidth = 4;
    self.menuView.layer.borderColor = [UIColor colorWithRed:1.00 green:0.00 blue:0.50 alpha:1.0].CGColor;
    self.menuView.hidden = YES;
    
    // تفعيل ميزة تحريك وسحب القائمة بالكامل في الشاشة
    UIPanGestureRecognizer *menuPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMenuPan:)];
    [self.menuView addGestureRecognizer:menuPan];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 290, 30)];
    titleLabel.text = @"👑 MOUSTACHE MOD MENU 👑";
    titleLabel.textColor = [UIColor colorWithRed:1.00 green:0.00 blue:0.50 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.menuView addSubview:titleLabel];
    
    // زر إضافة هدف
    UIButton *btnAddTarget = [self createStyledButton:@"🎯 إضافة هدف على الشاشة" frame:CGRectMake(25, 65, 260, 42) colorHex:@"#00FFCC"];
    [btnAddTarget addTarget:self action:@selector(addNewTarget) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnAddTarget];
    
    // زر مسح الأهداف
    UIButton *btnClearTargets = [self createStyledButton:@"🗑️ مسح كافة الأهداف" frame:CGRectMake(25, 115, 260, 42) colorHex:@"#FF9900"];
    [btnClearTargets addTarget:self action:@selector(clearAllTargets) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnClearTargets];
    
    // نص شريط السرعة
    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 175, 260, 20)];
    self.speedLabel.text = [NSString stringWithFormat:@"⚡ سرعة النقر التلقائي: %.0fms", self.clickSpeedMs];
    self.speedLabel.textColor = [UIColor whiteColor];
    self.speedLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeight some font:UIFontWeightSemibold];
    [self.menuView addSubview:self.speedLabel];
    
    // شريط السرعة Slider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(25, 205, 260, 30)];
    slider.minimumValue = 10.0; // فائق السرعة 10 ملي ثانية بدون تعليق
    slider.maximumValue = 1500.0;
    slider.value = self.clickSpeedMs;
    slider.minimumTrackTintColor = [UIColor colorWithRed:1.00 green:0.00 blue:0.50 alpha:1.0];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:slider];
    
    // زر تشغيل (أخضر نيون)
    UIButton *btnStart = [self createStyledButton:@"▶ تشغيل" frame:CGRectMake(25, 265, 125, 48) colorHex:@"#00FF00"];
    [btnStart addTarget:self action:@selector(startClicker) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnStart];
    
    // زر إيقاف (أحمر نيون)
    UIButton *btnStop = [self createStyledButton:@"🛑 إيقاف" frame:CGRectMake(160, 265, 125, 48) colorHex:@"#FF0000"];
    [btnStop addTarget:self action:@selector(stopClicker) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:btnStop];
    
    [self.menuWindow addSubview:self.menuView];
}

- (void)handleMenuPan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.menuWindow];
    self.menuView.center = CGPointMake(self.menuView.center.x + translation.x, self.menuView.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.menuWindow];
}

- (void)addNewTarget {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    NSInteger nextCount = self.targets.count + 1;
    MoustacheTargetView *target = [[MoustacheTargetView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - 25, screenBounds.size.height/2 - 25, 50, 50) count:nextCount];
    [self.targets addObject:target];
    [self.menuWindow addSubview:target];
    [self.menuWindow bringSubviewToFront:self.menuView]; // إبقاء المنيو في الأعلى
}

- (void)clearAllTargets {
    [self stopClicker];
    for (MoustacheTargetView *target in self.targets) {
        [target removeFromSuperview];
    }
    [self.targets removeAllObjects];
}

