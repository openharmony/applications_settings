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

import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DeviceNameItemComponent } from '@ohos/settings.commonUikit/src/main/ets/component/DeviceNameItemComponent';
import { AvailableDeviceHeaderComponent } from './AvailableDeviceHeaderComponent';
import { ConnectFailedDialogContentComponent } from './ConnectFailedDialogContentComponent';
import { DialogContentComponent } from './DialogContentComponent';
import { HelpComponent } from './HelpComponent';
import { PairFailedDialogContentComponent } from './PairFailedDialogContentComponent';
import { ProfileItemComponent } from './ProfileItemComponent';
import { OppAvailableDeviceHeaderComponent } from './OppAvailableDeviceHeaderComponent';

@Builder export function helpComponent(param: object) {
  HelpComponent();
}

@Builder export function availableDeviceHeader(param: object) {
  AvailableDeviceHeaderComponent();
}

@Builder export function oppAvailableDeviceHeader(param: object) {
  OppAvailableDeviceHeaderComponent();
}

@Builder export function profileItemBuilder(param: object) {
  ProfileItemComponent({item: param as SettingItemModel});
}

@Builder export function deviceNameItemBuilder(param: object) {
  DeviceNameItemComponent({
    item: param as SettingItemModel,
    blueToothName: true,
    maxLength: 64,
  });
}

@Builder export function disconnectRequestDialogContentBuilder(param: SettingItemModel) {
  DialogContentComponent({item: param});
}

@Builder export function pairFailedDialogContentBuilder(param: SettingItemModel) {
  PairFailedDialogContentComponent({item: param});
}

@Builder export function connectFailedDialogContentBuilder(param: SettingItemModel) {
  ConnectFailedDialogContentComponent({item: param});
}