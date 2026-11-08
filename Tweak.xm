#import <UIKit/UIKit.h>
#import <math.h>

// Vealix Engine - Dinamik Safe Area, Ekran Döndürme Uyumlu ve Çift Dilli UIKit Yardımcı Paneli (v15.0)

static UIWindow *vealixWindow = nil;
static UIButton *vealixFloatBtn = nil;
static UIView *vealixPanel = nil;
static UIView *titleBarView = nil;
static UIView *separatorLine = nil;

static UIScrollView *combatTabContent = nil;
static UIScrollView *visualTabContent = nil;
static UIScrollView *worldTabContent = nil;

static UIButton *combatTabBtn = nil;
static UIButton *visualTabBtn = nil;
static UIButton *worldTabBtn = nil;

static UILabel *titleLabel = nil;
static UILabel *subTitleLabel = nil;
static UIButton *closeButton = nil;
static UIButton *langButton = nil;

static UILabel *killauraValLbl = nil;
static UILabel *aimbotValLbl = nil;

// Özellik Metin Etiketleri (Merkezi Çeviri için)
static UILabel *lblKAText = nil;
static UILabel *lblAimText = nil;
static UILabel *lblAMText = nil;
static UILabel *lblESPText = nil;
static UILabel *lblUnlockText = nil;
static UILabel *lblSBText = nil;
static UILabel *lblFlyText = nil;
static UILabel *lblSpeedText = nil;

// Global Durum Değişkenleri
static BOOL isMenuOpen = NO;
static BOOL isEnglishLang = YES; // YES: English, NO: Türkçe
static CGPoint floatTouchOffset = {0, 0};
static CGPoint floatPanStartLocation = {0, 0};
static BOOL isDraggingFloatBtn = NO;
static id observerToken = nil;

// Arayüz Yerel Durum Değişkenleri (Gerçek oyun içi hile işlevleri yoktur, yalnızca arayüz durumunu tutar)
static BOOL isESPEnabled = NO;
static BOOL isKillAuraEnabled = NO;
static BOOL isAimbotEnabled = NO;
static BOOL isAttackMacroEnabled = NO;
static BOOL isSpinBotEnabled = NO;
static BOOL isFlyEnabled = NO;
static BOOL isSpeedHackEnabled = NO;
static BOOL isUnlockAllFeaturesEnabled = NO;

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

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    if (vealixWindow) {
        // Ekran döndürme ve Safe Area değişikliklerinde layout anında güncellenir
        Class actionsClass = NSClassFromString(@"VealixActions");
        if (actionsClass && [actionsClass respondsToSelector:@selector(updateLayoutForSize:)]) {
            [actionsClass performSelector:@selector(updateLayoutForSize:) withObject:[NSValue valueWithCGSize:vealixWindow.bounds.size]];
        }
    }
}
@end

@interface VealixActions : NSObject <UIGestureRecognizerDelegate>
+ (void)switchChangedESP:(UISwitch *)sender;
+ (void)switchChangedKillAura:(UISwitch *)sender;
+ (void)switchChangedAimbot:(UISwitch *)sender;
+ (void)switchChangedMacro:(UISwitch *)sender;
+ (void)switchChangedSpinBot:(UISwitch *)sender;
+ (void)switchChangedFly:(UISwitch *)sender;
+ (void)switchChangedSpeed:(UISwitch *)sender;
+ (void)switchChangedUnlockAll:(UISwitch *)sender;
+ (void)sliderChangedKillAura:(UISlider *)sender;
+ (void)sliderChangedAimbot:(UISlider *)sender;
+ (void)toggleMenu:(id)sender;
+ (void)toggleLanguage:(UIButton *)sender;
+ (void)switchTabToCombat:(UIButton *)sender;
+ (void)switchTabToVisual:(UIButton *)sender;
+ (void)switchTabToWorld:(UIButton *)sender;
+ (void)handleFloatPan:(UIPanGestureRecognizer *)gesture;
+ (void)handlePanelPan:(UIPanGestureRecognizer *)gesture;
+ (void)handleFloatTap:(UITapGestureRecognizer *)gesture;
+ (void)updateLayoutForSize:(CGSize)size;
+ (void)refreshLocalization;
+ (UIView *)createRowWithTitle:(NSString *)title switch:(UISwitch **)outSwitch slider:(UISlider **)outSlider valueLabel:(UILabel **)outValLbl height:(CGFloat)height width:(CGFloat)width;
@end

