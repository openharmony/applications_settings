/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 定义常量类
 */
export class Constant {
  // 定义包名常量类
  static readonly TAG: string = 'SettingsTest';
  static readonly SETTINGS_BUNDLE_NAME: string = 'com.ohos.settings';
  static readonly SETTINGS_MAIN_ABILITY_NAME: string = 'com.ohos.settings.MainAbility';
  static readonly SETTINGS_MOBILE_NETWORK_ABILITY_NAME: string = 'com.ohos.settings.MobileNetworkAbility';
  static readonly SETTINGS_MAIN_ABILITY_URL = 'pages/home/SettingsHome';
  static readonly BACK_BUTTON_TYPE: string = 'BackButton';

  // 设置首页字符串常量
  static readonly SETTINGS: string = '设置';

  // 关于本机页面字符串常量
  static readonly ABOUT_DEVICE: string = '关于本机';
  static readonly ABOUT_DEVICE_AVAILABLE_DEVICE: string = '可用设备';
  static readonly DEVICE_NAME: string = '设备名称';
  static readonly HOT_SPOT_CONNECT_DEVICE: string = '已连接设备';
  static readonly SERIAL_NUMBER: string = '序列号';
  static readonly IMEI_ID: string = 'IMEI';
  static readonly PARAMETER_VERSION_TITLE: string = '参数版本';
  static readonly STATUS_INFORMATION: string = '状态信息';
  static readonly NETWORK_INFORMATION: string = '网络';
  static readonly BLUETOOH_ADRESS: string = '蓝牙地址';
  static readonly BATTERY_LEVEL: string = '电池电量';
  static readonly SOFTWARE_UPDATE_SERVICES: string = '软件更新服务声明';
  static readonly ABOUT_DEVICE_CANCLE: string = '取消';
  static readonly ABOUT_DEVICE_CONFIRM: string = '确定';
  static readonly SYSTEM_TITLE: string = '系统';
  static readonly SOFTWARE_UPDATE_TEXT: string = '发现新版本';

  // WLAN页面字符串常量
  static readonly WIFI: string = 'WLAN';
  static readonly WIFI_AVAILABLE_AP_GROUP: string = '可用 WLAN';
  static readonly WIFI_BUTTON_CONNECT: string = '连接';
  static readonly WIFI_BUTTON_CANCEL: string = '取消';
  static readonly WIFI_BUTTON_DELETE: string = '删除';
  static readonly WIFI_CONNECT_STATUS_FAILED: string = '密码错误，连接失败。';
  static readonly WIFI_STATUS_CONNECTING: string = '正在连接';
  static readonly WIFI_STATUS_CONNECTED: string = '已连接';
  static readonly WIFI_ADD_OTHER_NETWORKS: string = '添加其他网络';
  static readonly WIFI_ADD_NETWORKS_TITLE: string = '添加网络';
  static readonly WIFI_ADD_NETWORKS_NAME_TEST: string = 'test1';
  static readonly WIFI_CONNECT_NETWORKS_LOADING: string = '正在连接 “test1”…';
  static readonly WIFI_NETWORK_NAME: string = '网络名称';
  static readonly WIFI_SECURITY: string = '安全性';
  static readonly WIFI_SECURITY_NO: string = '无';
  static readonly WIFI_SECURITY_WEP: string = 'WEP';
  static readonly WIFI_SECURITY_PSK: string = 'PSK';
  static readonly WIFI_SECURITY_SAE: string = 'SAE';
  static readonly WIFI_SECURITY_EAP: string = '802.1x EAP';
  static readonly WIFI_EAP: string = 'EAP 方法';
  static readonly WIFI_EAP_PEAP: string = 'PEAP';
  static readonly WIFI_EAP_PWD: string = 'PWD';
  static readonly WIFI_PHASE2_AUTH: string = '阶段 2 身份验证';
  static readonly WIFI_EAP_IDENTITY: string = '身份';
  static readonly WIFI_EAP_ANONYMOUS: string = '匿名身份';
  static readonly WIFI_EAP_PASSWORD: string = '密码';
  static readonly WIFI_EAP_PRIVACY: string = '隐私';
  static readonly WIFI_EAP_PRIVACY_RANDOM: string = '使用随机 MAC';
  static readonly WIFI_EAP_PRIVACY_DEVICE: string = '使用设备 MAC';
  static readonly WIFI_ADVANCED: string = '高级选项';
  static readonly WlAN_PRECISION: string = '提高精确度';
  static readonly WIFI_SCAN: string = 'WLAN 扫描';
  static readonly WIFI_PRECISION_TEXT: string = '为提高位置信息的精确度，应用和服务仍然会扫描 WLAN 网络。您可以在提高精确度中更改此设置。';
  static readonly WIFI_EAP_METHOD_ID: string = 'entry_image_wifi_eap_method';

  // 连接wlan信息
  static readonly WIFI_CONNECT_PASSWORD: string = '12345678';
  static readonly WIFI_CONNECT_ERROR_PASSWORD: string = 'error';
  static readonly WIFI_PASSWORD_INPUT_ID: string = 'wifi_password_input';
  static readonly WIFI_SWITCH_ID: string = 'entry_toggle_wifi_switch';
  static readonly CONNECT_WIFI_DELETE_ID: string = 'button_2_cancel_button';
  static readonly WIFI_CONNECT_BUTTON_ID: string = 'button_2_wifi_password_cancel_button';
  static readonly WIFI_CANCEL_BUTTON_ID: string = 'button_1_wifi_password_cancel_button';
  static readonly WIFI_CONNECT_EAP_NAME: string = 'wlanaccessv2.0';
  static readonly WIFI_CONNECT_STATUS_FAILED_ID: string = 'entry_title_connect_fail_message';
  static readonly WIFI_CONNECT_STATUS_FAILED_BUTTON_ID: string = 'button_1_connect_fail_cancel';
  static readonly WIFI_SCAN_INFO_ID: string = 'text_title_wlan_scan_content';

  // oobe页面字符串常量
  static readonly OOBE_TEST_ABILITY_NAME = 'OobeLocalUserTestAbility';
  static readonly OOBE_NICK_NAME_ID = 'nickNameInput';
  static readonly OOBE_NICK_NAME_WARN_ID = 'nickNameWarnText';
  static readonly OOBE_ACCOUNT_NAME_ID = 'accountNameInput';
  static readonly OOBE_ACCOUNT_NAME_WARN_ID = 'accountNameWarnText';
  static readonly OOBE_PASSWORD_ID = 'passwordInput';
  static readonly OOBE_PASSWORD_WARN_ID = 'passwordWarnText';
  static readonly OOBE_CONFIRM_PASSWORD_ID = 'confirmPasswordInput';
  static readonly OOBE_CONFIRM_PASSWORD_WARN_ID = 'confirmPasswordWarnText';
  static readonly OOBE_CONTINUE_BUTTON_ID = 'createButton';
  static readonly OOBE_CANCEL_BUTTON_ID = 'cancelButton';
  static readonly OOBE_OK_BUTTON_ID = 'okButton';

