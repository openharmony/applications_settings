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

import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { RemoveHeaderModel } from '../model/SettingAppItemHeaderModel';

@Builder
export function removeContentBuilder(param: object): void {
  RemoveContentComponent({ header: param as RemoveHeaderModel });
}

@Component
export struct RemoveContentComponent {
  header?: RemoveHeaderModel | null = null;
  @State pic: ResourceStr | PixelMap | null = null;
  @State label: string = '';

  build() {
    Column() {
      AppCloneBadgeComponent({
        iconStyle:{
          border: { width: '0px', color: '#00000000', radius: 0 },
          borderRadius: 0,
          width: 64,
          height: 64,
          mirrored: false,
          interpolation: ImageInterpolation.Medium,
          draggable: false
        } as SettingIconStyle,
        entry: this.header?.entry,
        isNeedEndPadding: false,
        iconSize: 64,
        bundleName: this.header?.entry?.name
      })
        .margin({top : 24})

      Text(this.label)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })
    }
  }

  aboutToAppear(): void {
    let data = this.header as RemoveHeaderModel;
    this.pic = data?.pic || null;
    let label: string = data?.label || '';
    this.label = ResourceUtil.getFormatStringSync($r('app.string.app_uninstall_confirm'), label);
  }
}