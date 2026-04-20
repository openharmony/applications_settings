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
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AboutDeviceUtils } from '../utils/AboutDeviceUtils';

export class KernelVersionController implements ComponentControl {
  private tag: string = 'KernelVersionController';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} on init`);
    this.compId = compParam.compId;
    let version: string = AboutDeviceUtils.getKernelVersion();
    this.refreshUi(version);
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

export class OpenHarmonyVersionController implements ComponentControl {
  private tag: string = 'OpenHarmonyVersionController';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} on init`);
    this.compId = compParam.compId;
    let version: string = AboutDeviceUtils.getOpenHarmonyVersion();
    this.refreshUi(version);
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

export class ApiVersionController implements ComponentControl {
  private tag: string = 'ApiVersionController';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} on init`);
    this.compId = compParam.compId;
    let version: string = AboutDeviceUtils.getApiVersion();
    this.refreshUi(version);
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