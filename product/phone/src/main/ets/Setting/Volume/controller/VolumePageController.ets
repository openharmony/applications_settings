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
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { RingtoneSimUtil } from '../utils/RingtoneSimUtil';
import { AvplayerController } from './AvplayerController';
import { MessagetoneController, NotificationtoneController, RingtoneController } from './RingToneController';
import { TouchFeedBackController } from './TouchFeedBackController';
import { VibrateWhenRingController } from './VibrateWhenRingController';
import { VolumeAdapter } from './VolumeAdapter';

const TAG: string = 'VolumePageController';

export class VolumePageController implements ComponentControl {
  private touchFeedBackController: TouchFeedBackController = new TouchFeedBackController(); // 系统触感反馈
  private ringtoneController: RingtoneController = new RingtoneController(); // 来电铃声
  private messageToneController: MessagetoneController = new MessagetoneController(); // 短信铃声
  private notificationToneController: NotificationtoneController = new NotificationtoneController(); // 通知铃声
  private vibrateWhenRingController: VibrateWhenRingController = new VibrateWhenRingController(); // 响铃时振动
  private curLocaleKey: string = 'curLocale';
  private defaultLocale: string = 'zh-Hans-CN';
  private isLocaleChange: boolean = false;
  private localeChangeForRingtone: string = 'localeChangeForRingtone';
  private localeChangeForMessageTone: string = 'localeChangeForMessageTone';
  private localeChangeForNotificationTone: string = 'localeChangeForNotificationTone';

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    let curLocale: string = i18n.System.getSystemLocale();
    if (curLocale !== PreferencesUtil.getSync(this.curLocaleKey, this.defaultLocale)) {
      this.isLocaleChange = true;
      PreferencesUtil.putSync(this.localeChangeForRingtone, this.isLocaleChange);
      PreferencesUtil.putSync(this.localeChangeForMessageTone, this.isLocaleChange);
      PreferencesUtil.putSync(this.localeChangeForNotificationTone, this.isLocaleChange);
      PreferencesUtil.putSync(this.curLocaleKey, curLocale);
      LogUtil.showInfo(TAG, `curLocale: ${curLocale}, isLocalChange: ${this.isLocaleChange}`);
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_SETTINGS_INTERNAL_ENTRY);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    AvplayerController.releaseAvplayer();
    RingtoneSimUtil.resetSimCardName();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.touchFeedBackController.onPageShow(component);
    this.ringtoneController.onPageShow(component);
    this.messageToneController.onPageShow(component);
    this.notificationToneController.onPageShow(component);
    this.vibrateWhenRingController.onPageShow(component);
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW);
    setTimeout(() => {
      VolumeAdapter.getInstance().registerVolumeEvents();
    }, 0);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    AvplayerController.releaseAvplayer();
    this.touchFeedBackController.onPageHide(component);
    this.ringtoneController.onPageHide(component);
    this.messageToneController.onPageHide(component);
    this.notificationToneController.onPageHide(component);
    this.vibrateWhenRingController.onPageHide(component);
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE);
    VolumeAdapter.getInstance().unregisterVolumeEvents();
  }
}