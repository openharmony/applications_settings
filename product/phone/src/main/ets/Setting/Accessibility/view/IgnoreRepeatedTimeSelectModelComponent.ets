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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  SettingModalState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  DefaultSettingPageModel,
  SettingPageModel,
  SettingSheetPageContext
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { IgnoreRepeatedStateModel } from '../utils/AccessibilityIgnoreRepeatedModel';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_EVENT,
  IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG,
  IGNORE_REPEATED_TIME_RESOURCE_MAP
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
  .borderRadius($r('sys.float.corner_radius_level4'))
}

@Extend(Text)
function titleTextStyles() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'))
  .maxFontScale(2)
  .wordBreak(WordBreak.HYPHENATION)
  .textOverflow({ overflow: TextOverflow.None })
  .textAlign(TextAlign.Start)
  .maxLines(20)
}

@Extend(Text)
function buttonTextStyles() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_emphasize'))
  .maxFontScale(1.75)
  .textOverflow({ overflow: TextOverflow.None })
  .textAlign(TextAlign.Center)
  .maxLines(20)
}

@Extend(Button)
function bottomButtonStyles() {
  .constraintSize({ minHeight: $r('app.float.height_40') })
  .borderRadius($r('sys.float.corner_radius_level10'))
  .margin({
    left: $r('app.float.margin_16'),
    right: $r('app.float.margin_16'),
  })
  .align(Alignment.Center)
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  .width('100%')
}

@Component
export struct IgnoreRepeatedTimeSelectModelComponent {
  tag: string = 'IgnoreRepeatedTimeSelectModelComponent: ';
  item?: object;
  pageParam?: PageParams;
  scroller: Scroller = new Scroller();
  @State isShowNext?: boolean = false;
  private sheetPageCtx?: SettingSheetPageContext;
  private isCloseChecked?: boolean = IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick;
  private delayChecked?: string = IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue;
  private isDeleteCache: boolean = true;
  private isNextClick: boolean = false;
  @State pathStack: NavPathStack = new NavPathStack();
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();

