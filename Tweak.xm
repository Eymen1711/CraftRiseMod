#import <UIKit/UIKit.h>

// Özellik Değişkenleri ve Mesafeler (Slider Değerleri)
static bool isKillAuraEnabled = false;
static float killAuraRange = 10.0f;

static bool isESPEnabled = false;
static float espRange = 10.0f;

static bool isMacroEnabled = false;
static float macroRange = 10.0f;

static bool isMacroBlockEnabled = false;
static bool isSpinBotEnabled = false;
static float spinSpeed = 35.0f;

// 1. Oyun içi döngü ve özellik kancaları (Hook)
void (*old_PlayerController_Update)(id self, SEL _cmd);
void new_PlayerController_Update(id self, SEL _cmd) {
    old_PlayerController_Update(self, _cmd);
    
    // 360 SpinBot mantığı
    if (isSpinBotEnabled) {
        Ivar rotationIvar = class_getInstanceVariable(object_getClass(self), "cameraYaw");
        if (rotationIvar) {
            float *yaw = (float *)((uint8_t *)self + ivar_getOffset(rotationIvar));
            *yaw += spinSpeed;
            if (*yaw >= 360.0f) *yaw = 0.0f;
        }
    }
}

// 2. Mod Menüsü Arayüzü (UI) ve Sürgülü Mesafe Çubukları
@interface ModMenuViewController : UIViewController
@end