  // wlan 代理信息
  static readonly WIFI_PROXY_TITLE: string = '代理';
  static readonly WIFI_PROXY_MANUALLY: string = '手动';
  static readonly WIFI_PROXY_NONE: string = '无';
  static readonly WIFI_PROXY_MANUALLY_SERVER_HOST: string = '服务器主机名';
  static readonly WIFI_PROXY_MANUALLY_SERVER_PORT: string = '服务器端口';
  static readonly WIFI_PROXY_MANUALLY_CAN_BYPASS_OBJ: string = '可绕过代理的对象';
  static readonly WIFI_PROXY_SELECT_ID: string = 'entry_text_wifi_manual_proxy_settings';
  static readonly WIFI_PROXY_MANUAL_ID: string = 'radiomenu_radio_select_dialog_key_1';
  static readonly WIFI_PROXY_NONE_ID: string = 'radiomenu_radio_select_dialog_key_0';
  static readonly WIFI_PROXY_MANUAL_HOSTNAME_ID: string = 'wifi_proxy_hostname_label';
  static readonly WIFI_PROXY_MANUAL_CORRECT_HOSTNAME_TEXT: string = 'www.baidu.com';
  static readonly WIFI_PROXY_MANUAL_CORRECT_HOSTNAME_ERROR_TEXT: string = 'test.error.';
  static readonly WIFI_PROXY_MANUAL_PORT_ID: string = 'wifi_proxy_port_label';
  static readonly WIFI_PROXY_MANUAL_CORRECT_PORT_TEXT: string = '8000';
  static readonly WIFI_PROXY_MANUAL_CORRECT_PORT_ERROR_TEXT: string = '65536';
  static readonly WIFI_PROXY_MANUAL_EXCLUSION_LIST_ID: string = 'proxy_exclusionlist_label';
  static readonly WIFI_PROXY_MANUAL_EXCLUSION_LIST_TEXT: string = 'www.test.com';
  static readonly WIFI_PROXY_MANUAL_EXCLUSION_LIST_ERROR_TEXT: string = 'www.error.';

  // eap wlan 信息
  static readonly WIFI_EAP_IDENTITY_ID: string = 'wifi_eap_identity';
  static readonly WIFI_EAP_IDENTITY_TEXT: string = 'test';
  static readonly WIFI_EAP_IDENTITY_ERROR_TEXT: string = 'identity';
  static readonly WIFI_EAP_ANONYMOUS_ID: string = 'textinput_title_wifi_eap_anonymous';
  static readonly WIFI_EAP_ANONYMOUS_TEXT: string = 'anonymous';
  static readonly WIFI_EAP_PASSWORD_ID: string = 'wifi_eap_password';
  static readonly WIFI_EAP_PASSWORD_TEXT: string = '111111';
  static readonly WIFI_EAP_PASSWORD_ERROR_TEXT: string = 'password';

  // wlan IP信息
  static readonly WIFI_IP_SELECT_ID: string = 'entry_text_wifi_ip_settings';
  static readonly WIFI_IP_STATIC_ID: string = '静态';
  static readonly WIFI_IP_DHCP_ID: string = 'DHCP';
  static readonly WIFI_IP_STATIC_IP_ADDRESS_ID: string = 'static_ip_address';
  static readonly WIFI_IP_STATIC_IP_ADDRESS_TEXT: string = '192.168.1.128';
  static readonly WIFI_IP_STATIC_IP_ADDRESS_ERROR_TEXT: string = '12345';
  static readonly WIFI_IP_STATIC_IP_GATEWAY_ID: string = 'static_ip_gateway';
  static readonly WIFI_IP_STATIC_IP_GATEWAY_TEXT: string = '192.168.1.1';
  static readonly WIFI_IP_STATIC_IP_GATEWAY_ERROR_TEXT: string = 'test';
  static readonly WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID: string = 'static_ip_prefix_length';
  static readonly WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT: string = '24';
  static readonly WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID: string = 'static_ip_dnsServers1';
  static readonly WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT: string = '8.8.8.8';
  static readonly WIFI_IP_STATIC_IP_DNS_SERVERS_1_ERROR_TEXT: string = '1';
  static readonly WIFI_IP_STATIC_IP_DNS_SERVERS_2_ID: string = 'static_ip_dnsServers2';
  static readonly WIFI_IP_STATIC_IP_DNS_SERVERS_2_TEXT: string = '8.8.4.4';
  static readonly WIFI_IP_STATIC_IP_DNS_SERVERS_2_ERROR_TEXT: string = '1234';

  // 蓝牙页面字符串常量
  static readonly BLUETOOTH: string = '蓝牙';
  static readonly BLUETOOTH_CANCLE: string = '取消';
  static readonly BLUETOOTH_CHECKBOX: string = '20000113';
  static readonly BLUETOOTH_OK: string = '知道了';
  static readonly BLUETOOTH_PAIR: string = '配对';
  static readonly BLUETOOTHBT_PAIR_FAILED: string = '配对失败';
  static readonly BLUETOOTH_CONFIRM: string = '确定';
  static readonly BLUETOOTH_A2DP_ID: string = 'entry_toggle_a2dp_device_key';
  static readonly BLUETOOTH_MAP: string = '信息授权';
  static readonly BLUETOOTH_SHARING_CALL_HISTORY: string = '共享联系人和呼叫历史记录';
  static readonly SHARE_NAME_AND_PHONE_NUMBER: string = '仅姓名和号码';
  static readonly BLUETOOTH_SHARE_ALL: string = '全部详情';
  static readonly BLUETOOTH_NOT_SHARE: string = '不共享';
  static readonly BLUETOOTH_SYNC_VOLUME_WITH_PHONE: string = '蓝牙设备音量与手机同步';
  static readonly BLUETOOTH_GEAR: string = '蓝牙齿轮';
  static readonly AUDIO_BUTLER: string = '音频管家';
  static readonly BLUETOOTH_CANCLE_PAIR: string = '取消配对';
  static readonly BLUETOOTH_PAIR_REQUEST: string = '蓝牙配对请求';
  static readonly BLUETOOTH_PAIR_MES: string = '配对之后，向所配对设备授予通讯和通话记录的访问权限';
  static readonly BLUETOOTH_DEVICE_PAIR: string = '要与以下设备配对：';
  static readonly BLUETOOTH_DEVICE_PAIR_MES_EORR: string = '配对码或要配对的设备配置错误。';
  static readonly BLUETOOTH_PBAP_TITLE: string = '要允许访问通讯录和通话记录吗？';
  static readonly BLUETOOTH_PAIR_MES_AUTH: string = '请确认该设备可信任后再授权。';
  static readonly BLUETOOTH_DISC: string = '断开连接？';
  static readonly BLUETOOTH_PAIR_SHARE_MES: string = '想要访问您的通讯录和通话记录，包括有关来电和去电的数据。';
  static readonly BLUETOOTH_DISC_CONNECTED: string = '此操作将会断开您与以下设备的连接：';


