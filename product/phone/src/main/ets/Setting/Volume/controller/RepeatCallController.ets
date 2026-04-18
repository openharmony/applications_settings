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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { RepeatRingController } from './RepeatRingController';

const TAG: string = 'RepeatCallController: ';

/**
 * 重复来电菜单控制器
 */
export class RepeatCallController implements ComponentControl {
  private compId?: string;
  private dataSource?: DynamicDataSource;

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init`);
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as DynamicDataSource;

    let repeatCallItem = {
      id: 'repeat_ringing',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.repeat_call_ringing') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: RepeatRingController.updateCheckedState(),
        },
      },
      compControl: new RepeatRingController(),
    } as SettingItemModel;
    this.dataSource?.pushData(repeatCallItem);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destory`);
  }
}