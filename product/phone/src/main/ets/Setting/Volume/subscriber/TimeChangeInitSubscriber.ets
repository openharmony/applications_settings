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

import StaticSubscriberExtensionAbility from '@ohos.application.StaticSubscriberExtensionAbility';
import commonEventManager from '@ohos.commonEventManager';
import settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { NotDisturbTimerManager } from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { FOCUS_MODE_MANUAL_ENABLE } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
/* instrument ignore file */
const TAG = 'TimeChangeInitSubscriber';
const EVENT_TIME_CHANGED = 'usual.event.TIME_CHANGED';
const EVENT_TIMEZONE_CHANGED = 'usual.event.TIMEZONE_CHANGED';
type CommonEventData = commonEventManager.CommonEventData;

/**
 * Subscriber used to receive common events
 *
 * @since 2024-07-19
 */
export default class TimeChangeInitSubscriber extends StaticSubscriberExtensionAbility {
  async onReceiveEvent(event: CommonEventData): Promise<void> {
    LogUtil.info(`${TAG} receive event: ${event?.event}`);
    let isSupportIntelligentScene = CapabilitySupportUtils.isSupportIntelligentScene();
    if (isSupportIntelligentScene) {
      LogUtil.warn(`${TAG} It supports intelligent scene`);
      return;
    }

    if (!event?.event) {
      LogUtil.error(`${TAG} onReceiveEvent occurs error`);
      return;
    }
    let isManual = SettingsDataUtils.getSettingsDataWithContext(this.context,
      FOCUS_MODE_MANUAL_ENABLE, '0', settings.domainName.USER_PROPERTY) === '1';
    if (isManual) {
      return;
    }
    if (event.event === EVENT_TIME_CHANGED || event.event === EVENT_TIMEZONE_CHANGED) {
      LogUtil.info(`${TAG} onReceiveEvent: refreshTimer`);
      GlobalContext.getInstance().set('TimerContext', this.context);
      NotDisturbTimerManager.getInstance().closeTypeOncesDb(true);
      NotDisturbTimerManager.getInstance().stopAlarm();
      NotDisturbTimerManager.getInstance().refreshTimer();
    }
  }
}