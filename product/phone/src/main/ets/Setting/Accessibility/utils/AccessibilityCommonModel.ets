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
import {
  ACCESSIBILITY_FLASH_REMINDER_SWITCH,
  ACCESSIBILITY_REMINDER_FUNCTION_ENABLED,
  ACCESSIBILITY_SOUND_RECOGNITION_ENABLED,
  ACCESSIBILITY_SOUND_RECOGNITION_SWITCH,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  FunctionSelectOriginNameValue,
  ReminderFunctionModeValue,
  VoiceRecognitionModeValue
} from '../constant/Constants';

const TAG: string = 'AccessibilityCommonModel: ';

export const DIALOG_CLICK_BUTTON: string = 'privacy_dialog_button';

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
    await AccessibilityReportUtil.reportSoundRecogStatisticEvent();
    await AccessibilityReportUtil.reportFlashRemindStatisticEvent();
    await AccessibilityReportUtil.reportHearingAidStaticEvent();
  }

  public static async reportHearingAidStaticEvent(): Promise<void> {
    let params: Record<string, Object> = {}
    let leftState = SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SWITCH_KEY, '0');
    if (leftState === '0') {
      params.LEFT_EAR_SWITCH_STATUS = 'off';
    } else if (leftState === '1') {
      params.LEFT_EAR_SWITCH_STATUS = 'on';
    }
    let rightState = SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SWITCH_KEY, '0');
    if (rightState === '0') {
      params.RIGHT_EAR_SWITCH_STATUS = 'off';
    } else if (rightState === '1') {
      params.RIGHT_EAR_SWITCH_STATUS = 'on';
    }
    let state = SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.UNILATERAL_ADJUST_SWITCH_KEY, '0');
    if (state === '0') {
      params.UNILATERAL_ADJUSTMENT_STATUS = 'off';
    } else if (state === '1') {
      params.UNILATERAL_ADJUSTMENT_STATUS = 'on';
    }
    params.LEFT_SLIDER_STATUS =
      parseInt(SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SLIDER_VALUE, '0'));
    params.RIGHT_SLIDER_STATUS =
      parseInt(SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SLIDER_VALUE, '0'));
    params.BINAURAL_SLIDER_STATUS =
      parseInt(SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.BINAURAL_SLIDER_VALUE, '0'));
    HiSysEventUtil.reportStatisticEventByUE(HiSysAccessibilityStaticEventGroup.HEARING_AID_STATUS, params);
  }

  public static async reportSoundRecogStatisticEvent(): Promise<void> {
    let soundEnabled: string = SettingsDataUtils.getSecureValue(ACCESSIBILITY_SOUND_RECOGNITION_ENABLED, '');
    let params: Record<string, Object> = {};
    Object.values(VoiceRecognitionModeValue).forEach(key => {
      switch (key) {
        case VoiceRecognitionModeValue.ENV_BABYCRY:
          params.ENV_BABYCRY = soundEnabled.includes(key) ? 'on' : 'off';
          break;
        case VoiceRecognitionModeValue.ENV_MEOW:
          params.ENV_MEOW = soundEnabled.includes(key) ? 'on' : 'off';
          break;
        case VoiceRecognitionModeValue.ENV_BARK:
          params.ENV_BARK = soundEnabled.includes(key) ? 'on' : 'off';
          break;
        case VoiceRecognitionModeValue.ENV_DOORBELL:
          params.ENV_DOORBELL = soundEnabled.includes(key) ? 'on' : 'off';
          break;
        case VoiceRecognitionModeValue.ENV_KNOCK:
          params.ENV_KNOCK = soundEnabled.includes(key) ? 'on' : 'off';
          break;
        case VoiceRecognitionModeValue.ENV_ALARM:
          params.ENV_ALARM = soundEnabled.includes(key) ? 'on' : 'off';
          break;
        case VoiceRecognitionModeValue.DEFAULT:
          break;
        default:
          LogUtil.error(`${TAG} reportSoundRecogStatisticEvent unMatch key: ${key}`);
          break;
      }
    });
    HiSysEventUtil.reportStatisticEventByUE(HiSysAccessibilityStaticEventGroup.SOUND_RECOG_ENABLED_STATUS, params);
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
        case ReminderFunctionModeValue.INCOMING_CALL:
          params.INCOMING_CALL = flashEnabled.includes(key) ? 'on' : 'off';
          break;
        case ReminderFunctionModeValue.NOTIFY:
          params.NOTIFY = flashEnabled.includes(key) ? 'on' : 'off';
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
 * 辅助功能助听设备数据类
 *
 * @since 2025-07-12
 */
export class AccessibilityHearingAidModel {
  public static deviceMacId: string[] = [];
  // public static hearingAidProfile: hearingAid.HearingAidSourceProfile | null = null;
  public static leftSwitchState: boolean = true;
  public static rightSwitchState: boolean = true;
  public static unilateralAdjustSwitchState: boolean = true;
  public static leftMacId: string;
  public static rightMacId: string;
  public static LEFT_EAR_SLIDER_VALUE: string = 'left_ear_slider_value';
  public static RIGHT_EAR_SLIDER_VALUE: string = 'right_ear_slider_value';
  public static BINAURAL_SLIDER_VALUE: string = 'binaural_slider_value';
  public static LEFT_EAR_SWITCH_KEY: string = 'left_ear_switch_key';
  public static RIGHT_EAR_SWITCH_KEY: string = 'right_ear_switch_key';
  public static UNILATERAL_ADJUST_SWITCH_KEY: string = 'unilateral_adjust_switch_key';

  /**
   * 获取助听器Side
   * @param deviceId 助听设备mac地址
   * @returns device side
   */
  static getHearingAidSide(deviceId?: string): number {
    // if (!AccessibilityHearingAidModel.hearingAidProfile) {
    //   LogUtil.error(`${TAG} hearingAidProfile is null`);
    //   return -1;
    // }
    let deviceSide: number = 0;
    try {
      // deviceSide = AccessibilityHearingAidModel.hearingAidProfile.getHearingAidDeviceInfo(deviceId).deviceSide
    } catch (err) {
      LogUtil.error(`${TAG} err is code: ${err?.code} message: ${err?.message}`);
    }
    return deviceSide;
  }

  /**
   * 设置助听器音量
   * @param deviceId: 助听设备mac地址；volume：音量值
   * @returns
   */
  static setVolume(deviceId: string, volume: number): void {
    // if (!AccessibilityHearingAidModel.hearingAidProfile) {
    //   LogUtil.error(`${TAG} hearingAidProfile is null`);
    //   return;
    // }
    // if (deviceId != undefined) {
    //   AccessibilityHearingAidModel.hearingAidProfile.setVolume(deviceId, volume);
    // }
  }
}
