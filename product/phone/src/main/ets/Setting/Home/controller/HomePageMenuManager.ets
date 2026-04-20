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

import taskpool from '@ohos.taskpool';
import access from '@ohos.bluetooth.access';
import bundleManager from '@ohos.bundle.bundleManager';
import deviceInfo from '@ohos.deviceInfo';
import distributedAccount from '@ohos.account.distributedAccount';
import Settings from '@ohos.settings';
import { DeviceUtil, SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { homeInitData, HomeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import lazy { DefaultName, DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import lazy { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { EthernetUtil } from '@ohos/settings.network/src/main/ets/util/EthernetUtil';

const PRODUCT_MODEL: string = 'const.product.model';
const PRODUCT_MODEL_EMULATOR: string = 'emulator';
const PRODUCT_DEVICE_TYPE: string = 'const.product.devicetype';
const PRODUCT_CPU_ABILITST: string = 'const.product.cpu.abilist';
const PRODUCT_DEVICE_TYPE_PHONE: string = 'phone';
const PRODUCT_CPU_ABILITST_X86_64: string = 'x86_64';

@Concurrent
function isBundleExist(homeInitData: HomeInitData, bundleName: string): void {
  let support: boolean = false;
  try {
    bundleManager.getBundleInfoSync(bundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    support = true;
  } catch (err) {
    LogUtil.showError('HomePageMenuManager', `check bundle ${bundleName} exist error: ${err?.message}`);
  }
  if (bundleName === 'com.ohos.vassistant') {
    homeInitData.supportVassistant = support;
  } else if (bundleName === 'com.ohos.hiwrite') {
    homeInitData.supportHiWrite = support;
  }
  LogUtil.showInfo('initHomeData', `${bundleName} support result is ${support}`);
}

@Concurrent
async function isMainOsAccount(homeInitData: HomeInitData): Promise<void> {
  try {
    let ns = await import('@ohos.account.osAccount');
    homeInitData.isMainAccount = await ns.default.getAccountManager().isMainOsAccount() as boolean;
  } catch (err) {
    LogUtil.showError('HomePageMenuManager', `get is main os account error: ${err?.message}`);
  }
  LogUtil.showInfo('initHomeData', `isMainOsAccount ${homeInitData.isMainAccount}`);
}

@Concurrent
export function initBluetoothState(homeInitData: HomeInitData, context: Context): void {
  if (CapabilitySupportUtils.isSupportFusion()) {
    // homeInitData.fusionState = FusionUtil.getState();
    // LogUtil.showInfo('initHomeData', `fusion state is ${homeInitData.fusionState}`);
  } else {
    const SWITCH_ON_VAL: string = '1';
    const SWITCH_OFF_VAL: string = '0';
    let bluetoothState: access.BluetoothState = access.BluetoothState.STATE_OFF;
    try {
      bluetoothState = access.getState();
    } catch (e) {
      LogUtil.error(` initHomeData get bluetoothState error error.code ${e?.code} error.message ${e?.message}`);
    }
    if (bluetoothState === access.BluetoothState.STATE_ON) {
      homeInitData.bluetoothState = true;
    }
    LogUtil.showInfo('initHomeData', `bluetoothState is ${homeInitData.bluetoothState}`);
  }
}

@Concurrent
async function initDeviceName(homeInitData: HomeInitData, context: Context) {
  try {
    let time: string = new Date().getTime().toString();
    let newDeviceName: string | undefined = DeviceNameUtil.getDeviceNameAsync()
    if (!newDeviceName) {
      return;
    }
    homeInitData.deviceName = newDeviceName;
    DeviceNameUtil.updateHotspotName(newDeviceName);
    DeviceNameUtil.releaseDeviceManager();
    LogUtil.showInfo('initHomeData', `deviceName is ${LogMaskUtil.getLogNickNameString(newDeviceName)}`);
  } catch (error) {
    LogUtil.showError('initHomeData', `initDeviceName failed ：code: ${error?.code} message: ${error?.message}`);
  }
}

@Concurrent
function initWifiState(homeInitData: HomeInitData) {
  homeInitData.wifiState = WifiUtils.isWifiActive();
  LogUtil.showInfo('initHomeData', `wifiState is ${homeInitData.wifiState}`);
}

@Concurrent
function initHiWriteState(homeInitData: HomeInitData, context: Context) {
  const STATE_KEY = 'stylus_enable';
  const STATE_ON_FLAG = '1';
  homeInitData.hiWriteState = SettingsDataUtils.getSettingsDataWithContext(context, STATE_KEY, STATE_ON_FLAG);
  LogUtil.showInfo('initHiWriteState', `hiWriteState is ${homeInitData.hiWriteState}`);
}

export class HomePageMenuManager {
  private static menuManager: HomePageMenuManager | undefined = undefined;
  private static productModel: string = SystemParamUtil.getParam(PRODUCT_MODEL, '');
  private static productDeviceType: string = SystemParamUtil.getParam(PRODUCT_DEVICE_TYPE, '');
  private static productCpuAbilist: string = SystemParamUtil.getParam(PRODUCT_CPU_ABILITST, '');

  public static getInstance(): HomePageMenuManager {
    if (HomePageMenuManager.menuManager) {
      return HomePageMenuManager.menuManager;
    }
    HomePageMenuManager.menuManager = new HomePageMenuManager();
    return HomePageMenuManager.menuManager;
  }

  public async initHomeData(context: Context): Promise<void> {
    LogUtil.showInfo('initHomeData1', 'begin');
    try {
      let group: taskpool.TaskGroup = new taskpool.TaskGroup();
      group.addTask(isMainOsAccount, homeInitData);
      group.addTask(initBluetoothState, homeInitData, context);
      group.addTask(initWifiState, homeInitData);
      group.addTask(initDeviceName, homeInitData, context);
      group.addTask(initHiWriteState, homeInitData, context);
      group.addTask(isBundleExist, homeInitData, 'com.ohos.vassistant');
      group.addTask(isBundleExist, homeInitData, 'com.ohos.hiwrite');
      taskpool.execute(group, taskpool.Priority.HIGH);
      LogUtil.showInfo('initHomeData', 'end');
    } catch (error) {
      LogUtil.showError('initHomeData', `initHomeData fail: ${error?.message}`);
    }
  }

  public isEntryNotSupported(): boolean {
    return HomePageMenuManager.productModel === PRODUCT_MODEL_EMULATOR;
  }

  public isPhoneEntryNotSupported(): boolean {
    return HomePageMenuManager.productModel === PRODUCT_MODEL_EMULATOR &&
      HomePageMenuManager.productDeviceType === PRODUCT_DEVICE_TYPE_PHONE;
  }

  public isSatelliteNotSupport(): boolean {
    if (AppStorage.get('isMainAccount') === undefined || AppStorage.get('isMainAccount') === true) {
      LogUtil.info(`isSatelliteNotSupport appStorage get is undefined or result is true`);
      return HomePageMenuManager.productModel === PRODUCT_MODEL_EMULATOR || !SatelliteUtils.isSupport();
    }
    return true;
  }

  public isAssistantNotSupport(): boolean {
    LogUtil.showInfo('isAssistantNotSupport', `${homeInitData.supportVassistant}`);
    let isAssistantNotSupport: boolean = HomePageMenuManager.productModel === PRODUCT_MODEL_EMULATOR;
    if (homeInitData.supportVassistant === undefined) {
      isBundleExist(homeInitData, 'com.ohos.vassistant');
    }
    isAssistantNotSupport = isAssistantNotSupport || !homeInitData.supportVassistant;
    return isAssistantNotSupport;
  }

  public isTouchpadNotSupport(): boolean {
    let isTouchpadNotSupport = SystemParamUtil.getParam('const.settings.touchpad_support', 'false') === 'true';
    let isDeviceNotSupport: boolean = HomePageMenuManager.productDeviceType === PRODUCT_DEVICE_TYPE_PHONE;
    if (!isTouchpadNotSupport) {
      isDeviceNotSupport = true;
    }
    return isDeviceNotSupport;
  }

  public isHiWriteNotSupport(): boolean {
    if (DeviceUtil.isDevicePhone()) {
      return true;
    }
    let isHiWriteNotSupport: boolean = HomePageMenuManager.productModel === PRODUCT_MODEL_EMULATOR;
    if (homeInitData.supportHiWrite === undefined) {
      isBundleExist(homeInitData, 'com.ohos.hiwrite');
    }
    isHiWriteNotSupport = isHiWriteNotSupport || !homeInitData.supportHiWrite;
    return isHiWriteNotSupport;
  }

  /**
   * 移动网络页面不支持
   *
   * @returns true, 移动网络页面不支持
   */
  public isMobileNetworkPageNotSupport(): boolean {
    let isMobileNetworkNotSupport: boolean =
      EthernetUtil.useNewNetworkPage() || HomePageMenuManager.productModel === PRODUCT_MODEL_EMULATOR;
    return isMobileNetworkNotSupport;
  }

  /**
   * 融合PC网络页面不支持
   *
   * @returns true, 融合PC网络页面不支持
   */
  public isNetworkPageNotSupport(): boolean {
    return !EthernetUtil.useNewNetworkPage();
  }
}