  // 桌面和个性化页面字符串常量
  static readonly THEME: string = '桌面和个性化';
  static readonly MY_THEME: string = '我的主题';
  static readonly THEME_VITALITY: string = '活力';
  static readonly THEME_APPLIED: string = '已应用';
  static readonly WALLPAPERS: string = '壁纸';
  static readonly SCREE_OFF_DISPLAY: string = '熄屏风格';
  static readonly THEME_ICON: string = '图标';
  static readonly THEME_MORE_SETTINGS: string = '更多设置';
  static readonly DESKTOP_SETTINGS: string = '桌面设置';
  static readonly SCREE_OFF_SETTINGS: string = '熄屏显示设置';
  static readonly SELECT_FROM_GALLERY: string = '从图库中选择';
  static readonly MY_WALLPAPERS: string = '我的壁纸';
  static readonly THEME_PINNACLE: string = '巅峰';
  static readonly THEME_UNIVERSE: string = '宇宙';
  static readonly RANDOM_DISPLAY_OF_PHONES: string = '照片随机显示';
  static readonly THEME_ONLINE: string = '查看主题';

  // 显示和亮度页面字符串常量
  static readonly DISPLAY: string = '显示和亮度';
  static readonly DISPLAY_FIFTEEN_SECONDS: string = '15 秒';
  static readonly DISPLAY_THIRTY_SECONDS: string = '30 秒';
  static readonly DISPLAY_ONE_MINUTE: string = '1 分钟';
  static readonly DISPLAY_TWO_MINUTE: string = '2 分钟';
  static readonly DISPLAY_FIVE_MINUTE: string = '5 分钟';
  static readonly DISPLAY_TEN_MINUTE: string = '10 分钟';
  static readonly DISPLAY_AFTER_FIFTEEN_SECONDS: string = '15 秒后';
  static readonly DISPLAY_AFTER_THIRTY_SECONDS: string = '30 秒后';
  static readonly DISPLAY_AFTER_ONE_MINUTE: string = '1 分钟后';
  static readonly DISPLAY_AFTER_TWO_MINUTE: string = '2 分钟后';
  static readonly DISPLAY_AFTER_FIVE_MINUTE: string = '5 分钟后';
  static readonly DISPLAY_AFTER_TEN_MINUTE: string = '10 分钟后';
  static readonly DISPLAY_NEVER: string = '永不';
  static readonly COLOR_ADJUSTMENT_AND_COLOR_TEMPERATURE: string = '色彩调节与色温';
  static readonly COLOR_ADJUSTMENT_STANDARD: string = '标准';
  static readonly COLOR_ADJUSTMENT_VIVID: string = '鲜艳';
  static readonly COLOR_TEMPERATURE_DEFAULT: string = '默认';
  static readonly COLOR_TEMPERATURE_WARM: string = '暖色';
  static readonly COLOR_TEMPERATURE_COOL: string = '冷色';

  // hmscore页面字符串常量
  static readonly HMS_CORE_ADVERTISEMENT: string = '广告';

  // 更多连接页面字符串常量
  static readonly MULTI_DEVICE_COLLABORATION: string = '多设备协同';
  static readonly MORE_CONNECTION: string = '更多连接';
  static readonly MORE_CONNECTION_SWITCH_OFF: string = '已关闭';
  static readonly MORE_CONNECTION_CONNECT_OFF: string = '未连接';
  static readonly MORE_CONNECTION_CONNECT_ON: string = '已开启';
  static readonly MORE_CONNECTION_NOT_CONNECT: string = '未连接';
  static readonly MORE_CONNECTION_SUPER_DESKTOP: string = '超级桌面';
  static readonly MORE_CONNECTION_STYLUS: string = '手写笔';
  static readonly HICAR_MY_DEVICE: string = '我的设备';
  static readonly NFC_HOW_TO_USE_DESCRIPTION: string = '若要进行移动支付、碰一碰等操作，可将本设备背部触碰其他设备 NFC 感应区。';
  static readonly DEFAULT_FAULT_PAYMENT_APP: string = '默认付款应用';
  static readonly MORE_CONNECTION_NFC: string = 'NFC';
  static readonly MORE_NFC_NOT_SET: string = '未设置';
  static readonly WIRELESS_PROJECTION: string = '无线投屏';
  static readonly CALCULATORS: string = '计算器';
  static readonly GALLERY: string = '图库';
  static readonly APP_CONTINUE: string = '接续';
  static readonly COLLABORATION_MORE: string = '高级';
  static readonly APP_CLIPBOARD: string = '跨设备剪贴板';

  // 通知和状态栏页面字符串常量
  static readonly NOTIFUCATION_STAUS_BAR: string = '通知和状态栏';
  static readonly NOTIFUCATION: string = '通知';
  static readonly NOTIFUCATION_MANAGEMENT: string = '通知管理';

  // 隐私页面字符串常量
  static readonly PRIVACY: string = '隐私和安全';
  static readonly LOCATION_SETTINGS: string = '定位服务';
  static readonly PRIVACY_PERMISSION: string = '隐私权限';
  static readonly PRIVACY_LOCATION_INFO: string = '位置信息';
  static readonly PRIVACY_CAMERA: string = '相机';
  static readonly PRIVACY_MICROPHONE: string = '麦克风';
  static readonly LOCATION_ACCESS: string = '访问我的位置信息';
  static readonly LOCATION_HELP: string = '帮助';

