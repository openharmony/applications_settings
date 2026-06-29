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

import { rpc } from '@kit.IPCKit';
import { ability, common } from '@kit.AbilityKit';
import screen from '@ohos.screen';
import { settings } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  APP_NAME,
  KEY_MOUSE_SERVICE,
  KEY_MOUSE_SERVICE_DESCRIPTOR,
  KEY_MOUSE_SERVICE_SETTINGS_DESCRIPTOR
} from '../constant/DisplayConstant';
import { DeviceDisplayType, DevicesController } from './DevicesController';
import { DisplayCommonUtils } from '../utils/DisplayCommonUtils';
import { AddStatus, RemoteDeviceInfo, SwitchCode } from '../utils/DeviceUtil';
import { DragController } from './DragController';

/* instrument ignore file */
const TAG = 'RemoteDevicesController';

export class RemoteDeviceStub extends rpc.RemoteObject {
  constructor(des: string) {
    super(des);
  }

  async onRemoteMessageRequest(code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    options: rpc.MessageOption): Promise<boolean> {
    LogUtil.info(`${TAG} onRemoteMessageRequest code: ' + ${code}`);
    let token = data.readInterfaceToken();
    if (token !== KEY_MOUSE_SERVICE_SETTINGS_DESCRIPTOR) {
      LogUtil.info(`${TAG} interface token invalid`);
      return false;
    }
    switch (code) {
      case SwitchCode.REFRESH_DEVICE_INFOS:
        let dataInfo: string = data.readString();
        LogUtil.info(`${TAG} SwitchCode.REFRESH_DEVICE_INFOS`);
        RemoteDevicesController.getInstance().refreshRemoteDevices(dataInfo);
        break;
      case SwitchCode.WRITE_SWITCH:
        let associateSwitch: boolean = data.readBoolean();
        LogUtil.info(`${TAG} SwitchCode.WRITE_SWITCH`);
        EventBus.getInstance().emit(CommonEventConstant.EVENT_KEY_MOUSE_SWITCH_CHANGE, associateSwitch);
        break;
      default:
        LogUtil.showInfo(TAG, 'unknown request code');
    }
    return true;
  }
}

export class RemoteDevicesController {
  public static readonly SETTING_SWITCH_STATUS: string = 'associate_assistant_state';
  private static instance: RemoteDevicesController;
  private remoteDeviceStub?: RemoteDeviceStub;
  private connectionId: number = -1;
  private keyMouseServiceProxy?: rpc.IRemoteObject;
  private remoteDevices: RemoteDeviceInfo[] = [];
  private updateDeviceAddStateCallback?: (result: boolean) => void;

  private constructor() {
  }

  public static getInstance(isNewObject?: boolean): RemoteDevicesController {
    if (!RemoteDevicesController.instance || isNewObject) {
      RemoteDevicesController.instance = new RemoteDevicesController();
    }
    return RemoteDevicesController.instance;
  }

  /**
   * 通过设备id获取设备信息
   * @param deviceId
   * @returns
   */
  public getRemoteDeviceByDeviceId(deviceId: string | number): RemoteDeviceInfo | undefined {
    if (typeof deviceId === 'number') {
      return undefined;
    }
    return this.remoteDevices.find((item: RemoteDeviceInfo) => item.mDeviceId === deviceId);
  }

  /**
   * 获取键鼠组网的所有设备
   * @returns
   */
  public getRemoteDevices(): RemoteDeviceInfo[] {
    return this.remoteDevices;
  }

