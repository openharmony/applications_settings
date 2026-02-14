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
import { LengthMetrics } from '@ohos.arkui.node';

export const SETTINGS_EYESHIELD_ENABLE = 'settings.eyeshield.enable';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE = 'settings.display.eye_comfort_mode';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_OLD = 'settings.display.eye_comfort_mode_old';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_LAST = 'settings.display.eye_comfort_last_mode';
export const SETTINGS_DISPLAY_EYE_COMFORT_LEVEL = 'settings.display.eye_comfort_level';
export const SETTINGS_DISPLAY_EYE_DC_BRIGHTNESS_SWITCH = 'settings.display.eye_dc_brightness_switch';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_CLOSE = '0';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_ALL_DAY = '1';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_TIMEON = '2';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_SUN = '3';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE_AI = '4';
export const CHECKED_DELAY: number = 50;
export const SETTINGS_DISPLAY_EYE_COMFORT_STARTTIME = 'settings.display.eye_comfort_starttime';
export const SETTINGS_DISPLAY_EYE_COMFORT_ENDTIME = 'settings.display.eye_comfort_endtime';
export const DEFAULT_START_TIME = '1320';
export const DEFAULT_END_TIME = '1860';
export const STR_START_TIME = 'startTime';
export const STR_END_TIME = 'endTime';
export const STR_ON = 'on';
export const STR_OFF = 'off';
export const STR_SUN = 'sun';
export const STR_CUSTOM = 'custom';
export const STR_EBOOK_COLOR = 'color';
export const STR_EBOOK_BLACK = 'black';
export const ENABLED: string = '1';
export const DISABLED: string = '0';
export const ENABLED_TEMP: string = '3';
export const DISABLED_TEMP: string = '2';
export const MIN_60: number = 60;
export const HOUR_24: number = 24;
export const HOUR_7: number = 7;
export const HOUR_22: number = 22;
export const HOUR_12: number = 12;
export const REFRESH_EYE_COMFORT_MODE_START_TIME: string = 'refresh_eye_comfort_mode_start_time';
export const REFRESH_EYE_COMFORT_MODE_END_TIME: string = 'refresh_eye_comfort_mode_end_time';
export const SUBMIT_ACTION: string = 'submit';
export const DISPLAY_EYE_SHIELD = 'settings.eyeshield.enable';
export const SETTINGS_DISPLAY_EYE_COMFORT_CALLBACK = 'settings.display.eye_comfort_eyeTimeOnCallBack';
export const SETTINGS_DISPLAY_EBOOK_SWITCH: string = 'settings.display.ebook_switch';
export const ADVANCE_SETTING_PARAM: string = 'const.config.display.advanced_settings_enabled';
export const SETTINGS_DISPLAY_SUPPORT_EXPAND = 'const.settings.support_expand';
export const SETTINGS_DISPLAY_HDR_PIC_SWITCH: string = 'settings.display.hdr_picture_switch';
export const SETTINGS_DISPLAY_BIONIC_VISION_SWITCH: string = 'settings.display.prog_disp_switch';
export const SETTINGS_DISPLAY_AIHDR_VIDEO_SWITCH: string = 'settings.display.AiHDR_video_switch';
export const SETTINGS_DISPLAY_EBOOK_MODE: string = 'settings.display.ebook_mode';
export const BLACK_PICTURE_BOOK = '1';
export const COLOR_PICTURE_BOOK = '2';
export const INVALID_MODE = '-1';
export const SWITCH_ENABLED: string = '1';
export const SWITCH_DISABLED: string = '0';
export const EVENT_EBOOK_SWITCH: string = 'EVENT_EBOOK_SWITCH';
export const EVENT_EBOOK_MODE: string = 'EVENT_EBOOK_MODE';
export const SUPPORT_BIONIC_VISION: string = 'settings.display.supportBionicVision';
export const SHOW_TOAST_TIME: number = 2000;
export const SUPPORT_HDR: string = 'settings.display.supportHdr';
export const EVENT_DISPLAY_DEVICE_CHANGE: string = 'display_current_device_change';

// 首选项key
export const NATURAL_COLOR_TEMPERATURE_KEY: string = 'settings.display.naturalColorTemperature';

// 色温模式
export const DISPLAY_COLOR_TEMPERATURE_MODE_TABLE: string = 'settings.color_temperature';
export const DISPLAY_COLOR_TEMPERATURE_COORDINATE_TABLE: string = 'settings.color_temperature_coordinate';
export enum DisplayColorTemperatureMode {
  STANDARD = 'default',
  WARM = 'warm',
  COOL = 'cold',
  NATURE = 'nature',
  CUSTOM = 'custom',
}

