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

import { curves, display } from '@kit.ArkUI';
import uiAppearance from '@ohos.uiAppearance';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_10,
  PADDING_12,
  PADDING_16,
  PADDING_4,
  PADDING_6,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SuggestionCardManager } from '../manager/SuggestionCardManager';
import { SuggestionInfo } from '../model/SuggestionInfo';
import SuggestionUtil, { SUGGESTION_EFFECT, SuggestionOperation } from '../util/SuggestionUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
/* instrument ignore file */
@Builder
export function suggestionItemGroupViewBuilder(param: object): void {
  SuggestionItemGroupView({ param: param as SettingBaseModel })
}

const TAG = 'SuggestionItemGroupView';

// 显示角标数量的最小数值
const SHOW_BADGE_MIN_NUMBER = 2;

const MAX_SHOW_NUMBER = 1;

// 推荐建议列表
@Component
export struct SuggestionItemGroupView {
  param?: SettingBaseModel;
  @State suggestionList: SuggestionInfo[] = [];
  suggestionManager: SuggestionCardManager = SuggestionCardManager.getInstance();
  dataCallback?: ((suggestionList: SuggestionInfo[]) => void) = undefined;

  build() {
    Column() {
      ForEach(this.suggestionList.slice(0, MAX_SHOW_NUMBER), (suggestionInfo: SuggestionInfo, index: number) => {
        SuggestionItemView({ suggestionInfo: suggestionInfo, badgeNumber: this.suggestionList.length })
          .margin({
            top: index === 0 ? PADDING_12 : PADDING_0,
            bottom: (index === MAX_SHOW_NUMBER - 1) ? PADDING_0 : PADDING_10
          })
      })
    }
    .margin({
      bottom: this.suggestionList.length > 0 && this.suggestionList[this.suggestionList.length - 1] &&
        (this.suggestionList[this.suggestionList.length - 1].isHomePageNoNeedShowDesc === false) ? PADDING_4 : PADDING_0
    })
    .visibility(this.suggestionList.length > 0 ? Visibility.Visible : Visibility.None)
    .animation({
      curve: curves.interpolatingSpring(0, 1, 240, 31)
    })
    .transition(SUGGESTION_EFFECT)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (!this.dataCallback) {
      this.dataCallback = (suggestionCardList: SuggestionInfo[]) => {
        LogUtil.info(`${TAG} on suggestionInfos get ${suggestionCardList.length}`);
        if (suggestionCardList.length > 0) {
          SuggestionUtil.setSuggestionShowTime(suggestionCardList[0]);
        }
        this.suggestionList = suggestionCardList;
      };
      this.suggestionManager.registerSuggestionCallback(this.dataCallback);
    }
    this.suggestionManager.refreshData(getContext());
  }

  aboutToDisappear(): void {
    if (this.dataCallback) {
      this.suggestionManager.unregisterSuggestionCallback(this.dataCallback);
      this.dataCallback = undefined;
    }
  }
}

