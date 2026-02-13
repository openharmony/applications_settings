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

import settings from '@ohos.settings';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SleepTimeNum, SLEEP_KEY_MAP} from '../Constant/Constant';
/* instrument ignore file */
const CHOOSE_SLEEP_RADIO: string = 'choose_sleep_radio';
const TAG: string = 'DormancyRadioController';

export class DormancyRadioController {
  public isChecked: boolean = false;
  public menuTitle: string = '';
  private menuKey: string = '';
  private settingsValue: string = '';

  constructor(compId: string, value: string, isSelected: boolean) {
    this.menuKey = compId;
    this.settingsValue = value;
    this.isChecked = isSelected;
  }

  init(): void {
    let sleepTimeNumber: string = SleepTimeNum.SLEEP_TIME_THIRTY_SECONDS;
    if (SLEEP_KEY_MAP.has(this.menuKey)) {
      sleepTimeNumber = SLEEP_KEY_MAP.get(this.menuKey) as string;
    }
    let formatStr: ResourceStr = $r('app.string.two_minutes');
    if (sleepTimeNumber === SleepTimeNum.SLEEP_TIME_FIFTEEN_SECONDS ||
      sleepTimeNumber === SleepTimeNum.SLEEP_TIME_THIRTY_SECONDS) {
      formatStr = $r('app.string.fifteen_seconds');
    } else if (sleepTimeNumber === SleepTimeNum.SLEEP_TIME_ONE_MINUTE) {
      formatStr = $r('app.string.one_minute');
    }
    this.menuTitle = ResourceUtil.getNumberFormatStringSync(formatStr, sleepTimeNumber);
  }

  public onRadioChange(isChecked: boolean): void {
    LogUtil.showInfo(TAG, `onRadioChange: ${isChecked} value:${this.settingsValue}`);
    this.setRadio(isChecked);
    SettingsDataUtils.setSettingsData(settings.display.SCREEN_OFF_TIMEOUT, this.settingsValue);
    displayDataManager.updateSleepTime();
    HiSysEventUtil.reportRadioEvent(CHOOSE_SLEEP_RADIO, this.settingsValue);
    if (isChecked) {
      AccessibilityUtils.announceRadioSelected();
    }
  }

  private setRadio(isChecked: boolean): void {
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
    }
  }
}