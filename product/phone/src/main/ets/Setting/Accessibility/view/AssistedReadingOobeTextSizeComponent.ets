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

import { i18n } from '@kit.LocalizationKit';
import { accessibility } from '@kit.AccessibilityKit';
import { BusinessError } from '@ohos.base';
import settings from '@ohos.settings';
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ElderCareManager } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  ASSISTED_READING_TEXT_SIZE_NAME_LIST,
  FONT_SIZE_SCALE_LIST,
  FONT_SIZE_STEP_NUM,
  MAX_FONT_SIZE_LEVEL,
  MIN_FONT_SIZE_LEVEL,
  TextSizeStepConstants,
  TRANSACTION_TIME
} from '../constant/Constants';
import { AccessibilityCardContainerComp } from './AccessibilityCardContainerComp';
import { CardMaterialManager } from '../../Wlan/view/manager/CardMaterialManager';

/* instrument ignore file */
const TAG: string = 'AssistedReadingOobeTextSizeComponent : ';
const DEFAULT_FONT_SIZE: number = 16;
const FONT_SIZE_BUTTON_Z_INDEX: number = 1;

@Component
export struct AssistedReadingOobeTextSizeComponent {
  @State fontSize: string = DEFAULT_FONT_SIZE + 'vp';
  @State fontSizeStepVal: number = 1;
  // 判断设备是否为宽屏设备，UX规格宽屏对话框安全距离为100vp，非宽屏32vp
  @State isWideScreen: boolean = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand();
  @Link fontSizeName: Resource | string;
  @Link isMainPage: boolean;
  @StorageProp('oobeFootBtnWidth') footBtnWidth: number | Resource = $r('app.float.wh_value_188');
  private maxFontScale: number = i18n.System.getSystemLanguage() === 'bo' ? 1.3 : 1.45 // 判断系统语言是否为藏语来调整按钮最大缩放比例
  private isRTL: boolean = i18n.isRTL(i18n.System.getSystemLanguage());
  private safeMargin: Resource = this.isWideScreen ? $r('app.float.wh_value_100') : $r('app.float.wh_value_32');
  private isSupportNewMaterial: boolean = CardMaterialManager.getInstance().isSupportNewMaterial;

  /**
   * 对话框组件
   */
  @Builder
  buildPreviewComponent() {
    Column() {
      Column() {
        Column() {
          Text($r('app.string.setting_font_size_content1'))
            .fontSize(this.fontSize)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
            .textAlign(TextAlign.Start)
        }
        .stateStyles({ normal: this.messageRightBoxLeftStyles })
      }
      .alignItems(HorizontalAlign.End)
      .width('100%')
      .padding({
        left: this.isRTL ? 0 : this.safeMargin,
        right: this.isRTL ? this.safeMargin : 0,
      })
      .margin({
        bottom: $r('app.float.wh_value_16')
      })

      Column() {
        Column() {
          Text($r('app.string.setting_font_size_content2'))
            .fontSize(this.fontSize)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .textAlign(TextAlign.Start)
        }
        .stateStyles({ normal: this.messageLeftBoxStyles })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({
        left: this.isRTL ? this.safeMargin : 0,
        right: this.isRTL ? 0 : this.safeMargin,
      })
    }
    .padding({
      left: $r('app.float.wh_value_16'),
      right: $r('app.float.wh_value_16'),
    })
    .constraintSize({ minHeight: '100%' })
  }

  /**
   * 字体大小slider组件
   */
  @Builder
  buildSliderComponent() {
    Column() {
      Row() {
        this.fontSizeTextItem();
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height($r('app.float.length_48'))

      this.fontSizeSliderItem();
    }
    .borderRadius($r('app.float.wh_value_16'))
    .backgroundColor(this.isSupportNewMaterial ? $r('app.color.card_bg_color_60') :
      $r('app.color.oobe_wlan_bg_color'))
    .height($r('app.float.wh_value_96'))
    .width('100%')
    .padding({
      left: $r('app.float.length_16'),
      right: $r('app.float.length_16'),
    })
    .margin({
      top: $r('app.float.wh_value_16')
    })
  }

  @Builder
  fontSizeTextItem() {
    Text($r('app.string.screen_zoom_text_size'))
      .fontSize($r('app.float.length_16'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .textAlign(TextAlign.Start)
    Text(this.fontSizeName)
      .fontSize($r('app.float.length_14'))
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontWeight(FontWeight.Regular)
  }

  @Builder
  fontSizeSliderItem() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Button({ type: ButtonType.Normal }) {
        SymbolGlyph($r('sys.symbol.character'))
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_24'))
          .draggable(false)
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
          .fontWeight(FontWeight.Regular)
          .fontSize($r('app.float.wh_value_24'))
      }
      .stateEffect(false)
      .backgroundColor(Color.Transparent)
      .accessibilityText($r('app.string.toggle_to_smaller'))
      .zIndex(FONT_SIZE_BUTTON_Z_INDEX)
      .onClick(() => {
        this.onStartIconClick();
      })

      Column() {
        Slider({
          style: SliderStyle.InSet,
          value: this.fontSizeStepVal,
          step: FONT_SIZE_STEP_NUM,
          max: MAX_FONT_SIZE_LEVEL,
          min: MIN_FONT_SIZE_LEVEL
        })
          .blockColor('#FFFFFF')
          .height($r('app.float.length_20'))
          .showSteps(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.End) {
              this.onSliderChange(value);
            }
          });
      }
      .height($r('app.float.wh_value_40'))
      .padding({
        top: $r('app.float.wh_value_10'),
        left: $r('app.float.wh_value_6'),
        right: $r('app.float.wh_value_4'),
        bottom: $r('app.float.wh_value_10'),
      })

      Button({ type: ButtonType.Normal }) {
        SymbolGlyph($r('sys.symbol.character'))
          .width($r('app.float.wh_value_28'))
          .height($r('app.float.wh_value_28'))
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
          .fontSize($r('app.float.wh_value_28'))
          .fontWeight(FontWeight.Medium)
          .draggable(false)
      }
      .stateEffect(false)
      .backgroundColor(Color.Transparent)
      .accessibilityText($r('app.string.toggle_to_bigger'))
      .zIndex(FONT_SIZE_BUTTON_Z_INDEX)
      .onClick(() => {
        this.onEndIconClick();
      })
    }
    .height($r('app.float.wh_value_48'))
    .padding({
      bottom: $r('app.float.wh_value_8')
    })
  }

