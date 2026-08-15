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
import Display from '@ohos.display';
import window from '@ohos.window';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  SettingModalState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  DefaultSettingPageModel,
  SettingPageModel,
  SettingSheetPageContext
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { CountDownTimer, IgnoreRepeatedStateModel } from '../utils/AccessibilityIgnoreRepeatedModel';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG,
  IGNORE_REPEATED_TIME_NAME_ARRAY,
  IGNORE_REPEATED_TIME_NUM_ARRAY,
  IGNORE_REPEATED_TIME_SELECT_MODEL_SHOW_EVENT,
  IGNORE_REPEATED_TIMER_DOWN_EVENT
} from '../constant/Constants';

@Styles
function normalStateIconStyles() {
  .backgroundColor(Color.Transparent)
  .borderRadius(0)
}

@Styles
function pressedStateIconStyles() {
  .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
    ? $r('sys.color.interactive_click') : null)
  .borderRadius($r('sys.float.ohos_id_corner_radius_notification'))
}

@Extend(Image)
function alterButtonImageStyle() {
  .width(32)
  .height(32)
  .hoverEffect(null)
  .visibility(Visibility.Visible)
  .draggable(false)
  .objectFit(ImageFit.Cover)
  .fillColor($r('sys.color.icon_primary'))
  .stateStyles({
    normal: normalStateIconStyles,
    pressed: pressedStateIconStyles,
  })
}

@Extend(Text)
function ignoreRepeatedButtonText() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Regular)
  .fontSize($r('sys.float.Title_L'))
  .fontColor($r('sys.color.font_primary'))
  .wordBreak(WordBreak.BREAK_WORD)
  .maxFontScale(2)
  .textOverflow({ overflow: TextOverflow.None })
  .textAlign(TextAlign.Start)
  .maxLines(10)
}

@Extend(SymbolGlyph)
function symbolStyle() {
  .draggable(false)
  .fontColor([$r('sys.color.icon_primary')])
  .fontSize($r('app.float.font_24'))
  .maxFontScale(2)
}

@Extend(Button)
function cardButtonStyles() {
  .borderRadius($r('sys.float.corner_radius_level4'))
  .width('100%')
  .height(118)
  .shadow(ShadowStyle.OUTER_DEFAULT_SM)
}

@Extend(Text)
function bottomTextStyles() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Regular)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_emphasize'))
  .maxFontScale(1.75)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .textAlign(TextAlign.Center)
  .maxLines(1)
}

@Extend(Button)
function bottomButtonStyles() {
  .align(Alignment.Center)
  .borderRadius($r('sys.float.corner_radius_level10'))
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  .width('100%')
  .constraintSize({ minHeight: $r('app.float.height_40') })
}

const TIME_END_DELAY: number = 0.5;
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');

const IGNORE_REPEATED_BUTTON_COLOR_MAP: Map<string, ResourceStr> = new Map([
  ['normal', $r('sys.color.background_primary')],
  ['green', $r('sys.color.multi_color_04')],
  ['red', $r('sys.color.warning')]
]);

const IGNORE_REPEATED_SUMMARY_MAP: Map<string, ResourceStr> = new Map([
  ['leftSummary', $r('app.string.ignore_repeated_left_click')],
  ['rightSummary', $r('app.string.ignore_repeated_right_click')],
  ['endSummary', $r('app.string.ignore_repeated_trial_end')]
]);

const IGNORE_REPEATED_TIPS_MAP: Map<string, ResourceStr> = new Map([
  ['leftResult', $r('app.string.ignore_repeated_left_click_result')],
  ['rightResult', $r('app.string.ignore_repeated_right_click_result')],
  ['endResult', $r('app.string.ignore_repeated_timed_end')],
  ['trialResult', $r('app.string.ignore_repeated_trial_end')],
  ['EndTipsResult', $r('app.plural.ignore_repeated_timed_end_tips')],
  ['failedResult', $r('app.plural.ignore_repeated_failed_result')]
]);

const IGNORE_REPEATED_RECOMMED_TIPS_MAP: Map<string, ResourceStr> = new Map([
  ['delayTips', $r('app.string.ignore_repeated_recommended_delay')],
  ['shortTips', $r('app.string.ignore_repeated_recommended_shorten')],
  ['closeTips', $r('app.string.ignore_repeated_recommended_close')]
]);

