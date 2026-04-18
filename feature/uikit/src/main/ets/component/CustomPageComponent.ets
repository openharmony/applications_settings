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
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
/* instrument ignore file */
const TAG: string = 'CustomPageComponent: ';
const SPAN_12: number = 12;
const COMMON_GRID_COL_OPTIONS: GridColOptions = {
  span: {
    xs: SPAN_12,
    sm: SPAN_12,
    md: SPAN_12,
    lg: SPAN_12,
  },
  offset: {
    xs: 0,
    md: 0,
    sm: 0,
    lg: 0,
  },
};

/**
 * 自定义标题栏页面模板
 */
@Component
export struct CustomPageComponent {
  @StorageProp('navDesDynamicPadding') navDesDynamicPadding: number = AppStorage.get<number>('navDesDynamicPadding') as number;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @BuilderParam content: () => void;
  @Prop title: string = '';
  bgColor?: ResourceColor = $r('sys.color.ohos_id_color_sub_background');
  onPageShow?: () => void;
  onHidden?: () => void;

  build() {
    NavDestination() {
      GridRow() {
        GridCol(COMMON_GRID_COL_OPTIONS) {
          this.pageContentBuilder()
        }
      }
    }
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
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
    .padding({
      left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
      right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
    })
  }

  @Builder
  pageContentBuilder() {
    Column() {
      Scroll() {
        Column() {
          this.content()
        }
        .width('100%')
        .align(Alignment.TopStart)
      }
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.None)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.bgColor)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}