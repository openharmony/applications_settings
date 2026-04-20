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

import {
  AirPlaneModeSwitchController
} from '@ohos/settings.network/src/main/ets/controller/AirPlaneModeSwitchController';
import { AdvancedSettingController } from '@ohos/settings.network/src/main/ets/controller/AdvancedSettingController';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  EthernetConnectStatusController
} from '@ohos/settings.network/src/main/ets/controller/EthernetConnectStatusController';
import { EthernetDetailSettingView } from '@ohos/settings.network/src/main/ets/view/EthernetDetailSettingView';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysNetworkGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import {
  WiredNetworkSettingPresenter
} from '@ohos/settings.network/src/main/ets/controller/WiredNetworkSettingPresenter';
import { WlanStatusController } from '@ohos/settings.network/src/main/ets/controller/WlanStatusController';
import { VpnTypeModel } from '@ohos/settings.vpn/src/main/ets/model/VpnTypeModel';
/* instrument ignore file */
const TAG: string = 'NetworkPageController : ';
const PROXY_PAGE: string = 'proxy_page';

@Builder
function pcEthernetDetailSettingBuilder(param: object) {
  EthernetDetailSettingView();
}

/**
 * 网络页面控制器类
 */
export class NetworkPageController implements ComponentControl {
  private isInitialised: boolean = false;
  private params: PushParam = new PushParam();
  private settingPageModel?: SettingPageModel;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.param) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.params = compParam.param as PushParam;
    this.settingPageModel = compParam.component as SettingPageModel;

    // 兼容外部浏览器要直接跳转到网络设置-代理页面
    if (this.params.subUri === PROXY_PAGE) {
      LogUtil.info(`${TAG} jump to proxy page from external.`);
      PageRouter.push(NavEntryKey.PC_NETWORK_PROXY_SETTINGS, undefined, false, true);
    }

    // WLAN
    this.addWlanGroup();
    // 以太网状态面板
    this.addEthernetStatusGroup();
    // 以太网详情面板
    this.addEthernetDetailSettingsGroup();
    // 以太网高级设置
    this.addEthernetAdvancedSettingsGroup();
    // 飞行模式
    this.addAirPlaneGroup();
    // 代理
    this.addProxySettingsGroup();
    // VPN
    this.addVpnGroup();
    // 流量管理
    this.addDataManagerGroup();
    this.doInit();
    this.isInitialised = true;
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    // 休眠唤醒场景有一定概率出现init - destroy - onPageShow的错误生命周期，导致网络监听注册失败，先增加标记来规避
    if (!this.isInitialised) {
      this.doInit();
      this.isInitialised = true;
    }
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    WiredNetworkSettingPresenter.getInstance().unregisterNetStatusListener();
    this.isInitialised = false;
  }

  addWlanGroup(): void {
    let model: SettingGroupModel = {
      id: 'pc_network_wlan_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'pc_network_wlan_setting',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.wifi_settings_title') },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: WifiUtils.isWifiActive() ? $r('app.string.projection_state_on') :
              $r('app.string.projection_state_off')
            },
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_CUSTOM,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            iconType: SettingIconType.ICON_TYPE_ARROW,
            onItemClick: () => {
              PageRouter.push(NavEntryKey.WIFI_ENTRY, undefined, false, undefined, true);
              HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysNetworkGroup.ENTER_WLAN_ENTRY_FORM_NETWORK);
            },
          },
          compControl: new WlanStatusController()
        },
      ],
    };
    this.settingPageModel?.groups?.push(model);
  }

  addEthernetStatusGroup() {
    let model: SettingGroupModel = {
      id: 'pc_ethernet_status_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      header: { id: 'pc_ethernet_header', content: $r('app.string.network_title') },
      items: [
        {
          id: 'pc_ethernet_status',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.network_title')
          },
          desc: { content: $r('app.string.ethernet_status_disconnected') },
          compControl: new EthernetConnectStatusController(),
          focusable: false
        },
      ],
    };
    this.settingPageModel?.groups?.push(model);
  }

  addEthernetDetailSettingsGroup() {
    let model: SettingGroupModel = {
      id: 'pc_ethernet_setting_group',
      type: GroupType.GROUP_TYPE_CUSTOM,
      visible: false,
      builder: wrapBuilder(pcEthernetDetailSettingBuilder),
    };
    this.settingPageModel?.groups?.push(model);
  }

  addEthernetAdvancedSettingsGroup() {
    let model: SettingGroupModel = {
      id: 'pc_ethernet_advanced_group',
      type: GroupType.GROUP_TYPE_DYNAMIC,
      visible: false,
      compControl: new AdvancedSettingController(),
    };
    this.settingPageModel?.groups?.push(model);
  }

  addAirPlaneGroup() {
    let model: SettingGroupModel = {
      id: 'air_plane_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      header: { id: 'other_service_header', content: $r('app.string.network_proxy_head') },
      items: [
        {
          id: 'air_plane_mode_setting',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.airplane_mode')
          },
          desc: { content: $r('app.string.airplane_mode_describe') },
          result: {
            type: ItemResultType.RESULT_TYPE_TOGGLE,
            result: {
              state: false,
            }
          },
          compControl: new AirPlaneModeSwitchController()
        },
      ],
    };
    this.settingPageModel?.groups?.push(model);
  }

  addProxySettingsGroup() {
    let model: SettingGroupModel = {
      id: 'proxy_setting_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'proxy_setting',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.network_proxy_title')
          },
          desc: { content: $r('app.string.network_proxy_describe') },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            iconType: SettingIconType.ICON_TYPE_ARROW,
            destination: NavEntryKey.PC_NETWORK_PROXY_SETTINGS,
          },
        },
      ],
    };
    this.settingPageModel?.groups?.push(model);
  }

  addVpnGroup(): void {
    let isSupportVpn = VpnTypeModel.getInstance().isSupportVpn();
    if (!isSupportVpn) {
      LogUtil.info('isSupportVpn false, return');
      return;
    }
    let model: SettingGroupModel = {
      id: 'vpn_group_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      cached: false,
      visible: true,
      items: [
        {
          id: 'vpn_settings',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.VPN')
          },
          desc: { content: $r('app.string.vpn_describe') },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
            icon: $r('app.media.ic_settings_arrow'),
            iconType: SettingIconType.ICON_TYPE_ARROW,
            destination: NavEntryKey.VPN_SETTINGS_ENTRY,
          }
        }
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  addDataManagerGroup(): void {
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
            iconType: SettingIconType.ICON_TYPE_ARROW,
            destination: NavEntryKey.DATA_USAGE_MANAGEMENT_ENTRY,
          },
        }
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }

  private doInit() {
    WiredNetworkSettingPresenter.getInstance().init();
    WiredNetworkSettingPresenter.getInstance().registerNetStatusListener();
  }
}
