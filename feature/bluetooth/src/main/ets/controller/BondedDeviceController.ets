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

import { dataShare } from '@kit.ArkData';
import { JSON } from '@kit.ArkTS';
import preferences from '@ohos.data.preferences';
import emitter from '@ohos.events.emitter';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EVENT_ID_BT_BOUND_DEVICE_NAME_CHANGED, } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemType,
  SettingIconType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingDialogState,
  SettingIconState,
  SettingStateType,
  SettingTextState,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BluetoothUtils, DisconnectCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import {
  NavEntryKey,
  NUMBER_CLOSE,
  NUMBER_OPEN,
  WIRELESS_ANTI_THEFT_HOST_ADDRESS_KEY,
  WIRELESS_ANTI_THEFT_KEY,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { EncryptUtils } from '@ohos/settings.common/src/main/ets/utils/EncryptUtils';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  BluetoothAdapter,
  BluetoothBondChangeListener,
  BluetoothBondedDeviceChangeListener,
  BluetoothDeviceChangeListener,
  BluetoothProfileStateChangeListener,
  BluetoothStateChangeListener,
} from '../BluetoothAdapter';
import { BluetoothItemModel } from '../model/BluetoothItemModel';
import {
  BluetoothDevice,
  BondState,
  BondStateParam,
  PinRequiredParam,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam,
} from '../model/BluetoothModel';
import { connectFailedDialogContentBuilder, disconnectRequestDialogContentBuilder } from '../view/CustomBuilder';
import { BluetoothBondedDeviceController } from './BluetoothBondedDeviceController';

/* instrument ignore file */
const BONDED_DEVICE_START_INDEX: number = 1000;

export const BONDED_DEVICE_TIME_FLAG: number = -2000000000000;

/**
 * 已配对蓝牙设备列表控制器
 *
 * @since 2022-04-25
 */
