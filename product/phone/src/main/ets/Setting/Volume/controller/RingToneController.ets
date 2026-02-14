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
import i18n from '@ohos.i18n';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import {
  DEFAULT_CARD0_RINGTONE,
  DEFAULT_CARD0_RINGTONE_CN,
  DEFAULT_CARD1_RINGTONE,
  DEFAULT_CARD1_RINGTONE_CN,
  DEFAULT_MESSAGE_TONE,
  DEFAULT_MESSAGE_TONE_CN,
  DEFAULT_NOTIFICATION_TONE,
  DEFAULT_NOTIFICATION_TONE_CN,
  EVENT_SYSTEM_MESSAGETONE,
  EVENT_SYSTEM_NOTIFICATIONTONE,
  EVENT_SYSTEM_RINGTONE,
  RingtoneType,
  SimRingtoneKey
} from '../constant/VolumeConstant';
import { ToneType } from '../model/RingtoneParam';
import { VolumeDataType } from '../model/VolumeType';
import { RingtoneSimUtil, SLOT_INDEX_0, SLOT_INDEX_1 } from '../utils/RingtoneSimUtil';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { VolumeController } from './VolumeController';

const MAX_SIM_NUM: number = 2;

export class RingtoneController extends VolumeController {
  private tag: string = 'RingtoneController : ';

  init(): void {
    LogUtil.showDebug(this.tag, 'init');
    this.getSystemRingtone();
    EventBus.getInstance().on(EVENT_SYSTEM_RINGTONE, (data: VolumeDataType) => {
      RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SIM, this.stateInfo);
    });
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'destroy');
    EventBus.getInstance().off(EVENT_SYSTEM_RINGTONE);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    let context: Context = getContext(this);
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager = systemSoundManager.getSystemSoundManager();
    Promise.all([
      systemSoundManagerInstance.getRingtoneAttrList(context, systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0)
    ]).then(async (res) => {
      let ringtoneList: systemSoundManager.ToneAttrsArray = res[0];
      let ringtone0: string = await RingtonesUtils.getCurrentTone(ringtoneList,
        systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0, ToneType.RINGTONE, 0);
      let ringtone1: string = await RingtonesUtils.getCurrentTone(ringtoneList,
        systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1, ToneType.RINGTONE, 1);
      this.flushSystemRingtone(ringtone0, ringtone1);
      EventBus.getInstance().emit('ring_tone_settings_phone_event', this.stateInfo);
    }).catch((error: Error) => {
      LogUtil.error(`${this.tag} get Promise.all failed, error reason: ${error}`);
    });
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  private async getSystemRingtone(): Promise<void> {
    let curLocale: string = i18n.System.getSystemLocale();
    let default0: string = curLocale === 'zh-Hans-CN' ? DEFAULT_CARD0_RINGTONE_CN : DEFAULT_CARD0_RINGTONE;
    let default1: string = curLocale === 'zh-Hans-CN' ? DEFAULT_CARD1_RINGTONE_CN : DEFAULT_CARD1_RINGTONE;
    let curToneForCard0: string =
      PreferencesUtil.getSync(SimRingtoneKey.CARD_0_RINGTONE_KEY, default0) as string;
    let curToneForCard1: string =
      PreferencesUtil.getSync(SimRingtoneKey.CARD_1_RINGTONE_KEY, default1) as string;
    curToneForCard0 = RingtonesUtils.formatNoRingtone(curToneForCard0,
      systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0, ToneType.RINGTONE);
    curToneForCard1 = RingtonesUtils.formatNoRingtone(curToneForCard1,
      systemSoundManager.ToneHapticsType.CALL_SIM_CARD_1, ToneType.RINGTONE);
    LogUtil.showInfo(this.tag, `getSystemRingtone, curTone: ${curToneForCard0}, ${curToneForCard1}`);
    this.flushSystemRingtone(curToneForCard0, curToneForCard1);
  }

  private flushSystemRingtone(ringtoneValue1: string, ringtoneValue2: string): void {
    LogUtil.info(`${this.tag} flushSystemRingtone, ringtoneValue1: ${ringtoneValue1}, ringtoneValue2: ${ringtoneValue2}`);
    if (SimUtils.getCardSlotNum() === MAX_SIM_NUM) {
      if (ringtoneValue1 && ringtoneValue2 && ringtoneValue1 === ringtoneValue2) {
        this.stateInfo.summaryInfo = ringtoneValue1;
        this.stateInfo.primaryState = '';
        this.stateInfo.secondaryState = '';
      } else {
        let card1: string = RingtoneSimUtil.getSimCardName(SLOT_INDEX_0);
        let card2: string = RingtoneSimUtil.getSimCardName(SLOT_INDEX_1);
        this.stateInfo.primaryState = `${card1}: ${ringtoneValue1}`;
        this.stateInfo.secondaryState = `${card2}: ${ringtoneValue2}`;
        this.stateInfo.summaryInfo = '';
      }
    } else {
      this.stateInfo.summaryInfo = ringtoneValue1;
      this.stateInfo.primaryState = '';
      this.stateInfo.secondaryState = '';
    }
  }
}

/**
 * 信息铃声
 */
export class MessagetoneController extends VolumeController {
  private tag: string = 'MessagetoneController : ';

