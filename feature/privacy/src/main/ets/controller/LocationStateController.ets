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

import { LocationStateChangeListener, LocationUtil } from '../LocationUtil';
import { BusinessError } from '@ohos.base';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'LocationStateController : ';

/**
 * 控制位置入口的位置启用状态展示
 */
export class LocationStateController extends MenuController implements LocationStateChangeListener {
  static CreateLocationStateController(menu: SettingsBaseMenu): Controller {
    return new LocationStateController(menu);
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
    try {
      LocationUtil.getInstance().start();
    } catch (error) {
      LogUtil.error(`${TAG} location service is unavailable: ${(error as BusinessError).message}}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(TAG + 'aboutToDisappear');

    super.aboutToDisappear();
    try {
      LocationUtil.getInstance().stop();
    } catch (error) {
      LogUtil.error(`${TAG} location service is unavailable: ${(error as BusinessError).message}}`);
    }
  }

  onLocationStateChange(state: boolean): void {
    LogUtil.info(TAG + `listener find location service isChanged: ${state}`);
    this.checkLocationState();
    this.refreshUi();
  }

  protected registerDataChange(): void {
    LogUtil.info(TAG + 'registerDataChange');
    try {
      LocationUtil.getInstance().registerStateChangeListener(this);
    } catch (error) {
      LogUtil.error(`${TAG} location service is unavailable: ${(error as BusinessError).message}}`);
    }
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(TAG + 'unRegisterDataChange');
    try {
      LocationUtil.getInstance().unRegisterStateChangeListener(this);
    } catch (error) {
      LogUtil.error(`${TAG} location service is unavailable: ${(error as BusinessError).message}}`);
    }
  }

  updateStatus(): void {
    super.updateStatus();
    this.checkLocationState();
  }

  private checkLocationState(): void {
    try {
      import('@ohos.geoLocationManager').then(geoLocationManager => {
        let state: boolean = geoLocationManager.default.isLocationEnabled();
        LogUtil.info(TAG + `update location service state, state: ${state}`);
        this.menu.state = state ? $r('app.string.location_switch_on_text') : $r('app.string.location_switch_off_text');
        this.refreshUi();
      });
    } catch (err) {
      LogUtil.error(TAG + 'check location api failed');
    }
  }
}
