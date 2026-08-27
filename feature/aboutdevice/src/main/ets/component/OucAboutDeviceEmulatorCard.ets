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

import { ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
/* instrument ignore file */
import { IOucEmulatorCardModel } from '../model/IOucEmulatorCardModel';
@Extend(Image)
function imageStyle(imageStyle?: ImageStyle) {
  .width(imageStyle?.size?.width as Length)
  .height(imageStyle?.size?.height as Length)
  .constraintSize(imageStyle?.constraintSize)
  .padding(imageStyle?.padding ?? 0)
  .margin(imageStyle?.margin ?? 0)
  .layoutWeight(imageStyle?.layoutWeight ?? 0)
  .objectFit(imageStyle?.imageFit ?? ImageFit.Contain)
  .draggable(false)
}

@Component
export struct OucAboutDeviceEmulatorCard {
  @ObjectLink pageModel: IOucEmulatorCardModel;

  build() {
    Stack() {
      Column() {
        Image(this.pageModel.icon)
          .visibility(this.pageModel.icon ? Visibility.Visible : Visibility.None)
          .interpolation(ImageInterpolation.Medium)
          .autoResize(false)
          .imageStyle(this.pageModel.iconImageStyle);
      }

      Image(this.pageModel.stateIcon)
        .visibility(this.pageModel.stateIcon ? Visibility.Visible : Visibility.None)
        .interpolation(ImageInterpolation.Medium)
        .autoResize(false)
        .imageStyle(this.pageModel.stateIconStyle);
    }
    .alignContent(Alignment.Center)
    .size(this.pageModel.rootContainerStyle?.size)
    .constraintSize(this.pageModel.rootContainerStyle?.constraintSize)
    .padding(this.pageModel.rootContainerStyle?.padding ?? 0)
    .margin(this.pageModel.rootContainerStyle?.margin ?? 0)
    .layoutWeight(this.pageModel.rootContainerStyle?.layoutWeight ?? 0)
    .clip(this.pageModel.rootContainerStyle?.clip)
    .borderRadius(this.pageModel.rootContainerStyle?.borderRadius as Length)
    .backgroundColor(this.pageModel.rootContainerStyle?.backgroundColor)
    .visibility(Visibility.Visible);
  }
}