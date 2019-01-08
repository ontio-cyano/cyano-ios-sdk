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
    /*
     * TODO
     * 1.从 callbackDic 回调中解出 message
     * NSDictionary *params = callbackDic[@"params"];
     * NSString *message = params[@"message"];
     *
     * 2.将 message 转换成 hexString
     *
     * 3.弹出密码框,解出钱包account,对message进行签名，注意密码是base64EncodeString,并且耗时操作。
     *  （签名方法参考DEMO中TS SDK中signDataHex方法）
     *
     * 4.拼接返回结果，包括：action、version、error、desc、id、type、publicKey、address、
     *   message、signature                          
     * NSDictionary *result =@{@"type": @"account",
     *                         @"publicKey":钱包公钥,
     *                         @"address": 钱包地址,
     *                         @"message":message ,
     *                         @"signature":签名结果,
     *                         };
     * NSDictionary *callBackMessage =@{@"action":@"login",
     *                                  @"version": @"v1.0.0",
     *                                  @"error": @0,
     *                                  @"desc": @"SUCCESS",
     *                                  @"result":result,
     *                                  @"id":callbackDic[@"id"]
     *                                  };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```

##### action: GetAccount

```
[webView setGetAccountCallback:^(NSDictionary *callbackDic) {
    /*
     * TODO
     * 1.发送钱包地址到webView
     * NSDictionary *callBackMessage =@{@"action":@"getAccount",
     *                                  @"version":@"v1.0.0",
     *                                  @"error":@0,
     *                                  @"desc":@"SUCCESS",
     *                                  @"result":钱包地址,
     *                                  @"id":callbackDic[@"id"]
     *                                  };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```

##### action: Invoke

```
[webView setInvokeTransactionCallback:^(NSDictionary *callbackDic) {
    /* TODO
     * 1.弹出密码框，解出钱包明文私钥
     *
     * 2.将 callbackDic 转换成 jsonString 并以此构造交易（构造交易方法参考DEMO中TS SDK 中 
     *   makeDappTransaction 方法）
     *
     * 3.预执行交易（预执行交易方法参考DEMO中TS SDK 中 checkTransaction 方法），并解析结果，注意耗时
     *   操作
     *
     * 4.将预知行结果解析出Notify结果，显示手续费，如果结果中包含ONT,ONG合约地址，需显示转账金额和收款
     *   地址，
     *
     * 5.用户确认后发送交易到链上
     *
     * 6.发送交易hash到webView
     * NSDictionary *callBackMessage = @{@"action":@"invoke",
     *                                 @"version": @"v1.0.0",
     *                                 @"error": @0,
     *                                 @"desc": @"SUCCESS",
     *                                 @"result":交易hash,
     *                                 @"id":callbackDic[@"id"]
     *                                 };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```



##### action: InvokeRead

```
[webView setInvokeReadCallback:^(NSDictionary *callbackDic) {
    /* TODO
     * 1.将 callbackDic 转换成 jsonString 并以此构造交易（构造交易方法参考DEMO中TS SDK 中 
     *   makeDappInvokeReadTransaction 方法）
     *
     * 2.预执行交易（预执行交易方法参考DEMO中TS SDK 中 checkTransaction 方法），并解析结果，注意耗时
     *   操作
     *
     * 3.将预知行结果解析出Notify结果，显示手续费，如果结果中包含ONT,ONG合约地址，需显示转账金额和收款
     *   地址，
     *
     * 4.用户确认后发送交易到链上
     *
     * 5.发送交易hash到webView
     * NSDictionary *callBackMessage = @{@"action":@"InvokeRead",
     *                                 @"version": @"v1.0.0",
     *                                 @"error": @0,
     *                                 @"desc": @"SUCCESS",
     *                                 @"result":交易hash,
     *                                 @"id":callbackDic[@"id"]
     *                                 };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```



##### action: InvokePasswordFree

```
[webView setInvokePasswordFreeCallback:^(NSDictionary *callbackDic) {
    /* TODO
     * 1.第一次操作和action：Invoke相同，保存password，解出callbackDic[@"params"]并转换成
     *   jsonString 并保存
     *
     * 2.当第二次收到相同的 callbackDic[@"params"] 时候，将用保存的密码进行签名，预知行获取结果
     *
     * 3.预知行结果不用显示给用户确认
     *
     * 4.发送交易hash到webView
     * NSDictionary *callBackMessage = @{@"action":@"InvokePasswordFree",
     *                                 @"version": @"v1.0.0",
     *                                 @"error": @0,
     *                                 @"desc": @"SUCCESS",
     *                                 @"result":交易hash,
     *                                 @"id":callbackDic[@"id"]
     *                                 };
     * [webView sendMessageToWeb:callBackMessage];
     * 
     * 注意:进入页面或者返回上一页面时,清除保存的密码等信息
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

