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
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import audio from '@ohos.multimedia.audio';
import common from '@ohos.app.ability.common';
import { vibrator } from '@kit.SensorServiceKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import {
  CALL_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM,
  CALL_SILENT_AND_NORMAL_CARD2_VIBRATE_PARAM,
  CALL_VIBRATE_CARD1_VIBRATE_PARAM,
  CALL_VIBRATE_CARD2_VIBRATE_PARAM,
  DEFAULT_CALL_VIBRATE_FILENAME,
  DEFAULT_MESSAGE_VIBRATE_FILENAME,
  DEFAULT_NOTIFICATION_VIBRATE_FILENAME,
  MESSAGE_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM,
  MESSAGE_SILENT_AND_NORMAL_CARD2_VIBRATE_PARAM,
  MESSAGE_VIBRATE_CARD1_VIBRATE_PARAM,
  MESSAGE_VIBRATE_CARD2_VIBRATE_PARAM,
  NOTIFICATION_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM,
  NOTIFICATION_VIBRATE_CARD1_VIBRATE_PARAM,
  RadioName,
} from '../constant/VibrateConstant';
import { ToneType } from '../model/RingtoneParam';
import { MyToneHapticsSettings, VibrateParam } from '../model/VibrateParam';
import { RINGTONE_TYPE_SYSTEM, SimRingtoneKey } from '../constant/VolumeConstant';

const TAG: string = 'VibrateUtil : ';

/**
 * 振动相关工具类
 */
export class VibrateUtil {
  static getToneHapticsType(toneType: ToneType, cardIndex: number | null): systemSoundManager.ToneHapticsType {
    let toneHapticsType: systemSoundManager.ToneHapticsType = systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0;
    if (toneType === ToneType.RINGTONE) {
      toneHapticsType = cardIndex !== 1 ?
        systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0 : systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1;
    } else if (toneType === ToneType.MESSAGE_TONE) {
      toneHapticsType = cardIndex !== 1 ? systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0 :
        systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1;
    } else {
      toneHapticsType = systemSoundManager.ToneHapticsType.NOTIFICATION;
    }
    return toneHapticsType;
  }

  /**
   * 获取来电、信息、通知铃声，卡1、卡2对应的内存的key的前缀
   *
   * @param toneHapticsType
   * @returns
   */
  static getRingtoneKeyPrefix(toneHapticsType: systemSoundManager.ToneHapticsType): string {
    switch (toneHapticsType) {
      case systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0:
        return SimRingtoneKey.CARD_0_RINGTONE_KEY;
      case systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1:
        return SimRingtoneKey.CARD_1_RINGTONE_KEY;
      case systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0:
        return SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY;
      case systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1:
        return SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY;
      case systemSoundManager.ToneHapticsType.NOTIFICATION:
        return SimRingtoneKey.NOTIFICATION_RINGTONE_KEY;
      default:
        LogUtil.showWarn(TAG, `getRingtoneKey invalid toneHapticsType: ${toneHapticsType}`);
        return '';
    }
  }

  /**
   * 从缓存中取振动参数(根据版本号是否改变toneHapticsType)
   *
   * @returns
   */
  static getVibrateParamInMemory(vibrateParamKey: string, vibrateParamTemp: VibrateParam): VibrateParam {
    let vibrateParam: VibrateParam = PreferencesUtil.getSync(vibrateParamKey, vibrateParamTemp) as VibrateParam;
    const versionNumber = PreferencesUtil.getSync(vibrateParamKey + '.version', 1) as number;
    if (versionNumber < 2) {
      PreferencesUtil.putSync(vibrateParamKey + '.version', 2);
      vibrateParam.toneHapticsType = VibrateUtil.changeToneHapticsType(vibrateParam.toneHapticsType);
      PreferencesUtil.putSync(vibrateParamKey, vibrateParam);
    }
    return vibrateParam;
  }

