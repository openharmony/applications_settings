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

import { WifiBaseConfigManager } from '../WifiBaseConfigManager';
import { WifiUtils } from '../WifiUtils';

@Component
export struct ConnectFailedComponent {
  private failedReasonString: ResourceStr | undefined;

  build() {
    Text(this.failedReasonString ?? '')
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .textAlign(TextAlign.Center)
      .constraintSize({
        minHeight: 21,
      })
      .width('100%')
  }

  aboutToAppear(): void {
    let failReason: number = WifiUtils.getDisconnectedReason();
    WifiUtils.reportWlanConnectFailureEvent(failReason);
    this.failedReasonString = WifiBaseConfigManager.getDisconnectedReasonMessage(failReason);
  }

  aboutToDisappear(): void {
  }
}