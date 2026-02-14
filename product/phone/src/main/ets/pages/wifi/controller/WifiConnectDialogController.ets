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

import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { wifiTracker } from '@ohos/settings.wifi';
import wifiManager from '@ohos.wifiManager';

const TAG: string = 'WifiPasswordButtonMenuController : ';

export const CONNECT_CANCEL: string = 'isConnectCancel';

export class WifiConnectDialogController extends MenuController implements DialogLifecycleObserverInterface {
  public getObserverKey?: () => string = (): string => {
    return this.menu?.key as string;
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateWifiConnectDialogController(menu: SettingsBaseMenu): Controller {
    return new WifiConnectDialogController(menu);
  }

  onDialogClose(key?: string, data?: Object): void {
  }

  onDialogCancel(key?: string, data?: Object): void {
    LogUtil.info(`${TAG} onDialogCancel key :${key}`);

    // dialog和page不是同一个pageRoot，无法注册Controller监听
    AppStorage.setOrCreate<Boolean>(CONNECT_CANCEL, true);
    wifiTracker.removeWifiDevice(this.menu.extra as wifiManager.WifiDeviceConfig);
  }

  onDialogOpen(key?: string, data?: Object): void {
  }
}