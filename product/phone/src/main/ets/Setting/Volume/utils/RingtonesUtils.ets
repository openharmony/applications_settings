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
import { BusinessError } from '@ohos.base';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import settings from '@ohos.settings';
import call from '@ohos.telephony.call';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { RadioName } from '../constant/VibrateConstant';
import {
  DEFAULT_CARD0_RINGTONE,
  DEFAULT_CARD1_RINGTONE,
  DEFAULT_MESSAGE_TONE,
  DEFAULT_NO_RING_URI,
  DEFAULT_NO_RINGTONE_URI,
  DEFAULT_NOTIFICATION_TONE,
  EVENT_SYSTEM_MESSAGETONE,
  EVENT_SYSTEM_NOTIFICATIONTONE,
  EVENT_SYSTEM_RINGTONE,
  RingtoneType,
  SimRingtoneKey,
  RINGTONE_TYPE_CUSTOM
} from '../constant/VolumeConstant';
import { VolumeAdapter } from '../controller/VolumeAdapter';
import { ToneType } from '../model/RingtoneParam';
import { VibrateParam } from '../model/VibrateParam';
import { ToneAttrs, VolumeDataType, VolumeStateInfo } from '../model/VolumeType';
import { VibrateUtil } from '../utils/VibrateUtil';
import { RingtoneSimUtil, SLOT_INDEX_0, SLOT_INDEX_1 } from './RingtoneSimUtil';

const TAG: string = 'RingtonesUtils :';
const SUB_LINE: string = '_';
const PCE_PRODUCT_MODEL: string = 'PCE';

/**
 * 铃声工具类
 */
export class RingtonesUtils {
  private static context: Context = getContext(this);
  private static isVoiceCapabilityEnable: boolean = call.hasVoiceCapability();

  // 无铃声 转为 仅振动
  public static formatNoRingtone(curTone: string, hapticsType: systemSoundManager.ToneHapticsType, toneType: ToneType) {
    const currentRingMode = VolumeAdapter.getInstance().getRingerMode();
    const vibrateKey = VibrateUtil.getVibrateParamKey(toneType, hapticsType, currentRingMode);
    let defaultVibrateParam: VibrateParam = new VibrateParam();
    let vibrateParam: VibrateParam = PreferencesUtil.getSync(vibrateKey, defaultVibrateParam) as VibrateParam;
    // 判断是否无振动
    if (curTone === ResourceUtil.getStringSync($r('app.string.no_ringtone')) ||
      curTone === ResourceUtil.getStringSync($r('app.string.vibrate_only'))) {
      if (vibrateParam.checkedVibrateRadioName === RadioName.NOT_VIBRATE) {
        curTone = ResourceUtil.getStringSync($r('app.string.volume_mode_silent'));
      } else {
        curTone = ResourceUtil.getStringSync($r('app.string.vibrate_only'));
      }
    }
    return curTone;
  }

  // 获取当前铃声
  static async getCurrentTone(ringtoneList: systemSoundManager.ToneAttrsArray,
    type: systemSoundManager.RingtoneType | systemSoundManager.SystemToneType, toneType: ToneType,
    cardNumber: number): Promise<string> {
    let key: string = '';
    let ringtone: string = '';
    let toneCustomizedType: number = systemSoundManager.ToneCustomizedType.PRE_INSTALLED;
    let sysSoundManager: systemSoundManager.SystemSoundManager = systemSoundManager.getSystemSoundManager();
    if (sysSoundManager === undefined || sysSoundManager === null) {
      LogUtil.showError(TAG, `getCurrentTone SystemSoundManager invalid!`);
      return '';
    }
    if (toneType === ToneType.RINGTONE) {
      ringtone = await sysSoundManager.getRingtoneUri(RingtonesUtils.context,
        type as systemSoundManager.RingtoneType);
      key = type === systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0 ? SimRingtoneKey.CARD_0_RINGTONE_KEY :
        SimRingtoneKey.CARD_1_RINGTONE_KEY;
    } else if (toneType === ToneType.MESSAGE_TONE) {
      ringtone = await sysSoundManager.getSystemToneUri(RingtonesUtils.context,
        type as systemSoundManager.SystemToneType);
      key = type === systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0 ?
        SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY : SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY;
    } else {
      ringtone = await sysSoundManager.getSystemToneUri(RingtonesUtils.context,
        type as systemSoundManager.SystemToneType);
      key = SimRingtoneKey.NOTIFICATION_RINGTONE_KEY;
    }

    if (ringtone === DEFAULT_NO_RINGTONE_URI || ringtone === DEFAULT_NO_RING_URI) {
      ringtone = ResourceUtil.getStringSync($r('app.string.vibrate_only'));
      ringtone = RingtonesUtils.formatNoRingtone(ringtone, VibrateUtil.getToneHapticsType(toneType, cardNumber),
        toneType);
      PreferencesUtil.putSync(key, ringtone);
      PreferencesUtil.putSync(key + '_type', RINGTONE_TYPE_CUSTOM);
    }

    for (let index = 0; index < ringtoneList.length; index++) {
      if (ringtoneList[index].getUri() === ringtone) {
        toneCustomizedType = ringtoneList[index].getCustomizedType();
        ringtone = ringtoneList[index].getTitle();
        if (toneCustomizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED) {
          ringtone = ringtone.replace(new RegExp('_', 'g'), ' ');
        }
        RingtonesUtils.putDataByToneType(toneCustomizedType, key, ringtone, ringtoneList[index].getUri());
      }
    }
    LogUtil.showInfo(TAG, `now ringtone is : ${ringtone}, type: ${type}, key: ${key}`);
    return ringtone;
  }

