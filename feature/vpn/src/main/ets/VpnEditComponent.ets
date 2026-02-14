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

import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { VpnEditView } from './VpnEditView';
import ConfigData from './ConfigData';
import VpnConfig from './model/VpnConfig';
import { VpnConfigModel } from './model/VpnConfigModel';

/* instrument ignore file */
@Component
export struct VpnEditComponent {
  @State vpnConfig: VpnConfig = new VpnConfig();
  @State isSaveBtnEnabled: boolean = false;
  @State isDelBtnVisibility: Visibility = Visibility.None;
  @State params: PushParam | null = null;
  @Consume('pathInfos') pathInfos: NavPathStack;
  protocolSheets: SheetInfo[] = [];
  onSaveClicked?: (config: VpnConfig) => void;
  onCancelClicked?: () => void;

  aboutToAppear(): void {
    this.vpnConfig = this.params?.config as VpnConfig;
  }

  backToListPage(): void {
    VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
    this.pathInfos?.pop();
  }

  build() {
    NavDestination() {
      Column() {
        VpnEditView({
          vpnConfig: this.vpnConfig,
          isDelBtnVisible: true,
          onDelClickFinish: () => {
            this.backToListPage();
          },
          onSaveClickFinish: () => {
            this.backToListPage();
          },
        })
      }
      .padding({ top: 8, left: DeviceUtil.isDevicePc() ? 8 : 0, right: DeviceUtil.isDevicePc() ? 8 : 0 })
      .width(ConfigData.WH_100_100)
    }
    .title((AppStorage.get<Context>('pageContext') as Context)?.resourceManager?.getStringSync($r('app.string.VPN').id))
    .backgroundColor($r('sys.color.comp_background_gray'))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }
}