  /**
   * 转化toneHapticsType
   *
   * @returns
   */
  static changeToneHapticsType(toneHapticsType: number): systemSoundManager.ToneHapticsType {
    switch (toneHapticsType) {
      case 100:
        return systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0;
      case 101:
        return systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1;
      case 102:
        return systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0;
      case 103:
        return systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1;
      case 104:
        return systemSoundManager.ToneHapticsType.NOTIFICATION;
      case systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0:
        return systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0;
      case systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1:
        return systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1;
      case systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0:
        return systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0;
      case systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1:
        return systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1;
      case systemSoundManager.ToneHapticsType.NOTIFICATION:
        return systemSoundManager.ToneHapticsType.NOTIFICATION;
      default:
        LogUtil.showWarn(TAG, `changeToneHapticsType, invalid toneHapticsType: ${toneHapticsType}`);
        return systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0;
    }
  }

  /**
   * 转化toneHapticsType为SystemToneType|RingtoneType
   *
   * @returns
   */
  static toneHapticsTypeToToneType(toneHapticsType: systemSoundManager.ToneHapticsType): 
    systemSoundManager.SystemToneType | systemSoundManager.RingtoneType {
    switch (toneHapticsType) {
      case systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0:
        return systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
      case systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1:
        return systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1;
      case systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0:
        return systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
      case systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1:
        return systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1;
      case systemSoundManager.ToneHapticsType.NOTIFICATION:
        return systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION;
      default:
        LogUtil.showError(TAG, `toneHapticsTypeToToneType invalid toneHapticsType: ${toneHapticsType}`);
        return toneHapticsType;
    }
  }

  /**
   * 判断当前是不是系统铃声
   *
   * @param toneHapticsType
   * @returns
   */
  static isSystemRingTone(toneHapticsType: systemSoundManager.ToneHapticsType): boolean {
    LogUtil.showInfo(TAG, `isSystemRingTone toneHapticsType is ${toneHapticsType}`);
    let key: string = VibrateUtil.getRingtoneKeyPrefix(toneHapticsType);
    let isSystemRingTone: boolean = PreferencesUtil.getSync(key + '_type', RINGTONE_TYPE_SYSTEM) === RINGTONE_TYPE_SYSTEM;
    return isSystemRingTone;
  }

  static getVibrateParamKey(toneType: ToneType, toneHapticsType: systemSoundManager.ToneHapticsType
    , audioRingMode: audio.AudioRingMode): string {
    let key: string = '';
    if (toneType === ToneType.RINGTONE) {
      if (audioRingMode === audio.AudioRingMode.RINGER_MODE_SILENT ||
        audioRingMode === audio.AudioRingMode.RINGER_MODE_NORMAL) {
        if (toneHapticsType === systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0) {
          key = CALL_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM;
        } else {
          key = CALL_SILENT_AND_NORMAL_CARD2_VIBRATE_PARAM;
        }
      } else {
        if (toneHapticsType === systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0) {
          key = CALL_VIBRATE_CARD1_VIBRATE_PARAM;
        } else {
          key = CALL_VIBRATE_CARD2_VIBRATE_PARAM;
        }
      }
    } else if (toneType === ToneType.MESSAGE_TONE) {
      if (audioRingMode === audio.AudioRingMode.RINGER_MODE_SILENT ||
        audioRingMode === audio.AudioRingMode.RINGER_MODE_NORMAL) {
        if (toneHapticsType === systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0) {
          key = MESSAGE_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM;
        } else {
          key = MESSAGE_SILENT_AND_NORMAL_CARD2_VIBRATE_PARAM;
        }
      } else {
        if (toneHapticsType === systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0) {
          key = MESSAGE_VIBRATE_CARD1_VIBRATE_PARAM;
        } else {
          key = MESSAGE_VIBRATE_CARD2_VIBRATE_PARAM;
        }
      }
    } else if (toneType === ToneType.NOTIFICATION_TONE) {
      if (audioRingMode === audio.AudioRingMode.RINGER_MODE_SILENT ||
        audioRingMode === audio.AudioRingMode.RINGER_MODE_NORMAL) {
        key = NOTIFICATION_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM;
      } else {
        key = NOTIFICATION_VIBRATE_CARD1_VIBRATE_PARAM;
      }
    }
    return key;
  }