  private static putDataByToneType(toneCustomizedType: number, key: string, ringtone: string, uri: string) {
    PreferencesUtil.putSync(key + '_type', toneCustomizedType);
    if (toneCustomizedType === 1) {
      // 非系统铃声,刷新 key_music值
      let nowTone: Record<string, Object> = PreferencesUtil.getSync(key + '_music', []) as Record<string, Object>;
      if (ringtone !== nowTone?.ringtoneName) {
        let data: Record<string, Object> = {};
        data['ringtoneName'] = ringtone;
        data['uri'] = uri;
        nowTone = data;
      }
      PreferencesUtil.putSync(key + '_music', nowTone);
    } else {
      PreferencesUtil.delete(key + '_music');
    }
    LogUtil.showInfo(TAG, `putDataByToneType, ${key}, ${ringtone}`);
    PreferencesUtil.putSync(key, ringtone);
  }

  static getRingtoneKey(isCardOne: boolean, type: RingtoneType | string): string {
    switch (type) {
      case RingtoneType.RINGTONE_TYPE_SIM:
        return isCardOne ? SimRingtoneKey.CARD_0_RINGTONE_KEY : SimRingtoneKey.CARD_1_RINGTONE_KEY;
      case ToneType.RINGTONE:
        return isCardOne ? SimRingtoneKey.CARD_0_RINGTONE_KEY : SimRingtoneKey.CARD_1_RINGTONE_KEY;
      case RingtoneType.RINGTONE_TYPE_SMS:
        return isCardOne ? SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY : SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY;
      case ToneType.MESSAGE_TONE:
        return isCardOne ? SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY : SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY;
      case RingtoneType.RINGTONE_TYPE_NOTIFICATION:
        return SimRingtoneKey.NOTIFICATION_RINGTONE_KEY;
      case ToneType.NOTIFICATION_TONE:
        return SimRingtoneKey.NOTIFICATION_RINGTONE_KEY;
      default:
        LogUtil.showWarn(TAG, `getRingtoneKey invalid type: ${type}`);
        return '';
    }
  }

  static async getRingtoneUri(ringtoneType: RingtoneType, context: Context): Promise<string> {
    let ringtoneValue: string = '';
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager = systemSoundManager.getSystemSoundManager();
    if (systemSoundManagerInstance === undefined || systemSoundManagerInstance === null) {
      LogUtil.showError(TAG, 'getRingtoneUri SystemSoundManager invalid');
      return ringtoneValue;
    }
    if (ringtoneType === RingtoneType.RINGTONE_TYPE_SIM) {
      ringtoneValue = await systemSoundManagerInstance.getRingtoneUri(context,
        systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0);
    } else if (ringtoneType === RingtoneType.RINGTONE_TYPE_ALARM) {
      await systemSoundManagerInstance.getDefaultAlarmToneAttrs(context).then((value) => {
        ringtoneValue = value.getUri();
      })
    } else if (ringtoneType === RingtoneType.RINGTONE_TYPE_NOTIFICATION) {
      ringtoneValue = await systemSoundManagerInstance.getSystemToneUri(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION);
    } else {
      LogUtil.showError(TAG, `unknown ringtoneType:${ringtoneType}`);
    }
    return ringtoneValue;
  }

