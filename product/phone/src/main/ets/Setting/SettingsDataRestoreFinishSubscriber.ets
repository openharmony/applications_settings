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
import StaticSubscriberExtensionAbility from '@ohos.application.StaticSubscriberExtensionAbility';
import commonEventManager from '@ohos.commonEventManager';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NotDisturbUtils } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';

const TAG = 'SettingsDataRestoreFinishSubscriber : ';
const EVENT_SETTINGS_DATA_FINISH: string = 'custom.event.SETTINGS_DATA_RESTORE_FINISH';

type CommonEventData = commonEventManager.CommonEventData;

export default class SettingsDataRestoreFinishSubscriber extends StaticSubscriberExtensionAbility {
  async onReceiveEvent(event: CommonEventData): Promise<void> {
    LogUtil.info(`${TAG} onReceiveEvent.`);
    if (!event?.event) {
      LogUtil.error(`${TAG} onReceiveEvent occurs error`);
      return;
    }
    if (event.event !== EVENT_SETTINGS_DATA_FINISH || !event.data) {
      return;
    }
    AbilityContextManager.setExtContext(this.context);
    if (!CapabilitySupportUtils.isSupportIntelligentScene()) {
      await NotDisturbUtils.handleNotDisturbRestore(event.data);
    }
    AbilityContextManager.setExtContext(undefined);
  }
}