  /**
   * 获取振动类型名
   *
   * @param checkedVibrateRadioName
   * @returns
   */
  static async getCheckedVibrateTypeName(sysSoundManager: systemSoundManager.SystemSoundManager | undefined
    , context: Context, checkedVibrateRadioName: string): Promise<string> {
    let checkedVibrateTypeName: string = '';
    if (checkedVibrateRadioName === RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE) {
      checkedVibrateTypeName = ResourceUtil.getStringSync($r('app.string.vibrate_synchronize_with_ringtone'));
    } else if (checkedVibrateRadioName === RadioName.NOT_VIBRATE) {
      checkedVibrateTypeName = ResourceUtil.getStringSync($r('app.string.not_vibrate'));
    } else {
      let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined =
        await VibrateUtil.getToneHapticsList(sysSoundManager, context);
      let checkedToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined =
        toneHapticsAttrsArray?.find((item: systemSoundManager.ToneHapticsAttrs) => {
          return item.getFileName() === checkedVibrateRadioName;
        });
      checkedVibrateTypeName = checkedToneHapticsAttrs!.getTitle();
    }
    return checkedVibrateTypeName;
  }

  /**
   * 获取铃音类型对应的非同步默认文件名
   *
   * @param toneType
   * @returns
   */
  static getNonSyncDefaultFileName(toneType: string): string {
    switch (toneType) {
      case ToneType.RINGTONE:
        return DEFAULT_CALL_VIBRATE_FILENAME;
      case ToneType.MESSAGE_TONE:
        return DEFAULT_MESSAGE_VIBRATE_FILENAME;
      case ToneType.NOTIFICATION_TONE:
        return DEFAULT_NOTIFICATION_VIBRATE_FILENAME;
      default:
        LogUtil.showWarn(TAG, `getDefaultFileName invalid key: ${toneType}`);
        return '';
    }
  }

  static getSystemSoundManagerInstance(): systemSoundManager.SystemSoundManager | undefined {
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined = undefined;
    try {
      systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
      LogUtil.showInfo(TAG, ` systemSoundManagerInstance success`);
    } catch (err) {
      LogUtil.showError(TAG, `systemSoundManagerInstance errorCode ${err?.code} errorMessage ${err?.message}`);
    }
    return systemSoundManagerInstance;
  }

