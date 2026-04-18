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

import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

const TAG: string = 'StorageDataHeaderComponent'

@Builder
export function upgradingDataFooterBuilder(param: object): void {
  UpgradingDataFooterComponent({ footer: param as SettingContentModel });
}

@Component
export struct UpgradingDataFooterComponent {
  footer?: SettingContentModel;

  build() {
    Column() {
      Text($r('app.string.storage_upgrading_data_tip'))
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .constraintSize({minHeight: $r('app.float.wh_value_16')})
      Text(ResourceUtil.getNumberFormatStringSync($r('app.string.storage_upgrading_data_tip_two'),
        LanguageUtils.getNumberFormat(2)))
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .constraintSize({minHeight: $r('app.float.wh_value_16')})
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}