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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';

const TAG: string = 'UpgradingDataHeaderComponent'

@Builder
export function upgradingDataHeaderBuilder(param: object): void {
  UpgradingDataHeaderComponent({ header: param as SettingContentModel });
}

@Component
export struct UpgradingDataHeaderComponent {
  header?: SettingContentModel;

  build() {
    Row() {
      Image($r('app.media.ic_app_icon_settings'))
        .width(64)
        .height(64)
        .margin({ end: PADDING_16 })
        .borderRadius($r('sys.float.corner_radius_level8'))

      Column() {
        Text($r('app.string.storage_upgrading_data'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({minHeight: $r('app.float.wh_value_21')})
      }
      .width('calc(100% - 64vp)')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 24 })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}