@implementation VealixActions

+ (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

+ (void)switchChangedESP:(UISwitch *)sender { isESPEnabled = sender.isOn; }
+ (void)switchChangedKillAura:(UISwitch *)sender { isKillAuraEnabled = sender.isOn; }
+ (void)switchChangedAimbot:(UISwitch *)sender { isAimbotEnabled = sender.isOn; }
+ (void)switchChangedMacro:(UISwitch *)sender { isAttackMacroEnabled = sender.isOn; }
+ (void)switchChangedSpinBot:(UISwitch *)sender { isSpinBotEnabled = sender.isOn; }
+ (void)switchChangedFly:(UISwitch *)sender { isFlyEnabled = sender.isOn; }
+ (void)switchChangedSpeed:(UISwitch *)sender { isSpeedHackEnabled = sender.isOn; }
+ (void)switchChangedUnlockAll:(UISwitch *)sender { isUnlockAllFeaturesEnabled = sender.isOn; }

+ (void)sliderChangedKillAura:(UISlider *)sender {
    killAuraDistance = sender.value;
    if (killauraValLbl) killauraValLbl.text = [NSString stringWithFormat:@"%.1fm", sender.value];
}

+ (void)sliderChangedAimbot:(UISlider *)sender {
    aimbotDistance = sender.value;
    if (aimbotValLbl) aimbotValLbl.text = [NSString stringWithFormat:@"%.0fm", sender.value];
}

+ (void)toggleMenu:(id)sender {
    isMenuOpen = !isMenuOpen;
    if (vealixPanel) {
        vealixPanel.hidden = !isMenuOpen;
        if (isMenuOpen && vealixWindow) {
            [self updateLayoutForSize:vealixWindow.bounds.size];
        }
    }
}

+ (void)refreshLocalization {
    if (titleLabel) titleLabel.text = isEnglishLang ? @"VEALİX ENGINE // HELPER" : @"VEALİX MOTOR // YARDIMCI";
    if (subTitleLabel) subTitleLabel.text = @"TIKTOK: VEALİXBL";
    if (langButton) [langButton setTitle:(isEnglishLang ? @"EN 🌐" : @"TR 🌐") forState:UIControlStateNormal];
    
    if (combatTabBtn) [combatTabBtn setTitle:(isEnglishLang ? @"COMBAT" : @"SAVAŞ") forState:UIControlStateNormal];
    if (visualTabBtn) [visualTabBtn setTitle:(isEnglishLang ? @"VISUALS" : @"GÖRSEL") forState:UIControlStateNormal];
    if (worldTabBtn) [worldTabBtn setTitle:(isEnglishLang ? @"WORLD/MISC" : @"DÜNYA") forState:UIControlStateNormal];
    
    if (lblKAText) lblKAText.text = isEnglishLang ? @"Kill Aura Range" : @"Kill Aura Mesafesi";
    if (lblAimText) lblAimText.text = isEnglishLang ? @"Aimbot Distance" : @"Aimbot Mesafesi";
    if (lblAMText) lblAMText.text = isEnglishLang ? @"Attack Macro (50 CPS)" : @"Saldırı Makrosu (50 CPS)";
    if (lblESPText) lblESPText.text = isEnglishLang ? @"Player ESP Boxes" : @"Oyuncu ESP Kutuları";
    if (lblUnlockText) lblUnlockText.text = isEnglishLang ? @"Unlock All Cosmetics" : @"Tüm Kozmetikleri Aç";
    if (lblSBText) lblSBText.text = isEnglishLang ? @"360 SpinBot" : @"360 Derece SpinBot";
    if (lblFlyText) lblFlyText.text = isEnglishLang ? @"Egg Wars Fly" : @"Egg Wars Uçuş Modu";
    if (lblSpeedText) lblSpeedText.text = isEnglishLang ? @"Bunny Hop Speed" : @"Hızlı Koşu (Speed)";
}

+ (void)toggleLanguage:(UIButton *)sender {
    isEnglishLang = !isEnglishLang;
    [self refreshLocalization];
}

+ (void)switchTabToCombat:(UIButton *)sender {
    if (!combatTabContent || !visualTabContent || !worldTabContent) return;
    combatTabContent.hidden = NO;
    visualTabContent.hidden = YES;
    worldTabContent.hidden = YES;
    
    combatTabBtn.backgroundColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.3];
    visualTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    worldTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
}

