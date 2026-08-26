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
import MediaQuery from '@ohos.mediaquery';
import { BusinessError } from '@ohos.base';
import { accessibility } from '@kit.AccessibilityKit';
import { settings } from '@kit.BasicServicesKit';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ElderCareUtils } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  ElderCareEnlargeDisplayConstant
} from '@ohos/settings.common/src/main/ets/constant/ElderCareEnlargeDisplayConstant';
import { ElderCareZoomDisplayConstants, FONT_SIZE_STEP_NUM } from '../../constant/Constants';

const DEFAULT_LEVEL: string = '0';
const LANGUAGE_BO = 'bo'; // 系统语言为藏文
const boLineHeight = '165%';
const ELDER_CARE_SWITCH_TOGGLE_ID: string = 'Setting.ElderCare.elder_care_switch_group.elder_care_switch.toggle';
const DEFAULT_FONT_SIZE: number = 16;
const DEFAULT_FONT_WEIGHT: number = 400;
const MAX_PRE_VIEW_HEIGHT: number = 168;
let isPad: boolean = DeviceUtil.isDevicePad();
let isLargeFold: boolean = DeviceUtil.isLargeInFoldProduct();

@Component
export struct ElderCareEnlargeDisplayComponent {
  private startIconAccessibilyText: string = ResourceUtil.getStringSync($r('app.string.elder_care_make_smaller'));
  private endIconAccessibilyText: string = ResourceUtil.getStringSync($r('app.string.elder_care_make_larger'));
  tag: string = 'ElderCareEnlargeDisplayComponent : ';
  item?: SettingItemModel;
  @State fontSizeName: string | Resource = '';
  @State sliderValue: number = 0;
  @State fontSize: string = DEFAULT_FONT_SIZE + 'vp';
  @State fontWeight: number = DEFAULT_FONT_WEIGHT;
  @State isShow: boolean = true;
  @State previewLength: number | Resource | string = $r('app.float.padding_36');
  @StorageLink('isPortraitOrientation') isPortraitOrientation: boolean = false;
  private orientationListener: MediaQuery.MediaQueryListener | undefined = undefined;
  currentLanguage = i18n.System.getSystemLanguage();
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} receive toggle state change: ${toggleState.state}`);
    this.isShow = toggleState.state;
  }

  build() {
    Column() {
      this.buildItemTitle();
      Column() {
        Row() {
          this.buildPreview();
        }
        .width('100%')
        .padding({
          top: $r('sys.float.padding_level8'),
          bottom: $r('sys.float.padding_level4')
        })

        Row() {
          Text(this.fontSizeName)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('sys.color.font_primary'))
        }.margin({ top: $r('sys.float.padding_level8'), bottom: $r('sys.float.padding_level4') })

        this.buildSlider();
      }
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .width('100%')
    }
    .visibility(this.isShow ? Visibility.Visible : Visibility.None)
  }

  @Builder
  buildItemTitle() {
    Column() {
      Row() {
        Text($r('app.string.elder_care_enlarge_display'))
          .id(`entry_toggle_elder_care_title`)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Start)
      }
      .width('100%')
    }
    .padding({
      start: PADDING_12,
      end: PADDING_12,
      top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_16 : PADDING_0,
      bottom: PADDING_8
    })
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .justifyContent(FlexAlign.End)
  }

  @Builder
  buildPreview() {
    Scroll() {
      Column() {
        this.buildFirstLineText();
        this.buildSecondLineText();
      }.width('100%')
    }
    .constraintSize({ maxHeight: MAX_PRE_VIEW_HEIGHT })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  buildFirstLineText() {
    Flex({ justifyContent: FlexAlign.End }) {
      Column() {
        Text($r('app.string.elder_care_preview_text1_new'))
          .fontSize(this.fontSize)
          .fontWeight(this.fontWeight)
          .fontColor($r('sys.color.font_on_primary'))
          .textAlign(TextAlign.Start)
          .lineHeight(this.currentLanguage === LANGUAGE_BO ? boLineHeight : 0)
      }
      .borderRadius({
        topLeft: $r('sys.float.corner_radius_level8'),
        topRight: $r('sys.float.corner_radius_level1'),
        bottomLeft: $r('sys.float.corner_radius_level8'),
        bottomRight: $r('sys.float.corner_radius_level8')
      })
      .backgroundColor($r('sys.color.background_emphasize'))
      .padding({
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level4'),
        left: $r('sys.float.padding_level5'),
        right: $r('sys.float.padding_level5')
      })
    }
    .width('100%')
    .padding({ left: this.previewLength })
  }

  @Builder
  buildSecondLineText() {
    Flex({ justifyContent: FlexAlign.Start }) {
      Column() {
        Text($r('app.string.elder_care_preview_text2'))
          .fontSize(this.fontSize)
          .fontWeight(this.fontWeight)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .lineHeight(this.currentLanguage === LANGUAGE_BO ? boLineHeight : 0)
      }
      .borderRadius({
        topLeft: $r('sys.float.corner_radius_level1'),
        topRight: $r('sys.float.corner_radius_level8'),
        bottomLeft: $r('sys.float.corner_radius_level8'),
        bottomRight: $r('sys.float.corner_radius_level8')
      })
      .backgroundColor($r('sys.color.interactive_hover'))
      .padding({
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level4'),
        left: $r('sys.float.padding_level5'),
        right: $r('sys.float.padding_level5')
      })
      .margin({ top: $r('sys.float.padding_level8') })
    }
    .width('100%')
    .padding({ right: this.previewLength })
  }

  @Builder
  buildSlider() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Button({ type: ButtonType.Normal, stateEffect: false }) {
        SymbolGlyph($r('sys.symbol.minus_magnifyingglass'))
          .accessibilityText(this.startIconAccessibilyText)
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
          .fontSize($r('app.float.wh_value_24'))
          .draggable(false)
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onStartIconClick();
      });

      Slider({
        value: this.sliderValue,
        min: ElderCareZoomDisplayConstants.ZOOM_DISPLAY_LEVEL_MIN,
        max: ElderCareZoomDisplayConstants.ZOOM_DISPLAY_LEVEL_MAX,
        step: ElderCareZoomDisplayConstants.ZOOM_DISPLAY_STEP,
        style: SliderStyle.InSet
      })
        .margin({
          top: $r('app.float.wh_value_0'),
          bottom: $r('app.float.wh_value_0'),
          left: $r('app.float.margin_6'),
          right: $r('app.float.margin_6'),
        })
        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .showSteps(true)
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode === SliderChangeMode.End) {
            this.onSliderChange(value);
          }
        })

      Button({ type: ButtonType.Normal, stateEffect: false }) {
        SymbolGlyph($r('sys.symbol.plus_magnifyingglass'))
          .accessibilityText(this.endIconAccessibilyText)
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
          .fontSize($r('app.float.wh_value_24'))
          .draggable(false)
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.onEndIconClick();
      });
    }
    .margin({
      bottom: $r('sys.float.padding_level6'), left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6')
    })
  }

  private changePreView(value: number): void {
    LogUtil.info(`${this.tag} change preview val: ${value}`);
    this.fontSize = (DEFAULT_FONT_SIZE * ElderCareUtils.FONT_SIZE_SCALE_LIST[value]).toString() + 'vp';
    this.fontWeight = DEFAULT_FONT_WEIGHT * ElderCareUtils.FONT_WEIGHT_SCALE_LIST[value];
  }

  private initPreviewLayout(isPortraitOrientation: boolean): void {
    if (isPad) {
      if (isPortraitOrientation) {
        LogUtil.info(`${this.tag} isPad and Portrait screen`)
        // 平板竖屏
        this.previewLength = $r('app.float.value_140');
      } else {
        LogUtil.info(`${this.tag} isPad and Landscape screen`)
        // 平板横屏
        this.previewLength = $r('app.float.length_224');
      }
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
      LogUtil.info(`${this.tag} isPortraitOrientation: ${this.isPortraitOrientation}`)
      this.initPreviewLayout(this.isPortraitOrientation)
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    EventBus.getInstance().on(ELDER_CARE_SWITCH_TOGGLE_ID, this.onToggleChangeCallback);
    // 添加平板页面横竖屏的监听器
    if (isPad) {
      this.isPortraitOrientation = DisplayUtils.isScreenPortraitOrientation();
      this.initPreviewLayout(this.isPortraitOrientation);
      this.addOrientationListener();
    }
    if (isLargeFold) {
      LogUtil.info(`${this.tag} isLargeFold and Landscape Portrait screen`)
      // 大折叠横竖屏
      this.previewLength = $r('app.float.width_120');
    }
    this.isShow = ElderCareUtils.isElderCareOn();
    this.initEnlargeDisplayContent();
    this.registerStateChange();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    // 销毁平板页面横竖屏监听器
    if (isPad) {
      this.orientationListener?.off('change');
    }
    EventBus.getInstance().detach(ELDER_CARE_SWITCH_TOGGLE_ID, this.onToggleChangeCallback);
    this.unRegisterStateChange();
  }

  private initEnlargeDisplayContent(): void {
    let enlargeDisplayScale: string = SettingsDataUtils.getSecureValue('elder_care_font_scale', DEFAULT_LEVEL);
    if (Number.isNaN(Number(enlargeDisplayScale))) {
      LogUtil.error(`${this.tag} elderCareFontValue is not number.`);
      enlargeDisplayScale = DEFAULT_LEVEL;
    }
    let enlargeDisplayPreLevel: number =
      Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, '0'));
    if (Number(enlargeDisplayScale) !== enlargeDisplayPreLevel) {
      SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, enlargeDisplayScale);
    }
    this.sliderValue = Number(enlargeDisplayScale);
    this.fontSizeName = this.getEnlargeDisplayTitle(this.sliderValue);
    this.changePreView(this.sliderValue);
  }

  private onStartIconClick(): void {
    LogUtil.info(`${this.tag} current fontsize value: ${this.sliderValue}`);
    if (this.sliderValue > ElderCareZoomDisplayConstants.ZOOM_DISPLAY_LEVEL_MIN) {
      this.sliderValue -= FONT_SIZE_STEP_NUM;
      this.handleFontChangeEvents(true);
    }
  }

  private onEndIconClick(): void {
    LogUtil.info(`${this.tag} current fontsize value: ${this.sliderValue}`);
    if (this.sliderValue < ElderCareZoomDisplayConstants.ZOOM_DISPLAY_LEVEL_MAX) {
      this.sliderValue += FONT_SIZE_STEP_NUM;
      this.handleFontChangeEvents(true);
    }
  }

  private onSliderChange(sliderNum: number): void {
    LogUtil.info(`${this.tag} on slider change : ${sliderNum}`);
    if (sliderNum === this.sliderValue) {
      LogUtil.info(`${this.tag} font size slider val not change`);
      return;
    }
    this.sliderValue = sliderNum;
    this.handleFontChangeEvents(false);
  }

  private handleFontChangeEvents(isNeedBroadcast: boolean): void {
    this.fontSizeName = this.getEnlargeDisplayTitle(this.sliderValue);
    this.changePreView(this.sliderValue);
    if (isNeedBroadcast) {
      this.sendAccessibilityEvent(ResourceUtil.getStringSync(this.fontSizeName));
    }
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_PRE_SET_LEVEL, this.sliderValue.toString());
    if (this.sliderValue !== ElderCareUtils.ELDER_CARE_START_PRE) {
      SettingsDataUtils.setSettingsData(ElderCareUtils.ELDER_CARE_PRE_HAS_CHANGED, 'true');
    }
  }

  private getEnlargeDisplayTitle(sliderNum: number): ResourceStr {
    LogUtil.info(`${this.tag} sliderNum is ${sliderNum}`);
    switch (sliderNum) {
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_DEFAULT_STEP:
        return ResourceUtil.getStringSync($r('app.string.display_mode_font_size_normal'));
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_ONE_STEP:
        return ResourceUtil.getNumberFormatStringSync($r('app.string.elder_care_display_level'), '1');
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_TWO_STEP:
        return ResourceUtil.getNumberFormatStringSync($r('app.string.elder_care_display_level'), '2');
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_THREE_STEP:
        return ResourceUtil.getNumberFormatStringSync($r('app.string.elder_care_display_level'), '3');
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_FOUR_STEP:
        return ResourceUtil.getNumberFormatStringSync($r('app.string.elder_care_display_level'), '4');
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_FIVE_STEP:
        return ResourceUtil.getNumberFormatStringSync($r('app.string.elder_care_display_level'), '5');
      case ElderCareEnlargeDisplayConstant.ENLARGE_DISPLAY_LARGE_SIX_STEP:
        return ResourceUtil.getNumberFormatStringSync($r('app.string.elder_care_display_level'), '6');
      default:
        return ResourceUtil.getStringSync($r('app.string.display_mode_font_size_normal'));
    }
  }

  private sendAccessibilityEvent(text: string): void {
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.settings',
      triggerAction: 'common',
      textAnnouncedForAccessibility: text
    });
    accessibility.sendAccessibilityEvent(eventInfo).then(() => {
      LogUtil.info(`${this.tag} Succeeded in send event`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} failed in send event, error: ${error?.code}`);
    });
  }

  private registerStateChange(): void {
    SettingsDataUtils.registerKeyObserverWithDomain(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL,
      settings.domainName.USER_SECURITY, () => {
        this.sliderValue =
          Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, DEFAULT_LEVEL));
        this.handleFontChangeEvents(false);
        LogUtil.info(`${this.tag} current slider value:  ${this.sliderValue}`);
      })
  }

  private unRegisterStateChange(): void {
    SettingsDataUtils.unregisterKeyObserverWithDomain(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL,
      settings.domainName.USER_SECURITY);
  }
}
