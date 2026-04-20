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
import { ColorMetrics, LengthMetrics } from '@kit.ArkUI';
import { FOCUS_BOX_PADDING_METRICS, PADDING_2 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { RINGER_MODE_NORMAL, RINGER_MODE_SILENT, RINGER_MODE_VIBRATE } from '../controller/VolumeAdapter';
import { IS_SUPPORT_VIBRATE, ModeChangeEventCb, VolumeModeController } from '../controller/VolumeModeController';

@Component
struct SoundModeItemComponent {
  radioIcon: Resource = $r('sys.symbol.bell');
  radioIconSelect: Resource = $r('sys.symbol.bell');
  radioText: ResourceStr = '';
  ringMode: number = 0;
  itemBorderStyle?: Length | BorderRadiuses | LocalizedBorderRadiuses = {};
  item?: SettingBaseModel;
  controller?: VolumeModeController = undefined;
  @State isHover: boolean = false;
  @State isSelected: boolean = false;
  private modeChangeCallback: ModeChangeEventCb = (mode: number) => {
    let selected: boolean = this.ringMode === mode;
    if (selected !== this.isSelected) {
      this.isSelected = selected;
    }
  }

  aboutToAppear(): void {
    this.isSelected = this.controller?.audioRingMode === this.ringMode;
    this.controller?.registerModeChangeListener(this.modeChangeCallback);
  }

  aboutToDisappear(): void {
    this.controller?.unregisterModeChangeListener(this.modeChangeCallback);
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isHover && !this.isSelected) {
      return $r('sys.color.interactive_hover');
    }
    return this.isSelected ? $r('sys.color.brand') : $r('sys.color.comp_background_list_card');
  }

  build() {
    Flex({
      justifyContent: FontScaleUtils.isExtraLargeFontMode() ?
        FlexAlign.Start : FlexAlign.Center,
      alignItems: ItemAlign.Center,
      direction: FlexDirection.Column
    }) {
      Row(){
        SymbolGlyph(this.isSelected ? this.radioIconSelect : this.radioIcon)
          .fontColor([this.isSelected ? Color.White : $r('sys.color.font_primary')])
          .draggable(false)
          .margin({ bottom: $r('app.float.margin_13') })
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
      }
      .height('auto')
      .justifyContent(FlexAlign.Center)

      Row(){
        Text(this.radioText)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isSelected ? Color.White : $r('sys.color.font_primary'))
          .opacity(this.isSelected ? 1 : $r('sys.float.alpha_secondary'))
          .fontWeight(FontWeight.Medium)
          .maxFontScale(2);
      }
      .height('auto')
      .justifyContent(FlexAlign.Center)
    }
    .width(IS_SUPPORT_VIBRATE ? (99.3 / 3 + '%') : (99.4 / 2 + '%'))
    .padding({ top: $r('sys.float.padding_level10'), bottom: $r('sys.float.padding_level10') })
    .backgroundColor(this.getBackgroundColor())
    .accessibilitySelected(this.isSelected)
    .accessibilityDescription(this.isSelected ? ' ' : '')
    .borderRadius(this.itemBorderStyle)
    .focusBox({
      margin: FOCUS_BOX_PADDING_METRICS,
      strokeColor: this.isSelected ?
      ColorMetrics.resourceColor(Color.White) : ColorMetrics.resourceColor($r('sys.color.brand')),
    })
    .onClick((event) => {
      this.controller?.onRadioChange(this.ringMode);
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
  }
}

@Component
export struct SoundModeComponent {
  item?: SettingBaseModel;
  controller: VolumeModeController = new VolumeModeController();
  private cornerRadiusLeveL10: LengthMetrics | undefined =
    LengthMetrics.resource($r('sys.float.corner_radius_level10'));

  aboutToAppear(): void {
    this.controller.init();
  }

  aboutToDisappear(): void {
    this.controller.destroy();
  }

  build() {
    Row() {
      RelativeContainer() {
        SoundModeItemComponent({
          radioIcon: $r('sys.symbol.bell'),
          radioIconSelect: $r('sys.symbol.bell_fill'),
          radioText: $r('app.string.volume_mode_sound'),
          ringMode: RINGER_MODE_NORMAL,
          controller: this.controller,
          item: this.item,
          itemBorderStyle: {
            topStart: this.cornerRadiusLeveL10,
            bottomStart: this.cornerRadiusLeveL10
          }
        })
          .id('sound')

        SoundModeItemComponent({
          radioIcon: $r('sys.symbol.rectangle_portrait_wave_2'),
          radioIconSelect: $r('sys.symbol.rectangle_portrait_wave_2_fill'),
          radioText: $r('app.string.volume_mode_vibrate'),
          ringMode: RINGER_MODE_VIBRATE,
          controller: this.controller
        })
          .id('vibrate')
          .alignRules({
            top: { anchor: 'sound', align: VerticalAlign.Top },
            left: { anchor: 'sound', align: HorizontalAlign.End },
            bottom: { anchor: 'sound', align: VerticalAlign.Bottom },
          })
          .margin({ start: PADDING_2})
          .visibility(IS_SUPPORT_VIBRATE ? Visibility.Visible : Visibility.None)

        SoundModeItemComponent({
          radioIcon: $r('sys.symbol.bell_slash'),
          radioIconSelect: $r('sys.symbol.bell_slash_fill'),
          radioText: $r('app.string.volume_mode_silent'),
          ringMode: RINGER_MODE_SILENT,
          controller: this.controller,
          itemBorderStyle: {
            topEnd: this.cornerRadiusLeveL10,
            bottomEnd: this.cornerRadiusLeveL10
          }
        })
          .margin({ start: PADDING_2})
          .alignRules(IS_SUPPORT_VIBRATE ?
            { top: { anchor: 'vibrate', align: VerticalAlign.Top },
              left: { anchor: 'vibrate', align: HorizontalAlign.End },
              bottom: { anchor: 'vibrate', align: VerticalAlign.Bottom }} :
            { top: { anchor: 'sound', align: VerticalAlign.Top },
              left: { anchor: 'sound', align: HorizontalAlign.End },
              bottom: { anchor: 'sound', align: VerticalAlign.Bottom }})
      }
      .height('auto')
    }
    .width('100%')
  }
}