+ (void)switchTabToVisual:(UIButton *)sender {
    if (!combatTabContent || !visualTabContent || !worldTabContent) return;
    combatTabContent.hidden = YES;
    visualTabContent.hidden = NO;
    worldTabContent.hidden = YES;
    
    combatTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    visualTabBtn.backgroundColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.3];
    worldTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
}

+ (void)switchTabToWorld:(UIButton *)sender {
    if (!combatTabContent || !visualTabContent || !worldTabContent) return;
    combatTabContent.hidden = YES;
    visualTabContent.hidden = YES;
    worldTabContent.hidden = NO;
    
    combatTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    visualTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    worldTabBtn.backgroundColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.3];
}

+ (void)handleFloatPan:(UIPanGestureRecognizer *)gesture {
    UIButton *btn = (UIButton *)gesture.view;
    UIView *superv = btn.superview;
    if (!superv) return;

    if (gesture.state == UIGestureRecognizerStateBegan) {
        floatTouchOffset = [gesture locationInView:btn];
        floatPanStartLocation = [gesture locationInView:superv];
        isDraggingFloatBtn = NO;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint loc = [gesture locationInView:superv];
        CGFloat dx = loc.x - floatPanStartLocation.x;
        CGFloat dy = loc.y - floatPanStartLocation.y;
        if (sqrt(dx * dx + dy * dy) > 5.0f) isDraggingFloatBtn = YES;
        
        if (isDraggingFloatBtn) {
            CGPoint newCenter = CGPointMake(loc.x - floatTouchOffset.x + (btn.bounds.size.width / 2.0f),
                                            loc.y - floatTouchOffset.y + (btn.bounds.size.height / 2.0f));
            CGFloat halfW = btn.bounds.size.width / 2.0f;
            CGFloat halfH = btn.bounds.size.height / 2.0f;
            CGSize screenSz = superv.bounds.size;
            
            UIEdgeInsets insets = UIEdgeInsetsZero;
            if (@available(iOS 11.0, *)) {
                insets = superv.safeAreaInsets;
            }
            
            newCenter.x = MAX(halfW + insets.left, MIN(screenSz.width - halfW - insets.right, newCenter.x));
            newCenter.y = MAX(halfH + insets.top, MIN(screenSz.height - halfH - insets.bottom, newCenter.y));
            btn.center = newCenter;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (isDraggingFloatBtn) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                isDraggingFloatBtn = NO;
            });
        }
    }
}

+ (void)handleFloatTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded && !isDraggingFloatBtn) {
        [self toggleMenu:nil];
    }
}

