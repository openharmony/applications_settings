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
 * 指纹数据更新事件
 */
export const EVENT_ID_FINGERPRINT_DB_UPDATE: number = 100101;

/**
 * 系统语言更新事件
 */
export const EVENT_ID_LANGUAGE_UPDATE: number = 100102;

/**
 * 添加或者移除黑名单事件
 */
export const EVENT_ID_BLOCK_LIST_CHANGE: number = 200200;

/**
 * 黑名单清空事件
 */
export const EVENT_ID_BLOCK_LIST_EMPTY: number = 200201;

/**
 * 刷新个人热点二维码事件
 */
export const EVENT_ID_CHANGE_HOT_SPOT_QRCODE: number = 200202;

/**
 * 已配对蓝牙设备名称修改事件
 */
export const EVENT_ID_BT_BOUND_DEVICE_NAME_CHANGED: number = 200203;

/**
 * 指纹数据更新事件附加参数
 */
export const KEY_ID_FINGERPRINT_DB_UPDATE: string = 'key_id_fingerprint_db_update';

/**
 * 页面退到后台
 */
export const EVENT_ID_ON_PAGE_BACKGROUND: number = 200101;

/**
 * 页面回到前台
 */
export const EVENT_ID_ON_PAGE_FOREGROUND: number = 200102;

/**
 * 全局页面onTouch事件
 */
export const EVENT_ID_ON_PAGE_TOUCHED: number = 200103;

/**
 * plugin window 关闭事件
 */
export const EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE: number = 200104;

/**
 * windowStage状态改变
 */
export const EVENT_ID_ON_WINDOW_STAGE_CHANGED: number = 200105;

export const EVENT_ID_BUNDLE_RESOURCES_CHANGED: string = 'EVENT_ID_BUNDLE_RESOURCES_CHANGED';

export const EVENT_ID_CLEAR_CACHE: string = 'EVENT_ID_CLEAR_CACHE';

export const EVENT_ID_APP_CACHE_LOADED: string = 'EVENT_ID_APP_CACHE_LOADED';

export const EVENT_ID_REFRESH_CACHE: string = 'EVENT_ID_REFRESH_CACHE';

export const EVENT_ID_DARK_MODE_CACHE: string = 'EVENT_ID_DARK_MODE_CACHE';

export const EVENT_ID_SHEET_TYPE: string = 'EVENT_ID_SHEET_TYPE';

export const EVENT_ID_MAINABILITY_ON_FOREGROUND: string = 'EVENT_ID_ON_PAGE_FOREGROUND';
export const EVENT_ID_MAINABILITY_ON_BACKGROUND: string = 'EVENT_ID_ON_PAGE_BACKGROUND';

/**
 * 多用户userForm提交事件
 */
export const EVENT_ID_ON_USER_FORM_SUBMIT: number = 200107;

/**
 * 多用户userForm提交事件
 */
export const EVENT_ID_ON_CHANGE_USER_FORM_STATUS: number = 200108;

/**
 * 多用户头像裁剪事件
 */
export const EVENT_ID_CLIP_AVATAR: number = 200109;

/**
 * 主页外部跳转事件
 */
export const EVENT_ID_NAVIGATION_CHANGE: number = 200110;

/**
 * 多用户默认头像选择事件
 */
export const EVENT_ID_CHOOSE_DEFAULT_AVATAR: number = 200111;

/**
 * 多用户确认头像事件
 */
export const EVENT_ID_CONFIRM_DEFAULT_AVATAR: number = 200112;

/**
 * NFC状态切换事件
 */
export const EVENT_ID_NFC_SWITCH_CHANGE: number = 200113;
/**
 * PC控制中心WLAN二级页面展开折叠事件
 */
export const EVENT_ID_WLAN_LIST_COLLAPSE_STATE_CHANGE: number = 200114;

/**
 * PC控制中心WLAN二级页面展开折叠状态重置事件
 */
export const EVENT_ID_WLAN_LIST_COLLAPSE_STATE_RESET: number = 200115;

/**
 * PC设置蓝牙已配对界面弹出连接失败弹窗事件
 */
export const EVENT_ID_PC_BT_CONNECT_FAILED: number = 200116;

/**
 * PC MODE控制中心WLAN二级页面已连接栏显示事件
 */
export const EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE: string = 'EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE';

/**
 * PC MODE控制中心共享网络二级页面已连接栏显示事件
 */
export const EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE: string = 'EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE';

/**
 * PC MODE控制中心WLAN二级页面可用wlan显示事件
 */
export const EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE: string = 'EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE';

/**
 * PC MODE控制中心WLAN二级页面展开折叠事件
 */
export const EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE: string = 'EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE';

/**
 * PC MODE控制中心WLAN二级页面wlan开关事件
 */
export const EVENT_ID_PC_MODE_WLAN_SWITCH: string = 'EVENT_ID_PC_MODE_WLAN_SWITCH';

