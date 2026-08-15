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
import { CustomContentDialog } from '@kit.ArkUI';
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AccessibilityCardContainerComp } from './AccessibilityCardContainerComp';
import { OobeZoomGestureBuilderComponent } from './OobeZoomGestureBuilderComponent';
import { AccessibilityImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  SCREEN_MAGNIFICATION,
  SCREEN_MAGNIFICATION_TYPE_KEY,
  SCREEN_MAGNIFICATION_TRIGGER_METHOD,
  SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP,
  OOBE_ZOOM_GESTURE_REQUEST_FOCUS_EVENT,
  TRANSACTION_TIME
} from '../constant/Constants';

/* instrument ignore file */
const TAG: string = 'AssistedReadingOobeZoomGestureComponent : ';
const FULL_WIDTH: string = '100%';
const FULL_HEIGHT: string = '100%';
const CLICK_NUMBER: number = 888;
const ZOOM_AEAR_SWITCH_TYPE: string = '3';
const MAX_LINES_20: number = 20;

@Extend(Text)
function bottomTextStyles() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .textAlign(TextAlign.Center)
  .align(Alignment.Center)
  .maxLines(1)
  .width('100%')
  .height('100%')
}

@Extend(Button)
function bottomButtonStyles() {
  .align(Alignment.Center)
  .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  .backgroundColor($r('app.color.font_color_blue_entry_menu'))
  .padding({
    left: $r('sys.float.padding_level8'),
    right: $r('sys.float.padding_level8')
  })
  .height($r('app.float.height_40'))
}

@Component
export struct AssistedReadingOobeZoomGestureComponent {
  @Link isMainPage: boolean;
  @State isZoomGestureOpen: boolean = false;
  @Link zoomGestureName: ResourceStr;
  @StorageProp('oobeFootBtnWidth') footBtnWidth: number | Resource = $r('app.float.wh_value_188');
  private dialogController: CustomDialogController | undefined = undefined;
  private maxFontScale: number = i18n.System.getSystemLanguage() === 'bo' ? 1.3 : 1.45 // 判断系统语言是否为藏语来调整按钮最大缩放比例
  private dialogCloseEvent = () => {
    LogUtil.info(`${TAG} dialogCloseEvent`);
    if (this.isZoomGestureOpen) {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName('oobe_zoom_gesture_footer_disable_button');
    } else {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName('oobe_zoom_gesture_footer_enable_button');
    }
  }

  @Builder
  contentBuilder(): void {
    OobeZoomGestureBuilderComponent();
  }

