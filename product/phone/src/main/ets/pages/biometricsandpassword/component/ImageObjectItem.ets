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

import { ImageObject } from '../module/fingerprint/model/ImageAnimationObject'

/* instrument ignore file */
@Component
export default struct ImageObjectItem {
  @ObjectLink imageObject: ImageObject;
  isCallback: () => void = () => {
  };
  COMPONENT_OPACITY = 0.9; //透明度
  PAGE_WIDTH = '100%';
  COMPONENT_ASPECTRATIO = (9 / 18);

  build() {
    Column() {
      Stack() {
        Image(this.imageObject.image)
          .width(this.PAGE_WIDTH)
          .aspectRatio(this.COMPONENT_ASPECTRATIO)
          .borderRadius($r('app.float.border_radius_16'))
          .objectFit(ImageFit.Fill)
          .draggable(false)
        Row() {
          Toggle({ type: ToggleType.Checkbox, isOn: this.imageObject.check })
            .visibility(this.imageObject.check ? Visibility.Visible : Visibility.Hidden)
            .hitTestBehavior(HitTestMode.None)
            .width($r('app.float.length_20'))
            .height($r('app.float.length_20'))
            .borderRadius($r('app.float.wh_value_4'))
            .draggable(false)
        }
        .justifyContent(FlexAlign.End)
        .width(this.PAGE_WIDTH)
        .padding({
          left: $r('sys.float.padding_level2'),
          right: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2')
        })
      }
      .width(this.PAGE_WIDTH)
      .align(Alignment.BottomEnd)

      Text(this.imageObject.name)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .opacity(this.COMPONENT_OPACITY)
        .constraintSize({minHeight: $r('app.float.length_19')})
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .alignSelf(ItemAlign.Center)
        .margin({ top: $r('app.float.margin_8') })
        .draggable(false)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.End)
  }
}