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

/* instrument ignore file */
import bluetooth from '@ohos.bluetooth';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { BluetoothAdapter, bluetoothPairManager, BluetoothStateChangeListener } from '../BluetoothAdapter';
/* instrument ignore file */
import { Utils } from '../utils/Utils';

/**
 * 蓝牙页面控制器类
 *
 * @since 2022-06-18
 */
export class BluetoothPageController implements ComponentControl, BluetoothStateChangeListener {
  public tag: string = 'BluetoothPageController: ';
  public isPageShow: boolean = false;
  private intervalId: number = 0; // 循环定时器ID

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    this.setDiscoveryConfig();
    this.isPageShow = true;
    this.registerDataChange();
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
    }
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    BluetoothAdapter.getInstance().updateSwitchState();
    this.isPageShow = true;
    BluetoothAdapter.getInstance().isBluetoothPageShow = this.isPageShow;
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
      EventBus.getInstance().emit(`Setting.Bluetooth.SwitchGroup.footer.update`); // 刷新设备名称
    }
    BluetoothAdapter.getInstance().setAutoDiscovery(true);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
    this.isPageShow = false;
    BluetoothAdapter.getInstance().isBluetoothPageShow = this.isPageShow;
    Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE);
    BluetoothAdapter.getInstance().setAutoDiscovery(false);

    // 循环扫描 30s=>2s停止=>30s
    this.intervalId = setInterval(() => {
      BluetoothAdapter.getInstance().startDiscovery()
      setTimeout(() => {
        BluetoothAdapter.getInstance().stopDiscovery()
      }, 30000)
    }, 32000)
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    clearInterval(this.intervalId);
    this.intervalId = 0;
    let isExist: boolean = CommonUtils.isPageExist(NavEntryKey.BLUETOOTH_ENTRY);
    LogUtil.info(`${this.tag} unRegisterDataChange: ${isExist}`);
    if (isExist) {
      LogUtil.info(`${this.tag} the page exist, not destroy`);
      return;
    }

    this.isPageShow = false;
    this.unRegisterDataChange();
    BluetoothAdapter.getInstance().stop();
    BluetoothAdapter.getInstance().onQuit();
  }

  private setDiscoveryConfig(): void {
    LogUtil.info(`${this.tag} setDiscoveryConfig`);
    BluetoothAdapter.getInstance().start();
    bluetoothPairManager.setListener(BluetoothAdapter.getInstance());
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(`${this.tag} onBluetoothStateChange state: ${state}`);
    if (BluetoothUtils.isBluetoothStateOn(state)) {
      if (this.isPageShow) {
        Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
      }
      return;
    }

    if (BluetoothUtils.isBluetoothStateOff(state)) {
      Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE);
    }
  }

  getListenKey(): string {
    return 'Bluetooth_Page_Controller';
  }

  private registerDataChange(): void {
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().registerStateChangeListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
  }
}
