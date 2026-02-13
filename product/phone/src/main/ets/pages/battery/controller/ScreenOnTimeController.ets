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

import xPowerManager from '@hms.xpower';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { PowerDataFormatUtil } from '@ohos/settings.common/src/main/ets/utils/PowerDataFormatUtil';
import { BusinessError } from '@ohos.base';

export class ScreenOnTimeController extends PageLifecycleMenuGroupController {
  public tag: string = 'ScreenOnTimeController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateScreenOnTimeController(menu: SettingsBaseMenu): Controller {
    return new ScreenOnTimeController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    super.aboutToAppear();
    this.getScreenOnDuration();
  }

  onPageShow() {
    LogUtil.info(`${this.tag} onPageShow`)
    this.getScreenOnDuration();
  }

  private getScreenOnDuration() {
    LogUtil.info(`${this.tag} xPowerManager getScreenOnDuration.`);
    xPowerManager.getScreenOnDuration().then(data => {
      LogUtil.info(`${this.tag} xPowerManager getScreenOnDuration reply data.`);
      this.menu.state = PowerDataFormatUtil.formatTimeMillisToHourMinute(data);
    }).catch((err: BusinessError) => {
      LogUtil.info(`${this.tag} getScreenOnDuration fail, err->${err?.message}`);
    });
  }
}