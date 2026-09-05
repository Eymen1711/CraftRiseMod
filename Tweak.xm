#import <UIKit/UIKit.h>
#import <substrate.h>

static UIWindow *vealixWindow = nil;
static UIButton *vealixFloatBtn = nil;
static UIView *vealixPanel = nil;
static BOOL isMenuOpen = NO;

static UILabel *killauraValLbl = nil;
static UILabel *aimbotValLbl = nil;

// Hile durum ve değer değişkenleri
static BOOL isESPEnabled = NO;
static BOOL isKillAuraEnabled = NO;
static BOOL isAimbotEnabled = NO;
static BOOL isAttackMacroEnabled = NO;
static BOOL isSpinBotEnabled = NO;

static float killAuraDistance = 5.0f;
static float aimbotDistance = 20.0f;

@interface VealixTouchWindow : UIWindow
@end

@implementation VealixTouchWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (vealixFloatBtn && !vealixFloatBtn.hidden) {
        CGPoint p1 = [self convertPoint:point toView:vealixFloatBtn];
        if ([vealixFloatBtn pointInside:p1 withEvent:event]) return YES;
    }
    if (isMenuOpen && vealixPanel && !vealixPanel.hidden) {
        CGPoint p2 = [self convertPoint:point toView:vealixPanel];
        if ([vealixPanel pointInside:p2 withEvent:event]) return YES;
    }
    return NO;
}
@end

@interface VealixActions : NSObject
+ (void)switchChangedESP:(UISwitch *)sender;
+ (void)switchChangedKillAura:(UISwitch *)sender;
+ (void)switchChangedAimbot:(UISwitch *)sender;
+ (void)switchChangedMacro:(UISwitch *)sender;
+ (void)switchChangedSpinBot:(UISwitch *)sender;
+ (void)sliderChangedKillAura:(UISlider *)sender;
+ (void)sliderChangedAimbot:(UISlider *)sender;
+ (void)toggleMenu:(UIButton *)sender;
+ (void)handleFloatPan:(UIPanGestureRecognizer *)gesture;
+ (void)handlePanelPan:(UIPanGestureRecognizer *)gesture;
@end

@implementation VealixActions
+ (void)switchChangedESP:(UISwitch *)sender {
    isESPEnabled = sender.isOn;
}
+ (void)switchChangedKillAura:(UISwitch *)sender {
    isKillAuraEnabled = sender.isOn;
}
+ (void)switchChangedAimbot:(UISwitch *)sender {
    isAimbotEnabled = sender.isOn;
}
+ (void)switchChangedMacro:(UISwitch *)sender {
    isAttackMacroEnabled = sender.isOn;
}
+ (void)switchChangedSpinBot:(UISwitch *)sender {
    isSpinBotEnabled = sender.isOn;
}
+ (void)sliderChangedKillAura:(UISlider *)sender {
    killAuraDistance = sender.value;
    if (killauraValLbl) {
        killauraValLbl.text = [NSString stringWithFormat:@"%.1fm", sender.value];
    }
}
+ (void)sliderChangedAimbot:(UISlider *)sender {
    aimbotDistance = sender.value;
    if (aimbotValLbl) {
        aimbotValLbl.text = [NSString stringWithFormat:@"%.0fm", sender.value];
    }
}
+ (void)toggleMenu:(UIButton *)sender {
    isMenuOpen = !isMenuOpen;
    if (vealixPanel) {
        vealixPanel.hidden = !isMenuOpen;
    }
}
+ (void)handleFloatPan:(UIPanGestureRecognizer *)gesture {
    UIButton *btn = (UIButton *)gesture.view;
    CGPoint translation = [gesture translationInView:btn.superview];
    CGPoint newCenter = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    
    CGFloat halfW = btn.bounds.size.width / 2;
    CGFloat halfH = btn.bounds.size.height / 2;
    CGSize screenSz = btn.superview.bounds.size;
    
    newCenter.x = MAX(halfW, MIN(screenSz.width - halfW, newCenter.x));
    newCenter.y = MAX(halfH, MIN(screenSz.height - halfH, newCenter.y));
    
    btn.center = newCenter;
    [gesture setTranslation:CGPointZero inView:btn.superview];
}
+ (void)handlePanelPan:(UIPanGestureRecognizer *)gesture {
    UIView *panel = gesture.view;
    CGPoint translation = [gesture translationInView:panel.superview];
    CGPoint newCenter = CGPointMake(panel.center.x + translation.x, panel.center.y + translation.y);
    
    CGFloat halfW = panel.bounds.size.width / 2;
    CGFloat halfH = panel.bounds.size.height / 2;
    CGSize screenSz = panel.superview.bounds.size;
    
    newCenter.x = MAX(halfW, MIN(screenSz.width - halfW, newCenter.x));
    newCenter.y = MAX(halfH, MIN(screenSz.height - halfH, newCenter.y));
    
    panel.center = newCenter;
    [gesture setTranslation:CGPointZero inView:panel.superview];
}
@end

