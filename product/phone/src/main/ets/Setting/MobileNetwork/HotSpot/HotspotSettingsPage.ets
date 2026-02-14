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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import DeviceNameDisable from '@ohos/settings.common/src/main/ets/utils/DeviceNameDisable';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { DeviceNameItemComponent } from '@ohos/settings.commonUikit/src/main/ets/component/DeviceNameItemComponent';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HotSpotAboutComponent } from './view/HotSpotAboutComponent';
import { HotspotSwitchController } from './controller/HotspotSwitchController';
import { HotspotQrcodeCardController } from './controller/HotspotQrcodeCardController';
import { HotspotPwdController } from './controller/HotspotPwdController';
import { HotspotNameController } from './controller/HotspotNameController';
import { HotspotConnectedController } from './controller/HotspotConnectedController';
import { HOT_SPOT_PSW_SHEET_PAGE } from './HotspotPasswordSheetPage';
/* instrument ignore file */
const SCREEN_HEIGHT_RATE: number = 0.76;
const MAX_LINES_10: number = 10;

@Builder
function hotspotAboutFooter(param: object): void {
  HotSpotAboutComponent({
    param: param,
  });
}

@Builder
function deviceNameItemBuilder(param: object) {
  DeviceNameItemComponent({
    item: param as SettingItemModel,
    maxLength: 100,
    hint: CapabilitySupportUtils.isSupportNearLink() ? $r('app.string.device_name_settings_summary_with_near_link') :
    $r('app.string.device_name_settings_summary_new'),
  });
}

function hotspotSettingsPage(): SettingPageModel {
  let enable: boolean = !SatelliteUtils.isCommunicationOpen();
  let hotspotConnectedController: HotspotConnectedController = new HotspotConnectedController();
  let hotspotSwitchController: HotspotSwitchController = new HotspotSwitchController();//包含热点toggle是否可以点击
  let hotspotPwdController: HotspotPwdController = new HotspotPwdController();
  let deviceName: string = DeviceNameUtil.getDisplayDeviceName();
  return {
    id: 'hotspot_data_entry',
    url: NavEntryKey.MOBILE_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.hotspot_settings_title')),
    compControl: {
      init: (compParam: CompCtrlParam) => {
        DeviceNameDisable.getInstance().disableItems();
      },
      destroy: () => {},
      onPageShow: (component: SettingBaseModel) => {
        if (DeviceNameDisable.getInstance().disableItems()) {
          DeviceNameDisable.getInstance().notifyMenuDisable();
        }
        hotspotConnectedController.onPageShow(component);
        hotspotSwitchController.onPageShow(component);
        hotspotPwdController.onPageShow(component);
      },
      onPageHide: (component: SettingBaseModel) => {
        hotspotConnectedController.onPageHide(component);
        hotspotSwitchController.onPageHide(component);
        hotspotPwdController.onPageHide(component);
      },
    },
    groups: [
      {
        id: 'hotspot_switch',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'hotspot_switch_setting',
            type: ItemType.ITEM_TYPE_STANDARD,

            title: { content: $r('app.string.hotspot_settings_title') },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: {
                state: true,
                enabled: enable,
              }
            },
            compControl: hotspotSwitchController,
          },
        ],
      },
      {
        id: 'qr_code_group',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: new HotspotQrcodeCardController(),
      },
      {
        id: 'hotspot_devices_info',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'hot_spot_device_name',
            type: ItemType.ITEM_TYPE_CUSTOM,
            enabled: enable && !DeviceNameDisable.getInstance().getDisable(),
            title: { content: $r('app.string.hotspot_device_name') },
            builder: wrapBuilder(deviceNameItemBuilder),
            compControl: new HotspotNameController(deviceName),
          },
          {
            id: 'password_entry',
            type: ItemType.ITEM_TYPE_STANDARD,
            enabled: enable,
            title: {
              content: $r('app.string.hotspot_password'),
            },
            compControl: hotspotPwdController,
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MODAL,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: HOT_SPOT_PSW_SHEET_PAGE,
              sheetOptions: {
                detents: [DeviceUtil.isNexFormsProduct() ? SheetSize.LARGE :
                  DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE],
                height: SheetSize.LARGE,
                backgroundColor: $r('app.color.component_ultra_thick_panel'),
                dragBar: false,
                showClose: false,
                keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
              }
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: '',
                style: {
                  maxLines: MAX_LINES_10,
                  wordBreak: WordBreak.BREAK_WORD,
                },
              }
            }
          },
          {
            id: 'connected_device_entry',
            type: ItemType.ITEM_TYPE_STANDARD,
            enabled: enable,
            compControl: hotspotConnectedController,
            title: {
              content: $r('app.string.hotspot_connected_device'),
              style: {
                maxLines: MAX_LINES_10,
                wordBreak: WordBreak.BREAK_WORD,
              },
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: ''
              }
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.HOTSPOT_CONNECTED_ENTRY,
            }
          }
        ]
      },
      {
        id: 'hotspot_more_settings',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: {
          id: 'hotspot_about',
          enabled: enable,
          builder: wrapBuilder(hotspotAboutFooter),
        },
        items: [
          {
            id: 'more_share_entry',
            type: ItemType.ITEM_TYPE_STANDARD,
            enabled: enable,
            title: {
              content: $r('app.string.hotspot_more_share_settings')
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.HOTSPOT_SHARE_ENTRY,
            }
          }
        ]
      }
    ],
  };
}

PageLoader.load(NavEntryKey.HOTSPOT_ENTRY, {
  configGenerator: hotspotSettingsPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});