enum IgnoreRepeatedButtonText {
  WORD_F = 'F',
  WORD_J = 'J',
}

enum IgnoreRepeatedEndResult {
  DEFAULT = '0',
  BORDER = '1',
  FAILED = '2'
}

@Component
export struct IgnoreRepeatedExperimentModelComponent {
  tag: string = 'IgnoreRepeatedExperimentModelComponent: ';
  item?: object;
  pageParam?: PageParams;
  scroller: Scroller = new Scroller();
  private sheetPageCtx?: SettingSheetPageContext;
  private isDeleteCache: boolean = true;
  @State pathStack: NavPathStack = new NavPathStack();
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();
  @State trySummary: ResourceStr = '';
  @State tryTips: ResourceStr = '';
  @State tryTipsVisible: boolean = false;
  @State leftButtonColor: ResourceStr = '';
  @State leftButtonOpacity: number = 1;
  @State leftButtonEnable: boolean = true;
  @State isLeftButtonTextVisible: boolean = true;
  @State leftBorderVisible: boolean = false;
  @State rightButtonColor: ResourceStr = '';
  @State rightButtonOpacity: number = 1;
  @State isRightButtonTextVisible: boolean = true;
  @State rightBorderVisible: boolean = false;
  @State rightButtonEnable: boolean = false;
  @State suggestedTextVisible: boolean = false;
  @State suggestedControlVisible: boolean = false;
  @State suggestedLeftEnable: boolean = false;
  @State suggestedRightEnable: boolean = false;
  @State suggestedText: ResourceStr = '';
  @State suggestedNumberValue: string = IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache;
  @State suggestedLocalNumberValue: string =
    ResourceUtil.getAnyStrFormatStringSync($r('app.string.ignore_repeated_time_shortest'),
      String(ResourceUtil.getLocalNumberFormat((IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue()))));
  @State previousButtonVisible: boolean = true;
  @State tryAgainButtonVisible: boolean = false;
  @State doneButtonEnable: boolean = false;
  @State delayTime: number = IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue();
  @State cardBothSidesMargin: ResourceStr = '';
  @State cardMiddleSpace: ResourceStr = '';
  private leftCnt: number = 0;
  private rightCnt: number = 0;
  private leftResult: string = IgnoreRepeatedEndResult.DEFAULT;
  private rightResult: string = IgnoreRepeatedEndResult.DEFAULT;
  private leftTimer: CountDownTimer = new CountDownTimer(IgnoreRepeatedButtonText.WORD_F, this.delayTime);
  private rightTimer: CountDownTimer = new CountDownTimer(IgnoreRepeatedButtonText.WORD_J, this.delayTime);
  private ignoreRepeatedTimerCallback = (timerType: string) => {
    if (timerType === undefined) {
      LogUtil.error(`${this.tag} ignoreRepeatedTimerCallback timerType is undefined.`);
      return;
    }
    LogUtil.info(`${this.tag} ignoreRepeatedTimerCallback timerType: ${timerType}`);
    this.onButtonTimerChange(timerType);
  };
  private onFoldChangeCallBack = (status: number) => {
    this.handleFoldStateChange(status);
  };
  private windowStatusChangeCallback = (windowStatusType: window.WindowStatusType): void => {
    LogUtil.info(`${this.tag} windowStatusChange, window type is ${windowStatusType}`);
    this.initFoldSpace();
  };

