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
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { BusinessError } from '@ohos.base';
import connection from '@ohos.bluetooth.connection';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { CHECK_SUCCESS } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import {
  DeviceNameController,
  SheetParam,
  SHOW_DEVICE_NAME_SHEET
} from '@ohos/settings.commonUikit/src/main/ets/controller/DeviceNameController';
import { wearableSheet } from '../../component/BluetoothWearableSheetComponent';
import { BluetoothDevice } from '../../model/BluetoothModel';
import { BluetoothAdapter } from '../../BluetoothAdapter';

const WEARABLE_UPDATE_NAME_SUCCESS: number = 0;
const WEARABLE_UPDATE_NAME_FAIL: number = 1;

export const WEARABLE_UPDATE_NAME_EVENT: string = 'wearable_update_name';

export class BluetoothDeviceNameController extends DeviceNameController {
  public readonly tag: string = 'BluetoothDeviceNameController : ';
  private device: BluetoothDevice;
  private isWearable: boolean = false;
  private onWearableNameChange = (name: string, code: number) => {
    let logDeviceName: string = LogMaskUtil.getLogNickNameString(name);
    LogUtil.info(`${this.tag} onWearableNameChange, name: ${logDeviceName}, code: ${code}`);
    if (StringUtil.isEmpty(name) || code === undefined || code === WEARABLE_UPDATE_NAME_FAIL) {
      LogUtil.warn(`${this.tag} onWearableNameChange fail`);
      ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.device_name_update_fail')),
        ToastUtil.SHORT_DURATION);
      EventBus.getInstance().emit(SHOW_DEVICE_NAME_SHEET, false);
      this.reConfirmCallBack?.(false);
      return;
    }
    this.device.deviceName = name;
    if (this.sheetBuilder?.param) {
      (this.sheetBuilder?.param as SheetParam).deviceName = name;
    }
    this.setResult(name);
    this.setTextValue(name);
    this.reConfirmCallBack?.(true);
  }
  public compId?: string;

  constructor(device: BluetoothDevice) {
    super();
    this.device = device;
    this.setResult(this.device?.deviceName ?? '');
    this.setTextValue(this.device?.deviceName ?? '');
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.isWearable = await this.isWearableDevice(this.device?.deviceId);
    if (this.isWearable) {
      this.sheetBuilder =
        {
          builder: wrapBuilder(wearableSheet),
          param: { deviceId: this.device?.deviceId, deviceName: this.device?.deviceName } as SheetParam
        };
      EventBus.getInstance().on(WEARABLE_UPDATE_NAME_EVENT, this.onWearableNameChange);
    }

    LogUtil.info(`${this.tag} init: ${compParam.compId}`);
    this.compId = compParam?.compId;
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    if (this.isWearable) {
      EventBus.getInstance().detach(WEARABLE_UPDATE_NAME_EVENT, this.onWearableNameChange);
    }
  }

  async checkUpdateCondition(): Promise<number> {
    return CHECK_SUCCESS;
  }

  updateDeviceName(newDeviceName: string): void {
    LogUtil.info(`${this.tag} onPrimaryButtonClick modify device name.`);
    if (!this.device || !this.device.deviceId || !newDeviceName) {
      LogUtil.error(`${this.tag} modify device name failed, deviceName is ${LogMaskUtil.getLogNickNameString(newDeviceName)}`);
      return;
    }
    let deviceId: string = this.device.deviceId ?? '';
    connection.setRemoteDeviceName(deviceId, newDeviceName).then(() => {
      LogUtil.info(`${this.tag} setRemoteDeviceName success.`);
      this.device.deviceName = newDeviceName;
      // 更新蓝牙适配器缓存，确保持久化
      BluetoothAdapter.getInstance().updateBluetoothCaches(deviceId, newDeviceName);
      BluetoothAdapter.getInstance().setBondedDevice(deviceId, this.device);
      this.setResult(newDeviceName);
      this.setTextValue(newDeviceName);
      EventBus.getInstance().emit(`${this.device?.deviceId}updateName`, newDeviceName);
      this.reConfirmCallBack?.(true);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} setRemoteDeviceName failed: error.code:  ${error?.code} error.message ${error?.message} `);
      this.reConfirmCallBack?.(false);
    });
  }

  private async isWearableDevice(deviceId: string): Promise<boolean> {
    let uri: string = ('datashareproxy://com.ohos.health.core/device_info_data');
    let context: Context = ContextUtils.getContext();
    let helper: dataShare.DataShareHelper | undefined = undefined;
    try {
      helper = await dataShare.createDataShareHelper(context, uri, { isProxy: true });
    } catch (err) {
      LogUtil.error(`${this.tag} createDataShareHelper fail: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    }
    let result: boolean = false;
    let predicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('mac', deviceId).and().equalTo('is_support_modify_name', 1);
    try {
      let dataResult: DataShareResultSet = await helper.query(uri, predicates, ['*']);
      LogUtil.info(`${this.tag} dshelper query success: ${dataResult.rowCount}`);
      result = dataResult.rowCount > 0;
      dataResult.close();
    } catch (err) {
      LogUtil.error(`${this.tag} helper query fail: ${err?.code}, errMsg: ${err?.message}`);
      return false;
    } finally {
      helper.close();
    }
    return result;
  }

  private setResult(deviceName: string): void {
    this.result = deviceName;
  }

  private setTextValue(deviceName: string): void {
    this.textValue = deviceName;
  }
}