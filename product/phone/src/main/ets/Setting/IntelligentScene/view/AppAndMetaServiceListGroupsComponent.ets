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

import { display } from '@kit.ArkUI';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_16, PADDING_84 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { AppAndMetaServiceListController } from '../controller/AppAndMetaServiceListController';
import { AppInfo } from '../model/bean/AppInfo';
import { AppListItemComponent } from './AppListItemComponent';
import { AlphabetIndexerComponent } from './AlphabetIndexerComponent';
import { EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START } from '../event/types';
/* instrument ignore file */
import { ListSlideSelectController } from '../controller/ListSlideSelectController';
import {
  FULL_DISPLAY_MODE,
  EXPEND_TOOLBAR_HEIGHT,
  FOLD_TOOLBAR_HEIGHT,
  IntelligentSceneDisplayUtil,
} from '../utils/IntelligentSceneDisplayUtil';

const TAG: string = 'AppAndMetaServiceListGroupsComponent: ';

@Component
export struct AppAndMetaServiceListGroupsComponent {
  private tag: string = 'AppAndMetaServiceListGroupsComponent: ';
  private scroller: ListScroller = new ListScroller();
  private appGroupController?: AppAndMetaServiceListController;
  private onAppItemClicked: (index: number, item: AppInfo) => void = () => {};
  private slideSelectCtrl: ListSlideSelectController = new ListSlideSelectController();
  @Link appGroups: AppInfoDataSource;
  @State alphabetIndex: number | undefined = 0;
  @State isEmpty: boolean = false;
  @State paddingBottom: number = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ?
    EXPEND_TOOLBAR_HEIGHT : FOLD_TOOLBAR_HEIGHT
  private appListEmptyCallBack = (isEmpty: boolean, index: number) => {
    this.isEmpty = isEmpty;
  };
  private foldStatusChangeCallback = (foldStatus: display.FoldDisplayMode) => {
    LogUtil.info(`${TAG} foldStatusChangeCallback ${foldStatus}`);
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL || foldStatus === FULL_DISPLAY_MODE) {
      // 双折叠完全展开，三折叠展开两屏或三屏
      this.paddingBottom = EXPEND_TOOLBAR_HEIGHT;
      return;
    }
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN) {
      // 双折叠折为单屏，三折叠折为单屏
      this.paddingBottom = FOLD_TOOLBAR_HEIGHT;
      return;
    }
  };

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      List({ scroller: this.scroller }) {
        LazyForEach(this.appGroups, (item: AppInfo, index: number) => {
          ListItem() {
            AppListItemComponent({
              item: item,
              index: index,
              totalCount: this.appGroups.totalCount(),
              onAppItemClicked: this.onAppItemClicked
            })
              .borderRadius({
                topLeft: this.isFirstItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                topRight: this.isFirstItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                bottomLeft: this.isLastItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                bottomRight:  this.isLastItem(index) ? $r('sys.float.corner_radius_level10') : 0,
              })
              .backgroundColor($r('sys.color.comp_background_list_card'))
          }
        }, (item: AppInfo) => (`${item.name}${item.appIndex}${item.isSelected}`))
      }
      .width('100%')
      .height('100%')
      .borderRadius($r('sys.float.corner_radius_level10'))
      .padding({
        bottom: this.paddingBottom,
      })
      .onScrollIndex((start: number, end: number, mid: number) => {
        this.alphabetIndex = this.appGroups?.getPrefixIndex(start);
        this.slideSelectCtrl.onScrollIndex(start, end, mid);
      })
      .onScrollStart(() => {
        EventBus.getInstance().emit(EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START);
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
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
        selectedIndex: this.alphabetIndex
      })
        .visibility(this.isEmpty ? Visibility.Hidden : Visibility.Visible)
        .margin({
          top: 24,
        })
        .padding({
          bottom: this.paddingBottom,
        })
    }
    .width('100%')
    .padding({
      start: PADDING_16,
      end: PADDING_16,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.appGroupController?.init();
    EventBus.getInstance().on('EVENT_ID_APP_LIST_EMPTY', this.appListEmptyCallBack);
    this.slideSelectCtrl.setListSource(this.appGroups);
    this.slideSelectCtrl.setTouchListener(this.onAppItemClicked);
    IntelligentSceneDisplayUtil.registerFoldStatusChangeListener(this.foldStatusChangeCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.appGroupController?.destroy();
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_EMPTY', this.appListEmptyCallBack);
    IntelligentSceneDisplayUtil.unRegisterFoldStatusChangeListener(this.foldStatusChangeCallback);
  }

  private isFirstItem(index: number): boolean {
    return index === 0;
  }

  private isLastItem(index: number): boolean {
    return index === this.appGroups.totalCount() - 1;
  }
}