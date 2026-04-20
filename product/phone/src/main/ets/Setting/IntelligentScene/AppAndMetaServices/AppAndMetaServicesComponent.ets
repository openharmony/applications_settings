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

import { curves } from '@kit.ArkUI';
import display from '@ohos.display';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  PADDING_10,
  PADDING_12,
  PADDING_16,
  PADDING_28,
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { SegmentButtonGroup } from './SegmentButtonGroup';
import { AppData, AppInfo } from '../model/bean/AppInfo';
import { EmptyListComponent } from '../view/EmptyListComponent';
import { AppAndMetaServiceListController } from '../controller/AppAndMetaServiceListController';
import { AppAndMetaServiceListGroupsComponent } from '../view/AppAndMetaServiceListGroupsComponent';
import { AppListItemComponent } from '../view/AppListItemComponent';
import { AppAndMetaServiceSelectedComponent } from '../view/AppAndMetaServiceSelectedComponent';
import { SheetTittleComponent } from '../view/SheetTittleComponent';
import { EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START } from '../event/types';
import {
  IntelligentSceneWindowManager,
  WINDOW_MODE_CHANGE,
  SPLIT_1_3_RATE,
  SPLIT_MIN_SCROLL,
  SPLIT_MAX_SCROLL,
  SPLIT_PORTRAIT_RATE,
} from '../manager/IntelligentSceneWindowManager';
import { IntelligentSceneFontScaleUtil } from '../utils/IntelligentSceneFontScaleUtil';
import {
  IntelligentSceneDisplayUtil,
  FOLD_TOOLBAR_HEIGHT,
  EXPEND_TOOLBAR_HEIGHT,
  FULL_DISPLAY_MODE,
  FOLD_PADDING_BOTTOM,
  EXPEND_PADDING_BOTTOM,
} from '../utils/IntelligentSceneDisplayUtil';

/* instrument ignore file */
const TAG: string = 'AppAndMetaServicesComponent : ';

@Entry
@Component
export struct AppAndMetaServicesComponent {
  private controller: SearchController = new SearchController();
  @State changeValue: string = '';
  @State isSearching: boolean = false;
  @State searchDataComplete: boolean = false;
  @State loadDataComplete: boolean = false;
  @State selectCount: number = 0;
  @State appGroups: AppInfoDataSource = new AppInfoDataSource();
  @State selectAppGroups: AppInfoDataSource = new AppInfoDataSource();
  @State showNoResultView: boolean = false;
  @State showSearchResult: boolean = false;
  @State isShowSelected: boolean = false;
  @State isSplitScreenMode: boolean = false;
  // 分屏 1/3 模式
  @State isSplitScreenMinMode: boolean = false;
  @State splitModeMaxScrollHeight: Length = '100%';
  @State @Watch('selectIndexesUpdated') selectedIndexes: number[] = [0];
  @State selectViewMarginBottom: Length = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ?
    EXPEND_TOOLBAR_HEIGHT : FOLD_TOOLBAR_HEIGHT;
  @State toolBarHeight: number = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ?
    EXPEND_TOOLBAR_HEIGHT : FOLD_TOOLBAR_HEIGHT;
  @State containerPaddingBottom: number = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ?
    FOLD_PADDING_BOTTOM : EXPEND_PADDING_BOTTOM;
  @State toolBarPaddingBottom: LengthMetrics = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ?
    PADDING_10 : PADDING_28;
  private searchResultArray: AppInfoDataSource = new AppInfoDataSource();
  private appGroupController?: AppAndMetaServiceListController;
  private scroller: Scroller = new Scroller();
  private allSearchData: AppInfoDataSource = new AppInfoDataSource();
  private onSearchItemClicked: (index: number, item: AppInfo) => void = (index: number, item: AppInfo) => {
    if (item.isSelected) {
      if (this.selectAppGroups.getArray().indexOf(item) < 0) {
        this.addToSelectedGroups(item);
      }
    } else {
      this.updateSelectApp(item);
    }
    this.selectCount = this.selectAppGroups.totalCount();
    EventBus.getInstance().emit('intelligenceAppInfoRefresh', item.name, item.label, item.isSelected);
  };
  private onSelectedAppItemClicked: (index: number, item: AppInfo) => void = (index: number, item: AppInfo) => {
    this.updateSelectApp(item);
    this.selectCount = this.selectAppGroups.totalCount();
    if (this.selectCount === 0) {
      this.isShowSelected = false;
    }
    this.selectAppGroups.notifyDataChange(0);
    if (this.selectCount > 1) {
      this.selectAppGroups.notifyDataChange(this.selectCount - 1);
    }
    EventBus.getInstance().emit('intelligenceAppInfoRefresh', item.name, item.label);
  };
  private loadingCallback = (isLoading: boolean) => {
    this.loadDataComplete = !isLoading;
  };
  private appInfoLoadedCallBack = () => {
    if (this.appGroups.totalCount() > 0 && !this.loadDataComplete) {
      this.loadDataComplete = true;
    }
    let totalCount: number = this.allSearchData.totalCount();
    this.selectAppGroups.clearAll();
    for (let i = 0; i < totalCount; i++) {
      if (this.allSearchData.getArray()[i].isSelected) {
        let appInfo: AppInfo = this.allSearchData.getArray()[i];
        this.selectAppGroups.getArray().push(appInfo);
      }
    }
    this.selectCount = this.selectAppGroups.totalCount();
  };
  private onAppItemClicked: (index: number, item: AppInfo) => void = (index: number, item: AppInfo) => {
    if (item.isSelected) {
      if (this.selectAppGroups.getArray().indexOf(item) < 0) {
        this.addToSelectedGroups(item);
      }
    } else {
      this.updateSelectApp(item);
    }
    this.selectCount = this.selectAppGroups.totalCount();
  };

