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
import {
  EVENT_ID_SEARCH_BAR_VISIBLE,
  EVENT_ID_SEARCH_NO_EDIT
} from '@ohos/settings.common/src/main/ets/event/types';
import { SafeMarginUtils } from '@ohos/settings.common/src/main/ets/utils/SafeMarginUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { NavigationBar } from '@ohos/settings.commonUikit/src/main/ets/component/NavigationBar';
import { TitleIcon } from '@ohos/settings.commonUikit/src/main/ets/component/TitleIcon';

const TAG: string = 'SearchComponent: ';
const MAX_SEARCH_LEN: number = 128;
const SEARCH_INTERVAL: number = 300;

@Component
export struct SearchComponent {
  controller: SearchController = new SearchController();
  menuBuilder?: WrappedBuilder<[]> = undefined;
  searchComponentId: string = 'search';
  onChangeSearchText: (newValue: string, oldValue: string) => void = () => {
  };
  onFocusChange: () => void = () => {
  };
  onBlurChange: () => void = () => {
  };
  onClickSearchIcon: () => void = () => {
  };
  onClickSearchBack: () => void = () => {
  };
  onClickPageBack: () => void = () => {
  };
  onMoreIconClicked: () => void = () => {
  };
  private oldValue: string = '';
  private safePagePadding: Resource = SafeMarginUtils.getSafeMargin();
  private fontScale: number = FontScaleUtils.getCurrentScale(getContext(this));
  private searchBarEventCb = (isSearching: boolean, coverVisible: boolean, searchWord: string) => {
    this.isSearching = isSearching;
    this.changeValue = searchWord;
  }
  private searchEditEvent = () => {
    this.controller.stopEditing();
  }
  @State changeValue: string = '';
  @State @Watch('stopEditingEvent') isSearching: boolean = false;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  @Prop searchIconMargin: number = 0;
  private timer: number = 0;

  stopEditingEvent(): void {
    if (this.isSearching === false) {
      this.controller.stopEditing();
    }
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(EVENT_ID_SEARCH_BAR_VISIBLE, this.searchBarEventCb);
    EventBus.getInstance().on(EVENT_ID_SEARCH_NO_EDIT, this.searchEditEvent);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(EVENT_ID_SEARCH_BAR_VISIBLE, this.searchBarEventCb);
    EventBus.getInstance().detach(EVENT_ID_SEARCH_NO_EDIT, this.searchEditEvent);
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      // 返回箭头按钮
      Column() {
        TitleIcon({
          symbolIcon: $r('sys.symbol.chevron_backward'),
          accessibilityTextRes: $r('app.string.navigation_back'),
          onClickButton: () => {
            if (this.isSearching) {
              this.onClickSearchBack();
            } else {
              PageRouter.pop('Setting');
            }
          }
        })
      }
      .flexShrink(0)
      .margin({ right: 8 })
      .visibility((!(this.isSplitMode()) || this.isSearching) ? Visibility.Visible : Visibility.None)

      if (this.isSearching) {
        // 搜索时的导航栏相关布局
        Row() {
          Row() {
            this.searchBarView();
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
        }
        .transition(
          TransitionEffect.asymmetric(
            TransitionEffect.OPACITY.animation({ duration: 250, delay: 50, curve: Curve.Sharp }),
            TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Sharp })
          )
        )
        .onAreaChange(() => {
          LogUtil.info(`${TAG} search onAreaChange : `);
          if (this.isSearching) {
            focusControl.requestFocus(this.searchComponentId);
          }
        })
      } else {
        // 正常显示页面时的导航栏布局
        NavigationBar({
          title: $r('app.string.application_and_meta_service_settings_title'),
          menuBuilder: this.menuBuilder,
          onMoreIconClicked: this.onMoreIconClicked,
          shouldShowBackButton: !(this.isSplitMode()),
          showAnimation: !(this.isSplitMode()),
          needLargeTitle: this.isSplitMode(),
          onSearchIconClicked: this.onClickSearchIcon,
        })
          .visibility(this.isSearching ? Visibility.None : Visibility.Visible)
          .transition(
            TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.animation({ duration: 250, delay: 50, curve: Curve.Sharp }),
              TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Sharp })
            )
          )
          .onAreaChange(() => {
            LogUtil.info(`${TAG} title onAreaChange : `);
          })
      }
    }
    .width('100%')
    .padding({
      left: this.safePagePadding,
      right: this.safePagePadding
    })
    .constraintSize({ minHeight: 56 })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  searchBarView(): void {
    Search({ value: this.changeValue, placeholder: $r('app.string.setting_search'), controller: this.controller })
      .id(this.searchComponentId)
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({
        size: ($r('sys.float.Body_L')),
        weight: FontWeight.Regular
      })
      .textFont({
        size: this.fontScale >= FontScaleUtils.EXTRA_LARGE_FONT_2 ? '32vp' : ('sys.float.Body_L')
      })
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .defaultFocus(true)
      .maxLength(MAX_SEARCH_LEN)
      .onChange((value: string) => {
        clearTimeout(this.timer);
        this.timer = setTimeout(() => {
          this.changeValue = value;
          this.onChangeSearchText(value, this.oldValue);
          this.oldValue = value;
          this.timer = 0;
        }, SEARCH_INTERVAL);
      })
      .enabled(true)
  }

  isSplitMode(): boolean {
    return this.navigationMode === NavigationMode.Split;
  }
}
