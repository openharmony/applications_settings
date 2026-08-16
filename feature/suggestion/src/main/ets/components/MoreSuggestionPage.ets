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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  FOCUS_BOX_PADDING_METRICS,
  FOCUS_BOX_PADDING_METRICS_4,
  PADDING_12,
  PADDING_16,
  PADDING_2,
  PADDING_4,
  PADDING_8,
  PADDING_10
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { SuggestionInfo } from '../model/SuggestionInfo';
import { SuggestionCardManager } from '../manager/SuggestionCardManager';
/* instrument ignore file */
const TAG = 'MoreSuggestionPage';
const EXTRA_LARGE_FONT_1: number = 1.15;
const SUGGESTION_LIST_ID: string = 'moreSuggestionPage_suggestionList';
let isNeedRequestFocus: boolean = false;

@Component
export struct MoreSuggestionPage {
  @State params: PushParam | null = null;
  @State suggestionList?: SuggestionInfo[] = [];
  @State fullLength: number = 0;
  @StorageProp('navDesDynamicPadding') navDesDynamicPadding: number =
    AppStorage.get<number>('navDesDynamicPadding') as number;
  dataCallback?: ((suggestionList: SuggestionInfo[]) => void) = undefined;

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.suggestionList = SuggestionCardManager.getInstance().suggestionInfoList;
    if (!this.dataCallback) {
      this.dataCallback = (suggestionCardList: SuggestionInfo[]) => {
        LogUtil.info(`${TAG} suggestionCardList refresh ${suggestionCardList.length}`);
        this.suggestionList = suggestionCardList;
        if (CheckEmptyUtils.isEmptyArr(suggestionCardList)) {
          if (AppStorage.get<NavigationMode>('navigationMode') === NavigationMode.Split) {
            this.jumpToDefaultPage();
          } else {
            LogUtil.info(`${TAG} pop`);
            PageRouter.pop('Setting');
          }
        } else {
          if (isNeedRequestFocus) {
            focusControl.requestFocus(SUGGESTION_LIST_ID);
            isNeedRequestFocus = false;
          }
        }
      };
      SuggestionCardManager.getInstance().registerSuggestionCallback(this.dataCallback);
    }
    LogUtil.info(`${TAG} aboutToAppear getSuggestionList finish ${JSON.stringify(this.suggestionList)}`);
  }

  private jumpToDefaultPage(): void {
    LogUtil.info(`${TAG} jump to default page`);
    AppStorage.setOrCreate('currentHomeKey', NavEntryKey.ABOUT_DEVICE_ENTRY);
    PageRouter.push(NavEntryKey.ABOUT_DEVICE_ENTRY, undefined, false);
    notifyCompStateChange(NavEntryKey.ABOUT_DEVICE_ENTRY,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
        { state: true } as SettingCompState]]));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (this.dataCallback) {
      SuggestionCardManager.getInstance().unregisterSuggestionCallback(this.dataCallback);
      this.dataCallback = undefined;
    }
  }

  build() {
    Column() {
      ForEach(this.suggestionList, (item: SuggestionInfo, index: number) => {
        Row() {
          SuggestionDetailItemView({ suggestionInfo: item, index: index })
        }
        .id(SUGGESTION_LIST_ID + index)
        .margin({ bottom: PADDING_12 })
        .borderRadius($r('sys.float.corner_radius_level10'))
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .constraintSize({ maxHeight: 480 })
      })
    }
    .id(SUGGESTION_LIST_ID)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .width('100%')
  }
}

@Component
export struct SuggestionDetailItemView {
  @State suggestionInfo: SuggestionInfo = {};
  @State title: string | undefined | Resource = '';
  @State summary: string | undefined | Resource = '';
  @State icon?: ResourceStr | PixelMap | null = null;
  @State isBigFont: boolean = (FontScaleUtils.getCurrentScale(getContext(this)) >= EXTRA_LARGE_FONT_1);
  @State currentFontSize: number = FontScaleUtils.getCurrentScale(getContext(this));
  @State index: number = 0;

  @Styles
  pressStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
    .borderRadius($r('sys.float.corner_radius_level7'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
  }

  aboutToAppear(): void {
    if (this.suggestionInfo) {
      this.title = this.suggestionInfo.title;
      this.summary = this.suggestionInfo.desc;
      this.icon = this.suggestionInfo.iconImg;
    }
  }

  onHandleCancelClick(index: number): void {
    if (SuggestionCardManager.getInstance().suggestionInfoList.length > 1) {
      AccessibilityUtils.requestFocusAccessibility('Setting.homepage_suggestion_more_page.title_id');
      let value = Math.max(0, index - 1);
      focusControl.requestFocus(SUGGESTION_LIST_ID + value);
      if (index === 0) {
        isNeedRequestFocus = true;
      }
    }
    SuggestionCardManager.getInstance().closeSuggestionByClick(this.suggestionInfo);
  }

  onHandleButtonClick(): void {
    SuggestionCardManager.getInstance().clickSuggestion(this.suggestionInfo);
  }

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image(this.icon)
          .width($r('app.float.length_32'))
          .height($r('app.float.height_32'))
          .interpolation(ImageInterpolation.Medium)
          .border({ width: '1px', color: '#99808080', style: BorderStyle.Solid })
          .borderRadius(8)
          .draggable(false)
      }
      Column() {
        Row() {
          Text(this.title)
            .maxFontSize($r('sys.float.Subtitle_M'))
            .minFontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .maxLines(2)
            .maxFontScale(2)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ end: PADDING_8 })
          Blank()
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.xmark'))
              .draggable(false)
              .fontSize((this.currentFontSize === 0) ? 18 : 18 / this.currentFontSize)
              .fontColor([$r('sys.color.icon_secondary')])
              .accessibilityText($r('app.string.dialog_disable'))
          }
          .stateStyles({
            pressed: this.pressStyles,
            normal: this.normalStyles
          })
          .height(26)
          .aspectRatio(1)
          .onClick(() => {
            this.onHandleCancelClick(this.index)
          })
        }
        .alignItems(VerticalAlign.Top)
        .width('100%')

        Text(this.summary)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .maxLines(this.isBigFont ? 5 : 2)
          .maxFontScale(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
          .width('100%')
        Row() {
          Text($r('app.string.view_details'))
            .margin({ top: FOCUS_BOX_PADDING_METRICS, end: PADDING_16, start: FOCUS_BOX_PADDING_METRICS_4 })
            .padding({
              start: PADDING_4,
              top: PADDING_2,
              end: PADDING_4,
              bottom: PADDING_2
            })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .maxFontScale(2)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
            .minFontSize(9)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.onHandleButtonClick()
            })
            .stateStyles({
              pressed: this.pressStyles,
              normal: this.normalStyles
            })
        }
      }
      .margin({ start: PADDING_12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({
      start: PADDING_12,
      end: PADDING_12,
      top: PADDING_12,
      bottom: PADDING_10
    })
    .defaultFocus(this.index === 0)
  }
}