@implementation ModMenuViewController {
    UIView *menuView;
    UIButton *floatingButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ekrandaki küçük açma/kapama butonu (VeaLix Hack / TikTok)
    floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    floatingButton.frame = CGRectMake(20, 100, 90, 60);
    floatingButton.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.8f];
    [floatingButton setTitle:@"VeaLix\nHack" forState:UIControlStateNormal];
    floatingButton.titleLabel.numberOfLines = 2;
    floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [floatingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    floatingButton.layer.cornerRadius = 10;
    [floatingButton addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:floatingButton];
    
    // Büyük Mod Menüsü (Daha uzun boyutta, slider'lar sığması için)
    menuView = [[UIView alloc] initWithFrame:CGRectMake(130, 50, 280, 520)];
    menuView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.95f];
    menuView.layer.cornerRadius = 15;
    menuView.hidden = YES;
    [keyWindow addSubview:menuView];
    
    // TikTok Başlık Bilgisi
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 260, 25)];
    titleLabel.text = @"TikTok: vealixbl";
    titleLabel.textColor = [UIColor cyanColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [menuView addSubview:titleLabel];
    
    // --- ESP (Buton + Slider) ---
    UIButton *espButton = [UIButton buttonWithType:UIButtonTypeCustom];
    espButton.frame = CGRectMake(15, 40, 250, 32);
    [espButton setTitle:@"ESP: OFF" forState:UIControlStateNormal];
    [espButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    espButton.backgroundColor = [UIColor redColor];
    espButton.layer.cornerRadius = 6;
    [espButton addTarget:self action:@selector(toggleESP:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:espButton];
    
    UISlider *espSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, 75, 250, 20)];
    espSlider.minimumValue = 10.0f;
    espSlider.maximumValue = 100.0f;
    espSlider.value = 10.0f;
    [espSlider addTarget:self action:@selector(sliderESP:) forControlEvents:UIControlEventValueChanged];
    [menuView addSubview:espSlider];
    
    // --- Kill Aura (Buton + Slider) ---
    UIButton *kaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    kaButton.frame = CGRectMake(15, 105, 250, 32);
    [kaButton setTitle:@"Kill Aura: OFF" forState:UIControlStateNormal];
    [kaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    kaButton.backgroundColor = [UIColor redColor];
    kaButton.layer.cornerRadius = 6;
    [kaButton addTarget:self action:@selector(toggleKillAura:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:kaButton];
    
    UISlider *kaSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, 140, 250, 20)];
    kaSlider.minimumValue = 10.0f;
    kaSlider.maximumValue = 100.0f;
    kaSlider.value = 10.0f;
    [kaSlider addTarget:self action:@selector(sliderKA:) forControlEvents:UIControlEventValueChanged];
    [menuView addSubview:kaSlider];
    
    // --- 50 CPS Macro (Buton + Slider) ---
    UIButton *macroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    macroButton.frame = CGRectMake(15, 170, 250, 32);
    [macroButton setTitle:@"50 CPS Macro: OFF" forState:UIControlStateNormal];
    [macroButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    macroButton.backgroundColor = [UIColor redColor];
    macroButton.layer.cornerRadius = 6;
    [macroButton addTarget:self action:@selector(toggleMacro:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:macroButton];
    
    UISlider *macroSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, 205, 250, 20)];
    macroSlider.minimumValue = 10.0f;
    macroSlider.maximumValue = 100.0f;
    macroSlider.value = 10.0f;
    [macroSlider addTarget:self action:@selector(sliderMacro:) forControlEvents:UIControlEventValueChanged];
    [menuView addSubview:macroSlider];
    
    // --- 360 SpinBot (Sadece Buton) ---
    UIButton *aimButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aimButton.frame = CGRectMake(15, 240, 250, 38];
    [aimButton setTitle:@"360 SpinBot: OFF" forState:UIControlStateNormal];
    [aimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aimButton.backgroundColor = [UIColor redColor];
    aimButton.layer.cornerRadius = 6;
    [aimButton addTarget:self action:@selector(toggleSpinBot:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:aimButton];
    
    // --- Macro Block (Sadece Buton - Ayrı) ---
    UIButton *blockMacroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    blockMacroButton.frame = CGRectMake(15, 290, 250, 38];
    [blockMacroButton setTitle:@"Macro Block: OFF" forState:UIControlStateNormal];
    [blockMacroButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    blockMacroButton.backgroundColor = [UIColor redColor];
    blockMacroButton.layer.cornerRadius = 6;
    [blockMacroButton addTarget:self action:@selector(toggleBlockMacro:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:blockMacroButton];
}

// Menü Açma Kapatma
- (void)toggleMenu:(UIButton *)sender {
    menuView.hidden = !menuView.hidden;
}

// ESP Kontrolleri
- (void)toggleESP:(UIButton *)sender {
    isESPEnabled = !isESPEnabled;
    sender.backgroundColor = isESPEnabled ? [UIColor greenColor] : [UIColor redColor];
    [sender setTitle:isESPEnabled ? @"ESP: ON" : @"ESP: OFF" forState:UIControlStateNormal];
}
- (void)sliderESP:(UISlider *)sender { espRange = sender.value; }

// Kill Aura Kontrolleri
- (void)toggleKillAura:(UIButton *)sender {
    isKillAuraEnabled = !isKillAuraEnabled;
    sender.backgroundColor = isKillAuraEnabled ? [UIColor greenColor] : [UIColor redColor];
    [sender setTitle:isKillAuraEnabled ? @"Kill Aura: ON" : @"Kill Aura: OFF" forState:UIControlStateNormal];
}
- (void)sliderKA:(UISlider *)sender { killAuraRange = sender.value; }

// 50 CPS Macro Kontrolleri
- (void)toggleMacro:(UIButton *)sender {
    isMacroEnabled = !isMacroEnabled;
    sender.backgroundColor = isMacroEnabled ? [UIColor greenColor] : [UIColor redColor];
    [sender setTitle:isMacroEnabled ? @"50 CPS Macro: ON" : @"50 CPS Macro: OFF" forState:UIControlStateNormal];
}
- (void)sliderMacro:(UISlider *)sender { macroRange = sender.value; }

// 360 SpinBot Kontrolü
- (void)toggleSpinBot:(UIButton *)sender {
    isSpinBotEnabled = !isSpinBotEnabled;
    sender.backgroundColor = isSpinBotEnabled ? [UIColor greenColor] : [UIColor redColor];
    [sender setTitle:isSpinBotEnabled ? @"360 SpinBot: ON" : @"360 SpinBot: OFF" forState:UIControlStateNormal];
}

// Macro Block Kontrolü (Ayrı)
- (void)toggleBlockMacro:(UIButton *)sender {
    isMacroBlockEnabled = !isMacroBlockEnabled;
    sender.backgroundColor = isMacroBlockEnabled ? [UIColor greenColor] : [UIColor redColor];
    [sender setTitle:isMacroBlockEnabled ? @"Macro Block: ON" : @"Macro Block: OFF" forState:UIControlStateNormal];
}

@end

// Constructor
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ModMenuViewController *menuController = [[ModMenuViewController alloc] init];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:menuController animated:YES completion:nil];
    });
}