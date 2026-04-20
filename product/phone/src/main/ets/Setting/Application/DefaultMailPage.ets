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
import { EmailListController } from '@ohos/settings.application/src/main/ets/controller/EmailListController';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EmailRadioController } from '@ohos/settings.application/src/main/ets/controller/EmailRadioController';

const TAG: string = 'DefaultMailPage:';

function customPage(): SettingPageModel {
  const radioController: EmailRadioController = new EmailRadioController();
  const systemEmailListController: EmailListController = new EmailListController(radioController, true);
  const noSystemEmailListController: EmailListController = new EmailListController(radioController, false);
  return {
    id: 'EmailList',
    url: NavEntryKey.DEFAULT_MAIL_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.default_mail')),
    groups: [
      {
        id: 'SystemEmailGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: systemEmailListController,
      },
      {
        id: 'NoSystemEmailGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: noSystemEmailListController,
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
        systemEmailListController.onPageShow(component);
        noSystemEmailListController.onPageShow(component);
        radioController.onPageShow(component);
      },
      onPageHide: (component: SettingBaseModel) => {
        LogUtil.info(`${TAG} onPageHide.`);
        systemEmailListController.onPageHide(component);
        noSystemEmailListController.onPageHide(component);
        radioController.onPageHide(component);
      },
    },
  }
}

PageLoader.load(NavEntryKey.DEFAULT_MAIL_ENTRY, {
  configGenerator: customPage
});