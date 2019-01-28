//
//  CeshiViewController.m
//  cyano
//
//  Created by Apple on 2018/12/21.
//  Copyright © 2018 LR. All rights reserved.
//

#import "ONTOWebViewController.h"
#import <WebKit/WebKit.h>
#import "Common.h"
#import "ONTOMBProgressHUD.h"
#import "UILabel+changeSpace.h"
#import "ToastUtil.h"
#import "Masonry.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface ONTOWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler> {
    WKWebView      *webView;
    UIButton       *promptButton;
    NSString       *resultString;
}
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, copy)   NSString *confirmPwd;
@property(nonatomic, copy)   NSString *confirmSurePwd;
@property(nonatomic, copy)   NSString       *hashString;
@property(nonatomic, strong) ONTOMBProgressHUD *hub;
@property(nonatomic, assign) BOOL isLogin;
@property(nonatomic, strong) NSDictionary   *promptDic;
@property(nonatomic, strong) UIWindow         *window;
@property(nonatomic, assign) BOOL isFirst;
@end

@implementation ONTOWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNav];
    [self configUI];
    self.isLogin = YES;
    self.isFirst = YES;
    [self loadWeb];
    
    self.progressView =
    [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 1)];
    self.progressView.backgroundColor = [Common colorWithHexString:@"#32A4BE"];
    self.progressView.tintColor = [Common colorWithHexString:@"#35BFDF"];
    
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [webView.configuration.userContentController addScriptMessageHandler:self name:@"JSCallback"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            }                completion:^(BOOL finished) {
                
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)configUI {
    
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc]init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.userContentController = [[WKUserContentController alloc]init];
    config.processPool = [[WKProcessPool alloc]init];
    webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];

    
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

// 导航栏设置
- (void)configNav {
    [self setNavLeftImageIcon:[UIImage imageNamed:@"BackWhite"] Title:@""];
    
}

// 返回
- (void)navLeftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

// 加载网页
- (void)loadWeb {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_dappUrl]]];
}

//将NSString转换成十六进制的字符串则可使用如下方式:
- (NSString *)convertStringToHexStr:(NSString *)str {
    if (!str || [str length] == 0) {
        return @"";
    }
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char *) bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

#pragma mark WKWebViewDelegate
/**
 webview加载完成
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"js finish！！！");
    //    _callbackJSFinish();
    [self setupPostMessageScript];
    
    [ONTOMBProgressHUD hideHUDForView:self.view animated:YES];
    [ONTOMBProgressHUD hideHUDForView:self.view animated:YES];

    self.progressView.hidden = YES;
    
}
- (void)setupPostMessageScript {
    
    NSString *source = @"window.originalPostMessage = window.postMessage;"
    "window.postMessage = function(message, targetOrigin, transfer) {"
    "window.webkit.messageHandlers.JSCallback.postMessage(message);"
    "if (typeof targetOrigin !== 'undefined') {"
    "window.originalPostMessage(message, targetOrigin, transfer);"
    "}"
    "};";
    
    
    
    WKUserScript *script = [[WKUserScript alloc] initWithSource:source
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:false];
    [webView.configuration.userContentController addUserScript:script];
    [webView evaluateJavaScript:source completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    
}
- (void)postMessage:(NSString *)message
{
    NSDictionary *eventInitDict = @{
                                    @"data": message,
                                    };
    NSString *source = [NSString
                        stringWithFormat:@"document.dispatchEvent(new MessageEvent('message', %@));",
                        [Common dictionaryToJson:eventInitDict]
                        ];
    
    
    [webView evaluateJavaScript:source completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}
/**
 webview开始加载
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"js start！！！");
    [ONTOMBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
    
}
- (void)dealloc {
    [webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [webView.configuration.userContentController removeScriptMessageHandlerForName:@"JSCallback"];
}
/**
 webview加载失败
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"js error！！！");
    [_hub hideAnimated:YES];
    self.progressView.hidden = YES;
}

/**
 webview拦截alert
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(
                                                                                                                                                              void))completionHandler {
    NSLog(@"alert=%@", message);
    completionHandler();
}

/**
 webview拦截Confirm
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(
                                                                                                                                                                BOOL))completionHandler {
    NSLog(@"confirm=%@", message);
    completionHandler(YES);
}

/**
 webview拦截Prompt
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(
                                                                                                                                                                                                    NSString *_Nullable))completionHandler {
    
    //    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"prompt===%@", prompt);
//    [self savePrompt:prompt];
    completionHandler(@"123");
}

/**
 webview拦截js方法
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message:%@", message);
    if ([message.name isEqualToString:@"JSCallback"]) {
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
}

//- (void)viewWillAppear:(BOOL)animated {
//
//    [super viewWillAppear:animated];
//    NSString
//    *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
//    NSError *errors;
//    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
//}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

