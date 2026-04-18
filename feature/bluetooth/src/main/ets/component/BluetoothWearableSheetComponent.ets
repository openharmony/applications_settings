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
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil, LogMaskUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SheetParam } from '@ohos/settings.commonUikit/src/main/ets/controller/DeviceNameController';
import { WEARABLE_UPDATE_NAME_EVENT } from '../controller/BondedDevice/BluetoothDeviceNameController';

const TAG: string = 'BluetoothWearableSheetComponent : ';
const BUNDLE_NAME: string = 'com.ohos.health';
const ABILITY_NAME: string = 'ModifyDeviceNameExtensionAbility';

@Builder
export function wearableSheet(param: object) {
  BluetoothWearableSheetComponent({
    param: param
  });
}

@Component
export struct BluetoothWearableSheetComponent {
  param?: SheetParam;

  aboutToAppear() {
    let logDeviceId: string = BluetoothUtils.getLogMAC(this.param?.deviceId ?? '');
    let logDeviceName: string = LogMaskUtil.getLogNickNameString(this.param?.deviceName ?? '');
    LogUtil.info(`${TAG} aboutToAppear deviceId: ${logDeviceId} name: ${logDeviceName}`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  build() {
    Column() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'deviceId': this.param?.deviceId ?? '',
          'deviceName': this.param?.deviceName ?? ''
        }
      })
        .defaultFocus(true)
        .onError((error) => {
          LogUtil.error(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
        })
        .onTerminated((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onTerminated`);
          if (!data?.want?.parameters) {
            LogUtil.warn(`${TAG} UIExtensionComponent onTerminated param empty`);
            EventBus.getInstance().emit(WEARABLE_UPDATE_NAME_EVENT);
            return;
          }
          EventBus.getInstance().emit(WEARABLE_UPDATE_NAME_EVENT, data.want.parameters['result'], data.want.parameters['resultCode']);
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }
}