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
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import emitter from '@ohos.events.emitter';
import { EVENT_ID_ENTERPRISE_MENU_HIDE } from '@ohos/settings.common/src/main/ets/event/types';

const TAG = 'DeviceAndApplicationController: ';

export class DeviceAndApplicationController implements ComponentControl {

  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    emitter.off(EVENT_ID_ENTERPRISE_MENU_HIDE);
    emitter.on({
      eventId: EVENT_ID_ENTERPRISE_MENU_HIDE
    }, (eventData: emitter.EventData) => {
      notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: false } as SettingCompState]]
      ));
    })
  }

  destroy(): void {
    emitter.off(EVENT_ID_ENTERPRISE_MENU_HIDE);
  }
}