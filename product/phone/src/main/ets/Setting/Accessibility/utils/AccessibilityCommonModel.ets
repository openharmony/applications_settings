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

/* instrument ignore file */
import bluetooth from '@ohos.bluetooth';
// import hearingAid from '@hms.bluetooth.hearingAid';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import config from '@ohos.accessibility.config';
import accessibility from '@ohos.accessibility';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@ohos.base';
import resmgr from '@ohos.resourceManager';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HiSysAccessibilityException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import {
  ExtensionServiceInstallModel
} from '@ohos/settings.accessibility/src/main/ets/model/ExtensionServiceInstallModel';
import bundle from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityStaticEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/StaticEventConsts';
import { CommonFailedEventUtils } from '@ohos/settings.common/src/main/ets/utils/CommonFailedEventUtils';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import {
  ACCESSIBILITY_FLASH_REMINDER_SWITCH,
  ACCESSIBILITY_REMINDER_FUNCTION_ENABLED,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  FunctionSelectOriginNameValue,
  ReminderFunctionModeValue,
  ANIMATION_OFF_KEY
} from '../constant/Constants';

const TAG: string = 'AccessibilityCommonModel: ';

export const DIALOG_CLICK_BUTTON: string = 'privacy_dialog_button';

/**
 * 资源调用
 *
 * @since 2024-10-17
 */
export class AccessibilityCommonModel {
  static async getSelectAbilityName(context: Context, targetKey: string): Promise<string> {
    let selectName: string = '';
    let extensionServiceList: accessibility.AccessibilityAbilityInfo[] =
      await accessibility.getAccessibilityExtensionList('all', 'install');
    switch (targetKey) {
      case FunctionSelectOriginNameValue.HIGH_CONTRAST_TEXT:
        selectName = await ResourceUtil.getString($r('app.string.highContrast_text'));
        break;
      case FunctionSelectOriginNameValue.SINGLE_AUDIO:
        selectName = await ResourceUtil.getString($r('app.string.single_audio'));
        break;
      case FunctionSelectOriginNameValue.INVERT_COLOR:
        selectName = await ResourceUtil.getString($r('app.string.invert_color'));
        break;
      default:
        if (selectName) {
          LogUtil.info(`${TAG} getSelectAbilityName  ${selectName}`);
        } else {
          selectName = await ResourceUtil.getString($r('app.string.shortkey_close'));
          LogUtil.error(`${TAG} failed to find ability name`);
        }
        break;
    }
    return selectName;
  }

  static async getSelectAbilityResourceName(context: Context, targetKey: string): Promise<ResourceStr> {
    let selectName: ResourceStr = '';
    let extensionServiceList: accessibility.AccessibilityAbilityInfo[] =
      await accessibility.getAccessibilityExtensionList('all', 'install');
    switch (targetKey) {
      case FunctionSelectOriginNameValue.HIGH_CONTRAST_TEXT:
        selectName = $r('app.string.highContrast_text');
        break;
      case FunctionSelectOriginNameValue.SINGLE_AUDIO:
        selectName = $r('app.string.single_audio');
        break;
      case FunctionSelectOriginNameValue.INVERT_COLOR:
        selectName = $r('app.string.invert_color');
        break;
      default:
        if (selectName) {
          LogUtil.info(`${TAG} getSelectAbilityName  ${selectName}`);
        } else {
          selectName = $r('app.string.shortkey_close');
          LogUtil.error(`${TAG} failed to find ability name`);
        }
        break;
    }
    return selectName;
  }

  static async getBundleResourceLabelInfo(context: Context, bundleName: string, labelId: number): Promise<string> {
    let bundleContext: Context = context.createBundleContext(bundleName);
    if (!bundleContext) {
      LogUtil.info(`${TAG} bundleContext is null.`);
      return '';
    }
    let resourceManager: resmgr.ResourceManager = bundleContext.resourceManager;
    if (!resourceManager) {
      LogUtil.info(`${TAG} resourceManager is null.`);
      return '';
    }
    let label: string = await resourceManager.getString(labelId);
    if (!label) {
      LogUtil.info(`${TAG} get label failed.`);
      return '';
    }
    MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    return label;
  }