  private onWindowModeChange = (windowMode: string) => {
    LogUtil.info(`${TAG} onWindowModeChange: ${windowMode}`);
    this.isSplitScreenMode = IntelligentSceneWindowManager.isSplitScreenMode(windowMode);
  };

  private updateSelectApp(item: AppInfo) {
    this.selectAppGroups.getArray().forEach(element => {
      if (element.name === item.name && element.appIndex === item.appIndex) {
        const index = this.selectAppGroups.getArray().indexOf(element);
        if (index > -1) {
          this.selectAppGroups.removeDataByIndex(index);
        }
      }
    })
  }

  private addToSelectedGroups(item: AppInfo): void {
    this.selectAppGroups.getArray().push(item);
    this.selectAppGroups.getArray().sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
    this.selectAppGroups.notifyDataReload();
  }

  private foldStatusChangeCallback = (foldStatus: display.FoldDisplayMode) => {
    LogUtil.info(`${TAG} foldStatusChangeCallback ${foldStatus}`);
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL || foldStatus === FULL_DISPLAY_MODE) {
      // 双折叠完全展开，三折叠展开两屏
      this.toolBarHeight = EXPEND_TOOLBAR_HEIGHT;
      this.containerPaddingBottom = FOLD_PADDING_BOTTOM;
      this.toolBarPaddingBottom = PADDING_10;
      return;
    }
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN) {
      // 双折叠折为单屏，三折叠折为单屏
      this.toolBarHeight = FOLD_TOOLBAR_HEIGHT;
      this.containerPaddingBottom = EXPEND_PADDING_BOTTOM;
      this.toolBarPaddingBottom = PADDING_28;
      return;
    }
  };

  @Builder
  searchBarView(): void {
    Search({ value: $$this.changeValue, placeholder: $r('app.string.setting_search'), controller: this.controller })
      .margin({
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level5')
      })
      .width('calc(100% - 32vp)')
      .placeholderColor($r('sys.color.font_secondary'))
      .fontColor($r('sys.color.font_secondary'))
      .placeholderFont({
        size: ($r('sys.float.Body_L')),
        weight: FontWeight.Regular
      })
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .enableKeyboardOnFocus(false)
      .onChange((value: string) => {
        this.onSearchBarChange(value);
      })
      .enabled(true)
  }

  @Builder
  toolBarView(): void {
    Column() {
      RelativeContainer() {
        Text($r('app.plural.selected_app', this.selectCount, this.selectCount))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectCount > 0 ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
          .accessibilityDescription(this.selectCount <= 0 ?
            ResourceUtil.getStringSync($r('app.string.wifi_state_off')) : '')
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .maxFontScale(IntelligentSceneFontScaleUtil.getToolbarMaxFontSize(getContext(this), this.selectCount))
          .alignRules({
            start: { anchor: '__container__', align: HorizontalAlign.Start },
            center: { anchor: '__container__', align: VerticalAlign.Center },
            end: { anchor: 'selected_app_finish', align: HorizontalAlign.Start }
          })
          .constraintSize({ minHeight: '19vp' })
          .onClick(() => {
            this.onSelectedTextClick();
          })

        Button({ type: ButtonType.Capsule, buttonStyle: ButtonStyleMode.EMPHASIZED }) {
          Text($r('app.string.done'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(IntelligentSceneFontScaleUtil.getToolbarMaxFontSize(getContext(this), this.selectCount))
            .textAlign(TextAlign.Center)
            .constraintSize({ minWidth: '72vp', minHeight: '28vp' })
            .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
        }
        .id('selected_app_finish')
        .onClick(async () => {
          this.closeSheetPage(true);
        })
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
      }
      .height(56)
    }
    .width('100%')
    .height(this.toolBarHeight)
    .backgroundColor($r('app.color.sheet_finish_background'))
    .padding({
      start: PADDING_16,
      end: PADDING_16,
      bottom: this.toolBarPaddingBottom,
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      LogUtil.showInfo(TAG, `new area: ${newArea.height}`);
      if (!newArea?.height) {
        return;
      }
      this.selectViewMarginBottom = newArea.height;
    })
  }
  @Builder
  contentsView(): void {
    Column() {
      SheetTittleComponent({
        isSearching: this.isSearching,
        closeSheetPage: this.closeSheetPage,
        title: $r('app.string.add_app_meta_service'),
        clickBackImage: () => {
          this.isSearching = false;
          this.changeValue = '';
          this.searchDataComplete = false;
          this.controller.stopEditing();
        },
      })

      Scroll(this.scroller){
        Column() {
          this.searchBarView()
          // SegmentButtonGroup({
          //   selectedIndexes: this.selectedIndexes
          // })
          //   .visibility(!this.isSearching ? Visibility.Visible : Visibility.None)
          this.normalView()

          if (this.isSearching) {
            this.searchView()
          }
        }
        .height(this.isSplitScreenMode ? this.splitModeMaxScrollHeight : '100%')
      }
      .width('100%')
      .padding({
        bottom: this.containerPaddingBottom,
      })
    }
    .width('100%')
    .height('100%')

    if (this.isShowSelected) {
      Column() {
        this.selectedView()
      }
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder
  selectedView(): void {
    Stack() {
      Column() {
      }
      .backgroundColor('#19000000')
      .height('100%')
      .width('100%')
      .onClick(() => {
        this.isShowSelected = false;
      })

      Column() {
        AppAndMetaServiceSelectedComponent({
          appGroups: this.selectAppGroups,
          onAppItemClicked: this.onSelectedAppItemClicked,
        })
          .width('calc(100% - 32vp)')
      }
      .backgroundColor($r('app.color.sheet_finish_background'))
      .width('100%')
      .constraintSize({
        maxHeight: '60%',
      })
      .margin({ bottom: this.selectViewMarginBottom })
      .alignItems(HorizontalAlign.Center)
      .clip(true)
      .padding({
        top: $r('sys.float.padding_level8'),
      })
      .borderRadius({
        topLeft: $r('sys.float.corner_radius_level10'),
        topRight: $r('sys.float.corner_radius_level10')
      })
      .animation({
        curve: curves.interpolatingSpring(4, 1, 342, 37),
        duration: 400,
        onFinish: () => {
        }
      })

    }
    .alignContent(Alignment.Bottom)
    .height('100%')
    .width('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  searchView(): void {
    Column() {
      if (this.searchDataComplete) {
        if (this.showNoResultView) {
          this.noResultView()
        } else {
          this.searchListView()
        }
      }
    }
    .width('calc(100% - 32vp)')
    .height('100%')
  }

  @Builder
  searchListView(): void {
    Column() {
      List() {
        LazyForEach(this.searchResultArray, (item: AppInfo, index: number) => {
          ListItem() {
            AppListItemComponent({
              item: item,
              index: index,
              totalCount: this.searchResultArray.totalCount(),
              onAppItemClicked: this.onSearchItemClicked,
              isSearchList: true,
            })
              .borderRadius({
                topLeft: this.isFirstItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                topRight: this.isFirstItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                bottomLeft: this.isLastItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                bottomRight:  this.isLastItem(index) ? $r('sys.float.corner_radius_level10') : 0,
              })
              .backgroundColor($r('sys.color.comp_background_list_card'))
          }
        }, (item: AppInfo, index: number) => (this.getId(item, index)))
      }
      .height('100%')
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: !this.isSplitScreenMode,
      })
      .scrollBar(BarState.Off)
    }
    .layoutWeight(1)
    .transition(TransitionEffect.OPACITY.animation({
      duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
    }))
    .visibility(this.showSearchResult ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  noResultView(): void {
    Column() {
      Image($r('app.media.search_no_result'))
        .width(120)
        .height(120)
        .margin({ bottom: '16vp' })
        .draggable(false)
      Text($r('app.string.no_matching_results'))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize('14vp')
    }
    .offset({ y: '130' })
    .visibility(this.showSearchResult ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  normalView(): void {
    Stack() {
      if (!this.loadDataComplete && !this.isSearching) {
        Column() {
          LoadingProgress()
            .color($r('sys.color.icon_secondary'))
            .size({ height: '72vp', width: '72vp' })
            .id('loading_progress_')

          Text($r('app.string.app_loading'))
            .padding({ top: '16vp' })
            .fontSize('14fp')
            .maxFontSize(2)
        }
        .justifyContent(FlexAlign.Center)
        .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
      }
      EmptyListComponent({
        loadDataComplete: this.loadDataComplete
      })
        .visibility(this.isSearching ? Visibility.None : Visibility.Visible)
        .layoutWeight(1)
      AppAndMetaServiceListGroupsComponent({
        appGroups: this.appGroups,
        onAppItemClicked: this.onAppItemClicked,
        appGroupController: this.appGroupController,
      })
        .margin({
          top: PADDING_12,
        })
        .visibility(this.loadDataComplete && !this.isSearching ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .layoutWeight(1)
  }

  build() {
    Stack() {
      Stack() {
        this.contentsView()
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.TopStart)

      if (this.loadDataComplete) {
        this.toolBarView()
      }
    }
    .onAreaChange((oldArea, newArea) => {
      if (!this.isSplitScreenMode) {
        return;
      }
      let isDevicePortrait: boolean = DeviceUtil.isDevicePortrait();
      if (isDevicePortrait && newArea.height &&
        Number(newArea.height) < SPLIT_1_3_RATE * DisplayUtils.getScreenHeight()) {
        this.isSplitScreenMinMode = true;
      } else {
        this.isSplitScreenMinMode = false;
      }
      LogUtil.info(`${TAG} onAreaChange isSplitScreenMinMode: ${this.isSplitScreenMinMode}`);
      this.setMaxScrollHeight(Number(newArea.height));
    })
    .alignContent(Alignment.BottomStart)
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.appGroupController =
      new AppAndMetaServiceListController(this.appGroups, this.allSearchData, this.onAppItemClicked);
    EventBus.getInstance().on('EVENT_ID_LOADING', this.loadingCallback);
    EventBus.getInstance().on('APP_INFO_LOADED', this.appInfoLoadedCallBack);
    const windowMode: string = IntelligentSceneWindowManager.getWindowMode();
    this.isSplitScreenMode = IntelligentSceneWindowManager.isSplitScreenMode(windowMode);
    this.setMaxScrollHeight();
    EventBus.getInstance().on(WINDOW_MODE_CHANGE, this.onWindowModeChange);
    IntelligentSceneDisplayUtil.registerFoldStatusChangeListener(this.foldStatusChangeCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach('EVENT_ID_LOADING', this.loadingCallback);
    EventBus.getInstance().detach('APP_INFO_LOADED', this.appInfoLoadedCallBack);
    EventBus.getInstance().detach(WINDOW_MODE_CHANGE, this.onWindowModeChange);
    IntelligentSceneDisplayUtil.unRegisterFoldStatusChangeListener(this.foldStatusChangeCallback);
  }

  private selectIndexesUpdated(): void {
    this.appGroupController?.selectIndexesUpdated(this.selectedIndexes[0]);
    EventBus.getInstance().emit(EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START);
  }

  private onSearchBarChange(value: string): void {
    if (value.length !== 0) {
      this.isSearching = true;
      this.searchItemByKeyWord(value);
      this.searchDataComplete = true;
      this.showSearchResult = true;
    } else {
      this.isSearching = false;
      this.showSearchResult = false;
    }
    this.showNoResultView = this.searchResultArray.totalCount() === 0;
  }

  private getId(item: AppInfo, index: number): string {
    let totalCount: number = this.searchResultArray.totalCount();
    let ifFirst: boolean = index === 0;
    let ifLast: boolean = index === totalCount - 1;
    return `${item.name}${item.isSelected}${ifFirst}${ifLast}`;
  }

  private isFirstItem(index: number): boolean {
    return index === 0;
  }

  private isLastItem(index: number): boolean {
    return index === this.searchResultArray.totalCount() - 1;
  }

  private searchItemByKeyWord(word: string): void {
    this.searchResultArray.clearAll();
    for (let element of this.allSearchData.getArray()) {
      if (element.label?.toUpperCase().includes(word.toUpperCase())) {
        this.searchResultArray.pushData(element);
      }
      this.searchResultArray.notifyDataReload();
    }
  }

  private onSelectedTextClick(): void {
    if (this.selectCount > 0) {
      if (!this.isShowSelected) {
        this.isShowSelected = true;
      } else {
        this.isShowSelected = false;
      }
    } else {
      this.isShowSelected = false;
    }
  }

  private setMaxScrollHeight(height?: number): void {
    let maxSize: number = Math.max(DisplayUtils.getScreenHeight(), DisplayUtils.getScreenWidth());
    if (this.isSplitScreenMinMode) {
      this.splitModeMaxScrollHeight = SPLIT_MIN_SCROLL * maxSize;
    } else {
      this.splitModeMaxScrollHeight = SPLIT_MAX_SCROLL * maxSize;
    }
    if (height && maxSize && (height / maxSize) > SPLIT_PORTRAIT_RATE) {
      this.splitModeMaxScrollHeight = height - Number(this.selectViewMarginBottom);
    }
    LogUtil.showInfo(TAG, `setMaxScrollHeight height: ${this.splitModeMaxScrollHeight}, phoneHeight: ${maxSize}, component height: ${height}`);
  }

  private closeSheetPage(isFinishEdit?: boolean): void {
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (!session) {
      LogUtil.error(`${TAG} close sheet page failed, session is empty.`);
      return;
    }
    let selectData: string = '';
    if (isFinishEdit) {
      let appConditionList: AppData[] = [];
      for (let element of this.selectAppGroups.getArray()) {
        appConditionList.push({
          bundleName: element.name,
          index: element.appIndex,
          uid: element.appInfo?.uid,
        })
      }
      try {
        selectData = JSON.stringify(appConditionList);
      } catch (error) {
        LogUtil.error(`${TAG} json stringify failed, error.message: ${error?.message}`);
      }
    }

    session.sendData({
      action: 'closeSheet',
      isFinishEdit: isFinishEdit,
      selectData: selectData,
    });
    session.terminateSelf();
  }
}