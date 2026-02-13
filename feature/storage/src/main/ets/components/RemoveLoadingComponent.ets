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
import { RemoveHeaderModel } from '../model/SettingAppItemHeaderModel';

@Builder
export function removeLoadingBuilder(param: object): void {
  RemoveLoadingComponent({ header: param as RemoveHeaderModel });
}

@Component
export struct RemoveLoadingComponent {
  header?: RemoveHeaderModel | null = null;
  @State label: string = 'label';

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text(this.label)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Center)
      LoadingProgress()
        .width(40)
        .height(40)
        .margin({
          left: $r('sys.float.padding_level4')
        })
        .id('loading_progress_storage_app_list_group')
        .alignSelf(ItemAlign.Center)
    }
  }

  aboutToAppear(): void {
    this.label =
      ResourceUtil.getFormatStringSync($r('app.string.uninstalling_dialog_message'), this.header?.label as string);
  }
}