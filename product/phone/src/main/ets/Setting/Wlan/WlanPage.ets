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

import wifiManager from '@ohos.wifiManager';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { PADDING_0, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { WifiPrecisionModel } from '@ohos/settings.wifi/src/main/ets/model/WifiPrecisionModel';
import { WifiPrecisionComponent } from '@ohos/settings.wifi/src/main/ets/component/WifiPrecisionComponent';
import { WlanSecurityCheckComponent } from '@ohos/settings.wifi/src/main/ets/component/WlanSecurityCheckComponent';
import { WlanPullLoadingComponent } from '@ohos/settings.wifi/src/main/ets/component/WlanPullLoadingComponent';
import { OtherWlanHeaderComponent } from '@ohos/settings.wifi/src/main/ets/component/OtherWlanHeaderComponent';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { WlanPullLoadingController } from '@ohos/settings.wifi/src/main/ets/controller/WlanPullLoadingController';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { OTHER_WLAN_SHEET_SHOW_EVENT } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WifiMenuManager } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { URL_WLAN_DETAIL_PAGE } from '@ohos/settings.wifi/src/main/ets/WifiPasswordSettingsSheet';
import { WifiSwitchController } from '@ohos/settings.wifi/src/main/ets/controller/new/WifiSwitchController';
import AvailableWlanController from '@ohos/settings.wifi/src/main/ets/controller/new/AvailableWlanController';
import SharedNetworkController from '@ohos/settings.wifi/src/main/ets/controller/new/SharedNetworkController';
import {
  AddOtherWlanGroupController
} from '@ohos/settings.wifi/src/main/ets/controller/new/AddOtherWlanGroupController';
import {
  WifiSecurityCheckGroupController
} from '@ohos/settings.wifi/src/main/ets/controller/new/WifiSecurityCheckGroupController';
import { ShareWlanController } from '@ohos/settings.wifi/src/main/ets/controller/new/ShareWlanController';
import { OtherWlanListController } from '@ohos/settings.wifi/src/main/ets/controller/new/OtherWlanListController';
import { WifiEntryParams } from '../../pages/wifi/controller/WifiEntryController';
/* instrument ignore file */
const URL_WLAN_PAGE: string = 'wifi_entry';
const TAG: string = 'WlanPage';

@Builder
function wlanConfigFooter(param: object): void {
  WifiPrecisionComponent({
    param: param,
  });
}

@Builder
function wlanSecurityCheckFooter(param: object): void {
  WlanSecurityCheckComponent();
}

@Builder
function wlanPullLoading(param: object): void {
  WlanPullLoadingComponent({
    param: param,
  });
}

@Builder
function otherWlanHeader(param: object) {
  OtherWlanHeaderComponent();
}