+ (void)handlePanelPan:(UIPanGestureRecognizer *)gesture {
    UIView *dragArea = (UIView *)gesture.view;
    if (!dragArea) return;
    UIView *panel = dragArea.superview;
    UIView *superv = panel.superview;
    if (!superv || !panel) return;
    
    CGPoint translation = [gesture translationInView:superv];
    CGPoint newCenter = CGPointMake(panel.center.x + translation.x, panel.center.y + translation.y);
    CGFloat halfW = panel.bounds.size.width / 2.0f;
    CGFloat halfH = panel.bounds.size.height / 2.0f;
    CGSize screenSz = superv.bounds.size;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = superv.safeAreaInsets;
    }
    
    newCenter.x = MAX(halfW + insets.left, MIN(screenSz.width - halfW - insets.right, newCenter.x));
    newCenter.y = MAX(halfH + insets.top, MIN(screenSz.height - halfH - insets.bottom, newCenter.y));
    
    panel.center = newCenter;
    [gesture setTranslation:CGPointZero inView:superv];
}

+ (void)updateLayoutForSize:(CGSize)size {
    if (!vealixPanel || !vealixWindow) return;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = vealixWindow.safeAreaInsets;
    }
    
    CGFloat maxAllowedW = size.width - insets.left - insets.right - 20.0f;
    CGFloat maxAllowedH = size.height - insets.top - insets.bottom - 20.0f;
    
    // Küçük ekranlar için dinamik ve esnek minimum sınırlar (taşma önlendi)
    CGFloat minW = MIN(220.0f, maxAllowedW);
    CGFloat minH = MIN(180.0f, maxAllowedH);
    
    CGFloat pW = MAX(minW, MIN(440.0f, maxAllowedW));
    CGFloat pH = MAX(minH, MIN(300.0f, maxAllowedH));
    
    CGPoint oldCenter = vealixPanel.center;
    vealixPanel.bounds = CGRectMake(0, 0, pW, pH);
    
    CGFloat halfW = pW / 2.0f;
    CGFloat halfH = pH / 2.0f;
    oldCenter.x = MAX(halfW + insets.left, MIN(size.width - halfW - insets.right, oldCenter.x));
    oldCenter.y = MAX(halfH + insets.top, MIN(size.height - halfH - insets.bottom, oldCenter.y));
    vealixPanel.center = oldCenter;
    
    // Floating Button ekran döndüğünde dışarıda kalmasın
    if (vealixFloatBtn) {
        CGPoint fCenter = vealixFloatBtn.center;
        CGFloat fHalfW = vealixFloatBtn.bounds.size.width / 2.0f;
        CGFloat fHalfH = vealixFloatBtn.bounds.size.height / 2.0f;
        fCenter.x = MAX(fHalfW + insets.left, MIN(size.width - fHalfW - insets.right, fCenter.x));
        fCenter.y = MAX(fHalfH + insets.top, MIN(size.height - fHalfH - insets.bottom, fCenter.y));
        vealixFloatBtn.center = fCenter;
    }
    
    if (titleBarView) {
        titleBarView.frame = CGRectMake(0, 0, pW, 45);
        if (titleLabel) titleLabel.frame = CGRectMake(15, 6, pW - 120, 18);
        if (subTitleLabel) subTitleLabel.frame = CGRectMake(15, 24, pW - 120, 14);
        if (langButton) langButton.frame = CGRectMake(pW - 75, 8, 30, 28);
        if (closeButton) closeButton.frame = CGRectMake(pW - 40, 8, 30, 28);
    }
    
    CGFloat tabWidth = (pW - 40) / 3.0f;
    if (combatTabBtn) combatTabBtn.frame = CGRectMake(15, 52, tabWidth, 26);
    if (visualTabBtn) visualTabBtn.frame = CGRectMake(20 + tabWidth, 52, tabWidth, 26);
    if (worldTabBtn) worldTabBtn.frame = CGRectMake(25 + (tabWidth * 2), 52, tabWidth, 26);
    if (separatorLine) separatorLine.frame = CGRectMake(15, 84, pW - 30, 1);
    
    CGRect scrollFrame = CGRectMake(0, 90, pW, pH - 98);
    CGFloat rowW = pW - 30;
    
    for (UIScrollView *scroll in @[combatTabContent, visualTabContent, worldTabContent]) {
        if (!scroll) continue;
        scroll.frame = scrollFrame;
        CGFloat maxY = 10;
        for (UIView *row in scroll.subviews) {
            CGRect f = row.frame;
            f.size.width = rowW;
            row.frame = f;
            if (CGRectGetMaxY(f) > maxY) {
                maxY = CGRectGetMaxY(f);
            }
            for (UIView *sub in row.subviews) {
                if ([sub isKindOfClass:[UISwitch class]]) {
                    CGRect sf = sub.frame;
                    sf.origin.x = rowW - 65;
                    sub.frame = sf;
                } else if ([sub isKindOfClass:[UISlider class]]) {
                    CGRect slf = sub.frame;
                    slf.size.width = rowW - 20;
                    sub.frame = slf;
                } else if ([sub isKindOfClass:[UILabel class]] && sub.frame.size.width == 55) {
                    CGRect lf = sub.frame;
                    lf.origin.x = rowW - 125;
                    sub.frame = lf;
                }
            }
        }
        scroll.contentSize = CGSizeMake(pW, maxY + 20.0f);
    }
}

