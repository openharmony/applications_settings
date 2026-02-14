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

import emitter from '@ohos.events.emitter';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RadioMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysNfcEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';

/* instrument ignore file */
const TAG: string = 'settingDefaultNFCController : ';
const DEFAULT_PAY_APP = 'nfc_payment_default_app';

export const DEFAULT_PAY_APP_SELECT: number = 300001;

export class SettingDefaultNFCController extends RadioMenuController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }


  static CreateSettingDefaultNFCController(menu: SettingsBaseMenu): Controller {
    return new SettingDefaultNFCController(menu);
  }

  updateStatus(): void {
    let curInput = (this.menu?.extra as extraType).value;
    if (curInput === SettingsDataUtils.getSettingsData(DEFAULT_PAY_APP, '')) {
      this.setRadio(true);
    }
  }

  onRadioChange(isChecked: boolean): void {
    this.setRadio(isChecked);
    SettingsDataUtils.setSettingsData(DEFAULT_PAY_APP, (this.menu?.extra as extraType).value as string);
    LogUtil.info(`onRadioChange ${(this.menu?.extra as extraType).value as string}`)
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNfcEventGroup.UPDATE_DEFAULT_NFC_PAY,
      (this.menu?.extra as extraType).value as string);
    emitter.emit({
      eventId: DEFAULT_PAY_APP_SELECT,
    }, {
      data: {
        DEFAULT_PAY_APP_SELECT: (this.menu?.extra as extraType).value,
      }
    });
    if (isChecked) {
      AccessibilityUtils.announceRadioSelected();
    }
  }

  setRadio(isChecked: boolean): void {
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      this.refreshUi();
    }
  }
}