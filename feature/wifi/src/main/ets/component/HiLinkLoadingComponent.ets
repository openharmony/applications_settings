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

import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'HiLinkLoadingComponent: ';

@Component
export struct HiLinkLoadingComponent {
  private loadingContent?: ResourceStr;

  build() {
    Row() {
      Text(this.loadingContent ?? '')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
        .constraintSize({
          minHeight: 21,
        })
        .layoutWeight(1)

      LoadingProgress()
        .color($r('app.color.loading_color'))
        .align(Alignment.Top)
        .margin({
          left: $r('sys.float.padding_level6'),
        })
        .size({
          width: 40,
          height: 40,
        });
    }
    .constraintSize({
      minHeight: 48,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    this.loadingContent = WifiPasswordConfigManager.getInstance().hiLinkLoadingContent;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
  }
}