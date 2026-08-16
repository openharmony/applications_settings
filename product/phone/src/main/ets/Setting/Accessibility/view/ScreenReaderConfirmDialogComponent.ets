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
import window from '@ohos.window';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { AccessibilityImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';
import { SECURITY_NOTIFICATION_TIMER_EVENT } from '../constant/Constants';
import { AccessibilityCountDownMessageController } from '../controller/AccessibilityCountDownMessageController';
import { IgnoreRepeatedStateModel } from '../utils/AccessibilityIgnoreRepeatedModel';

const TAG: string = 'ScreenReaderConfirmDialogComponent: ';
const SHORTCUT_TIMEOUT: number = 3;
const ANNOUNCE_TEXT_TIME: number = 2000;
const SCROLL_MAX_HEIGHT: string = '24%';

@Extend(Text)
function verticalButtonText() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_emphasize'))
  .wordBreak(WordBreak.BREAK_WORD)
  .maxFontScale(2)
  .maxLines(10)
  .textOverflow({ overflow: TextOverflow.None })
  .textAlign(TextAlign.Center)
  .ellipsisMode(EllipsisMode.END)
}

@Extend(Button)
function normalButtonStyles() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .layoutWeight(1)
  .fontColor($r('sys.color.font_emphasize'))
  .constraintSize({ minHeight: $r('app.float.height_40') })
  .backgroundColor(Color.Transparent)
  .borderRadius($r('sys.float.corner_radius_level10'))
  .maxFontScale(2)
}

@CustomDialog
export struct ScreenReaderConfirmDialogComponent {
  controller?: CustomDialogController;
  private handleConfirmClick?: () => void;
  private handleCancelClick?: () => void;
  private isClearItemState: boolean = true;
  private timeOutId: number = -1;
  private delayTimeOutId: number = -1;
  private announceTimeLeft: ResourceStr = '';
  @State updateTitle: ResourceStr = '';
  @State isButtonEnabled: boolean = false;
  @State countDownController: AccessibilityCountDownMessageController =
    new AccessibilityCountDownMessageController($r('app.plural.dialog_ok_countdown'),
      $r('app.string.button_title_ok'), $r('app.plural.dialog_countdown_time'), 10000);
  private paddingValue: ResourceStr | number = $r('sys.float.padding_level8');
  @State contentLayoutWeight: number = 0;
  @State isGlobalScroll: boolean = false;
  private securityNotificationTimerCallback =
    (itemInfo: ResourceStr | undefined, timeLeft: ResourceStr | undefined) => {
      if (!itemInfo || !timeLeft) {
        LogUtil.error(`${TAG} itemInfo or timeLeft is undefined.`);
        return;
      }
      this.updateTitle = itemInfo;
      this.announceTimeLeft = timeLeft;
      this.onButtonEnableChange();
    };
  private windowStatusChangeCallback = (windowStatusType: window.WindowStatusType): void => {
    LogUtil.info(`${TAG} windowStatusChange, window type is ${windowStatusType}`);
    this.initLayoutData();
  };
  private processFocusCallback: (isFocus: boolean) => void =
    (isFocus: boolean): void => {
      LogUtil.info(`${TAG} processFocusCallback in: ${isFocus}`);
      this.clearTimeout();
      if (isFocus) {
        let buttonText: string = ResourceUtil.getCapitalStringSync($r('app.string.button_title_ok'));
        if (buttonText === this.updateTitle) {
          return;
        }
        this.announceButtonText(buttonText, 0);
      }
    };

  private async announceButtonText(announceText: string, timesCnt: number): Promise<void> {
    timesCnt += 1;
    if (announceText === this.updateTitle) {
      LogUtil.debug(`${TAG} requestFocusAccessibilityWithBundleName: ${this.updateTitle}`);
      AccessibilityUtils.requestFocusAccessibilityWithBundleName('confirm_down_btn');
      return;
    }
    if (timesCnt === 1) {
      this.delayTimeOutId = setTimeout(() => {
        LogUtil.debug(`${TAG} delayTimeOutId announceButtonText: ${this.announceTimeLeft}`);
        this.startAnnounceTimeout(announceText, timesCnt);
      }, ANNOUNCE_TEXT_TIME);
      return;
    }
    this.startAnnounceTimeout(announceText, timesCnt);
  }

