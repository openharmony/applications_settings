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

import bluetooth from '@ohos.bluetooth';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';

const TAG: string = 'BluetoothPairOnlyUtil : ';

/**
 * 同类设备（手机/电脑/平板）仅配对、不建立 Profile 连接的总开关。
 */
export const ENABLE_PEER_DEVICE_PAIR_ONLY: boolean = true;

/**
 * 是否为同类终端设备（手机/电脑/平板），而非耳机/音箱/键鼠等外设。
 */
export function isPeerTerminalDevice(deviceId: string): boolean {
  if (!deviceId) {
    return false;
  }
  const deviceClass = bluetooth.getRemoteDeviceClass(deviceId);
  if (!deviceClass || !deviceClass.majorClass) {
    return false;
  }
  switch (deviceClass.majorClass) {
    case bluetooth.MajorClass.MAJOR_PHONE:
    case bluetooth.MajorClass.MAJOR_COMPUTER:
      return true;
    default:
      if (deviceClass.majorMinorClass === bluetooth.MajorMinorClass.COMPUTER_TABLET) {
        return true;
      }
      return false;
  }
}

/**
 * 是否应对该设备执行「只配对、不连接」策略。
 */
export function isPairOnlyDevice(deviceId: string): boolean {
  if (!ENABLE_PEER_DEVICE_PAIR_ONLY || !deviceId) {
    return false;
  }
  const pairOnly: boolean = isPeerTerminalDevice(deviceId);
  if (pairOnly) {
    LogUtil.info(`${TAG} isPairOnlyDevice true, deviceId:${BluetoothUtils.getLogMAC(deviceId)}`);
  }
  return pairOnly;
}
