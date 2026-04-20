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

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { URL_NETWORK_SETTING_PAGE } from '@ohos/settings.wifi/src/main/ets/NetworkSettingPage';

const URL_WLAN_PAGE: string = 'open_network_entry';
const TAG: string = 'OpenNetworkEntryPage: ';

function wlanPage(): SettingPageModel {
  return {
    id: 'Wlan',
    url: URL_WLAN_PAGE,
    type: PageType.PAGE_TYPE_STANDARD,
    layout: {
      backgroundColor: Color.Transparent,
    },
    fixedGroups: [
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
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MODAL,
              icon: '',
              destination: URL_NETWORK_SETTING_PAGE,
              sheetOptions: {
                detents: [SheetSize.MEDIUM],
                showInSubWindow: true,
                dragBar: false,
                backgroundColor: $r('app.color.component_ultra_thick_panel'),
                onAppear: () => {
                  LogUtil.info(`${TAG} EditSheet onAppear.`);
                },
                onDisappear: () => {
                  LogUtil.info(`${TAG} EditSheet onDisappear.`);
                  const session: UIExtensionContentSession | undefined =
                    LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
                  session?.terminateSelf();
                }
              }
            }
          }
        ],
      }
    ],
  };
}

PageLoader.load(URL_WLAN_PAGE, {
  configGenerator: wlanPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});