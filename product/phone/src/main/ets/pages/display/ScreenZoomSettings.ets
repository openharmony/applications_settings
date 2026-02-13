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

import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import dataShare from '@ohos.data.dataShare';
import common from '@ohos.app.ability.common';
import Settings from '@ohos.settings';
import uiAppearance from '@ohos.uiAppearance';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import DpiManager from '@ohos/settings.common/src/main/ets/utils/DpiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontWeightInfo, TsRemoteCaller } from '@ohos/settings.uikit/src/main/ets/service/api/TsRemoteCaller';
import {
  DisplayUtils,
  SUMMARIES_LARGER,
  SUMMARIES_SMALLER,
  SUMMARY_DEFAULT,
} from '@ohos/settings.display/src/main/ets/DisplayUtils';
import { DisplayManager } from '@ohos/settings.common/src/main/ets/displaymanager/DisplayManager';
import { DisplayChange } from '@ohos/settings.common/src/main/ets/displaymanager/DisplayChange';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { FontSizeAdjustComponent } from '@ohos/settings.uikit/src/main/ets/component/display/FontSizeAdjustComponent';
import { FontWeightAdjustComponent } from '@ohos/settings.uikit/src/main/ets/component/display/FontWeightAdjustComponent';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { EVENT_ID_CONFIGURATION_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ScreenZoomPage } from './model/ScreenZoomPage';
import { ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED } from '../../Setting/Accessibility/constant/Constants';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */


/**
 * 滑动条的颗粒
 */
const STEP_NUM: number = 1;

@Builder
export function ScreenZoomSettingsLoader($$: Params): void {
  ScreenZoomSettings();
}

