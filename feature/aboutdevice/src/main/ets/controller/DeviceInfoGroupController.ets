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

import { taskpool } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AboutDeviceUtils } from '../utils/AboutDeviceUtils';

export class RunningMemoryController implements ComponentControl {
  private tag: string = 'RunningMemoryController';
  private compId: string = '';

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam.compId;
    try {
      this.refreshUi(AboutDeviceUtils.getRunningMemory());
    } catch (error) {
      LogUtil.error(`${this.tag} hidebug getSystemMemInfo error code: ${error?.code}`);
    }
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'on destroy');
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class StorageCapacityController implements ComponentControl {
  public totalBytes: string = '';
  public usedBytes: string = '';
  public message: string = '';
  private tag: string = 'StorageCapacityController';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} on init`);
    this.compId = compParam.compId;
    this.initial();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
  }

  /**
   * 获取接口数据,总内存及已使用内存
   */
  async initial(): Promise<void> {
    LogUtil.info(`${this.tag} get storage info start`);
    let context: common.Context = ContextUtils.getContext();
    let task: taskpool.Task = new taskpool.Task(getAppInfoStorageAsync, context);
    await taskpool.execute(task, taskpool.Priority.MEDIUM).then(result => {
      let appInfoStorage: string = result as string;
      LogUtil.info(`${this.tag} appInfStorage: ${appInfoStorage}`)
      if (!CheckEmptyUtils.isEmpty(appInfoStorage)) {
        this.refreshUi(appInfoStorage);
      }
    });
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class ScreenResolutionController implements ComponentControl {
  private tag: string = 'ScreenResolutionController';
  private compId: string = '';

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${this.tag} on init`);
    this.compId = compParam.compId;
    try {
      this.refreshUi(await AboutDeviceUtils.getDefaultDisplay());
    } catch (err) {
      LogUtil.showError(this.tag, 'get display error');
    }
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'on destroy');
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class EIDDetailController implements ComponentControl {
  private tag: string = 'EIDDetailController';
  private compId: string = '';

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.showInfo(this.tag, 'on init');
    this.compId = compParam.compId;
    try {
      this.refreshUi(await AboutDeviceUtils.getEID());
    } catch (err) {
      LogUtil.showError(this.tag, 'get eid error');
    }
  }

  destroy(): void {
    LogUtil.showDebug(this.tag, 'on destroy');
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

@Concurrent
export async function getAppInfoStorageAsync(context: common.Context): Promise<string> {
  AbilityContextManager.setSubThreadContext(context);
  return await AboutDeviceUtils.getAppInfoStorage();
}