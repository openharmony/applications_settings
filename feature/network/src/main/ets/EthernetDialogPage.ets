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

import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { AdvancedEthernetSettingDialogView } from './view/AdvancedEthernetSettingDialogView';

export const URL_NETWORK_ETHERNET_DIALOG_PAGE: string = 'Setting.PcNetwork.EthernetDialogPage';

@Builder
export function ethernetDialogBuilder(param: object): void {
  AdvancedEthernetSettingDialogView();
}

function customPage(): SettingPageModel {
  return {
    id: 'network_ethernet_config_dialog',
    url: URL_NETWORK_ETHERNET_DIALOG_PAGE,
    type: PageType.PAGE_TYPE_CUSTOM,
    layout: {
      backgroundColor: Color.Transparent,
      blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
    },
  }
}

ModalLoader.load(URL_NETWORK_ETHERNET_DIALOG_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(ethernetDialogBuilder),
});