  build() {
    Column() {
      Row() {
        Scroll() {
          Column() {
            this.topTextArea();
            this.middleListArea();
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
        this.bottomButton();
      }
      .constraintSize({ minHeight: $r('app.float.height_40') })
      .margin({
        top: $r('app.float.margin_16'),
        bottom: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
          $r('app.float.margin_value_28') : $r('app.float.margin_0'),
      })
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  topTextArea(): void {
    Column() {
      Row() {
        Text($r('app.string.ignore_repeated_time_select_summary'))
          .titleTextStyles()
      }
      .constraintSize({
        minHeight: $r('app.float.height_42')
      })
      .margin({
        top: $r('sys.float.padding_level8'),
        bottom: $r('sys.float.padding_level4'),
      })

      Row() {
        Text($r('app.string.ignore_repeated_time_select_tips'))
          .titleTextStyles()
      }
      .constraintSize({
        minHeight: $r('app.float.height_42')
      })
      .margin({
        bottom: $r('sys.float.padding_level8'),
      })
    }
    .margin({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
    .padding({
      left: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
        $r('sys.float.padding_level0') : $r('sys.float.padding_level2'),
      right: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
        $r('sys.float.padding_level0') : $r('sys.float.padding_level2'),
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  middleListArea(): void {
    List({ scroller: this.scroller }) {
      ListItemGroup({ style: ListItemGroupStyle.CARD }) {
        ListItem({ style: ListItemStyle.NONE }) {
          IgnoreItemContentComponent({
            item: $r('app.string.dialog_disable'),
            itemResource: '',
            index: 0,
            isChecked: !this.isCloseChecked,
            isShowNext: this.isShowNext
          })
        }

        ForEach(Array.from(IGNORE_REPEATED_TIME_RESOURCE_MAP.entries()),
          (item: [string, Resource], itemIndex: number) => {
            ListItem({ style: ListItemStyle.NONE }) {
              IgnoreItemContentComponent({
                item: item[0],
                itemResource: item[1],
                index: itemIndex + 1,
                isChecked: this.isCloseChecked ? item[0] === IgnoreRepeatedStateModel.getInstance()
                  .formatToOneDecimal(String(IgnoreRepeatedStateModel.getInstance()
                    .ConvertIntervalValue(this.delayChecked))) : false,
                isShowNext: this.isShowNext
              })
            }
          });
      }
      .margin({})
      .divider({
        strokeWidth: px2vp(1),
        color: $r('sys.color.comp_divider'),
        startMargin: $r('sys.float.padding_level4'),
        endMargin: $r('sys.float.padding_level4'),
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.corner_radius_level10'))
    }
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .scrollBar(BarState.Off)
    .alignSelf(ItemAlign.Start)
    .clip(true)
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .visibility(Visibility.Visible);
  }

  @Builder
  bottomButton(): void {
    Row() {
      Stack({ alignContent: Alignment.Top }) {
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.done'))
            .buttonTextStyles()
        }
        .bottomButtonStyles()
        .visibility(this.isShowNext ? Visibility.Hidden : Visibility.Visible)
        .onClick(() => {
          LogUtil.info(`${this.tag} done button click repeatClickIntervalValueCache: ${IgnoreRepeatedStateModel.getInstance()
            .repeatClickIntervalValueCache}`);
          if (IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache ===
          ResourceUtil.getStringSync($r('app.string.dialog_disable'))) {
            HiSysEventUtil.reportDefaultBehaviorEventByUE(
              HiSysAccessibilityEventGroup.IGNORE_REPEAT_TOUCHES_SWITCH, 'off');
            this.isDeleteCache = false;
            AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', false);
            IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = false;
            IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
            IgnoreRepeatedStateModel.getInstance().closeNotifyRefreshState();
          }
          this.closePage();
        })

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.dialog_next'))
            .buttonTextStyles()
        }
        .bottomButtonStyles()
        .visibility(this.isShowNext ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          LogUtil.info(`${this.tag} dialog_next button click`);
          this.isDeleteCache = false;
          this.isNextClick = true;
          if (IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache === '') {
            IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache =
              IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue;
          }
          EventBus.getInstance().emit(IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_EVENT, true);
          this.closePage();
        })
      }
    }
    .draggable(false)
    .margin({
      bottom: $r('app.float.margin_16'),
    })
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .width('100%');
  }

  private closePage(): void {
    let item: SettingItemModel = this.sheetPageCtx?.itemComp as SettingItemModel;
    item?.onItemEvent?.(new Map([[
      SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState
    ]]));
  }

  aboutToAppear(): void {
    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
    }
    let item = this.sheetPageCtx.itemComp as SettingItemModel;
    LogUtil.info(`${this.tag} aboutToAppear delayChecked: ${
    this.delayChecked}, isCloseChecked:${this.isCloseChecked}, isDeleteCache:${this.isDeleteCache}`);
    IgnoreRepeatedStateModel.getInstance().cacheIgnoreClickState();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    let isTrialModelClosed: boolean = SettingsDataUtils.getSettingsData(
      IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (this.isDeleteCache && !isTrialModelClosed) {
      IgnoreRepeatedStateModel.getInstance().recoveryIgnoreClickState();
    }
    if (isTrialModelClosed) {
      SettingsDataUtils.setSettingsData(IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG, CLICK_SWITCH_OFF);
    }
    if (!this.isNextClick) {
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
      IgnoreRepeatedStateModel.getInstance().recoveryIgnoreClickData();
    }
  }
}

@Component
export struct IgnoreItemContentComponent {
  private tag: string = 'IgnoreItemContentComponent: '
  @State item: ResourceStr = '';
  @State itemResource: ResourceStr = '';
  @State index: number = 0;
  @State isChecked: boolean = false;
  @Link isShowNext: boolean;

  private getTitleFormat(title: string): string {
    if (!this.isNumber(title)) {
      return title;
    }
    let titleFormat: string = ResourceUtil.getLocalNumberFormat(Number(title));
    return titleFormat;
  }

  /**
   * 判断是否为number类型
   *
   * @param val 数值
   */
  private isNumber(val: string): boolean {
    return val === '' ? false : !Number.isNaN(Number(val));
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.itemResource ? ResourceUtil.getAnyStrFormatStringSync(this.itemResource as Resource,
            this.getTitleFormat(this.item as string)) : this.item)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .constraintSize({
              minHeight: $r('app.float.length_21'),
            })
            .maxFontScale(2)
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)

        Radio({
          value: this.itemResource ? ResourceUtil.getAnyStrFormatStringSync(this.itemResource as Resource,
            this.getTitleFormat(this.item as string)) : this.item as string,
          group: 'IgnoreItemRadioGroup'
        })
          .checked(this.isChecked)
          .hitTestBehavior(HitTestMode.None)
          .onClick(() => {
            this.checkButtonState();
          })
          .width($r('app.float.length_20'))
          .height($r('app.float.length_20'))
          .accessibilityText(' ')
          .id(`ignore_Repeated_radio_${this.index}`)
      }
      .width('100%')
      .height('auto')
    }
    .stateStyles({
      normal: normalStateIconStyles,
      pressed: pressedStateIconStyles,
    })
    .padding({
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4'),
      top: $r('sys.float.padding_level6'),
      bottom: $r('sys.float.padding_level6'),
    })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .constraintSize({
      minHeight: '48vp'
    })
    .justifyContent(FlexAlign.Center)
    .onClick((event) => {
      this.isChecked = !this.isChecked;
      this.checkButtonState();
    });
  }

  private checkButtonState(): void {
    LogUtil.info(`${this.tag} onClick checkButtonState: ${ResourceUtil.getStringSync(this.item)}`);
    if (!this.itemResource) {
      this.isShowNext = false;
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache =
        ResourceUtil.getStringSync($r('app.string.dialog_disable'));
    } else if (IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick &&
      ResourceUtil.getAnyStrFormatStringSync(this.itemResource as Resource,
        this.item as string) ===
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValue) {
      this.isShowNext = false;
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache =
        ResourceUtil.getAnyStrFormatStringSync(this.itemResource as Resource,
          this.item as string);
    } else {
      this.isShowNext = true;
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache =
        ResourceUtil.getAnyStrFormatStringSync(this.itemResource as Resource,
          this.item as string);
    }
    this.isChecked = this.setCheckedState();
  }

  private setCheckedState(): boolean {
    if (this.itemResource) {
      return IgnoreRepeatedStateModel.getInstance()
        .formatToOneDecimal(IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache) ===
      IgnoreRepeatedStateModel.getInstance()
        .formatToOneDecimal(ResourceUtil.getAnyStrFormatStringSync(this.itemResource as Resource,
          this.item as string));
    }
    return IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache ===
    ResourceUtil.getStringSync(this.item);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }
}