  /**
   * 保存键鼠排序顺序
   * @param deviceOrder
   */
  public saveDevicePosition(deviceOrder: Array<string | number>): void {
    if (!Array.isArray(deviceOrder)) {
      LogUtil.error(`deviceOrder is not Array`);
      return;
    }
    if (DevicesController.getInstance().getOtherDeviceCount() === 0) {
      LogUtil.showError(TAG, `RemoteDevice length = 0, not need to saveDevicePosition`);
      return;
    }
    for (const remoteDevice of this.remoteDevices) {
      if (remoteDevice.isLocalDevice) {
        remoteDevice.mDeviceLocation = deviceOrder.indexOf(0);
      } else {
        remoteDevice.mDeviceLocation = deviceOrder.indexOf(remoteDevice.mDeviceId);
      }
    }
    const addedDevices = this.refreshDragPosition();
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    data.writeString(JSON.stringify(addedDevices));
    this.sendMessage(SwitchCode.DRAG_POSITION, data);
  }

  /**
   *  更新预览区设备顺序
   */
  private refreshDragPosition(): RemoteDeviceInfo[] {
    LogUtil.showInfo(TAG, `refreshDragPosition start`);
    const addedDevices =
      this.remoteDevices.filter((device: RemoteDeviceInfo) =>
      (device.mAddStatus === AddStatus.ADDED && device.isEstablished) || device.isLocalDevice)
        .sort((device1: RemoteDeviceInfo, device2: RemoteDeviceInfo): number => {
          return device1.mDeviceLocation - device2.mDeviceLocation;
        });
    if (addedDevices.length !== 0) {
      LogUtil.showInfo(TAG, `refreshDragPosition refreshDevices`);
      DevicesController.getInstance().refreshDevices(addedDevices);
      return addedDevices;
    }
    return [];
  }

  /**
   * 更新组网设备
   * @param remoteDevices
   */
  public refreshRemoteDevices(remoteDevicesStr: string): void {
    try {
      LogUtil.showInfo(TAG, `refreshRemoteDevices start remoteDevicesStr`);
      const remoteDevices: RemoteDeviceInfo[] | undefined =
        DisplayCommonUtils.parseString<RemoteDeviceInfo[]>(remoteDevicesStr);
      if (remoteDevices === undefined) {
        LogUtil.error(`${TAG} remoteDevices  = undefined`);
        this.remoteDevices = [];
        return;
      }
      const preAddedDrives = this.remoteDevices.filter(
        (device: RemoteDeviceInfo) => device.mAddStatus === AddStatus.ADDED && device.isEstablished);
      const currentDevices = remoteDevices.filter(
        (device: RemoteDeviceInfo) => device.mAddStatus === AddStatus.ADDED && device.isEstablished);
      this.remoteDevices = remoteDevices;
      if (preAddedDrives.length === currentDevices.length && DragController.getInstance().getHasDraggedState()) {
        LogUtil.showWarn(TAG,
          `length of addedDevice is not changed and has dragged, not need update`);
        return;
      }
      LogUtil.info(`${TAG} remoteDevices length ${remoteDevices.length}`);
      this.refreshDragPosition();
    } catch (e) {
      LogUtil.showError(TAG, `refreshRemoteDevices errorcode: ${e?.code} errorMessage: ${e?.message}`);
    }
  }

  /**
   * 发起键鼠服务的连接
   */
  public startKeyMoueService(): void {
    LogUtil.showInfo(TAG, `startKeyMoueService enter`);
    this.connectKeyMouseService(() => {
      this.getRemoteDeviceList();
    })
  }

