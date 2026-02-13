# Settings<a name="ZH-CN_TOPIC_0000001103421572"></a>

-   [简介](#section11660541593)
    -   [架构图](#section48896451454)

-   [目录](#section161941989596)
-   [相关仓](#section1371113476307)

## 简介<a name="section11660541593"></a>

设置应用是OpenHarmony标准系统中预置的系统应用，为用户提供基础的设置功能，包括：支持首页搜索功能、支持WLAN设置功能、支持蓝牙设置功能、支持移动网络设置功能、支持多设备协同设置功能、支持桌面和个性化设置功能、支持通知和状态栏设置功能、支持显示和亮度设置功能、支持声音和振动设置功能、支持应用设置功能、支持生物识别和密码设置功能、支持电池设置功能、支持存储设置功能、支持系统设置功能、支持关于本机设置功能、支持开发者选项设置功能。

### 架构图<a name="section48896451454"></a>

![](figures/zh-cn_image_0000001153225717.png)

## 目录<a name="section161941989596"></a>

````
settings
├─ product
│  └─ phone
│     └─ src
│        └─ main
│           ├─ ets
│              ├─ Application  # 全局ets逻辑和应用生命周期管理文件
│              ├─ MainAbility  # Ability与ExtentionAbility存放目录
│              ├─ pages        # 页面组件存放目录
│              ├─ Setting      # 设置项存放目录
│              ├─ stub         # 设置服务stub存放目录
│              ├─ utils        # 公共工具存放目录
│           ├─ resources       # 资源文件存放目录
├─ native                      # 内核native相关代码存放目录
├─ feature                     # 相关模块业务逻辑存放目录
├─ common                      # 通用逻辑存放目录
├─ LICENSE                     # 许可文件
├─ signature                   # 证书文件目录

````



## 相关仓

[**Setings**](https://gitcode.com/openharmony/applications_settings)
[**SetingsData**](https://gitcode.com/openharmony/applications_settings_data)