  static async getSelectColorFilterName(colorFilter: string): Promise<string> {
    let selectName: string = '';
    switch (colorFilter) {
      case 'Normal':
        selectName = await ResourceUtil.getString($r('app.string.color_filter_normal'));
        break;
      case 'Protanomaly':
        selectName = await ResourceUtil.getString($r('app.string.protanomaly_radio'));
        break;
      case 'Deuteranomaly':
        selectName = await ResourceUtil.getString($r('app.string.deuteranomaly_radio'));
        break;
      case 'Tritanomaly':
        selectName = await ResourceUtil.getString($r('app.string.tritanomaly_radio'));
        break;
      default:
        selectName = await ResourceUtil.getString($r('app.string.color_filter_normal'));
        LogUtil.error(`${TAG} failed to find color filter name`);
        break;
    }
    return selectName;
  }

  static getSelectTouchDurationName(clickTime: config.ClickResponseTime): ResourceStr {
    let selectName: ResourceStr = '';
    switch (clickTime) {
      case 'Short':
        selectName = $r('app.string.touchscreen_short');
        break;
      case 'Medium':
        selectName = $r('app.string.medium');
        break;
      case 'Long':
        selectName = $r('app.string.long');
        break;
      default:
        selectName = $r('app.string.touchscreen_short');
        LogUtil.error(`${TAG} failed to find click response time name`);
        break;
    }
    return selectName;
  }

  static getSelectIgnoreRepeatClickTimeName(repeatClickTime: config.RepeatClickInterval): string {
    let selectName: string = '';
    switch (repeatClickTime) {
      case 'Shortest':
        selectName = ResourceUtil.getStringSync($r('app.string.shortest'));
        break;
      case 'Short':
        selectName = ResourceUtil.getStringSync($r('app.string.short'));
        break;
      case 'Medium':
        selectName = ResourceUtil.getStringSync($r('app.string.medium'));
        break;
      case 'Long':
        selectName = ResourceUtil.getStringSync($r('app.string.long'));
        break;
      case 'Longest':
        selectName = ResourceUtil.getStringSync($r('app.string.longest'));
        break;
      default:
        selectName = ResourceUtil.getStringSync($r('app.string.shortest'));
        LogUtil.error(`${TAG} failed to find ignore repeat click time name`);
        break;
    }
    LogUtil.info(`${TAG} select title name ${selectName}`);
    return selectName;
  }

  /**
   * 通过CCM配置来判断是否支持环境音识别
   *
   * @returns true表示支持  false表示不支持
   */
  static isSupportSoundRecognitionSwitch(): boolean {
    try {
      let isSupport: boolean = systemParameterEnhance.getSync(
        'persist.accessibility.voiceRecognition', 'false') === 'true';
      LogUtil.info(`${TAG} isSupportSoundRecognitionSwitch isSupport: ${isSupport}`);
      return isSupport;
    } catch (err) {
      LogUtil.error(`${TAG} get isSupportSoundRecognitionSwitch fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    }
  }

  /**
   * 是否支持闪烁提醒
   *
   * @returns true表示支持  false表示不支持
   */
  static isSupportFlashReminderSwitch(): boolean {
    let isSupport: boolean = false;
    try {
      let cameraManager: camera.CameraManager | undefined = undefined;
      cameraManager = camera.getCameraManager(AbilityContextManager.getContext());
      if (DeviceUtil.isDevicePhone() && cameraManager.isTorchSupported()) {
        isSupport = true;
      }
    } catch (err) {
      CommonFailedEventUtils.reportFailureEvent(
        HiSysAccessibilityException.IS_SUPPORT_FLASH_FAILED,
        `isSupportFlash failed. message: ${err?.message}`);
      LogUtil.error(`${TAG} isSupportFlash failed, code: ${err?.code}, message: ${err?.message}`);
    }
    return isSupport;
  }

  /**
   * 通过Preferences来判断是否需要禁用过渡动画
   *
   * @returns true表示是  false表示不是
   */
  static isEnableRetail(): boolean {
    try {
      let isEnabled: boolean = PreferencesUtil.getSync('TransitionAnimations', false) as boolean;;
      LogUtil.info(`${TAG} isEnableRetail isEnabled: ${isEnabled}`);
      return isEnabled;
    } catch (err) {
      LogUtil.error(`${TAG} get isEnableRetail fail, errCode: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    }
  }
}

/**
 * 辅助功能快捷键弹框数据恢复类
 *
 * @since 2024-06-29
 */
export class AccessibilityFunctionSelectCacheModel {
  /**
   * 单例对象
   */
  private static instance: AccessibilityFunctionSelectCacheModel;
  public functionSelectScaleOpen: Boolean = false;
  public securityNotificationOpen: Boolean = false;
  public shortKeyTargetsIdListCache: string[] = [];

