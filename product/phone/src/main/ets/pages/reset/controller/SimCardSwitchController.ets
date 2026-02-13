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

import data from '@ohos.telephony.data';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RadioMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { ResourceUtil} from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

/* instrument ignore file */
const TAG: string = 'SimCardSwitchController : ';
const BLANK: string = '_';
const SIM_CHECK_KEY = 'sim_check';
const SLOT_ID_UNDEFINED: number = -1;

export class SimCardSwitchController extends RadioMenuController {
  public defaultSlotId = SLOT_ID_UNDEFINED;

  static createSimCardSwitchController(menu: SettingsBaseMenu): Controller {
    return new SimCardSwitchController(menu);
  }

  onRadioChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} onRadioChange, isChecked=${isChecked}`);
    this.setRadio(isChecked);
    let simIds = (this.menu.extra as string).split(BLANK);
    let simId = simIds[0];
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.CHOOSE_PHONE_CARD, simId);
    if (isChecked) {
      AccessibilityUtils.announceText(ResourceUtil.getStringSync($r('app.string.be_chosen')));
    }
    SettingsDataUtils.setSettingsData(SIM_CHECK_KEY, simId);
  }

  async updateStatus(): Promise<void> {
    let simIds = (this.menu.extra as string).split(BLANK);
    this.defaultSlotId = await data.getDefaultCellularDataSlotId();
    LogUtil.info(`${TAG} defaultSlotId is ${this.defaultSlotId}`);
    let simId = simIds[0];
    if (this.defaultSlotId == parseInt(simId)) {
      this.setRadio(true);
      // 首次进入初始化，默认选择sim卡
      SettingsDataUtils.setSettingsData(SIM_CHECK_KEY, simId);
    }
  }
}