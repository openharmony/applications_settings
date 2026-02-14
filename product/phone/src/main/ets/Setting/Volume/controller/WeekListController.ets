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
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { NotDisturbTimerPararm } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';

const TAG: string = 'WeekListController';

/**
 * 免打扰定时规则重复选择控制器
 */
export class WeekListController implements ComponentControl {
  private timer: NotDisturbTimerPararm;

  constructor(param: NotDisturbTimerPararm) {
    this.timer = param;
  }

  init(compParam: CompCtrlParam): void {
  };

  destroy(): void {
  };

  updateRepeatText(text: string): void {
    LogUtil.info(`${TAG} weeklist updateRepeatText`);
    this.timer.repeat = text;
  }

  getRepeatType(): number {
    return this.timer.repeatType === undefined ? 0 : this.timer.repeatType;
  }

  getRepeatText(): string {
    return this.timer.repeat === undefined ? '' : this.timer.repeat;
  }
}