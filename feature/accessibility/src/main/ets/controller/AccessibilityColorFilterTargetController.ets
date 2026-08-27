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

import config from '@ohos.accessibility.config';
import { BusinessError } from '@ohos.base';
import { RadioMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
export enum SelectColorFilterValue {
  NORMAL = 'Normal',
  PROTANOMALY = 'Protanomaly',
  DEUTERANOMALY = 'Deuteranomaly',
  TRITANOMALY = 'Tritanomaly',
}

const TAG: string = 'AccessibilityColorFilterTargetController : ';

export class AccessibilityColorFilterTargetController extends RadioMenuController {
  static CreateAccessibilityColorFilterTargetController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityColorFilterTargetController(menu);
  }

  onRadioChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} onRadioChange: ${isChecked}`);
    let targetName: config.DaltonizationColorFilter;
    this.setRadio(isChecked);
    if (this.menu.extra) {
      targetName = this.menu.extra as config.DaltonizationColorFilter;
    } else {
      targetName = SelectColorFilterValue.NORMAL;
      LogUtil.error(`${TAG} get color filter state fail`);
    }
    config.daltonizationColorFilter.set(targetName).then(() => {
      LogUtil.info(`${TAG} accessibilityConfigSetting color filter success: ${targetName}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityConfigSetting color filter fail: ${targetName} err: ${err?.message}`);
    });
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.CHOOSE_COLOR_FILTER_RADIO, targetName);
    this.closeSelf(this.menu.title);
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    config.daltonizationColorFilter.get().then((data: config.DaltonizationColorFilter) => {
      let selectColorFilter = data;
      if (selectColorFilter === this.menu.extra) {
        this.setRadio(true);
        LogUtil.info(`${TAG} setRadio success`);
      }
      LogUtil.info(`${TAG} get color filter success`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get color filter, because：${err?.message}`);
    });
  }
}