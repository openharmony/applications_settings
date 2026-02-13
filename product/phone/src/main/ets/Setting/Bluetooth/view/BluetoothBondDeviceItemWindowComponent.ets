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
import { MenuEntry } from '@ohos/settings.bluetooth/src/main/ets/model/MenuEntry';
import {
  BluetoothWindowBondDeviceViewModel
} from '@ohos/settings.bluetooth/src/main/ets/ViewModel/BluetoothWindowBondDeviceViewModel';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BondDeviceItemWindowComponent } from '../../ControlCenterCommon/view/BondDeviceItemWindowComponent';

const TAG: string = 'BluetoothBondDeviceItemWindowComponent: ';

@Component
export struct BluetoothBondDeviceItemWindowComponent {
  private controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @ObjectLink menu: MenuEntry;
  @Prop bondDeviceViewModel: BluetoothWindowBondDeviceViewModel;

  build() {
    BondDeviceItemWindowComponent({
      symbolIcon: this.menu.icon as ResourceStr,
      title: this.menu.title,
      subTitle: this.menu.subTitle,
      isConnect: this.menu.isConnect,
      controlCenterColor: this.controlCenterColor,
      handleClickEvent: () => {
        this.handleClickEvent();
      },
    })
  }

  private handleClickEvent(): void {
    LogUtil.info(`${TAG} click device, deviceId: ${BluetoothUtils.getLogMAC(this.menu.key)}`);
    this.bondDeviceViewModel.handleBondedDeviceItemClick(this.menu.key);
  }
}
