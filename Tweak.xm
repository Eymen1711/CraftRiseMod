#import <UIKit/UIKit.h>

static UIWindow *vealixWindow = nil;
static UIButton *vealixToggleBtn = nil;
static UIView *vealixMenu = nil;

@interface VealixTouchHandler : UIButton
@property (nonatomic, copy) void (^tapAction)(void);
@end

@implementation VealixTouchHandler
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.tapAction) {
        self.tapAction();
    }
}
@end

static void SetupVeaLixUI() {
    if (vealixWindow) return;

    UIWindowScene *targetScene = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                targetScene = scene;
                break;
            }
        }
    }

    if (@available(iOS 13.0, *)) {
        if (targetScene) {
            vealixWindow = [[UIWindow alloc] initWithWindowScene:targetScene];
        } else {
            vealixWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
    } else {
        vealixWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    vealixWindow.windowLevel = UIWindowLevelAlert + 99999;
    vealixWindow.backgroundColor = [UIColor clearColor];
    vealixWindow.hidden = NO;

    UIViewController *emptyVC = [[UIViewController alloc] init];
    emptyVC.view.backgroundColor = [UIColor clearColor];
    vealixWindow.rootViewController = emptyVC;

    // 1. ANA TOGGLE BUTONU (Sol Üst)
    VealixTouchHandler *toggleBtn = [VealixTouchHandler buttonWithType:UIButtonTypeCustom];
    toggleBtn.frame = CGRectMake(40, 60, 65, 65);
    toggleBtn.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:0.95];
    toggleBtn.layer.cornerRadius = 32.5;
    toggleBtn.layer.borderWidth = 2.0;
    toggleBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:0.95 blue:0.99 alpha:1.0].CGColor;
    
    // Gölge
    toggleBtn.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.95 blue:0.99 alpha:0.7].CGColor;
    toggleBtn.layer.shadowOffset = CGSizeZero;
    toggleBtn.layer.shadowRadius = 8.0;
    toggleBtn.layer.shadowOpacity = 1.0;

    [toggleBtn setTitle:@"VEALIX\nHACK" forState:UIControlStateNormal];
    toggleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:9];
    toggleBtn.titleLabel.numberOfLines = 2;
    toggleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [toggleBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.95 blue:0.99 alpha:1.0] forState:UIControlStateNormal];

    // 2. MENÜ PANELİ
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(40, 140, 280, 320)];
    menuView.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:0.98];
    menuView.layer.cornerRadius = 16;
    menuView.layer.borderWidth = 1.0;
    menuView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    menuView.hidden = YES; // Başta gizli
    vealixMenu = menuView;

    // Menü Başlığı
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 180, 25)];
    titleLabel.text = @"VeaLixHack v2.0";
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithRed:0.0 green:0.95 blue:0.99 alpha:1.0];
    [menuView addSubview:titleLabel];

    // TikTok Rozeti
    UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 12, 75, 22)];
    badgeLabel.text = @"vealixbl";
    badgeLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    badgeLabel.textColor = [UIColor lightGrayColor];
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    badgeLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    badgeLabel.layer.cornerRadius = 6;
    badgeLabel.layer.masksToBounds = YES;
    [menuView addSubview:badgeLabel];

    // Özellik Satırı Oluşturan Yardımcı Blok/Fonksiyon Mantığı (ESP Örneği)
    CGFloat startY = 50;
    NSArray *features = @[@"ESP", @"Kill Aura", @"Aimbot", @"Attack Macro", @"SpinBot"];
    
    for (int i = 0; i < features.count; i++) {
        UIView *rowBg = [[UIView alloc] initWithFrame:CGRectMake(12, startY + (i * 48), 256, 40)];
        rowBg.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
        rowBg.layer.cornerRadius = 8;
        rowBg.layer.borderWidth = 1.0;
        rowBg.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;

        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 150, 20)];
        nameLbl.text = features[i];
        nameLbl.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        nameLbl.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
        [rowBg addSubview:nameLbl];

        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(195, 4, 50, 30)];
        [sw setOnTintColor:[UIColor colorWithRed:0.0 green:0.95 blue:0.99 alpha:1.0]];
        [rowBg addSubview:sw];

        [menuView addSubview:rowBg];
    }

    // Toggle Butonuna Tıklama Aksiyonu (Menüyü aç/kapat)
    toggleBtn.tapAction = ^{
        menuView.hidden = !menuView.hidden;
    };

    [emptyVC.view addSubview:toggleBtn];
    [emptyVC.view addSubview:menuView];
    
    vealixToggleBtn = toggleBtn;
}

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SetupVeaLixUI();
        });
    }];
}
