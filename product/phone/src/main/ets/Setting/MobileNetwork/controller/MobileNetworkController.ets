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

import { bundleManager } from '@kit.AbilityKit';
import call from '@ohos.telephony.call';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil'
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';

import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AirPlaneModeSwitchController } from './AirPlaneModeSwitchController';
/* instrument ignore file */
export class MobileNetworkController implements ComponentControl {
  public readonly tag: string = 'MobileNetworkController : ';
  private readonly FIRST_SKYTONE_VER: number = 50003000;
  private settingPageModel?: SettingPageModel;
  private isMobileDateAvailable?: boolean;
  private airPlaneModeSwitchController = new AirPlaneModeSwitchController();

  init(compParam: CompCtrlParam): void {
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    this.isMobileDateAvailable = call.hasVoiceCapability();
    LogUtil.info(`${this.tag} addMobileNetworkVisibleMenus, isMobileDateAvailable: ${this.isMobileDateAvailable}`);
    this.addAirPlaneMenuGroup();
    this.addDataUsageMenuGroup();
  }

  destroy(): void {
    this.airPlaneModeSwitchController.destroy();
  }

  onPageShow(component: SettingBaseModel): void {
    this.airPlaneModeSwitchController.onPageShow(component);
  }

  onPageHide(component: SettingBaseModel): void {
    this.airPlaneModeSwitchController.onPageHide(component);
  }

  addAirPlaneMenuGroup(): void {
    let mobileDataItems = this.getMobileDataItems();
    let model: SettingGroupModel = {
      id: 'air_plane_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'air_plane_mode_setting',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.airplane_mode')
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TOGGLE,
            result: {
              state: false,
            }
          },
          compControl: this.airPlaneModeSwitchController
        },
        ...mobileDataItems
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  addDataUsageMenuGroup(): void {
    let model: SettingGroupModel = {
      id: 'data_usage_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: 'mobile_data_manage_entry',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.data_usage_management_title')
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            destination: NavEntryKey.DATA_USAGE_MANAGEMENT_ENTRY,
          },
        }
      ]
    }
    this.settingPageModel?.groups?.push(model);
  }

  getMobileDataItems(): SettingItemModel[] {
    let mobileDataItems: SettingItemModel[] = [];
    if (this.isMobileDateAvailable) {
      mobileDataItems.push(
        {
          id: 'mobile_data_setting_entry',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.mobile_data_setting_title')
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            destination: NavEntryKey.MOBILE_DATA_SETTING_ENTRY,
          }
        },
        {
          id: 'hotspot_data_settings',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.hotspot_settings_title')
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            destination: NavEntryKey.HOTSPOT_ENTRY,
          },
          needHide: () => {
            return !AccountUtil.isMainUser();
          }
        }
      )
    }
    return mobileDataItems;
  }
}