  // 显示和亮度页面字符串常量
  static readonly SCREEN_REFRESH_RATE_TITLE: string = '屏幕刷新率';
  static readonly SCREEN_REFRESH_RATE_SMART: string = '智能';
  static readonly SCREEN_REFRESH_RATE_SMART_TIPS: string = '最高 120 Hz，兼顾省电和画面流畅性';
  static readonly SCREEN_REFRESH_RATE_MIDDLE_TIPS: string = '最高 120 Hz，兼顾省电和画面流畅性';
  static readonly SCREEN_REFRESH_RATE_HIGH_TIPS: string = '最高 120 Hz，兼顾省电和画面流畅性';
  static readonly SCREEN_REFRESH_RATE_STANDARD_TIPS: string = '最高 120 Hz，兼顾省电和画面流畅性';
  static readonly SCREEN_REFRESH_RATE_HIGH: string = '高';
  static readonly SCREEN_REFRESH_RATE_MIDDLE: string = '中';
  static readonly SCREEN_REFRESH_RATE_STANDARD: string = '标准';
  static readonly SMART_RESOLUTION_TYPE: string = '0';
  static readonly SMART_RESOLUTION_TITLE: string = '智能分辨率';
  static readonly SCREEN_RESOLUTION_TITLE: string = '屏幕分辨率';
  static readonly SCREEN_RESOLUTION_HIGH_TITLE: string = '高';
  static readonly SCREEN_RESOLUTION_MIDDLE_TITLE: string = '标准';
  static readonly SCREEN_RESOLUTION_LOW_TITLE: string = '低';

  // 声音页面字符串常量
  static readonly SOUND_AND_VIBRATION: string = '声音和振动';
  static readonly SOUND_TOUCH_SWITCH: string = '系统触感反馈';
  static readonly SOUND_TOUCH_SWITCH_TIP: string = '仅为精准操作和重要事件提供触感反馈';
  static readonly SOUND_TOUCH_SWITCH_ID: string = 'Setting.Volume.touch_settings.touch_feedback.result';

  // 存储页面字符串常量
  static readonly STORAGE: string = '存储';
  static readonly STORAGE_USED_SPACE: string = '已用空间';
  static readonly STORAGE_AVAILABLE_SPACE: string = '可用空间';

  // 应用字符串常量
  static readonly APPLICATION_AND_SERVICE: string = '应用';
  static readonly APPLICATION_MANAGEMENT: string = '应用管理';
  static readonly APPLICATION_NAME_MEM: string = '备忘录';
  static readonly APPLICATION_NAME_CL: string = '畅连';
  static readonly APPLICATION_TIPS: string = '玩机技巧';
  static readonly APPLICATION_HEALTH_CORE: string = 'health_core';
  static readonly APPLICATION_PERMISSION: string = '权限管理';
  static readonly APPLICATION_INFORMATION: string = '应用信息';
  static readonly APPLICATION_CANCLE: string = '取消';
  static readonly APPLICATION_FORCE_STOP: string = '强行停止';
  static readonly APPLICATION_DELETE_DATA: string = '删除数据';
  static readonly APPLICATION_UNINSTALL: string = '卸载';
  static readonly META_APP: string = '应用';
  static readonly APPLICATION_RESTORE: string = '恢复应用';
  static readonly APPLICATION_NETWORKING_MANAGE: string = '应用联网';
  static readonly APPLICATION_NETWORKING_CELLULAR: string = '移动数据';
  static readonly APPLICATION_NETWORKING_WLAN: string = 'WLAN';

  // 生物识别与密码页面字符串常量
  static readonly PASSWORD: string = '生物识别和密码';
  static readonly LOCK_SCREEN_PWD: string = '锁屏密码';
  static readonly SET_LOCK_SCREEN_PWD: string = '设置锁屏数字密码';
  static readonly SET_NEW_LOCK_SCREEN_PWD: string = '设置新的锁屏密码';
  static readonly PIN_PASSWORD_MSG: string = '密码由 6 位数字组成';
  static readonly PIN_TEST_PSD: string = '123466';
  static readonly OTHER_PASSWORD_TYPE: string = '其他密码类型';
  static readonly NUMBER_PASSWORD_TYPE: string = '自定义数字密码';
  static readonly MIXED_PASSWORD_TYPE: string = '混合密码';
  static readonly MIXED_PASSWORD_MSG: string = '密码由 6-32 位字符组成，需至少包含 1 个字母';
  static readonly MIXED_PASSWORD_TOO_SHORT_MSG: string = '混合密码必须至少包含 6 个字符';
  static readonly PASSWORD_TOO_SHORT_ILLEGAL_MSG: string = '密码必须多于 6 个字符且不能包含非法字符';
  static readonly PIN_ISOVARIANCE_SERIES_PSD: string = '123456';
  static readonly PASSWORD_TOO_SHORT_MSG: string = '密码必须多于 6 个字符';
  static readonly PASSWORD_TOO_LONG_MSG: string = '密码必须少于 32 个字符';
  static readonly PASSWORD_REPEAT_ERROR_MSG: string = '密码不一致';
  static readonly PASSWORD_ILLEGAL_MSG: string = '密码包含不合法字符';
  static readonly PASSWORD_TOO_LONG_ILLEGAL_MSG: string = '密码必须少于 32 个字符且不能包含非法字符';
  static readonly PASSWORD_MILLISECONDS_TIME_2H_MSG: string = '请 2 小时后重试';
  static readonly PASSWORD_MILLISECONDS_TIME_0: number = 0;
  static readonly PASSWORD_MILLISECONDS_TIME_2H: number = 7200000;
  static readonly MIXED_PASSWORD_TOO_SHORT: string = '1111';
  static readonly MIXED_PASSWORD_NULL: string = '';
  static readonly PASSWORD_TOO_SHORT_ILLEGAL_CHARACTER: string = '1~`·';
  static readonly PASSWORD_TOO_LONG_ILLEGAL_CHARACTER: string = '1111111122222222333333334444445~`·q';
  static readonly MIXED_PASSWORD_INCLUDE_LETTER_MSG: string = '请至少包含 1 个字母';
  static readonly MIXED_PASSWORD_NOT_INCLUDE_LETTER: string = '11111111';
  static readonly MIXED_PASSWORD: string = '11111111a';
  static readonly MIXED_PASSWORD_TOO_LONG: string = '012345678901234567890123456789aaa';
  static readonly MIXED_PASSWORD_MAX: string = '012345678901234567890123456789aa';
  static readonly PASSWORD_ILLEGAL_CHARACTER: string = '1555277~';
  static readonly MIXED_PASSWORD_CHANGED: string = '22222222a';
  static readonly REMEMBER_PIN_WARNING_TITLE: string = '请牢记您的锁屏密码，忘记后无法找回';
  static readonly INPUT_PASSWORD_AGAIN: string = '请再次输入密码';
  static readonly UPDATE_LOCK_SCREEN_PWD: string = '更改锁屏密码';
  static readonly CLOSE_LOCK_SCREEN_PWD: string = '关闭锁屏密码';
  static readonly INPUT_CURRENT_LOCK_SCREEN_PWD: string = '输入当前锁屏密码';
  static readonly INPUT_LOCK_SCREEN_PWD: string = '输入锁屏密码';
  static readonly NUMBER_PASSWORD_MSG: string = '密码由 6-32 位数字组成';
  static readonly NUMBER_PASSWORD_TOO_SHORT_MSG: string = '数字密码至少应为 6 位';
  static readonly NUMBER_PASSWORD_TOO_LONG_MSG: string = 'PIN 必须少于 33 位数。';
  static readonly NUMBER_PASSWORD_TOO_LONG: string = '111111112222222233333333444444445555';
  static readonly NUMBER_PASSWORD_MUST_BE_NUMBER_MSG: string = 'PIN 必须为纯数字';
  static readonly NUMBER_PASSWORD_MUST_BE_NUMBER: string = 'aaaaaa';
  static readonly NUMBER_PASSWORD_UPDATE: string = '22222222';
  static readonly PIN_REPEAT_ERROR_TITLE: string = '密码不一致，请重新输入';
  static readonly CONTINUE: string = '继续';
  static readonly CONFIRM: string = '确定';
  static readonly CLOSE: string = '关闭';
  static readonly NEXT_STEP: string = '下一步';
  static readonly USE_ANYWAY: string = '继续使用';
  static readonly ENTER_LATER: string = '稍后录入';
  static readonly PASSWORD_CIRCLE_5: string = 'PasswordCircle5';

