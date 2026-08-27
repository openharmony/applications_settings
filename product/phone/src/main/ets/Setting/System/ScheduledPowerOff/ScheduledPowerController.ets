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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SystemPageMenuManager } from '../controller/SystemPageMenuManager';

const TAG = 'ScheduledPowerController: ';

export class ScheduledPowerController implements ComponentControl {
  private compId?: string;

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.showInfo(TAG, 'onInit');
    if (!compParam || !compParam.component) {
      LogUtil.showInfo(TAG, 'init failed, component is empty');
      return;
    }
    this.compId = compParam.compId;
    SystemPageMenuManager.getInstance().isScheduledPowerSupport().then(isSupport => {
      if (!isSupport) {
        this.hideScheduledPowerGroup();
      }
    });
  }

  private hideScheduledPowerGroup(): void {
    LogUtil.showInfo(TAG, `hideScheduledPowerGroup, id is ${this.compId}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: false } as SettingCompState]]
    ));
  }

  destroy(): void {
  }
}