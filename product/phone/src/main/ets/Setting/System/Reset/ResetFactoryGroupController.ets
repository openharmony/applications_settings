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

import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
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

/* instrument ignore file */
const TAG = 'ResetFactoryController: ';

export class ResetFactoryGroupController implements ComponentControl {
  private compId?: string;

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.showInfo(TAG, 'onInit');
    if (!compParam || !compParam.component) {
      LogUtil.showInfo(TAG, 'init failed, component is empty');
      return;
    }
    this.compId = compParam.compId;
    AccountUtil.isCurrentPrivate().then(result => {
      let isPrivacy: boolean = result;
      LogUtil.showInfo(TAG, `isPrivacy is ${isPrivacy}`);
      this.showOrHideGroup(!isPrivacy);
    })
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.showInfo(TAG, `showOrHideGroup: ${isShow}, id is ${this.compId}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  destroy(): void {
  }
}