+ (UIView *)createRowWithTitle:(NSString *)title switch:(UISwitch **)outSwitch slider:(UISlider **)outSlider valueLabel:(UILabel **)outValLbl height:(CGFloat)height width:(CGFloat)width {
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(15, 0, width, height)];
    row.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.02];
    row.layer.cornerRadius = 8;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, width - 85, 20)];
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    lbl.textColor = [UIColor colorWithRed:0.88 green:0.91 blue:0.95 alpha:1.0];
    lbl.adjustsFontSizeToFitWidth = YES;
    lbl.minimumScaleFactor = 0.85;
    [row addSubview:lbl];
    
    if ([title containsString:@"Kill Aura"]) lblKAText = lbl;
    else if ([title containsString:@"Aimbot"]) lblAimText = lbl;
    else if ([title containsString:@"Attack Macro"]) lblAMText = lbl;
    else if ([title containsString:@"ESP"]) lblESPText = lbl;
    else if ([title containsString:@"Cosmetics"]) lblUnlockText = lbl;
    else if ([title containsString:@"SpinBot"]) lblSBText = lbl;
    else if ([title containsString:@"Fly"]) lblFlyText = lbl;
    else if ([title containsString:@"Speed"]) lblSpeedText = lbl;
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(width - 65, 4, 50, 30)];
    [sw setOnTintColor:[UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0]];
    [row addSubview:sw];
    if (outSwitch) *outSwitch = sw;
    
    if (height > 40 && outSlider) {
        UILabel *vLbl = [[UILabel alloc] initWithFrame:CGRectMake(width - 125, 8, 55, 18)];
        vLbl.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
        vLbl.textColor = [UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0];
        vLbl.textAlignment = NSTextAlignmentRight;
        [row addSubview:vLbl];
        if (outValLbl) *outValLbl = vLbl;
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 32, width - 20, 15)];
        slider.minimumTrackTintColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0];
        [row addSubview:slider];
        *outSlider = slider;
    }
    return row;
}

@end

