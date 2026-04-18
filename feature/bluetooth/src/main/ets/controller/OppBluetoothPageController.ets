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
import { UIExtensionContentSession } from '@kit.AbilityKit';
import bluetooth from '@ohos.bluetooth';
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  SettingPageModel,
  SettingSheetTitleIcon
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import {
  BluetoothAdapter,
  bluetoothPairManager,
  BluetoothStateChangeListener
} from '../BluetoothAdapter';
import { Utils } from '../utils/Utils';

/**
 * 半模态蓝牙页面控制器类
 *
 * @since 2025-02-12
 */
export class OppBluetoothPageController implements ComponentControl, BluetoothStateChangeListener {
  public tag: string = 'OppBluetoothPageController: ';
  public isPageShow: boolean = false;
  private settingPageModel?: SettingPageModel;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!compParam || !compParam.compId || !compParam.component) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    if (!this.settingPageModel) {
      LogUtil.error(`${this.tag} init fail, settingPageModel is invalid`);
      return;
    }
    this.setDiscoveryConfig();
    this.isPageShow = true;
    this.registerDataChange();
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
    }
    this.setCloseIcon();
    this.setBackIcon();
    this.settingPageModel.showBackIcon = true;
  }

  setCloseIcon(): void {
    LogUtil.info(`${this.tag} setCloseIcon`);
    let closeIcon: SettingSheetTitleIcon = {
      icon: $r('app.media.ic_close'),
      action: () => {
        this.closeSheetPage();
      }
    }
    if (this.settingPageModel) {
      this.settingPageModel.closeIconAction = closeIcon;
    }
  }

  setBackIcon(): void {
    LogUtil.info(`${this.tag} setBackIcon`);
    let backIcon: SettingSheetTitleIcon = {
      icon: $r('sys.symbol.chevron_backward'),
      action: () => {
        this.backSheetPage();
      }
    }
    if (this.settingPageModel) {
      this.settingPageModel.backIconAction = backIcon;
    }
  }

  async closeSheetPage(): Promise<void> {
    LogUtil.info(`${this.tag} closeSheetPage`);
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (session === undefined) {
      return;
    }
    session.sendData({
      action: 'closeSheet',
    });
    session.terminateSelf();
  }

  async backSheetPage(): Promise<void> {
    LogUtil.info(`${this.tag} backSheetPage`);
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (session === undefined) {
      return;
    }
    session.sendData({
      action: 'backSheet',
    });
    session.terminateSelf();
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.isPageShow = true;
    BluetoothAdapter.getInstance().isBluetoothPageShow = this.isPageShow;
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
      EventBus.getInstance().emit(`Setting.Bluetooth.SwitchGroup.footer.update`); // 刷新设备名称
    }
    BluetoothAdapter.getInstance().setAutoDiscovery(true);
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
    this.isPageShow = false;
    BluetoothAdapter.getInstance().isBluetoothPageShow = this.isPageShow;
    Utils.setBluetoothScanMode(bluetooth.ScanMode.SCAN_MODE_CONNECTABLE);
    BluetoothAdapter.getInstance().setAutoDiscovery(false);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    this.unRegisterDataChange();
    BluetoothAdapter.getInstance().stop();
    BluetoothAdapter.getInstance().onQuit();
  }

  private setDiscoveryConfig(): void {
    LogUtil.info(`${this.tag} setDiscoveryConfig`);
    this.isPageShow = true;
    BluetoothAdapter.getInstance().isBluetoothPageShow = this.isPageShow;
    BluetoothAdapter.getInstance().start();
    BluetoothAdapter.getInstance().setAutoDiscovery(true);
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
    return 'Opp_Bluetooth_Page_Controller';
  }

  private registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().registerStateChangeListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
  }
}