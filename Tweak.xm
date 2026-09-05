#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static UIWindow *vealixWindow = nil;
static WKWebView *vealixWebView = nil;

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

    vealixWindow.windowLevel = UIWindowLevelAlert + 1; // Oyunun her katmanının en üstünde yer alır
    vealixWindow.backgroundColor = [UIColor clearColor];
    vealixWindow.hidden = NO;

    UIViewController *emptyVC = [[UIViewController alloc] init];
    emptyVC.view.backgroundColor = [UIColor clearColor];
    vealixWindow.rootViewController = emptyVC;

    CGRect screenBounds = emptyVC.view.bounds;

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;

    vealixWebView = [[WKWebView alloc] initWithFrame:screenBounds configuration:config];
    vealixWebView.backgroundColor = [UIColor clearColor];
    vealixWebView.opaque = NO;
    vealixWebView.userInteractionEnabled = YES;
    vealixWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    vealixWebView.scrollView.scrollEnabled = NO;

    NSString *htmlContent = @""
    "<!DOCTYPE html>"
    "<html lang='tr'>"
    "<head>"
    "<meta charset='UTF-8'>"
    "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>"
    "<style>"
    "* { box-sizing: border-box; user-select: none; -webkit-user-select: none; }"
    "body { margin: 0; padding: 0; background: transparent; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; overflow: hidden; width: 100vw; height: 100vh; pointer-events: none; }"
    
    "#vealix-toggle-btn { position: absolute; top: 60px; left: 40px; width: 65px; height: 65px; background: rgba(10, 10, 15, 0.95); border: 2px solid #00f2fe; border-radius: 50%; box-shadow: 0 0 15px rgba(0, 242, 254, 0.7); display: flex; flex-direction: column; justify-content: center; align-items: center; cursor: pointer; z-index: 2147483647; pointer-events: auto; }"
    "#vealix-toggle-btn:active { transform: scale(0.92); }"
    ".btn-text-main { font-size: 8px; font-weight: 900; color: #00f2fe; text-shadow: 0 0 6px rgba(0,242,254,0.8); letter-spacing: 0.5px; }"
    ".btn-text-sub { font-size: 5px; font-weight: 700; color: #94a3b8; margin-top: 2px; text-align: center; }"

    "#vealix-menu { position: absolute; top: 140px; left: 40px; width: 280px; background: rgba(15, 15, 20, 0.96); border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 16px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.8), 0 0 25px rgba(0, 242, 254, 0.2); z-index: 2147483646; color: #fff; overflow: hidden; display: none; pointer-events: auto; }"
    "#vealix-menu.show { display: block; }"
    
    ".menu-header { padding: 12px 16px; background: linear-gradient(135deg, rgba(0, 242, 254, 0.2), rgba(79, 172, 254, 0.2)); border-bottom: 1px solid rgba(255, 255, 255, 0.08); display: flex; justify-content: space-between; align-items: center; }"
    ".menu-title { font-size: 13px; font-weight: 700; letter-spacing: 0.5px; background: linear-gradient(45deg, #00f2fe, #4facfe); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }"
    ".tiktok-badge { font-size: 9px; color: #94a3b8; background: rgba(255,255,255,0.06); padding: 2px 6px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.05); }"
    ".menu-body { padding: 12px; max-height: 380px; overflow-y: auto; }"
    ".feature-group { background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.06); border-radius: 10px; padding: 10px 12px; margin-bottom: 8px; }"
    ".feature-row { display: flex; justify-content: space-between; align-items: center; }"
    ".feature-name { font-size: 11px; font-weight: 600; color: #e2e8f0; }"
    ".switch { position: relative; display: inline-block; width: 36px; height: 20px; }"
    ".switch input { opacity: 0; width: 0; height: 0; }"
    ".slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(255, 255, 255, 0.2); transition: .3s cubic-bezier(0.4, 0, 0.2, 1); border-radius: 20px; }"
    ".slider:before { position: absolute; content: ''; height: 14px; width: 14px; left: 3px; bottom: 3px; background-color: white; transition: .3s cubic-bezier(0.4, 0, 0.2, 1); border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.3); }"
    "input:checked + .slider { background: linear-gradient(135deg, #00f2fe, #4facfe); }"
    "input:checked + .slider:before { transform: translateX(16px); }"
    ".range-container { margin-top: 8px; padding-top: 6px; border-top: 1px solid rgba(255,255,255,0.05); display: none; }"
    ".range-container.active { display: block; }"
    ".range-header { display: flex; justify-content: space-between; font-size: 9px; color: #94a3b8; margin-bottom: 4px; }"
    "input[type=range] { width: 100%; -webkit-appearance: none; background: rgba(255,255,255,0.1); height: 4px; border-radius: 2px; outline: none; }"
    "input[type=range]::-webkit-slider-thumb { -webkit-appearance: none; width: 12px; height: 12px; border-radius: 50%; background: #00f2fe; cursor: pointer; box-shadow: 0 0 6px rgba(0,242,254,0.6); }"
    "</style>"
    "</head>"
    "<body>"
    
    "<div id='vealix-toggle-btn' onclick='toggleMenu()'>"
    "<span class='btn-text-main'>VEALIX</span>"
    "<span class='btn-text-sub'>HACK</span>"
    "</div>"

    "<div id='vealix-menu'>"
    "<div class='menu-header' id='menu-header'>"
    "<span class='menu-title'>VeaLixHack v2.0</span>"
    "<span class='tiktok-badge'>TikTok: vealixbl</span>"
    "</div>"
    "<div class='menu-body'>"
    
    "<div class='feature-group'>"
    "<div class='feature-row'><span class='feature-name'>ESP</span>"
    "<label class='switch'><input type='checkbox' onchange='notifyFeature(this, \"ESP\")'><span class='slider'></span></label></div>"
    "</div>"
    
    "<div class='feature-group'>"
    "<div class='feature-row'><span class='feature-name'>Kill Aura</span>"
    "<label class='switch'><input type='checkbox' onchange=\"toggleRange('range-killaura', this.checked); notifyFeature(this, 'Kill Aura');\"><span class='slider'></span></label></div>"
    "<div class='range-container' id='range-killaura'>"
    "<div class='range-header'><span>Mesafe Algılama</span><span id='val-killaura'>20m</span></div>"
    "<input type='range' min='1' max='50' value='20' oninput=\"document.getElementById('val-killaura').innerText = this.value + 'm'\">"
    "</div></div>"
    
    "<div class='feature-group'>"
    "<div class='feature-row'><span class='feature-name'>Aimbot</span>"
    "<label class='switch'><input type='checkbox' onchange=\"toggleRange('range-aimbot', this.checked); notifyFeature(this, 'Aimbot');\"><span class='slider'></span></label></div>"
    "<div class='range-container' id='range-aimbot'>"
    "<div class='range-header'><span>Mesafe Algılama</span><span id='val-aimbot'>20m</span></div>"
    "<input type='range' min='1' max='50' value='20' oninput=\"document.getElementById('val-aimbot').innerText = this.value + 'm'\">"
    "</div></div>"
    
    "<div class='feature-group'>"
    "<div class='feature-row'><span class='feature-name'>Attack Macro (50 CPS)</span>"
    "<label class='switch'><input type='checkbox' onchange='notifyFeature(this, \"Attack Macro\")'><span class='slider'></span></label></div>"
    "</div>"
    
    "<div class='feature-group'>"
    "<div class='feature-row'><span class='feature-name'>360 SpinBot</span>"
    "<label class='switch'><input type='checkbox' onchange='notifyFeature(this, \"SpinBot\")'><span class='slider'></span></label></div>"
    "</div>"
    
    "<div class='feature-group'>"
    "<div class='feature-row'><span class='feature-name'>Block Macro (50 CPS)</span>"
    "<label class='switch'><input type='checkbox' onchange='notifyFeature(this, \"Block Macro\")'><span class='slider'></span></label></div>"
    "</div>"
    
    "</div></div>"
    
    "<script>"
    "const menu = document.getElementById('vealix-menu');"
    
    "function toggleMenu() {"
    "  menu.classList.toggle('show');"
    "}"
    
    "function notifyFeature(checkbox, name) {"
    "  const status = checkbox.checked ? 'Açıldı!' : 'Kapandı!';"
    "  console.log(name + ' ' + status);"
    "}"
    
    "function toggleRange(id, show) {"
    "  const el = document.getElementById(id);"
    "  if (show) { el.classList.add('active'); } else { el.classList.remove('active'); }"
    "}"
    "</script>"
    "</body>"
    "</html>";

    [vealixWebView loadHTMLString:htmlContent baseURL:nil];
    [emptyVC.view addSubview:vealixWebView];
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