function wlanPage(): SettingPageModel {
  let enable: boolean = !SatelliteUtils.isCommunicationOpen();
  let isWifiActive: boolean = WifiUtils.isWifiActive();
  let wifiSwitchController = new WifiSwitchController()
  let availableWlanController = new AvailableWlanController();
  let otherWlanListController = new OtherWlanListController();
  let pullLoadingController = new WlanPullLoadingController();
  let sharedNetworkController = new SharedNetworkController();
  let shareWlanController = new ShareWlanController();
  let isInOObeStage: boolean = WifiMenuManager.isInOObeStage();
  return {
    id: 'Wlan',
    url: URL_WLAN_PAGE,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.wifi_settings_title')),
    layout: {
      backgroundColor: isInOObeStage ? Color.Transparent : undefined,
      hideTitleBar: isInOObeStage,
    },
    barState: isInOObeStage ? BarState.Off : undefined,
    compControl: {
      init: (compParam: CompCtrlParam) => {
        console.log('zzzzzzzzz wlan init')
        // 控制中心点击加密wlan进入
        let param: PushParam = compParam.param as PushParam;
        if ((param?.config as WifiEntryParams)?.needShowModal) {
          otherWlanListController.jumpConfig = (param.config as WifiEntryParams).config as wifiManager.WifiDeviceConfig;
        } else {
          otherWlanListController.jumpConfig = null;
        }
        shareWlanController.init();
        LogUtil.info(`${TAG} WlanPage init, is jumpConfig: ${otherWlanListController.jumpConfig !== null}`);
      },
      destroy: () => {
        shareWlanController.destroy();
        LogUtil.info(`${TAG} WlanPage destroy.`);
      },
      onPageShow: (component: SettingBaseModel) => {
        wifiSwitchController.onPageShow(component);
        availableWlanController.onPageShow(component);
        otherWlanListController.onPageShow(component);
        shareWlanController.onPageShow();
      },
      onPageHide: (component: SettingBaseModel) => {
        wifiSwitchController.onPageHide(component);
        availableWlanController.onPageHide(component);
        otherWlanListController.onPageHide(component);
        shareWlanController.onPageHide();
      },
    },
    scrollListener: {
      onScrollStop: () => {
        pullLoadingController.onScrollStop();
        otherWlanListController.onScrollStop();
      },
      onScrollStart: () => {
        if (isInOObeStage) {
          notifyCompStateChange('Setting.Wlan', new Map<SettingStateType, SettingBaseState>(
            [[SettingStateType.STATE_TYPE_SCROLLBAR, { state: true } as SettingCompState]]
          ));
        }
        otherWlanListController.onScrollStart();
      },
      onReachStart: () => {
        pullLoadingController.onReachStart();
      },
      onScroll: (yOffset, state) => {
        pullLoadingController.onScroll(yOffset, state);
      }
    },
    groupForeground: {
      id: 'WlanPullLoading',
      builder: wrapBuilder(wlanPullLoading),
      compControl: pullLoadingController,
      visible: isWifiActive,
    },
    menus: [
      {
        icon: $r('app.media.ic_public_more'),
        style: {
          width: 24,
          height: 24,
          fillColor: $r('sys.color.icon_primary'),
          accessibilityText: $r('app.string.more_options'),
          draggable: false
        },
        bindMenu: [
          {
            value: $r('app.string.wifi_install_certificates'),
            action: () => {
              let pathInfoStack: NavPathStack | undefined =
                AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
              DynamicLoader.getInstance().fire(NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY).then(() => {
                pathInfoStack?.pushPathByName(NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY, undefined);
              });
            }
          }
        ],
      }
    ],
    fixedGroups: [
      {
        id: 'WlanConfig',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: isInOObeStage ? undefined : {
          id: 'WlanConfigFooter',
          builder: wrapBuilder(wlanConfigFooter),
          isWifiActive: isWifiActive,
        } as WifiPrecisionModel,
        layout: {
          margin: {
            bottom: isInOObeStage ? PADDING_16 : PADDING_0,
          },
        },
        items: [
          {
            id: 'WlanSwitch',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: 'WLAN' },
            enabled: enable,
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: {
                state: isWifiActive,
                enabled: WifiUtils.isWifiEnabled(),
              }
            },
            compControl: wifiSwitchController,
            layout: { background: { pressedBackgroundColor: Color.Transparent }},
          },
        ],
      },
      // 隐藏菜单、用于弹出半模态弹窗
      {
        id: 'EditSheetConfig',
        type: GroupType.GROUP_TYPE_STANDARD,
        visible: false,
        items: [
          {
            id: 'EditSheet',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: '' },
            visible: true,
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: '',
              }
            },
            compControl: new WifiSwitchController(),
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MODAL,
              icon: '',
              destination: URL_WLAN_DETAIL_PAGE,
              sheetOptions: {
                detents: [SheetSize.LARGE],
                dragBar: false,
                backgroundColor: $r('app.color.component_ultra_thick_panel'),
                onAppear: () => {
                  LogUtil.info(`${TAG} EditSheet onAppear.`);
                  EventBus.getInstance().emit(OTHER_WLAN_SHEET_SHOW_EVENT, true);
                  PasswordUtil.setPrivacyMode(true);
                },
                onDisappear: () => {
                  LogUtil.info(`${TAG} EditSheet onDisappear.`);
                  EventBus.getInstance().emit(OTHER_WLAN_SHEET_SHOW_EVENT, false);
                  PasswordUtil.setPrivacyMode(false);
                }
              }
            }
          }
        ],
      }
    ],
    groups: [
      {
        id: 'SharedNetwork',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: false,
        header: {
          id: 'SharedNetworkHeader',
          content: $r('app.string.shared_network_ap_group'),
          style: {
            height: 40,
            fontSize: $r('sys.float.Subtitle_S'),
            fontColor: $r('sys.color.font_secondary'),
            fontWeight: FontWeight.Medium,
          }
        },
        compControl: sharedNetworkController,
        needHide: false,
      },
      {
        id: 'AvailableWlan',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: isWifiActive,
        header: {
          id: 'AvailableWlanHeader',
          content: $r('app.string.wifi_available_ap_group'),
          style: {
            height: 40,
            fontSize: $r('sys.float.Subtitle_S'),
            fontColor: $r('sys.color.font_secondary'),
            fontWeight: FontWeight.Medium,
          }
        },
        compControl: availableWlanController,
      },
      {
        id: 'OtherWlan',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: isWifiActive,
        header: {
          id: 'AvailableDeviceHeader',
          builder: wrapBuilder(otherWlanHeader),
        },
        compControl: otherWlanListController,
      },
      {
        id: 'AddOtherWlan',
        // 这里需要动态显示隐藏，因此用GROUP_TYPE_DYNAMIC
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: isWifiActive,
        compControl: new AddOtherWlanGroupController(),
      },
      {
        id: 'WlanSecurityCheck',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: !isInOObeStage && isWifiActive,
        footer: {
          id: 'WlanSecurityCheckFooter',
          builder: wrapBuilder(wlanSecurityCheckFooter),
        },
        compControl: new WifiSecurityCheckGroupController(),
      }
    ],
  };
}

PageLoader.load(URL_WLAN_PAGE, {
  configGenerator: wlanPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});