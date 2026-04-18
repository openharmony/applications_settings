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
import {
  CardMenuSection,
  DefaultEntryMenuStyle,
  StateMenu,
  StateTextStyle,
  SwitchMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import WirelessSwitchController, {
  DeviceShowController,
  IpAddressController
} from '../controller/WirelessCommissioningController';
import { PageUrl } from '../../PageUrl';

class WirelessTextStyle extends StateTextStyle {
  public constraintSize: ConstraintSizeOptions = {
    maxWidth: 'calc(100% - 30vp)'
  }
}

let wirelessTextStyle = new WirelessTextStyle();

// 设置时间菜单窗口偏移量
class WirelessMenuStyle extends DefaultEntryMenuStyle {
  public startFlexShrink: number = 0;
  public endFlexShrink: number = 1;
  public state: TextStyle = wirelessTextStyle;
}

/**
 * 无线调试页面数据
 *
 * @since 2023-12-13
 */

export class WirelessCommissioningComponents extends SettingHeaderPage {
  public status: boolean = false;

  constructor(pathInfos: NavPathStack, status: boolean) {
    super({
      pageUrl: PageUrl.WIRELESS_COMISSIONING_URL,
      title: $r('app.string.wireless_commissioning'),
      isNavigation: true,
      showHeader: false,
    });
    this.status = status;
    this.addMenus([
    // index 用于菜单排序
      new CardMenuSection(
        {
          key: 'development_personnel',
          index: 10,
        },
        [
          new SwitchMenu(
            {
              key: 'development_personnel_option',
              index: 20,
              title: $r('app.string.wireless_commissioning'),
              controller: {
                createControllerConstructorInter: WirelessSwitchController.CreateWirelessSwitchController,
              },
              pathInfos: pathInfos
            }
          ),
        ]
      ),
      new CardMenuSection(
        {
          key: 'automatic_update',
          index: 10,
          controller: {
            createControllerConstructorInter: DeviceShowController.CreateDeviceShowController,
          },
          extra: status
        },
        [
          new StateMenu({
            key: 'system_rollback_settings',
            index: 30,
            title: $r('app.string.device_name_settings_title'),
            style: new WirelessMenuStyle,
            state: DeviceNameUtil.getDisplayDeviceName()
          }),
          new StateMenu({
            key: 'system_wireless_commissioning',
            index: 40,
            title: $r('app.string.ip_address_and_port'),
            controller: {
              createControllerConstructorInter: IpAddressController.CreateIpAddressController,
            }
          })
        ]
      )
    ]
    );

  }
}