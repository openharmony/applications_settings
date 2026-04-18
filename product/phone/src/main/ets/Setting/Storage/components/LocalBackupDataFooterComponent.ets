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
import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';

const TAG: string = 'StorageDataHeaderComponent'

@Builder
export function localBackupDataFooterBuilder(param: object): void {
  LocalBackupDataFooterComponent({ footer: param as SettingContentModel });
}

@Component
export struct LocalBackupDataFooterComponent {
  footer?: SettingContentModel;

  build() {
    Column() {
      Text() {
        Span(ResourceUtil.getFormatStringSync($r('app.string.storage_local_backup_data_guide'), ''))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .constraintSize({minHeight: $r('app.float.wh_value_16')})
        Span($r('app.string.storage_local_backup_data_view'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .constraintSize({minHeight: $r('app.float.wh_value_16')})
          .onClick(() => {
            this.jumpToLocalBackup();
          });
      }
      .margin({bottom: '4vp'})
      Text($r('app.string.storage_local_backup_data_tip'))
        .fontSize($r('sys.float.Body_S'))
        .fontFamily('HarmonyHeiTi')
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

  private jumpToLocalBackup(): void {
    try {
      AbilityUtils.startAbility({
        bundleName: 'com.ohos.databackup',
        abilityName: 'EntryAbility',
        parameters: {
          wantContent: 'localbackup',
        },
      });
      LogUtil.info(`${TAG} jump to local backup success`);
    } catch (err) {
      LogUtil.error(`${TAG} jump to local backup failed: ${err?.message}`);
    }
  }
}