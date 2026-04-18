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
import MediaQuery from '@ohos.mediaquery';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import {
  MouseConstants,
  MousePointColor,
  MousePointColorIndex,
  MouseSliderType,
  MouseStyleType
} from '../utils/Constants';
import { MouseSettingsManager } from '../MouseSettingsManager';
import { MousePointerSliderController } from '../controller/MouseStyleController';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

@Component
export struct MouseImageComponent {
  build() {
    Column() {
      Image($r('app.media.mouse'))
        .width(MouseConstants.MOUSE_IMAGE_RATIO)
        .height(MouseConstants.MOUSE_IMAGE_RATIO)
        .objectFit(ImageFit.Contain)
        .draggable(false)
    }
    .width('100%')
    .height($r('app.float.mouse_image_background'))
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct MouseStyleRadioComponent {
  private mouseStyleType: string = MouseStyleType.DEFAULT;
  @State isChecked: boolean = false;
  private mouseStyleChangedCallback = (isChecked: boolean) => {
    switch (this.mouseStyleType) {
      case MouseStyleType.MouseArrowCursor:
        MouseSettingsManager.getInstance().setMouseStyle(!isChecked);
        EventBus.getInstance().emit('mouse_style_changed', !isChecked);
        break;
      default:
        break;
    }
  }

  aboutToAppear(): void {
    MouseSettingsManager.getInstance().refreshPointerStyle();
    let isMouseStyleCircle: boolean = MouseSettingsManager.getInstance().isCircleStyle();
    this.isChecked = this.mouseStyleType === MouseStyleType.MouseDotCursor ? isMouseStyleCircle : !isMouseStyleCircle;
  }

  build() {
    Radio({ value: this.mouseStyleType, group: 'MouseStyle' })
      .key(`mouse_style_comp_${this.mouseStyleType}`)
      .height($r('app.float.mouse_style_checkbox_size'))
      .alignSelf(ItemAlign.End)
      .checked(this.isChecked)
      .onChange(this.mouseStyleChangedCallback)
  }
}

@Component
export struct SplitMouseSliderComponent {
  private tag: string = 'SplitMouseSliderComponent: ';
  @State sliderValue: number = 0;
  private sliderType: number = MouseSliderType.DEFAULT;
  private title: ResourceStr = '';
  private orientationListener: MediaQuery.MediaQueryListener | undefined = undefined;
  @StorageLink('isPortraitOrientation') isPortraitOrientation: boolean = false;
  @StorageLink('windowMode') windowMode: number = MouseConstants.MOUSE_SPLIT_DEF;

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} windowModemouse ${this.windowMode}`); //默认为1，分屏为5
    this.isPortraitOrientation = DisplayUtils.isScreenPortraitOrientation();
    this.addOrientationListener();
  }

  aboutToDisappear(): void {
    this.orientationListener?.off('change');
  }

  build() {
    if (this.windowMode === MouseConstants.MOUSE_SPLIT && !this.isPortraitOrientation) {
      Column() {
        Row() {
          Text(this.title)
            .padding({ end: PADDING_8 })
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .margin({ top: $r('sys.float.padding_level8'), bottom: $r('sys.float.padding_level4') })
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })

        Row() {
          MouseSliderComponent({
            sliderValue: this.sliderValue,
            sliderType: this.sliderType,
            isSplit: true,
            isPortrait: this.isPortraitOrientation
          });
        }
        .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
        .margin({ bottom: $r('sys.float.padding_level6') })
      }
      .alignItems(HorizontalAlign.Start)
    } else {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.title)
            .padding({ end: PADDING_8 })
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
        .constraintSize({ minWidth: MouseConstants.MOUSE_TEXT_WIDTH })
        .flexGrow(1)
        .flexShrink(0)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        MouseSliderComponent({
          sliderValue: this.sliderValue,
          sliderType: this.sliderType,
          isSplit: false,
          isPortrait: this.isPortraitOrientation
        })
          .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
      }
      .margin({ top: $r('sys.float.padding_level5'), bottom: $r('sys.float.padding_level5') })
    }
  }

  async addOrientationListener(): Promise<void> {
    this.orientationListener = MediaQuery.matchMediaSync('(orientation: landscape)');
    this.orientationListener.on('change', () => {
      if (!DisplayUtils.isScreenPortraitOrientation()) {
        AppStorage.setOrCreate('isPortraitOrientation', false);
      } else {
        AppStorage.setOrCreate('isPortraitOrientation', true);
      }
    })
  }
}

@Component
export struct MouseSliderComponent {
  private tag: string = 'MouseSliderComponent: ';
  @State sliderValue: number = 0;
  @State isSplit: boolean = false;
  @State isPortrait: boolean = false;
  private controller: MousePointerSliderController = new MousePointerSliderController();
  private sliderType: number = MouseSliderType.DEFAULT;
  private sliderTimer?: number = 0;
  @State minValue: number = 0;
  @State maxValue: number = 0;
  @State step: number = 1;
  private mouseStyleChangedEventCallback = () => {
    LogUtil.info(`${this.tag} mouse_style_changed ${this.sliderType}`);
    this.sliderTimer = setTimeout(() => {
      this.sliderValue = this.controller.getSliderValue();
      LogUtil.info(`${this.tag} mouse_style_changed ${this.sliderValue}`);
    }, MouseConstants.MOUSE_SETTING_INTERVAL);
  };

  aboutToAppear(): void {
    this.controller.init(this.sliderType);
    this.minValue = this.controller.minValue;
    this.maxValue = this.controller.maxValue;
    this.mouseStyleChangedEventCallback();
    EventBus.getInstance().on(`mouse_style_changed`, this.mouseStyleChangedEventCallback);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach('mouse_style_changed', this.mouseStyleChangedEventCallback);
    clearTimeout(this.sliderTimer);
  }

  build() {
    Slider({
      value: this.sliderValue,
      min: this.minValue,
      max: this.maxValue,
      step: this.step,
      style: SliderStyle.InSet
    })
      .key(`mouse_slider_comp_${this.sliderType}`)
      .selectedColor($r('app.color.pointer_slide_color'))
      .showTips(false)
      .showSteps(false)
      .constraintSize(this.isSplit ? { maxWidth: '100%' } : { maxWidth: $r('app.float.mouse_card_slide_width') })
      .height($r('app.float.mouse_card_slide_height'))
      .alignSelf(ItemAlign.End)
      .onChange((value: number, mode: SliderChangeMode) => {
        this.controller?.onSliderChange(value, mode);
        this.sliderValue = this.controller.getSliderValue();
      })
  }
}

@Component
export struct SplitMouseRadioComponent {
  @StorageLink('isPortraitOrientation') isPortraitOrientation: boolean = false;
  @StorageLink('windowMode') windowMode: number = MouseConstants.MOUSE_SPLIT_DEF;

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  build() {
    if (this.windowMode === MouseConstants.MOUSE_SPLIT &&
      !this.isPortraitOrientation) {
      Column() {
        Row() {
          Text($r('app.string.mouse_pointer_color'))
            .padding({ right: $r('sys.float.padding_level8') })
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .margin({ top: $r('sys.float.padding_level8'), bottom: $r('sys.float.padding_level4') })
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })

        Row() {
          MouseRadioComponent({
            isSplit: true
          });
        }
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
        .margin({ bottom: $r('sys.float.padding_level6') })
      }
      .alignItems(HorizontalAlign.Start)
    } else {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text($r('app.string.mouse_pointer_color'))
            .padding({ right: $r('sys.float.padding_level8') })
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
        .constraintSize({ minWidth: MouseConstants.MOUSE_TEXT_WIDTH })
        .flexGrow(1)
        .flexShrink(0)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        MouseRadioComponent({
          isSplit: false
        })
          .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
      }
      .margin({ top: $r('sys.float.padding_level6'), bottom: $r('sys.float.padding_level6') })
    }
  }
}

@Component
export struct MouseRadioComponent {
  @State curSelectedIndex: number = MouseSettingsManager.getInstance().getMousePointColor();
  @State isSplit: boolean = false;
  private mouseColorTimer?: number = 0;
  private mouseStyleChangedEventCallback = () => {
    this.mouseColorTimer = setTimeout(() => {
      this.curSelectedIndex = MouseSettingsManager.getInstance().getMousePointColor();
    }, MouseConstants.MOUSE_SETTING_INTERVAL)
  };
  private mouseColorChangedEventCallback = (selectedColorIndex: number) => {
    if (this.curSelectedIndex !== selectedColorIndex) {
      this.curSelectedIndex = selectedColorIndex;
      MouseSettingsManager.getInstance().setMousePointColor(this.curSelectedIndex);
    }
  };

  aboutToAppear(): void {
    EventBus.getInstance().on('mouse_selected_color_index_changed', this.mouseColorChangedEventCallback);
    EventBus.getInstance().on(`mouse_style_changed`, this.mouseStyleChangedEventCallback);
    this.mouseStyleChangedEventCallback();
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach('mouse_selected_color_index_changed', this.mouseColorChangedEventCallback);
    EventBus.getInstance().detach('mouse_style_changed', this.mouseStyleChangedEventCallback);
    clearTimeout(this.mouseColorTimer);
  }

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_RED_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_RED
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_YELLOW_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_YELLOW
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_GREEN_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_GREEN
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_CYAN_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_CYAN
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_BLUE_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_BLUE
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_PURPLE_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_PURPLE
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: true,
        radioIndex: MousePointColorIndex.MOUSE_POINT_WHITE_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_WHITE
      })
      MouseColorRatioComponent({
        isSelected: false,
        curSelectedIndex: this.curSelectedIndex,
        isWhite: false,
        radioIndex: MousePointColorIndex.MOUSE_POINT_BLACK_INDEX,
        radioColor: MousePointColor.MOUSE_POINT_BLACK
      })
    }
    .constraintSize(this.isSplit ? { maxWidth: '100%' } : { maxWidth: $r('app.float.mouse_card_slide_width') })
    .margin({ top: $r('app.float.wh_value_8'), bottom: $r('app.float.wh_value_8') })
    .padding({
      left: $r('app.float.padding_12'),
      right: $r('app.float.padding_12')
    })
    .align(Alignment.End)
  }
}

@Component
struct MouseColorRatioComponent {
  @State isSelected: boolean = false;
  @State brColor: ResourceColor = MousePointColor.MOUSE_POINT_BLACK;
  @State bgColor: ResourceColor = MousePointColor.MOUSE_POINT_BLACK;
  @State brWidth: Length | EdgeWidths = 0;
  @Prop @Watch('updateSelectedState') curSelectedIndex: number = 8;
  isWhite: boolean = false;
  radioIndex: number = 0;
  radioColor: ResourceColor = MousePointColor.MOUSE_POINT_BLACK;

  updateSelectedState(): void {
    this.isSelected = this.radioIndex === this.curSelectedIndex
    if (this.isSelected) {
      this.bgColor = this.isWhite ? $r('sys.color.black') : $r('sys.color.white');
      this.brColor = this.radioColor;
      this.brWidth = $r('app.float.mouse_color_circle_select_border_width');
    } else {
      this.bgColor = this.radioColor;
      this.brColor = this.isWhite ? $r('sys.color.black') : this.radioColor;
      this.brWidth = this.isWhite ? 1 : 0;
    }
  }

  aboutToAppear(): void {
    this.updateSelectedState();
  }

  build() {
    Button({ type: ButtonType.Circle })
      .key(`btn_color_select_${this.radioIndex}`)
      .backgroundColor(this.bgColor)
      .width($r('app.float.mouse_color_circle_select_width'))
      .height($r('app.float.mouse_color_circle_select_height'))
      .borderRadius($r('sys.float.corner_radius_level6'))
      .borderWidth(this.brWidth)
      .borderColor(this.brColor)
      .onClick(() => {
        if (!this.isSelected) {
          this.isSelected = true;
          this.curSelectedIndex = this.radioIndex;
          EventBus.getInstance().emit('mouse_selected_color_index_changed', this.curSelectedIndex)
        }
      })
  }
}