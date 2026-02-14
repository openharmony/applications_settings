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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LocationStateChangeListener, LocationUtil } from '../LocationUtil';

const ALOW_LOCATION_INFORMATION: string = 'alow_location_information';
const TAG: string = 'LocationServiceController : ';

export class LocationServiceController extends SwitchMenuController implements LocationStateChangeListener {
  static CreateLocationServiceController(menu: SettingsBaseMenu): Controller {
    return new LocationServiceController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  aboutToAppear(): void {
    LogUtil.info(TAG + 'aboutToAppear');

    super.aboutToAppear();
    LocationUtil.getInstance().start();
  }

  onLocationStateChange(state: boolean): void {
    LogUtil.info(TAG + `listener find location service isChanged: ${state}`);
    let currentState: boolean = this.getAndUpdateServiceState();
    this.setChecked(currentState);
    this.refreshUi();
  }

  protected registerDataChange(): void {
    LogUtil.info(TAG + 'registerDataChange');
    LocationUtil.getInstance().registerStateChangeListener(this);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(TAG + 'unRegisterDataChange');
    LocationUtil.getInstance().unRegisterStateChangeListener(this);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    LogUtil.info(TAG + 'enter updateCheckedState...');
    return this.getAndUpdateServiceState();
  }

  private getAndUpdateServiceState(): boolean {
    try {
      import('@ohos.geoLocationManager').then(geoLocationManager => {
        let state: boolean = geoLocationManager.default.isLocationEnabled();
        LogUtil.info(TAG + `update location service state, state: ${state}`);
        return state;
      });
    } catch (err) {
      LogUtil.error(TAG + 'check location api failed');
    }
    return false;
  }

  /**
   * 开关变化的回调，这一步返回值是表示事件是否被处理，而不是开关的状态
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(TAG + 'enter handleCheckedChange...');

    if (isChecked) {
      LocationUtil.getInstance().enableLocation();
      HiSysEventUtil.reportSwitchEvent(ALOW_LOCATION_INFORMATION, 'on');
    } else {
      LocationUtil.getInstance().disableLocation();
      HiSysEventUtil.reportSwitchEvent(ALOW_LOCATION_INFORMATION, 'off');
    }
    return true;
  }

}