  // 更新铃声展示
  static updateRingtone(data: VolumeDataType, ringtoneType: RingtoneType, stateInfo: VolumeStateInfo): void {
    let eventName: string =
      ringtoneType === RingtoneType.RINGTONE_TYPE_SIM ? HiSysVolumeEventGroup.VOLUME_PHONE_SELECTED :
      HiSysVolumeEventGroup.VOLUME_MESSAGE_SELECTED;
    const card0 = RingtoneSimUtil.getSimCardName(SLOT_INDEX_0);
    const card1 = RingtoneSimUtil.getSimCardName(SLOT_INDEX_1);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(eventName, data?.value);
    RingtonesUtils.updateMenuStatus(data, ringtoneType, stateInfo, card0, card1);

    let card1Value: string | undefined =
      stateInfo.primaryState.substring(stateInfo.primaryState.indexOf(':') + 1).trim();
    let card2Value: string | undefined =
      stateInfo.secondaryState.substring(stateInfo.secondaryState.indexOf(':') + 1).trim();
    if (stateInfo.summaryInfo && (data?.currentIndex === 0 || data?.currentIndex === 1)) {
      if (card1Value && card1Value !== stateInfo.summaryInfo) {
        stateInfo.secondaryState = `${card1}: ${stateInfo.summaryInfo}`;
      } else if (card2Value && card2Value !== stateInfo.summaryInfo) {
        stateInfo.primaryState = `${card0}: ${stateInfo.summaryInfo}`;
      } else if ((card1Value || card2Value) === stateInfo.summaryInfo) {
        stateInfo.primaryState = `${card0}: ${stateInfo.summaryInfo}`;
        stateInfo.secondaryState = `${card1}: ${stateInfo.summaryInfo}`;
      }
      stateInfo.summaryInfo = '';
    }
    card1Value = stateInfo.primaryState.substring(stateInfo.primaryState.indexOf(':') + 1).trim();
    card2Value = stateInfo.secondaryState.substring(stateInfo.secondaryState.indexOf(':') + 1).trim();
    if (card1Value && card1Value === card2Value) {
      stateInfo.secondaryState = '';
      stateInfo.primaryState = '';
      stateInfo.summaryInfo = data?.value ?? '';
    }
  }

  static updateMenuStatus(data: VolumeDataType, ringtoneType: RingtoneType, stateInfo: VolumeStateInfo, card0: string,
    card1: string) {
    if (data?.currentIndex === 0) {
      if (data?.isSelect) {
        if (stateInfo.summaryInfo) {
          // 卡1和卡2一样时，卡1选择无铃声展示卡2
          stateInfo.secondaryState = `${card1}: ${stateInfo.summaryInfo}`;
        }
        stateInfo.primaryState = `${card0}: ${data?.value}`;
      } else {
        // 设置来电铃声卡1
        stateInfo.primaryState = `${card0}: ${data?.value}`;
      }
    } else if (data?.currentIndex === 1) {
      if (data?.isSelect) {
        if (stateInfo.summaryInfo) {
          // 卡1和卡2一样时，卡2选择无铃声展示卡1
          stateInfo.primaryState = `${card0}: ${stateInfo.summaryInfo}`;
        }
        stateInfo.secondaryState = `${card1}: ${data?.value}`;
      } else {
        // 设置来电铃声卡2
        stateInfo.secondaryState = `${card1}: ${data?.value}`;
      }
    } else {
      stateInfo.summaryInfo = data?.value ?? '';
    }
  }

  public static isVoiceCapabilityDisable(): boolean {
    return !RingtonesUtils.isVoiceCapabilityEnable;
  }

  public static getTouchSwitchStatus(): boolean {
    return SettingsDataUtils.getSettingsData('physic_navi_haptic_feedback_enabled', '1') == '1';
  }

  public static getDialToneChose(): number {
    let context: Context = SettingsDataUtils.getContext();
    return Number(SettingsDataUtils.getSettingsDataWithContext(context, 'dialpad_touch_tone_type', '1',
      settings.domainName.USER_PROPERTY));
  }

