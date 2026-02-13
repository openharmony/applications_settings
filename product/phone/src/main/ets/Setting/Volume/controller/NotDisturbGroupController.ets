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
  SettingStandardGroupItemsChange,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'NotDisturbGroupController';

/**
 * 声音免打扰Group控制器
 */
export class NotDisturbGroupController implements ComponentControl {
  async init(compParam: CompCtrlParam): Promise<void> {
    let isPrivateSpace: boolean = await AccountUtil.isCurrentPrivate();
    LogUtil.info(`${TAG} refreshVisibleState ${isPrivateSpace}`);
    if (isPrivateSpace) {
      let notDisturbItemIds: string[] = ['not_disturb_mode'];
      notifyCompStateChange('Setting.Volume.not_disturb', new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_STANDARD_GROUP_ITEMS_CHANGE, {
          deleted: true,
          itemIds: notDisturbItemIds
        } as SettingStandardGroupItemsChange]]
      ));
    }
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
  }
}

