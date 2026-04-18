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
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CommonUIExtensionSettings } from '@ohos/settings.common/src/main/ets/viewmodel/CommonUIExtensionSettings';

const BUNDLE_NAME: string = 'com.ohos.esimmanager';
const ABILITY_NAME: string = 'com.ohos.esim.EidDetailUIExtAbility';

@Builder
export function settingEIDDetailPageBuilder(param: object): void {
  CommonUIExtensionSettings({ params: getParam(param) });
}

function getParam(param: object) {
  let params: PushParam = (param as PageParams)?.param as PushParam;
  params.bundleName = BUNDLE_NAME;
  params.abilityName = ABILITY_NAME;
  return params;
}

function customPage(): SettingPageModel {
  return {
    id: 'eid_detail_entry',
    url: NavEntryKey.EID_DETAIL_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'eid_detail_entry',
  }
}

PageLoader.load(NavEntryKey.EID_DETAIL_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingEIDDetailPageBuilder),
});