  public static async getDefaultTone(toneType: systemSoundManager.RingtoneType | systemSoundManager.SystemToneType,
    ringtoneType: RingtoneType, systemSoundManagerInstance: systemSoundManager.SystemSoundManager): Promise<string> {
    let defaultTune: string = '';
    try {
      switch (ringtoneType) {
        case RingtoneType.RINGTONE_TYPE_SIM:
          defaultTune = (await systemSoundManagerInstance.getDefaultRingtoneAttrs(RingtonesUtils.context,
            toneType as systemSoundManager.RingtoneType)).getTitle();
          defaultTune = defaultTune.replace(new RegExp(SUB_LINE, 'g'), ' ');
          if (toneType === systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0) {
            PreferencesUtil.putSync(SimRingtoneKey.CARD_0_RINGTONE_KEY + '_defaultTune', defaultTune);
          } else {
            PreferencesUtil.putSync(SimRingtoneKey.CARD_1_RINGTONE_KEY + '_defaultTune', defaultTune);
          }
          break;
        case RingtoneType.RINGTONE_TYPE_SMS:
          defaultTune = (await systemSoundManagerInstance.getDefaultSystemToneAttrs(RingtonesUtils.context,
            toneType as systemSoundManager.SystemToneType)).getTitle();
          defaultTune = defaultTune.replace(new RegExp(SUB_LINE, 'g'), ' ');
          PreferencesUtil.putSync(SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY + '_defaultTune', defaultTune);
          break;
        case RingtoneType.RINGTONE_TYPE_NOTIFICATION:
          defaultTune = (await systemSoundManagerInstance.getDefaultSystemToneAttrs(RingtonesUtils.context,
            toneType as systemSoundManager.SystemToneType)).getTitle();
          defaultTune = defaultTune.replace(new RegExp(SUB_LINE, 'g'), ' ');
          PreferencesUtil.putSync(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY + '_defaultTune', defaultTune);
        default:
          break;
      }
    } catch (err) {
      LogUtil.showError(TAG, `get default tone error, code: ${(err as BusinessError)?.code}, message: ${(err as BusinessError)?.message}`);
    }
    LogUtil.showInfo(TAG, `toneType: ${toneType}, ringtoneType: ${ringtoneType}, defaultTune: ${defaultTune}`);
    return defaultTune;
  }

