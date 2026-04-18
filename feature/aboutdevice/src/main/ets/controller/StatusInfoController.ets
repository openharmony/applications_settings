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

// import manager from '@hms.nearlink.manager';
import wifiManager from '@ohos.wifiManager';
import batteryInfo from '@ohos.batteryInfo';
import bluetoothManager from '@ohos.bluetoothManager';
import CommonEventManager from '@ohos.commonEventManager';
import access from '@ohos.bluetooth.access';
import systemDateTime from '@ohos.systemDateTime';
import { connection } from '@kit.NetworkKit';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  BATTERY_STATUS_CHARGING,
  BATTERY_STATUS_FILLED
} from '@ohos/settings.common/src/main/ets/constant/BatteryConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { DeviceTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { AboutDeviceUtils } from '../utils/AboutDeviceUtils';

const POWER_ON_TIMER: number = 1000;
const netCon: connection.NetConnection = connection.createNetConnection();

export class BatteryStatusController implements ComponentControl {
  private tag: string = 'BatteryStatusController';
  private batteryStatus: string = '';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'init');
    this.compId = compParam?.compId;
    this.batteryStatusState.registerCommonEvent();
    this.updateBatteryStatus();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.batteryStatusState.unRegisterCommonEvent();
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_POWER_CONNECTED,
      CommonEventManager.Support.COMMON_EVENT_POWER_DISCONNECTED
    ]
  }
  private batteryStatusState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `this.subscribeInfo data: ${data?.event} err: ${err?.message}`);
    try {
      if (data?.parameters && data?.parameters['soc']) {
        let chartState: number = Number(data?.parameters['chargeState']);
        this.updateBatteryStatusByEvent(chartState);
      } else {
        this.updateBatteryStatus();
      }
    } catch (error) {
      LogUtil.showError(this.tag, `batteryStatusState subscribe fail: ${error?.message}, code: ${error?.code}`);
    }
  });

  private getBatteryStatusType(chargingStatus: number) {
    switch (chargingStatus) {
      case BATTERY_STATUS_CHARGING:
        return $r('app.string.battery_status_charging');
      case BATTERY_STATUS_FILLED:
        return $r('app.string.battery_status_filled');
      default:
        return $r('app.string.battery_status_consuming_power');
    }
  }

  private updateBatteryStatusByEvent(chartState: number): void {
    let chargingStatus: Resource = this.getBatteryStatusType(chartState);
    this.batteryStatus = ResourceUtil.getStringSync(chargingStatus);
    this.refreshUi(this.batteryStatus);
  }

  private updateBatteryStatus(): void {
    try {
      let chargingStatus: Resource = this.getBatteryStatusType(batteryInfo.chargingStatus);
      LogUtil.showInfo(this.tag, `bacharging status: ${chargingStatus}`);
      this.batteryStatus = ResourceUtil.getStringSync(chargingStatus);
    } catch (error) {
      LogUtil.showError(this.tag, `batteryInfo get battery info fail: ${error?.message}, code: ${error?.code}`);
    }
    this.refreshUi(this.batteryStatus);
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class BatteryLevelController implements ComponentControl {
  private tag: string = 'BatteryLevelController';
  private batteryLevel: string = '';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'init');
    this.compId = compParam?.compId;
    this.batteryLevelState.registerCommonEvent();
    this.updateBatteryLevel();
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    this.batteryLevelState.unRegisterCommonEvent();
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_BATTERY_CHANGED,
    ]
  }
  private batteryLevelState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.showInfo(this.tag, `this.batteryLevel data: ${data?.event} err: ${err?.message}`);
    try {
      if (data?.parameters && data?.parameters['soc']) {
        let soc: string = data?.parameters['soc'];
        this.updateBatteryLevelByEvent(soc);
      } else {
        this.updateBatteryLevel();
      }
    } catch (error) {
      LogUtil.showError(this.tag, `batteryLevelState subscribe fail: ${error?.message}, code: ${error?.code}`);
    }
  });

  private updateBatteryLevelByEvent(soc: string): void {
    this.batteryLevel = `${soc}%`;
    this.refreshUi(this.batteryLevel);
  }

  private updateBatteryLevel(): void {
    try {
      let batterySOC: string = `${batteryInfo.batterySOC}%`;
      LogUtil.showInfo(this.tag, `bbatterySOC: ${batterySOC}`);
      this.batteryLevel = batterySOC;
    } catch (error) {
      LogUtil.showError(this.tag, `batteryInfo get battery info fail: ${error?.message}, code: ${error?.code}`);
    }
    this.refreshUi(this.batteryLevel);
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class IpAddressController implements ComponentControl {
  private tag: string = 'IpAddressController';
  private compId: string = ''
  private ipAddressState: string = '';

  init(compParam: CompCtrlParam): void {
    this.compId = compParam?.compId;
    LogUtil.showInfo(this.tag, 'init');
    this.updateIpAddress();
    netCon.register(() => {
      LogUtil.showInfo(this.tag, 'register NetConnection.');
    });
    netCon.on('netConnectionPropertiesChange', (data: connection.NetConnectionPropertyInfo) => {
      LogUtil.showInfo(this.tag, 'netConnectionPropertiesChange');
      this.updateIpAddress();
    });
    // 网络断开
    netCon.on('netLost', (data: connection.NetHandle) => {
      LogUtil.showInfo(this.tag, 'netLost');
      this.ipAddressState = ResourceUtil.getStringSync($r('app.string.wifi_state_off'));
      this.refreshUi(this.ipAddressState);
    });
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    netCon.unregister(() => {
      LogUtil.showInfo(this.tag, 'unregister NetConnection.');
    });
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }

  private async updateIpAddress(): Promise<void> {
    try {
      let netHandle: connection.NetHandle = await connection.getDefaultNet();
      if (netHandle) {
        this.ipAddressState = await AboutDeviceUtils.getIpAddress(netHandle);
        LogUtil.showInfo(this.tag, 'getIpAddress success')
      }
    } catch (error) {
      LogUtil.showError(this.tag, `connection.getDefaultNet error: ${error?.message} code: ${error?.code}`);
      this.ipAddressState = ResourceUtil.getStringSync($r('app.string.wifi_state_off'));
    }
    this.refreshUi(this.ipAddressState);
  }
}

export class WlanMacController implements ComponentControl {
  private tag: string = 'WlanMacController';
  private wifiWlanMacState: string = '';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'init');
    this.compId = compParam?.compId;
    WifiUtils.wifiStateChangeOn(this.tag, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOn(this.tag, this.onWifiConnectionChange);
    let state = WifiUtils.isWifiActive();
    this.getWifiState(state);
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    WifiUtils.wifiStateChangeOff(this.tag, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOff(this.tag, this.onWifiConnectionChange);
  }

  public onWifiStateChange = (state: number) => {
    let states = WifiUtils.isWifiActive();
    this.getWifiState(states);
    AppStorage.SetOrCreate('wifi_state', state);
  }
  public onWifiConnectionChange = () => {
    let state = WifiUtils.isWifiActive();
    this.getWifiState(state);
  };

  async getWifiState(state: Boolean) {
    let randomMac = '';
    let deviceMac = '';
    if (state) {
      let wifiName = await WifiUtils.wifiLinkedInfo();
      let lastLinkedInfo = await wifiManager.getLinkedInfo();
      LogUtil.showInfo(this.tag, `MAC type ${lastLinkedInfo.macType}`);
      //随机mac地址不支持暂时只显示设备地址
      if (false) {
        if (lastLinkedInfo.macType === 0) {
          // randomMac = ResourceUtil.windowGetAnyStrFormatStringSync($r('app.string.random_mac'), lastLinkedInfo.macAddress);
          deviceMac = ResourceUtil.windowGetAnyStrFormatStringSync($r('app.string.device_mac'), WifiUtils.getDeviceMacAddress()
            .toString());
        } else {
          randomMac = lastLinkedInfo.macAddress;
        }
      } else {
        randomMac = WifiUtils.getDeviceMacAddress().toString();
      }
    } else {
      randomMac = ResourceUtil.getStringSync($r('app.string.wifi_state_off'));
    }
    if (StringUtil.isNotEmpty(deviceMac)) {
      this.wifiWlanMacState = `${randomMac}\n${deviceMac}`;
    } else {
      this.wifiWlanMacState = randomMac;
    }
    this.refreshUi(this.wifiWlanMacState);
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class BluetoothAddressController implements ComponentControl {
  private tag: string = 'BluetoothAddressController';
  private blutoothAddressState: string = '';
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, 'init');
    this.compId = compParam?.compId;
    bluetoothManager.on('stateChange', this.onBluetoothStateChange);
    let state: boolean = BluetoothUtils.isBluetoothOn();
    this.getBluetoothState(state);
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    let states: boolean = BluetoothUtils.isBluetoothOn();
    bluetoothManager.off('stateChange', this.onBluetoothStateChange);
    this.getBluetoothState(states);
  }

  public onBluetoothStateChange = (state: number) => {
    let states: boolean = BluetoothUtils.isBluetoothOn();
    this.getBluetoothState(states);
  }

  public async getBluetoothState(state: boolean) {
    if (state) {
      LogUtil.showInfo(this.tag, `isBluetoothOn ${state}`);
      try {
        let bluetoothMac: string = access.getLocalAddress();
        this.blutoothAddressState = bluetoothMac ?? ResourceUtil.getStringSync($r('app.string.wifi_state_off'));
      } catch (error) {
        this.blutoothAddressState = ResourceUtil.getStringSync($r('app.string.wifi_state_off'));
        LogUtil.showError(this.tag, `bluetoothMac error: ${error?.message} code: ${error?.code}`);
      }
    } else {
      this.blutoothAddressState = ResourceUtil.getStringSync($r('app.string.wifi_state_off'));
    }

    this.refreshUi(this.blutoothAddressState);
  }

  private refreshUi(result: string): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: result }
        } as SettingResultState]]
      )
    );
  }
}