  /**
   * 连接键鼠服务
   * @param callback
   */
  private connectKeyMouseService(callback: () => void): void {
    if (this.keyMouseServiceProxy) {
      LogUtil.info(`${TAG} Has been connected KeyMouseService`);
      callback();
      return;
    }
    LogUtil.info(`${TAG} connectKeyMouseService, this.isConnect = ${this.keyMouseServiceProxy === undefined}`);
    let want: Want = {
      'bundleName': APP_NAME,
      'abilityName': KEY_MOUSE_SERVICE
    };
    let options: ability.ConnectOptions = {
      onConnect: (elementName, binder) => {
        if (binder === undefined) {
          LogUtil.error(`${TAG} onConnect binder is null`);
          return;
        }
        LogUtil.info(`${TAG} onConnect success`);
        this.keyMouseServiceProxy = binder;
        this.setRemoteDeviceStub();
        this.noticeCollaborationConnectService(true);
        callback();
      },
      onDisconnect: () => {
        LogUtil.error(`${TAG} onDisconnect`);
        this.keyMouseServiceProxy = undefined;
      },
      onFailed: () => {
        LogUtil.error(`${TAG} onFailed`);
        this.keyMouseServiceProxy = undefined;
      }
    };
    const context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
    if (context) {
      this.connectionId = context.connectServiceExtensionAbility(want, options);
      LogUtil.info(`${TAG} connectKeyMouseService result: ${this.connectionId}`);
    }
  }

  getIsConnectKeyMouseService(): boolean {
    return this.keyMouseServiceProxy !== undefined;
  }

  /**
   * stop KeyMouseService
   */
  stopKeyMouseService(): void {
    LogUtil.info(`${TAG} stopKeyMouseService`);
    if (!this.keyMouseServiceProxy) {
      LogUtil.info(`${TAG} keyMouseService has not been connected`);
      return;
    }
    this.noticeCollaborationConnectService(false);
    const context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
    if (context) {
      context.disconnectServiceExtensionAbility(this.connectionId);
    }
    this.connectionId = -1;
    this.keyMouseServiceProxy = undefined;
  }

  /**
   * 获取组网设备列表
   * @returns
   */
  public async getRemoteDeviceList(): Promise<void> {
    if (this.keyMouseServiceProxy === undefined) {
      this.startKeyMoueService();
      return;
    }
    try {
      let data: rpc.MessageSequence = rpc.MessageSequence.create();
      data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
      await this.sendMessage(SwitchCode.GET_DEVICE_LIST, data);
    } catch (e) {

    }
  }

  /**
   * 订阅键鼠
   */
  setRemoteDeviceStub(): void {
    LogUtil.info(`${TAG} setRemoteDeviceStub start`);
    this.remoteDeviceStub = new RemoteDeviceStub('RemoteDeviceService');
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    data.writeRemoteObject(this.remoteDeviceStub);
    this.sendMessage(SwitchCode.SET_SETTING_STUB, data);
  }


  noticeCollaborationConnectService(isConnect: boolean): void {
    LogUtil.info(`${TAG} noticeCollaborationConnectService isConnect = ${isConnect}`);
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    data.writeBoolean(isConnect)
    this.sendMessage(SwitchCode.NOTICE_COLLABORATION_BIND_SERVICE, data);
  }

  /**
   * 断开当前选择设备
   */
  public disconnectCurrentDevice(deviceKey?: number | string): void {
    if (deviceKey === undefined) {
      const currentDevice = DevicesController.getInstance().getCurrentDevice()
      if (currentDevice.deviceType !== DeviceDisplayType.OTHERS) {
        LogUtil.showError(TAG, `disconnectDevice is not RemoteDevice`);
        return;
      }
      deviceKey = currentDevice.key;
    }
    const remoteDevice = this.remoteDevices.find((item) => item.mDeviceId === deviceKey);
    if (remoteDevice === undefined) {
      LogUtil.showError(TAG, `remoteDevice not found`);
      return;
    }
    this.updateDeviceAddState(remoteDevice.mNetworkId, (result: boolean) => {
      LogUtil.showInfo(TAG, `disconnectCurrentDevice result = ${result}`);
    })
  }

  /**
   * 更新设备连接状态
   * @param networkId
   * @param callback
   */
  public updateDeviceAddState(networkId: string, callback: (result: boolean) => void): void {
    if (this.keyMouseServiceProxy === undefined) {
      this.startKeyMoueService();
      LogUtil.showInfo(TAG, `keyMouseServiceProxy = undefined`);
      return;
    }
    this.updateDeviceAddStateCallback = callback;
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    data.writeString(networkId);
    this.sendMessage(SwitchCode.UPDATE_DEVICE_ADD_STATE, data);
  }

