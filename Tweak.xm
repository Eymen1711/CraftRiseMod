#import <UIKit/UIKit.h>

static UIWindow *vealixSharedWindow = nil;
static UIButton *vealixMenuBtn = nil;
static UIView *vealixPanel = nil;
static BOOL isMenuOpen = NO;

static UILabel *killauraValLbl = nil;
static UILabel *aimbotValLbl = nil;

// Dokunmaları kesinlikle yutmayan ve sürüklemeyi (Pan) destekleyen buton
@interface VealixDraggableButton : UIButton
@end

@implementation VealixDraggableButton
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.superview bringSubviewToFront:self]; // Her zaman en öne al
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    // Eğer sürüklenmediyse sadece tıklama olarak algıla ve menüyü aç/kapat
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x >= 0 && point.x <= self.bounds.size.width && point.y >= 0 && point.y <= self.bounds.size.height) {
        isMenuOpen = !isMenuOpen;
        if (vealixPanel) {
            vealixPanel.hidden = !isMenuOpen;
        }
    }
}
@end

@interface VealixActions : NSObject
+ (void)sliderChangedKillAura:(UISlider *)sender;
+ (void)sliderChangedAimbot:(UISlider *)sender;
+ (void)handlePanGesture:(UIPanGestureRecognizer *)gesture;
@end

@implementation VealixActions
+ (void)sliderChangedKillAura:(UISlider *)sender {
    if (killauraValLbl) {
        killauraValLbl.text = [NSString stringWithFormat:@"%.0fm", sender.value];
    }
}
+ (void)sliderChangedAimbot:(UISlider *)sender {
    if (aimbotValLbl) {
        aimbotValLbl.text = [NSString stringWithFormat:@"%.0fm", sender.value];
    }
}
+ (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    UIView *btn = gesture.view;
    CGPoint translation = [gesture translationInView:btn.superview];
    
    CGPoint newCenter = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    
    // Ekran dışına çıkmasını engelle
    CGFloat halfW = btn.bounds.size.width / 2;
    CGFloat halfH = btn.bounds.size.height / 2;
    CGSize screenSz = btn.superview.bounds.size;
    
    newCenter.x = MAX(halfW, MIN(screenSz.width - halfW, newCenter.x));
    newCenter.y = MAX(halfH, MIN(screenSz.height - halfH, newCenter.y));
    
    btn.center = newCenter;
    [gesture setTranslation:CGPointZero inView:btn.superview];
    
    // Buton sürüklenirken menüyü de butonun altına konumlandırabiliriz veya sabit tutabiliriz
    if (vealixPanel) {
        vealixPanel.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y + 75, 280, 480);
    }
}
@end