/**
 * PC MODE控制中心WLAN二级页面wlan item点击事件
 */
export const EVENT_ID_PC_MODE_WLAN_ITEM_CLICK_EVENTS: string = 'EVENT_ID_PC_MODE_WLAN_ITEM_CLICK_EVENTS';

/**
 * PC MODE控制中心共享网络二级页面item点击事件
 */
export const EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK: string = 'EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK';

/**
 * Configuration更新事件
 */
export const EVENT_ID_CONFIGURATION_UPDATE: number = 200117;

/**
 * 个人热点开关打开关闭事件
 */
export const EVENT_ID_HOT_SPOT_SWITCH_CHANGE: number = 200118;

/**
 * 企业禁止添加用户弹窗关闭事件
 */
export const EVENT_ID_DISALLOW_ADD_USER_DIALOG_CLOSE: number = 200120;

/**
 * 删除锁屏密码事件
 */
export const EVENT_ID_DELETE_PASSWORD: number = 200122;

/**
 * 企业用户和设备管理菜单关闭事件
 */
export const EVENT_ID_ENTERPRISE_MENU_HIDE: number = 200123;

/**
 * 刷新主题与个性化页面事件
 */
export const REFRESH_DESKTOP_AND_PERSONAL_PAGE: number = 200124;


/**
 * 刷新时间段内耗电排行榜事件
 */
export const REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT: number = 200125;

/**
 * 刷新24小时内耗电排行榜事件
 */
export const REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS: number = 200126;

/**
 * 刷新时区事件
 */
export const REFRESH_TIME_ZONE_EVENTS: number = 200127;

/**
 * 自动设置开关打开事件
 */
export const AUTO_SET_UPDATE_EVENTS: number = 200128;

/**
 * 24小时开关打开事件
 */
export const TIME_24_HOUR_SWITCH_OPEN_EVENTS: number = 200129;

/**
 * 选择耗电区间排行时间
 */
export const SELECT_CONSUMPTION_CHART_SEGMENT_EVENT: string = 'EVENT_CONSUMPTION_CHART_SEGMENT_SELECT';

/**
 * 选择所有耗电排行
 */
export const SELECT_CONSUMPTION_CHART_ALL_EVENT: string = 'EVENT_CONSUMPTION_CHART_ALL';

/**
 * 选择屏幕排行时间
 */
export const SELECT_SCREEN_TIME_CHART_SEGMENT_EVENT: string = 'EVENT_SCREEN_TIME_CHART_SELECT';

/**
 * 选择所有屏幕时间
 */
export const SELECT_SCREEN_TIME_CHART_ALL_EVENT: string = 'EVENT_SCREEN_TIME_CHART_ALL';

/**
 * 亮屏时长
 */
export const SCREEN_ON_TIME_EVENT: string = 'EVENT_SCREEN_ON_TIME';

/**
 * 气泡传递事件
 */
export const SCREEN_SELECT_BUBBLE_EVENT: string = 'EVENT_SCREEN_SELECT_BUBBLE';

/**
 * 刷新电池折线图数据事件
 */
export const REFRESH_LESS_THAN_HALF_AN_HOUR_EVENTS: number = 200131;

/**
 * 存储数据更新事件
 */
export const STORAGE_DATA_UPDATE_EVENT: string = '200132';

/**
 * App列表加载完成事件
 */
export const APP_LOADING_DONE_EVENT: string = '200133';

/**
 * 取消查找设备事件
 */
export const EVENT_ID_EXIT_FIND_DEVICE_PAGE: number = 200135;

/**
 * App列表TAB切换事件
 */
export const EVENT_ID_APP_TAB_CHANGE_EVENT: string = 'event_id_app_tab_change_event';

/**
 * 设置搜索返回事件
 */
export const EVENT_ID_SETTING_SEARCH_BACK: number = 200138;

/**
 * 电池-无线反向充电
 */
export const WIRELESS_REVERSE_CHARGING: number = 200144;

/**
 * 账号支持胶囊显示事件
 */
export const ACCOUNT_CAPSULE_DISPLAY_EVENT: number = 200145;

/**
 * 订阅胶囊显示事件
 */
export const SUBSCRIBE_CAPSULE_DISPLAY_EVENT: number = 200147;

/**
 * 胶囊展开折叠切换事件
 */
export const EVENT_ID_CAPSULE_NAVIGATION_CHANGE: number = 200148;

/**
 * 首页应用状态变化事件
 */
export const EVENT_ID_HOME_APP_STATE_CHANGED: number = 200149;

/**
 * 更多应用新增事件
 */
export const EVENT_ID_BUNDLE_LIST_CHANGED: number = 200152;

/**
 * 更多应用新增事件
 */
export const EVENT_ID_BUNDLE_ADD: number = 200153;

/**
 * 更多应用删除事件
 */
export const EVENT_ID_BUNDLE_REMOVE: number = 200154;

/**
 * App列表加载完成事件
 */