  // 指纹字符串常亮
  static readonly FINGERPRINT: string = '指纹';
  static readonly FINGERPRINT_USED_FOR: string = '指纹用于';
  static readonly FINGERPRINT_UNLOCK: string = '解锁设备';
  static readonly FINGERPRINT_NOTE_TITLE: string = '操作说明：';
  static readonly ADD_FINGERPRINT: string = '新建指纹';
  static readonly BIOMETRICS: string = '生物识别';
  static readonly FINGERPRINT_NOTE_1: string = '1、录入或验证指纹时，请稍许用力按压。';
  static readonly FINGERPRINT_NOTE_2: string = '2、指纹感应区有第三方贴膜或污渍会影响解锁体验。';
  static readonly FINGERPRINT_NOTE_3: string = '3、手指干燥会影响指纹识别。识别时，请保持湿润。';
  static readonly FINGERPRINT_NOTE_4: string = '4、黑屏时，指纹解锁会同时触发人脸识别，提升解锁体验。';
  static readonly FINGERPRINT_NOTE_5: string = '5、指纹识别期间，系统将暂时修改背光亮度和护眼模式状态。';
  static readonly FINGERPRINT_INTRO_SUMMARY_01: string = '手指放在屏内指纹感应区，并稍许用力按压。';
  static readonly FINGERPRINT_NOTICE_MESSAGE_INFO: string = '提示：指纹识别的安全性可能不及图案和数字密码。指纹数据将在您的设备本地加密保存。';
  static readonly FINGERPRINT_INNER_SCREEN_BTN: string = '开始录入';
  static readonly FINGERPRINT_INNER_SCREEN_NOTE: string = '屏内指纹使用提示';
  static readonly FINGERPRINT_NO_PROMPT: string = '不再提示';
  static readonly FINGERPRINT_CONFIRMED_BTN: string = '知道了';
  static readonly FINGERPRINT_SCREEN_ENROLL_PLACE: string = '放置手指';
  static readonly FINGERPRINT_PASSWORD_MSG: string = '启用指纹识别前，请设置锁屏密码，以便指纹不可用时使用。';
  static readonly FINGERPRINT_SCREEN_ENROLL_PLACE_SUMMARY_01: string = '手指按压屏内感应区，感受到振动后移开，重复此步骤。';
  static readonly FINGERPRINT_COVER_MESSAGE: string = '第三方贴膜对指纹识别影响较大，请使用官方贴膜或不贴膜。';
  static readonly FINGERPRINT_PASSWORD_VAULT: string = '自动填充帐号和密码';

  // 人脸字符串常量
  static readonly FACE: string = '人脸识别';
  static readonly ADD_FACE: string = '新建面部数据';
  static readonly FACE_CONTINUE: string = '继续';