// 色彩模式
export const DISPLAY_COLOR_MODE_TABLE: string = 'settings.color_mode';
export enum DisplayColorMode {
  STANDARD = 'standard',
  VIVID = 'bright',
}

export class DisplayEventConstant {
  // 色温盘标点坐标改变事件
  public static readonly EVENT_DISPLAY_COLOR_TEMPERATURE_DISC_CHANGE: string = 'settings.event.display.color.temperature.disc.change';
  // 色温盘标点用户拖动事件
  public static readonly EVENT_DISPLAY_COLOR_TEMPERATURE_DISC_DRAG: string = 'settings.event.display.color.temperature.disc.drag';
}

export const APP_NAME: string = 'com.ohos.associateassistant';
export const KEY_MOUSE_SERVICE: string = 'KeyMouseService';
export const KEY_MOUSE_SERVICE_DESCRIPTOR: string = 'com.ohos.associateassistant.KeyMouseManager';
export const KEY_MOUSE_SERVICE_SETTINGS_DESCRIPTOR = 'com.ohos.associateassistant.SettingsStub';
/** 默认卡片宽度 */
export const DEFAULT_CARD_WIDTH = 200;

/** 默认卡片高度 */
export const DEFAULT_CARD_HEIGHT = 130;

export const PHONE_CARD_WIDTH = 36;
export const PHONE_CARD_HEIGHT = 80;


export const PAD_CARD_WIDTH = 120;
export const PAD_CARD_HEIGHT = 80;

export class DisplayResolution {
  /** 显示器高度对应选项值 */
  public height: number = 1600;

  /** 显示器宽度选项对应选项值 */
  public width: number = 2400;

  constructor(height: number, width: number) {
    this.height = height;
    this.width = width;
  }
}

export class DisplayConstants {
  /** 分辨率 2400 * 1600 */
  public static readonly DisplayResolution_2400_1600 = new DisplayResolution(1600, 2400);

  /** 分辨率 1920 * 1280 */
  public static readonly DisplayResolution_1920_1280 = new DisplayResolution(1280, 1920);

  /** 分辨率 1920 * 1080 */
  public static readonly DisplayResolution_1920_1080 = new DisplayResolution(1080, 1920);

  /** 分辨率 2560 * 1600 */
  public static readonly DisplayResolution_2560_1600 = new DisplayResolution(1600, 2560);

  /** 分辨率 2160 * 1440 */
  public static readonly DisplayResolution_2160_1440 = new DisplayResolution(1440, 2160);

  /** 分辨率 3000 * 2000 */
  public static readonly DisplayResolution_3000_2000 = new DisplayResolution(2000, 3000);

  /** 分辨率 3840 * 2560 */
  public static readonly DisplayResolution_3840_2560 = new DisplayResolution(2560, 3840);

  /** 分辨率 3100 * 2080 */
  public static readonly DisplayResolution_3100_2080 = new DisplayResolution(2080, 3100);

  /** 刷新率 60 hz */
  public static readonly RefreshRate_60 : string = '60';

  /** 刷新率 75 hz */
  public static readonly RefreshRate_75 : string = '75';

  /** 刷新率 80 hz */
  public static readonly RefreshRate_80 : string = '80';

  /** 刷新率 100 hz */
  public static readonly RefreshRate_100 : string = '100';

  /** 刷新率 120 hz */
  public static readonly RefreshRate_120 : string = '120';

  /** 默认数字 */
  public static readonly DEFAULT_NUMBER = 0;

  /** 默认宽度 */
  public static readonly DEFAULT_WIDTH = 0.00;

  /** 默认高度 */
  public static readonly DEFAULT_HEIGHT = 0.00;

  /** 默认卡片宽度 */
  public static readonly DEFAULT_CARD_WIDTH = 200;

  /** 默认卡片高度 */
  public static readonly DEFAULT_CARD_HEIGHT = 130;

  /** 默认最大卡片高度 */
  public static readonly DEFAULT_CARD_HEIGHT_MAX = 153;

  /** 默认最小卡片高度 */
  public static readonly DEFAULT_CARD_HEIGHT_MIN = 110;

  /** 缩略图缓存分辨率缩放比 */
  public static readonly DEFAULT_SIZE_SCALE_RATE = 0.2;

  /** 默认按钮宽度 */
  public static readonly DEFAULT_BUTTON_WIDTH = 120;

  /** 默认按钮宽度 */
  public static readonly DEFAULT_BUTTON_HEIGHT = 40;

  /** 默认边框大小 */
  public static readonly DEFAULT_BORDER_WIDTH = 2;

  /** 默认边框圆角 */
  public static readonly DEFAULT_BORDER_RADIUS = 10;

  /** 键鼠后，手机边框圆角 */
  public static readonly PHONE_BORDER_RADIUS = 4;