  /**
   * 单例方法
   *
   * @returns 单例对象
   */
  public static getInstance(): AccessibilityFunctionSelectCacheModel {
    if (!AccessibilityFunctionSelectCacheModel.instance) {
      AccessibilityFunctionSelectCacheModel.instance = new AccessibilityFunctionSelectCacheModel();
    }
    return AccessibilityFunctionSelectCacheModel.instance;
  }
}

export function getCurrentListPadding(): ResourceStr {
  let currentScaleSize: number = FontScaleUtils.getFontScaleSize();
  let currentPadding: ResourceStr = '';
  if (currentScaleSize === FontScaleUtils.EXTRA_LARGE_FONT_1) {
    currentPadding = $r('sys.float.padding_level8');
  } else if (currentScaleSize === FontScaleUtils.EXTRA_LARGE_FONT_2) {
    currentPadding = $r('app.float.padding_20');
  } else if (currentScaleSize === FontScaleUtils.EXTRA_LARGE_FONT_2_25 ||
    currentScaleSize === FontScaleUtils.EXTRA_LARGE_FONT_3) {
    currentPadding = $r('sys.float.padding_level12');
  } else {
    currentPadding = $r('sys.float.padding_level4');
  }
  return currentPadding;
}

/**
 * 辅助功能打点工具类
 *
 * @since 2024-11-18
 */
export class AccessibilityReportUtil {
  public static promiseStatusMap = new Map<string, () => Promise<string>>([
    [HiSysAccessibilityStaticEventGroup.ACCESSIBILITY_SHORTCUT_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getShortKeyStatusForReport() ? 'on' : 'off';
    }],
    [HiSysAccessibilityStaticEventGroup.DALTONIZATION_SWITCH_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getDaltonizationStateForReport();
    }],
    [HiSysAccessibilityStaticEventGroup.INVERT_COLOR_SWITCH_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getInvertColorStateForReport() ? 'on' : 'off';
    }],
    [HiSysAccessibilityStaticEventGroup.HIGH_CONTRAST_TEXT_SWITCH_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getHighContrastTextStateForReport() ? 'on' : 'off';
    }],
    [HiSysAccessibilityStaticEventGroup.AUDIO_MONO_SWITCH_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getSingleAudioStateForReport() ? 'on' : 'off';
    }],
    [HiSysAccessibilityStaticEventGroup.AUDIO_BALANCE_CHANGE_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getAudioBalanceForReport();
    }],
    [HiSysAccessibilityStaticEventGroup.TOUCHE_DURATION_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getTouchDurationStateForReport();
    }],
    [HiSysAccessibilityStaticEventGroup.TIME_INTERVAL_STATUS, async (): Promise<string> => {
      return await AccessibilityReportUtil.getTimeIntervalStateForReport();
    }]
  ]);

  public static async reportStatisticEvent(): Promise<void> {
    LogUtil.info(`${TAG} reportStatisticEvent begin`);
    for (let eventName of AccessibilityReportUtil.promiseStatusMap.keys()) {
      let value: string = '';
      let valueFunc = AccessibilityReportUtil.promiseStatusMap.get(eventName);
      if (valueFunc) {
        try {
          value = await valueFunc();
          HiSysEventUtil.reportStatusStatisticEvent(eventName, value);
        } catch (e) {
          LogUtil.error(`${TAG} try to report status fail. eventName: ${eventName}, error: ${e}, value: ${value}`);
        }
      }
    }
    await AccessibilityReportUtil.reportFlashRemindStatisticEvent();
    await AccessibilityReportUtil.reportTransitionAnimationsStatus();
  }

  public static async reportTransitionAnimationsStatus(): Promise<void> {
    let params: Record<string, Object> = {
      'PNAMEID': HiSysEventUtil.getPkgName(),
      'PVERSIONID': HiSysEventUtil.getProcessName()
    };
    let switchStatus = SettingsDataUtils.getSecureValue(ANIMATION_OFF_KEY, CLICK_SWITCH_OFF);
    params.SWITCH_STATUS = switchStatus == 'CLICK_SWITCH_OFF' ? 'off' : 'on'
    HiSysEventUtil.reportStatisticEventByUE(HiSysAccessibilityStaticEventGroup.TRANSITION_ANIMATIONS_STATUS, params);
  }

  public static async reportFlashRemindStatisticEvent(): Promise<void> {
    let flashEnabled: string = SettingsDataUtils.getSecureValue(ACCESSIBILITY_REMINDER_FUNCTION_ENABLED, '');
    let params: Record<string, Object> = {};
    Object.keys(ReminderFunctionModeValue).forEach(key => {
      LogUtil.info(`${TAG} reportFlashRemindStatisticEvent key: ${key}`);
      switch (key) {
        case ReminderFunctionModeValue.ALARM_CLOCK:
          params.ALARM_CLOCK = flashEnabled.includes(key) ? 'on' : 'off';
          break;
        case ReminderFunctionModeValue.DEFAULT:
          break;
        default:
          LogUtil.error(`${TAG} reportFlashRemindStatisticEvent unMatch key: ${key}`);
          break;
      }
    });
    HiSysEventUtil.reportStatisticEventByUE(HiSysAccessibilityStaticEventGroup.FLASH_REMIND_ENABLED_STATUS, params);
  }

  public static async getShortKeyStatusForReport(): Promise<boolean> {
    let currentShortkey: boolean = false;
    await config.shortkey.get().then((data) => {
      currentShortkey = data;
    })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getShortKeyStatusForReport is invalid: ${err?.message}`);
      });
    return currentShortkey;
  }

  public static async getSingleAudioStateForReport(): Promise<boolean> {
    let currentSingleAudioState: boolean = false;
    await config.audioMono.get().then((data) => {
      currentSingleAudioState = data;
    })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getSingleAudioStateForReport is invalid: ${err?.message}`);
      });
    return currentSingleAudioState;
  }

  public static async getAudioBalanceForReport(): Promise<string> {
    let currentAudioBalance: string = '';
    await config.audioBalance.get().then((data) => {
      currentAudioBalance = data.toString();
    })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getSingleAudioStateForReport is invalid: ${err?.message}`);
      });
    return currentAudioBalance;
  }

  public static async getInvertColorStateForReport(): Promise<boolean> {
    let currentInvertColorState: boolean = false;
    await config.invertColor.get().then((data) => {
      currentInvertColorState = data;
    })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getInvertColorStateForReport is invalid: ${err?.message}`);
      });
    return currentInvertColorState;
  }

  public static async getHighContrastTextStateForReport(): Promise<boolean> {
    let currentHighContrastTextState: boolean = false;
    await config.highContrastText.get().then((data) => {
      currentHighContrastTextState = data;
    })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getHighContrastTextStateForReport is invalid: ${err?.message}`);
      });
    return currentHighContrastTextState;
  }

  public static async getDaltonizationStateForReport(): Promise<string> {
    let currentDaltonizationState: string = '';
    let currentDaltonizationType: string = '';
    await config.daltonizationState.get().then((data) => {
      currentDaltonizationState = data ? 'on' : 'off';
    })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getDaltonizationStateForReport daltonizationState is invalid: ${err?.message}`);
      });
    await config.daltonizationColorFilter.get().then((data: config.DaltonizationColorFilter) => {
      currentDaltonizationType = data.toString();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getDaltonizationStateForReport daltonizationColorFilter is invalid：${err?.message}`);
    });

    return `${currentDaltonizationState}-${currentDaltonizationType}`;
  }

  public static async getTouchDurationStateForReport(): Promise<string> {
    let currentTouchDurationState: string = '';
    await config.clickResponseTime.get().then((data: config.ClickResponseTime) => {
      currentTouchDurationState = data.toString();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getTouchDurationStateForReport clickResponseTime is invalid：${err?.message}`);
    });
    return currentTouchDurationState;
  }

  public static async getTimeIntervalStateForReport(): Promise<string> {
    let currentTimeIntervalState: string = '';
    await config.repeatClickInterval.get().then((data: config.RepeatClickInterval) => {
      currentTimeIntervalState = data.toString();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getTimeIntervalStateForReport clickResponseTime is invalid：${err?.message}`);
    });
    return currentTimeIntervalState;
  }
}

/**
 * 辅助功能闪烁提醒数据类
 *
 * @since 2025-05-22
 */
export class AccessibilityFlashReminderModel {
  /**
   * 单例对象
   */
  private static instance: AccessibilityFlashReminderModel;
  public flashReminderSwitch: boolean | undefined = undefined;
  public flashReminderEnabled: string | undefined = undefined;
  public flashReminderEnabledSet: Set<string> = new Set();

  /**
   * 单例方法
   *
   * @returns 单例对象
   */
  public static getInstance(): AccessibilityFlashReminderModel {
    if (!AccessibilityFlashReminderModel.instance) {
      AccessibilityFlashReminderModel.instance = new AccessibilityFlashReminderModel();
    }
    return AccessibilityFlashReminderModel.instance;
  }

  /**
   * 开关是否开启
   */
  public isSwitchOpen(): boolean {
    try {
      let switchOpen: boolean = SettingsDataUtils.getSecureValue(ACCESSIBILITY_FLASH_REMINDER_SWITCH,
        CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
      if (this.flashReminderSwitch !== switchOpen) {
        this.flashReminderSwitch = switchOpen;
      }
      LogUtil.info(`${TAG} check flash reminder switch active status is : ${switchOpen}`);
      return switchOpen;
    } catch (error) {
      LogUtil.error(`${TAG} failed to check whether flash reminder switch active, errCode:${(error as BusinessError)?.code},
        message:${(error as BusinessError)?.message}`);
      return false;
    }
  }

  /**
   * 获取闪烁提醒使能类型
   */
  public getFlashReminderEnabled(): Set<string> {
    let enabledStr: string = '';
    try {
      enabledStr = SettingsDataUtils.getSecureValue(ACCESSIBILITY_REMINDER_FUNCTION_ENABLED, '');
      if (enabledStr !== '') {
        this.flashReminderEnabled = enabledStr;
        this.flashReminderEnabledSet =
          new Set(enabledStr.includes(',') ? enabledStr.split(',') : [enabledStr]);
      } else {
        this.initEmptyReminderFunction();
      }
      LogUtil.info(`${TAG} check flash enabled mode is : ${enabledStr}`);
    } catch (error) {
      LogUtil.error(`${TAG} failed to get flash enabled mode, errCode:${(error as BusinessError)?.code},
        message:${(error as BusinessError)?.message}`);
    }
    return this.flashReminderEnabledSet;
  }

  /**
   * 初始化闪烁提醒settingsData值
   */
  public initEmptyReminderFunction(): void {
    this.flashReminderEnabled = 'DEFAULT';
    this.flashReminderEnabledSet = new Set(['DEFAULT']);
    SettingsDataUtils.setSecureValue(ACCESSIBILITY_REMINDER_FUNCTION_ENABLED, 'DEFAULT');
  }
}

/**
 * 助听器数据类
 *
 * @since 2025-04-28
 */
export class AccessibilityHearingAidModel {
  public static deviceMacId: string[] = [];
  public static leftSwitchState: boolean = true;
  public static rightSwitchState: boolean = true;
  public static unilateralAdjustSwitchState: boolean = true;
  public static leftMacId: string = '';
  public static rightMacId: string = '';
  public static LEFT_EAR_SLIDER_VALUE: string = 'left_ear_slider_value';
  public static RIGHT_EAR_SLIDER_VALUE: string = 'right_ear_slider_value';
  public static BINAURAL_SLIDER_VALUE: string = 'binaural_slider_value';
  public static LEFT_EAR_SWITCH_KEY: string = 'left_ear_switch_key';
  public static RIGHT_EAR_SWITCH_KEY: string = 'right_ear_switch_key';
  public static UNILATERAL_ADJUST_SWITCH_KEY: string = 'unilateral_adjust_switch_key';
  private static readonly MIN_VOLUME_DB: number = -128;
  private static readonly MAX_VOLUME_DB: number = 0;

  static getHearingAidSide(deviceId?: string): number {
    return -1;
  }

  static setVolume(deviceId: string, volume: number): void {
    LogUtil.info(`${TAG} setVolume deviceId: ${deviceId}, volume: ${volume}`);
  }

  static volumeToDb(value: number): number {
    return AccessibilityHearingAidModel.MIN_VOLUME_DB +
      (value / 100) * (AccessibilityHearingAidModel.MAX_VOLUME_DB - AccessibilityHearingAidModel.MIN_VOLUME_DB);
  }

  static unilateralAdjustmentDataManeger(value: number): void {
    SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SLIDER_VALUE, value.toString());
    SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SLIDER_VALUE, value.toString());
    SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.BINAURAL_SLIDER_VALUE, value.toString());
  }
}
