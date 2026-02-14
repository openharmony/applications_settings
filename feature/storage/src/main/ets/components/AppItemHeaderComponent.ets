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

/* instrument ignore file */
import { BusinessError } from '@ohos.base';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { SettingAppItemHeaderModel } from '../model/SettingAppItemHeaderModel';

const TAG: string = 'AppItemHeaderComponent'

@Builder
export function appItemHeaderBuilder(param: object): void {
  AppItemHeaderComponent({ header: param as SettingAppItemHeaderModel });
}

@Component
export struct AppItemHeaderComponent {
  header?: SettingAppItemHeaderModel | null = null;
  @State icon: ResourceStr | PixelMap | null = null;
  @State versionName: string = '';
  @State label: string = '';
  @State name: string = '';
  @State appIndex: number = 0;

  build() {
    Row() {
      AppCloneBadgeComponent({
        iconStyle:{
          border: { width: '0px', color: '#00000000', radius: 0 },
          borderRadius: 12,
          width: 64,
          height: 64,
          mirrored: false,
          interpolation: ImageInterpolation.Medium,
          draggable: false
        } as SettingIconStyle,
        bundleName: this.header?.entry?.name,
        appIndex: this.appIndex,
        entry: this.header?.entry,
        iconSize: 64,
        isNeedEndPadding:false
      })
        .margin({ end: PADDING_12 })

      Column() {
        Text(this.label)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(`${this.versionName}`)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('calc(100% - 64vp)')
      .alignItems(HorizontalAlign.Start)
    }
    .accessibilityGroup(true)
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 24 })
  }

  aboutToAppear(): void {
    let data = this.header as SettingAppItemHeaderModel;
    this.versionName =
      ResourceUtil.getFormatStringSync($r('app.string.app_info_version'), data?.versionName as string);
    this.icon = data?.icon || null;
    this.label = data?.label || '';
    this.name = data?.name as string;
    this.appIndex = data?.appIndex as number;
    this.updateAppDisPlayInfo();
  }

  updateAppDisPlayInfo(): void {
    // 当app名和图标都没有时，默认未获取到app的基础信息，需要重新获取下
    if (!this.label || !this.icon) {
      AppListLoader.getInstance().getAndUpdateAppEntryByName(this.name as string).then(entry => {
        this.label = entry?.label as string;
        this.icon = entry?.icon as PixelMap;
        this.versionName = entry?.versionName as string;
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} get app info failed,error is ${error?.code}`);
      })
    }
  }
}