  /**
   * 注册设置窗口悬浮窗模式监听事件
   */
  public registerFloatingStatusListener(): void {
    try {
      const stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      stage?.getMainWindow((err, data) => {
        if (err?.code || data === undefined) {
          LogUtil.error(`${this.tag} Failed to obtain the main window.`);
          return;
        }
        try {
          data?.on('windowStatusChange', this.windowStatusChangeCallback);
        } catch (listenerErr) {
          LogUtil.error(`${this.tag} register windowStatusChange failed: code: ${listenerErr?.code} ` +
            `message: ${listenerErr?.message}`);
        }
      })
    } catch (err) {
      LogUtil.error(`${this.tag} register window stage listener failed: code: ${err?.code} message: ${err?.message}`);
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
          LogUtil.error(`${this.tag} Failed to obtain the main window.`);
          return;
        }
        try {
          data?.off('windowStatusChange', this.windowStatusChangeCallback);
        } catch (listenerErr) {
          LogUtil.error(`${this.tag} unRegister windowStatusChange failed: code: ${listenerErr?.code} ` +
            `message: ${listenerErr?.message}`);
        }
      })
    } catch (err) {
      LogUtil.error(`${this.tag} unRegister window stage listener failed: code: ${err?.code} message: ${err?.message}`);
    }
  }

  /**
   * 倒计时结束回调函数
   * @param timerType 倒计时类型
   */
  private onButtonTimerChange(timerType: string) {
    if (timerType === IgnoreRepeatedButtonText.WORD_F) {
      this.onLeftButtonCountdown();
    } else if (timerType === IgnoreRepeatedButtonText.WORD_J) {
      this.onRightButtonCountdown();
    } else if (timerType === 'END') {
      this.onEndCountdown();
    } else {
      LogUtil.error(`${this.tag} onButtonTimerChange timerType invalid: ${timerType}`);
    }
  }

  private onLeftButtonCountdown() {
    LogUtil.info(`${this.tag} onLeftButtonCountdown`);
    this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_F, 'green');
    if (this.leftCnt > 1) {
      this.tryTips = ResourceUtil.getPluralStringValueSync(
        IGNORE_REPEATED_TIPS_MAP.get('EndTipsResult') as Resource, this.leftCnt - 1)
    } else {
      this.tryTips = IGNORE_REPEATED_TIPS_MAP.get('endResult') as ResourceStr;
    }
    this.isLeftButtonTextVisible = false;
    this.tryTipsVisible = true;
    this.leftBorderVisible = false;
  }

  private onRightButtonCountdown() {
    LogUtil.info(`${this.tag} onRightButtonCountdown`);
    this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_J, 'green');
    if (this.rightCnt > 1) {
      this.tryTips = ResourceUtil.getPluralStringValueSync(
        IGNORE_REPEATED_TIPS_MAP.get('EndTipsResult') as Resource, this.rightCnt - 1)
    } else {
      this.tryTips = IGNORE_REPEATED_TIPS_MAP.get('endResult') as ResourceStr;
    }
    this.isRightButtonTextVisible = false;
    this.tryTipsVisible = true;
    this.rightBorderVisible = false;
    new CountDownTimer('END', TIME_END_DELAY).startCountdown();
  }

  private onEndCountdown() {
    LogUtil.info(`${this.tag} onEndCountdown timerType END`);
    this.trySummary = IGNORE_REPEATED_SUMMARY_MAP.get('endSummary') as ResourceStr;
    this.tryTipsVisible = false;
    this.previousButtonVisible = false;
    this.tryAgainButtonVisible = true;
    this.doneButtonEnable = true;
    this.rightButtonEnable = false;
    // 根据试用结果显示不同的建议
    if (this.leftResult === IgnoreRepeatedEndResult.FAILED &&
      this.rightResult === IgnoreRepeatedEndResult.FAILED) {
      this.suggestedControlVisible = true;
      this.suggestedText = IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('delayTips') as ResourceStr;
      if (this.checkBoundaryState()) {
        this.suggestedTextVisible = true;
      }
      this.alterBoundaryEnable();
    } else if (this.leftResult === IgnoreRepeatedEndResult.DEFAULT &&
      this.rightResult === IgnoreRepeatedEndResult.DEFAULT) {
      this.suggestedTextVisible = true;
      this.suggestedControlVisible = false;
      this.suggestedText = IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('closeTips') as ResourceStr;
      this.tryAgainButtonVisible = false;
    } else if (this.leftResult !== IgnoreRepeatedEndResult.FAILED &&
      this.rightResult !== IgnoreRepeatedEndResult.FAILED) {
      this.suggestedControlVisible = true;
      this.suggestedText = IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('shortTips') as ResourceStr;
      if (this.checkBoundaryState()) {
        this.suggestedTextVisible = true;
      }
      this.alterBoundaryEnable();
    } else {
      this.suggestedTextVisible = false;
      this.suggestedControlVisible = true;
      this.alterBoundaryEnable();
    }
  }

  private changeColorAndOpacity(changeType: string, key: string) {
    if (changeType === IgnoreRepeatedButtonText.WORD_F) {
      if (IGNORE_REPEATED_BUTTON_COLOR_MAP.has(key)) {
        this.leftButtonColor = IGNORE_REPEATED_BUTTON_COLOR_MAP.get(key) as ResourceStr;
      }
      this.leftButtonOpacity = this.leftButtonEnable === false ? 0.8 : 1;
    } else if (changeType === IgnoreRepeatedButtonText.WORD_J) {
      if (IGNORE_REPEATED_BUTTON_COLOR_MAP.has(key)) {
        this.rightButtonColor = IGNORE_REPEATED_BUTTON_COLOR_MAP.get(key) as ResourceStr;
      }
      this.rightButtonOpacity = this.rightButtonEnable === false ? 0.8 : 1;
    } else {
      LogUtil.error(`${this.tag} changeColorAndOpacity changeType error: ${changeType}`);
    }
  }

  /**
   * 检查推荐tips的边界场景
   */
  private checkBoundaryState(): boolean {
    if (!this.checkArraysEmpty()) {
      return false;
    }
    let delayIndex: number =
      IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue));
    LogUtil.info(`${this.tag} checkBoundaryState delayIndex: ${
    delayIndex}, suggestedText: ${ResourceUtil.getStringSync(this.suggestedText)}`);
    if ((ResourceUtil.getStringSync(this.suggestedText) ===
    ResourceUtil.getStringSync(IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('delayTips')) && delayIndex === 4) ||
      (ResourceUtil.getStringSync(this.suggestedText) ===
      ResourceUtil.getStringSync(IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('shortTips')) && delayIndex === 0)) {
      return false;
    }
    return true;
  }

  /**
   * 调节按钮的边界场景显示问题
   */
  private alterBoundaryEnable(): void {
    if (!this.checkArraysEmpty()) {
      return;
    }
    let delayIndex: number = IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(
      IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue));
    LogUtil.info(`${this.tag} alterBoundaryEnable delayIndex: ${delayIndex}`);
    if (delayIndex === 4) {
      this.suggestedRightEnable = false;
    } else if (delayIndex === 0) {
      this.suggestedLeftEnable = false;
    }
  }

  build() {
    Column() {
      Row() {
        Scroll() {
          Column() {
            this.topTitleText();
            this.twoCardButton();
            this.recommendedTips()
          }
        }
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .edgeEffect(EdgeEffect.Spring)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .align(Alignment.Top)
      }
      .layoutWeight(1)

      Row() {
        if (FontScaleUtils.isExtraLargeFontMode()) {
          this.buttonHorizontalBuilder();
        } else {
          this.bottomButton();
        }
      }
      .constraintSize({
        minHeight: $r('app.float.height_40'),
      })
      .margin({
        top: $r('app.float.margin_16'),
        bottom: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
          $r('app.float.margin_value_28') : $r('app.float.margin_0'),
      })
      .justifyContent(FlexAlign.Start)
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  topTitleText(): void {
    Row() {
      Text(ResourceUtil.getPluralStringValueSync($r('app.plural.ignore_repeated_experiment_summary'),
        this.getTitleFormat()))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .maxFontScale(2)
    }.margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      top: $r('sys.float.padding_level8'),
      bottom: $r('app.float.margin_48'),
    })

    Row() {
      Text(this.trySummary)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_primary'))
        .maxFontScale(2)
    }
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level4'),
    })

    Row() {
      Text(this.tryTips)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .visibility(this.tryTipsVisible ? Visibility.Visible : Visibility.Hidden)
        .maxFontScale(2)
    }
    .constraintSize({
      minHeight: $r('app.float.length_21')
    })
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('app.float.padding_45'),
    })
  }

  @Builder
  recommendedTips(): void {
    Column() {
      Row() {
        Text(this.suggestedText)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .align(Alignment.Center)
          .maxFontScale(2)
          .wordBreak(WordBreak.HYPHENATION)
      }
      .constraintSize({
        minHeight: $r('app.float.length_21')
      })
      .margin({
        bottom: 24
      })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .visibility(this.suggestedTextVisible ? Visibility.Visible : Visibility.Hidden)

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_button_reduce'))
          .alterButtonImageStyle()
          .enabled(this.suggestedLeftEnable)
          .opacity(this.suggestedLeftEnable ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
          .margin({
            right: $r('sys.float.padding_level4'),
          })
          .onClick(() => {
            this.onReduceButtonClick();
          });

        Text(this.suggestedLocalNumberValue)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Title_M'))
          .fontColor($r('sys.color.brand'))
          .maxFontScale(2)
          .width('70%')
          .textAlign(TextAlign.Center)

        Image($r('app.media.ic_button_add'))
          .alterButtonImageStyle()
          .enabled(this.suggestedRightEnable)
          .opacity(this.suggestedRightEnable ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
          .margin({
            left: $r('sys.float.padding_level4'),
          })
          .onClick(() => {
            this.onAddButtonClick();
          });
      }
      .visibility(this.suggestedControlVisible ? Visibility.Visible : Visibility.Hidden)
      .constraintSize({
        minHeight: $r('app.float.height_32'),
      })
    }
    .margin({
      left: 65,
      right: 65,
    })
  }

  @Builder
  twoCardButton(): void {
    Row({ space: this.cardMiddleSpace }) {
      Row() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Stack({ alignContent: Alignment.Center }) {
            Text(IgnoreRepeatedButtonText.WORD_F)
              .ignoreRepeatedButtonText()
              .visibility(this.isLeftButtonTextVisible ? Visibility.Visible : Visibility.Hidden)

            SymbolGlyph($r('sys.symbol.checkmark'))
              .symbolStyle()
              .visibility(this.isLeftButtonTextVisible ? Visibility.Hidden : Visibility.Visible)
          }
        }
        .cardButtonStyles()
        .enabled(this.leftButtonEnable)
        .backgroundColor(this.leftButtonColor)
        .opacity(this.leftButtonOpacity)
        .onClick(() => {
          this.onLeftCardButtonClick();
        })
      }
      .width(102)
      .height(130)
      .layoutWeight(1)
      .border(this.leftBorderVisible ? { width: 3, color: $r('sys.color.multi_color_04'), radius: 6 } :
        { width: 3, color: Color.Transparent })
      .padding({
        left: 6,
        right: 6,
        top: 6,
        bottom: 6,
      })

      Row() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Stack({ alignContent: Alignment.Center }) {
            Text(IgnoreRepeatedButtonText.WORD_J)
              .ignoreRepeatedButtonText()
              .visibility(this.isRightButtonTextVisible ? Visibility.Visible : Visibility.Hidden)

            SymbolGlyph($r('sys.symbol.checkmark'))
              .symbolStyle()
              .visibility(this.isRightButtonTextVisible ? Visibility.Hidden : Visibility.Visible)
          }
        }
        .cardButtonStyles()
        .enabled(this.rightButtonEnable)
        .backgroundColor(this.rightButtonColor)
        .opacity(this.rightButtonOpacity)
        .onClick(() => {
          this.onRightCardButtonClick();
        })
      }
      .width(102)
      .layoutWeight(1)
      .border(this.rightBorderVisible ? { width: 3, color: $r('sys.color.multi_color_04'), radius: 6 } :
        { width: 3, color: Color.Transparent })
      .padding({
        left: 6,
        right: 6,
        top: 6,
        bottom: 6,
      })
    }
    .direction(Direction.Ltr)
    .margin({
      left: this.cardBothSidesMargin,
      right: this.cardBothSidesMargin,
      bottom: 74,
    })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buttonHorizontalBuilder() {
    Column() {
      Stack() {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.ignore_repeated_previous_step'))
            .bottomTextStyles()
        }
        .bottomButtonStyles()
        .visibility(this.previousButtonVisible ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.closePage();
          EventBus.getInstance().emit(IGNORE_REPEATED_TIME_SELECT_MODEL_SHOW_EVENT, true);
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.ignore_repeated_trial_again'))
            .bottomTextStyles()
        }
        .bottomButtonStyles()
        .visibility(this.tryAgainButtonVisible ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.initIgnoreState();
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.ignore_repeat_click_notification_button_disable'))
            .bottomTextStyles()
        }
        .bottomButtonStyles()
        .visibility((!this.previousButtonVisible && !this.tryAgainButtonVisible) ? Visibility.Visible :
          Visibility.Hidden)
        .onClick(() => {
          IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = false;
          IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
          IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
          AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', false);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.IGNORE_REPEAT_TOUCHES_SWITCH, 'off');
          this.closePage();
        })
      }
      .margin({ bottom: $r('app.float.margin_12') })
      .width('100%');

      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Text($r('app.string.done'))
          .bottomTextStyles()
      }
      .bottomButtonStyles()
      .enabled(this.doneButtonEnable)
      .opacity(this.doneButtonEnable === false ? $r('app.float.opacity_0_4') : 1)
      .onClick(() => {
        LogUtil.info(`${this.tag} done button click.`);
        this.closePage();
        if (IgnoreRepeatedStateModel.getInstance().saveRepeatClickIntervalValue()) {
          this.isDeleteCache = false;
        }
      })
      .width('100%');
    }
    .width('100%')
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .margin({
      bottom: $r('app.float.margin_16')
    })
  }

  @Builder
  bottomButton(): void {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.ignore_repeated_previous_step'))
            .bottomTextStyles()
        }
        .bottomButtonStyles()
        .visibility(this.previousButtonVisible ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.closePage();
          EventBus.getInstance().emit(IGNORE_REPEATED_TIME_SELECT_MODEL_SHOW_EVENT, true);
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.ignore_repeated_trial_again'))
            .bottomTextStyles()
        }
        .bottomButtonStyles()
        .visibility(this.tryAgainButtonVisible ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.initIgnoreState();
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.ignore_repeat_click_notification_button_disable'))
            .bottomTextStyles()
        }
        .bottomButtonStyles()
        .visibility((!this.previousButtonVisible && !this.tryAgainButtonVisible) ? Visibility.Visible :
          Visibility.Hidden)
        .onClick(() => {
          IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = false;
          IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
          IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
          AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', false);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.IGNORE_REPEAT_TOUCHES_SWITCH, 'off');
          this.closePage();
        })
      }
      .constraintSize({ minHeight: $r('app.float.height_40') })
      .layoutWeight(1)

      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Text($r('app.string.done'))
          .bottomTextStyles()
      }
      .bottomButtonStyles()
      .layoutWeight(1)
      .enabled(this.doneButtonEnable)
      .opacity(this.doneButtonEnable === false ? $r('app.float.opacity_0_4') : 1)
      .onClick(() => {
        LogUtil.info(`${this.tag} done button click.`);
        this.closePage();
        if (IgnoreRepeatedStateModel.getInstance().saveRepeatClickIntervalValue()) {
          this.isDeleteCache = false;
        }
      })
    }
    .flexShrink(0)
    .margin({
      bottom: $r('app.float.margin_16')
    })
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .width('100%');
  }

  private onLeftCardButtonClick(): void {
    LogUtil.info(`${this.tag} onLeftCardButtonClick, isLeftButtonTextVisible: ${
    this.isLeftButtonTextVisible}, this.leftCnt: ${this.leftCnt}`);
    this.leftCnt += 1;
    if (this.leftCnt === 1) {
      this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_F, 'green');
      this.trySummary = IGNORE_REPEATED_SUMMARY_MAP.get('rightSummary') as ResourceStr;
      this.tryTips = IGNORE_REPEATED_TIPS_MAP.get('leftResult') as ResourceStr;
      this.tryTipsVisible = true;
      this.rightButtonEnable = true;
      this.leftTimer.startCountdown();
    } else {
      if (this.leftTimer.remainingTime > 0) {
        // 定时未结束，继续点击F键，显示绿框
        this.leftBorderVisible = true;
        this.tryTipsVisible = false;
        this.leftResult = IgnoreRepeatedEndResult.BORDER;
      } else {
        // 定时结束，继续点击F键，显示红色
        this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_F, 'red');
        this.tryTips = ResourceUtil.getPluralStringValueSync(
          IGNORE_REPEATED_TIPS_MAP.get('failedResult') as Resource, this.delayTime);
        this.isLeftButtonTextVisible = true;
        this.leftResult = IgnoreRepeatedEndResult.FAILED;
      }
    }
  }

  private onRightCardButtonClick(): void {
    LogUtil.info(`${this.tag} onRightCardButtonClick, isRightButtonTextVisible: ${
    this.isRightButtonTextVisible}, rightCnt: ${this.rightCnt}`);
    this.rightCnt += 1;
    this.leftButtonEnable = false;
    if (this.leftTimer.remainingTime > 0) {
      this.leftTimer.stopTimer();
      this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_F, 'green');
      this.isLeftButtonTextVisible = false;
      this.leftBorderVisible = false;
    }
    if (this.rightCnt === 1) {
      this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_J, 'green');
      this.tryTips = IGNORE_REPEATED_TIPS_MAP.get('rightResult') as ResourceStr;
      this.tryTipsVisible = true;
      this.rightTimer.startCountdown();
    } else {
      if (this.rightTimer.remainingTime > 0) {
        this.rightBorderVisible = true;
        this.tryTipsVisible = false;
        this.rightResult = IgnoreRepeatedEndResult.BORDER;
      } else {
        // 定时结束，继续点击J键的情况
        this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_J, 'red');
        this.tryTips = ResourceUtil.getPluralStringValueSync(
          IGNORE_REPEATED_TIPS_MAP.get('failedResult') as Resource, this.delayTime);
        this.isRightButtonTextVisible = true;
        this.rightResult = IgnoreRepeatedEndResult.FAILED;
      }
    }
  }

  private onReduceButtonClick(): void {
    LogUtil.debug(`${this.tag} onReduceButtonClick: ${IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(
      IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue))}`);
    if (!this.checkArraysEmpty()) {
      return;
    }
    let delayIndex: number =
      IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue));
    if (delayIndex > 0) {
      delayIndex -= 1;
      this.suggestedTextVisible = true;
      this.suggestedNumberValue = IGNORE_REPEATED_TIME_NAME_ARRAY[delayIndex];
      this.suggestedLocalNumberValue =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.ignore_repeated_time_shortest'),
          String(ResourceUtil.getLocalNumberFormat((IGNORE_REPEATED_TIME_NUM_ARRAY[delayIndex]))));
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = this.suggestedNumberValue;
      if (!this.suggestedRightEnable) {
        this.suggestedRightEnable = true;
      }
      if (delayIndex === 0) {
        this.suggestedLeftEnable = false;
        // 当提示文本为缩短，当前时延为最小的时候，隐藏提示文本
        if (ResourceUtil.getStringSync(this.suggestedText) ===
        ResourceUtil.getStringSync(IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('shortTips'))) {
          this.suggestedTextVisible = false;
        }
      }
    }
  }

  private onAddButtonClick(): void {
    LogUtil.info(`${this.tag} onAddButtonClick: ${IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(
      IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue))}`);
    if (!this.checkArraysEmpty()) {
      return;
    }
    let addDelayIndex: number =
      IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue));
    if (addDelayIndex < IGNORE_REPEATED_TIME_NUM_ARRAY.length - 1) {
      addDelayIndex += 1;
      this.suggestedTextVisible = true;
      this.suggestedNumberValue = IGNORE_REPEATED_TIME_NAME_ARRAY[addDelayIndex];
      this.suggestedLocalNumberValue =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.ignore_repeated_time_shortest'),
          String(ResourceUtil.getLocalNumberFormat((IGNORE_REPEATED_TIME_NUM_ARRAY[addDelayIndex]))));
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = this.suggestedNumberValue;
      if (!this.suggestedLeftEnable) {
        this.suggestedLeftEnable = true;
      }
      if (addDelayIndex === IGNORE_REPEATED_TIME_NAME_ARRAY.length - 1) {
        this.suggestedRightEnable = false;
        // 当提示文本为延长，当前时延为最大的时候，隐藏提示文本
        if (ResourceUtil.getStringSync(this.suggestedText) ===
        ResourceUtil.getStringSync(IGNORE_REPEATED_RECOMMED_TIPS_MAP.get('delayTips'))) {
          this.suggestedTextVisible = false;
        }
      }
    }
  }

  private checkArraysEmpty(): boolean {
    if (CheckEmptyUtils.isEmpty(this.suggestedNumberValue) || IGNORE_REPEATED_TIME_NUM_ARRAY.indexOf(
      IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue(this.suggestedNumberValue)) < 0) {
      LogUtil.error(`${this.tag} checkArraysEmpty invalid value`);
      return false;
    }
    return true;
  }

  private handleFoldStateChange(status: number): void {
    LogUtil.info(`${this.tag} on fold status changed: ${status}`);
    if (status === Display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.cardBothSidesMargin = $r('app.float.width_40');
      this.cardMiddleSpace = $r('app.float.length_68');
    } else {
      this.initFoldSpace();
    }
  }

  private closePage(): void {
    let item: SettingItemModel = this.sheetPageCtx?.itemComp as SettingItemModel;
    item?.onItemEvent?.(new Map([[
      SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState
    ]]));
  }

  private initIgnoreState(): void {
    this.delayTime = IgnoreRepeatedStateModel.getInstance().ConvertIntervalValue();
    this.trySummary = IGNORE_REPEATED_SUMMARY_MAP.get('leftSummary') as ResourceStr;
    this.tryTips = IGNORE_REPEATED_TIPS_MAP.get('leftResult') as ResourceStr;
    this.tryTipsVisible = false;
    this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_F, 'normal');
    this.leftButtonEnable = true;
    this.isLeftButtonTextVisible = true;
    this.leftBorderVisible = false;
    this.changeColorAndOpacity(IgnoreRepeatedButtonText.WORD_J, 'normal');
    this.isRightButtonTextVisible = true;
    this.rightBorderVisible = false;
    this.rightButtonEnable = false;
    this.leftResult = IgnoreRepeatedEndResult.DEFAULT;
    this.rightResult = IgnoreRepeatedEndResult.DEFAULT;
    this.suggestedTextVisible = false;
    this.suggestedControlVisible = false;
    this.previousButtonVisible = true;
    this.tryAgainButtonVisible = false;
    this.doneButtonEnable = false;
    this.leftCnt = 0;
    this.rightCnt = 0;
    this.leftTimer = new CountDownTimer(IgnoreRepeatedButtonText.WORD_F, this.delayTime);
    this.rightTimer = new CountDownTimer(IgnoreRepeatedButtonText.WORD_J, this.delayTime);
    this.suggestedLeftEnable = true;
    this.suggestedRightEnable = true;
  }

  private initFoldSpace(): void {
    if (IgnoreRepeatedStateModel.getInstance().isWideScreenMode()) {
      this.cardBothSidesMargin = $r('app.float.width_40');
      this.cardMiddleSpace = $r('app.float.length_68');
    } else {
      this.cardBothSidesMargin = $r('app.float.length_70');
      this.cardMiddleSpace = $r('app.float.max_length_128');
    }
  }

  private getTitleFormat(): number {
    let titleFormat: string = ResourceUtil.getLocalNumberFormat(this.delayTime);
    return this.isNumber(titleFormat) ? Number(titleFormat) : this.delayTime;
  }

  /**
   * 判断是否为number类型
   *
   * @param val 数值
   */
  private isNumber(val: string): boolean {
    return val === '' ? false : !Number.isNaN(Number(val));
  }

  async aboutToAppear(): Promise<void> {
    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
    }
    let item = this.sheetPageCtx.itemComp as SettingItemModel;
    this.initFoldSpace();
    this.initIgnoreState();
    IgnoreRepeatedStateModel.getInstance().cacheIgnoreClickState();
    LogUtil.info(`${this.tag} aboutToAppear repeatClickIntervalValueCache: ${IgnoreRepeatedStateModel.getInstance()
      .repeatClickIntervalValueCache}, ignoreRepeatClick: ${IgnoreRepeatedStateModel.getInstance()
      .ignoreRepeatClick}, ignoreRepeatClickOriginal: ${IgnoreRepeatedStateModel.getInstance()
      .ignoreRepeatClickOriginal}`);
    EventBus.getInstance().on(IGNORE_REPEATED_TIMER_DOWN_EVENT, this.ignoreRepeatedTimerCallback);
    if (DeviceUtil.isFoldable()) {
      DisplayUtils.registerFoldStatusChange(this.onFoldChangeCallBack);
    }
    this.registerFloatingStatusListener();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach(IGNORE_REPEATED_TIMER_DOWN_EVENT, this.ignoreRepeatedTimerCallback);
    let isTrialModelClosed: boolean = SettingsDataUtils.getSettingsData(
      IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (this.isDeleteCache && !isTrialModelClosed) {
      IgnoreRepeatedStateModel.getInstance().recoveryIgnoreClickState('OriginalClear');
    }
    if (isTrialModelClosed) {
      SettingsDataUtils.setSettingsData(IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG, CLICK_SWITCH_OFF);
    }
    IgnoreRepeatedStateModel.getInstance().recoveryIgnoreClickData();
    if (DeviceUtil.isFoldable()) {
      DisplayUtils.unRegisterFoldStatusChange(this.onFoldChangeCallBack);
    }
    this.unRegisterFloatingStatusListener();
  }
}