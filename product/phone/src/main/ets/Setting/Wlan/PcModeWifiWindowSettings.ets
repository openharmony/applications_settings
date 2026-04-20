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

import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PcModeWifiWindowSettingsComponent } from '@ohos/settings.wifi/src/main/ets/component/PcModeWifiWindowSettingsComponent';

const TAG: string = 'PcModeWifiWindowSettings : ';

@Entry
@Component
struct PcModeWifiWindowSettings {

  build() {
    Column() {
      PcModeWifiWindowSettingsComponent();
    }
    .size({ width: '100%', height: '100%' })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.CLICK_WLAN_TEXT_SHOW_DIALOG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}