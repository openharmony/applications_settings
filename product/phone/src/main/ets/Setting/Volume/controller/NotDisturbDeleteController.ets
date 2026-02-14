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
import settings from '@ohos.settings';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { NotDisturbTimerPararm } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import {
  FOCUS_MODE_TIMER,
  NotDisturbTimerManager
} from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { FOCUS_MODE_MANUAL_ENABLE,
  NOT_DISTURB_VALUE_DISABLE } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';

const SETTINGSDATA_UPDATE_TIMEOUT: number = 20;

/**
 * 免打扰定时规则删除控制器
 */
export class NotDisturbDeleteController implements ComponentControl {
  public tag: string = 'NotDisturbDeleteController: ';
  private timer: NotDisturbTimerPararm;

  constructor(timer: NotDisturbTimerPararm) {
    this.timer = timer;
  }

  init(compParam: CompCtrlParam): void {
  }

  destroy(): void {
  }

  onDialogClick(): void {
    if (!this.timer) {
      return;
    }
    let context = NotDisturbTimerManager.getContext();
    let zenTimers: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(context);
    const index: number = zenTimers.findIndex((value: NotDisturbTimerPararm) => {
      return this.timer.id === value.id;
    });
    LogUtil.info(`${this.tag} index: ${index}`);
    if (index < 0) {
      return;
    }
    zenTimers.splice(index, 1);
    let count: number = this.timer.id;
    zenTimers.forEach((item) => {
      if (item.id <= this.timer.id) {
        return;
      }
      item.id = count;
      count++;
    });
    SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER, JSON.stringify(zenTimers),
      settings.domainName.USER_PROPERTY);
    let isNotMaunalTurnOn: boolean = SettingsDataUtils.getSettingsData(FOCUS_MODE_MANUAL_ENABLE,
      NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_DISABLE;
    if (isNotMaunalTurnOn) {
      NotDisturbTimerManager.getInstance().refreshTimer(false, zenTimers);
    }
    LogUtil.info(`${this.tag} onMenuClick ${this.timer}`);
    setTimeout(() => {
      PageRouter.pop('Setting');
    }, SETTINGSDATA_UPDATE_TIMEOUT);
  }
}