  init(): void {
    LogUtil.showDebug(this.tag, 'init');
    this.getSystemMessageTone();
    EventBus.getInstance().on(EVENT_SYSTEM_MESSAGETONE, (data: VolumeDataType) => {
      RingtonesUtils.updateRingtone(data, RingtoneType.RINGTONE_TYPE_SMS, this.stateInfo);
    });
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    let context: Context = getContext(this);
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager =
      systemSoundManager.getSystemSoundManager();
    Promise.all([
      systemSoundManagerInstance.getSystemToneAttrList(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0)
    ]).then(async (res) => {
      let systemToneList = res[0];
      let messageTone0: string = await RingtonesUtils.getCurrentTone(systemToneList,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0, ToneType.MESSAGE_TONE, 0);
      let messageTone1: string = await RingtonesUtils.getCurrentTone(systemToneList,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1, ToneType.MESSAGE_TONE, 1);
      this.flushSystemRingtone(messageTone0, messageTone1);
      EventBus.getInstance().emit('ring_tone_settings_message_event', this.stateInfo);
    }).catch((error: Error) => {
      LogUtil.error(`${this.tag} get Promise.all failed, error reason: ${error?.message}`);
    });
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'destroy');
    EventBus.getInstance().off(EVENT_SYSTEM_MESSAGETONE);
  }

  //获取信息铃声及信息展示
  private async getSystemMessageTone(): Promise<void> {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_MESSAGE_TONE_CN : DEFAULT_MESSAGE_TONE;
    let curToneForCard0: string =
      PreferencesUtil.getSync(SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY, defaultTone) as string;
    let curToneForCard1: string =
      PreferencesUtil.getSync(SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY, defaultTone) as string;
    curToneForCard0 = RingtonesUtils.formatNoRingtone(curToneForCard0,
      systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_0, ToneType.MESSAGE_TONE);
    curToneForCard1 = RingtonesUtils.formatNoRingtone(curToneForCard1,
      systemSoundManager.ToneHapticsType.TEXT_MESSAGE_SIM_CARD_1, ToneType.MESSAGE_TONE)
    LogUtil.showInfo(this.tag, `getSystemMessageTone, curTone: ${curToneForCard0}, ${curToneForCard1}`);
    this.flushSystemRingtone(curToneForCard0, curToneForCard1);
  }

  private flushSystemRingtone(ringtoneValue1: string, ringtoneValue2: string): void {
    LogUtil.info(`${this.tag} flushSystemRingtone`);
    if (SimUtils.getCardSlotNum() === MAX_SIM_NUM) {
      if (ringtoneValue1 === ringtoneValue2) {
        this.stateInfo.summaryInfo = ringtoneValue1;
        this.stateInfo.primaryState = '';
        this.stateInfo.secondaryState = '';
      } else {
        let card1: string = RingtoneSimUtil.getSimCardName(SLOT_INDEX_0);
        let card2: string = RingtoneSimUtil.getSimCardName(SLOT_INDEX_1);
        this.stateInfo.primaryState = `${card1}: ${ringtoneValue1}`;
        this.stateInfo.secondaryState = `${card2}: ${ringtoneValue2}`;
        this.stateInfo.summaryInfo = '';
      }
    } else {
      this.stateInfo.summaryInfo = ringtoneValue1;
      this.stateInfo.primaryState = '';
      this.stateInfo.secondaryState = '';
    }
  }
}

/**
 * 通知铃声
 */
export class NotificationtoneController extends VolumeController {
  private tag: string = 'NotificationtoneController : ';

  init(): void {
    LogUtil.showDebug(this.tag, 'init');
    this.getSystemNotificationTone();
    EventBus.getInstance().on(EVENT_SYSTEM_NOTIFICATIONTONE, (data: VolumeDataType) => {
      this.notificationToneSettings(data);
    });
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    let context: Context = getContext(this);
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager =
      systemSoundManager.getSystemSoundManager();
    Promise.all([
      systemSoundManagerInstance.getSystemToneAttrList(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION)
    ]).then(async (res) => {
      let systemToneList1 = res[0];
      let notificationTone: string = await RingtonesUtils.getCurrentTone(systemToneList1,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION, ToneType.NOTIFICATION_TONE, 0);
      this.stateInfo.summaryInfo = notificationTone;
      EventBus.getInstance().emit('ring_tone_settings_notification_event', this.stateInfo);
    }).catch((error: Error) => {
      LogUtil.error(`${this.tag} get Promise.all failed, error reason: ${error}`);
    });
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'destroy');
    EventBus.getInstance().off(EVENT_SYSTEM_NOTIFICATIONTONE);
  }

  // 获取通知铃声
  private async getSystemNotificationTone(): Promise<void> {
    let curLocale: string = i18n.System.getSystemLocale();
    let defaultTone: string = curLocale === 'zh-Hans-CN' ? DEFAULT_NOTIFICATION_TONE_CN : DEFAULT_NOTIFICATION_TONE;
    let curTone: string =
      PreferencesUtil.getSync(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY, defaultTone) as string;
    curTone = RingtonesUtils.formatNoRingtone(curTone, systemSoundManager.ToneHapticsType.NOTIFICATION,
      ToneType.NOTIFICATION_TONE)
    LogUtil.showInfo(this.tag, `getSystemNotificationTone, curTone: ${curTone}`);
    curTone = curTone.replace(new RegExp('_', 'g'), ' ');
    this.stateInfo.summaryInfo = curTone;
  }

  // 设置修改通知铃声展示
  private notificationToneSettings(data: VolumeDataType): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_NOTIFICATION_SELECTED, data?.value);
    this.stateInfo.summaryInfo = data?.value as string;
    PreferencesUtil.putSync(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY, data?.value as string);
  }
}