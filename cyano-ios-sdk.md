# cyano-ios-sdk

cyano-ios-sdk 帮助 iOS webview和网页dapp之间通信。它对iOS webview进行了一些方法的封装。

> webview通信的方式是window.postmeaage()

## 如何使用

- 将 CyanoRNWebView.framework 导入项目
- #import "RNJsWebView.h"

### 示例

#### 初始化

```
RNJsWebView * webView = [[RNJsWebView alloc]initWithFrame:CGRectZero];
[webView setURL:@""];
```

##### data

消息体data格式为json字符串

```
{
	"action": "login",
	"params": {
		"type": "account",
		"dappName": "My dapp",
		"message": "test message",
		"expired": "201812181000",
		"callback": ""
	}
}
```

##### message

对消息体 data 进行 decode 并 base64 加密,然后在拼接后的字符串首位再拼接上 ontprovider://ont.io?params= 作为网页端传来的原文数据

##### action: Login

```
[webView setLoginCallback:^(NSDictionary *callbackDic) {
    
}];
```

##### action: GetAccount

```
[webView setGetAccountCallback:^(NSDictionary *callbackDic) {
    
}];
```

##### action: Invoke

```
[webView setInvokeTransactionCallback:^(NSDictionary *callbackDic) {

}];
```



##### action: InvokeRead

```
[webView setInvokeReadCallback:^(NSDictionary *callbackDic) {
    
}];
```



##### action: InvokePasswordFree

```
[webView setInvokePasswordFreeCallback:^(NSDictionary *callbackDic) {
    
}];
```

##### action: sendMessageToWeb

```
NSDictionary *params = @{@"action":@"",
                         @"version":@"v1.0.0",
                         @"error":@0,
                         @"desc":@"SUCCESS",
                         @"result":@""
                         };
[webView sendMessageToWeb:params];
```

## DEMO

#### [cyano-ios](https://github.com/ontio-cyano/cyano-ios.git)

