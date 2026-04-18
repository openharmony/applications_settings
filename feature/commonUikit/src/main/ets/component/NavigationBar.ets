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

import curves from '@ohos.curves';
import i18n from '@ohos.i18n';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TitleIcon } from './TitleIcon'

@Component
export struct NavigationBar {
  menuBuilder?: WrappedBuilder<[]> = undefined;
  moreComponentId: string = 'moreIcon';
  onSearchIconClicked: () => void = () => {
  };
  onMoreIconClicked: () => void = () => {
  };
  private isRtl: boolean = i18n.isRTL(i18n.System.getSystemLanguage());
  private isPC: boolean = DeviceUtil.isDevicePc();
  @Prop title: ResourceStr;
  @Prop shouldShowBackButton: boolean = true;
  @Prop needLargeTitle: boolean = false;
  @Prop searchComponentId?: string = 'searchIcon';
  // 入场动效，默认添加
  @Prop showAnimation: boolean = true;
  @Prop titleId?: string = 'navigationTitle';

  build() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      // 标题, 分栏情况下首页面标题字体24
      Text(this.title)
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
        .maxLines(2)
        .minFontSize('14vp')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor($r('sys.color.icon_primary'))
        .maxFontSize((this.needLargeTitle && !this.isPC) ? '24vp' : '20vp')
        .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
        .flexGrow(1)
        .padding({ right: 8 })
        .id(this.titleId)

      // 搜索按钮，默认不展示
      Column() {
        TitleIcon({
          symbolIcon: $r('sys.symbol.magnifyingglass'),
          accessibilityTextRes: $r('app.string.setting_search'),
          onClickButton: this.onSearchIconClicked
        })
          .margin({
            end: PADDING_8,
          })
      }
      .id(this.searchComponentId)

      Column() {
        // 更多选项按钮不能抽取到TitleIcon中(语音播报和bindMenu冲突)
        Button() {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize('24vp')
            .fontColor([$r('sys.color.icon_primary')])
            .renderingStrategy(SymbolRenderingStrategy.SINGLE)
            .focusable(true)
            .draggable(false)
        }
        .onClick(() => {
          this.onMoreIconClicked();
        })
        .width(40)
        .height(40)
        .borderRadius(20)
        .focusOnTouch(true)
        .align(Alignment.Center)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .accessibilityText($r('app.string.more_options'))
        .bindMenu(this.menuBuilder?.builder())
      }
      .flexShrink(0)
      .id(this.moreComponentId)
    }
    .height(56)
    .constraintSize({ minHeight: '56vp' })
    .backgroundColor($r('sys.color.background_secondary'))
    .accessibilityLevel(AccessibilityLevelType.YES)
  }
}