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
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { KeyBoardFirmwareUpgrade } from './view/KeyBoardFirmwareUpgradeComponent';

@Builder
function keyBoardFirmwareUpgradeBuilder(param: object): void {
  KeyBoardFirmwareUpgrade({ params: (param as PageParams)?.param as PushParam });
}

function customPage(): SettingPageModel {
  return {
    id: 'KEYBOARD_FIRMWARE_UPGRADE',
    url: NavEntryKey.PAD_KEYBOARD_FIRMWARE_UPGRADE,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'KEYBOARD_FIRMWARE_UPGRADE',
  }
}

PageLoader.load(NavEntryKey.PAD_KEYBOARD_FIRMWARE_UPGRADE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(keyBoardFirmwareUpgradeBuilder),
});