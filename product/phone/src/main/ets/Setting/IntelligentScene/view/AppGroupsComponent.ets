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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PADDING_12, PADDING_26 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { AppListDataInfoComponent } from './AppListDataInfoComponent';
import { AppGroupsController } from '../controller/AppGroupsController';
import { AppInfo } from '../model/bean/AppInfo';
import { AlphabetIndexerComponent } from './AlphabetIndexerComponent';
import { EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START } from '../event/types';
import { IntelligentSceneWindowManager, WINDOW_MODE_CHANGE } from '../manager/IntelligentSceneWindowManager';
import { ListSlideSelectController } from '../controller/ListSlideSelectController';

/* instrument ignore file */
const TAG: string = 'AppGroupsComponent';

@Component
export struct AppGroupsComponent {
  private tag: string = 'AppGroupsComponent: ';
  private scroller: ListScroller = new ListScroller();
  private appGroupController?: AppGroupsController;
  private onAppItemClicked: (index: number, item: AppInfo) => void = () => {};
  private slideSelectCtrl: ListSlideSelectController = new ListSlideSelectController();
  @Link appGroups: AppInfoDataSource;
  @State alphabetIndex: number | undefined = 0;
  @State isSplitScreenMode: boolean = false;
  @State isFloatingWindowMode: boolean = false;

  private onWindowModeChange = (windowMode: string) => {
    LogUtil.info(`${TAG} onWindowModeChange: ${windowMode}`);
    this.isSplitScreenMode = IntelligentSceneWindowManager.isSplitScreenMode(windowMode);
    this.isFloatingWindowMode = IntelligentSceneWindowManager.isFloatWindowMode(windowMode);
  };

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      List({ scroller: this.scroller }) {
        LazyForEach(this.appGroups, (item: AppInfo, index: number) => {
          ListItem() {
            AppListDataInfoComponent({
              item: item,
              index: index,
              totalCount: this.appGroups.totalCount(),
              onAppItemClicked: this.onAppItemClicked,
            })
          }
        }, (item: AppInfo) => (`${item.label}${item.name}${item.isSelected}`))
      }
      .width('100%')
      .height('100%')
      .padding({
        start: PADDING_12,
        end: PADDING_26,
      })
      .onScrollStart(() => {
        EventBus.getInstance().emit(EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START);
      })
      .onScrollIndex((start: number, end: number, mid: number) => {
        this.alphabetIndex = this.appGroups?.getPrefixIndex(start);
        this.slideSelectCtrl.onScrollIndex(start, end, mid);
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: true,
      })
      .scrollBar(BarState.Off)
      .onSizeChange(this.slideSelectCtrl.onSizeChange())
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.slideSelectCtrl.onAreaChange(newValue);
      })
      .onGestureRecognizerJudgeBegin(this.slideSelectCtrl.onGestureRecognizerJudgeBegin())
      .gesture(
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart(this.slideSelectCtrl.onActionStart(this.scroller))
          .onActionUpdate(this.slideSelectCtrl.onActionUpdate(this.scroller))
          .onActionEnd(this.slideSelectCtrl.onActionEnd(this.scroller))
      )

      AlphabetIndexerComponent({
        appInfoGroups: this.appGroups,
        scroller: this.scroller,
        selectedIndex: this.alphabetIndex,
        isAutoCollapse: true,
      })
    }
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.appGroupController = new AppGroupsController(this.appGroups);
    this.appGroupController.init();
    const windowMode: string = IntelligentSceneWindowManager.getWindowMode();
    this.isSplitScreenMode = IntelligentSceneWindowManager.isSplitScreenMode(windowMode);
    this.isFloatingWindowMode = IntelligentSceneWindowManager.isFloatWindowMode(windowMode);
    this.slideSelectCtrl = new ListSlideSelectController();
    this.slideSelectCtrl.setListSource(this.appGroups);
    this.slideSelectCtrl.setTouchListener(this.onAppItemClicked);
    EventBus.getInstance().on(WINDOW_MODE_CHANGE, this.onWindowModeChange);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.appGroupController?.destroy();
    EventBus.getInstance().on(WINDOW_MODE_CHANGE, this.onWindowModeChange);
  }
}