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

import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { OppBluetoothPageController } from '@ohos/settings.bluetooth/src/main/ets/controller/OppBluetoothPageController';
import { BluetoothSwitchController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothSwitchController';
import { OppBondedDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/OppBondedDeviceController';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { OppAvailableDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/OppAvailableDeviceController';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
/* instrument ignore file */
/**
 * 蓝牙半模态页面控制器类
 *
 * @since 2025-02-12
 */
export class OppBluetoothPhonePageController extends OppBluetoothPageController {
  public tag: string = 'OppBluetoothPhonePageController: ';
  private switchController: BluetoothSwitchController;
  private oppBondedDeviceController: OppBondedDeviceController;
  private oppAvailableDeviceController: OppAvailableDeviceController;

  constructor(switchController: BluetoothSwitchController, oppBondedDeviceController: OppBondedDeviceController,
    oppAvailableDeviceController: OppAvailableDeviceController) {
    super();
    this.switchController = switchController;
    this.oppBondedDeviceController = oppBondedDeviceController;
    this.oppAvailableDeviceController = oppAvailableDeviceController;
    LogUtil.info(`${this.tag} constructor`);
  }

  private pageShowEventCb = (data: object) => {
    LogUtil.info(`${this.tag} pageShowEventCb`);
    this.onPageShow();
  };
  private pageHideEventCb = (data: object) => {
    LogUtil.info(`${this.tag} pageHideEventCb`);
    this.onPageHide();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    super.init(compParam);
    EventBus.getInstance().on('pageShow', this.pageShowEventCb);
    EventBus.getInstance().on('pageHide', this.pageHideEventCb);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    super.destroy();
    EventBus.getInstance().detach('pageShow', this.pageShowEventCb);
    EventBus.getInstance().detach('pageHide', this.pageHideEventCb);
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    BluetoothAdapter.getInstance().updateSwitchState();
    super.onPageShow();
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      BluetoothAdapter.getInstance().updateBondedDevices();
      BluetoothAdapter.getInstance().updatePairingState();
    }

    this.switchController?.onPageShow();
    this.oppAvailableDeviceController?.onPageShow();
    this.oppBondedDeviceController?.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
    super.onPageHide();
    this.oppAvailableDeviceController?.onPageHide();
  }
}