  // 通用页面字符串常量
  static readonly SYSTEM_AND_UPDATES: string = '系统更新';
  static readonly RESET_DEVICE: string = '恢复出厂设置';
  static readonly RESET_FACTORY_DETAIL_TITLE: string = '此操作将彻底删除内部储存空间中的数据，包括：';
  static readonly RESET_NET_DETAIL_TITLE: string = '此操作将还原所有网络设置，包括：';
  static readonly DEVELOPER_OPTIONS_SETTINGS: string = '开发者选项';
  static readonly DEVELOPER_OPTIONS_INSIGHT_INTENT_DEBUG_SETTINGS: string = '意图框架调试';
  static readonly ANIMATION_OFF_KEY: string = '关闭动画';
  static readonly ANIMATION_SCALE_0_5_KEY: string = '动画缩放 0.5x';
  static readonly ANIMATION_SCALE_1_0_KEY: string = '动画缩放 1x';
  static readonly ANIMATION_SCALE_1_5_KEY: string = '动画缩放 1.5x';
  static readonly ANIMATION_SCALE_2_0_KEY: string = '动画缩放 2x';
  static readonly ANIMATION_SCALE_5_0_KEY: string = '动画缩放 5x';
  static readonly ANIMATION_SCALE_10_0_KEY: string = '动画缩放 10x';
  static readonly SYSTEM_BACK: string = '系统回退';
  static readonly DATE_TIME_TITLE: string = '日期和时间';
  static readonly AUTO_SYSTEM_UPDATES: string = '自动系统更新';
  static readonly CHARGE_TEMPERATURE_LIMIT: string = '充电温度限制';
  static readonly ATOMICSERVICE_DEBUG: string = '应用中元服务豁免管控';
  static readonly USB_DEBUG: string = 'USB 调试';
  static readonly USB_DEBUG_SUMMARY: string = '连接 USB 后开启调试模式';
  static readonly ALLOW_CONDUCT_DEBUG: string = '允许此网络进行“无线调试”？';
  static readonly OPEN_USB_DEBUG_UNUSABLE: string = '开启无线调试后，USB调试将同步关闭不可用。';
  static readonly LINK_WIRELESS_TITLE: string = '无法开启“无线调试”';
  static readonly LINK_WIRELESS_SUMMARY: string = '当前设备未连接WLAN，请连接后重试。';
  static readonly REVOCATION_USB_TITLE: string = '撤销 “USB 调试”授权？';
  static readonly REVOCATION_USB_SUMMARY: string = '撤销对您之前授权的所有计算机，是否撤销其 USB 调试的访问权限?';
  static readonly CLOSE_DEVELOPER_MODE_TITLE: string = '关闭“开发者选项”？';
  static readonly CLOSE_DEVELOPER_MODE_SUMMARY: string = '“开发者选项”关闭后将无法进行应用调测，是否立即重启并关闭“开发者选项”？';
  static readonly WLAN_DEBUG_OK_BTN: string = '知道了';
  static readonly WLAN_DEBUG: string = '无线调试';
  static readonly DEBUG: string = '调试';
  static readonly INPUT: string = '输入';
  static readonly ACTIVATING_USB_DEBUG: string = '连接到WLAN后启用调试模式';
  static readonly DISPLAY_REFRESH_TITLE: string = '显示刷新频率';
  static readonly DISPLAY_REFRESH_SUMMARY: string = '当前场景的显示屏最大刷新率';
  static readonly SHOW_TOUCH_TITLE: string = '显示触摸操作';
  static readonly SHOW_TOUCH_TITLE_SUMMARY: string = '为触摸操作提供视觉提示';
  static readonly DISPLAY_LAYOUT_BOUNDARIES: string = '显示布局边界';
  static readonly TRANSITION_ANIMATION_SCALING: string = '过渡动画缩放';
  static readonly DATE_24_HOUR_SYSTEM: string = '24 小时制';
  static readonly DATE: string = '日期';
  static readonly TIME: string = '时间';
  static readonly AUTO_LOCATION: string = '打开定位服务，自动定位所在时区';
  static readonly TIME_ZONE: string = '时区';
  static readonly SYSTEM_AND_UPDATES_CANCEL: string = '取消';
  static readonly DATE_TIME_CONFIRM: string = '确定';
  static readonly COMMON: string = '通用';
  static readonly SOFTWARE_UPDATE: string = '软件更新';
  static readonly SOFTWARE_UPDATE_NIGHT_UPGRADE: string = '夜间安装';
  static readonly PARAM_VERSION: string = '参数版本';
  static readonly PARAM_VERSION_AUTO_UPGRADE: string = '参数自动下载并更新';
  static readonly ALL_SCENE_UPDATE: string = '协同更新';
  static readonly CHECK_UPDATE: string = '检查更新';
  static readonly RESET: string = '重置';
  static readonly ENTERPRISE_DEVICE_AND_APPLICATION_MANAGER: string = '企业设备和应用管理';
  static readonly ENTERPRISE_DEVICE_MANAGER: string = '设备管理';
  static readonly ENTERPRISE_APPLICATION_MANAGER: string = '企业设备和应用管理';
  static readonly SMART_PAY: string = '智感支付';
  static readonly SMART_SCAN: string = '智感扫码';

  // 语言和输入法页面字符串常量
  static readonly LANGUAGE_AND_INPUT: string = '语言和输入法';
  static readonly LANGUAGE_AND_REGION: string = '语言和地区';
  static readonly ADD_LANGUAGE: string = '添加语言';
  static readonly LANGUAGE_HAS_ADDED: string = '已添加为偏好语言';
  static readonly SIMPLIFIED_CHINESE: string = '简体中文';
  static readonly ALL_LANGUAGE: string = '所有语言';
  static readonly ENGLISH: string = '英文';
  static readonly ADDED_LANGUAGE: string = '已添加语言';
  static readonly KEEP_CURRENT: string = '保留当前';
  static readonly CHOOSE_MODIFY: string = '更改';
  static readonly EDIT: string = '编辑';
  static readonly EDIT_LANGUAGE: string = '编辑语言';
  static readonly SAVE_LANGUAGE: string = '请至少保留一种偏好语言。';
  static readonly ENTRY_CLOSE_ENGLISH: string = 'entry_close_英文';
  static readonly ENTRY_CLOSE_CHINESE: string = 'entry_close_简体中文';
  static readonly LANGUAGE_CONFIRM: string = '确定';
  static readonly CHINA: string = '中国';
  static readonly AFGHANISTAN: string = '阿富汗';
  static readonly CURRENT_REGION: string = '当前地区';

  // 拖拽
  static readonly DRAG: string = '全局拖拽';

  //快捷启动和手势字符串常量
  static readonly QUICK_GESTURE: string = '快捷启动和手势';
  static readonly ACCESSIBILITY_WAKE_SCREEN: string = '亮屏';
  static readonly ACCESSIBILITY_WAKE_PICKUP: string = '拿起手机亮屏';
  static readonly ACCESSIBILITY_WAKE_DOUBLECLICK: string = '双击亮屏';
  static readonly AIR_SHARE: string = '隔空分享';
  static readonly GESTURE_MUTE_CALL: string = '静音/减弱音量';
  static readonly GESTURE_FLIP_MUTE_CALL: string = '拿起手机亮屏';
  static readonly GESTURE_PICKUP_REDUCE_CALL: string = '拿起手机亮屏';
  static readonly GESTURE_QUICK_CALL: string = '快速通话';

  // 移动网络页面字符串常量
  static readonly MOBILE_NETWORK_SETTINGS: string = '移动网络';
  static readonly FLIGHT_MODE: string = '飞行模式';
  static readonly MOBILE_DATA_SETTINGS: string = '移动数据';
  static readonly MOBILE_SIM_CARD_MANAGEMENT: string = 'SIM 卡管理';
  static readonly MOBILE_HOTSPOT_SETTINGS: string = '个人热点';
  static readonly MOBILE_MESSAGE: string = '卡 1 网络 ';
  static readonly MOBILE_UNIVERSAL: string = '通用';
  static readonly DATA_USAGE_MANAGEMENT: string = '流量管理';
  static readonly DATA_USAGE_MONTH_RANKING: string = '本月流量排行';
  static readonly INTERNATIONAL_INTERNET: string = '国际上网服务';

