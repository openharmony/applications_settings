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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { BrowserRadioController } from '@ohos/settings.application/src/main/ets/controller/BrowserRadioController';
import { BrowserListController } from '@ohos/settings.application/src/main/ets/controller/BrowserListController';
import { PADDING_0, PADDING_24, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

const TAG: string = 'DefaultBrowserPage:';

function customPage(): SettingPageModel {
  const radioController: BrowserRadioController = new BrowserRadioController();
  const systemBrowserListController: BrowserListController = new BrowserListController(radioController, true);
  const noSystemBrowserListController: BrowserListController = new BrowserListController(radioController, false);
  return {
    id: 'BrowserList',
    url: NavEntryKey.DEFAULT_BROWSER_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.default_browser')),
    header: {
      id: 'BrowserListHeader',
      content: $r('app.string.app_info_default_content'),
      style: {
        fontSize: $r('sys.float.Subtitle_S'),
        fontColor: $r('sys.color.font_secondary'),
        fontWeight: FontWeight.Medium,
        padding: { start: PADDING_8, end: PADDING_8, top: PADDING_0, bottom: PADDING_24 },
      }
    },
    groups: [
      {
        id: 'SystemBrowserGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: systemBrowserListController,
      },
      {
        id: 'NoSystemBrowserGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: noSystemBrowserListController,
      }
    ],
    compControl: {
      init: (compParam: CompCtrlParam) => {
        LogUtil.info(`${TAG} init.`);
        radioController.init(compParam);
      },
      destroy: () => {
        LogUtil.info(`${TAG} destroy.`);
        radioController.destroy();
      },
      onPageShow: (component: SettingBaseModel) => {
        LogUtil.info(`${TAG} onPageShow.`);
        systemBrowserListController.onPageShow(component);
        noSystemBrowserListController.onPageShow(component);
        radioController.onPageShow(component);
      },
      onPageHide: (component: SettingBaseModel) => {
        LogUtil.info(`${TAG} onPageHide.`);
        systemBrowserListController.onPageHide(component);
        noSystemBrowserListController.onPageHide(component);
        radioController.onPageHide(component);
      },
    },
  }
}

PageLoader.load(NavEntryKey.DEFAULT_BROWSER_ENTRY, {
  configGenerator: customPage
});