  @Builder
  contentBuilder(): void {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Scroll() {
        this.buildPreviewComponent()
      }
      .flexGrow(1)

      Column() {
        this.buildSliderComponent()
      }
      .flexShrink(0)
      .padding({
        left: $r('app.float.wh_value_16'),
        right: $r('app.float.wh_value_16'),
      })
    }
    .width('100%')
    .constraintSize({ minHeight: '100%' })
  }

  /**
   * 底部确定按钮组件
   */
  @Builder
  footerComponent(): void {
    Column() {
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.button_tittle_yes'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
          .maxFontScale(this.maxFontScale)
          .textStyle()
      }
      .width(this.footBtnWidth)
      .height($r('app.float.wh_value_40'))
      .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
      .backgroundColor($r('app.color.font_color_blue_entry_menu'))
      .align(Alignment.Center)
      .onClick(() => {
        this.confirmButtonClick();
      });
    }
    .width('100%')
    .padding({
      top: $r('app.float.wh_value_24'),
      bottom: $r('app.float.wh_value_68')
    })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  pageContainerBuilder(): void {
    Stack() {
      AccessibilityCardContainerComp({
        bodyContent: () => this.contentBuilder(),
        mHeadName: $r('app.string.elder_care_search_item_font_size'),
        onButtonClick: () => this.onBackBtnClick(),
      })
      Column() {
        this.footerComponent();
      }
    }
    .width('100%')
    .height('100%')
    .align(Alignment.End)
    .alignContent(Alignment.Bottom)
  }

  build() {
    HdsNavDestination() {
      Column() {
        this.pageContainerBuilder()
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    let fontSizeScale: number = ElderCareManager.getFontScale();
    LogUtil.info(`${TAG} init font size : ${fontSizeScale}`);
    this.fontSizeStepVal = this.getDefaultFontSizeStep(fontSizeScale);
    this.fontSizeName = this.getDefaultFontSizeScaleName();
    this.changePreviewFontSize(this.fontSizeStepVal - FONT_SIZE_STEP_NUM);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private changePreviewFontSize(sliderNum: number): void {
    this.fontSize = (DEFAULT_FONT_SIZE * FONT_SIZE_SCALE_LIST[sliderNum]).toString() + 'vp';
  }

  private confirmButtonClick(): void {
    LogUtil.info(`${TAG} current font step val: ${this.fontSizeStepVal}`);
    animateTo({ duration: TRANSACTION_TIME }, () => {
      this.isMainPage = true;
    })
    ElderCareManager.setFontSize(FONT_SIZE_SCALE_LIST[this.fontSizeStepVal - 1]);
    SettingsDataUtils.setSettingsDataDomain(settings.display.FONT_SCALE,
      FONT_SIZE_SCALE_LIST[this.fontSizeStepVal - 1].toString(), settings.domainName.USER_PROPERTY);
  }

  private onBackBtnClick(): void {
    LogUtil.info(`${TAG} backSheetPage`);
    animateTo({ duration: TRANSACTION_TIME }, () => {
      this.isMainPage = true;
    })
    let fontSizeScale: number = ElderCareManager.getFontScale();
    const index = FONT_SIZE_SCALE_LIST.findIndex(item => item === fontSizeScale);
    if (index !== -1) {
      this.fontSizeName = ASSISTED_READING_TEXT_SIZE_NAME_LIST[index];
    } else {
      this.fontSizeName = $r('app.string.display_mode_font_size_normal');
    }
  }

  private getDefaultFontSizeScaleName(): Resource {
    return ASSISTED_READING_TEXT_SIZE_NAME_LIST[this.fontSizeStepVal - FONT_SIZE_STEP_NUM];
  }

  private getDefaultFontSizeStep(fontSizeScale: number): number {
    LogUtil.info(`${TAG} fontSizeScale is ${fontSizeScale}`);
    switch (fontSizeScale) {
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL:
        return TextSizeStepConstants.TEXT_FONT_SIZE_NORMAL_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE:
        return TextSizeStepConstants.TEXT_FONT_SIZE_LARGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE:
        return TextSizeStepConstants.TEXT_FONT_SIZE_EXTRA_LARGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE:
        return TextSizeStepConstants.TEXT_FONT_SIZE_HUGE_STEP;
      default:
        return TextSizeStepConstants.TEXT_FONT_SIZE_NORMAL_STEP;
    }
  }

  private onStartIconClick(): void {
    LogUtil.info(`${TAG} current fontsize value: ${this.fontSizeStepVal}`);
    if (this.fontSizeStepVal > MIN_FONT_SIZE_LEVEL) {
      this.fontSizeStepVal -= FONT_SIZE_STEP_NUM;
      this.fontSizeName = this.getDefaultFontSizeScaleName();
      this.changePreviewFontSize(this.fontSizeStepVal - FONT_SIZE_STEP_NUM);
      this.sendAccessibilityEvent(ResourceUtil.getStringSync(this.fontSizeName));
    }
  }

  private onEndIconClick(): void {
    LogUtil.info(`${TAG} current fontsize value: ${this.fontSizeStepVal}`);
    if (this.fontSizeStepVal < MAX_FONT_SIZE_LEVEL) {
      this.fontSizeStepVal += FONT_SIZE_STEP_NUM;
      this.fontSizeName = this.getDefaultFontSizeScaleName();
      this.changePreviewFontSize(this.fontSizeStepVal - FONT_SIZE_STEP_NUM);
      this.sendAccessibilityEvent(ResourceUtil.getStringSync(this.fontSizeName));
    }
  }

  private onSliderChange(sliderNum: number): void {
    LogUtil.info(`${TAG} on slider change : ${sliderNum}`);
    this.fontSizeStepVal = sliderNum;
    this.fontSizeName = this.getDefaultFontSizeScaleName();
    this.changePreviewFontSize(this.fontSizeStepVal - FONT_SIZE_STEP_NUM);
  }

  private sendAccessibilityEvent(text: string): void {
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.settings',
      triggerAction: 'common',
      textAnnouncedForAccessibility: text
    });
    accessibility.sendAccessibilityEvent(eventInfo).then(() => {
      LogUtil.info(`${TAG} Succeeded in send event`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} failed in send event, error: ${error?.code}`);
    });
  }

  /**
   * 右侧对话框通用样式
   */
  @Styles
  messageRightBoxLeftStyles() {
    .backgroundColor($r('app.color.oobe_text_size_bg_color'))
    .borderRadius({
      topLeft: this.isRTL ? $r('app.float.wh_value_2') : $r('app.float.wh_value_16'),
      topRight: this.isRTL ? $r('app.float.wh_value_16') : $r('app.float.wh_value_2'),
      bottomLeft: $r('app.float.wh_value_16'),
      bottomRight: $r('app.float.wh_value_16'),
    })
    .padding({
      top: $r('app.float.wh_value_8'),
      left: $r('app.float.wh_value_10'),
      right: $r('app.float.wh_value_10'),
      bottom: $r('app.float.wh_value_8'),
    })
  }

  /**
   * 左侧对话框通用样式
   */
  @Styles
  messageLeftBoxStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
    .borderRadius({
      topLeft: this.isRTL ? $r('app.float.wh_value_16') : $r('app.float.wh_value_2'),
      topRight: this.isRTL ? $r('app.float.wh_value_2') : $r('app.float.wh_value_16'),
      bottomLeft: $r('app.float.wh_value_16'),
      bottomRight: $r('app.float.wh_value_16'),
    })
    .padding({
      top: $r('app.float.wh_value_8'),
      left: $r('app.float.wh_value_10'),
      right: $r('app.float.wh_value_10'),
      bottom: $r('app.float.wh_value_8'),
    })
  }
}

@Extend(Text)
function textStyle() {
  .height('100%')
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .minFontSize($r('app.float.font_9'))
  .maxFontSize($r('app.float.font_16'))
  .maxLines(1)
}