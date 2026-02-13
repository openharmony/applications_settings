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

import settings from '@ohos.settings';
import Want from '@ohos.app.ability.Want';
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  DISTURB_MODE_TRIGGER_END_TIME,
  DISTURB_MODE_TRIGGER_START_TIME,
  NotDisturbTimerManager
} from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import {
  FOCUS_MODE_ENABLED,
  NotDisturbUtils,
  NOT_DISTURB_VALUE_ENABLE,
  NOT_DISTURB_VALUE_ERROR
} from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { NotDisturbReportSources } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
/* instrument ignore file */
/**
 * Service ability for NotDisturb
 *
 * @since 2024-07-15
 */
const TAG: string = 'NotDisturbService';
const ONE_MINUTE: number = 60 * 1000;

export default class NotDisturbService extends ServiceExtensionAbility {
  async onCreate(want: Want) {
    LogUtil.showInfo(TAG, 'onCreate');
    GlobalContext.getInstance().set('TimerContext', this.context);
  }

  async onRequest(want: Want, startId: number) {
    let isSupportIntelligentScene = CapabilitySupportUtils.isSupportIntelligentScene();
    if (isSupportIntelligentScene) {
      LogUtil.warn(`${TAG} It supports intelligent scene`);
      return;
    }
    LogUtil.info(`${TAG} onRequest abilityName:${want.abilityName} bundleName:${want.bundleName} startId:${startId}`);
    let modeValue = SettingsDataUtils.getSettingsDataWithContext(this.context,
      FOCUS_MODE_ENABLED, '', settings.domainName.USER_SECURITY);
    NotDisturbTimerManager.getInstance().initOtherConfig(this.context);
    LogUtil.info(`${TAG} onRequest focus_mode_enable modeValue: ${modeValue}`);
    if (modeValue === NOT_DISTURB_VALUE_ENABLE) {
      SettingsDataUtils.setSettingsDataWithContext(this.context, DISTURB_MODE_TRIGGER_START_TIME,
        NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsDataWithContext(this.context, DISTURB_MODE_TRIGGER_END_TIME,
        NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      NotDisturbTimerManager.getInstance().closeTypeOncesDb();
      NotDisturbTimerManager.getInstance().refreshTimer(true);
    } else {
      let nowTime = new Date().getTime();
      let startTime = Number(SettingsDataUtils.getSettingsDataWithContext(this.context,
        DISTURB_MODE_TRIGGER_START_TIME, NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY));
      LogUtil.info(`${TAG} onRequest newtime: ${nowTime}  startTime: ${startTime}`);
      if (nowTime - startTime >= ONE_MINUTE || nowTime < startTime) {
        NotDisturbTimerManager.getInstance().refreshTimer();
        return;
      }
      SettingsDataUtils.setSettingsDataWithContext(this.context, FOCUS_MODE_ENABLED,
        NOT_DISTURB_VALUE_ENABLE, settings.domainName.USER_SECURITY);
      let endTime = Number(SettingsDataUtils.getSettingsDataWithContext(this.context,
        DISTURB_MODE_TRIGGER_END_TIME, NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY));
      NotDisturbUtils.reportNotDisturb('on', NotDisturbReportSources.TIMER);
      LogUtil.info(`${TAG} onRequest DISTURB_MODE_TRIGGER_END_TIME endTime: ${endTime}  set focus_mode_enable 1`);
      NotDisturbTimerManager.getInstance().startTimeAlarm(endTime);
    }
  }

  onDestroy() {
    LogUtil.info(`${TAG} onDestroy`);
    GlobalContext.getInstance().remove('TimerContext');
  }
}