  private startAnnounceTimeout(announceText: string, timesCnt: number): void {
    this.timeOutId = setTimeout(() => {
      LogUtil.debug(`${TAG} announceButtonText: ${this.announceTimeLeft}`);
      announceText !== this.updateTitle ? AccessibilityUtils.announceTextNoInterrupt(this.announceTimeLeft) :
      AccessibilityUtils.announceText(this.announceTimeLeft);
      this.announceButtonText(announceText, timesCnt);
    }, ANNOUNCE_TEXT_TIME);
  }

  onButtonEnableChange() {
    if (this.updateTitle === ResourceUtil.getCapitalStringSync($r('app.string.button_title_ok'))) {
      LogUtil.info(`${TAG} isButtonEnabled true.`);
      this.isButtonEnabled = true;
    }
  }

  build() {
    Column() {
      this.reConfirmDialogBuilder();
    }
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2')
    })
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .height('auto')
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
  }

  @Builder
  reConfirmDialogBuilder() {
    if (this.isGlobalScroll) {
      Scroll() {
        Column() {
          this.titleBuilder()
          this.contentBuilder()
          if (FontScaleUtils.isExtraLargeFontMode()) {
            this.buttonHorizontalBuilder()
          } else {
            this.buttonBuilder()
          }
        }
      }
      .padding({
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6'),
      })
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
    } else {
      Column() {
        this.titleBuilder()
        Scroll() {
          this.contentBuilder()
        }
        .scrollable(ScrollDirection.Vertical)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .width('100%')
        .height('auto')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .constraintSize({
          maxHeight: SCROLL_MAX_HEIGHT
        })
        .padding({
          left: this.paddingValue,
          right: this.paddingValue,
        })

        if (FontScaleUtils.isExtraLargeFontMode()) {
          this.buttonHorizontalBuilder()
        } else {
          this.buttonBuilder()
        }
      }
    }
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.screenreader_is_sure_add'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_S'))
        .maxFontScale(2)
        .wordBreak(WordBreak.BREAK_WORD)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .constraintSize({
          minHeight: $r('app.float.length_27'),
        })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: 24,
      right: 24
    })
  }

  @Builder
  contentBuilder() {
    Column() {
      Row() {
        Text($r('app.string.screenreader_is_sure_add_summary', ResourceUtil.getLocalNumberFormat(
          SHORTCUT_TIMEOUT)))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .wordBreak(WordBreak.HYPHENATION)
          .textOverflow({ overflow: TextOverflow.None })
          .maxLines(20)
          .textAlign(TextAlign.Center)
          .constraintSize({
            minHeight: 21,
          })
      }
    }
    .padding({
      left: this.isGlobalScroll ? $r('app.float.margin_6') : $r('app.float.margin_0'),
      right: this.isGlobalScroll ? $r('app.float.margin_6') : $r('app.float.margin_0'),
    })
    .onAreaChange((_) => {
      this.initLayoutData();
    })
    .id('dialogContent')
    .layoutWeight(this.contentLayoutWeight)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buttonBuilder() {
    Row() {
      Button($r('app.string.dialog_cancel'))
        .normalButtonStyles()
        .onClick(() => {
          LogUtil.info(`${TAG} onClick cancel`);
          if (this.handleCancelClick) {
            this.isClearItemState = false;
            this.handleCancelClick();
          }
          this.controller?.close();
        })

      Divider()
        .vertical(true)
        .height(24)
        .strokeWidth(px2vp(2))
        .lineCap(LineCapStyle.Round)
        .color($r('sys.color.comp_divider'))
        .margin({ left: 8, right: 8 })

      Button(this.updateTitle)
        .normalButtonStyles()
        .id('confirm_down_btn')
        .opacity(this.isButtonEnabled ? 1 : 0.4)
        .enabled(this.isButtonEnabled)
        .onClick(() => {
          LogUtil.info(`${TAG} onClick open`);
          if (this.handleConfirmClick) {
            this.isClearItemState = false;
            this.handleConfirmClick();
          }
          this.controller?.close();
        })
        .onAccessibilityFocus(this.processFocusCallback)
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .margin({
      top: $r('sys.float.padding_level4'),
    })
    .padding({
      left: this.isGlobalScroll ? $r('app.float.padding_6') : $r('sys.float.padding_level6'),
      right: this.isGlobalScroll ? $r('app.float.padding_6') : $r('sys.float.padding_level6'),
      bottom: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  buttonHorizontalBuilder() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text(this.updateTitle)
          .verticalButtonText()
      }
      .margin({
        top: $r('app.float.margin_4'),
        bottom: $r('app.float.margin_4'),
      })
      .id('confirm_down_btn')
      .maxFontScale(2)
      .constraintSize({ minHeight: 40 })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor(Color.Transparent)
      .opacity(this.isButtonEnabled ? 1 : 0.4)
      .enabled(this.isButtonEnabled)
      .width('100%')
      .onAccessibilityFocus(this.processFocusCallback)
      .onClick(() => {
        LogUtil.info(`${TAG} onClick open`);
        if (this.handleConfirmClick) {
          this.isClearItemState = false;
          this.handleConfirmClick();
        }
        this.controller?.close();
      })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      top: $r('sys.float.padding_level4'),
      left: this.isGlobalScroll ? $r('app.float.padding_6') : $r('sys.float.padding_level6'),
      right: this.isGlobalScroll ? $r('app.float.padding_6') : $r('sys.float.padding_level6'),
    })
    .width('100%')

    Row() {
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.dialog_cancel'))
          .verticalButtonText()
      }
      .width('100%')
      .margin({
        bottom: $r('app.float.margin_4'),
      })
      .maxFontScale(2)
      .constraintSize({ minHeight: 40 })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        LogUtil.info(`${TAG} onClick cancel`);
        if (this.handleCancelClick) {
          this.isClearItemState = false;
          this.handleCancelClick();
          HiSysEventUtil.abilityReportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.CLICK_SELECT_FUNCTION, '', 'RefuseOpen');
        }
        this.controller?.close();
      })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding({
      bottom: $r('sys.float.padding_level8'),
      left: this.isGlobalScroll ? $r('app.float.padding_6') : $r('sys.float.padding_level6'),
      right: this.isGlobalScroll ? $r('app.float.padding_6') : $r('sys.float.padding_level6'),
    })
    .width('100%')
  }

  private clearTimeout(): void {
    if (this.delayTimeOutId !== -1) {
      LogUtil.debug(`${TAG} clearTimeout delayTimeOutId`);
      clearTimeout(this.delayTimeOutId);
      this.delayTimeOutId = -1;
    }
    if (this.timeOutId !== -1) {
      LogUtil.debug(`${TAG} clearTimeout timeOutId`);
      clearTimeout(this.timeOutId);
      this.timeOutId = -1;
    }
  }

  private initGlobalScrolling(): void {
    this.isGlobalScroll = !AccessibilityImageSizeAdjust.checkIsDevicesExpanded() &&
    IgnoreRepeatedStateModel.getInstance().checkWindowStatusType(window.WindowStatusType.SPLIT_SCREEN) ? true : false;
  }

  private initLayoutData(): void {
    this.initGlobalScrolling();
    this.contentLayoutWeight = !FontScaleUtils.isExtraLargeFontMode() || this.isGlobalScroll ? 0 : 1;
  }

  /**
   * 注册设置窗口悬浮窗模式监听事件
   */
  public registerFloatingStatusListener(): void {
    try {
      const stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      stage?.getMainWindow((err, data) => {
        if (err?.code || data === undefined) {
          LogUtil.error(`${TAG} Failed to obtain the main window.`);
          return;
        }
        data?.on('windowStatusChange', this.windowStatusChangeCallback);
      })
    } catch (err) {
      LogUtil.error(`${TAG} register window stage listener failed: code: ${err?.code} message: ${err?.message}`);
    }
  }

  /**
   * 取消注册设置窗口悬浮窗模式监听事件
   */
  public unRegisterFloatingStatusListener(): void {
    try {
      const stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      stage?.getMainWindow((err, data) => {
        if (err?.code || data === undefined) {
          LogUtil.error(`${TAG} Failed to obtain the main window.`);
          return;
        }
        data?.off('windowStatusChange', this.windowStatusChangeCallback);
      })
    } catch (err) {
      LogUtil.error(`${TAG} unRegister window stage listener failed: code: ${err?.code} message: ${err?.message}`);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.initLayoutData();
    this.countDownController.aboutToAppear();
    this.updateTitle = this.countDownController.title;
    EventBus.getInstance().on(SECURITY_NOTIFICATION_TIMER_EVENT, this.securityNotificationTimerCallback);
    this.registerFloatingStatusListener();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(SECURITY_NOTIFICATION_TIMER_EVENT, this.securityNotificationTimerCallback);
    this.unRegisterFloatingStatusListener();
    this.countDownController.stopTimer();
    if (this.isClearItemState && this.handleCancelClick) {
      LogUtil.info(`${TAG} clear item state.`);
      this.handleCancelClick();
    }
    this.controller?.close();
    this.clearTimeout();
  }
}