static void BuildVeaLixInterface() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (vealixWindow) return;

        UIWindowScene *targetScene = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    targetScene = scene;
                    break;
                }
            }
            if (targetScene) vealixWindow = [[VealixTouchWindow alloc] initWithWindowScene:targetScene];
        }
        if (!vealixWindow) vealixWindow = [[VealixTouchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.userInteractionEnabled = YES;
        
        vealixWindow.rootViewController = vc;
        vealixWindow.windowLevel = UIWindowLevelNormal + 100;
        vealixWindow.backgroundColor = [UIColor clearColor];
        vealixWindow.hidden = NO;

        // Floating Button
        UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatBtn.frame = CGRectMake(30, 80, 50, 50);
        floatBtn.backgroundColor = [UIColor colorWithRed:0.01 green:0.01 blue:0.02 alpha:0.92];
        floatBtn.layer.cornerRadius = 25;
        floatBtn.layer.borderWidth = 1.8;
        floatBtn.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:1.0].CGColor;
        [floatBtn setTitle:@"VEALİX" forState:UIControlStateNormal];
        floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [floatBtn setTitleColor:[UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0] forState:UIControlStateNormal];

        UIPanGestureRecognizer *floatPan = [[UIPanGestureRecognizer alloc] initWithTarget:[VealixActions class] action:@selector(handleFloatPan:)];
        floatPan.delegate = [VealixActions class];
        [floatBtn addGestureRecognizer:floatPan];
        
        UITapGestureRecognizer *floatTap = [[UITapGestureRecognizer alloc] initWithTarget:[VealixActions class] action:@selector(handleFloatTap:)];
        floatTap.delegate = [VealixActions class];
        [floatBtn addGestureRecognizer:floatTap];

        CGSize currentSize = vealixWindow.bounds.size;
        UIEdgeInsets insets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            insets = vealixWindow.safeAreaInsets;
        }
        
        CGFloat maxAllowedW = currentSize.width - insets.left - insets.right - 20.0f;
        CGFloat maxAllowedH = currentSize.height - insets.top - insets.bottom - 20.0f;
        CGFloat minW = MIN(220.0f, maxAllowedW);
        CGFloat minH = MIN(180.0f, maxAllowedH);
        CGFloat pW = MAX(minW, MIN(440.0f, maxAllowedW));
        CGFloat pH = MAX(minH, MIN(300.0f, maxAllowedH));
        
        UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, pH)];
        panel.center = CGPointMake(currentSize.width / 2.0f, currentSize.height / 2.0f);
        panel.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.05 alpha:0.98];
        panel.layer.cornerRadius = 16;
        panel.layer.borderWidth = 1.2;
        panel.layer.borderColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.5].CGColor;
        panel.hidden = YES;

        // Başlık Alanı
        titleBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW, 45)];
        titleBarView.backgroundColor = [UIColor clearColor];
        
        UIView *dragZone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pW - 80, 45)];
        dragZone.backgroundColor = [UIColor clearColor];
        UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:[VealixActions class] action:@selector(handlePanelPan:)];
        [dragZone addGestureRecognizer:panelPan];
        [titleBarView addSubview:dragZone];

        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 6, pW - 120, 18)];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = [UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0];
        [titleBarView addSubview:titleLabel];

        subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 24, pW - 120, 14)];
        subTitleLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
        subTitleLabel.textColor = [UIColor colorWithRed:0.25 green:0.60 blue:0.95 alpha:0.8];
        [titleBarView addSubview:subTitleLabel];

        langButton = [UIButton buttonWithType:UIButtonTypeCustom];
        langButton.frame = CGRectMake(pW - 75, 8, 30, 28);
        langButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [langButton setTitleColor:[UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [langButton addTarget:[VealixActions class] action:@selector(toggleLanguage:) forControlEvents:UIControlEventTouchUpInside];
        [titleBarView addSubview:langButton];

        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(pW - 40, 8, 30, 28);
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [closeButton setTitleColor:[UIColor colorWithRed:1.0 green:0.33 blue:0.33 alpha:1.0] forState:UIControlStateNormal];
        [closeButton addTarget:[VealixActions class] action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
        [titleBarView addSubview:closeButton];
        
        [panel addSubview:titleBarView];

        // Sekmeler
        CGFloat tabWidth = (pW - 40) / 3.0f;
        combatTabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        combatTabBtn.frame = CGRectMake(15, 52, tabWidth, 26);
        combatTabBtn.backgroundColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.3];
        combatTabBtn.layer.cornerRadius = 6;
        combatTabBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [combatTabBtn setTitleColor:[UIColor colorWithRed:0.35 green:0.78 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [combatTabBtn addTarget:[VealixActions class] action:@selector(switchTabToCombat:) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:combatTabBtn];

        visualTabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        visualTabBtn.frame = CGRectMake(20 + tabWidth, 52, tabWidth, 26);
        visualTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
        visualTabBtn.layer.cornerRadius = 6;
        visualTabBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [visualTabBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [visualTabBtn addTarget:[VealixActions class] action:@selector(switchTabToVisual:) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:visualTabBtn];

        worldTabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        worldTabBtn.frame = CGRectMake(25 + (tabWidth * 2), 52, tabWidth, 26);
        worldTabBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
        worldTabBtn.layer.cornerRadius = 6;
        worldTabBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [worldTabBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [worldTabBtn addTarget:[VealixActions class] action:@selector(switchTabToWorld:) forControlEvents:UIControlEventTouchUpInside];
        [panel addSubview:worldTabBtn];

        separatorLine = [[UIView alloc] initWithFrame:CGRectMake(15, 84, pW - 30, 1)];
        separatorLine.backgroundColor = [UIColor colorWithRed:0.22 green:0.65 blue:1.0 alpha:0.2];
        [panel addSubview:separatorLine];

        CGFloat rowW = pW - 30;

        // --- 1. COMBAT TAB ---
        combatTabContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, pW, pH - 98)];
        combatTabContent.hidden = NO;
        CGFloat cY = 10;

        UISwitch *swKA = nil; UISlider *sliderKA = nil;
        UIView *rowKA = [VealixActions createRowWithTitle:@"Kill Aura Range" switch:&swKA slider:&sliderKA valueLabel:&killauraValLbl height:55 width:rowW];
        rowKA.frame = CGRectMake(15, cY, rowW, 55);
        [swKA setOn:isKillAuraEnabled];
        [swKA addTarget:[VealixActions class] action:@selector(switchChangedKillAura:) forControlEvents:UIControlEventValueChanged];
        sliderKA.value = killAuraDistance;
        sliderKA.minimumValue = 1; sliderKA.maximumValue = 15;
        [sliderKA addTarget:[VealixActions class] action:@selector(sliderChangedKillAura:) forControlEvents:UIControlEventValueChanged];
        killauraValLbl.text = [NSString stringWithFormat:@"%.1fm", killAuraDistance];
        [combatTabContent addSubview:rowKA];

        cY += 62;

        UISwitch *swAim = nil; UISlider *sliderAim = nil;
        UIView *rowAim = [VealixActions createRowWithTitle:@"Aimbot Distance" switch:&swAim slider:&sliderAim valueLabel:&aimbotValLbl height:55 width:rowW];
        rowAim.frame = CGRectMake(15, cY, rowW, 55);
        [swAim setOn:isAimbotEnabled];
        [swAim addTarget:[VealixActions class] action:@selector(switchChangedAimbot:) forControlEvents:UIControlEventValueChanged];
        sliderAim.value = aimbotDistance;
        sliderAim.minimumValue = 1; sliderAim.maximumValue = 50;
        [sliderAim addTarget:[VealixActions class] action:@selector(sliderChangedAimbot:) forControlEvents:UIControlEventValueChanged];
        aimbotValLbl.text = [NSString stringWithFormat:@"%.0fm", aimbotDistance];
        [combatTabContent addSubview:rowAim];

        cY += 62;

        UISwitch *swAM = nil;
        UIView *rowAM = [VealixActions createRowWithTitle:@"Attack Macro (50 CPS)" switch:&swAM slider:nil valueLabel:nil height:38 width:rowW];
        rowAM.frame = CGRectMake(15, cY, rowW, 38);
        [swAM setOn:isAttackMacroEnabled];
        [swAM addTarget:[VealixActions class] action:@selector(switchChangedMacro:) forControlEvents:UIControlEventValueChanged];
        [combatTabContent addSubview:rowAM];

        combatTabContent.contentSize = CGSizeMake(pW, cY + 48);

        // --- 2. VISUALS TAB ---
        visualTabContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, pW, pH - 98)];
        visualTabContent.hidden = YES;
        CGFloat vY = 10;

        UISwitch *swESP = nil;
        UIView *rowESP = [VealixActions createRowWithTitle:@"Player ESP Boxes" switch:&swESP slider:nil valueLabel:nil height:38 width:rowW];
        rowESP.frame = CGRectMake(15, vY, rowW, 38);
        [swESP setOn:isESPEnabled];
        [swESP addTarget:[VealixActions class] action:@selector(switchChangedESP:) forControlEvents:UIControlEventValueChanged];
        [visualTabContent addSubview:rowESP];

        vY += 45;

        UISwitch *swUnlock = nil;
        UIView *rowUnlock = [VealixActions createRowWithTitle:@"Unlock All Cosmetics" switch:&swUnlock slider:nil valueLabel:nil height:38 width:rowW];
        rowUnlock.frame = CGRectMake(15, vY, rowW, 38);
        [swUnlock setOn:isUnlockAllFeaturesEnabled];
        [swUnlock addTarget:[VealixActions class] action:@selector(switchChangedUnlockAll:) forControlEvents:UIControlEventValueChanged];
        [visualTabContent addSubview:rowUnlock];

        visualTabContent.contentSize = CGSizeMake(pW, vY + 48);

        // --- 3. WORLD / MISC TAB ---
        worldTabContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, pW, pH - 98)];
        worldTabContent.hidden = YES;
        CGFloat wY = 10;

        UISwitch *swSB = nil;
        UIView *rowSB = [VealixActions createRowWithTitle:@"360 SpinBot" switch:&swSB slider:nil valueLabel:nil height:38 width:rowW];
        rowSB.frame = CGRectMake(15, wY, rowW, 38);
        [swSB setOn:isSpinBotEnabled];
        [swSB addTarget:[VealixActions class] action:@selector(switchChangedSpinBot:) forControlEvents:UIControlEventValueChanged];
        [worldTabContent addSubview:rowSB];

        wY += 45;

        UISwitch *swFly = nil;
        UIView *rowFly = [VealixActions createRowWithTitle:@"Egg Wars Fly" switch:&swFly slider:nil valueLabel:nil height:38 width:rowW];
        rowFly.frame = CGRectMake(15, wY, rowW, 38);
        [swFly setOn:isFlyEnabled];
        [swFly addTarget:[VealixActions class] action:@selector(switchChangedFly:) forControlEvents:UIControlEventValueChanged];
        [worldTabContent addSubview:rowFly];

        wY += 45;

        UISwitch *swSpeed = nil;
        UIView *rowSpeed = [VealixActions createRowWithTitle:@"Bunny Hop Speed" switch:&swSpeed slider:nil valueLabel:nil height:38 width:rowW];
        rowSpeed.frame = CGRectMake(15, wY, rowW, 38);
        [swSpeed setOn:isSpeedHackEnabled];
        [swSpeed addTarget:[VealixActions class] action:@selector(switchChangedSpeed:) forControlEvents:UIControlEventValueChanged];
        [worldTabContent addSubview:rowSpeed];

        worldTabContent.contentSize = CGSizeMake(pW, wY + 48);

        [panel addSubview:combatTabContent];
        [panel addSubview:visualTabContent];
        [panel addSubview:worldTabContent];
        [vc.view addSubview:floatBtn];
        [vc.view addSubview:panel];

        vealixFloatBtn = floatBtn;
        vealixPanel = panel;

        [VealixActions refreshLocalization];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        if (!observerToken) {
            observerToken = [nc addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                if (vealixWindow) {
                    vealixWindow.hidden = NO;
                    [VealixActions updateLayoutForSize:vealixWindow.bounds.size];
                }
            }];
        }
    });
}

void __attribute__((constructor)) initVealixEngine() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BuildVeaLixInterface();
    });
}
