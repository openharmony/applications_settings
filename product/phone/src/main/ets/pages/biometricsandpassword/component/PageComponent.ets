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

/* instrument ignore file */
const TAG: string = 'PageComponent: ';

/**
 * 通用页面模板
 */
@Component
export struct PageComponent {
  @BuilderParam content: () => void;
  hideTitle?: boolean = false;
  title: string = '';
  bgColor?: ResourceColor = $r('sys.color.ohos_id_color_sub_background');
  paddingTop?: string | number | Resource;
  paddingLeft?: string | number | Resource;
  paddingRight?: string | number | Resource;
  onPageShow?: () => void;
  onHidden?: () => void;
  onBackPress?: () => boolean;

  build() {
    NavDestination() {
      Column() {
        this.content();
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .padding({
        top: this.paddingTop ? this.paddingTop : '12vp',
        left: this.paddingLeft ? this.paddingLeft : $r('app.float.padding_16'),
        right: this.paddingRight ? this.paddingRight : $r('app.float.padding_16'),
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .backgroundColor(this.bgColor)
    }
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .hideTitleBar(this.hideTitle ?? false)
    .title(this.title)
    .backgroundColor(this.bgColor)
    .onShown(() => {
      if (typeof this.onPageShow === 'function') {
        this.onPageShow();
      }
    })
    .onHidden(() => {
      if (typeof this.onHidden === 'function') {
        this.onHidden();
      }
    })
    .onBackPressed(() => {
      if (typeof this.onBackPress === 'function') {
        return this.onBackPress();
      }
      return false;
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}