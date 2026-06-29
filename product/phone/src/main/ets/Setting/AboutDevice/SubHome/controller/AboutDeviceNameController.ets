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

import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { DeviceNameController } from '@ohos/settings.commonUikit/src/main/ets/controller/DeviceNameController';
import { LogUtil, LogMaskUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysUpdateDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

/* instrument ignore file */
const PAGE_INFO: string = 'AboutDevice';

export class AboutDeviceNameController extends DeviceNameController {
  public readonly tag: string = 'AboutDeviceNameController : ';

  constructor() {
    super();
    let deviceName: string = DeviceNameUtil.getDisplayDeviceName();
    this.setResult(deviceName);
    this.setTextValue(deviceName);
  }

  updateDeviceName(newDeviceName: string): void {
    LogUtil.info(`${this.tag} onPrimaryButtonClick deviceName : ${LogMaskUtil.getLogNickNameString(newDeviceName)}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysUpdateDeviceEventGroup.UPDATE_DEVICE_NAME, PAGE_INFO);
    DeviceNameUtil.setDisplayDeviceNameAsync(newDeviceName).then((result: boolean) => {
      if (!result) {
        LogUtil.warn(`${this.tag} updateDeviceName fail`);
        this.reConfirmCallBack?.(false);
        return;
      }
      DeviceNameUtil.setMigratedDeviceName('0');
      homeInitData.deviceName = newDeviceName;
      this.setResult(newDeviceName);
      this.setTextValue(newDeviceName);
      this.reConfirmCallBack?.(true);
    });
  }

  private setResult(deviceName: string): void {
    this.result = deviceName;
  }

  private setTextValue(deviceName: string): void {
    this.textValue = deviceName;
  }
}