  // 无障碍字符串常量
  static readonly ACCESSIBILITY: string = '辅助功能';
  static readonly SCREEN_READER: string = '屏幕朗读';
  static readonly SCREEN_READER_MORE_SETTINGS: string = '更多设置';
  static readonly ACCESSIBILITY_ZOOM_GESTURE: string = '放大手势';
  static readonly ACCESSIBILITY_COLOR_FILTER: string = '色彩校正';
  static readonly ACCESSIBILITY_CORRECTION_MODE: string = '校正模式';
  static readonly ACCESSIBILITY_DEUTERANOMALY_MODE: string = '绿色弱视 (红绿色)';
  static readonly ACCESSIBILITY_PROTANOMALY_MODE: string = '红色弱视 (红绿色)';
  static readonly ACCESSIBILITY_TRITANOMALY_MODE: string = '蓝色弱视 (蓝-黄)';
  static readonly ACCESSIBILITY_CANCEL: string = '取消';
  static readonly ACCESSIBILITY_SHORTCUTS: string = '辅助功能快捷键';
  static readonly ACCESSIBILITY_SELECT_ABILITY: string = '选择功能';
  static readonly ACCESSIBILITY_SELECT_ABILITY_CLOSED: string = '已关闭';
  static readonly ACCESSIBILITY_HIGHCONTRASTTEXT_ABILITY: string = '高对比度文字';
  static readonly ACCESSIBILITY_AUDIOMONO_ABILITY: string = '单声道音频';
  static readonly ACCESSIBILITY_INVERTCOLOR_ABILITY: string = '颜色反转';
  static readonly ACCESSIBILITY_OTHER_SERVICES: string = '已安装的服务';
  static readonly ACCESSIBILITY_TOUCHSCREEN: string = '屏幕触控';
  static readonly ACCESSIBILITY_CLICKRESPONSETIME: string = '点击持续时间';
  static readonly ACCESSIBILITY_IGNOREREPEATCLICK: string = '忽略重复点击';
  static readonly ACCESSIBILITY_TOUCHSCREEN_SHORT: string = '短 (默认)';
  static readonly ACCESSIBILITY_TOUCHSCREEN_MEDIUM: string = '中';
  static readonly ACCESSIBILITY_TOUCHSCREEN_LONG: string = '长';
  static readonly ACCESSIBILITY_TOUCHSCREEN_TIMEINTERVAL: string = '时间间隔';
  static readonly ACCESSIBILITY_ELDER_CARE_TEST: string = '关怀模式';
  static readonly ACCESSIBILITY_ELDER_CARE_ENABLE_TEST: string = '开启';
  static readonly ACCESSIBILITY_ELDER_CARE_MORE_TIPS: string = '查看更多常用功能指南';
  static readonly ACCESSIBILITY_ELDER_CARE_SOS: string = '紧急信息';
  static readonly ACCESSIBILITY_AVAILABLE_SCREEN_LOCKED: string = '屏幕锁定时可用';
  static readonly ACCESSIBILITY_AUDIO_ADJUSTMENT: string = '音频调节';
  static readonly ACCESSIBILITY_HEARING_AID: string = '助听设备';
  static readonly ACCESSIBILITY_GO_TO_BULETOOTH: string = '前往蓝牙查看';
  static readonly ACCESSIBILITY_TRANSITION_ANIMATION: string = '过渡动画';
  static readonly ACCESSIBILITY_ENHANCE_VOICE: string = '声音修复';
  static readonly ACCESSIBILITY_BLINKING_REMINDER: string = '闪烁提醒';


  // 电池
  static readonly BATTERY: string = '电池';
  static readonly WRC_DIALOG: string = '请将支持无线充电的设备(手机、可穿戴设备等)，放在本机背面。'
  static readonly BATTERY_SCREEN_ON_TIME: string = '今日亮屏时长';

  // 用户与账户字符串常量
  static readonly CURRENT_LOGIN: string = '当前登录';
  static readonly USER_TITLE: string = '用户';
  static readonly USERS_AND_ACCOUNTS: string = '用户和帐户';
  static readonly USER_TYPE_ADMIN: string = '管理员';
  static readonly USER_CANCEL: string = '取消';
  static readonly ADD_USER: string = '添加用户'
  static readonly ADD_GUEST: string = '添加访客';
  static readonly GUEST_USER: string = 'Guest';

  // 5G 网络模式选择常量
  static readonly NR_MODE_ID: string = 'entry_title_debug_nr_mode';
  static readonly NR_MODE_NSA: string = 'NSA 模式';
  static readonly NR_MODE_SA_NSA: string = 'SA+NSA 模式';
  static readonly NR_MODE_NSA_SELECT_ID: string = 'SingleChoiceMenuItem_icon_debug_nr_mode_1';

  // 个人热点
  static readonly HOTSPOT_PASSWORD: string = '密码';
  static readonly HOTSPOT_PASSWORD_CANCLE: string = '取消';
  static readonly HOTSPOT_PASSWORD_CONFIRM: string = '确定';
  static readonly HOTSPOT_PASSWORD_RESET: string = '重新设置';
  static readonly HOTSPOT_PASSWORD_NAME_1: string = '12345678';
  static readonly HOTSPOT_PASSWORD_NAME_NORMAL: string = 'test12345678';
  static readonly HOTSPOT_CONNECTED_DEVICES: string = '已连接设备';
  static readonly HOTSPOT_BLOCK_LIST: string = '黑名单';

  static readonly HOTSPOT_DEVICES_NAME_TOO_LONG: string = '一二三四五六七八九十十';
  static readonly HOTSPOT_DEVICES_NAME_NEW: string = '一二三四五六七八...';

  static readonly APPLICATION_CLOCK_TITLE: string = '时钟';

  // 重置页面字符串常量
  static readonly RESET_TITLE: string = '重置';
  static readonly RESET_NET_TITLE: string = '还原网络设置';
  static readonly RESET_FACTORY_TITLE: string = '恢复出厂设置';
  static readonly RESET_DEVICE_BUTTON: string = '重置手机';
  static readonly RESET_DEVICE_DISABLED_TOAST = '此功能已被贵组织禁用';
  static readonly RESET_DEVICE_INFO_TEXT = '重置前，为防数据丢失，建议备份设备中的数据。';

  // 显示大小和文字
  static readonly DISPLAY_FONT_SIZE_AND_TEXT: string = '显示大小和文字';

  //键盘页面字符串常量
  static readonly KEYBOARD: string = '键盘';
  static readonly PRODUCT_INFO: string = '产品信息';
  static readonly FIRMWARE_UPDATE: string = '固件更新';
  static readonly MODEL: string = '型号';
  static readonly HARDWARE_VERSION: string = '硬件版本';
  static readonly FIRMWARE_VERSION: string = '固件版本';
  static readonly HELPER_SHORTCUT: string = '键盘快捷键帮助程序';

  // 指纹键快捷功能页面字符串常量
  static readonly FINGERPRINT_KEY_SHORTCUT: string = '指纹键快捷功能';