  /**
   * 发送设备方位信息
   * @param positionsDataList
   */
  public sendRefreshDevicePosition(positionsDataList: string[]): void {
    LogUtil.showInfo(TAG, `sendRefreshDevicePosition positionsDataList ${positionsDataList.length}`);
    if (positionsDataList.length === 0) {
      return;
    }
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    data.writeString(JSON.stringify(positionsDataList));
    this.sendMessage(SwitchCode.REFRESH_DEVICE_POSITION, data);
  }

  /**
   * 设置屏幕模式 发消息给键鼠
   * @param sourceMode
   */
  public setScreenSourceMode(sourceMode: screen.MultiScreenMode): void {
    LogUtil.showInfo(TAG, `setScreenSourceMode sourceMode ${JSON.stringify(sourceMode)}`);
    if (sourceMode === undefined) {
      return;
    }
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    data.writeInt(sourceMode);
    this.sendMessage(SwitchCode.SET_SCREEN_SOURCE_MODE, data);
  }

  refreshErrorState() {
    LogUtil.showInfo(TAG, `refreshErrorState`);
    let data = rpc.MessageSequence.create();
    data.writeInterfaceToken(KEY_MOUSE_SERVICE_DESCRIPTOR);
    this.sendMessage(SwitchCode.REFRESH_ERROR_STATE, data);
  }

  /**
   * sendMessage
   * @param data parameter data
   * @param code control code
   */
  private async sendMessage(code: number, data: rpc.MessageSequence): Promise<void> {
    if (this.keyMouseServiceProxy === undefined) {
      LogUtil.showError(TAG, 'proxy === undefined');
      data.reclaim();
      return;
    }
    let options: rpc.MessageOption = new rpc.MessageOption();
    let reply: rpc.MessageSequence = rpc.MessageSequence.create();
    try {
      const result = await this.keyMouseServiceProxy.sendMessageRequest(code, data, reply, options);
      LogUtil.showInfo(TAG, 'sendMessageRequest: ' + result.code);
      switch (code) {
        case SwitchCode.SET_SETTING_STUB:
          LogUtil.showInfo(TAG, 'sendMessageRequest stub success');
          break;
        case SwitchCode.GET_DEVICE_LIST:
          LogUtil.showInfo(TAG, 'sendMessageRequest GET_DEVICE_LIST');
          let result: string = reply.readString();
          this.refreshRemoteDevices(result);
          break;
        case SwitchCode.UPDATE_DEVICE_ADD_STATE:
          let updateResult: boolean = reply.readBoolean();
          LogUtil.showInfo(TAG, 'sendMessageRequest UPDATE_DEVICE_ADD_STATE: ' + JSON.stringify(updateResult));
          if (this.updateDeviceAddStateCallback) {
            this.updateDeviceAddStateCallback(updateResult);
          }
          break;
        case SwitchCode.DRAG_POSITION:
          let dragResult: boolean = reply.readBoolean();
          LogUtil.showInfo(TAG, 'sendMessageRequest DRAG_POSITION: ' + JSON.stringify(dragResult));
          break;
        default:
          LogUtil.showError(TAG, `code is unkown`);
          break;
      }
    } catch (error) {
      LogUtil.showError(TAG, `error code = ${error?.code} message = ${error?.message}, code =${SwitchCode[code]}`);
    } finally {
      data.reclaim();
      reply.reclaim();
    }
  }

  /**
   * 获取键鼠共享开关
   * @returns
   */
  public getKeyMouseSwitchStatus(): boolean {
    const switchValue: string = SettingsDataUtils.getSettingsData(RemoteDevicesController.SETTING_SWITCH_STATUS, '0',
      settings.domainName.USER_SECURITY);
    return switchValue.length > 0 && switchValue === '1';
  }
}