  /**
   * 设置振动配置
   *
   * @param sysSoundManager
   * @param context
   * @param toneHapticsType
   * @param toneHapticsSettings
   * @returns
   */
  static async setToneHapticsSettings(sysSoundManager: systemSoundManager.SystemSoundManager | undefined
    , context: common.BaseContext, toneHapticsType: systemSoundManager.ToneHapticsType
    , toneHapticsSettings: MyToneHapticsSettings): Promise<void> {
    try {
      await sysSoundManager?.setToneHapticsSettings(context, toneHapticsType, toneHapticsSettings);
      LogUtil.showInfo(TAG, `set vibrate settings, success, hapticsUri: ${toneHapticsSettings?.hapticsUri}, mode: ${toneHapticsSettings?.mode}, toneHapticsType: ${toneHapticsType}`);
    } catch (err) {
      LogUtil.showError(TAG, ` set vibrate settings, failed, err:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 获取振动配置
   *
   * @param sysSoundManager
   * @param context
   * @param toneHapticsType
   * @returns
   */
  static async getToneHapticsSettings(sysSoundManager: systemSoundManager.SystemSoundManager | undefined
    , context: common.BaseContext, toneHapticsType: systemSoundManager.ToneHapticsType):
    Promise<systemSoundManager.ToneHapticsSettings | undefined> {
    let toneHapticsSettings: systemSoundManager.ToneHapticsSettings | undefined = undefined;
    try {
      toneHapticsSettings = await sysSoundManager?.getToneHapticsSettings(context, toneHapticsType);
      LogUtil.showInfo(TAG, `getToneHapticsSettings, success, hapticsUri: ${toneHapticsSettings?.hapticsUri}, mode: ${toneHapticsSettings?.mode}`);
    } catch (err) {
      LogUtil.showError(TAG, `getToneHapticsSettings, failed, error: ${err}`);
    }
    return toneHapticsSettings;
  }

  /**
   * 获取经典(非同步)振动的振动配置
   *
   * @param sysSoundManager
   * @param context
   * @returns
   */
  static async getToneHapticsList(sysSoundManager: systemSoundManager.SystemSoundManager | undefined
    , context: common.BaseContext):
    Promise<systemSoundManager.ToneHapticsAttrsArray | undefined> {
    let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined = undefined;
    try {
      toneHapticsAttrsArray = await sysSoundManager?.getToneHapticsList(context, false);
      LogUtil.showInfo(TAG, `getToneHapticsList, success, toneHapticsAttrsArray length: ${toneHapticsAttrsArray?.length}`);
    } catch (err) {
      LogUtil.showError(TAG, `getToneHapticsList, failed, error: ${err}`);
    }
    return toneHapticsAttrsArray;
  }

  /**
   * 打开振动文件并预览振动
   *
   * @param sysSoundManager
   * @param context
   * @param toneType
   * @param uri
   * @returns
   */
  static async previewHaptics(sysSoundManager: systemSoundManager.SystemSoundManager
    , context: common.BaseContext, toneType: ToneType, uri: string): Promise<void> {
    LogUtil.showInfo(TAG, `previewSyncedHaptics, before getRingtoneUri, uri: ${uri}, toneType: ${toneType}`);
    // 打开振动文件
    let toneHapticsFd: number | undefined = undefined;
    try {
      toneHapticsFd = await sysSoundManager?.openToneHaptics(context, uri);

      let usage: string = '';
      switch (toneType) {
        case ToneType.RINGTONE:
          usage = 'ring';
          break;
        case ToneType.MESSAGE_TONE:
          usage = 'communication';
          break;
        case ToneType.NOTIFICATION_TONE:
          usage = 'notification';
          break;
        default:
          usage = 'unknown';
          break;
      }
      if (toneHapticsFd) {
        await VibrateUtil.doPreviewHaptics(usage as vibrator.Usage, toneHapticsFd);
      }
    } catch (err) {
      LogUtil.showError(TAG, `previewHaptics, failed, error: ${err}`);
    } finally {
      if (toneHapticsFd) {
        try {
          await sysSoundManager?.close(toneHapticsFd);
        } catch (err) {
          LogUtil.showError(TAG, `previewHaptics, close, failed, error: ${err}`);
        }
      }
    }
  }

  /**
   * 预览振动
   *
   * @param usage
   * @param toneHapticsFd
   * @returns
   */
  static async doPreviewHaptics(usage: vibrator.Usage, toneHapticsFd: number): Promise<void> {
    LogUtil.showInfo(TAG, `previewHaptics, before startVibration, usage: ${usage}, fd: ${toneHapticsFd}`);
    let effect: vibrator.VibrateEffect = {
      type: 'file',
      hapticFd: {
        fd: toneHapticsFd
      }
    }
    let attribute: vibrator.VibrateAttribute = {
      usage: usage
    }
    try {
      await vibrator.startVibration(effect, attribute);
      LogUtil.showInfo(TAG, `previewHaptics, startVibration success`);
    } catch (err) {
      LogUtil.showError(TAG, `previewHaptics, startVibration failed, error: ${err}`);
    }
  }

  /**
   * 校验参数合法
   *
   * @param vibrateParam
   * @returns
   */
  static validityCheck(vibrateParam: VibrateParam): boolean {
    let validity: boolean = true;
    if (vibrateParam.toneHapticsSettings.mode === systemSoundManager.ToneHapticsMode.SYNC) {
      validity = vibrateParam.isSystemRingTone && vibrateParam.isUseDefault &&
        vibrateParam.defaultVibrateRadioName === RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE &&
        vibrateParam.checkedVibrateRadioName === vibrateParam.defaultVibrateRadioName;
    } else if (vibrateParam.toneHapticsSettings.mode === systemSoundManager.ToneHapticsMode.NON_SYNC) {
      if (vibrateParam.isSystemRingTone) {
        validity = !vibrateParam.isUseDefault &&
          vibrateParam.defaultVibrateRadioName === RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE &&
          vibrateParam.checkedVibrateRadioName !== vibrateParam.defaultVibrateRadioName;
      } else {
        if (vibrateParam.isUseDefault) {
          validity = (vibrateParam.defaultVibrateRadioName !== RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE) &&
            (vibrateParam.defaultVibrateRadioName !== RadioName.NOT_VIBRATE) &&
            (vibrateParam.defaultVibrateRadioName === vibrateParam.checkedVibrateRadioName);
        } else {
          validity = (vibrateParam.defaultVibrateRadioName !== RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE) &&
            (vibrateParam.defaultVibrateRadioName !== RadioName.NOT_VIBRATE) &&
            (vibrateParam.checkedVibrateRadioName !== RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE);
        }
      }
    } else {
      validity = !vibrateParam.isUseDefault && vibrateParam.checkedVibrateRadioName === RadioName.NOT_VIBRATE &&
        vibrateParam.defaultVibrateRadioName !== RadioName.NOT_VIBRATE;
    }
    return validity;
  }

  /**
   * 非系统铃声与系统铃声切换时更新振动参数
   *
   * @param sysSoundManager
   * @param context
   * @param vibrateParam
   * @param isSystemRingToneCurrent
   * @returns
   */
  static async updateVibrateParam(sysSoundManager: systemSoundManager.SystemSoundManager | undefined, context: Context
    , vibrateParam: VibrateParam, isSystemRingToneCurrent: boolean): Promise<VibrateParam> {
    let isSystemRingToneOld: boolean = vibrateParam.isSystemRingTone;
    // 更新是否是系统铃声
    vibrateParam.isSystemRingTone = isSystemRingToneCurrent;
    LogUtil.showInfo(TAG, `updateVibrateParam, old isSystemRingTone: ${isSystemRingToneOld}, current isSystemRingTone: ${vibrateParam.isSystemRingTone}`);
    // 非系统铃声与系统铃声切换时更新ToneHapticsSettings
    if (isSystemRingToneOld !== vibrateParam.isSystemRingTone) {
      if (isSystemRingToneOld) { // 之前是系统铃声,现在不是系统铃声
        let nonSyncDefaultFileName: string = VibrateUtil.getNonSyncDefaultFileName(vibrateParam.toneType);
        let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined =
          await VibrateUtil.getToneHapticsList(sysSoundManager, context);
        let nonSyncDefaultToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined =
          toneHapticsAttrsArray?.find((item: systemSoundManager.ToneHapticsAttrs) => {
            return item.getFileName() === nonSyncDefaultFileName;
          });
        if (vibrateParam.isUseDefault) {
          if (nonSyncDefaultToneHapticsAttrs) {
            vibrateParam.checkedVibrateRadioName = nonSyncDefaultToneHapticsAttrs?.getFileName();
            vibrateParam.defaultVibrateRadioName = nonSyncDefaultToneHapticsAttrs?.getFileName();
            vibrateParam.toneHapticsSettings = new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.NON_SYNC
              , nonSyncDefaultToneHapticsAttrs?.getUri());
            await VibrateUtil.setToneHapticsSettings(sysSoundManager, context, vibrateParam.toneHapticsType
              , vibrateParam.toneHapticsSettings);
          }
        } else {
          if (nonSyncDefaultToneHapticsAttrs) {
            vibrateParam.defaultVibrateRadioName = nonSyncDefaultToneHapticsAttrs?.getFileName();
          }
        }
      } else { // 之前不是系统铃声,现在是系统铃声
        if (vibrateParam.isUseDefault) {
          vibrateParam.checkedVibrateRadioName = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
          vibrateParam.defaultVibrateRadioName = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
          vibrateParam.toneHapticsSettings = new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.SYNC);
          await VibrateUtil.setToneHapticsSettings(sysSoundManager, context, vibrateParam.toneHapticsType
            , vibrateParam.toneHapticsSettings);
        } else {
          vibrateParam.defaultVibrateRadioName = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
        }
      }
    }
    return vibrateParam;
  }
}