English | [中文](https://github.com/ontio-cyano/cyano-ios-sdk/blob/master/README_CN.md)

# cyano-ios-provider-sdk

Cyano-ios-sdk helps communication between iOS webview and webpage dapp. It encapsulates some methods for iOS webview.

> webview communication is done by window.postmessage()

* [Installation](#Installation)
* [Integration provider sdk](#Integration-provider-sdk)
* [ONTID(NOT SUPPORT)](#ONTID(NOT-SUPPORT))
    * [How to use](#How-to-use-ONTID)
    * [example](#use-example)
* [Wallet demo](#wallet-demo)


## Installation

Import the project as a module into the project, please refer to [CEP1 ](https://github.com/ontio-cyano/CEPs/blob/master/CEPS/CEP1.mediawiki) document for data format.

```
#import "RNJsWebView.h"
```
## Integration provider sdk

### initialization

```
RNJsWebView * webView = [[RNJsWebView alloc]initWithFrame:CGRectZero];
[webView setURL:@""];
```

#### data

The message body data format is a json string

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

Decode and base64 the message body data, and then stitch the first string of the concatenated string ontprovider://ont.io?params= as the original data from the web page

- ##### Login action: Login


```
[webView setLoginCallback:^(NSDictionary *callbackDic) {
    /*
     * TODO
     * 1.Solve the message from the callbackDic callback
     * NSDictionary *params = callbackDic[@"params"];
     * NSString *message = params[@"message"];
     *
     * 2.Convert message to hexString
     *
     * 3.The password box pops up, the wallet account is solved, the message is signed,                 
     *   and the password is base64EncodeString, and it takes time to operate.
     *  (Signature method refers to the signDataHex method in the TS SDK in DEMO)
     *
     * 4.Splicing returns results, including：action、version、error、desc、id、type、
     *   publicKey、address、message、signature                      
     * NSDictionary *result =@{@"type": @"account",
     *                         @"publickey":publicKey,
     *                         @"user": address,
     *                         @"message":message ,
     *                         @"signature":signature,
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

- ##### get account of wallet action: GetAccount


```
[webView setGetAccountCallback:^(NSDictionary *callbackDic) {
    /*
     * TODO
     * 1.Send wallet address to webView
     * NSDictionary *callBackMessage =@{@"action":@"getAccount",
     *                                  @"version":@"v1.0.0",
     *                                  @"error":@0,
     *                                  @"desc":@"SUCCESS",
     *                                  @"result":address,
     *                                  @"id":callbackDic[@"id"]
     *                                  };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```

- ##### invoke smartcontract action: Invoke


```
[webView setInvokeTransactionCallback:^(NSDictionary *callbackDic) {
    /* TODO
     * 1.Pop up the password box to unlock the wallet plaintext private key
     *
     * 2.Convert callbackDic to jsonString and construct the transaction (construct the 
     *   transaction method reference to the makeDappTransaction method in the TS SDK in 
     *   DEMO)
     *
     * 3.Pre-execute the transaction (pre-execution transaction method refers to the 
     *   checkTransaction method in the TS SDK in DEMO), and parse the result, paying 
     *   attention to time-consuming operations
     *
     * 4.The predicted line result is parsed out of the Notify result, and the handling 
     *   fee is displayed. If the result includes the ONT, ONG contract address, the 
     *   transfer amount and the receiving address are displayed.
     *
     * 5.Send the transaction to the chain after the user confirms
     *
     * 6.Send transaction hash to webView
     * NSDictionary *callBackMessage = @{@"action":@"invoke",
     *                                 @"version": @"v1.0.0",
     *                                 @"error": @0,
     *                                 @"desc": @"SUCCESS",
     *                                 @"result":Trading hash,
     *                                 @"id":callbackDic[@"id"]
     *                                 };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```



- ##### prepare execution smartcontract action: InvokeRead


```
[webView setInvokeReadCallback:^(NSDictionary *callbackDic) {
    /* TODO
     * 1.Convert callbackDic to jsonString and construct the transaction (construct the 
     *   transaction method with reference to the makeDappInvokeReadTransaction method in 
     *   the TS SDK in DEMO)
     *
     * 2.Pre-execute the transaction (pre-execution transaction method refers to the 
     *   checkTransaction method in the TS SDK in DEMO), and parse the result, paying 
     *   attention to time-consuming operations
     *
     * 3.The predicted line result is parsed out of the Notify result, and the handling 
     *   fee is displayed. If the result includes the ONT, ONG contract address, the 
     *   transfer amount and the receiving address are displayed.
     *
     * 4.Send the transaction to the chain after the user confirms
     *
     * 5.Send transaction hash to webView
     * NSDictionary *callBackMessage = @{@"action":@"InvokeRead",
     *                                 @"version": @"v1.0.0",
     *                                 @"error": @0,
     *                                 @"desc": @"SUCCESS",
     *                                 @"result":Trading hash,
     *                                 @"id":callbackDic[@"id"]
     *                                 };
     * [webView sendMessageToWeb:callBackMessage];
     */
}];
```



- ##### invoke smartcontract with no pwassword action: InvokePasswordFree


```
[webView setInvokePasswordFreeCallback:^(NSDictionary *callbackDic) {
    /* TODO
     * 1.The first operation is the same as action:Invoke, save the password, solve  
     *   callbackDic[@"params"] and convert it to jsonString and save it.
     *
     * 2.When the same callbackDic[@"params"] is received for the second time, it will be 
     *   signed with the saved password, and the prediction result will be obtained.
     *
     * 3.Predictive line results are not displayed to the user for confirmation
     *
     * 4.Send transaction hash to webView
     * NSDictionary *callBackMessage = @{@"action":@"InvokePasswordFree",
     *                                 @"version": @"v1.0.0",
     *                                 @"error": @0,
     *                                 @"desc": @"SUCCESS",
     *                                 @"result":Trading hash,
     *                                 @"id":callbackDic[@"id"]
     *                                 };
     * [webView sendMessageToWeb:callBackMessage];
     * 
     * Note: Clear the saved password and other information when entering the page or 
     *  returning to the previous page.
}];
```

- ##### sendMessage action: sendMessageToWeb


```
NSDictionary *params = @{@"action":@"",
                         @"version":@"v1.0.0",
                         @"error":@0,
                         @"desc":@"SUCCESS",
                         @"result":@""
                         };
[webView sendMessageToWeb:params];
```

## ONTID(NOT SUPPORT)

- ONT ID Authentication

  ```
  [webView setAuthenticationCallback:^(NSDictionary * callbackDic) {
       NSDictionary * params = callbackDic[@"params"];
       NSString * subaction = params[@"subaction"];
       NSArray * allSubaction = @[@"getRegistryOntidTx",@"submit",@"getIdentity"];
       NSInteger index = [allSubaction indexOfObject:subaction];
       
       switch (index) {
       case 0:
       /* TODO
        * 1.Send saved ONT_ID transactions to webView
        * NSDictionary *params = @{
        *                        @"action":@"authentication",
        *                        @"version":callbackDic[@"version"],
        *                        @"result":
        *                            @{
        *                                @"subaction":@"getRegistryOntidTx",
        *                                @"ontid":ontid,
        *                                @"registryOntidTx":registryOntidTx
        *                                },
        *                        @"id":callbackDic[@"id"],
        *                        @"error":@0,
        *                        @"desc":@"SUCCESS",
        *                        };
        *  [webView sendMessageToWeb:params];
        */
       break;
       case 1:
       /* TODO
        * 1.Send the returned H5 content back to the wallet backstage
        * 2.Return the sent result
        * NSDictionary *params = @{
        *                        @"action":@"authentication",
        *                        @"version":callbackDic[@"version"],
        *                        @"result":@1,
        *                        @"id":callbackDic[@"id"],
        *                        @"error":@0,
        *                        @"desc":@"SUCCESS",
        *                        };
        *  [webView sendMessageToWeb:params];
        */
       break;
       case 2:
       /* TODO
        * 1.Send ONT_ID to webView
        * NSDictionary *params = @{
        *                        @"action":@"authentication",
        *                        @"version":callbackDic[@"version"],
        *                        @"result":ontid,
        *                        @"id":callbackDic[@"id"],
        *                        @"error":@0,
        *                        @"desc":@"SUCCESS",
        *                        };
        *  [webView sendMessageToWeb:params];
        */
       break;
       default:
       break;
       }
   }];
  ```

- ONT ID authorization

  ```
  [webView setAuthorizationCallback:^(NSDictionary *callbackDic) {
        NSDictionary * params = callbackDic[@"params"];
        NSString * subaction = params[@"subaction"];
        NSArray  * allSubaction = @[@"exportOntid",@"deleteOntid",@"decryptClaim",
                                   @"getAuthorizationInfo",@"requestAuthorization"];
        NSInteger index = [allSubaction indexOfObject:subaction];
  
        switch (index) {
        case 0:
        /* TODO
         * 1.Pop-up password box to verify ONT ID password
         * 
         * 2.Export the identity to the WIF format
         */
        break;
        case 1:
        /* TODO
         * 1.Pop-up password box to verify ONT ID password
         * 
         * 2.Delete the local ONT ID and close the page after the password is successful
         */
        break;
        case 2:
        /* TODO
         * 1.Pop-up password box to verify ONT ID password
         * 2.Decrypt, get the result of decryption
         * 3.Return the result
         * NSDictionary *params =   @{
         *                          @"action":@"authorization",
         *                          @"version":callbackDic[@"version"],
         *                          @"result":Decryption results,
         *                          @"id":callbackDic[@"id"],
         *                          @"error":@0,
         *                          @"desc":@"SUCCESS",
         *                          };
         * [webView sendMessageToWeb:params];
         */
        break;
        case 3:
        /* TODO
         * 1.Change the subaction that saves the data to getAuthorizationInfo
         * 
         * 2.Return the result
         * NSDictionary * resultDic = [[NSUserDefaults standardUserDefaults] 
         *                            valueForKey:ONTIDAUTHINFO];
         * NSDictionary * resultParams = resultDic[@"params"];
         * NSMutableDictionary * resultParamsChange = [NSMutableDictionary 
         *                            dictionaryWithDictionary:resultParams];
         * resultParamsChange[@"subaction"] = @"getAuthorizationInfo";
         * NSDictionary *params = @{
         *                        @"action":@"authorization",
         *                        @"version":callbackDic[@"version"],
         *                        @"result":resultParamsChange,
         *                        @"id":callbackDic[@"id"],
         *                        @"error":@0,
         *                        @"desc":@"SUCCESS",
         *                        };
         *  [webView sendMessageToWeb:params];
         */
        break;
        case 4:
        /* TODO
         * 1.Save the received callbackDic and jump to the authorization interface
         * [webView setURL:url];
         */
        break;
        default:
        break;
        }
  }];
  ```


## how to use

- Import CyanoRNWebView.framework into the project

- # import "RNJsWebView.h"

##### Method 1: Code import

- Import a three-party library using pod

```
pod 'MBProgressHUD', '~> 1.1.0'

pod 'Masonry', '~> 1.1.0'

pod 'IQKeyboardManager' ,'~> 6.0.6'
```

- Import the Third folder
- Import the Tools folder
- Import js blue folder
- Import cyano.bundle

##### Method 2: Static library import

- Import js blue folder
- Import cyano.bundle

##### *Note: SDK does not make camera permissions related settings, you must first obtain camera permissions before use.*

## Use example

Start the ONT ID interface. The private key of the ONT ID is the same as the default wallet of the ONT. Before entering the interface, you need to check whether the wallet has been created.。

ONT ID only allows one to be created

```
NSString * ontIdString = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTONTID];
if ([Common isBlankString:ontIdString]) {
    // Incoming wallet dictionary
    NSString *jsonStr = [[NSUserDefaults standardUserDefaults] valueForKey:ASSET_ACCOUNT];
    if (!jsonStr) {
    [Common showToast:@"No Wallet"];
    return;
    }
    NSDictionary *dict = [Common dictionaryWithJsonString:jsonStr];
    ONTIdPreViewController * vc = [[ONTIdPreViewController alloc]init];
    vc.walletDic = dict;
    [self.navigationController pushViewController:vc animated:YES];
}else{
    ONTOAuthSDKViewController * vc= [[ONTOAuthSDKViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
```

## Wallet demo

[cyano-ios](https://github.com/ontio-cyano/cyano-ios)