static void BuildVeaLixInterface() {
    if (vealixSharedWindow) return;

    UIWindow *targetWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *win in scene.windows) {
                    if (win.isKeyWindow) {
                        targetWindow = win;
                        break;
                    }
                }
            }
        }
    }
    if (!targetWindow) {
        targetWindow = [UIApplication sharedApplication].keyWindow;
    }
    if (!targetWindow || !targetWindow.rootViewController) return;

    UIViewController *rootVC = targetWindow.rootViewController;

    // Oyunun pencerelerini bypass eden bağımsız görünüm katmanı
    UIView *containerView = [[UIView alloc] initWithFrame:rootVC.view.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.userInteractionEnabled = YES;
    [rootVC.view addSubview:containerView];
    [rootVC.view bringSubviewToFront:containerView];

    // 1. Sürüklenebilir ve Tıklanabilir Ana Buton
    VealixDraggableButton *btn = [VealixDraggableButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(35, 55, 65, 65);
    btn.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:0.95];
    btn.layer.cornerRadius = 32.5;
    btn.layer.borderWidth = 2.0;
    btn.layer.borderColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0].CGColor;
    
    btn.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:0.6].CGColor;
    btn.layer.shadowOffset = CGSizeZero;
    btn.layer.shadowRadius = 6.0;
    btn.layer.shadowOpacity = 1.0;

    [btn setTitle:@"VEALIX\nHACK" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:9];
    btn.titleLabel.numberOfLines = 2;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0] forState:UIControlStateNormal];

    // Butona Sürükleme (Pan) Özelliği Ekleme
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:[VealixActions class] action:@selector(handlePanGesture:)];
    [btn addGestureRecognizer:panGesture];

    // 2. Menü Paneli
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(35, 135, 280, 480)];
    panel.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.09 alpha:0.97];
    panel.layer.cornerRadius = 16;
    panel.layer.borderWidth = 1.0;
    panel.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.18].CGColor;
    panel.hidden = YES;

    // Başlık
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 170, 25)];
    title.text = @"VeaLixHack v2.0";
    title.font = [UIFont boldSystemFontOfSize:14];
    title.textColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0];
    [panel addSubview:title];

    // TikTok Rozeti
    UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(190, 12, 75, 22)];
    badge.text = @"vealixbl";
    badge.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    badge.textColor = [UIColor lightGrayColor];
    badge.textAlignment = NSTextAlignmentCenter;
    badge.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    badge.layer.cornerRadius = 6;
    badge.layer.masksToBounds = YES;
    [panel addSubview:badge];

    CGFloat startY = 48;

    // --- ESP ---
    UIView *rowESP = [[UIView alloc] initWithFrame:CGRectMake(12, startY, 256, 42)];
    rowESP.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    rowESP.layer.cornerRadius = 8;
    rowESP.layer.borderWidth = 1.0;
    rowESP.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    UILabel *lblESP = [[UILabel alloc] initWithFrame:CGRectMake(12, 11, 150, 20)];
    lblESP.text = @"ESP";
    lblESP.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblESP.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowESP addSubview:lblESP];
    UISwitch *swESP = [[UISwitch alloc] initWithFrame:CGRectMake(195, 6, 50, 30)];
    [swESP setOnTintColor:[UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0]];
    [rowESP addSubview:swESP];
    [panel addSubview:rowESP];

    // --- Kill Aura (+ Slider) ---
    UIView *rowKA = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 50, 256, 80)];
    rowKA.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    rowKA.layer.cornerRadius = 8;
    rowKA.layer.borderWidth = 1.0;
    rowKA.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    
    UILabel *lblKA = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 100, 20)];
    lblKA.text = @"Kill Aura";
    lblKA.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblKA.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowKA addSubview:lblKA];
    
    UISwitch *swKA = [[UISwitch alloc] initWithFrame:CGRectMake(195, 4, 50, 30)];
    [swKA setOnTintColor:[UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0]];
    [rowKA addSubview:swKA];

    UILabel *lblKAMsg = [[UILabel alloc] initWithFrame:CGRectMake(12, 34, 100, 15)];
    lblKAMsg.text = @"Mesafe Algılama";
    lblKAMsg.font = [UIFont systemFontOfSize:9];
    lblKAMsg.textColor = [UIColor lightGrayColor];
    [rowKA addSubview:lblKAMsg];

    killauraValLbl = [[UILabel alloc] initWithFrame:CGRectMake(195, 34, 50, 15)];
    killauraValLbl.text = @"20m";
    killauraValLbl.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    killauraValLbl.textColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0];
    killauraValLbl.textAlignment = NSTextAlignmentRight;
    [rowKA addSubview:killauraValLbl];

    UISlider *sliderKA = [[UISlider alloc] initWithFrame:CGRectMake(12, 52, 232, 20)];
    sliderKA.minimumValue = 1;
    sliderKA.maximumValue = 50;
    sliderKA.value = 20;
    sliderKA.minimumTrackTintColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0];
    [sliderKA addTarget:[VealixActions class] action:@selector(sliderChangedKillAura:) forControlEvents:UIControlEventValueChanged];
    [rowKA addSubview:sliderKA];
    [panel addSubview:rowKA];

    // --- Aimbot (+ Slider) ---
    UIView *rowAim = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 138, 256, 80)];
    rowAim.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    rowAim.layer.cornerRadius = 8;
    rowAim.layer.borderWidth = 1.0;
    rowAim.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    
    UILabel *lblAim = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 100, 20)];
    lblAim.text = @"Aimbot";
    lblAim.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblAim.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowAim addSubview:lblAim];
    
    UISwitch *swAim = [[UISwitch alloc] initWithFrame:CGRectMake(195, 4, 50, 30)];
    [swAim setOnTintColor:[UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0]];
    [rowAim addSubview:swAim];

    UILabel *lblAimMsg = [[UILabel alloc] initWithFrame:CGRectMake(12, 34, 100, 15)];
    lblAimMsg.text = @"Mesafe Algılama";
    lblAimMsg.font = [UIFont systemFontOfSize:9];
    lblAimMsg.textColor = [UIColor lightGrayColor];
    [rowAim addSubview:lblAimMsg];

    aimbotValLbl = [[UILabel alloc] initWithFrame:CGRectMake(195, 34, 50, 15)];
    aimbotValLbl.text = @"20m";
    aimbotValLbl.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    aimbotValLbl.textColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0];
    aimbotValLbl.textAlignment = NSTextAlignmentRight;
    [rowAim addSubview:aimbotValLbl];

    UISlider *sliderAim = [[UISlider alloc] initWithFrame:CGRectMake(12, 52, 232, 20)];
    sliderAim.minimumValue = 1;
    sliderAim.maximumValue = 50;
    sliderAim.value = 20;
    sliderAim.minimumTrackTintColor = [UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0];
    [sliderAim addTarget:[VealixActions class] action:@selector(sliderChangedAimbot:) forControlEvents:UIControlEventValueChanged];
    [rowAim addSubview:sliderAim];
    [panel addSubview:rowAim];

    // --- Attack Macro ---
    UIView *rowAM = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 226, 256, 42)];
    rowAM.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    rowAM.layer.cornerRadius = 8;
    rowAM.layer.borderWidth = 1.0;
    rowAM.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    UILabel *lblAM = [[UILabel alloc] initWithFrame:CGRectMake(12, 11, 150, 20)];
    lblAM.text = @"Attack Macro (50 CPS)";
    lblAM.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblAM.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowAM addSubview:lblAM];
    UISwitch *swAM = [[UISwitch alloc] initWithFrame:CGRectMake(195, 6, 50, 30)];
    [swAM setOnTintColor:[UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0]];
    [rowAM addSubview:swAM];
    [panel addSubview:rowAM];

    // --- SpinBot ---
    UIView *rowSB = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 274, 256, 42)];
    rowSB.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    rowSB.layer.cornerRadius = 8;
    rowSB.layer.borderWidth = 1.0;
    rowSB.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    UILabel *lblSB = [[UILabel alloc] initWithFrame:CGRectMake(12, 11, 150, 20)];
    lblSB.text = @"360 SpinBot";
    lblSB.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblSB.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowSB addSubview:lblSB];
    UISwitch *swSB = [[UISwitch alloc] initWithFrame:CGRectMake(195, 6, 50, 30)];
    [swSB setOnTintColor:[UIColor colorWithRed:0.0 green:0.92 blue:1.0 alpha:1.0]];
    [rowSB addSubview:swSB];
    [panel addSubview:rowSB];

    [containerView addSubview:btn];
    [containerView addSubview:panel];

    vealixMenuBtn = btn;
    vealixPanel = panel;
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BuildVeaLixInterface();
    });
}