export const EVENT_ID_MORE_APP_LIST_LOADER: number = 200156;

/**
 * 电池-允许休眠时通知
 */
export const EVENT_ID_SLEEP_NOTIFICATION_ENABLE: number = 200157;

/**
 * 存储应用信息更新
 */
export const STORAGE_APP_CHANGE_EVENT: string = '200139';

/**
 * 加载更多存储应用信息
 */
export const STORAGE_APP_LOAD_MORE_EVENT: string = '200156';

/*
 * 屏幕刷新率
 */
export const EVENT_ID_REFRESH_RATE: number = 200158;

/**
 * 护眼定时弹框事件
 */
export const SHOW_EYE_TIMEPICKER = 200159;

/**
 * 护眼定时值刷新事件
 */
export const SHOW_EYE_TIMEPICKER_VALUE_FLUSH = 200160;

/**
 * 护眼开关事件
 */
export const EYE_COMFORT_TIME_SELECT = 200161;

/**
 * 护眼定时页面选择模式事件
 */
export const EYE_COMFORT_TIME_SELECT_MODE = 200162;

/**
 * 电子书开关事件
 */
export const EBOOK_SELECT = 200163;

/**
 * 护眼全天开启开关事件
 */
export const EYE_COMFORT_MODE = 200164;

/*
 * 免打扰数据变更事件
 */
export const EVENT_ID_NOT_DISTURB_UPDATE: number = 200159;

/*
 * 免打扰数据变更事件
 */
export const EVENT_ID_NOT_DISTURB_ALPHABET_INDEX_UPDATE: number = 200160;

/*
 * 无线调试
 */
export const EVENT_ID_WIRELESS_STATE_NUM: number = 7883;
export const EVENT_ID_WIRELESS_TYPE_NUM: number = 7886;
export const EVENT_ID_WIRELESS_SWITCH_STATE: string = 'EVENT_ID_WIRELESS_SWITCH_STATE';

/*
 * usb调试
 */
export const EVENT_ID_CLOSE_USB_DEBUG_SWITCH: string = 'EVENT_ID_CLOSE_USB_DEBUG_SWITCH';

/*
 * 锁屏提示音
 */
export const EVENT_ID_LOCK_SCREEN_TONE: number = 200165;

/*
 * 截屏提示音
 */
export const EVENT_ID_SCREENSHOT: number = 200166;

/*
 * 色彩调节与色温->色彩
 */
export const EVENT_ID_COLOR_MODE: number = 200167;

/**
 *  关怀模式放大显示档位
 */
export const EVENT_ID_ELDER_CARE_SLIDER_VALUE_NUM: number = 200168;

/**
 *  免打扰-来电-允许联系人
 */
export const EVENT_ID_ALLOW_CONTACTS: number = 200169;

/**
 *  关怀模式开关状态
 */
export const EVENT_ID_ELDER_CARE_SWITCH_VALUE_NUM: number = 200170;

/**
 *  关怀模式骚扰拦截-陌生号码识别
 */
export const EVENT_ID_ELDER_CARE_TEL_IDENTITY_VALUE_NUM: number = 200171;

/**
 *  声音模式变化事件
 */
export const EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED: string = 'EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED';

/**
 *  输入法切换默认输入法事件
 */
export const EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE: string = 'EVENT_ID_DEFAULT_INPUT_METHOD_CHANGE';

/**
 *  三方输入法使能状态变化事件
 */
export const INPUT_ENABLE_STATE_CHANGE: string = 'INPUT_ENABLE_STATE_CHANGE';

/**
 * 监听分屏模式和悬浮窗模式，桌面添加应用锁，更改隐私密码显示的按钮
 */
export const EVENT_ID_ON_WINDOW_STAGE_CHANGED_FOR_PRIVATE_PIN: number = 200172;

/**
 *  声音与振动-开机铃声
 */
export const EVENT_ID_BOOT_SOUND_VALUE_NUM: number = 200173;

/**
 * 账号建议显示事件
 */
export const ACCOUNT_RECOMMENDATION_CAPSULE_DISPLAY_EVENT: number = 200176;

/**
 * 关闭桌面和个性化的全屏页面事件
 */
export const EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE: number = 200177;

/*
 * 图标编辑页回后台推出事件
 */
export const EVENT_ID_ICON_SETTING_PAGE_BACKGROUND: number = 200178;

/*
 * 应用和元服务搜索框可见性
 */
export const EVENT_ID_SEARCH_BAR_VISIBLE: string = 'EVENT_ID_SEARCH_BAR_VISIBLE';

/*
 * 搜索框去除焦点事件
 */
export const EVENT_ID_SEARCH_NO_EDIT: string = 'EVENT_ID_SEARCH_NO_EDIT';

/*
 * 界面节点组变化事件
 */
export const EVENT_ID_PAGE_RENDER_GROUP_CHANGE: string = 'EVENT_ID_PAGE_RENDER_GROUP_CHANGE';