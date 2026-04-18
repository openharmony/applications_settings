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

import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_16, PADDING_2 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingAppItemHeaderModel } from '@ohos/settings.storage/src/main/ets/model/SettingAppItemHeaderModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DateAndTimeUtil } from '@ohos/settings.datetime/src/main/ets/utils/DateAndTimeUtil';
import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { StorageDataManager } from '@ohos/settings.storage/src/main/ets/model/StorageDataManager';

const TAG: string = 'StorageDataHeaderComponent'

const SECOND_TO_MILE_SECOND: number = 1000;

@Builder
export function localBackupDataHeaderBuilder(param: object): void {
  LocalBackupDataHeaderComponent({ header: param as SettingContentModel });
}

@Component
export struct LocalBackupDataHeaderComponent {
  header?: SettingContentModel;
  @State backupDate: string = '';

  build() {
    Row() {
      Image($r('app.media.ic_app_icon_settings'))
        .width(64)
        .height(64)
        .margin({ end: PADDING_16 })
        .borderRadius($r('sys.float.corner_radius_level8'))
      Column() {
        Text($r('app.string.storage_local_backup_data'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({minHeight: $r('app.float.wh_value_21')})
        Text(this.backupDate)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .constraintSize({minHeight: $r('app.float.wh_value_19')})
          .margin({ top: 2 })
      }
      .padding({ end: PADDING_2 })
      .width('calc(100% - 64vp)')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 24 })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.updateCreatTimeCallback();
    EventBus.getInstance().on('Setting.storage.updateCreatTime', this.updateCreatTimeCallback);
  }

  private updateCreatTimeCallback = () => {
    LogUtil.info(`${TAG} updateCreatTime`);
    let createTime =
      new Date (StorageDataManager.getInstance().getLocalBackupModel().createTime * SECOND_TO_MILE_SECOND);
    this.backupDate = ResourceUtil.getFormatStringSync($r('app.string.storage_backup_time'),
      DateAndTimeUtil.formatDate(createTime));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach('Setting.storage.updateCreatTime', this.updateCreatTimeCallback);
  }
}