  /**
   * 底部确定按钮组件
   */
  @Builder
  footerComponent(): void {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Button({ type: ButtonType.Normal }) {
          Text($r('app.string.dialog_enable'))
            .bottomTextStyles()
            .maxFontScale(this.maxFontScale)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .minFontSize($r('app.float.font_9'))
            .maxFontSize($r('app.float.font_16'))
        }
        .id('oobe_zoom_gesture_footer_enable_button')
        .bottomButtonStyles()
        .width(this.footBtnWidth)
        .visibility(this.isZoomGestureOpen ? Visibility.Hidden : Visibility.Visible)
        .onClick(() => {
          this.confirmButtonClick();
        });

        Button({ type: ButtonType.Normal }) {
          Text($r('app.string.ignore_repeat_click_notification_button_disable'))
            .bottomTextStyles()
            .maxFontScale(this.maxFontScale)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .minFontSize($r('app.float.font_9'))
            .maxFontSize($r('app.float.font_16'))
        }
        .id('oobe_zoom_gesture_footer_disable_button')
        .bottomButtonStyles()
        .width(this.footBtnWidth)
        .visibility(this.isZoomGestureOpen ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.disableButtonClick();
        });
      }
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
        mHeadName: $r('app.string.zoom_gesture'),
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

  private onBackBtnClick(): void {
    LogUtil.info(`${TAG} backSheetPage`);
    animateTo({ duration: TRANSACTION_TIME }, () => {
      this.isMainPage = true;
    })
  }

  private confirmButtonClick(): void {
    LogUtil.info(`${TAG} confirmButtonClick.`)
    this.dialogController?.open();
  }

  private disableButtonClick(): void {
    LogUtil.info(`${TAG} disableButtonClick.`)
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_OFF);
    this.isZoomGestureOpen = false;
    this.zoomGestureName = $r('app.string.assisted_reading_not_enable');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ZOOM_GESTURE_SWITCH, 'off');
    this.dialogCloseEvent();
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    OobeZoomGestureDialogComponent();
  }

  build() {
    HdsNavDestination() {
      Column() {
        this.pageContainerBuilder()
      }
      .size({
        width: FULL_WIDTH,
        height: FULL_HEIGHT
      })
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private initDialogController(): void {
    this.isZoomGestureOpen = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION,
      CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.dialogController = new CustomDialogController({
      builder: CustomContentDialog({
        contentAreaPadding: ({
          top: $r('sys.float.padding_level0'),
          bottom: $r('sys.float.padding_level0'),
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8')
        }),
        contentBuilder: () => {
          this.buildContent();
        },
        buttons: [
          {
            value: $r('app.string.dialog_stay_closed'),
            action: () => {
              this.closeDialog();
            }
          },
          {
            value: $r('app.string.dialog_confirm_to_open'),
            action: () => {
              LogUtil.info(`${TAG} dialog_confirm_to_open`);
              this.closeDialog();
              this.enabledZoomGesture();
            }
          }
        ],
      }),
      cancel: () => {
      },
      autoCancel: true,
      alignment: DialogAlignment.Center,
      maskColor: $r('sys.color.ohos_id_color_mask_thin')
    });
  }

  private enabledZoomGesture(): void {
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_ON);
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TYPE_KEY, ZOOM_AEAR_SWITCH_TYPE);
    // 设置页按单指三击引导，显式写入触发方式
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TRIGGER_METHOD,
      SCREEN_MAGNIFICATION_TRIGGER_SINGLE_FINGER_TRIPLE_TAP);
    this.isZoomGestureOpen = true;
    this.zoomGestureName = $r('app.string.accessibility_on');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ZOOM_GESTURE_SWITCH, 'on');
  }

  private closeDialog(): void {
    this.dialogController?.close();
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.initDialogController();
    EventBus.getInstance().on(OOBE_ZOOM_GESTURE_REQUEST_FOCUS_EVENT, this.dialogCloseEvent);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.closeDialog();
    EventBus.getInstance().detach(OOBE_ZOOM_GESTURE_REQUEST_FOCUS_EVENT, this.dialogCloseEvent);
  }
}

@Component
export struct OobeZoomGestureDialogComponent {
  controller?: CustomDialogController;

  build() {
    Column() {
      this.reConfirmDialogBuilder();
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  reConfirmDialogBuilder() {
    Column() {
      Row() {
        Text($r('app.string.on_zoom_gesture_dialog_title'))
          .id('on_zoom_gesture_dialog_title')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
          .constraintSize({
            minHeight: $r('app.float.wh_value_26'),
          })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .accessibilityGroup(true)
      .id('oobe_zoom_gesture_dialog_title')
      .justifyContent(FlexAlign.Center)
      .size({
        width: '100%',
      })
      .margin({
        top: $r('app.float.margin_15'),
        bottom: $r('app.float.margin_15'),
      })

      Scroll() {
        this.contentBuilder()
      }
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: '40%'
      })
      .padding({
        left: $r('app.float.margin_6'),
        right: $r('app.float.margin_6')
      })
    }
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .width('100%')
  }

  @Builder
  contentBuilder() {
    Column() {
      Row() {
        Text($r('app.string.zoom_gesture_risk_warning_dialog_summary',
          ResourceUtil.getLocalNumberFormat(CLICK_NUMBER)))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .wordBreak(WordBreak.BREAK_WORD)
          .textOverflow({ overflow: TextOverflow.None })
          .maxLines(20)
          .textAlign(TextAlign.Center)
          .constraintSize({
            minHeight: 21,
          })
          .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    AccessibilityUtils.requestFocusAccessibilityWithBundleName('oobe_zoom_gesture_dialog_title');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().emit(OOBE_ZOOM_GESTURE_REQUEST_FOCUS_EVENT);
  }
}