export class PowerOnDurationController implements ComponentControl {
  private tag: string = 'PowerOnDurationController';
  private timer: number | null = null;
  private powerOnDuration: string = '';
  private powerOnTime: number = 0;
  private itemModel?: SettingItemModel;
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    this.itemModel = compParam?.component as SettingItemModel;
    this.compId = compParam?.compId;
    LogUtil.showInfo(this.tag, 'init');
    try {
      this.powerOnTime = systemDateTime.getUptime(systemDateTime.TimeType.STARTUP, false);
      LogUtil.showInfo(this.tag, `get systemDateTime getUptime info: ${this.powerOnTime}`);
    } catch (error) {
      LogUtil.showError(this.tag, `Failed to get uptime. message: ${error?.message} code: ${error?.code}`);
    }
    this.powerOnDuration = DeviceTimeUtil.formatTimeMillis(this.powerOnTime);
    this.refreshUi(this.powerOnDuration);
    //定时器每秒进行一次刷新
    this.timer = setInterval(() => {
      this.powerOnTime = this.powerOnTime + POWER_ON_TIMER;
      this.powerOnDuration = DeviceTimeUtil.formatTimeMillis(this.powerOnTime);
      this.refreshUi(this.powerOnDuration);
    }, POWER_ON_TIMER);
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, 'on destroy');
    clearInterval(this.timer);
    this.timer = null;
  }

  private refreshUi(result: string): void {
    this.itemModel?.onItemEvent?.(new Map<SettingStateType, SettingResultState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: result }
      } as SettingResultState]]
    ));
  }
}