  public static async getRingerToneList(toneType: systemSoundManager.RingtoneType | systemSoundManager.SystemToneType,
    ringtoneType: RingtoneType): Promise<Array<ToneAttrs>> {
    let resToneList: ToneAttrs[] = [];
    let toneAttrsArray: systemSoundManager.ToneAttrsArray = [];
    let defaultCardTune: string = '';
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager = systemSoundManager.getSystemSoundManager();
    if (systemSoundManagerInstance === undefined || systemSoundManagerInstance === null) {
      LogUtil.showError(TAG, `getRingerToneList SystemSoundManager invalid!`);
      return resToneList;
    }
    defaultCardTune = await RingtonesUtils.getDefaultTone(toneType, ringtoneType, systemSoundManagerInstance);
    try {
      switch (ringtoneType) {
        case RingtoneType.RINGTONE_TYPE_SIM:
          toneAttrsArray = await systemSoundManagerInstance.getRingtoneAttrList(RingtonesUtils.context,
            systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0);
          break;
        case RingtoneType.RINGTONE_TYPE_SMS:
          toneAttrsArray = await systemSoundManagerInstance.getSystemToneAttrList(RingtonesUtils.context,
            toneType as systemSoundManager.SystemToneType);
          break;
        case RingtoneType.RINGTONE_TYPE_NOTIFICATION:
          toneAttrsArray = await systemSoundManagerInstance.getSystemToneAttrList(RingtonesUtils.context,
            toneType as systemSoundManager.SystemToneType);
          break;
        default:
          LogUtil.showError(TAG, 'ring tone type is wrong!');
          break;
      }
    } catch (err) {
      LogUtil.showError(TAG, `get list error, code: ${(err as BusinessError)?.code}, message: ${(err as BusinessError)?.message}`);
      return [];
    }
    let defaultValue: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_default'));
    LogUtil.showInfo(TAG, `defaultValue: ${defaultValue}`);
    let defaultTone: ToneAttrs = {
      title: `${defaultCardTune.replace(new RegExp(SUB_LINE, 'g'), ' ')} (${defaultValue})`,
      fileName: '',
      uri: '',
      customizedType: systemSoundManager.ToneCustomizedType.PRE_INSTALLED
    };
    resToneList.push(defaultTone);
    for (let index = 0; index < toneAttrsArray.length; index++) {
      const element = toneAttrsArray[index];
      let title = element.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' ');
      if (title === defaultCardTune &&
        element.getCustomizedType() === systemSoundManager.ToneCustomizedType.PRE_INSTALLED) {
        resToneList[0].fileName = element.getFileName();
        resToneList[0].uri = element.getUri();
        continue;
      }
      let curTone: ToneAttrs = { title: '', fileName: '', uri: '', customizedType: systemSoundManager.ToneCustomizedType.PRE_INSTALLED };
      curTone.title = element.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' ');
      curTone.fileName = element.getFileName();
      curTone.uri = element.getUri();
      curTone.customizedType = element.getCustomizedType();
      resToneList.push(curTone);
    }
    return resToneList;
  }

  public static getEmitId(key: string): string {
    switch (key) {
      case NavEntryKey.RING_TONE_ENTRY:
        return EVENT_SYSTEM_RINGTONE;
      case ToneType.RINGTONE:
        return EVENT_SYSTEM_RINGTONE;
      case NavEntryKey.MESSAGING_TONE_ENTRY:
        return EVENT_SYSTEM_MESSAGETONE;
      case ToneType.MESSAGE_TONE:
        return EVENT_SYSTEM_MESSAGETONE;
      case NavEntryKey.NOTIFICATION_TONE_ENTRY:
        return EVENT_SYSTEM_NOTIFICATIONTONE;
      case ToneType.NOTIFICATION_TONE:
        return EVENT_SYSTEM_NOTIFICATIONTONE;
      default:
        LogUtil.showWarn(TAG, `getEmitId invalid key: ${key}`);
        return '';
    }
  }

  // 铃声界面navKey转换ToneType
  public static navKey2Type(navKey: string): ToneType {
    switch (navKey) {
      case NavEntryKey.RING_TONE_ENTRY:
        return ToneType.RINGTONE;
      case NavEntryKey.MESSAGING_TONE_ENTRY:
        return ToneType.MESSAGE_TONE;
      case NavEntryKey.NOTIFICATION_TONE_ENTRY:
        return ToneType.NOTIFICATION_TONE;
      default:
        LogUtil.showWarn(TAG, `navKey2Type invalid navKey: ${navKey}`);
        return ToneType.INVALID_TONE;
    }
  }

  // 默认铃声格式转化
  public static formatDefaultTone(isCardOne: boolean, toneType: ToneType, curTone: string): string {
    let defaultTone: string = '';
    switch (toneType) {
      case ToneType.RINGTONE:
        let defaultTone0 = PreferencesUtil.getSync(SimRingtoneKey.CARD_0_RINGTONE_KEY + '_defaultTune', DEFAULT_CARD0_RINGTONE) as string;
        let defaultTone1 = PreferencesUtil.getSync(SimRingtoneKey.CARD_1_RINGTONE_KEY + '_defaultTune', DEFAULT_CARD1_RINGTONE) as string;
        defaultTone = isCardOne ? defaultTone0 : defaultTone1;
        break;
      case ToneType.MESSAGE_TONE:
        defaultTone = PreferencesUtil.getSync(SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY + '_defaultTune', DEFAULT_MESSAGE_TONE) as string;
        break;
      case ToneType.NOTIFICATION_TONE:
        defaultTone = PreferencesUtil.getSync(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY + '_defaultTune', DEFAULT_NOTIFICATION_TONE) as string;
        break;
      default:
        LogUtil.showError(TAG, `invalid toneType`);
    }
    let defaultValue: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_default'));
    LogUtil.showInfo(TAG, `curTone:${curTone} defaultTone: ${defaultTone}`);
    curTone = curTone === defaultTone ? `${defaultTone} (${defaultValue})` : curTone;
    return curTone;
  }

  public static touchFeedBackShow(): boolean {
    LogUtil.debug(`${TAG} productModel: ${DeviceUtil.productMode}`);
    return DeviceUtil.productMode.includes(PCE_PRODUCT_MODEL) ? false : true;
  }

  public static getPreDefaultRingtone(ringToneKey: string, defaultRingTone: string): string {
    let defaultTitle = PreferencesUtil.getSync(ringToneKey, '') as string;
    let ringtoneValue = CheckEmptyUtils.isEmpty(defaultTitle) ? defaultRingTone : defaultTitle;
    LogUtil.info(`${TAG} ringToneKey: ${ringToneKey} title: ${defaultTitle} return ringtoneValue: ${ringtoneValue}`);
    return ringtoneValue;
  }
}