export class BondedDeviceController implements ComponentControl, BluetoothStateChangeListener,
BluetoothBondChangeListener, BluetoothDeviceChangeListener, BluetoothProfileStateChangeListener,
BluetoothBondedDeviceChangeListener {
  public tag: string = 'BondedDeviceController : ';
  public isStarted: boolean = false;
  public currentIndex: number = BONDED_DEVICE_START_INDEX;
  public dataSource?: DynamicDataSource;
  public compId?: string;
  private deviceTimestampMap: Map<string, string> = new Map();
  // 无线防盗标志位
  private isWirelessAntiTheft: boolean = false;
  private wirelessAntiTheftHostAddress: string = '';
  private deviceNameChangeListener = (eventData: emitter.EventData) => {
    if (!eventData.data?.deviceId || !eventData.data?.deviceName) {
      LogUtil.error(`${this.tag} receive device change event, but params id is empty.`);
      return;
    }
    LogUtil.info(`${this.tag} device name change: ${BluetoothUtils.getLogMAC(eventData.data?.deviceId)}, ${LogMaskUtil.getLogNickNameString(eventData.data?.deviceName)}`);
    let device: BluetoothDevice = BluetoothAdapter.getInstance().getBondedDevice(eventData.data?.deviceId);
    if (device) {
      device.deviceName = eventData.data?.deviceName;
      this.onBondDeviceAdded(device);
    } else {
      LogUtil.error(`${this.tag} found no bonded device cache.`);
    }
  };
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} receive toggle state change: ${toggleState?.state}`);
    if (toggleState?.state && (this.dataSource?.length ?? 0) > 0) {
      this.showOrHideHeader(true);
      this.showOrHideGroup(true);
    } else {
      this.showOrHideHeader(false);
      this.showOrHideGroup(false);
    }
  }
  // 音频管家dataShare帮助类
  private aamDataShareHelper: dataShare.DataShareHelper | undefined;
  // 音频管家dataShare中deviceInfo表使用的uri
  private readonly aamDeviceInfoUri = ('datashareproxy://com.ohos.audioaccessorymanager/deviceInfo');

  onAvailableDeviceClear() {
  }

  getListenKey(): string {
    return 'Bonded_Device_Controller';
  }

  onAvailableDevicesRefresh(): void {
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as DynamicDataSource;
    this.registerDataChange();
    emitter.on({
      eventId: EVENT_ID_BT_BOUND_DEVICE_NAME_CHANGED,
    }, this.deviceNameChangeListener);

    // 开关状态改变，已配对设备列表和header也对应显示或隐藏
    EventBus.getInstance().on('Setting.Bluetooth.SwitchGroup.SwitchItem.toggle', this.toggleStateChangeEventCallback);
    setTimeout(() => {
      this.updateBondedDevices();
    }, 100);
    this.registerL2HCIconsChange();
  }

  private registerDeviceNameChangeEvent(device: BluetoothDevice): void {
    EventBus.getInstance().on(`${device?.deviceId}updateName`, (newDeviceName: string) => {
      LogUtil.info(`${this.tag} receive device name change event: ${BluetoothUtils.getLogMAC(device?.deviceId)}, name: ${LogMaskUtil.getLogNickNameString(newDeviceName)}`);
      if (device) {
        device.deviceName = newDeviceName;
        // 更新蓝牙适配器缓存，确保设备名称持久化
        BluetoothAdapter.getInstance().updateBluetoothCaches(device.deviceId, newDeviceName);
        BluetoothAdapter.getInstance().setBondedDevice(device.deviceId, device);
        this.onBondDeviceAdded(device);
      }
    });
  }
  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    // 无线防盗相关
    this.isWirelessAntiTheft = this.getWirelessAntiTheftState();
    if (this.isWirelessAntiTheft) {
      this.wirelessAntiTheftHostAddress = this.getWirelessAntiTheftHostAddress();
    }
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      setTimeout(() => {
        this.updateBondedDevicesWithDelete();
      }, 100);
    }
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

  updateBondedDevicesWithDelete(): void {
    LogUtil.info(`${this.tag} updateBondedDevicesWithDelete`);
    this.updateBondedDevices();

    let devices = BluetoothAdapter.getInstance().getBondedDevices();
    if (!devices) {
      LogUtil.info(`${this.tag} bonded devices is empty`);
      return;
    }

    let deviceArray: BluetoothDevice[] = Array.from(devices);
    // 如果之前已配对的设备已经被删除了，那么这里也要删除
    this.deleteNoBondedDevices(deviceArray);
    // 如果之前标记为设置主动配对的设备不是配对状态，那么这里也要删除
    this.updateDeviceBondedFromLocal(deviceArray);
  }

  private deleteNoBondedDevices(deviceArray: BluetoothDevice[]): void {
    if (this.dataSource) {
      for (let i = 0; i < this.dataSource.length; i++) {
        let deviceId: string = (this.dataSource[i] as BluetoothItemModel).device?.deviceId ?? '';
        if (!this.isExistDevice(deviceArray, deviceId)) {
          this.dataSource.splice(i, 1);
          this.deviceTimestampMap.delete(deviceId);
          this.deleteFromPreference(deviceId);
        }
      }
      if ((this.dataSource?.length ?? 0) <= 0) {
        this.showOrHideHeader(false);
        this.showOrHideGroup(false);
      }
    }
  }

  private updateDeviceBondedFromLocal(deviceArray: BluetoothDevice[]): void {
    let bondedFromLocalDeviceIds: string[] =
      Array.from(BluetoothAdapter.getInstance().connectTimestampManager.getDeviceBondedFromLocalDevices());
    if (CheckEmptyUtils.isEmptyArr(bondedFromLocalDeviceIds)) {
      return;
    }

    for (let i = 0; i < bondedFromLocalDeviceIds.length; i++) {
      const deviceId: string = bondedFromLocalDeviceIds[i];
      if (!this.isExistDevice(deviceArray, deviceId)) {
        BluetoothAdapter.getInstance().connectTimestampManager.resetDeviceBondedFromLocal(deviceId);
        BluetoothAdapter.getInstance().connectTimestampManager.resetDeviceConnectTimestamp(deviceId);
      }
    }
  }

  private isExistDevice(deviceArray: BluetoothDevice[], deviceId?: string): boolean {
    if (!deviceId) {
      LogUtil.warn(`${this.tag} isExistDevice fail, deviceId is invalid`);
      return true;
    }
    for (let device of deviceArray) {
      if (device.deviceId === deviceId) {
        LogUtil.info(`${this.tag} isExistDevice success: true`);
        return true;
      }
    }

    LogUtil.info(`${this.tag} isExistDevice success: false`);
    return false;
  }

  private showOrHideHeader(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideHeader: ${isShow}`);
    notifyCompStateChange(`${this.compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideGroup: ${isShow}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    if (CommonUtils.isPageExist(NavEntryKey.BLUETOOTH_ENTRY)) {
      LogUtil.info(`${this.tag} the page exist, not unregister`);
      return;
    }

    this.unRegisterDataChange();
    emitter.off(EVENT_ID_BT_BOUND_DEVICE_NAME_CHANGED, this.deviceNameChangeListener);
    EventBus.getInstance()
      .detach('Setting.Bluetooth.SwitchGroup.SwitchItem.toggle', this.toggleStateChangeEventCallback);
    this.unRegisterDataChange();
    this.unregisterL2HCIconsChange();
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(`${this.tag} bluetooth state change: ${state}`);
    if (BluetoothUtils.isBluetoothStateOff(state)) {
      this.showOrHideHeader(false);
      this.showOrHideGroup(false);
      this.dataSource?.splice(0, this.dataSource?.length);
      return;
    }
    if (BluetoothUtils.isBluetoothStateOn(state)) {
      this.updateBondedDevices();
      if ((this.dataSource?.length ?? 0) > 0) {
        this.showOrHideHeader(true);
        this.showOrHideGroup(true);
      }
    }
  }

  private registerDataChange(): void {
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().registerStateChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(this);
    BluetoothAdapter.getInstance().registerDeviceChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterBondChangeListener(this);
    BluetoothAdapter.getInstance().registerBondChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
    BluetoothAdapter.getInstance().registerProfileStateChangeListener(this);

    BluetoothAdapter.getInstance().unregisterBondedDeviceChangeListener(this);
    BluetoothAdapter.getInstance().registerBondedDeviceChangeListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterBondChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
    BluetoothAdapter.getInstance().unregisterBondedDeviceChangeListener(this);
  }

  onDeviceAdded(device: BluetoothDevice): void {
  }

  onDeviceDeleted(device: BluetoothDevice): void {
  }

  onBondedDeviceMerged(device: BluetoothDevice): void {
    LogUtil.info(`${this.tag} onBondedDeviceMerged ${BluetoothUtils.getLogMAC(device?.deviceId)}`);
    this.onBondDeviceDeleted(device?.deviceId);
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    LogUtil.info(`${this.tag} onBluetoothProfileStateChange`);
    if (!stateChangeParam || !this.dataSource) {
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

    let index: number = this.findMenu(deviceId);
    LogUtil.info(`${this.tag} onBluetoothProfileStateChange index: ${index}`);
    if (index !== -1) {
      let device: BluetoothDevice | undefined = this.findDevice(index);
      if (!device) {
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange foundDevice is empty`);
        return;
      }
      if (stateChangeParam.state === ProfileConnectionState.STATE_CONNECTED) {
        this.updateDevice(device, index);
      }
      BluetoothAdapter.getInstance().cachedManager.addDevice(device);
      BluetoothAdapter.getInstance().setBondedDevice(device.deviceId, device);
      LogUtil.info(`${this.tag} onBluetoothProfileStateChange. profileId:${profileId} StateChangeParam:${stateChangeParam.state}`);
      device?.buildProfileSwitchState().then((data) => {
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange. getSummary profileId:${profileId} summary:${data} timestamp:${this.deviceTimestampMap.get(deviceId)}`);
        let index = this.findMenu(deviceId);
        if (index !== -1 && this.dataSource) {
          (this.dataSource[index] as BluetoothItemModel).desc = { content: data };
        }
        notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(deviceId)}`,
          new Map<SettingStateType, SettingBaseState>(
            [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: data } as SettingTextState]]
          ));
      });
      if (stateChangeParam.state === ProfileConnectionState.STATE_DISCONNECTED ||
        stateChangeParam.state === ProfileConnectionState.STATE_CONNECTED) {
        let isConnect: boolean = device.isConnected();
        LogUtil.info(`${this.tag} onBluetoothProfileStateChange. connect state change. deviceId:${this.deviceTimestampMap.get(deviceId)} isConnect:${isConnect}`);
        let data: number = new Date().getTime();
        (this.dataSource[index] as BluetoothItemModel).bondTime = isConnect ? BONDED_DEVICE_TIME_FLAG - data : -data;
        notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(deviceId)}`,
          new Map<SettingStateType, SettingBaseState>(
            [[SettingStateType.STATE_TYPE_ITEM_TITLE, {
              fontColor: isConnect ? $r('sys.color.ohos_id_color_text_primary_activated') :
              $r('sys.color.ohos_id_color_text_primary')
            } as SettingTextState]]
          ));
        this.sortByBondTime();
        this.addToPreference(device.deviceId, data);
      }
    }
  }

  private sortByBondTime(): void {
    if (this.dataSource == undefined || this.dataSource == null || this.dataSource.length <= 0) {
      return;
    }

    let preLastItemModel: BluetoothItemModel = this.dataSource?.[this.dataSource.length - 1] as BluetoothItemModel;
    this.dataSource?.sort((x1, x2) => {
      if (!x1) {
        return -1;
      }
      if (!x2) {
        return 1;
      }
      let device1: BluetoothItemModel = x1 as BluetoothItemModel;
      let device2: BluetoothItemModel = x2 as BluetoothItemModel;
      let a = device1?.bondTime as number;
      let b = device2?.bondTime as number;
      return a - b;
    });

    let curLastItemModel: BluetoothItemModel = this.dataSource?.[this.dataSource.length - 1] as BluetoothItemModel;
    if (preLastItemModel?.device?.deviceId !== curLastItemModel?.device?.deviceId) {
      preLastItemModel?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
      curLastItemModel?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: true } as SettingCompState
      ]]));
    }
  }

  private findDevice(index: number): BluetoothDevice | undefined {
    if (!this.dataSource || index < 0 || index > this.dataSource.length - 1) {
      return undefined;
    }

    let itemModel: BluetoothItemModel = this.dataSource[index] as BluetoothItemModel;
    return itemModel.device;
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
    LogUtil.info(`${this.tag} onConnectResult, deviceId = ${BluetoothUtils.getLogMAC(deviceId)} , isSuccess = ${isSuccess}`);
    if (!isSuccess) {
      let device = BluetoothAdapter.getInstance().getBondedDeviceOrSubDevice(deviceId);
      if (device && device.isHearingAidDevice()) {
        this.onHearingAidConnectFail(device, result);
        return;
      }
      let index: number = this.findMenu(deviceId);
      LogUtil.info(`${this.tag} onConnectResult, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, index is ${index}, result: ${result}`);
      if (index === -1 || result === DisconnectCause.USER_DISCONNECT) {
        return;
      }
      this.openConnectFailedDialog(deviceId, result);
      notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(deviceId)}`,
        new Map<SettingStateType, SettingBaseState>(
          [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: '' } as SettingTextState]]
        ));
    }
  }

  onHearingAidConnectFail(device: BluetoothDevice, result: number) {
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
    let index: number = this.findMenu(device.deviceId);
    if (index === -1) {
      return;
    }
    this.openConnectFailedDialog(device.deviceId, result);
    notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(device.deviceId)}`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: '' } as SettingTextState]]
      ));
  }

  private findBluetoothItemModel(deviceId: string): BluetoothItemModel | null {
    if (!this.dataSource) {
      return null;
    }
    let timestamp: string | undefined = this.deviceTimestampMap.get(deviceId);
    if (!timestamp) {
      return null;
    }

    for (let index = 0; index < this.dataSource.length; index++) {
      if (this.dataSource[index].id === timestamp) {
        return this.dataSource[index] as BluetoothItemModel;
      }
    }

    return null;
  }

  onDeviceAttributesChanged(device: BluetoothDevice): void {
    if (CheckEmptyUtils.isEmpty(device)) {
      LogUtil.error(`${this.tag} onDeviceAttributesChanged fail, param is empty`);
      return;
    }
    let index: number = this.findMenu(device.deviceId);
    if (index === -1) {
      return;
    }

    this.updateDevice(device, index);
  }

  onBondDeviceDeleted(deviceId: string): void {
    LogUtil.info(`${this.tag} onBondDeviceDeleted, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, ${this.deviceTimestampMap.get(deviceId)}`);
    if (!deviceId || this.dataSource == undefined || this.dataSource == null) {
      LogUtil.error(`${this.tag} onBondDeviceDeleted param empty`);
      return;
    }

    let index: number = this.findMenu(deviceId);
    if (index === -1) {
      LogUtil.warn(`${this.tag} onBondDeviceDeleted not found the device`);
      return;
    }
    this.dataSource?.removeData(this.dataSource[index]);
    this.deviceTimestampMap.delete(deviceId);
    if (this.dataSource?.length === 0) {
      this.showOrHideHeader(false);
      this.showOrHideGroup(false);
    }
    this.deleteFromPreference(deviceId);
  }

  onBondDeviceAdded(device: BluetoothDevice): void {
    if (!device) {
      LogUtil.error(`${this.tag} onBondDeviceAdded param empty`);
      return;
    }
    if ((this.isWirelessAntiTheft && device.deviceId === this.wirelessAntiTheftHostAddress)) {
      LogUtil.warn(`${this.tag} onBondDeviceAdded fail, it is wirelessAntiTheft device`);
      return;
    }
    LogUtil.info(`${this.tag} onBondDeviceAdded, deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId)}`);
    if (!BluetoothAdapter.getInstance().isBondedMainDevice(device?.deviceId)) {
      return;
    }

    if (this.dataSource?.length === 0) {
      this.showOrHideHeader(true);
      this.showOrHideGroup(true);
    }

    let index: number = this.findMenu(device.deviceId);
    if (index === -1) {
      let bondTime: number = new Date().getTime();
      device?.buildProfileSwitchState().then((data) => {
        LogUtil.info(`${this.tag} createBluetoothMenu, getSummary summary: ${data}, deviceId: ${BluetoothUtils.getLogMAC(device.deviceId)}, timestamp: ${this.deviceTimestampMap.get(device.deviceId)}`);
        if (this.dataSource == undefined || this.dataSource == null) {
          return;
        }

        this.deviceTimestampMap.set(device.deviceId, new Date().getTime().toString() +
        BluetoothUtils.getPreMac(device.deviceId) + BluetoothUtils.getSufMac(device.deviceId));

        let preLastItemModel: BluetoothItemModel | undefined;
        if (this.dataSource?.length ?? 0 > 0) {
          preLastItemModel = this.dataSource[this.dataSource.length - 1] as BluetoothItemModel;
        }
        this.dataSource?.push(this.createBluetoothItemModel(device, data, -bondTime));
        preLastItemModel?.onItemEvent?.(new Map([[
          SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
        ]]));
        let curLastItemModel: BluetoothItemModel = this.dataSource[this.dataSource.length - 1] as BluetoothItemModel;
        curLastItemModel?.onItemEvent?.(new Map([[
          SettingStateType.STATE_TYPE_ITEM_POS, { state: true } as SettingCompState
        ]]));

        this.sortByBondTime();
        this.addToPreference(device?.deviceId, bondTime);
      });
    } else {
      this.updateDevice(device, index);
    }
    // 注册设备名称变更EventBus事件监听
    this.registerDeviceNameChangeEvent(device);
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
    }

    if (stateParam.state === BondState.BOND_STATE_BONDED) {
      this.onBondDeviceAdded(BluetoothAdapter.getInstance().getBondedDevice(deviceId) ||
      BluetoothDevice.createDevice(deviceId));
    }
  }

  onBluetoothPinRequired(pinRequiredParam: PinRequiredParam): void {
  }

  onPairResult(deviceId: string, result: number, isSuccess: boolean): void {
  }

  updateBondedDevices(): void {
    LogUtil.info(`${this.tag} updateBondedDevices`);
    let devices = BluetoothAdapter.getInstance().getBondedDevices();
    if (!devices) {
      LogUtil.info(`${this.tag} bonded devices is empty`);
      return;
    }
    // 过滤掉防盗蓝牙设备
    let deviceArray: BluetoothDevice[] = Array.from(devices).filter(device => {
      if ((this.isWirelessAntiTheft && device.deviceId === this.wirelessAntiTheftHostAddress)) {
        LogUtil.warn(`${this.tag} updateBondedDevices push fail, it is wirelessAntiTheft device`);
        return false;
      }
      return true;
    });
    for (let i = 0; i < deviceArray.length; i++) {
      let device: BluetoothDevice = deviceArray[i];
      // 为初始加载的设备注册名称变更事件监听
      this.registerDeviceNameChangeEvent(device);
      let index: number = this.findMenu(device.deviceId);
      if (index !== -1) {
        this.updateDevice(device, index);
      } else {
        let timestamp: string = new Date().getTime().toString() +
        BluetoothUtils.getPreMac(device.deviceId) + BluetoothUtils.getSufMac(device.deviceId);
        this.deviceTimestampMap.set(device.deviceId, timestamp);
        let itemModel: BluetoothItemModel = this.createBluetoothItemModel(device, '', 0);
        this.dataSource?.push(itemModel);
        if (i === 0) {
          LogUtil.info(`${this.tag} this.dataSource.length > 0 show header and group`);
          this.showOrHideHeader(true);
          this.showOrHideGroup(true);
        }
        device?.buildProfileSwitchState().then((data) => {
          LogUtil.info(`${this.tag} createBluetoothMenu,getSummary deviceId: ${BluetoothUtils.getLogMAC(device.deviceId)}, timestamp: ${this.deviceTimestampMap.get(device.deviceId)}, summary: ${data}`);
          this.updateBondedDeviceDesp(device, data);
          this.updateBondedDeviceTitleColor(device, data);
          this.updateBondedDeviceEnable(device, data);
        });
        this.getFromPreferenceAndSort(device, itemModel);
      }
      if (BluetoothAdapter.getInstance().isDeviceConnected(device.deviceId)) {
        BluetoothAdapter.getInstance().connectTimestampManager.resetDeviceBondedFromLocal(device.deviceId);
        BluetoothAdapter.getInstance().connectTimestampManager.resetDeviceConnectTimestamp(device.deviceId);
        this.updateBondedDeviceL2HCIcons(device);
      }
    }
  }

  /**
   * 更新L2HC图标显示
   * @param device
   */
  private updateBondedDeviceL2HCIcons(device: BluetoothDevice) {
    device.updateL2HCIcon(getContext(this)).then(() => {
      let index: number = this.findMenu(device.deviceId);
      this.updateDevice(device, index);
    })
  }

  /**
   * 注册设备L2HC变化监听
   */
  private registerL2HCIconsChange() {
    try {
      dataShare.createDataShareHelper(getContext(this), this.aamDeviceInfoUri, { isProxy: true }).then((helper) => {
        this.aamDataShareHelper = helper;
        this.aamDataShareHelper.on('dataChange', this.aamDeviceInfoUri, async () => {
          LogUtil.info(`${this.tag} aamDataShareChange.`);
          let devices = BluetoothAdapter.getInstance().getBondedDevices();
          if (!devices) {
            LogUtil.info(`${this.tag} bonded devices is empty`);
            return;
          }
          // 过滤掉防盗蓝牙设备
          let deviceArray: BluetoothDevice[] = Array.from(devices).filter(device => {
            if ((this.isWirelessAntiTheft && device.deviceId === this.wirelessAntiTheftHostAddress)) {
              LogUtil.warn(`${this.tag} updateBondedDevices push fail, it is wirelessAntiTheft device`);
              return false;
            }
            return true;
          });
          for (let i = 0; i < deviceArray.length; i++) {
            let device: BluetoothDevice = deviceArray[i];
            let index: number = this.findMenu(device.deviceId);
            if (index === -1) {
              LogUtil.error(`${this.tag} aamDataShareChange: invalid index`);
              return;
            }
            if (BluetoothAdapter.getInstance().isDeviceConnected(device.deviceId)) {
              await device.updateL2HCIcon(getContext(this));
              LogUtil.info(`${this.tag} aamDataShareChange ${BluetoothUtils.getLogMAC(device.deviceId)} ${index}`);
              this.updateDevice(device, index);
            }
          }
        })
      })
    } catch (e) {
      LogUtil.error(`${this.tag} createDataShareHelper has error: ${JSON.stringify(e)}.`);
    }

  }

  /**
   * 注销设备L2HC变化监听
   */
  private unregisterL2HCIconsChange() {
    this.aamDataShareHelper?.off('dataChange', this.aamDeviceInfoUri);
    this.aamDataShareHelper?.close();
    this.aamDataShareHelper = undefined;
  }

  private updateBondedDeviceDesp(device: BluetoothDevice, data: ResourceStr): void {
    let index: number = this.findMenu(device.deviceId);
    if (this.dataSource && index !== -1) {
      this.dataSource[index].desc = { content: data };
      notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(device.deviceId)}`,
        new Map<SettingStateType, SettingBaseState>(
          [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: data } as SettingTextState]]
        ));
    }
  }

  private updateBondedDeviceTitleColor(device: BluetoothDevice, data: ResourceStr): void {
    let index: number = this.findMenu(device.deviceId);
    if (this.dataSource && index !== -1) {
      let isTitleActivated: boolean =
        (data !== ResourceUtil.getWindowsStringSync($r('app.string.bt_connecting_summary')) && data !== '');
      notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(device.deviceId)}`,
        new Map<SettingStateType, SettingBaseState>(
          [[SettingStateType.STATE_TYPE_ITEM_TITLE, {
            fontColor: isTitleActivated ? $r('sys.color.ohos_id_color_text_primary_activated') :
            $r('sys.color.ohos_id_color_text_primary')
          } as SettingTextState]]
        ));
    }
  }

  private updateBondedDeviceEnable(device: BluetoothDevice, data: ResourceStr): void {
    let index: number = this.findMenu(device.deviceId);
    if (this.dataSource && index !== -1) {
      let isConnecting: boolean = data === ResourceUtil.getWindowsStringSync($r('app.string.bt_connecting_summary'));
      device.setEnable(isConnecting ? false : true);
    }
  }

  private getFromPreferenceAndSort(device: BluetoothDevice, itemModel: BluetoothItemModel): void {
    let time = 1;
    this.getFromPreference(device?.deviceId, time).then((bondTime) => {
      LogUtil.info(`${this.tag} getFromPreference ${BluetoothUtils.getLogMAC(device?.deviceId)}, bondTime: ${bondTime}, time: ${time}`);
      if (bondTime > 0) {
        time = bondTime;
        itemModel.bondTime = device.isConnected() ? BONDED_DEVICE_TIME_FLAG - time : -time;
        this.sortByBondTime();
      }
    });
  }

  protected findMenu(deviceId: string): number {
    let index: number = -1;
    if (!this.dataSource || this.dataSource?.length < 1) {
      return index;
    }
    let timestamp: string | undefined = this.deviceTimestampMap.get(deviceId);
    if (!timestamp) {
      return index;
    }

    for (let i = 0; i < this.dataSource?.length; i++) {
      if (this.dataSource[i].id === timestamp) {
        return i;
      }
    }
    return index;
  }

  private createBluetoothItemModel(
    device: BluetoothDevice, despContent: ResourceStr, bondedTime?: number): BluetoothItemModel {
    let itemModel: BluetoothItemModel = {
      id: this.deviceTimestampMap.get(device.deviceId) as string,
      type: ItemType.ITEM_TYPE_STANDARD,
      device: device,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: {
          width: 24,
          height: 24,
          fillColor: $r('sys.color.icon_primary'),
          accessibilityText: device.getReadDetail() as Resource
        },
        isSymbolIcon: true,
      },
      title: { content: device.deviceName },
      titleIcon: {
        icon: device.getTitleIcon(),
        iconType: SettingIconType.ICON_TYPE_TITLE_ICON,
        style: {
          width: 32,
          height: 16,
          fillColor: $r('sys.color.icon_primary'),
          accessibilityText: device.getReadDetail() as Resource
        },

        isSymbolIcon: true,
      },
      desc: { content: despContent },
      bondTime: bondedTime,
      compControl: new BluetoothBondedDeviceController(),
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('app.media.ic_public_detail'),
        iconType: SettingIconType.ICON_TYPE_TIP,
        responseRegion: {
          x: -12,
          y: -12,
          width: 48,
          height: 48
        },
        style: {
          width: 24,
          height: 24,
          fillColor: $r('sys.color.icon_secondary'),
          accessibilityText: $r('app.string.check_the_detail')
        },
        onItemClick: (component: SettingBaseModel) => {
          this.handleBondedDeviceItemClick(component);
        },
        onSelfClick: (component: SettingBaseModel) => {
          this.handleDetailClick(component);
        },
      }
    };
    return itemModel;
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

  private async handleDetailClick(component: SettingBaseModel): Promise<void> {
    LogUtil.info(`${this.tag} handleDetailClick`);
    let bluetoothItemModel: BluetoothItemModel = component as BluetoothItemModel
    if (!bluetoothItemModel || !bluetoothItemModel.device) {
      return;
    }

    let device: BluetoothDevice = bluetoothItemModel.device;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.CLICK_GENERAL_SETTINGS_ICON);
    LogUtil.info(`${this.tag} BluetoothBondedDevice onStateIconClick , deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId as string)}, isEnable: ${device.getEnable()}`);
    if (!device.getEnable()) {
      return;
    }
    await device.isAbsoluteVolumeSupportedAndEnabled();
    await device.getDefaultDeviceType();
    await device.getShareType();
    const context = getContext(this);
    let isHearingAid = device?.isHearingAidDevice();
    let isJumpAudio = false;
    try {
      isJumpAudio = await device?.isAudioDevice(context);
    } catch (err) {
      LogUtil.error(`${this.tag} failed , errCode: ${err?.code}, errMsg: ${err?.message}`);
    }

    if (isJumpAudio) {
      if (CommonUtils.isPageExist(NavEntryKey.AUDIO_BUTLER_ENTRY)) {
        LogUtil.info(`${this.tag} the AUDIO_BUTLER_ENTRY page exist, not destroy`);
        return;
      }

      let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
      if (pathInfoStack) {
        DynamicLoader.getInstance().fire(NavEntryKey.AUDIO_BUTLER_ENTRY).then(() => {
          pathInfoStack?.pushPathByName(NavEntryKey.AUDIO_BUTLER_ENTRY, new PushParam(device));
        });
      }
    } else {
      if (CommonUtils.isPageExist(NavEntryKey.BLUETOOTH_BONDED_ENTRY)) {
        LogUtil.info(`${this.tag} the BLUETOOTH_BONDED_ENTRY page exist, not destroy`);
        return;
      }

      PageRouter.push(NavEntryKey.BLUETOOTH_BONDED_ENTRY, device);
    }
  }

  private handleBondedDeviceItemClick(component: SettingBaseModel): void {
    if (!component) {
      LogUtil.error(`${this.tag} handleBondedDeviceItemClick fail, component is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} handleBondedDeviceItemClick, component: ${component.id}`);
    let bluetoothItemModel: BluetoothItemModel = component as BluetoothItemModel;
    if (!bluetoothItemModel || !(bluetoothItemModel?.compControl instanceof BluetoothBondedDeviceController) ||
      !bluetoothItemModel.device) {
      LogUtil.error(`${this.tag} bluetoothItemModel is invalid, return`);
      return;
    }
    let controller: BluetoothBondedDeviceController = bluetoothItemModel.compControl as BluetoothBondedDeviceController;

    let deviceId: string = bluetoothItemModel.device.deviceId;
    let isConnected: boolean = bluetoothItemModel.device.isConnected();
    LogUtil.info(`${this.tag} handleBondedDeviceItemClick, isConnected: ${isConnected}, compid: ${controller?.compId}`);
    if (isConnected) {
      this.openDisconnectRequestDialog(controller?.compId as string);
    } else {
      let subDeviceId = bluetoothItemModel.device?.getSubDevice()?.deviceId;
      BluetoothAdapter.getInstance().startConnectIfSupport(deviceId, subDeviceId);
    }
  }

  private openDisconnectRequestDialog(compId: string): void {
    notifyCompStateChange(`${compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(disconnectRequestDialogContentBuilder),
        title: $r('app.string.bt_disconnect_title'),
        buttons: [
          {
            value: $r('app.string.button_tittle_cancel'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
            action: (component: SettingItemModel) => {
            },
          },
          {
            value: $r('app.string.dialog_sure'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
            action: (component: SettingItemModel) => {
              this.disconnectDevice(component);
            },
            focused: true,
          },
        ],
        buttonVertical: true,
      } as SettingDialogState]]
    ));
  }

  private disconnectDevice(component: SettingItemModel): void {
    LogUtil.info(`${this.tag} onClick ok, start to disconnect device`);
    let bluetoothItemModel: BluetoothItemModel = component as BluetoothItemModel;
    if (!bluetoothItemModel || !bluetoothItemModel.device) {
      return;
    }

    let deviceId: string = bluetoothItemModel.device.deviceId;
    if (!bluetoothItemModel.device.isConnected()) {
      LogUtil.warn(`${this.tag} already disconnect, return`);
      return;
    }
    let result = BluetoothAdapter.getInstance().disconnectDevice(deviceId);
    let subDevice = bluetoothItemModel.device.getSubDevice();
    if (subDevice !== undefined) {
      result = result && BluetoothAdapter.getInstance().disconnectDevice(subDevice.deviceId);
    }
    LogUtil.info(`${this.tag} disconnectDevice result : ${result}`);
  }

  protected openConnectFailedDialog(deviceId: string, errorCode: number): void {
    if (!deviceId) {
      LogUtil.error(`${this.tag} openConnectFailedDialog param empty`);
      return;
    }

    let itemModel: BluetoothItemModel | null = this.findBluetoothItemModel(deviceId);
    if (!itemModel) {
      LogUtil.info(`${this.tag} openConnectFailedDialog fail: itemModel is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} openConnectFailedDialog: ${this.compId}.${this.deviceTimestampMap.get(deviceId)}`);
    itemModel.connectErrCode = errorCode;
    notifyCompStateChange(`${this.compId}.${this.deviceTimestampMap.get(deviceId)}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(connectFailedDialogContentBuilder),
        title: $r('app.string.bt_connect_failed_title'),
        buttons: [
          {
            value: $r('app.string.button_title_ok'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
            action: (component: SettingItemModel) => {
            },
          },
        ],
      } as SettingDialogState]]
    ));

    let deviceName = BluetoothAdapter.getInstance().getDeviceName(deviceId);
    BluetoothAdapter.getInstance().updateBluetoothCaches(deviceId, deviceName);
  }

  private updateDevice(device: BluetoothDevice, index: number): void {
    if (!this.dataSource || this.dataSource?.length < index + 1) {
      return;
    }

    device.updateEarphoneIcon();
    if (this.dataSource[index].title?.content !== device.deviceName) {
      this.dataSource[index].title = { content: device.deviceName };
    }
    // 更新标题右侧图标
    if (this.dataSource[index].titleIcon?.icon !== device.getTitleIcon()) {
      this.dataSource[index].titleIcon = {
        icon: device.getTitleIcon(),
        iconType: SettingIconType.ICON_TYPE_TITLE_ICON,
        style: { width: 32, height: 16, fillColor: $r('sys.color.icon_primary') }
      };
      this.dataSource[index].onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_TITLE_ICON, { icon: device.getTitleIcon() } as SettingIconState
      ]]));
    }
    if (this.dataSource[index].icon?.icon !== device.getIcon()) {
      this.dataSource[index].icon = {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
        isSymbolIcon: true,
      };
      this.dataSource[index].onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_ICON, { icon: device.getIcon() } as SettingIconState
      ]]));
    }
  }
}