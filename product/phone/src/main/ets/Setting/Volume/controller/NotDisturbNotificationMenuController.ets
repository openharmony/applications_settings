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
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppBundleAndUid } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import { NotDisturbTimerManager } from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';

/**
 * 免打扰通知菜单控制器
 */
export class NotDisturbNotificationMenuController implements ComponentControl {
  async init(compParam: CompCtrlParam): Promise<void> {
    let item = compParam.component as SettingItemModel;
    let count: number = await NotDisturbTimerManager.getInstance().getCurrentTrustAppListCount();
    let res: ResourceStr = await ResourceUtil.getString($r('app.string.none_selected'));
    if (count >= 1) {
      res = $r('app.plural.user_select_app', count, count);
    }
    item.onItemEvent?.(new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
      {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: res }
      } as SettingResultState]]));
  }

  destroy(): void {
  }
}