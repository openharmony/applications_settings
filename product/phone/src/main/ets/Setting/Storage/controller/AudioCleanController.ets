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

import { dataSharePredicates } from '@kit.ArkData';
import { taskpool } from '@kit.ArkTS';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FILE_MANAGER_AUDIO_QUERY_URI, StorageDataShareUtil } from '../Utils/StorageDataShareUtil';
/* instrument ignore file */
const TAG: string = 'AudioCleanController';

export class AudioCleanController implements ComponentControl {
  private compId: string = '';

  init(compParam: CompCtrlParam) {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${TAG} init compId: ${this.compId}`)
    this.updateAudioDataSize();
  }

  private updateAudioDataSize: () => Promise<void> = async () => {
    let task: taskpool.Task = new taskpool.Task(queryAudioDataSize, getContext());
    taskpool.execute(task, taskpool.Priority.MEDIUM).then((audioSize) => {
      LogUtil.info(`${TAG} updateAudioDataSize got size from fileManager: ${audioSize}`);
      if (!audioSize) {
        return;
      }
      notifyCompStateChange(this.compId,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: audioSize } } as SettingResultState]]));
    })
  }

  destroy() {
    LogUtil.info(`${TAG} destroy`);
  }
}

/**
 * 并发查询音频数据大小
 *
 * @param context 上下文
 * @returns 文管接口返回音频数据大小
 */
@Concurrent
async function queryAudioDataSize(context: Context): Promise<string | undefined> {
  let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
  return await StorageDataShareUtil.queryDataByOneColumn(FILE_MANAGER_AUDIO_QUERY_URI, predicates, 'cardInfo', context);
}