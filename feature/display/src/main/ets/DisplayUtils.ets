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

import Settings from '@ohos.settings';
import hgmnapi from '@ohos.libhgmnapi.z.so';
import systemParameter from '@ohos.systemparameter';
import uiAppearance from '@ohos.uiAppearance';
import emitter from '@ohos.events.emitter';
import lazy { default as Brightness } from '@ohos.brightness';
import deviceInfo from '@ohos.deviceInfo';
import display from '@ohos.display';
import screen from '@ohos.screen';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import DpiManager from '@ohos/settings.common/src/main/ets/utils/DpiManager';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import {
  EVENT_ID_REFRESH_RATE,
  EVENT_ID_COLOR_MODE,
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { DeviceUserType } from './controller/DevicesController';
import { DisplayMeunShowUtils } from './utils/DisplayMenuShowUtils';
import {
  INVALID_MODE,
  SETTINGS_DISPLAY_EBOOK_MODE,
  SETTINGS_DISPLAY_EBOOK_SWITCH,
  SWITCH_DISABLED,
  SWITCH_ENABLED,
  COLOR_PICTURE_BOOK,
  BLACK_PICTURE_BOOK
} from './constant/DisplayConstant'
import { systemParameterEnhance } from '@kit.BasicServicesKit';

/* instrument ignore file */
const SCREEN_ID: number = 0;
const TAG: string = 'DisPlayUtils: ';
const SETTINGS_DATA_BRIGHTNESS = Settings.display.SCREEN_BRIGHTNESS_STATUS;
const DOMAIN_NAME: string = Settings.domainName.USER_PROPERTY;
// 深色模式是否全天开启
const KEY_DARK_MODE_ALL_DAY_ENABLE: string = 'AllDaySettingKey';
const ENABLED: string = '1';
const DISABLED: string = '0';
const SWITCH_DELAY: number = 200;
const OPTION_DELAY: number = 200;
const USER_SET_DPI_VALUE: string = 'user_set_dpi_value';
const INTENT_SET_DISPLAY_SIZE: string = 'intentSetDisplaySize';

const BRIGHTNESS_STEP: number = 10;
const AIHDR_VIDEO_DEFAULT_ENABLE: string = 'const.display.aihdr_video_default_enable';

const CUSTOM_REFRESH_RATE_LEVEL_MAP: Map<number, string> = new Map([
  [1, 'app.string.screen_refresh_rate_standard'],
  [2, 'app.string.screen_refresh_rate_mid'],
  [3, 'app.string.screen_refresh_rate_high'],
  [0, 'app.string.screen_refresh_rate_dynamic'],
]);

const DISPLAY_SIZE_ARR: number[] = [
  0, // 小
  1, // 默认
  2, // 大
  3, // 较大
  4, // 最大
];

// 屏幕刷新率
const REFRESH_TYPE: string = 'settings.display.hw_screen_freq';
const DYNAMIC_TYPE: string = '-1';
const HIGH_TYPE: string = '3';
const MID_TYPE: string = '2';
const STANDARD_TYPE: string = '1';

const SCREEN_REFRESH_RATE_STANDARD: string = 'Standard';
const SCREEN_REFRESH_RATE_HIGH_NUMBER: number = 3;
const PRODUCT_MODE_INFO_NOH: string = 'NOH';
// 当前设备id
const DISPLAY_CURRENT_DEVICE_ID: string = 'display_current_device_id';
// 用户设置模式
const USER_SET_DEVICE_MODE: string = 'user_set_last_screen_mode';
// 用户设置方位
const DEVICE_POSITIONS: string = 'user_set_relative_position';
// EDID字段
const DEVICE_EDID: string = 'user_set_screen_mode_edid';
// 合规ID最小限制
const IS_PROVED_ID_MIN: number = -1;
// 合规ID最大限制
const IS_PROVED_ID_MAX: number = 999;

enum ScreenRefreshRate {
  'High' = 3,
  'Medium' = 2,
  'Standard' = 1,
  'Dynamic' = 0,
}

enum DisplayMode {
  'MainDisplay' = DeviceUserType.MAIN_SCREEN,
  'ExtendDisplay' = DeviceUserType.EXTENDED,
  'Mirror' = DeviceUserType.MIRROR,
}

export enum ColorPattern {
  STANDARD = 'standard',
  VIVID = 'bright',
}

export enum ColorPatternTitle {
  'standard' = 'standard_color_title',
  'bright' = 'vivid_color_title',
}

export enum ColorTemperaturePattern {
  DEFAULT = 'default',
  WARM = 'warm',
  COOL = 'cold',
  NATURE = 'nature'
}

export enum ColorTemperaturePatternTitle {
  'default' = 'standard_color_title',
  'warm' = 'warm_color',
  'cold' = 'cool_color',
  'nature' = 'nature_color',
}

export const SUMMARIES_LARGER: Resource[] = [
  $r('app.string.screen_zoom_summary_large'),
  $r('app.string.screen_zoom_summary_very_large'),
  $r('app.string.screen_zoom_summary_extremely_large')];

export enum SleepTime {
  FIFTEEN_SECONDS = '15000',
  THIRTY_SECONDS = '30000',
  ONE_MINUTE = '60000',
  TWO_MINUTES = '120000',
  FIVE_MINUTES = '300000',
  TEN_MINUTES = '600000',
  NEVER_SLEEP = '-1',
}

export enum TextFontWeight {
  TEXT_FONT_WEIGHT_LIGHTEST = 'text_font_weight_lightest', // 最细
  TEXT_FONT_WEIGHT_LIGHT = 'text_font_weight_light', // 细
  TEXT_FONT_WEIGHT_NORMAL = 'text_font_weight_normal', // 标准
  TEXT_FONT_WEIGHT_BOLD = 'text_font_weight_bold', // 粗
  TEXT_FONT_WEIGHT_BOLDEST = 'text_font_weight_boldest', // 最粗
}

export const SUMMARIES_SMALLER: Resource[] = [$r('app.string.screen_zoom_summary_small')];

export const SUMMARY_DEFAULT: Resource = $r('app.string.screen_zoom_summary_default');

/**
 * 注释屏幕不熄屏 开关打开 1
 */
export const GAZE_ON: string = '1';

/**
 * 注释屏幕不熄屏 开关关闭 0 默认值
 */
export const GAZE_OFF: string = '0';

/**
 * 注释屏幕不熄屏 产品是否支持 支持为1 不支持0 默认值 0
 */
export const GAZE_NO_TURNING_OFF = 'const.config.swing_enabled';

/**
 * 显示工具类
 */
export class DisplayUtils {
  private static readonly DEFAULT_BRIGHTNESS: string = systemParameter.getSync('const.display.brightness.default');
  private static readonly MAX_BRIGHTNESS: number = Number(systemParameter.getSync('const.display.brightness.max'));
  private static readonly MIN_BRIGHTNESS: number = Number(systemParameter.getSync('const.display.brightness.min'));
  private static switchTimerId: number | null = null;
  private static optionTimerId: number | null = null;

  /**
   * 获取实时屏幕亮度
   */
  static getBrightnessValue(): number {
    let brightness = SettingsDataUtils.getSettingsData(SETTINGS_DATA_BRIGHTNESS, DisplayUtils.DEFAULT_BRIGHTNESS);
    let sliderValue: number = DisplayUtils.countUIValue(Number(brightness));
    return Math.min(sliderValue, DisplayUtils.getBrightnessSliderMax());
  }

  /**
   * 亮度条最大亮度
   */
  static getBrightnessSliderMax(): number {
    return DisplayUtils.MAX_BRIGHTNESS;
  }

  /**
   * 亮度条最小亮度
   */
  static getBrightnessSliderMin(): number {
    return DisplayUtils.MIN_BRIGHTNESS;
  }

  /**
   * 亮度条调节步长
   */
  static getBrightnessSliderStep(): number {
    return BRIGHTNESS_STEP;
  }

  /**
   * 通过算法将实际物理亮度值转化为显示亮度值
   */
  static countUIValue(britVar: number): number {
    let brightnessRange: number = DisplayUtils.MAX_BRIGHTNESS - DisplayUtils.MIN_BRIGHTNESS;
    let sliderRange: number = brightnessRange;
    brightnessRange = brightnessRange > 0 ? brightnessRange : 254;
    let percentage: number = Math.pow(((britVar - DisplayUtils.MIN_BRIGHTNESS) / brightnessRange), 1 / 1.8);
    let brightnessUI: number = percentage * sliderRange + DisplayUtils.MIN_BRIGHTNESS;
    return brightnessUI;
  }

  /**
   * 通过算法将显示亮度值转化为实际物理亮度值
   */
  static countPhysicsValue(uiVar: number): number {
    let brightnessRange: number = DisplayUtils.MAX_BRIGHTNESS - DisplayUtils.MIN_BRIGHTNESS;
    let sliderRange: number = brightnessRange;
    sliderRange = sliderRange > 0 ? sliderRange : 254;
    let brightness: number = Math.pow((uiVar - DisplayUtils.MIN_BRIGHTNESS) / sliderRange, 1.8) *
      brightnessRange + DisplayUtils.MIN_BRIGHTNESS;
    LogUtil.info(`${TAG} uiVar: ${uiVar} countPhysicsValue: ${brightness} brightnessRange: ${brightnessRange}`);
    return Math.round(brightness);
  }

  /**
   * 设置亮度值
   */
  static setBrightnessValue(value: number): void {
    Brightness.setValue(DisplayUtils.countPhysicsValue(value));
  }

  /**
   * 获取实时屏幕刷新率
   */
  static getScreenRefreshType(): string {
    let currentMode: number = hgmnapi.getCurrentRefreshRateMode(SCREEN_ID) as number;
    let refreshRateMode: string = ScreenRefreshRate[currentMode];
    let productModel: string = deviceInfo.productModel;
    if (CheckEmptyUtils.isEmpty(productModel)) {
      return SCREEN_REFRESH_RATE_STANDARD;
    }
    let productModelInfo: string = deviceInfo.productModel.split('-')[0];
    if (productModelInfo === PRODUCT_MODE_INFO_NOH && currentMode === SCREEN_REFRESH_RATE_HIGH_NUMBER) {
      refreshRateMode = SCREEN_REFRESH_RATE_STANDARD;
    }
    return refreshRateMode;
  }

  /**
   * 设置休眠时间长度
   */
  static setSleepValue(value: string): void {
    SettingsDataUtils.setSettingsData(Settings.display.SCREEN_OFF_TIMEOUT, value);
  }

  /**
   * 获取休眠时间
   */
  static getSleepValue(): string {
    let currentSelectedValue: string = SettingsDataUtils.getSettingsData(Settings.display.SCREEN_OFF_TIMEOUT,
      SleepTime.THIRTY_SECONDS);
    return currentSelectedValue;
  }

  /**
   * 获取休眠时间对应的标题
   */
  static getSleepValueTitle(): string {
    let sleepTime: string = SettingsDataUtils.getSettingsData(Settings.display.SCREEN_OFF_TIMEOUT,
      SleepTime.THIRTY_SECONDS);
    let resource: Resource = $r('app.string.after_thirty_seconds');
    let formatValue: number = Number(sleepTime) / 1000;
    switch (sleepTime) {
      case SleepTime.FIFTEEN_SECONDS:
        resource = $r('app.string.after_fifteen_seconds');
        formatValue = Number(sleepTime) / 1000;
        break;
      case SleepTime.THIRTY_SECONDS:
        resource = $r('app.string.after_thirty_seconds');
        formatValue = Number(sleepTime) / 1000;
        break;
      case SleepTime.ONE_MINUTE:
      case SleepTime.TWO_MINUTES:
      case SleepTime.FIVE_MINUTES:
      case SleepTime.TEN_MINUTES:
        resource = $r('app.string.after_one_minute');
        formatValue = Number(sleepTime) / 1000 / 60;
        break;
      default:
        return ResourceUtil.getStringSync($r('app.string.other_time'));
    }
    return ResourceUtil.getNumberFormatStringSync(resource, String(formatValue));
  }

  /**
   * 设置显示大小
   */
  static async setDisplaySizeValue(value: string) {
    if (CheckEmptyUtils.isEmptyArr(DpiManager.densityList)) {
      // setDpiName中会使用screenClass实例,这里需要await确保实例创建成功
      await DisplayUtils.getScreenZoomAsync();
    }
    if (CheckEmptyUtils.isEmpty(DpiManager.screenClass)) {
      await DpiManager.getClassInstance();
    }
    const index: number = Number(value);
    PreferencesUtil.putSync(INTENT_SET_DISPLAY_SIZE, index);
    DpiManager.setDpiName(index);
    AppStorage.setOrCreate('display_size_value', index);
    EventBus.getInstance().emit('screenRoomView_slider_value', index);
    LogUtil.info(`${TAG} SetDisplaySizeValue: ${value}`);
  }

  /**
   * 异步获取实时显示大小，对获取实例进行await，确保执行后续操作可以获取到实例
   */
  static async getScreenZoomAsync(): Promise<number> {
    let displaySize: number = PreferencesUtil.getSync(INTENT_SET_DISPLAY_SIZE, -1) as number;
    if (DISPLAY_SIZE_ARR.includes(displaySize)) {
      PreferencesUtil.delete(INTENT_SET_DISPLAY_SIZE);
      return displaySize;
    }
    await DpiManager.getClassInstance();
    return DisplayUtils.doGetScreenZoom();
  }

  /**
   * 获取实时显示大小
   */
  static getScreenZoom(): number {
    let displaySize: number = PreferencesUtil.getSync(INTENT_SET_DISPLAY_SIZE, -1) as number;
    if (DISPLAY_SIZE_ARR.includes(displaySize)) {
      PreferencesUtil.delete(INTENT_SET_DISPLAY_SIZE);
      return displaySize;
    }
    DpiManager.getClassInstance();
    return DisplayUtils.doGetScreenZoom();
  }

  static doGetScreenZoom():number {
    let inSetValue: number = 0;
    DpiManager.setDefaultDpi(displayDataManager.getDefaultDPI());
    inSetValue = DpiManager.setNumberAndScale(SUMMARIES_LARGER, SUMMARIES_SMALLER, SUMMARY_DEFAULT);
    let dpi = SettingsDataUtils.getSettingsData(USER_SET_DPI_VALUE, DpiManager.defaultDensityDpi.toString());
    inSetValue = DpiManager.getIndexByDpi(Number(dpi));
    LogUtil.info(`${TAG} inSetValue is ${inSetValue}`);
    return inSetValue;
  }

  /**
   * 获取字体显示大小档位个数
   */
  static getDisplaySizeCount(): number {
    DpiManager.getClassInstance();
    DpiManager.setDefaultDpi(displayDataManager.getDefaultDPI());
    DpiManager.setNumberAndScale(SUMMARIES_LARGER, SUMMARIES_SMALLER, SUMMARY_DEFAULT);
    return DpiManager.numSmaller + DpiManager.numLarger + 1;
  }

  /**
   * 获取设置显示大小标题
   */
  static getDisplaySizeValueTitle(): string {
    let inSetValue: number = 0;
    DpiManager.getClassInstance();
    DpiManager.setDefaultDpi(displayDataManager.getDefaultDPI());
    inSetValue = DpiManager.setNumberAndScale(SUMMARIES_LARGER, SUMMARIES_SMALLER, SUMMARY_DEFAULT);
    let dpi = SettingsDataUtils.getSettingsData(USER_SET_DPI_VALUE, DpiManager.defaultDensityDpi.toString());
    inSetValue = DpiManager.getIndexByDpi(Number(dpi));
    const title: string = ResourceUtil.getStringSync(DpiManager.getDpiName(inSetValue));
    LogUtil.info(`${TAG} getDisplaySizeValueTitle: ${title}`)
    return title;
  }

  /**
   * 获取文字大小
   * @returns 文字大小
   */
  public static getFontSize(): number {
    let fontScale = uiAppearance.getFontScale();
    return DisplayUtils.getDefaultFontSizeStep(fontScale);
  }

  /**
   * 设置文字大小
   * @param value 文字大小
   */
  public static async setFontSizeValue(value: string): Promise<void> {
    LogUtil.info(`${TAG} setFontSize target fontSize ${value}`)
    let fontSize = Number(value)
    let fontScale = DisplayUtils.getFontScaleByFontSizeValue(fontSize);
    LogUtil.info(`${TAG} fontScale of target fontSize ${fontScale}`)
    await uiAppearance.setFontScale(fontScale);
    SettingsDataUtils.setSettingsDataDomain(Settings.display.FONT_SCALE,
      fontScale.toString(), Settings.domainName.USER_PROPERTY);
    EventBus.getInstance().emit('fontSizeView_slider_value', Number(value));
  }

  /**
   * 获取文字大小对应显示值
   * @param fontSize 文字大小
   * @returns 显示title
   */
  public static getFontSizeValueTitle(): string {
    let fontSize = DisplayUtils.getFontSize();
    switch (fontSize) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_small');
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_normal');
      case DisplayConstant.TEXT_FONT_SIZE_LARGE_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_large');
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_extra_large');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_huge');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_huge2');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_huge3');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4_STEP:
        return ResourceUtil.getStringByName('display_mode_font_size_huge4');
      default:
        return ResourceUtil.getStringByName('display_mode_font_size_normal');
    }
  }

  /**
   * 获取字体粗细
   */
  public static getTextFontWeight(): string {
    let defaultFontWeightScale: number = Number(SettingsDataUtils
      .getSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, DisplayConstant.DEFAULT_FONT_WEIGHT_SCALE,
        Settings.domainName.USER_PROPERTY));
    switch (defaultFontWeightScale) {
      case DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST: // 最细
        return TextFontWeight.TEXT_FONT_WEIGHT_LIGHTEST;
      case DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST: // 最粗
        return TextFontWeight.TEXT_FONT_WEIGHT_BOLDEST;
      case DisplayConstant.TEXT_FONT_WEIGHT_NORMAL: // 标准
        return TextFontWeight.TEXT_FONT_WEIGHT_NORMAL;
      default:
        break;
    }
    if (defaultFontWeightScale > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) { // 粗
      return TextFontWeight.TEXT_FONT_WEIGHT_BOLD;
    }
    return TextFontWeight.TEXT_FONT_WEIGHT_LIGHT;
  }

  /**
   * 设置字体粗细
   */
  public static setTextFontWeight(value: string): void {
    let fontWeightScale: number = 0;
    switch (value) {
      case TextFontWeight.TEXT_FONT_WEIGHT_LIGHTEST: // 最细
        fontWeightScale = DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST;
        break;
      case TextFontWeight.TEXT_FONT_WEIGHT_NORMAL: // 标准
        fontWeightScale = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
        break;
      case TextFontWeight.TEXT_FONT_WEIGHT_BOLDEST: // 最粗
        fontWeightScale = DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST;
        break;
      case TextFontWeight.TEXT_FONT_WEIGHT_LIGHT: // 细
        fontWeightScale = (DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST + DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) / 2;
        break;
      case TextFontWeight.TEXT_FONT_WEIGHT_BOLD: // 粗
        fontWeightScale = (DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST + DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) / 2;
        break;
      default:
        break;
    }
    try {
      uiAppearance.setFontWeightScale(fontWeightScale);
      LogUtil.info(`${TAG} updateConfiguration success, ${fontWeightScale}`);
      SettingsDataUtils.setSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE,
        fontWeightScale.toString(), Settings.domainName.USER_PROPERTY);
      EventBus.getInstance().emit('fontWeightView_slider_value', fontWeightScale);
    } catch (err) {
      LogUtil.error(`${TAG} updateConfiguration error: ${err?.code}, message: ${err?.message}`);
    }
  }

  /**
   * 获取文字粗细对应显示值
   */
  public static getTextFontWeightTitle(): string {
    let defaultFontWeightScale: number = Number(SettingsDataUtils
      .getSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, DisplayConstant.DEFAULT_FONT_WEIGHT_SCALE,
        Settings.domainName.USER_PROPERTY));
    let fontWeightName: string = ResourceUtil.getStringByName('display_mode_font_weight_normal');
    if (defaultFontWeightScale === DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST) {
      fontWeightName = ResourceUtil.getStringByName('display_mode_font_weight_lightest');
    }

    if (defaultFontWeightScale > DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      defaultFontWeightScale < DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      fontWeightName = ResourceUtil.getStringByName('display_mode_font_weight_light');
    }

    if (defaultFontWeightScale === DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      fontWeightName = ResourceUtil.getStringByName('display_mode_font_weight_normal');
    }

    if (defaultFontWeightScale > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      defaultFontWeightScale < DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      fontWeightName = ResourceUtil.getStringByName('display_mode_font_weight_bold');
    }

    if (defaultFontWeightScale === DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      fontWeightName = ResourceUtil.getStringByName('display_mode_font_weight_boldest');
    }
    return fontWeightName;
  }

  /**
   * 根据字体大小获取字体缩放比例
   * @param value
   * @returns
   */
  static getFontScaleByFontSizeValue(value: number): number {
    switch (value) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_SMALL;
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_NORMAL;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_LARGE;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE2;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE3;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4_STEP:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE4;
      default:
        return DisplayConstant.TEXT_FONT_SIZE_NORMAL;
    }
  }

  static supportRefreshRates(): boolean {
    try {
      let refreshRates: number[] = [];
      refreshRates = hgmnapi.getScreenSupportedRefreshRates(SCREEN_ID);
      LogUtil.info(`${TAG} refreshRates length is ${refreshRates.length}`);
      return refreshRates.length === 3;
    } catch (error) {
      LogUtil.error(`${TAG} getScreenSupportedRefreshRates ${error?.message} code: ${error?.code}`);
      return true;
    }
  }

  /**
   * 设置刷新率模式SCREEN_REFRESH_RATE
   */
  static setScreenRefreshRateValue(value: string) {
    let refreshValue: string = value.toLowerCase();
    let refreshType: number = Number(DYNAMIC_TYPE);
    switch (refreshValue) {
      case 'high':
        refreshType = DisplayUtils.supportRefreshRates() ? Number(MID_TYPE) : Number(HIGH_TYPE);
        break;
      case 'standard':
        refreshType = Number(STANDARD_TYPE);
        break;
      case 'medium':
        refreshType = Number(MID_TYPE);
        break;
      default:
        refreshType = Number(DYNAMIC_TYPE);
        break;
    }
    try {
      SettingsDataUtils.setSettingsData(REFRESH_TYPE, String(refreshType));
      hgmnapi.setRefreshRateMode(refreshType);
      emitter.emit({
        eventId: EVENT_ID_REFRESH_RATE
      });
      LogUtil.info(`${TAG} refreshType is ${refreshType}`);
    } catch (error) {
      LogUtil.error(`${TAG} setRefreshRateMode fail ${error?.code} msg ${error?.message}`);
    }
  }

  /**
   * 查询“屏幕刷新率”的实时状态
   */
  static getRefreshType(): string {
    let refreshType: string = SettingsDataUtils.getSettingsData(REFRESH_TYPE, '-1');
    LogUtil.info(`${TAG} getRefreshType ${refreshType}`);
    let refreshText: string = '';
    switch (refreshType) {
      case DYNAMIC_TYPE:
        refreshText = 'Dynamic';
        break;
      case MID_TYPE:
        refreshText = DisplayUtils.supportRefreshRates() ? 'High' : 'Medium';
        break;
      case STANDARD_TYPE:
        refreshText = 'Standard';
        break;
      case HIGH_TYPE:
        refreshText = 'High';
        break;
      default:
        refreshText = 'Dynamic';
        break;
    }
    return refreshText;
  }

  /**
   * 屏幕刷新率--展示的title
   */
  static getRefreshTypeTitle(): string {
    let refreshType: string = SettingsDataUtils.getSettingsData(REFRESH_TYPE, '-1');
    LogUtil.info(`${TAG} getRefreshTypeTitle ${refreshType}`);
    let refreshTitle: string = '';
    switch (refreshType) {
      case STANDARD_TYPE:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_standard');
        break;
      case MID_TYPE:
        refreshTitle = DisplayUtils.supportRefreshRates() ? ResourceUtil.getStringByName('screen_refresh_rate_high') :
              ResourceUtil.getStringByName('screen_refresh_rate_mid');
        break;
      case DYNAMIC_TYPE:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_dynamic');
        break;
      case HIGH_TYPE:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_high');
        break;
      default:
        refreshTitle = ResourceUtil.getStringByName('screen_refresh_rate_dynamic');
        break;
    }
    return refreshTitle;
  }

  /**
   * 当前亮度自动调节开关状态
   */
  static isAutoBrightness(): boolean {
    let isAutoBright: boolean = SettingsDataUtils.getSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS,
      '1') === '1';
    return isAutoBright;
  }

  /**
   * 判断是否是电子书模式
   * @returns true：是
   */
  static isEbookMode(): boolean {
    const isEbook =
      SettingsDataUtils.getSettingsData(SETTINGS_DISPLAY_EBOOK_SWITCH, SWITCH_DISABLED,
        Settings.domainName.USER_PROPERTY) === SWITCH_ENABLED;
    LogUtil.info(`${TAG} getIsEbook. isEbook:${isEbook}`);
    return isEbook;
  }

  /**
   * 打开电子书模式
   * @returns
   */
  static enableEbookMode(): boolean {
    SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EBOOK_SWITCH, SWITCH_ENABLED,
      Settings.domainName.USER_PROPERTY);
    let oriEbookMode: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_EBOOK_MODE,
      INVALID_MODE, Settings.domainName.USER_PROPERTY);
    if (oriEbookMode === INVALID_MODE) {
      SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EBOOK_MODE,
        DisplayMeunShowUtils.isColorEBookSupport() ? COLOR_PICTURE_BOOK : BLACK_PICTURE_BOOK,
        Settings.domainName.USER_PROPERTY);
    }
    return true;
  }

  /**
   * 关闭电子书模式
   * @returns
   */
  static disableEbookMode(): boolean {
    SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EBOOK_SWITCH, SWITCH_DISABLED,
      Settings.domainName.USER_PROPERTY);
    return true;
  }

  /**
   * 开启亮度自动调节开关
   */
  static autoSwitchOn(): boolean {
    SettingsDataUtils.setSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS, '1');
    return true;
  }

  /**
   * 关闭亮度自动调节开关
   */
  static autoSwitchOff(): boolean {
    SettingsDataUtils.setSettingsData(Settings.display.AUTO_SCREEN_BRIGHTNESS, '0');
    return true;
  }

  /**
   * 获取是否已启用”深色模式全天开启“功能
   *
   * @returns 是否已启用”深色模式全天开启“功能
   */
  public static isDarkModeAllDayEnabled(): boolean {
    return uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
  }

  /**
   * 保存是否启用”深色模式全天开启“功能
   *
   * @param isEnabled true开启，false关闭
   */
  public static setDarkModeAllDayEnabled(isEnabled: boolean): void {
    SettingsDataUtils.setSettingsData(KEY_DARK_MODE_ALL_DAY_ENABLE, isEnabled ? ENABLED : DISABLED);
  }

  public static async enableDarkMode(): Promise<boolean> {
    return await DisplayUtils.changeColorMode(true);
  }

  public static async disableDarkMode(): Promise<boolean> {
    return await DisplayUtils.changeColorMode(false);
  }

  public static async changeColorMode(isModeDark: boolean): Promise<boolean> {
    let config = isModeDark ? uiAppearance.DarkMode.ALWAYS_DARK : uiAppearance.DarkMode.ALWAYS_LIGHT;
    let uiNightMode = isModeDark ? '2' : '1';
    LogUtil.info(`${TAG} updateConfiguration start`);
    try {
      await uiAppearance.setDarkMode(config);
      SettingsDataUtils.setSecureValue('ui_night_mode', uiNightMode);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} updateConfiguration fail: ${err?.code}`);
    }
    return true;
  }

  /**
   * 根据字体大小缩放系数返回缩放档位
   *
   * @return 缩放档位
   */
  public static getDefaultFontSizeStep(fontSizeScale: number): number {
    LogUtil.info(`${TAG} fontSizeScale is ${fontSizeScale}`);
    switch (fontSizeScale) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL:
        return DisplayConstant.TEXT_FONT_SIZE_SMALL_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL:
        return DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE:
        return DisplayConstant.TEXT_FONT_SIZE_LARGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE:
        return DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE2_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE3_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE4_STEP;
      default:
        return DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE;
    }
  }

  public static getColorMode(): string {
    return SettingsDataUtils.getSettingsDataDomain('settings.color_mode', ColorPattern.STANDARD,
      Settings.domainName.USER_PROPERTY);
  }

  public static getColorModeTitle(): string {
    const colorMode: string = SettingsDataUtils.getSettingsDataDomain('settings.color_mode', ColorPattern.STANDARD,
      Settings.domainName.USER_PROPERTY);
    return ResourceUtil.getStringByName(ColorPatternTitle[colorMode]);
  }

  public static setColorMode(value: string): void {
    emitter.emit({
      eventId: EVENT_ID_COLOR_MODE
    });
    switch (value) {
      case ColorPattern.STANDARD:
        LogUtil.info(`${TAG} settings.color_mode--standard`);
        SettingsDataUtils.setSettingsDataDomain('settings.color_mode', ColorPattern.STANDARD,
          Settings.domainName.USER_PROPERTY);
        break;
      case ColorPattern.VIVID:
        LogUtil.info(`${TAG} settings.color_mode--bright`);
        SettingsDataUtils.setSettingsDataDomain('settings.color_mode', ColorPattern.VIVID,
          Settings.domainName.USER_PROPERTY);
        break;
      default:
        LogUtil.info(`${TAG} invalid color_mode`);
        break;
    }
  }

  public static getColorTemperature(): string {
    return SettingsDataUtils.getSettingsDataDomain('settings.color_temperature',
      ColorTemperaturePattern.DEFAULT, Settings.domainName.USER_PROPERTY);
  }

  public static getColorTemperatureTitle(): string {
    const colorMode: string = SettingsDataUtils.getSettingsDataDomain('settings.color_temperature',
      ColorTemperaturePattern.DEFAULT, Settings.domainName.USER_PROPERTY);
    return ResourceUtil.getStringByName(ColorTemperaturePatternTitle[colorMode]);
  }

  public static setColorTemperature(value: string): void {
    switch (value) {
      case ColorTemperaturePattern.DEFAULT:
        LogUtil.info(`${TAG} set settings.color_temperature default`);
        SettingsDataUtils.setSettingsDataDomain('settings.color_temperature', ColorTemperaturePattern.DEFAULT,
          Settings.domainName.USER_PROPERTY);
        break;
      case ColorTemperaturePattern.WARM:
        LogUtil.info(`${TAG} settings.color_temperature--warm`);
        SettingsDataUtils.setSettingsDataDomain('settings.color_temperature', ColorTemperaturePattern.WARM,
          Settings.domainName.USER_PROPERTY);
        break;
      case ColorTemperaturePattern.COOL:
        LogUtil.info(`${TAG} settings.color_temperature--cool`);
        SettingsDataUtils.setSettingsDataDomain('settings.color_temperature', ColorTemperaturePattern.COOL,
          Settings.domainName.USER_PROPERTY);
        break;
      case ColorTemperaturePattern.NATURE:
        LogUtil.info(`${TAG} settings.color_temperature--nature`);
        SettingsDataUtils.setSettingsDataDomain('settings.color_temperature', ColorTemperaturePattern.NATURE,
          Settings.domainName.USER_PROPERTY);
        break;
      default:
        LogUtil.info(`${TAG} invalid color_temperature`);
        break;
    }
  }

  /**
   * 是否支持”注视屏幕不熄屏“功能
   *
   * @return true支持，false不支持
   */
  public static isGazeModelSupport(): boolean {
    return SystemParamUtils.getSystemParam(GAZE_NO_TURNING_OFF, DISABLED) === ENABLED;
  }

  /**
   * 获取当前显示器设备模式
   * @returns
   */
  public static async getDisplayMode(): Promise<string> {
    try {
      let screens = (await screen.getAllScreens())
        .filter((screen) => screen.id > IS_PROVED_ID_MIN && screen.id < IS_PROVED_ID_MAX);
      // 外接屏rsId不为0
      let currentScreen = screens.find((screen) => screen.rsId !== 0);
      switch (currentScreen?.sourceMode as number) {
        case DeviceUserType.MAIN_SCREEN:
          if (screens.length > 1) {
            return 'MainDisplay';
          } else {
            return 'OnlyScreen';
          }
        case DeviceUserType.EXTENDED:
          return 'ExtendDisplay';
        case DeviceUserType.MIRROR:
          return 'Mirror';
        default :
          return '';
      }
    } catch (err) {
      LogUtil.error(`${TAG} get display mode error: ${err?.code} `);
      return '';
    }
  }

  /**
   * 获取当前显示器设备模式标题
   */
  public static async getDisplayModeTitle(): Promise<string> {
    try {
      let screens = (await screen.getAllScreens())
        .filter((screen) => screen.id > IS_PROVED_ID_MIN && screen.id < IS_PROVED_ID_MAX);
      // 外接屏rsId不为0
      let currentScreen = screens.find((screen) => screen.rsId !== 0);
      switch (currentScreen?.sourceMode as number) {
        case DeviceUserType.MAIN_SCREEN:
          if (screens.length > 1) {
            return ResourceUtil.getStringByName('main_display');
          } else {
            let currentDisplay = display.getDisplayByIdSync(currentScreen?.id);
            LogUtil.info(`${TAG} getDisplayModeTitle get name: ${currentDisplay.name}`);
            return ResourceUtil.getFormatStringByNameSync('only_on_screen', currentDisplay.name);
          }
        case DeviceUserType.EXTENDED:
          return ResourceUtil.getStringByName('extended_display');
        case DeviceUserType.MIRROR:
          let name = ResourceUtil.getStringSync(currentScreen?.rsId as number !== 0 ?
          $r('app.string.display_machine') : $r('app.string.display_extended'));
          LogUtil.info(`${TAG} getDisplayModeTitle get name: ${name}`);
          return ResourceUtil.getFormatStringByNameSync('screen_settings_mirror_mode', name);
        default :
          return '';
      }
    } catch (err) {
      LogUtil.error(`${TAG} get display mode title error: ${err?.code} `);
      return '';
    }
  }

  /**
   * 意图接入设备模式切换
   * @param optionValue 传入意图切换模式
   */
  public static async setDisplayMode(optionValue: string): Promise<boolean> {
    let setMode: DeviceUserType = DisplayMode[optionValue];
    if (setMode === undefined || setMode === null) {
      return false;
    }
    try {
      let devicesDataList: string[] = JSON.parse(
        SettingsDataUtils.getSettingsDataDomain(DEVICE_EDID, JSON.stringify([]), DOMAIN_NAME)
      );
      let allScreens = (await screen.getAllScreens());
      let currentConnectDevice = allScreens.filter((screen) => {
        // 判断id是否合规
        return (screen.rsId > IS_PROVED_ID_MIN && screen.rsId < IS_PROVED_ID_MAX)
      });
      return DisplayUtils.setMultiMode(currentConnectDevice, setMode);
    } catch (err) {
      LogUtil.error(`${TAG} set display mode error: ${err?.code}`);
      return false;
    }
  }

  /**
   * 检查屏幕设置是否可用
   */
  public static async checkDeviceSettingsItem(): Promise<boolean> {
    if (!DeviceUtil.isDevicePc() && !DeviceUtil.isPcMode()) {
      LogUtil.error(`${TAG} is not PC`);
      return false;
    }
    // 直接获取屏幕信息
    let screens = (await screen.getAllScreens()).filter(
      (data) => data.id > IS_PROVED_ID_MIN && data.id < IS_PROVED_ID_MAX
    );
    // 仅第二屏模式无法获取内置屏信息
    if (screens.length === 1 && screens[0].id !== 0) {
      return true;
    }
    return screens.length > 1;
  }

  /**
   * 设置当前显示器模式
   *
   * @param devices 已连接设备
   * @param setMode 设置模式
   * @returns  意图返回信息
   */
  private static async setMultiMode(devices: screen.Screen[], setMode: DeviceUserType) {
    let currentDevice = devices.find((d) => d.rsId !== 0);
    if (!currentDevice) {
      LogUtil.error(`${TAG} not connect extend device`);
      return false;
    }
    let currentDeviceId = currentDevice?.rsId;
    LogUtil.info(`${TAG} setDisplayMode current device: ${currentDevice} | setMode : ${setMode}`);
    // 当前设备模式 与 目标设备模式相同，直接返回
    if (Number(currentDevice?.sourceMode) === setMode) {
      LogUtil.info(`${TAG} setDisplayMode current device mode is option value`);
      return true;
    }
    let mainId = Number(currentDeviceId);
    let secondId = Number(currentDeviceId);
    if (setMode === DeviceUserType.ONLY_SCREEN) {
      mainId = 0;
      secondId = 0;
      setMode = DeviceUserType.EXTENDED;
    } else {
      if (setMode === DeviceUserType.MAIN_SCREEN) { // 选择当前设备为主屏，其他设备模式 切换为 该设备模式
        let otherDevice = devices.find((d) => Number(d.sourceMode) === DeviceUserType.MAIN_SCREEN);
        if (otherDevice) {
          secondId = Number(otherDevice.rsId);
          setMode = Number(currentDevice?.sourceMode);
        }
        // 仅第二屏场景下切换主显示器，内置屏必定为扩展屏
        if (setMode === DeviceUserType.MAIN_SCREEN) {
          secondId = 0;
          setMode = DeviceUserType.EXTENDED;
        }
      } else if (Number(currentDevice?.sourceMode) === DeviceUserType.MAIN_SCREEN) { // 当前设备为主屏，切换为其他模式，选择其他设备为主屏，模式为该设备模式
        let otherDevice = devices.find((d) => Number(d.sourceMode) !== DeviceUserType.MAIN_SCREEN);
        if (otherDevice) {
          mainId = Number(otherDevice.rsId);
        } else {
          mainId = 0;
        }
      } else { // 当前设备切换 镜像/扩展模式，找出主屏设备，其他设备切换模式
        let mainDevice = devices.find((d) => Number(d.sourceMode) === DeviceUserType.MAIN_SCREEN);
        if (mainDevice) {
          mainId = Number(mainDevice.rsId);
        } else {
          mainId = 0;
        }
      }
      if (secondId === mainId) {
        LogUtil.error(`${TAG} setDisplayMode get display id error`);
        return false;
      }
    }
    DisplayUtils.setDevicesData(devices, setMode, mainId, secondId);
    // 下发参数
    try {
      let currentScreenMode: screen.MultiScreenMode =
        setMode === DeviceUserType.MIRROR ? screen.MultiScreenMode.SCREEN_MIRROR : screen.MultiScreenMode.SCREEN_EXTEND;
      screen.setMultiScreenMode(mainId as number, secondId as number, currentScreenMode);
      // 方位初始化
      if (currentScreenMode === screen.MultiScreenMode.SCREEN_EXTEND && mainId !== secondId) {
        LogUtil.info(`${TAG} setDisplayMode positions init`);
        DisplayUtils.setPositions(mainId, secondId);
      }
      EventBus.getInstance().emit('display_mode_change', setMode);
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} set multi screen mode error: ${err?.code}`);
      return false;
    }
  }

  /**
   * 下发方位信息，并发布方位初始化事件
   *
   * @param mainId 主屏ID
   * @param secondId 副屏ID
   */
  private static async setPositions(mainId: number, secondId: number) {
    try {
      let devicesDataList: string[] = JSON.parse(
        SettingsDataUtils.getSettingsDataDomain(DEVICE_EDID, JSON.stringify([]), DOMAIN_NAME)
      );
      let screens = (await screen.getAllScreens()).filter((screen) => {
        return screen.rsId > IS_PROVED_ID_MIN && screen.rsId < IS_PROVED_ID_MAX;
      });
      let currentDevice = screens.find((s) => s.rsId !== 0);
      let currentDeviceDataIndex = devicesDataList.findIndex((data) => {
        return data.split(';')[0] === currentDevice?.serialNumber;
      });
      if (currentDeviceDataIndex === -1) {
        return;
      }
      let mainScreen: screen.MultiScreenPositionOptions | null = null;
      let secondScreen: screen.MultiScreenPositionOptions | null = null;
      // 获取合规的display信息
      let displays = (await display.getAllDisplays()).filter((display) =>
        display.id > IS_PROVED_ID_MIN && display.id < IS_PROVED_ID_MAX
      );
      let data = devicesDataList[currentDeviceDataIndex].split(';');
      displays.forEach((d, index) => {
        let screenInfo: screen.MultiScreenPositionOptions | null = null;
        if (data.length <= 2) {
          // 默认左右布局
          if (index === 0) {
            screenInfo = {id: d.id, startX: 0, startY: 0};
          } else {
            screenInfo = {id: d.id, startX: displays[index - 1].width, startY: 0};
          }
          data.push(`${d.id} ${screenInfo.startX} ${screenInfo.startY}`);
        } else {
          if (d.id === Number(data[2].split(' ')[0])) {
            screenInfo = {id: d.id, startX: Number(data[2].split(' ')[1]), startY: Number(data[2].split(' ')[2])};
          } else {
            screenInfo = {id: d.id, startX: Number(data[3].split(' ')[1]), startY: Number(data[3].split(' ')[2])};
          }
        }
        if (screenInfo.id === mainId) {
          mainScreen = screenInfo;
        } else {
          secondScreen = screenInfo;
        }
      })
      if (mainScreen && secondScreen) {
        screen.setMultiScreenRelativePosition(mainScreen, secondScreen);
        EventBus.getInstance().emit('positions_init');
      } else {
        LogUtil.error(`${TAG} screen info is null`);
      }
    } catch (err) {
      LogUtil.error(`${TAG} set muti positions error: ${err?.code}`);
      return;
    }
  }

  private static setDevicesData(devices: screen.Screen[], setMode: DeviceUserType, mainId: number, secondId: number) {
    try {
      // 用户设置模式持久化处理
      let devicesDataList: string[] = JSON.parse(SettingsDataUtils.getSettingsDataDomain(DEVICE_EDID, '[]', DOMAIN_NAME));
      let currentScreen = devices.find((d) => d.rsId !== 0);
      if (!currentScreen) {
        return;
      }
      let currentDataIndex = devicesDataList.findIndex((data) => data.split(';')[0] === currentScreen?.serialNumber);
      let mode = `0 ${setMode}`;
      if (mainId !== 0) {
        mode = `${setMode} 0`;
      } else if (mainId === secondId) {
        mode = '0 0';
      }
      if (currentDataIndex !== -1) {
        let currentData = devicesDataList[currentDataIndex].split(';');
        currentData[1] = mode;
        devicesDataList[currentDataIndex] = currentData.join(';');
      } else {
        // 不存在当前显示器EDID字段
        let data: string[] = [];
        data.push(currentScreen.serialNumber!);
        data.push(mode);
        devicesDataList.push(data.join(';'));
      }
      LogUtil.info(`${TAG} setDisplayMode deviceDataList: ${devicesDataList}`);
      SettingsDataUtils.setSettingsDataDomain(DEVICE_EDID, JSON.stringify(devicesDataList), DOMAIN_NAME);
    } catch (err) {
      LogUtil.error(`${TAG} get/set settings data ${DEVICE_EDID} error: ${err?.code}`);
      return;
    }

  }

  /**
   * 获取当前选中设备ID
   */
  private static async getCurrentDeviceId(): Promise<string> {
    try {
      let currentDeviceId = SettingsDataUtils.getSettingsDataDomain(DISPLAY_CURRENT_DEVICE_ID, '0', DOMAIN_NAME);
      let allScreens = await screen.getAllScreens();
      if (allScreens.find((screen) => screen.rsId === Number(currentDeviceId))) {
        return currentDeviceId;
      } else {
        return '0';
      }
    } catch (err) {
      // 异常情况下默认本机为当前显示器
      LogUtil.error(`${TAG} get current device error: ${err?.code}`);
      return '0';
    }
  }

  /**
   * 获取视频HDR增强开关的默认状态，如果没有获取到默认打开。
   */
  public static getDefaultHDRVideoEnableState(): boolean {
    try {
      let isSupport: string = systemParameterEnhance.getSync(AIHDR_VIDEO_DEFAULT_ENABLE, 'true');
      return isSupport === 'true';
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportAiHDRVideo fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return true;
    }
  }
}
