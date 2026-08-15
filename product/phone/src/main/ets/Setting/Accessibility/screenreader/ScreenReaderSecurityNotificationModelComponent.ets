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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import {
  SettingModalState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  DefaultSettingPageModel,
  SettingPageModel,
  SettingSheetPageContext
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { CountDownMessageController } from '../controller/CountDownMessageController';
import { SCREEN_READER_SWITCH, SECURITY_NOTIFICATION_TIMER_EVENT } from '../constant/Constants';

@Component
export struct ScreenReaderSecurityNotificationModelComponent {
  tag: string = 'ScreenReaderSecurityNotificationModelComponent: ';
  item?: object;
  pageParam?: PageParams;
  scroller: Scroller = new Scroller();
  private isXmarkClick?: boolean = true;
  @State isSelected: boolean = true;
  @State updateTitle: ResourceStr = '';
  @State isButtonEnabled: boolean = false;
  @State controller: CountDownMessageController = new CountDownMessageController();
  private securityNotificationTimerCallback = (itemInfo: ResourceStr | undefined) => {
    if (!itemInfo) {
      LogUtil.error(`${this.tag} itemInfo is undefined.`);
      return;
    }
    this.updateTitle = itemInfo;
    this.onButtonEnableChange();
  };
  public static screenReaderServiceId: string = '';
  private sheetPageCtx?: SettingSheetPageContext;
  @State pathStack: NavPathStack = new NavPathStack();
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();

  onButtonEnableChange() {
    this.isSelected = true;
    if (this.updateTitle === ResourceUtil.getCapitalStringSync($r('app.string.accessibility_enable'))) {
      if (this.isSelected) {
        LogUtil.info(`${this.tag} isButtonEnabled true.`);
        this.isButtonEnabled = true;
      } else {
        LogUtil.info(`${this.tag} isButtonEnabled false.`);
        this.isButtonEnabled = false;
      }
    }
  }

  @Builder
  contentParagraph(): void {
    Row() {
      Text($r('app.string.screenreader_risk_content_one'))
        .id(`text_accessibility_notify_content`)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .textOverflow({
          overflow: TextOverflow.None
        })
        .maxLines(20)
        .constraintSize({
          minHeight: $r('app.float.height_38'),
        })
        .wordBreak(WordBreak.HYPHENATION)
        .fallbackLineSpacing(true)
    }
    .width('100%')

    Row() {
      Text($r('app.string.screenreader_risk_content_two'))
        .id(`text_accessibility_risk_detail`)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .textOverflow({
          overflow: TextOverflow.None
        })
        .maxLines(20)
        .textAlign(TextAlign.Start)
        .constraintSize({
          minHeight: $r('app.float.length_21'),
        })
        .wordBreak(WordBreak.HYPHENATION)
        .fallbackLineSpacing(true)
    }
    .width('100%')
    .margin({
      bottom: $r('app.float.margin_8'),
      top: $r('app.float.margin_16')
    })

    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
      Text('•')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .alignSelf(ItemAlign.Start)
        .fallbackLineSpacing(true)

      Blank().width($r('sys.float.padding_level4'))

      Text(`${ResourceUtil.getStringSync($r('app.string.screenreader_risk_content_three'))}`)
        .id(`text_accessibility_risk_content1`)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .textOverflow({
          overflow: TextOverflow.None
        })
        .maxLines(20)
        .wordBreak(WordBreak.HYPHENATION)
        .fallbackLineSpacing(true)
    }
    .accessibilityGroup(true)
    .width('100%')
  }

  @Builder
  checkboxItem(): void {
    Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Checkbox()
        .width(20)
        .height(20)
        .select(this.isSelected)
        .onChange((value: boolean) => {
          this.isSelected = value;
          this.controller.onCheckboxChange(value);
          LogUtil.info(`${this.tag} CheckboxMenuComponent`);
        })
        .margin({
          top: $r('app.float.margin_14'),
          bottom: $r('app.float.margin_14'),
          left: $r('app.float.wh_value_0'),
          right: $r('app.float.wh_value_12'),
        });

      Text($r('app.string.accessibility_user_approval'))
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .maxLines(10)
        .wordBreak(WordBreak.BREAK_WORD)
        .constraintSize({
          minHeight: $r('app.float.wh_value_24'),
        })
        .margin({
          top: $r('app.float.wh_value_12'),
          bottom: $r('app.float.wh_value_12'),
        })
        .textOverflow({ overflow: TextOverflow.None })
        .onClick(() => {
          this.isSelected = !this.isSelected;
          this.controller.onCheckboxChange(this.isSelected);
          LogUtil.info(`${this.tag} CheckboxMenuComponent`);
        })
    }
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .margin({
      bottom: this.getCenterDialogStyle($r('app.float.margin_8'), $r('app.float.margin_0')),
    })
    .constraintSize({
      minHeight: this.getCenterDialogStyle($r('app.float.height_48'), $r('app.float.height_68')),
    })
    .width('100%')
  }

  @Builder
  bottomButton(): void {
    Row() {
      Column() {
        Button(this.updateTitle)
          .fontWeight(FontWeight.Medium)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .type(ButtonType.Normal)
          .margin({
            left: $r('app.float.margin_16'),
            right: $r('app.float.margin_16'),
          })
          .width('100%')
          .opacity(this.isButtonEnabled ? 1 : 0.4)
          .enabled(this.isButtonEnabled)
          .onClick(() => {
            LogUtil.info(`${this.tag} open button click`);
            this.isXmarkClick = false;
            EventBus.getInstance().emit(SCREEN_READER_SWITCH, true);
            this.closePage();
          });
      }
      .width('100%');
    }
    .margin({
      bottom: $r('app.float.wh_value_16'),
    })
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .width('100%');
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Scroll() {
            Column() {
              this.contentParagraph();
            }
            .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .margin({
          bottom: $r('app.float.margin_16'),
          top: $r('app.float.margin_16')
        })
        .nestedScroll({
          scrollForward: NestedScrollMode.SELF_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        Column() {
          this.bottomButton();
        }
      }
    }
    .width('100%')
    .margin({
      bottom: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
      $r('app.float.margin_value_28') : $r('app.float.margin_0'),
    })
    .backgroundColor($r('app.color.component_ultra_thick_panel'))
    .borderRadius($r('sys.float.corner_radius_level16'))
  }

  private closePage(): void {
    let item: SettingItemModel = this.sheetPageCtx?.itemComp as SettingItemModel;
    item?.onItemEvent?.(new Map([[
      SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState
    ]]));
  }

  private getCenterDialogStyle(orignalValue: ResourceStr, finalValue: ResourceStr): ResourceStr {
    if (DisplayUtils.getSheetStyle() !== SheetDialogStyle.BOTTOM_DIALOG_STYLE &&
      !FontScaleUtils.isExtraLargeFontMode()) {
      return finalValue;
    } else {
      return orignalValue;
    }
  }

  async aboutToAppear(): Promise<void> {
    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
    }
    this.controller.aboutToAppear();
    this.updateTitle = this.controller.title;
    EventBus.getInstance().on(SECURITY_NOTIFICATION_TIMER_EVENT, this.securityNotificationTimerCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.controller.stopTimer();
    EventBus.getInstance().detach(SECURITY_NOTIFICATION_TIMER_EVENT, this.securityNotificationTimerCallback);
  }
}