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
import i18n from '@ohos.i18n';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_12,
  PADDING_3,
  PADDING_4,
  PADDING_54,
  PADDING_6,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { BluetoothWindowBondDeviceViewModel } from '../ViewModel/BluetoothWindowBondDeviceViewModel';
import { MenuEntry } from '../model/MenuEntry';

const TAG: string = 'BtWindowSettingsBondDeviceItemComponent: ';
const LANGUAGE_BO = 'bo'; // 系统语言为藏文

@Component
export struct BtWindowSettingsBondDeviceItemComponent {
  @Prop menu: MenuEntry;
  @Prop bondDeviceViewModel: BluetoothWindowBondDeviceViewModel;
  @Prop tabInd: number = TabIndexConstants.TAB_INDEX_DEFAULT;
  @State index: number = 0;
  @State menuLength: number = 0;
  @State bgColor: ResourceColor = Color.Transparent;
  currentLanguage = i18n.System.getSystemLanguage();

  build() {
    Row() {
      SymbolGlyph(this.menu.icon as Resource)
        .fontSize($r('app.float.wh_value_24'))
        .fontColor([$r('app.color.statusbar_blend_color')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .draggable(false)
        .advancedBlendMode(BlendModeUtil.getBlender())

      Column() {
        Row() {
          Text(this.menu.title)
            .fontColor(this.menu.isConnect ? $r('app.color.bluetooth_window_settings_connect_title_color') :
            $r('app.color.statusbar_blend_color'))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight($r('app.float.height_22'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .halfLeading(true)
            .advancedBlendMode(this.menu.isConnect ? undefined : BlendModeUtil.getBlender())
        }
        .constraintSize({
          minHeight: $r('app.float.height_24'),
        })
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)

        if (!this.menu.isConnect && this.menu.subTitle) {
          Row() {
            Text(this.menu.subTitle)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('app.color.statusbar_blend_color'))
              .fontWeight(FontWeight.Regular)
              .lineHeight($r('app.float.height_22'))
              .maxFontScale(this.currentLanguage === LANGUAGE_BO ? DisplayConstant.TEXT_FONT_SIZE_NORMAL :
              DisplayConstant.TEXT_FONT_SIZE_HUGE)
              .halfLeading(true)
              .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
          }
          .constraintSize({
            minHeight: $r('app.float.length_20'),
          })
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
        }
      }
      .layoutWeight(1)
      .margin({
        top: !this.menu.isConnect && this.menu.subTitle ? PADDING_6 : PADDING_8,
        bottom: !this.menu.isConnect && this.menu.subTitle ? PADDING_6 : PADDING_8,
        start: PADDING_12,
        end: this.menu.isConnect ? PADDING_8 : PADDING_54,
      })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)

      if (this.menu.isConnect) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize($r('app.float.width_24'))
          .fontWeight(FontWeight.Regular)
          .fontColor([$r('app.color.bluetooth_window_settings_connect_title_color')])
      }
    }
    .constraintSize({
      minHeight: !this.menu.isConnect && this.menu.subTitle ? $r('app.float.height_56') : $r('app.float.height_40'),
    })
    .layoutWeight(1)
    .margin({
      start: PADDING_3,
      end: PADDING_4,
    })
    .padding({
      left: $r('sys.float.padding_level10'),
      right: $r('sys.float.padding_level10'),
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level6'))
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .backgroundColor(this.bgColor)
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event)
    })
    .onClick(() => {
      this.onClickEvent();
    })
  }

  private onClickEvent(): void {
    this.bondDeviceViewModel.handleBondedDeviceItemClick(this.menu.key);
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.ohos_id_color_hover');
    } else {
      this.bgColor = Color.Transparent;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.ohos_id_color_click_effect');
    }
    if (event && event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.bgColor = $r('sys.color.ohos_id_color_click_effect');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }
}