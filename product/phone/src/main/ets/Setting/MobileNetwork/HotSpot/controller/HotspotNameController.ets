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
import buffer from '@ohos.buffer';
import emitter from '@ohos.events.emitter';
import wifiManager from '@ohos.wifiManager';
import sharing from '@ohos.net.sharing';
import { BusinessError } from '@ohos.base';
import CommonEventManager from '@ohos.commonEventManager';
import connection from '@ohos.bluetooth.connection';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { CompCtrlParam, } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysUpdateDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EVENT_ID_CHANGE_HOT_SPOT_QRCODE } from '@ohos/settings.common/src/main/ets/event/types';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { DeviceNameController, SHOW_DEVICE_NAME_SHEET } from '@ohos/settings.commonUikit/src/main/ets/controller/DeviceNameController';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG: string = 'HotspotNameController';
const CONFIRM_DEVICES_NAME: string = 'confirm_devices_name';
const HOTSPOT_NAME_MAX_LENGTH: number = 30;
const HOTSPOT_NAME_ELLIPSIS: string = '...';
const PAGE_INFO: string = 'HotsPot';

export class HotspotNameController extends DeviceNameController {
  private deviceName: string;
  private isShowNameRepeatWarning: boolean = false;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE,
    ]
  };
  private apConnected: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    this.onHotSpotStateChange();
  });

  constructor(deviceName: string) {
    super();
    this.deviceName = deviceName;
    this.setResult(deviceName);
    this.setTextValue(deviceName);
    this.needReConfirm = true;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init.`);
    this.apConnected.registerCommonEvent();
  }

  destroy(): void {
    this.apConnected.unRegisterCommonEvent();
    LogUtil.info(`${TAG} destroy`);
  }

  onSheetDisappear(): void {
    this.getLatestLinkedSsid().then((latestLinkedSsid: string) => {
      if (this.deviceName === latestLinkedSsid) {
        this.stopHotSpot();
      }
    });
  }

  updateConfirm(newDeviceName: string): boolean {
    LogUtil.info(`${TAG} update confirm.`);
    let currentDeviceName: string = DeviceNameUtil.getDisplayDeviceName();
    LogUtil.info(`${TAG}  xxxxxx ${currentDeviceName} ${newDeviceName}`);
    if (currentDeviceName === newDeviceName) {
      LogUtil.info(`${TAG} device name not change, no need to refresh`);
      if (this.reConfirmCallBack) {
        this.reConfirmCallBack(true);
      }
      return false;
    }
    try {
      if ((!wifiManager.isHotspotActive() || wifiManager.getStations()?.length <= 0)) {
        LogUtil.info(`${TAG} not need dialog.`);
        EventBus.getInstance().emit('updateDeviceNameConfirm');
        return false;
      }
    } catch (error) {
      LogUtil.error(`${TAG} getStations error： ${error?.message}`);
    }
    return true;
  }

  updateDeviceName(newDeviceName: string): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysUpdateDeviceEventGroup.UPDATE_DEVICE_NAME, PAGE_INFO);
    LogUtil.info(`${TAG} update device name.`);
    if (!newDeviceName) {
      LogUtil.error(`${TAG} update device name failed.`);
      return;
    }
    DeviceNameUtil.setDisplayDeviceNameAsync(newDeviceName).then((result: boolean) => {
      if (!result) {
        LogUtil.error(`${TAG} update device name failed.`);
        this.reConfirmCallBack?.(false);
        return;
      }
      DeviceNameUtil.setMigratedDeviceName('0');
      this.updateBtNameIfNeed(newDeviceName);
      this.setResult(newDeviceName);
      this.setTextValue(newDeviceName);
      this.deviceName = this.result;
      homeInitData.deviceName = newDeviceName;
      emitter.emit({
        eventId: EVENT_ID_CHANGE_HOT_SPOT_QRCODE,
        priority: emitter.EventPriority.IMMEDIATE,
      });
      this.reConfirmCallBack?.(true);
    });
  }

  private setResult(newDeviceName: string): void {
    if (StringUtil.getStringLength(newDeviceName) > HOTSPOT_NAME_MAX_LENGTH) {
      let ellipsisLength: number = StringUtil.getStringLength(HOTSPOT_NAME_ELLIPSIS);
      this.result =
        StringUtil.getSubstringByBytes(newDeviceName, HOTSPOT_NAME_MAX_LENGTH - ellipsisLength) + HOTSPOT_NAME_ELLIPSIS;
    } else {
      this.result = newDeviceName;
    }
  }

  private setTextValue(deviceName: string): void {
    this.textValue = deviceName;
  }

  private updateBtNameIfNeed(deviceName: string): void {
    if (!BluetoothUtils.isBluetoothOn()) {
      return;
    }
    try {
      let btName: string = connection.getLocalName();
      HiSysEventUtil.reportButtonEvent(CONFIRM_DEVICES_NAME, deviceName);
      if (btName !== deviceName) {
        connection.setLocalName(deviceName);
        LogUtil.info(`${TAG} setLocalName success.`);
      } else {
        LogUtil.error(`${TAG} no need to set local name.`);
      }
    } catch (error) {
      LogUtil.error(`${TAG} setLocalName failed, error is ${error?.message}`);
    }
  }

  private async onHotSpotStateChange(): Promise<void> {
    let ssid: string = await this.getLatestLinkedSsid();
    try {
      if (ssid !== this.deviceName ?? '') {
        LogUtil.info(`${TAG} ssid not equals state.`);
        return;
      }
      if (this.isShowNameRepeatWarning || !wifiManager.isHotspotActive()) {
        return;
      }
      this.isShowNameRepeatWarning = true;
      AlertDialog.show({
        message: ResourceUtil.getStringSync($r('app.string.name_repeat_warning')),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.cancel')),
          fontColor: $r('sys.color.font_emphasize'),
          action: () => {
            this.stopHotSpot();
            this.isShowNameRepeatWarning = false;
          }
        },
        secondaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.modify')),
          fontColor: $r('sys.color.font_emphasize'),
          action: () => {
            // 拉起修改设备名称半模态
            EventBus.getInstance().emit(SHOW_DEVICE_NAME_SHEET, true);
            this.isShowNameRepeatWarning = false;
          }
        },
        cancel: () => {
          this.stopHotSpot();
          this.isShowNameRepeatWarning = false;
        }
      });
    } catch (error) {
      LogUtil.error(`${TAG} occurs error: ${error?.message}`);
    }
  }

  private stopHotSpot(): void {
    sharing.stopSharing(sharing.SharingIfaceType.SHARING_WIFI).then(() => {
      LogUtil.info(`${TAG} stopSharing success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} stopSharing fail: ${error?.message}`);
    });
  }

  private async getLatestLinkedSsid(): Promise<string> {
    try {
      let linkInfo: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
      return linkInfo.ssid;
    } catch (error) {
      LogUtil.error(`${TAG} getLinkedInfo failed: ${error?.message}`);
    }
    return '';
  }
}