@Component
export struct ScreenZoomSettings {
  private TAG: string = 'ScreenZoomSettings : ';
  private elderCareModeStatus: string = SettingsDataUtils
    .getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, '0');
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('initial_settings_dpi') initialSettingsDpi: number = -1;
  @StorageLink('display_size_value') inSetValue: number = 0;
  @StorageLink('display_size_dpi_name') dpiName: Resource = SUMMARY_DEFAULT;
  @State isRefresh: boolean = false;
  @State fontSizeScale: number = Number(SettingsDataUtils
    .getSettingsDataDomain(Settings.display.FONT_SCALE, DisplayConstant.DEFAULT_FONT_SIZE_SCALE,
      Settings.domainName.USER_PROPERTY));
  @State @Watch('fontSizeChange') fontSizeStepVal: number = DisplayUtils.getDefaultFontSizeStep(this.fontSizeScale);
  @State maxFontSizeLevel: number = this.elderCareModeStatus === '1' ? DisplayConstant.CARING_MODEL_MAX_FONT_SIZE_LEVEL
    : DisplayConstant.MAX_FONT_SIZE_LEVEL_PHONE;
  @State maxFontWeightLevel: number = DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST;
  @State fontWeightVal: number = Number(SettingsDataUtils
    .getSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, DisplayConstant.DEFAULT_FONT_WEIGHT_SCALE,
      Settings.domainName.USER_PROPERTY));
  @State fontWeightStepVal: number = this.fontWeightVal;
  isFromExternal: boolean = false;
  windowWidth: number = 0;
  title: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_and_text'));
  statusFold: number = DisplayManager.getInstance().getFoldStatus();
  halfFullWidth: number = 0;
  private context = getContext(this) as common.UIAbilityContext;
  private isBackPressed: boolean = false;
  private imageWidth: string = '280vp';
  private imageHeight: string = '158vp';
  private oriFontSizeScale: number = this.fontSizeScale;
  private oriFontWeightScale: number = this.fontWeightVal;
  private isShownLargerFontTip: boolean = false;
  private largerFontDialogController: CustomDialogController | undefined = undefined;
  private displayChange: DisplayChange = new DisplayChange();
  @State multiWeight: boolean = true; // 在线字体

  // 关怀模式开关状监听回调
  private onDataChange = () => {
    let careModeStatus: string = SettingsDataUtils
      .getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, '0');
    LogUtil.info(`${this.TAG} elder care status data change ${careModeStatus}`);
    this.maxFontSizeLevel = careModeStatus === '1' ? DisplayConstant.CARING_MODEL_MAX_FONT_SIZE_LEVEL :
    DisplayConstant.MAX_FONT_SIZE_LEVEL_PHONE;
  }

  // 显示大小数据库变化监听回调(自由多窗)
  private onDpiDataChange = () => {
    let dpi: string = SettingsDataUtils.getSettingsData(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE,
      DpiManager.defaultDensityDpi.toString());
    this.inSetValue = DpiManager.getIndexByDpi(Number(dpi));
    this.dpiName = DpiManager.getDpiName(this.inSetValue);
    LogUtil.info(`${this.TAG} onDpiDataChange : ${dpi} - ${this.inSetValue} - ${this.dpiName}`);
    this.displayChange.emitDisplayChange();
  }

  // 关怀模式页面字体大小调整监听回调
  private onFontSizeChange = () => {
    LogUtil.info(`${this.TAG} onFontSizeChange`);
    let curFontSizeScale: number = Number(SettingsDataUtils
      .getSettingsDataDomain(Settings.display.FONT_SCALE, DisplayConstant.DEFAULT_FONT_SIZE_SCALE,
        Settings.domainName.USER_PROPERTY));
    let curFontWeightScale: number = Number(SettingsDataUtils
      .getSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, DisplayConstant.DEFAULT_FONT_WEIGHT_SCALE,
        Settings.domainName.USER_PROPERTY));
    if (this.fontSizeScale !== curFontSizeScale) {
      LogUtil.info(`${this.TAG} font size changed, need update, ${curFontSizeScale}`);
      this.fontSizeScale = curFontSizeScale;
      this.fontSizeStepVal = this.getFontSizeStep();
    }
    if (this.fontWeightVal !== curFontWeightScale) {
      LogUtil.info(`${this.TAG} font weight changed, need update, ${curFontWeightScale}`);
      this.fontWeightVal = curFontWeightScale;
      this.fontWeightStepVal = this.fontWeightVal;
    }
    EventBus.getInstance().emit(EVENT_ID_CONFIGURATION_UPDATE.toString());
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Blank().height($r('app.float.navigation_56'))
          this.buildTextAndImageContent();
          this.buildControllerContent();
        }
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      this.isBackPressed = true;
      if (this.isFromExternal) {
        LogUtil.info(`${this.TAG} onBackPressed`);
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DISPLAY_SIZE_SLIDER_CHANGE,
          this.getValue());
        this.termiteAbility();
        return true;
      }
      return false;
    })
  }

  @Builder
  buildControllerContent(): void {
    Column() {
      Column() {
        this.buildFontSizeAdjustComponent();
        this.buildFontWeightAdjustComponent();
        this.buildZoomItem();
      }
      .borderRadius($r('app.float.border_radius_20'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding({
        left: $r('app.float.length_16'),
        right: $r('app.float.length_16'),
        bottom: $r('app.float.length_20'),
      })
      .constraintSize({
        minHeight: $r('app.float.length_273')
      })
    }
    .margin({
      top: $r('app.float.length_32'),
      bottom: $r('app.float.length_16'),
      left: $r('app.float.length_16'),
      right: $r('app.float.length_16')
    })
    .justifyContent(FlexAlign.End)
  }

  @Builder
  buildTextAndImageContent(): void {
    Column() {
      Scroll() {
        Column() {
          Column() {
            this.buildFirstLineText();
            Image($r('app.media.display_illustration_image'))
              .margin({ top: $r('app.float.length_16') })
              .border({ radius: $r('app.float.border_radius_16') })// .height(this.imageHeight)
              .width(this.imageWidth)
              .height(this.imageHeight)// .objectFit(ImageFit.Auto)
              .draggable(false)
          }.alignItems(HorizontalAlign.End)
          .width('100%')
          this.buildSecondLineText();
        }.alignItems(HorizontalAlign.Start)
        .width('100%')
      }.scrollBar(BarState.Off)
    }.backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .padding({ left: $r('app.float.length_16'), right: $r('app.float.length_16') })
    .width('100%')
    .layoutWeight(1)
    .accessibilityGroup(true)
    .accessibilityText($r('app.string.font_adjustment_preview'))
  }

  @Builder
  buildFirstLineText(): void {
    Column() {
      this.buildMessage($r('app.string.display_mode_mail_content_1'), $r('app.string.display_mode_mail_content_2'),
        $r('sys.color.ohos_id_color_text_primary_contrary'));
    }
    .borderRadius({ topLeft: $r('app.float.length_16'), topRight: $r('app.float.length_2'),
      bottomLeft: $r('app.float.length_16'), bottomRight: $r('app.float.length_16') })
    .backgroundColor('#0A59F7')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: $r('app.float.length_21') })
  }

  @Builder
  buildSecondLineText(): void {
    Column() {
      Text($r('app.string.display_mode_mail_content_3'))
        .fontSize(this.calcFontSize(DisplayConstant.DEFAULT_FONT_SIZE))
        .fontWeight(this.calcFontWeight(), {enableVariableFontWeight: true})
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .textAlign(TextAlign.Start)
    }.borderRadius({ topLeft: $r('app.float.length_2'), topRight: $r('app.float.length_16'),
      bottomLeft: $r('app.float.length_16'), bottomRight: $r('app.float.length_16') })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding('8vp')
    .margin({ top: $r('app.float.length_16') })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildMessage(firstContent: Resource, secondContent: Resource, fontColor: ResourceColor): void {
    if (DeviceUtil.isDevicePad()) {
      Text(this.getPadMessage(firstContent, secondContent))
        .fontSize(this.calcFontSize(DisplayConstant.DEFAULT_FONT_SIZE))
        .fontWeight(this.calcFontWeight(), {enableVariableFontWeight: true})
        .fontColor(fontColor)
        .textAlign(TextAlign.Start)
    } else {
      Text(firstContent)
        .fontSize(this.calcFontSize(DisplayConstant.DEFAULT_FONT_SIZE))
        .fontWeight(this.calcFontWeight(), {enableVariableFontWeight: true})
        .fontColor(fontColor)
        .textAlign(TextAlign.Start)
      Text(secondContent)
        .fontSize(this.calcFontSize(DisplayConstant.DEFAULT_FONT_SIZE))
        .fontWeight(this.calcFontWeight(), {enableVariableFontWeight: true})
        .fontColor(fontColor)
        .textAlign(TextAlign.Start)
    }
  }

  private fontSizeChange(): void {
    LogUtil.info(`${this.TAG} fontSizeChange ${this.fontSizeStepVal}, ${this.isShownLargerFontTip}`);
    if (this.isNeedShowLargerFontTip()) {
      this.isShownLargerFontTip = true;
      //暂时屏蔽关怀模式的弹窗
      // this.openLargerFontDialog();
    }
  }

  private isNeedShowLargerFontTip(): boolean {
    return this.isShownLargerFontTip === false && this.fontSizeStepVal === DisplayConstant.MAX_FONT_SIZE_LEVEL_PHONE &&
      this.elderCareModeStatus === '0';
  }

  registerDataChange() {
    SettingsDataUtils.registerKeyObserverWithDomain(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
      Settings.domainName.USER_SECURITY, (err, value) => {
      this.onDataChange();
    });
    SettingsDataUtils.registerKeyObserver(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE, this.onDpiDataChange);
    LogUtil.info(`${this.TAG} elder care key listener registerd`);
  }

  unRegisterDataChange() {
    SettingsDataUtils.unregisterKeyObserverWithDomain(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
      Settings.domainName.USER_SECURITY);
    SettingsDataUtils.unregisterKeyObserver(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE);
    LogUtil.info(`${this.TAG} elder care key listener unregisterd`);
  }

  registerFontDataChange() {
    LogUtil.info(`${this.TAG} registerFontDataChange`);
    SettingsDataUtils.registerKeyObserverUser(Settings.display.FONT_SCALE, (err, value) => {
      this.onFontSizeChange();
    });
  }

  unRegisterFontDataChange() {
    LogUtil.info(`${this.TAG} unRegisterFontDataChange`);
    SettingsDataUtils.unregisterKeyObserverUser(Settings.display.FONT_SCALE);
  }

  private openLargerFontDialog(): void {
    let message: string = ResourceUtil.getStringSync($r('app.string.set_larger_fonts_message'));
    this.largerFontDialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: $r('app.string.set_larger_fonts'),
        content: message,
        primaryButton: {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.largerFontDialogController?.close();
          },
        },
        secondaryButton: {
          value: $r('app.string.go_to_set'),
          action: () => {
            LogUtil.info(`${this.TAG} onDialogConfirm`);
            this.largerFontDialogController?.close();
            this.goToElderMode();
          }
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.largerFontDialogController.open();
  }

  private goToElderMode(): void {
    PageRouter.push(NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY);
  }

  private getFontSizeStep(): number {
    switch (this.fontSizeScale) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL:
        return DisplayConstant.TEXT_FONT_SIZE_SMALL_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL:
        return DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE:
        return DisplayConstant.TEXT_FONT_SIZE_LARGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE:
        return DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE2_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE3_STEP;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4:
        return DisplayConstant.TEXT_FONT_SIZE_HUGE4_STEP;
      default:
        return DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP;
    }
  }

  private getPadMessage(firstContent: Resource, secondContent: Resource): string {
    return ResourceUtil.getStringSync(firstContent) + ResourceUtil.getStringSync(secondContent);
  }

  private calcFontSize(fpSize: number): string {
    LogUtil.info(`${this.TAG} start calcFontSize`);
    let dpiValue: number = DpiManager.getDpiValue(this.inSetValue) / DisplayConstant.DEFAULT_DPI_DENSITY;
    let fontSize: number = dpiValue * fpSize * this.fontSizeScale;
    LogUtil.info(`${this.TAG} calcFontSize ${this.inSetValue} - ${dpiValue} - ${fontSize}`);
    return Number.parseInt(fontSize.toString()) + 'px';
  }

  private calcFontWeight(): number {
    let fontWeight: number = DisplayConstant.FONT_WEIGHT_REGULAR * this.fontWeightVal;
    // 从主题接口拿到multiWeight字段
    const remoteCaller = new TsRemoteCaller(getContext() as common.UIAbilityContext);
    remoteCaller.getFontWeightInfo().then((item: FontWeightInfo) => {
      this.multiWeight = item?.multiWeight;
      LogUtil.info(`${this.TAG} multiWeight: ${item?.multiWeight}`);
    }).catch((err:Error) => {
      LogUtil.showError(this.TAG, `error in getMultiWeight: ${err?.message}`);
    });

    LogUtil.info(`${this.TAG} calcFontWeight ${this.fontWeightVal} - ${fontWeight}`);
    return Number.parseInt(fontWeight.toString());
  }

  private updateConfig(): void {
    if (this.oriFontSizeScale === this.fontSizeScale && this.oriFontWeightScale === this.fontWeightVal &&
      this.dpiName === DpiManager.getDpiName(this.inSetValue)) {
      LogUtil.info(`${this.TAG} no need updateConfig`);
      return;
    }
    try {
      uiAppearance.setFontScale(this.fontSizeScale);
      uiAppearance.setFontWeightScale(this.fontWeightVal);
      this.dpiName = DpiManager.setDpiName(this.inSetValue);
      this.updateSettingDataDB();
      FontScaleUtils.setConfig(this.fontSizeScale);
    } catch (err) {
      LogUtil.error(`${this.TAG} error code: ${err.code} message: ${err.message}`);
    }
  }

  private updateSettingDataDB(): void {
    LogUtil.info(`${this.TAG} reset and updateConfiguration success, ${this.fontSizeScale} ${this.fontWeightVal}`);
    this.oriFontSizeScale = this.fontSizeScale;
    this.oriFontWeightScale = this.fontWeightVal;
    SettingsDataUtils.setSettingsDataDomain(Settings.display.FONT_SCALE,
      this.fontSizeScale.toString(), Settings.domainName.USER_PROPERTY);
    SettingsDataUtils.setSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE,
      this.fontWeightVal.toString(), Settings.domainName.USER_PROPERTY);
  }

  @Builder
  buildZoomItem(): void {
    Row() {
      Text($r('app.string.screen_zoom_title'))
        .fontSize($r('app.float.wh_value_16'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .textAlign(TextAlign.Start)
        .fontFamily('HarmonyHeiTi')
      Text(this.dpiName)
        .fontSize($r('app.float.wh_value_14'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
    }.justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.length_48')})
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      SymbolGlyph($r('sys.symbol.minus_magnifyingglass'))
        .draggable(false)
        .fontSize($r('app.float.wh_value_24'))
        .fontColor([$r('sys.color.ohos_id_color_text_primary')])
        .accessibilityText($r('app.string.toggle_to_smaller'))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .onClick(() => {
          this.onReduceClick();
          AccessibilityUtils.announceText(ResourceUtil.getStringSync(this.dpiName));
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DISPLAY_SIZE_SLIDER_CHANGE,
            this.getValue());
        })
        .responseRegion({ x: -8, y: -8, width: 40, height: 40 })
      Slider({
        style: SliderStyle.InSet,
        value: this.inSetValue,
        step: STEP_NUM,
        max: DpiManager.numSmaller + DpiManager.numLarger,
        min: 0
      }).responseRegion({ x: 0, y: -6, width: '100%', height: 32 })
        .blockColor('#ffffff')
        .height($r('app.float.length_20'))
        .showSteps(true)
        .margin({ left: $r('app.float.length_5'), right: $r('app.float.length_5') })
        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode === SliderChangeMode.End) {
            LogUtil.info(`${this.TAG} slider dpi value change end`);
            this.zoomSliderChange(value);
          }
        });
      SymbolGlyph($r('sys.symbol.plus_magnifyingglass'))
        .draggable(false)
        .fontSize($r('app.float.wh_value_24'))
        .fontColor([$r('sys.color.ohos_id_color_text_primary')])
        .accessibilityText($r('app.string.toggle_to_bigger'))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .onClick(() => {
          this.onIncreaseClick();
          AccessibilityUtils.announceText(ResourceUtil.getStringSync(this.dpiName));
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DISPLAY_SIZE_SLIDER_CHANGE,
            this.getValue());
        })
        .responseRegion({ x: -8, y: -8, width: 40, height: 40 })
    }.constraintSize({ minHeight: $r('app.float.height_40') })
  }

  @Builder
  buildFontSizeAdjustComponent(): void {
    FontSizeAdjustComponent({
      fontSizeScale: this.fontSizeScale,
      fontSizeStepVal: this.fontSizeStepVal,
      maxFontSizeLevel: this.maxFontSizeLevel,
    })
  }

  @Builder
  buildFontWeightAdjustComponent(): void {
    FontWeightAdjustComponent({
      fontWeightVal: this.fontWeightVal,
      fontWeightStepVal: this.fontWeightVal,
      maxFontWeightLevel: this.maxFontWeightLevel,
      multiWeight: this.multiWeight,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear`);
    DpiManager.getClassInstance();
    DpiManager.setDefaultDpi(displayDataManager.getDefaultDPI());
    this.inSetValue = DpiManager.setNumberAndScale(SUMMARIES_LARGER, SUMMARIES_SMALLER, SUMMARY_DEFAULT);
    this.dpiName = DpiManager.getDpiName(this.inSetValue);
    this.registerDataChange();
    this.registerFontDataChange();
    LogUtil.info(`${this.TAG} this.initialSettingsDpi: ${this.initialSettingsDpi}`);
    this.pageRoot.aboutToAppear(new ScreenZoomPage());
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DISPLAY_SIZE_ENTRY);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    this.isBackPressed = false;
    this.pageRoot.aboutToDisappear();
    this.unRegisterDataChange();
    this.unRegisterFontDataChange();
  }

  onPageShow(): void {
    LogUtil.info(`${this.TAG} onPageShow`);
    let dpi = SettingsDataUtils.getSettingsData(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE,
      DpiManager.defaultDensityDpi.toString());
    this.inSetValue = DpiManager.getIndexByDpi(Number(dpi));
    this.dpiName = DpiManager.getDpiName(this.inSetValue);
    LogUtil.info(`${this.TAG} onPageShow :${DpiManager.defaultDensityDpi}-${dpi}-${this.inSetValue}`);
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${this.TAG} onPageHide`);
    this.updateConfig();
    this.pageRoot.onPageHide();
    this.largerFontDialogController?.close();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.EXIT_REPORT_DISPLAY_SIZE, this.getValue());
  }

  private zoomSliderChange(value: number): void {
    if (this.isBackPressed) {
      return;
    }
    if (this.inSetValue === value) {
      LogUtil.info(`${this.TAG} slider dpi value not change`);
      return;
    }
    this.inSetValue = value;
    this.dpiName = DpiManager.setDpiName(this.inSetValue);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.DISPLAY_SIZE_SLIDER_CHANGE,
      this.getValue());
    LogUtil.info(`${this.TAG} value = ` + value);
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }

  private onReduceClick(): void {
    LogUtil.info(`${this.TAG} onReduceClick`);
    if (this.inSetValue > 0) {
      this.inSetValue -= STEP_NUM;
    }
    this.dpiName = DpiManager.setDpiName(this.inSetValue);
  }

  private getValue(): string {
    let res: string = ResourceUtil.getStringSync(DpiManager.getDpiName(this.inSetValue));
    if (res === ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_small'))) {
      return 'small';
    } else if (res === ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_large'))) {
      return 'large';
    } else if (res === ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_extremely_large'))) {
      return 'utmost';
    } else if (res === ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_very_large'))) {
      return 'larger';
    } else {
      return 'default';
    }
  }

  private onIncreaseClick(): void {
    LogUtil.info(`${this.TAG} onIncreaseClick`);
    if (this.inSetValue < DpiManager.numLarger + DpiManager.numSmaller) {
      this.inSetValue += STEP_NUM;
    }
    LogUtil.info(`${this.TAG} inSetValue ` + this.inSetValue);
    this.dpiName = DpiManager.setDpiName(this.inSetValue);
  }
}
