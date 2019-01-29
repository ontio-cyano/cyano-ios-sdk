# cyano-iOS-sdk-ONTID

cyano-iOS-sdk-ONTID 帮助钱包集成ONTID相关功能

## 如何使用

- 将 CyanoRNWebView.framework 导入项目

- # import "RNJsWebView.h"

##### 方式一:代码导入

- 使用pod导入三方库

```
pod 'MBProgressHUD', '~> 1.1.0'

pod 'Masonry', '~> 1.1.0'

pod 'IQKeyboardManager' ,'~> 6.0.6'
```

- 导入 Third 文件夹
- 导入 Tools 文件夹
- 导入  js 蓝色文件夹
- 导入 cyano.bundle

##### 方式二:静态库导入

- 导入  js 蓝色文件夹
- 导入 cyano.bundle

##### *注意事项:SDK未做相机权限的相关设置,使用前需先获取相机权限*

## 使用示例

启动ONT ID界面，ONT ID的私钥，密码和ONT 默认钱包 钱包一致，在进入界面之前需要检查是否已创建好钱包。

ONT ID只允许创建一个

```
NSString * ontIdString = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTONTID];
if ([Common isBlankString:ontIdString]) {
    // 传入钱包字典
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

## DEMO

[cyano-ios](https://github.com/ontio-cyano/cyano-ios.git)