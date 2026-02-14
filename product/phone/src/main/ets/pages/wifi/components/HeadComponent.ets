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

/**
 * 标题组件
 * @since 2023-8-7
 */
@Component
export struct HeadComponent {
  @State mHeadImage: Resource = $r('app.media.ic_wifi_oobe');
  @State mHeadName: Resource = $r('app.string.device_name_empty_message');

  build() {
    Column() {
      Image(this.mHeadImage)
        .width($r('app.float.distance_48'))
        .height($r('app.float.distance_48'))
        .margin({ bottom: $r('app.float.distance_12') })
        .draggable(false);

      Text(this.mHeadName)
        .fontSize($r('app.float.font_size_30'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .fontFamily('HarmonyHeiTi')
        .backgroundColor($r('app.color.color_bg'))
    }
    .margin({ top: $r('app.float.distance_11_5'), bottom: $r('app.float.distance_48') })
    .width('100%')
    .backgroundColor($r('app.color.color_bg'))
    .alignItems(HorizontalAlign.Center);
  }
}
