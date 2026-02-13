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
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ItemResultType,
  SettingToggleModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NotDisturbTimerPararm } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import { ToggleMenuController } from './VolumeController';

const TAG: string = 'TimerStatusController';

/**
 * 免打扰定时规则开关控制器
 */
export class TimerStatusController extends ToggleMenuController implements ComponentControl {
  private timer: NotDisturbTimerPararm;
  private compId: string = '';

  constructor(param: NotDisturbTimerPararm) {
    super();
    this.timer = param;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.compId = compParam.compId;
    this.setChecked(false);

    EventBus.getInstance().on(`${this.compId}.toggle`, (param: object) => {
      let toggleState: SettingToggleModel = param as SettingToggleModel;
      let isChecked: boolean = !!(toggleState?.state);
      this.setChecked(isChecked);
      this.timer.isOpen = isChecked;

      LogUtil.info(`${TAG} is open ${this.timer.isOpen}`);
    });
  }

  destroy(): void {
    EventBus.getInstance().off(`${this.compId}.toggle`);
  }

  protected refreshUi(): void {
    notifyCompStateChange(`${this.compId}.toggle`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.isChecked } } as SettingResultState]]));
  }
}
