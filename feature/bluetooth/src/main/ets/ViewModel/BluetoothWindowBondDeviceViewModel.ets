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

import access from '@ohos.bluetooth.access';
import preferences from '@ohos.data.preferences';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  NUMBER_CLOSE,
  NUMBER_OPEN,
  WIRELESS_ANTI_THEFT_HOST_ADDRESS_KEY,
  WIRELESS_ANTI_THEFT_KEY,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { EncryptUtils } from '@ohos/settings.common/src/main/ets/utils/EncryptUtils';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  BluetoothAdapter,
  BluetoothBondChangeListener,
  BluetoothBondedDeviceChangeListener,
  BluetoothDeviceChangeListener,
  BluetoothDeviceNameUpdateListener,
  BluetoothProfileStateChangeListener,
  BluetoothStateChangeListener
} from '../BluetoothAdapter';
import {
  BluetoothDevice,
  BondState,
  BondStateParam,
  PinRequiredParam,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam,
} from '../model/BluetoothModel';
import { MenuEntry, MenuEntryData } from '../model/MenuEntry';

/* instrument ignore file */
export const BONDED_DEVICE_TIME_FLAG: number = -2000000000000;

@Observed
export class BluetoothWindowBondDeviceViewModel implements BluetoothBondChangeListener, BluetoothDeviceChangeListener,
BluetoothProfileStateChangeListener, BluetoothStateChangeListener, BluetoothDeviceNameUpdateListener,
BluetoothBondedDeviceChangeListener {
  public tag: string = 'BluetoothWindowBondDeviceViewModel : ';
  public bondDevicesMenu: MenuEntry[] = [];
  // 无线防盗标志位
  private isWirelessAntiTheft: boolean = false;
  private wirelessAntiTheftHostAddress: string = '';

  getListenKey(): string {
    return 'Bluetooth_Window_Bond_Device_View_Model';
  }

  init(bondDevicesMenu: MenuEntry[]): void {
    LogUtil.info(`${this.tag} init`);
    this.bondDevicesMenu = bondDevicesMenu;
    this.registerDataChange();
    // 无线防盗相关 (必须写在 updateBondedDevices 前面)
    this.isWirelessAntiTheft = this.getWirelessAntiTheftState();
    if (this.isWirelessAntiTheft) {
      this.wirelessAntiTheftHostAddress = this.getWirelessAntiTheftHostAddress();
    }
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      this.updateBondedDevices();
    }
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    this.bondDevicesMenu.splice(0, this.bondDevicesMenu.length);
    this.unRegisterDataChange();
  }

  /**
   * 获取当前系统设置中的无线防盗,默认false
   */
  private getWirelessAntiTheftState(): boolean {
    // 获取当前系统设置中的允许休眠时通知开关的状态,默认false
    const wirelessAntiTheftState: string = SettingsDataUtils.getSettingsData(WIRELESS_ANTI_THEFT_KEY, NUMBER_CLOSE);
    LogUtil.info(`${this.tag} getWirelessAntiTheftState. wirelessAntiTheftState:${wirelessAntiTheftState}`);
    return wirelessAntiTheftState === NUMBER_OPEN;
  }

  /**
   * 获取当前系统设置中的无线防盗蓝牙地址,默认空字符串
   */
  private getWirelessAntiTheftHostAddress(): string {
    // 获取当前系统设置中的允许休眠时通知开关的状态,默认false
    const hostAddress: string = SettingsDataUtils.getSettingsData(WIRELESS_ANTI_THEFT_HOST_ADDRESS_KEY, '');
    LogUtil.info(`${this.tag} getWirelessAntiTheftHostAddress. hostAddress:${BluetoothUtils.getLogMAC(hostAddress)}`);
    return hostAddress;
  }

  updateBondedDevices(): void {
    LogUtil.info(`${this.tag} updateBondedDevices`);
    let devices = BluetoothAdapter.getInstance().getBondedDevices();
    if (!devices) {
      LogUtil.info(`${this.tag} bonded devices is empty`);
      return;
    }

    for (let device of devices) {
      this.addBondDevice((BluetoothAdapter.getInstance().cachedBondedDevices.get(device.deviceId) ||
        new BluetoothDevice(device.deviceId)), 0);
      if (this.bondDevicesMenu.length > 0) {
        this.getFromPreferenceAndSort(device, this.bondDevicesMenu[this.bondDevicesMenu.length - 1]);
      }
    }
  }

  private addBondDevice(device: BluetoothDevice, bondTime: number): void {
    LogUtil.info(`${this.tag} add bond device, deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId)}`);
    if (!device) {
      LogUtil.error(`${this.tag} add bond device fail, device is invalid`);
      return;
    }
    if (this.findMenuEntry(device.deviceId) !== -1) {
      LogUtil.warn(`${this.tag} add bond device fail, has contain the device`);
      return;
    }
    if (this.isWirelessAntiTheft && device.deviceId === this.wirelessAntiTheftHostAddress) {
      LogUtil.warn(`${this.tag} add bond device fail, it is wirelessAntiTheft device`);
      return;
    }
    this.bondDevicesMenu.push(this.createMenuEntry(device, bondTime));
  }

  private createMenuEntry(device: BluetoothDevice, bondTime: number, isShow: boolean = false): MenuEntry {
    let param: MenuEntryData = {
      key: device.deviceId,
      title: device.deviceName,
      rssi: 0,
      icon: device.getIcon(),
    };
    let a2dpState: ProfileConnectionState =
      BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_A2DP_SOURCE, device.deviceId);
    let hfpState: ProfileConnectionState =
      BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY, device.deviceId);
    let hidState: ProfileConnectionState =
      BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_HID_HOST, device.deviceId);
    let hearingAidState: ProfileConnectionState =
      BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_HEARING_AID, device.deviceId);
    if (device.getSubDevice()) {
      let subDeviceState: ProfileConnectionState = BluetoothAdapter.getInstance()
        .getProfileState(ProfileId.PROFILE_HEARING_AID, (device.getSubDevice() as BluetoothDevice).deviceId);
      LogUtil.info(`${this.tag} createMenuEntry mainDeviceState :${hearingAidState}, subDeviceState : ${subDeviceState}`);
      hearingAidState = BluetoothDevice.mergeHearingAidState(hearingAidState, subDeviceState);
    }
    param.isConnect = [a2dpState, hfpState, hidState, hearingAidState].includes(ProfileConnectionState.STATE_CONNECTED);
    param.index = param.isConnect ? (BONDED_DEVICE_TIME_FLAG + bondTime) :
      ((bondTime === 0) ? this.bondDevicesMenu.length : bondTime);
    param.subTitle = this.getSubtitle(device.deviceId, a2dpState, hfpState, hidState, hearingAidState);
    LogUtil.info(`${this.tag} getSubtitle : ${param.subTitle}`);
    return new MenuEntry(param);
  }

  private getSubtitle(deviceId: string, a2dpState: ProfileConnectionState, hfpState: ProfileConnectionState,
    hidState: ProfileConnectionState, hearingAidState: ProfileConnectionState): ResourceStr {
    LogUtil.info(`${this.tag} getSubtitle a2dpState : ${a2dpState}, hfpState : ${hfpState}, hidState : ${hidState}, hearingAidState : ${hearingAidState}`);
    let lastSubtitle: ResourceStr = '';
    let index: number = this.findMenuEntry(deviceId);
    if (index !== -1 && index < this.bondDevicesMenu.length) {
      lastSubtitle = this.bondDevicesMenu[index].subTitle;
    }

    let subtitle: string = '';
    if ([a2dpState, hfpState, hidState, hearingAidState].includes(ProfileConnectionState.STATE_CONNECTING)) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_connecting_summary'));
      return subtitle;
    }
    if (a2dpState === ProfileConnectionState.STATE_CONNECTED && hfpState === ProfileConnectionState.STATE_CONNECTED) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_hfp_a2dp_connect_summary'));
      return subtitle;
    }
    if (a2dpState === ProfileConnectionState.STATE_CONNECTED &&
      hfpState === ProfileConnectionState.STATE_DISCONNECTED) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_a2dp_connect_summary'));
      return subtitle;
    }
    if (a2dpState === ProfileConnectionState.STATE_DISCONNECTED &&
      hfpState === ProfileConnectionState.STATE_CONNECTED) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_hfp_connect_summary'));
      return subtitle;
    }
    if (hidState === ProfileConnectionState.STATE_CONNECTED ||
      hearingAidState === ProfileConnectionState.STATE_CONNECTED) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_connected_summary'));
      return subtitle;
    }
    if ([a2dpState, hfpState, hidState].includes(ProfileConnectionState.STATE_DISCONNECTING)) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_disconnecting_summary'));
      return subtitle;
    }
    if (lastSubtitle === ResourceUtil.getWindowsStringSync($r('app.string.bt_connecting_summary'))) {
      subtitle = ResourceUtil.getWindowsStringSync($r('app.string.bt_connect_failed_title'));
      return subtitle;
    }

    return subtitle;
  }

  private findMenuEntry(deviceId: string): number {
    for (let index = 0; index < this.bondDevicesMenu.length; index++) {
      if (this.bondDevicesMenu[index].key === deviceId) {
        return index;
      }
    }
    return -1;
  }

  private compareMenu(menu1: MenuEntry, menu2: MenuEntry) {
    if (!menu1) {
      return -1;
    }
    if (!menu2) {
      return 1;
    }
    let a = menu1.index as number;
    let b = menu2.index as number;
    return a - b;
  }

  private registerDataChange(): void {
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().registerStateChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterBondChangeListener(this);
    BluetoothAdapter.getInstance().registerBondChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
    BluetoothAdapter.getInstance().registerProfileStateChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterDeviceNameUpdateListener(this);
    BluetoothAdapter.getInstance().registerDeviceNameUpdateListener(this);

    BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(this);
    BluetoothAdapter.getInstance().registerDeviceChangeListener(this);

    BluetoothAdapter.getInstance().unregisterBondedDeviceChangeListener(this);
    BluetoothAdapter.getInstance().registerBondedDeviceChangeListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterBondChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterDeviceNameUpdateListener(this);
    BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(this);
    BluetoothAdapter.getInstance().unregisterBondedDeviceChangeListener(this);
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(`${this.tag} bluetooth state change: ${state}`);
    if (BluetoothUtils.isBluetoothStateOn(state)) { // 开启
      this.updateBondedDevices();
    } else {
      this.bondDevicesMenu.splice(0, this.bondDevicesMenu.length);
    }
  }

  onDeviceNameUpdate(device: BluetoothDevice): void {
    LogUtil.info(`${this.tag} onDeviceNameUpdate deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId)}, newDeviceName: ${LogMaskUtil.getLogNickNameString(device?.deviceName)}`);
    if (!device || CheckEmptyUtils.checkStrIsEmpty(device?.deviceName)) {
      LogUtil.error(`${this.tag} device or deviceName is invalid`);
      return;
    }
    let index: number = this.findMenuEntry(device.deviceId)
    if (index === -1) {
      return;
    }

    this.bondDevicesMenu[index].title = device?.deviceName;
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    if (!stateChangeParam) {
      return;
    }
    let deviceId = stateChangeParam.deviceId;
    // 如果是附属设备，找到它的主设备，将目标deviceId切换为主设备的deviceId
    if (BluetoothAdapter.getInstance().isBondedSubDevice(deviceId)) {
      let mainDevice = BluetoothAdapter.getInstance().findMainDeviceBySubDevice(deviceId);
      if (mainDevice) {
        deviceId = mainDevice.deviceId;
      }
    }
    let index: number = this.findMenuEntry(deviceId);
    if (index !== -1) {
      let device: BluetoothDevice | undefined = BluetoothAdapter.getInstance().cachedBondedDevices.get(deviceId);
      if (!device) {
        LogUtil.error(`${this.tag} onBluetoothProfileStateChange. foundDevice is empty`);
        return;
      }
      LogUtil.info(`${this.tag} onBluetoothProfileStateChange. index:${index} profileId:${profileId} StateChangeParam:${stateChangeParam.state}`);
      device?.buildProfileSwitchState().then((data) => {
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange. buildProfileSwitchState summary:${data}`);
        let index = this.findMenuEntry(deviceId);
        this.bondDevicesMenu[index].subTitle = data;
        this.updatePluginWindowHeight(access.BluetoothState.STATE_ON);
      });
      if (stateChangeParam.state === ProfileConnectionState.STATE_DISCONNECTED ||
        stateChangeParam.state === ProfileConnectionState.STATE_CONNECTED) {
        let isConnect: boolean = device.isConnected();
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange. connect state change, isConnect:${isConnect}`);
        let data: number = new Date().getTime();
        this.bondDevicesMenu[index].isConnect = isConnect;
        this.bondDevicesMenu[index].index = isConnect ? BONDED_DEVICE_TIME_FLAG - data : -data;
        this.bondDevicesMenu.sort(this.compareMenu);
        this.addToPreference(device.deviceId, data);
      }
    }
  }

  public updatePluginWindowHeight(state?: number): void {
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
    LogUtil.info(`${this.tag} onConnectResult. deviceId:${BluetoothUtils.getLogMAC(deviceId)} isSuccess:${isSuccess}`);
    if (!isSuccess) {
      let device = BluetoothAdapter.getInstance().getBondedDeviceOrSubDevice(deviceId);
      if (!device) {
        LogUtil.error(`${this.tag} onConnectResult. foundDevice is empty`);
        return;
      }
      if (device && device.isHearingAidDevice()) {
        this.onHearingAidConnectFail(device);
        return;
      }
      // 这里将视图设为连接失败
      device?.buildProfileSwitchState(true).then((data) => {
        LogUtil.info(`${this.tag} onConnectResult. summary:${data}`);
        let index = this.findMenuEntry(deviceId);
        this.bondDevicesMenu[index].subTitle = data;
        this.updatePluginWindowHeight(access.BluetoothState.STATE_ON);
      });
    }
  }

  onHearingAidConnectFail(device: BluetoothDevice) {
    LogUtil.info(`${this.tag} onHearingAidConnectFail, deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId)}`);
    let anotherDevice: BluetoothDevice | undefined = undefined;
    let isSubDevice = BluetoothAdapter.getInstance().isBondedSubDevice(device?.deviceId);

    if (isSubDevice) {
      anotherDevice = BluetoothAdapter.getInstance().findMainDeviceBySubDevice(device?.deviceId);
    } else {
      if (device.getSubDevice()) {
        anotherDevice = device.getSubDevice();
      }
    }
    // 如果存在另一个设备，且不为Disconnect状态，不弹失败提示框
    if (anotherDevice &&
      BluetoothAdapter.getInstance().getProfileState(ProfileId.PROFILE_HEARING_AID, anotherDevice.deviceId) !==
      ProfileConnectionState.STATE_DISCONNECTED) {
      LogUtil.info(`${this.tag} onHearingAidConnectFail, anotherDevice is not Disconncted,not show fail Dialog`);
      return;
    }
    let mainDeviceId = device.deviceId;
    if (isSubDevice && anotherDevice) {
      mainDeviceId = anotherDevice?.deviceId;
    }

    let index: number = this.findMenuEntry(mainDeviceId);
    if (index === -1) {
      return;
    }
    // 这里将视图设为连接失败
    device?.buildProfileSwitchState(true).then((data) => {
      LogUtil.info(`${this.tag} onConnectResult. summary:${data}`);
      this.bondDevicesMenu[index].subTitle = data;
      this.updatePluginWindowHeight(access.BluetoothState.STATE_ON);
    });
  }

  onBondDeviceDeleted(deviceId: string): void {
    LogUtil.info(`${this.tag} onBondDeviceDeleted, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}`);
    if (!deviceId) {
      LogUtil.error(`${this.tag} onBondDeviceDeleted param empty`);
      return;
    }

    let index: number = this.findMenuEntry(deviceId);
    if (index === -1) {
      return;
    }
    this.bondDevicesMenu.splice(index, 1);
  }

  onBluetoothBondStateChange(stateParam: BondStateParam): void {
    if (!stateParam) {
      LogUtil.error(`${this.tag} onBluetoothBondStateChange param empty`);
      return;
    }

    LogUtil.info(`${this.tag} onBluetoothBondStateChange, deviceId: ${BluetoothUtils.getLogMAC(stateParam.deviceId)}, state: ${stateParam.state}`);
    let deviceId = stateParam.deviceId;
    if (stateParam.state !== BondState.BOND_STATE_BONDED) {
      this.onBondDeviceDeleted(deviceId);
      this.deleteFromPreference(deviceId);
    }

    if (stateParam.state === BondState.BOND_STATE_BONDED) {
      let bondTime: number = new Date().getTime();
      this.addBondDevice(BluetoothAdapter.getInstance().getBondedDevice(deviceId) ||
      BluetoothDevice.createDevice(deviceId), -bondTime);
      this.bondDevicesMenu.sort(this.compareMenu);
      this.addToPreference(deviceId, bondTime);
    }
  }

  onBluetoothPinRequired(pinRequiredParam: PinRequiredParam): void {
  }

  onPairResult(deviceId: string, result: number, isSuccess: boolean): void {
  }

  onDeviceAdded(device: BluetoothDevice): void {
  }

  onDeviceAttributesChanged(device: BluetoothDevice): void {
    let index: number = this.findMenuEntry(device?.deviceId);
    if (index === -1) {
      return;
    }
    this.bondDevicesMenu[index].icon = device.getIcon();
  }

  onDeviceDeleted(device: BluetoothDevice): void {
  }

  onAvailableDevicesRefresh(): void {
  }

  onAvailableDeviceClear(): void {
  }

  onBondedDeviceMerged(device: BluetoothDevice): void {
    LogUtil.info(`${this.tag} onBondedDeviceMerged ${BluetoothUtils.getLogMAC(device?.deviceId)}`);
    this.onBondDeviceDeleted(device?.deviceId);
  }

  private getFromPreferenceAndSort(device: BluetoothDevice, menuEntry: MenuEntry): void {
    let time = 1;
    this.getFromPreference(device?.deviceId, time).then((bondTime) => {
      LogUtil.info(`${this.tag} getFromPreference ${BluetoothUtils.getLogMAC(device?.deviceId)}, bondTime: ${bondTime}, time: ${time}`);
      if (bondTime > 0) {
        time = bondTime;
        menuEntry.index = device.isConnected() ? BONDED_DEVICE_TIME_FLAG - time : -time;
        this.bondDevicesMenu.sort(this.compareMenu);
      }
    });
  }

  private async getFromPreference(deviceId: string, defValue: number): Promise<number> {
    let pref: preferences.Preferences | undefined = await this.getPreference();
    if (!pref) {
      LogUtil.error(`${this.tag} getFromPreference fail: pref is invalid`);
      return defValue;
    }

    let deviceIdHash: string | undefined = await EncryptUtils.getAegSha256(deviceId);
    if (!deviceIdHash) {
      LogUtil.error(`${this.tag} getFromPreference fail: deviceIdHash is invalid`);
      return defValue;
    }

    let bondTime: number = defValue;
    try {
      bondTime = await pref.get(deviceIdHash, defValue) as number;
      LogUtil.error(`${this.tag} getFromPreference success: ${bondTime}`);
    } catch (err) {
      LogUtil.error(`${this.tag} getFromPreference fail: cause: ${err?.code}, ${err?.message}`);
      bondTime = defValue;
    }

    return bondTime;
  }

  private async addToPreference(deviceId: string, data: number): Promise<void> {
    let pref: preferences.Preferences | undefined = await this.getPreference();
    if (!pref) {
      LogUtil.error(`${this.tag} addToPreference fail: pref is invalid`);
      return;
    }

    let deviceIdHash: string | undefined = await EncryptUtils.getAegSha256(deviceId);
    if (!deviceIdHash) {
      LogUtil.error(`${this.tag} addToPreference fail: deviceIdHash is invalid`);
      return;
    }

    try {
      await pref.put(deviceIdHash, data);
      await pref.flush();
      LogUtil.info(`${this.tag} addToPreference success ${BluetoothUtils.getLogMAC(deviceId)}, ${data}`);
    } catch (err) {
      LogUtil.error(`${this.tag} addToPreference fail: cause: ${err?.message}`);
    }
  }

  private async deleteFromPreference(deviceId: string): Promise<void> {
    let pref: preferences.Preferences | undefined = await this.getPreference();
    if (!pref) {
      LogUtil.error(`${this.tag} deleteFromPreference fail: pref is invalid`);
      return;
    }

    let deviceIdHash: string | undefined = await EncryptUtils.getAegSha256(deviceId);
    if (!deviceIdHash) {
      LogUtil.error(`${this.tag} deleteFromPreference fail: deviceIdHash is invalid`);
      return;
    }

    try {
      await pref.delete(deviceIdHash);
      await pref.flush();
      LogUtil.info(`${this.tag} delete success`);
    } catch (err) {
      LogUtil.error(`${this.tag} deleteFromPreference fail: errCode: ${err?.code}, errMsg: ${err?.message}`);
    }
  }

  private async getPreference(): Promise<preferences.Preferences | undefined> {
    let promisePref: Promise<preferences.Preferences> | undefined;
    try {
      promisePref = preferences.getPreferences(AbilityContextManager.getContext(), 'btBondedDevice');
    } catch (err) {
      LogUtil.error(`${this.tag} getPreferences fail: ${err?.code}, ${err?.message}`);
    }
    return promisePref;
  }

  public handleBondedDeviceItemClick(deviceId: string): void {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      LogUtil.error(`${this.tag} handleBondedDeviceItemClick fail, deviceId is invalid`);
      return;
    }

    let index: number = this.findMenuEntry(deviceId);
    if (index === -1) {
      return;
    }

    LogUtil.info(`${this.tag} handleBondedDeviceItemClick, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}`);
    let menuEntry: MenuEntry = this.bondDevicesMenu[index];
    if (menuEntry.isConnect) {
      this.disconnectDevice(deviceId);
    } else {
      let subDeviceId = BluetoothAdapter.getInstance().cachedBondedDevices.get(deviceId)?.getSubDevice()?.deviceId;
      BluetoothAdapter.getInstance().startConnectIfSupport(deviceId, subDeviceId);
    }
  }

  private disconnectDevice(deviceId: string): void {
    LogUtil.info(`${this.tag} start to disconnect device`);
    let device = BluetoothAdapter.getInstance().getBondedDevice(deviceId);
    if (!device || !device.isConnected()) {
      LogUtil.error(`${this.tag} device not exit or already disconnect, return`);
      return;
    }

    let result = BluetoothAdapter.getInstance().disconnectDevice(device.deviceId);
    let subDevice = device.getSubDevice();
    if (subDevice) {
      result = result && BluetoothAdapter.getInstance().disconnectDevice(subDevice.deviceId);
    }
    LogUtil.info(`${this.tag} disconnectDevice result : ${result}`);
  }
}