  // VPN界面字符串常量
  static readonly ADD_VPN_BUTTON: string = '添加 VPN 网络';
  static readonly VPN_LIST_EMPTY: string = '没有 VPN';
  static readonly ADD_VPN_NAME: string = '名称';
  static readonly ADD_VPN_TYPE: string = '类型';
  static readonly ADD_VPN_SERVER_ADDRESS: string = '服务器地址';
  static readonly ADD_VPN_IPSEC: string = 'IPSec 标识符';
  static readonly ADD_VPN_IPSEC_CA: string = 'IPSec CA 证书';
  static readonly ADD_VPN_IPSEC_PRIVATE_CA: string = 'IPSec 服务器证书';
  static readonly NOT_VERIFY_SERVER: string = '(不验证服务器)';
  static readonly CERT_FROM_SERVER: string = '(来自服务器)';
  static readonly CERT_NOT_SPECIFIED: string = '(未指定)';
  static readonly SAVE_BUTTON: string = '保存';
  static readonly COLLAPSE_TEXT: string = '收起';
  static readonly ADVANCE_TEXT: string = '高级';
  static readonly ADVANCE_OPTIONS_TEXT: string = '高级选项';
  static readonly VPN_CONNECT: string = '连接';
  static readonly VPN_CONNECT_USERNAME: string = '用户名';
  static readonly VPN_CONNECT_PWD: string = '密码';
  static readonly VPN_CONNECT_SAVE_INFO: string = '保存用户信息';
  static readonly VPN_STATE_CONNECTING: string = '连接中...';
  static readonly VPN_STATE_CONNECT_FAILED: string = '连接失败';
  static readonly VPN_DELETE_NETWORK: string = '删除该网络';
  static readonly DIALOG_DELETE_TEXT: string = '删除';
  static readonly DIALOG_CANCEL_TEXT: string = '取消';
  static readonly PROTOCOL_UDP_TEXT: string = 'UDP';

  static readonly TYPE_IKEV2_IPSEC_MSCHAPv2: string = 'IKEv2/IPSec MSCHAPv2';
  static readonly TYPE_IKEV2_IPSEC_PSK: string = 'IKEv2/IPSec PSK';
  static readonly TYPE_IKEV2_IPSEC_RSA: string = 'IKEv2/IPSec RSA';
  static readonly TYPE_L2TP_IPSEC_PSK: string = 'L2TP/IPSec PSK';
  static readonly TYPE_L2TP_IPSEC_RSA: string = 'L2TP/IPSec RSA';
  static readonly TYPE_IPSEC_XAUTH_PSK: string = 'IPSec Xauth PSK';
  static readonly TYPE_IPSEC_XAUTH_RSA: string = 'IPSec Xauth RSA';
  static readonly TYPE_IPSEC_HYBRID_RSA: string = 'IPSec Hybrid RSA';
  static readonly TYPE_OPENVPN: string = 'OpenVpn';
  static readonly VPN_EDIT_SEARCH_DOMAINS: string = 'DNS 搜索域';
  static readonly VPN_EDIT_DNS_ADDRESS: string = 'DNS 服务器';
  static readonly VPN_EDIT_ROUTER: string = '转发路线';
  static readonly OPEN_VPN_CONFIG_FILE: string = 'OpenVPN 配置文件';
  static readonly OPEN_VPN_SERVER_ADDRESS: string = 'OpenVPN 服务器地址';
  static readonly OPEN_VPN_SERVER_PORT: string = 'OpenVPN 服务器端口';
  static readonly OPEN_VPN_SERVER_PROTOCOL: string = 'OpenVPN 协议';
  static readonly OPEN_VPN_AUTH_TYPE: string = 'OpenVPN 认证类型';
  static readonly OPEN_VPN_AUTH_TYPE_TLS: string = '证书(TLS)';
  static readonly OPEN_VPN_AUTH_TYPE_PWD: string = '密码';
  static readonly OPEN_VPN_AUTH_TYPE_TLS_PWD: string = '证书和密码(TLS)';
  static readonly OPEN_VPN_CA_CERTIFICATE: string = 'CA 证书';
  static readonly OPEN_VPN_USER_CERTIFICATE: string = '用户证书';
  static readonly OPEN_VPN_PRIVATE_PWD: string = '私钥密码';
  static readonly OPEN_VPN_PROXY_HOST: string = 'OpenVPN 代理主机';
  static readonly OPEN_VPN_PROXY_PORT: string = 'OpenVPN 代理端口';
  static readonly OPEN_VPN_PROXY_USERNAME: string = 'OpenVPN 代理用户名';
  static readonly OPEN_VPN_PROXY_PASSWORD: string = 'OpenVPN 代理密码';

  static readonly ADD_VPN_USER_NAME_ID: string = 'add_vpn_name_id';
  static readonly ADD_VPN_SERVER_ADDRESS_ID: string = 'add_server_address_id';
  static readonly ADD_VPN_IPSEC_IDENTIFIER_ID: string = 'add_ipsec_identifier_id';
  static readonly ADD_VPN_SEARCH_DOMAIN_ID: string = 'dns_search_domain_id';
  static readonly ADD_VPN_FORWARD_ROUTER_ID: string = 'forward_router_id';
  static readonly ADD_VPN_DNS_SERVER_ID: string = 'dns_server_id';
  static readonly VPN_LIST_KEY_ID: string = 'vpn_list_key_id';
  static readonly VPN_LIST_DETAIL_ID: string = 'vpn_list_detail_id';
  static readonly VPN_EDIT_TYPE_ID: string = 'vpn_edit_type_id';
  static readonly VPN_CONNECT_USERNAME_ID: string = 'vpn_connect_username_id';
  static readonly VPN_CONNECT_PWD_ID: string = 'vpn_connect_pwd_id';
  static readonly VPN_CONNECT_CHECKBOX_ID: string = 'vpn_connect_checkbox_id';
  static readonly VPN_EDIT_ADVANCED_ID: string = 'vpn_edit_advanced_id';
  static readonly VPN_EDIT_COLLAPSE_ID: string = 'vpn_edit_collapse_id';
  static readonly OPEN_VPN_SERVER_ADDRESS_ID: string = 'openvpn_server_address_id';
  static readonly OPEN_VPN_SERVER_PORT_ID: string = 'openvpn_server_port_id';
  static readonly OPEN_VPN_PROTOCOL_ID: string = 'openvpn_protocol_id';
  static readonly OPEN_VPN_AUTH_TYPE_ID: string = 'open_vpn_auth_type_id';
  static readonly OPEN_VPN_PRIVATE_PWD_ID: string = 'open_vpn_private_pwd_id';
  static readonly OPEN_VPN_DISPLAY_PROXY_ID: string = 'open_vpn_display_proxy_id';
  static readonly OPEN_VPN_PROXY_HOST_ID: string = 'open_vpn_proxy_host_id';
  static readonly OPEN_VPN_PROXY_PORT_ID: string = 'open_vpn_proxy_port_id';
  static readonly OPEN_VPN_PROXY_USERNAME_ID: string = 'open_vpn_proxy_username_id';
  static readonly OPEN_VPN_PROXY_PASSWORD_ID: string = 'open_vpn_proxy_password_id';
}
