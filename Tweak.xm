#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface VeaLixWindow : UIWindow
@end

@implementation VeaLixWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}
@end

static VeaLixWindow *vealixWindow = nil;
static WKWebView *vealixWebView = nil;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!vealixWindow) {
            CGRect frame = [UIScreen mainScreen].bounds;
            vealixWindow = [[VeaLixWindow alloc] initWithFrame:frame];
            vealixWindow.windowLevel = UIWindowLevelAlert + 9999;
            vealixWindow.hidden = NO;
            vealixWindow.backgroundColor = [UIColor clearColor];

            UIViewController *rootVC = [[UIViewController alloc] init];
            rootVC.view.backgroundColor = [UIColor clearColor];
            vealixWindow.rootViewController = rootVC;

            WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
            vealixWebView = [[WKWebView alloc] initWithFrame:rootVC.view.bounds configuration:config];
            vealixWebView.backgroundColor = [UIColor clearColor];
            vealixWebView.opaque = NO;
            
            NSString *htmlContent = @""
            "<!DOCTYPE html>"
            "<html lang='tr'>"
            "<head>"
            "<meta charset='UTF-8'>"
            "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
            "<style>"
            "* { box-sizing: border-box; user-select: none; -webkit-user-select: none; }"
            "body { margin: 0; padding: 0; background: transparent; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow: hidden; }"
            
            /* Açma/Kapama Yüzen Logo Butonu */
            "#vealix-toggle-btn { position: absolute; top: 40px; left: 40px; width: 70px; height: 70px; background: rgba(10, 10, 15, 0.9); border: 2px solid #00f2fe; border-radius: 50%; box-shadow: 0 0 15px rgba(0, 242, 254, 0.6), inset 0 0 10px rgba(0, 242, 254, 0.4); display: flex; flex-direction: column; justify-content: center; align-items: center; cursor: pointer; z-index: 10000; transition: transform 0.1s; }"
            "#vealix-toggle-btn:active { transform: scale(0.92); }"
            ".btn-text-main { font-size: 9px; font-weight: 900; color: #00f2fe; text-shadow: 0 0 6px rgba(0,242,254,0.8); letter-spacing: 0.5px; }"
            ".btn-text-sub { font-size: 6px; font-weight: 700; color: #94a3b8; margin-top: 2px; text-align: center; }"

            /* Ana Menü Tasarımı */
            "#vealix-menu { position: absolute; top: 120px; left: 40px; width: 280px; background: rgba(18, 18, 24, 0.88); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); border: 1px solid rgba(255, 255, 255, 0.12); border-radius: 16px; box-shadow: 0 15px 35px rgba(0, 0, 0, 0.7), 0 0 20px rgba(0, 242, 254, 0.15); z-index: 9999; color: #fff; overflow: hidden; display: none; }"
            "#vealix-menu.show { display: block; }"
            
            ".menu-header { padding: 12px 16px; background: linear-gradient(135deg, rgba(0, 242, 254, 0.18), rgba(79, 172, 254, 0.18)); border-bottom: 1px solid rgba(255, 255, 255, 0.08); cursor: grab; display: flex; justify-content: space-between; align-items: center; }"
            ".menu-header:active { cursor: grabbing; }"
            ".menu-title { font-size: 14px; font-weight: 700; letter-spacing: 0.5px; background: linear-gradient(45deg, #00f2fe, #4facfe); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }"
            ".tiktok-badge { font-size: 10px; color: #94a3b8; background: rgba(255,255,255,0.06); padding: 2px 6px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.05); }"
            ".menu-body { padding: 14px; max-height: 420px; overflow-y: auto; }"
            ".feature-group { background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.06); border-radius: 10px; padding: 10px 12px; margin-bottom: 10px; }"
            ".feature-row { display: flex; justify-content: space-between; align-items: center; }"
            ".feature-name { font-size: 12px; font-weight: 600; color: #e2e8f0; }"
            ".switch { position: relative; display: inline-block; width: 38px; height: 20px; }"
            ".switch input { opacity: 0; width: 0; height: 0; }"
            ".slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(255, 255, 255, 0.2); transition: .3s cubic-bezier(0.4, 0, 0.2, 1); border-radius: 20px; }"
            ".slider:before { position: absolute; content: ''; height: 14px; width: 14px; left: 3px; bottom: 3px; background-color: white; transition: .3s cubic-bezier(0.4, 0, 0.2, 1); border-radius: 50%; box-shadow: 0 2px 4px rgba(0,0,0,0.3); }"
            "input:checked + .slider { background: linear-gradient(135deg, #00f2fe, #4facfe); }"
            "input:checked + .slider:before { transform: translateX(18px); }"
            ".range-container { margin-top: 8px; padding-top: 6px; border-top: 1px solid rgba(255,255,255,0.05); display: none; }"
            ".range-container.active { display: block; }"
            ".range-header { display: flex; justify-content: space-between; font-size: 10px; color: #94a3b8; margin-bottom: 4px; }"
            "input[type=range] { width: 100%; -webkit-appearance: none; background: rgba(255,255,255,0.1); height: 4px; border-radius: 2px; outline: none; }"
            "input[type=range]::-webkit-slider-thumb { -webkit-appearance: none; width: 12px; height: 12px; border-radius: 50%; background: #00f2fe; cursor: pointer; box-shadow: 0 0 6px rgba(0,242,254,0.6); }"
            "</style>"
            "</head>"
            "<body>"
            
            // Yuvarlak Logolu Açma/Kapama Butonu
            "<div id='vealix-toggle-btn' onclick='toggleMenu()'>"
            "<span class='btn-text-main'>VEALIX</span>"
            "<span class='btn-text-sub'>HACK</span>"
            "</div>"

            // Ana Menü
            "<div id='vealix-menu'>"
            "<div class='menu-header' id='menu-header'>"
            "<span class='menu-title'>VeaLixHack v2.0</span>"
            "<span class='tiktok-badge'>TikTok: vealixbl</span>"
            "</div>"
            "<div class='menu-body'>"
            
            // ESP
            "<div class='feature-group'>"
            "<div class='feature-row'><span class='feature-name'>ESP</span>"
            "<label class='switch'><input type='checkbox'><span class='slider'></span></label></div>"
            "</div>"
            
            // Kill Aura (1-50m, 20m)
            "<div class='feature-group'>"
            "<div class='feature-row'><span class='feature-name'>Kill Aura</span>"
            "<label class='switch'><input type='checkbox' onchange=\"toggleRange('range-killaura', this.checked)\"><span class='slider'></span></label></div>"
            "<div class='range-container' id='range-killaura'>"
            "<div class='range-header'><span>Mesafe Algılama</span><span id='val-killaura'>20m</span></div>"
            "<input type='range' min='1' max='50' value='20' oninput=\"document.getElementById('val-killaura').innerText = this.value + 'm'\">"
            "</div></div>"
            
            // Aimbot (1-50m, 20m)
            "<div class='feature-group'>"
            "<div class='feature-row'><span class='feature-name'>Aimbot</span>"
            "<label class='switch'><input type='checkbox' onchange=\"toggleRange('range-aimbot', this.checked)\"><span class='slider'></span></label></div>"
            "<div class='range-container' id='range-aimbot'>"
            "<div class='range-header'><span>Mesafe Algılama</span><span id='val-aimbot'>20m</span></div>"
            "<input type='range' min='1' max='50' value='20' oninput=\"document.getElementById('val-aimbot').innerText = this.value + 'm'\">"
            "</div></div>"
            
            // Attack Macro
            "<div class='feature-group'>"
            "<div class='feature-row'><span class='feature-name'>Attack Macro (50 CPS)</span>"
            "<label class='switch'><input type='checkbox'><span class='slider'></span></label></div>"
            "</div>"
            
            // 360 SpinBot
            "<div class='feature-group'>"
            "<div class='feature-row'><span class='feature-name'>360 SpinBot</span>"
            "<label class='switch'><input type='checkbox'><span class='slider'></span></label></div>"
            "</div>"
            
            // Block Macro
            "<div class='feature-group'>"
            "<div class='feature-row'><span class='feature-name'>Block Macro (50 CPS)</span>"
            "<label class='switch'><input type='checkbox'><span class='slider'></span></label></div>"
            "</div>"
            
            "</div></div>"
            
            "<script>"
            "const menu = document.getElementById('vealix-menu');"
            "const toggleBtn = document.getElementById('vealix-toggle-btn');"
            "const header = document.getElementById('menu-header');"
            
            "function toggleMenu() {"
            "  menu.classList.toggle('show');"
            "}"
            
            // Buton Sürükleme Mantığı
            "let isDraggingBtn = false, btnStartX, btnStartY;"
            "toggleBtn.addEventListener('touchstart', e => { isDraggingBtn = true; btnStartX = e.touches[0].clientX - toggleBtn.offsetLeft; btnStartY = e.touches[0].clientY - toggleBtn.offsetTop; }, {passive: true});"
            "document.addEventListener('touchmove', e => { if (!isDraggingBtn) return; toggleBtn.style.left = (e.touches[0].clientX - btnStartX) + 'px'; toggleBtn.style.top = (e.touches[0].clientY - btnStartY) + 'px'; }, {passive: true});"
            "document.addEventListener('touchend', () => { isDraggingBtn = false; });"
            
            // Menü Sürükleme Mantığı
            "let isDraggingMenu = false, menuStartX, menuStartY;"
            "header.addEventListener('touchstart', e => { isDraggingMenu = true; menuStartX = e.touches[0].clientX - menu.offsetLeft; menuStartY = e.touches[0].clientY - menu.offsetTop; }, {passive: true});"
            "document.addEventListener('touchmove', e => { if (!isDraggingMenu) return; menu.style.left = (e.touches[0].clientX - menuStartX) + 'px'; menu.style.top = (e.touches[0].clientY - menuStartY) + 'px'; }, {passive: true});"
            "document.addEventListener('touchend', () => { isDraggingMenu = false; });"
            
            "function toggleRange(id, show) {"
            "  const el = document.getElementById(id);"
            "  if (show) { el.classList.add('active'); } else { el.classList.remove('active'); }"
            "}"
            "</script>"
            "</body>"
            "</html>";

            [vealixWebView loadHTMLString:htmlContent baseURL:nil];
            [rootVC.view addSubview:vealixWebView];
            [vealixWindow makeKeyAndVisible];
        }
    });
}
