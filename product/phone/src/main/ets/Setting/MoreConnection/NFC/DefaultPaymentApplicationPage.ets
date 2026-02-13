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
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { DefaultPaymentApplicationController } from './controller/DefaultPaymentApplicationController';

function defaultPaymentApplicationPage(): SettingPageModel {
  return {
    id: 'payment_application',
    url: NavEntryKey.PAYMENT_APPLICATION,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.nfc_default_payment_text')),
    groups: [
      {
        id: 'default_payment_app_group',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: true,
        compControl: new DefaultPaymentApplicationController(),
      }
    ],
  };
}

PageLoader.load(NavEntryKey.PAYMENT_APPLICATION, {
  configGenerator: defaultPaymentApplicationPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});