// Blok Legends / Oyun İçi Oyuncu Döngüsü Hook Örneği
// Not: Oyunun kendi player update metoduna göre buradaki sınıf/metod adını güncelleyebilirsin.
%datainit {
    // Gerekirse statik başlatmalar buraya
}

// Örnek Oyuncu Mantık Hook'u (Player Tick / Update simülasyonu)
// Oyundaki ana karakter sınıfı yakalandığında bu döngü tetiklenir ve hileler çalışır.
/*
%hook PlayerController
- (void)update {
    %orig;
    
    if (isKillAuraEnabled) {
        // Otomatik vuruş mantığı buraya tetiklenir
    }
    if (isSpinBotEnabled) {
        // Kamera/Açı döndürme mantığı
    }
}
%end
*/

static void BuildVeaLixInterface() {
    if (vealixWindow) return;

    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                vealixWindow = [[VealixTouchWindow alloc] initWithWindowScene:scene];
                break;
            }
        }
    }
    if (!vealixWindow) {
        vealixWindow = [[VealixTouchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    vealixWindow.windowLevel = UIWindowLevelAlert + 99999;
    vealixWindow.backgroundColor = [UIColor clearColor];
    vealixWindow.hidden = NO;

    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.view.userInteractionEnabled = YES;
    vealixWindow.rootViewController = vc;

    // Yüzen Menü Tuşu (Neon Mavi Stil)
    UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatBtn.frame = CGRectMake(30, 80, 50, 50);
    floatBtn.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.02 alpha:0.92];
    floatBtn.layer.cornerRadius = 25;
    floatBtn.layer.borderWidth = 1.8;
    floatBtn.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0].CGColor;
    
    floatBtn.layer.shadowColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.8].CGColor;
    floatBtn.layer.shadowOffset = CGSizeMake(0, 0);
    floatBtn.layer.shadowRadius = 6.0;
    floatBtn.layer.shadowOpacity = 0.9;

    [floatBtn setTitle:@"VEALİX" forState:UIControlStateNormal];
    floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    [floatBtn setTitleColor:[UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    
    [floatBtn addTarget:[VealixActions class] action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *floatPan = [[UIPanGestureRecognizer alloc] initWithTarget:[VealixActions class] action:@selector(handleFloatPan:)];
    [floatBtn addGestureRecognizer:floatPan];

    // Ana Menü Paneli
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake((screenW - 280) / 2, (screenH - 490) / 2, 280, 490)];
    panel.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.05 alpha:0.98];
    panel.layer.cornerRadius = 16;
    panel.layer.borderWidth = 1.2;
    panel.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.5].CGColor;
    panel.layer.shadowColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.4].CGColor;
    panel.layer.shadowOffset = CGSizeMake(0, 0);
    panel.layer.shadowRadius = 10.0;
    panel.layer.shadowOpacity = 0.8;
    panel.hidden = YES;

    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:[VealixActions class] action:@selector(handlePanelPan:)];
    [panel addGestureRecognizer:panelPan];

    // Başlık
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 200, 24)];
    title.text = @"VEALİX HACK";
    title.font = [UIFont boldSystemFontOfSize:16];
    title.textColor = [UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0];
    [panel addSubview:title];

    // TikTok Alt İmza
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 33, 200, 16)];
    subTitle.text = @"TİKTOK: VEALİXBL";
    subTitle.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    subTitle.textColor = [UIColor colorWithRed:0.25 green:0.60 blue:0.95 alpha:0.8];
    [panel addSubview:subTitle];

    // Kapatma Çarpı Butonu
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(238, 12, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [closeBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.33 blue:0.33 alpha:1.0] forState:UIControlStateNormal];
    [closeBtn addTarget:[VealixActions class] action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:closeBtn];

    // Ayraç Çizgi
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 58, 250, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.2];
    [panel addSubview:lineView];

    CGFloat startY = 68;

    // --- ESP ---
    UIView *rowESP = [[UIView alloc] initWithFrame:CGRectMake(12, startY, 256, 42)];
    rowESP.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.02];
    rowESP.layer.cornerRadius = 8;
    rowESP.layer.borderWidth = 1.0;
    rowESP.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.15].CGColor;
    UILabel *lblESP = [[UILabel alloc] initWithFrame:CGRectMake(12, 11, 150, 20)];
    lblESP.text = @"ESP";
    lblESP.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblESP.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowESP addSubview:lblESP];
    UISwitch *swESP = [[UISwitch alloc] initWithFrame:CGRectMake(195, 6, 50, 30)];
    [swESP setOn:isESPEnabled];
    [swESP setOnTintColor:[UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0]];
    [swESP addTarget:[VealixActions class] action:@selector(switchChangedESP:) forControlEvents:UIControlEventValueChanged];
    [rowESP addSubview:swESP];
    [panel addSubview:rowESP];

    // --- Kill Aura ---
    UIView *rowKA = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 50, 256, 80)];
    rowKA.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.02];
    rowKA.layer.cornerRadius = 8;
    rowKA.layer.borderWidth = 1.0;
    rowKA.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.15].CGColor;
    
    UILabel *lblKA = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 100, 20)];
    lblKA.text = @"Kill Aura";
    lblKA.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblKA.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowKA addSubview:lblKA];
    
    UISwitch *swKA = [[UISwitch alloc] initWithFrame:CGRectMake(195, 4, 50, 30)];
    [swKA setOn:isKillAuraEnabled];
    [swKA setOnTintColor:[UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0]];
    [swKA addTarget:[VealixActions class] action:@selector(switchChangedKillAura:) forControlEvents:UIControlEventValueChanged];
    [rowKA addSubview:swKA];

    UILabel *lblKAMsg = [[UILabel alloc] initWithFrame:CGRectMake(12, 34, 100, 15)];
    lblKAMsg.text = @"Mesafe Algılama";
    lblKAMsg.font = [UIFont systemFontOfSize:9];
    lblKAMsg.textColor = [UIColor lightGrayColor];
    [rowKA addSubview:lblKAMsg];

    killauraValLbl = [[UILabel alloc] initWithFrame:CGRectMake(195, 34, 50, 15)];
    killauraValLbl.text = [NSString stringWithFormat:@"%.1fm", killAuraDistance];
    killauraValLbl.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    killauraValLbl.textColor = [UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0];
    killauraValLbl.textAlignment = NSTextAlignmentRight;
    [rowKA addSubview:killauraValLbl];

    UISlider *sliderKA = [[UISlider alloc] initWithFrame:CGRectMake(12, 52, 232, 20)];
    sliderKA.minimumValue = 1;
    sliderKA.maximumValue = 15;
    sliderKA.value = killAuraDistance;
    sliderKA.minimumTrackTintColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0];
    [sliderKA addTarget:[VealixActions class] action:@selector(sliderChangedKillAura:) forControlEvents:UIControlEventValueChanged];
    [rowKA addSubview:sliderKA];
    [panel addSubview:rowKA];

    // --- Aimbot ---
    UIView *rowAim = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 138, 256, 80)];
    rowAim.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.02];
    rowAim.layer.cornerRadius = 8;
    rowAim.layer.borderWidth = 1.0;
    rowAim.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.15].CGColor;
    
    UILabel *lblAim = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 100, 20)];
    lblAim.text = @"Aimbot";
    lblAim.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblAim.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowAim addSubview:lblAim];
    
    UISwitch *swAim = [[UISwitch alloc] initWithFrame:CGRectMake(195, 4, 50, 30)];
    [swAim setOn:isAimbotEnabled];
    [swAim setOnTintColor:[UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0]];
    [swAim addTarget:[VealixActions class] action:@selector(switchChangedAimbot:) forControlEvents:UIControlEventValueChanged];
    [rowAim addSubview:swAim];

    UILabel *lblAimMsg = [[UILabel alloc] initWithFrame:CGRectMake(12, 34, 100, 15)];
    lblAimMsg.text = @"Mesafe Algılama";
    lblAimMsg.font = [UIFont systemFontOfSize:9];
    lblAimMsg.textColor = [UIColor lightGrayColor];
    [rowAim addSubview:lblAimMsg];

    aimbotValLbl = [[UILabel alloc] initWithFrame:CGRectMake(195, 34, 50, 15)];
    aimbotValLbl.text = [NSString stringWithFormat:@"%.0fm", aimbotDistance];
    aimbotValLbl.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
    aimbotValLbl.textColor = [UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0];
    aimbotValLbl.textAlignment = NSTextAlignmentRight;
    [rowAim addSubview:aimbotValLbl];

    UISlider *sliderAim = [[UISlider alloc] initWithFrame:CGRectMake(12, 52, 232, 20)];
    sliderAim.minimumValue = 1;
    sliderAim.maximumValue = 50;
    sliderAim.value = aimbotDistance;
    sliderAim.minimumTrackTintColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0];
    [sliderAim addTarget:[VealixActions class] action:@selector(sliderChangedAimbot:) forControlEvents:UIControlEventValueChanged];
    [rowAim addSubview:sliderAim];
    [panel addSubview:rowAim];

    // --- Attack Macro ---
    UIView *rowAM = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 226, 256, 42)];
    rowAM.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.02];
    rowAM.layer.cornerRadius = 8;
    rowAM.layer.borderWidth = 1.0;
    rowAM.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.15].CGColor;
    UILabel *lblAM = [[UILabel alloc] initWithFrame:CGRectMake(12, 11, 150, 20)];
    lblAM.text = @"Attack Macro (50 CPS)";
    lblAM.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblAM.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowAM addSubview:lblAM];
    UISwitch *swAM = [[UISwitch alloc] initWithFrame:CGRectMake(195, 6, 50, 30)];
    [swAM setOn:isAttackMacroEnabled];
    [swAM setOnTintColor:[UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0]];
    [swAM addTarget:[VealixActions class] action:@selector(switchChangedMacro:) forControlEvents:UIControlEventValueChanged];
    [rowAM addSubview:swAM];
    [panel addSubview:rowAM];

    // --- SpinBot ---
    UIView *rowSB = [[UIView alloc] initWithFrame:CGRectMake(12, startY + 274, 256, 42)];
    rowSB.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.02];
    rowSB.layer.cornerRadius = 8;
    rowSB.layer.borderWidth = 1.0;
    rowSB.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.15].CGColor;
    UILabel *lblSB = [[UILabel alloc] initWithFrame:CGRectMake(12, 11, 150, 20)];
    lblSB.text = @"360 SpinBot";
    lblSB.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    lblSB.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    [rowSB addSubview:lblSB];
    UISwitch *swSB = [[UISwitch alloc] initWithFrame:CGRectMake(195, 6, 50, 30)];
    [swSB setOn:isSpinBotEnabled];
    [swSB setOnTintColor:[UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0]];
    [swSB addTarget:[VealixActions class] action:@selector(switchChangedSpinBot:) forControlEvents:UIControlEventValueChanged];
    [rowSB addSubview:swSB];
    [panel addSubview:rowSB];

    [vc.view addSubview:floatBtn];
    [vc.view addSubview:panel];

    vealixFloatBtn = floatBtn;
    vealixPanel = panel;
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BuildVeaLixInterface();
    });
}
