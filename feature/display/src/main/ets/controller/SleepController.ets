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

import { RadioMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import Settings from '@ohos.settings';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';

export enum SleepKey {
  ENTER_DORMANCY_ENTRY = 'enter_dormancy_entry',
  FIFTEEN_SECONDS_KEY = 'fifteen_seconds_dormancy',
  THIRTY_SECONDS_KEY = 'thirty_seconds_dormancy',
  ONE_MINUTE_KEY = 'one_minute_dormancy',
  TWO_MINUTES_KEY = 'two_minutes_dormancy',
  FIVE_MINUTES_KEY = 'five_minutes_dormancy',
  TEN_MINUTES_KEY = 'ten_minutes_dormancy',
}

export enum SleepTime {
  FIFTEEN_SECONDS = '15000',
  THIRTY_SECONDS = '30000',
  ONE_MINUTE = '60000',
  TWO_MINUTES = '120000',
  FIVE_MINUTES = '300000',
  TEN_MINUTES = '600000',
  NEVER_SLEEP = '-1',
}

const SLEEP_TIME_FIFTEEN_SECONDS = '15';
const SLEEP_TIME_THIRTY_SECONDS = '30';
const SLEEP_TIME_ONE_MINUTE = '1';
const SLEEP_TIME_TWO_MINUTES = '2';
const SLEEP_TIME_FIVE_MINUTES = '5';
const SLEEP_TIME_TEN_MINUTES = '10';

const CHOOSE_SLEEP_RADIO: string = 'choose_sleep_radio';

export class SleepController extends RadioMenuController {
  static CreateSleepController(menu: SettingsBaseMenu): Controller {
    return new SleepController(menu);
  }

  public tag: string = 'SleepController : ';

  aboutToAppear(): void {
    super.aboutToAppear();
    switch (this.menu.key) {
      case SleepKey.FIFTEEN_SECONDS_KEY:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.fifteen_seconds'), SLEEP_TIME_FIFTEEN_SECONDS);
        break;
      case SleepKey.THIRTY_SECONDS_KEY:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.thirty_seconds'), SLEEP_TIME_THIRTY_SECONDS);
        break;
      case SleepKey.ONE_MINUTE_KEY:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.one_minute'), SLEEP_TIME_ONE_MINUTE);
        break;
      case SleepKey.TWO_MINUTES_KEY:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.two_minutes'), SLEEP_TIME_TWO_MINUTES);
        break;
      case SleepKey.FIVE_MINUTES_KEY:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.five_minutes'), SLEEP_TIME_FIVE_MINUTES);
        break;
      case SleepKey.TEN_MINUTES_KEY:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.ten_minutes'), SLEEP_TIME_TEN_MINUTES);
        break;
      default:
        this.menu.title = ResourceUtil.getNumberFormatStringSync($r('app.string.fifteen_seconds'), SLEEP_TIME_THIRTY_SECONDS);
    }
    this.refreshUi();
  }

  onRadioChange(isChecked: boolean): void {
    LogUtil.info('onRadioChange' + isChecked);
    this.setRadio(isChecked);
    let milliSeconds: string = this.menu.extra as string;
    LogUtil.info(this.tag + 'milliSeconds: ' + milliSeconds);
    SettingsDataUtils.setSettingsData(Settings.display.SCREEN_OFF_TIMEOUT, milliSeconds);
    displayDataManager.updateSleepTime();
    HiSysEventUtil.reportRadioEvent(CHOOSE_SLEEP_RADIO, milliSeconds);
  }

  updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus`);
    let dormancyTime = SettingsDataUtils.getSettingsData(Settings.display.SCREEN_OFF_TIMEOUT,
      SleepTime.THIRTY_SECONDS);
    if (dormancyTime == this.menu.extra) {
      this.setRadio(true);
    }
  }
}