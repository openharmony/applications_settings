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

import { nfcController } from '@kit.ConnectivityKit';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { NFCSwitchController } from './NFC/controller/NFCSwitchController';
import { NFCAnimationComponent } from './NFC/component/NFCAnimationComponent';
import { NFCTool } from './NFC/util/NFCTool';
import { NfcNotDisturbController } from './NFC/controller/NfcNotdisturbController';
import { NFCPageControl } from './NFC/controller/NFCPageController';

const DEFAULT_PAYMENT_APPLICATION_ITEM: string = 'Setting.nfc_settings.default_payment_application_group.default_payment_application_item';

@Builder
export function AnimationBuilder(param: object): void {
  NFCAnimationComponent();
}

function nfcSettingsPage(): SettingPageModel {
  let nfcSwitchController = new NFCSwitchController();
  let nfcEnabled: boolean = nfcController.isNfcOpen();
  return {
    id: 'nfc_settings',
    url: NavEntryKey.NFC_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.nfc_quick_toggle_title'),
    layout: { padding: { top: PADDING_0 } },
    compControl: new NFCPageControl(nfcSwitchController),
    groups: [
      {
        id: 'nfc_animate_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(AnimationBuilder),
      },
      // NFC开关
      {
        id: 'switch_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'switch_item',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.nfc_quick_toggle_title') },
            result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: nfcEnabled } },
            compControl: nfcSwitchController,
          }
        ]
      },
      // 默认付款应用
      {
        id: 'default_payment_application_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        cached: false,
        visible: true,
        items: [
          {
            id: 'default_payment_application_item',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.nfc_default_payment_text') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: $r('app.string.not_set') },
            },
            compControl: {
              init:()=> {
                let curDefaultPayAPPValue: string = SettingsDataUtils.getSettingsData('nfc_payment_default_app', '');
                NFCTool.notifyRefreshDefaultApp(curDefaultPayAPPValue, DEFAULT_PAYMENT_APPLICATION_ITEM);
              },
              destroy: ()=> {},
            },
            enabled: nfcEnabled,
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.PAYMENT_APPLICATION,
            },
          }
        ]
      },
      {
        id: 'nfc_not_disturb_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'nfc_not_disturb_item',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.nfc_read_not_disturb'),
            style:{opacity: nfcEnabled ? FULL_OPACITY : MASK_OPACITY}},
            result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: false, enabled: nfcEnabled } },
            compControl: new NfcNotDisturbController(),
          }
        ],
        footer: {
          id: 'nfc_not_disturb_description',
          content: $r('app.string.nfc_no_banner_text'),
        },
      },
    ],
  }
}

if (canIUse('SystemCapability.Communication.NFC.Core')) {
  PageLoader.load(NavEntryKey.NFC_ENTRY, {
    configGenerator: nfcSettingsPage,
    pageBuilder: wrapBuilder(settingPageBuilder),
  });
}