// 单个推荐建议
@Component
export struct SuggestionItemView {
  @State suggestionInfo: SuggestionInfo = new SuggestionInfo();
  @Prop badgeNumber: number = 0;
  private isSelected: boolean = false;
  @State isHover: boolean = false;
  @State isEnabled: boolean = true;
  @State showSelectedBackColor: boolean = false;
  isNeedSetSelectedBackColor: boolean = true;
  private isPad: boolean = DeviceUtil.isDevicePad();
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `SuggestionItemView aboutToAppear ${this.badgeNumber}`);
    let curKey: string = AppStorage.get('currentHomeKey') as string;
    this.showSelectedBackColor =
      curKey === NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE && this.navigationMode === NavigationMode.Split;
    EventBus.getInstance().on(NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE, (data: object) => {
      this.onItemSelectedEvent(data);
    });
  }

  private onItemSelectedEvent(data: object): void {
    if (!(data instanceof Map)) {
      LogUtil.error(`${TAG}invalid eventbus data type`);
      return;
    }

    let recvData: Map<SettingStateType, SettingBaseState> = data as Map<SettingStateType, SettingBaseState>;
    recvData.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (SettingStateType.STATE_TYPE_ITEM_SELECTED === key) {
        let state = value as SettingCompState;
        if (state.state) {
          this.showSelectedBackColor = this.navigationMode === NavigationMode.Split;
        } else {
          this.showSelectedBackColor = false;
        }
      }
    });
  }

  aboutToDisappear(): void {
    EventBus.getInstance().off(NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE);
  }

  private getNormalColor(): ResourceColor {
    LogUtil.info(`${TAG} getNormalColor`);
    if (this.showSelectedBackColor && this.isNeedSetSelectedBackColor) {
      return this.getBackgroundColorResource();
    }
    if (this.isHover) {
      return $r('sys.color.interactive_hover');
    }
    return $r('app.color.color_default_white');
  }

  private getPressedColor(): ResourceColor {
    LogUtil.info(`${TAG} getPressedColor`);
    if ((this.navigationMode === NavigationMode.Split) && this.showSelectedBackColor &&
      this.isNeedSetSelectedBackColor) {
      return $r('sys.color.interactive_click');
    }
    return $r('sys.color.interactive_pressed');
  }

  private getBackgroundColorResource(): ResourceColor {
    try {
      LogUtil.info(`${TAG} getDarkMode sucess`);
      return uiAppearance.getDarkMode() === 0 ? $r('app.color.color_pressed_click_dark') :
      $r('app.color.color_pressed_click');
    } catch (err) {
      LogUtil.error(`${TAG} getDarkMode fail`);
      return $r('app.color.color_pressed_click');
    }
  }

  private getBackgroundColor(): ResourceColor {
    LogUtil.info(`${TAG} getBackgroundColor sucess`);
    if (this.isSelected) {
      if ((display.isFoldable() || this.isPad) && this.showSelectedBackColor) {
        return $r('app.color.color_pressed_click');
      }
      return $r('app.color.color_1A000000_grey');
    }
    if (this.showSelectedBackColor) {
      return this.getBackgroundColorResource();
    }
    return $r('app.color.color_default_white');
  }

  private onEntryClick(): void {
    LogUtil.info(`${TAG} onEntryClick`);
    let lastKey: string = AppStorage.get('currentHomeKey') as string;
    notifyCompStateChange(lastKey,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
        { state: false } as SettingCompState]]));
    let isSameItem: boolean = lastKey === NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE;
    if (!isSameItem) {
      PageRouter.clear('Setting');
    }
    AppStorage.setOrCreate('currentHomeKey', NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE);
    this.showSelectedBackColor = this.navigationMode === NavigationMode.Split;
    SuggestionCardManager.getInstance().clickSuggestion(this.suggestionInfo, this.badgeNumber, true);
  }

  private isShowBadge(): boolean {
    return true;
  }

  @Builder
  suggestionIconBuilder() {
    Image(this.suggestionInfo.iconImg)
      .id(`suggestion_device_image`)
      .width('32vp')
      .height('32vp')
      .objectFit(ImageFit.Cover)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .draggable(false)
      .interpolation(ImageInterpolation.Medium)
      .syncLoad(true)
      .margin({ end: PADDING_16 })
  }

  @Builder
  suggestionNameBuilder() {
    Text(this.suggestionInfo.title)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .wordBreak(WordBreak.NORMAL)
      .padding({ end: this.isShowBadge() ? PADDING_8 : PADDING_0 })
      .flexShrink(this.isShowBadge() ? 0 : 1)
  }

  @Builder
  suggestionNameBuilderWithPointBadge() {
    Badge({
      value: SuggestionUtil.getBadgeValue(this.badgeNumber),
      position: BadgePosition.Right,
      style: { badgeSize: this.badgeNumber >= SHOW_BADGE_MIN_NUMBER ? '16vp' : '6vp' }
    }) {
      Text(this.suggestionInfo.title)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.NORMAL)
        .padding({ end: this.isShowBadge() ? PADDING_8 : PADDING_0 })
        .margin({ end: this.isShowBadge() && this.badgeNumber >= SHOW_BADGE_MIN_NUMBER ? PADDING_16 : PADDING_6 })
        .flexShrink(this.isShowBadge() ? 0 : 1)
    }
  }

  @Builder
  deviceEntryBuilder() {
    SymbolGlyph($r('sys.symbol.chevron_right'))
      .hoverEffect(null)
      .id(`entry_image_about_device`)
      .fontSize('24vp')
      .margin({ start: PADDING_4 })
      .fontColor([$r('sys.color.icon_fourth')])
  }

  @Builder
  showTextWithBadge() {
    Badge({
      value: SuggestionUtil.getBadgeValue(this.badgeNumber),
      position: BadgePosition.Right,
      style: { badgeSize:
      FontScaleUtils.getCurrentScale(getContext(this)) >= FontScaleUtils.EXTRA_LARGE_FONT_1 ? '23vp' : '16vp' }
    }) {
      Text()
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .maxLines(FontScaleUtils.isExtraLargeFontMode() ? undefined : 1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.NORMAL)
        .margin({ end: PADDING_10 })
        .id(`${TAG}_badge_text1`)
    }
  }

  @Builder
  deviceBadgeBuilder() {
    if (this.isShowBadge()) {
      Row() {
        this.showTextWithBadge()
      }
      .margin({ end: PADDING_8 })
      .justifyContent(FontScaleUtils.isExtraLargeFontMode() ? FlexAlign.Start : FlexAlign.End)
    }
  }

  @Builder
  SuggestionItemWithoutPrompt() {
    Row() {
      this.suggestionIconBuilder();
      Row() {
        if (this.badgeNumber >= SHOW_BADGE_MIN_NUMBER) {
          this.suggestionNameBuilder();
        } else {
          this.suggestionNameBuilderWithPointBadge();
        }
      }
      .layoutWeight(1)
      if (this.badgeNumber >= SHOW_BADGE_MIN_NUMBER) {
        this.deviceBadgeBuilder();
      }
      this.deviceEntryBuilder();
    }
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .padding({
      top: FontScaleUtils.getSafetyPadding(),
      bottom: FontScaleUtils.getSafetyPadding(),
      start: PADDING_8,
      end: PADDING_8
    })
    .id(this.suggestionInfo?.id)
    .width('100%')
    .constraintSize({
      minHeight: 48,
    })
    .backgroundColor(this.getBackgroundColor())
    .borderRadius($r('sys.float.corner_radius_level8'))
    .enabled(this.isEnabled)
    .opacity(!this.isEnabled ? $r('sys.float.alpha_tertiary') : 1)
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .stateStyles({
      normal: {
        .backgroundColor(this.getNormalColor())
      },
      pressed: {
        .backgroundColor(this.getPressedColor())
      },
    })
    .onClick(() => {
      this.onEntryClick();
    })
    .onMouse((event?: MouseEvent): void => {
      if (event) {
        if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
          this.isSelected = true;
        } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
          this.isSelected = false;
        } else {
          // no need handle
        }
      }
    })
    .onTouch((event?: TouchEvent): void => {
      if (event) {
        if (event.type === TouchType.Down) {
          this.isSelected = true;
        } else if (event.type === TouchType.Up) {
          this.isSelected = false;
        } else {
          // no need handle
        }
      }
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    });
  }

  build() {
    Column() {
      Row() {
        this.SuggestionItemWithoutPrompt()
      }
      .padding({
        top: PADDING_4,
        bottom: PADDING_4,
        start: PADDING_4,
        end: PADDING_4
      })
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor($r('sys.color.comp_background_list_card'))

      if (StringUtil.isNotEmpty(this.suggestionInfo.desc) && !this.suggestionInfo.isHomePageNoNeedShowDesc) {
        Row() {
          Text(this.suggestionInfo.desc)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.NORMAL)
        }
        .padding({
          top: FontScaleUtils.getSafetyPadding(),
          start: PADDING_12,
          end: PADDING_12
        })
        .width('100%')
      }
    }
  }
}
