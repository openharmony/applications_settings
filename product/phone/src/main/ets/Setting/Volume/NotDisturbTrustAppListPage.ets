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

import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { NotDisturbTrustAppListComponent } from './view/NotDisturbTrustAppListComponent';

export const URL_VOLUME_TRUST_LIST_PAGE: string = 'Setting.Volume.TrustAppList';

@Builder
export function selectTrustAppListBuilder(item: object) {
  NotDisturbTrustAppListComponent({ pageParam: (item as PageParams), });
}

// 免打扰通知页面
function customPage(): SettingPageModel {
  return {
    id: 'trust_app_list',
    url: URL_VOLUME_TRUST_LIST_PAGE,
    type: PageType.PAGE_TYPE_CUSTOM,
  }
}

ModalLoader.load(URL_VOLUME_TRUST_LIST_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(selectTrustAppListBuilder),
});