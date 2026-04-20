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

import common from '@ohos.app.ability.common';
import { homeInitData, LogUtil } from '@ohos/settings.common';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  AccountUtil, CHECK_SUCCESS_CODE, CHECK_FAIL_CODE
} from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import {
  DeviceNameUtil,
  CHECK_SUCCESS,
  CHECK_FAIL_REASON_NETWORK,
  CHECK_FAIL_REASON_LOG_IN
} from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { NetworkUtils } from '@ohos/settings.common/src/main/ets/utils/NetworkUtils';
/* instrument ignore file */
const TAG: string = 'DeviceNameController';

export const SHOW_DEVICE_NAME_SHEET: string = 'SHOW_DEVICE_NAME_SHEET';

export interface SheetParam {
  deviceId?: string,
  deviceName?: string
}

export interface SheetBuilderInfo {
  builder: WrappedBuilder<[object]>,
  param?: object
}

export class DeviceNameController implements ComponentControl {
  // SettingItemModel的result信息
  public result: string = '';

  // 半模态显示的信息
  public textValue: string = '';

  // 再次确认回调
  public reConfirmCallBack?: (result: boolean) => void;

  public needReConfirm?: boolean = false;

  public sheetBuilder?: SheetBuilderInfo;

  init(compParam?: CompCtrlParam): void {
  }

  destroy(): void {
  }

  onPrimaryButtonClick(context: common.Context, newDeviceName: string) {
    if (!newDeviceName.trim()) {
      return;
    }
    let name = DeviceNameUtil.getDisplayDeviceName();
    LogUtil.info(`xxxxxxxxxxxxxxxxxxxxxxxxx ${name} --- ${newDeviceName}`);
    if (name === newDeviceName) {
      if (this.reConfirmCallBack) {
        this.reConfirmCallBack(true);
      }
      return;
    }
    this.updateDeviceName(newDeviceName);
  }

  async checkUpdateCondition(): Promise<number> {
    if (!NetworkUtils.isNetworkAvailable()) {
      return CHECK_FAIL_REASON_NETWORK;
    }
    // if (!await AccountUtil.isAccountLogged()) {
    //   return CHECK_FAIL_REASON_LOG_IN;
    // }
    return CHECK_SUCCESS;
  }

  updateDeviceName(newDeviceName: string): void {
    DeviceNameUtil.setDisplayDeviceNameAsync(newDeviceName).then((result: boolean) => {
      if (!result) {
        LogUtil.warn(`xxxxxxx updateDeviceName fail`);
        this.reConfirmCallBack?.(false);
        return;
      }
      DeviceNameUtil.setMigratedDeviceName('0');
      homeInitData.deviceName = newDeviceName;
      // this.setResult(newDeviceName);
      // this.setTextValue(newDeviceName);
      this.reConfirmCallBack?.(true);
    });
  }

  updateConfirm(newDeviceName: string): boolean {
    return true;
  }

  onSheetDisappear(): void {
  }
}