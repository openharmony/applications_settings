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

import MdmDisable from '../other/MdmDisable';
import { ABOUT_DEVICE_NAME_COMP_ID } from './DeviceNameUtils';
import { BLUETOOTH_DEVICE_NAME_COMP_ID } from './BluetoothUtils';

const DEVICE_NAME_DISABLE: string = 'persist.edm.set_device_name_disable';
const NEARLINK_DEVICE_NAME_COMP_ID: string = 'Setting.NearLink.UpdateName';
const DEVICE_NAME_SETTINGS: string = 'DeviceNameSettings';

export default class DeviceNameDisable extends MdmDisable {
  private static instance?: DeviceNameDisable;

  private constructor() {
    super(DEVICE_NAME_DISABLE, [
      DEVICE_NAME_SETTINGS
    ], [
      ABOUT_DEVICE_NAME_COMP_ID,
      BLUETOOTH_DEVICE_NAME_COMP_ID,
      NEARLINK_DEVICE_NAME_COMP_ID
    ]);
  }

  public static getInstance(): DeviceNameDisable {
    if (!DeviceNameDisable.instance) {
      DeviceNameDisable.instance = new DeviceNameDisable();
    }
    return DeviceNameDisable.instance;
  }
}