  /** 默认返回宽度 */
  public static readonly DEFAULT_BACK_WIDTH = 24;

  /** 默认返回高度 */
  public static readonly DEFAULT_BACK_HEIGHT = 24;

  /** 默认拖拽窗口宽度 */
  public static readonly DEFAULT_DRAG_AREA_WIDTH = 638;

  /** 默认拖拽窗口高度 */
  public static readonly DEFAULT_DRAG_AREA_HEIGHT = 274;

  /** 默认分屏下弹窗窗口宽度比例 */
  public static readonly DEFAULT_SPLIT_SCREEN_DIALOG_WIDTH_RATE = '75%';

  /** 默认弹窗窗口宽度 */
  public static readonly DEFAULT_DIALOG_WIDTH = 640;

  /** 默认弹窗窗口高度 */
  public static readonly DEFAULT_DIALOG_HEIGHT = 408;

  /** 默认拖拽窗口 左侧坐标 */
  public static readonly DEFAULT_DRAG_AREA_LEFT = 323.5;

  /** 默认拖拽窗口 顶部坐标 */
  public static readonly DEFAULT_DRAG_AREA_TOP = 332;

  /** 默认拖拽窗口 右侧坐标 */
  public static readonly DEFAULT_DRAG_AREA_RIGHT = 1121;

  /** 默认拖拽窗口 底部坐标 */
  public static readonly DEFAULT_DRAG_AREA_BOTTOM = 647.5;

  /** 设备框高度 */
  public static readonly DEFAULT_IMAGE_DEVICE_HEIGHT = 218;

  /** 展示框高度 */
  public static readonly DEFAULT_IMAGE_DISPLAY_HEIGHT = 200;

  /** 方位设置弹窗辅助文本分割线高度 */
  public static readonly DIALOG_SUBTITLE_LINE_HEIGHT = 25;

  /** 分割线高度 */
  public static readonly DEFAULT_LINE_HEIGHT = 5;

  /** 键鼠设备栏高度 */
  public static readonly REMOTE_DEVICE_IMAGE_DISPLAY_HEIGHT = 66;

  /** List组件间隔 */
  public static readonly DEFAULT_LIST_SPACE = 2;

  /** 字体可写宽度 */
  public static readonly DEFAULT_FONT_WIDTH = 500;

  /** 默认补差 */
  public static readonly DEFAULT_ITEM_INTV = 120;

  /** 默认速率 */
  public static readonly DEFAULT_VELOCITY = 0;

  /** 默认大小 */
  public static readonly DEFAULT_MASS = 1;

  /** 默认僵直 */
  public static readonly DEFAULT_STIFFNESS = 400;

  /** 默认阻尼 */
  public static readonly DEFAULT_DAMPING = 38;

  /** 默认尺度 */
  public static readonly DEFAULT_SCALE = 20;

  /** 动画延迟 */
  public static readonly ANIMATETO_DELAY = 150;

  /** 动画时长 */
  public static readonly ANIMATETO_DURATION = 300;

  /** 动画速率 */
  public static readonly ANIMATETO_VELOCITY = 14;

  /** 动画大小 */
  public static readonly ANIMATETO_MASS = 1;

  /** 动画僵直 */
  public static readonly ANIMATETO_STIFFNESS = 170;

  /** 动画阻尼 */
  public static readonly ANIMATETO_DAMPING = 17;

  /** 按钮宽 */
  public static readonly BUTTON_WIDTH = 120;

  /** 按钮高 */
  public static readonly BUTTON_HEIGHT = 40;

  /** 按钮绝对定位X */
  public static readonly BUTTON_X = 650;

  /** 按钮绝对定位Y */
  public static readonly BUTTON_Y = 10;

  /** 默认缩放比例 */
  public static readonly DEFAULT_ZOOM = 1;

  /** 默认允许误差 */
  public static readonly DEFAULT_DIFF = 3;

  /** 默认最大吸附 */
  public static readonly DEFAULT_SNAP = 0.15;

  /** 方位设置按钮间距 */
  public static readonly DIALOG_BUTTON_SPACE_VERTICAL = 400;

  /** 操作区与内容区间距 */
  public static readonly DIALOG_CONTENT_BUTTON_SPACE = -20;

  /** 文本描述区与标题区间距 */
  public static readonly DIALOG_TITLE_SUBTITLE_SPACE = '-12vp';

  /** 内容区与文本描述区间距 */
  public static readonly DIALOG_SUBTITLE_CONTENT_SPACE = '4vp';

  /** 图片间距 */
  public static readonly DRAG_IMAGE_SPACE = LengthMetrics.px(2);

  /** 宽度自适应 */
  public static readonly WIDTH_AUTO = -1;
}