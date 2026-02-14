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

import display from '@ohos.display';
import curves from '@ohos.curves';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  PADDING_12,
  PADDING_16,
  PADDING_24,
  PADDING_26,
  PADDING_4,
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppInfoDataSource } from './model/bean/AppInfoDataSource';
import { AppGroupsComponent } from './view/AppGroupsComponent';
import { AppSwitchComponent } from './view/AppSwitchComponent';
import { AppListDataInfoComponent } from './view/AppListDataInfoComponent';
import { AppData, AppInfo } from './model/bean/AppInfo';
import { AppSelectedGroupsComponent } from './view/AppSelectedGroupsComponent';
import { SheetTittleComponent } from './view/SheetTittleComponent';
import { EmptyListComponent } from './view/EmptyListComponent';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import {
  IntelligentSceneWindowManager,
  WINDOW_MODE_CHANGE,
  SPLIT_1_3_RATE,
  SPLIT_MIN_SCROLL,
  SPLIT_MAX_SCROLL,
  SPLIT_PORTRAIT_RATE,
} from './manager/IntelligentSceneWindowManager';
import { IntelligentSceneFontScaleUtil } from './utils/IntelligentSceneFontScaleUtil';
import {
  FULL_DISPLAY_MODE,
  IntelligentSceneDisplayUtil,
  SYSTEM_TOOLBAR_HEIGHT,
} from './utils/IntelligentSceneDisplayUtil';

/* instrument ignore file */
const TAG: string = 'IntelligentSceneAppSelectComponent : ';
const SPLIT_PORTRAIT_BOTTOM: number = 65;

@Entry
@Component
export struct IntelligentSceneAppSelectComponent {
  private controller: SearchController = new SearchController();
  private isAdd: boolean = false;
  @State appGroups: AppInfoDataSource = new AppInfoDataSource();
  @State loadDataComplete: boolean = false;
  @State selectCount: number = 0;
  @State changeValue: string = '';
  @State isSearching: boolean = false;
  @State isOpen: boolean = false;
  @State searchDataComplete: boolean = false;
  @State showNoResultView: boolean = false;
  @State showSearchResult: boolean = false;
  @State isShowSelected: boolean = false;
  @State selectAppGroups: AppInfoDataSource = new AppInfoDataSource();
  @State searchArray: AppInfo[] = [];
  @State isSplitScreenMode: boolean = false;
  @State isListEmpty: boolean = false;
  // 分屏 1/3 模式
  @State isSplitScreenMinMode: boolean = false;
  @State splitModeMaxScrollHeight: Length = '100%';
  @State navigationBarHeight: number = DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ||
    this.isDeviceExpandState() ? 0 : SYSTEM_TOOLBAR_HEIGHT;
  private dialogControllerConfirm?: CustomDialogController;
  private savedAppCount: number = 0;
  private baseHeight: number = 52;
  @State toolBarHeight: number = 0;
  private scroller: Scroller = new Scroller();
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
  private onSelectedAppItemClicked: (index: number, item: AppInfo) => void = (index: number, item: AppInfo) => {
    this.updateSelectApp(item);
    this.selectCount = this.selectAppGroups.totalCount();
    if (this.selectCount == 0) {
      this.isShowSelected = false;
    }
    EventBus.getInstance().emit('intelligenceAppInfoRefresh', item.name, item.label);
  };
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
  private loadingCallback = (isLoading: boolean) => {
    this.loadDataComplete = !isLoading;
  };
  private appInfoLoadedCallBack = () => {
    let totalCount: number = this.appGroups.totalCount();
    if (totalCount > 0) {
      this.loadDataComplete = true;
    }
    this.isListEmpty = totalCount === 0;
    for (let i = 0; i < totalCount; i++) {
      if (this.appGroups.getArray()[i].isSelected) {
        this.addToSelectedGroups(this.appGroups.getArray()[i]);
      }
    }
    this.selectCount = this.selectAppGroups.totalCount();
    this.savedAppCount = this.selectCount;
  };
  private onWindowModeChange = (windowMode: string) => {
    LogUtil.info(`${TAG} onWindowModeChange: ${windowMode}`);
    this.isSplitScreenMode = IntelligentSceneWindowManager.isSplitScreenMode(windowMode);
  };
  private foldStatusChangeCallback = (foldStatus: display.FoldDisplayMode) => {
    LogUtil.info(`${TAG} foldStatusChangeCallback ${foldStatus}`);
    if (this.isDeviceExpandState(foldStatus)) {
      this.navigationBarHeight = 0;
      return;
    }
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN) {
      // 双折叠折为单屏，三折叠折为单屏
      this.navigationBarHeight = SYSTEM_TOOLBAR_HEIGHT;
      return;
    }
  };

  @Builder
  switchMenu(): void {
    AppSwitchComponent({
      isOn: this.isOpen,
    })
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
        AppSelectedGroupsComponent({
          appGroups: this.selectAppGroups,
          onAppItemClicked: this.onSelectedAppItemClicked,
        })
          .width('100%')
      }
      .backgroundColor($r('app.color.app_sheet_background'))
      .width('100%')
      .constraintSize({
        maxHeight: '60%',
      })
      .margin({ bottom: this.toolBarHeight })
      .alignItems(HorizontalAlign.Center)
      .clip(true)
      .padding({
        top: PADDING_4,
        start: PADDING_12,
        end: PADDING_26
      })
      .borderRadius({
        topLeft: $r('sys.float.corner_radius_level10'),
        topRight: $r('sys.float.corner_radius_level10')
      })
      .clip(true)
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
          .maxLines(2)
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
          end: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
      }
      .height(this.baseHeight)

      if (!this.isAdd && !this.isSplitScreenMinMode) {
        Button() {
          Text($r('app.string.delete_condition'))
            .maxFontScale(IntelligentSceneFontScaleUtil.getToolbarMaxFontSize(getContext(this), this.selectCount))
            .maxLines(1)
            .ellipsisMode(EllipsisMode.END)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
        }
        .type(ButtonType.Capsule)
        .role(ButtonRole.ERROR)
        .enabled(true)
        .buttonStyle(ButtonStyleMode.NORMAL)
        .width('100%')
        .constraintSize({
          minHeight: 40,
          maxHeight: 48,
        })
        .margin({
          top: PADDING_4,
          bottom: PADDING_16
        })
        .onClick(() => {
          this.showDeleteDialog();
        })
      }
    }
    .onAreaChange((oldArea, newArea) => {
      this.toolBarHeight = newArea?.height as number || 0;
    })
    .width('100%')
    .backgroundColor($r('app.color.app_sheet_background'))
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: this.navigationBarHeight
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  searchBarView(): void {
    Search({ value: $$this.changeValue, placeholder: $r('app.string.search_app'), controller: this.controller })
      .margin({
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level4')
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
    .width('100%')
    .height('100%')
  }

  @Builder
  normalView(): void {
    EmptyListComponent({
      loadDataComplete: this.loadDataComplete
    })
      .visibility(this.isSearching ? Visibility.None : Visibility.Visible)

    AppGroupsComponent({
      appGroups: this.appGroups,
      onAppItemClicked: this.onAppItemClicked,
    })
      .padding({ bottom: this.toolBarHeight })
      .layoutWeight(1)
      .visibility(this.loadDataComplete && !this.isSearching ? Visibility.Visible : Visibility.None)

    if (!this.loadDataComplete && !this.isSearching) {
      Column() {
        LoadingProgress()
          .color($r('sys.color.icon_secondary'))
          .size({ height: '72vp', width: '72vp' })
          .id('loading_progress_')

        Text($r('app.string.app_loading'))
          .padding({ top: '16vp' })
      }
      .justifyContent(FlexAlign.Center)
      .height(this.isSplitScreenMode ? 200 : 0)
      .layoutWeight(this.isSplitScreenMode ? 0 : 1)
      .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    }
  }

  @Builder
  searchListView(): void {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.searchArray, (item: AppInfo, index: number) => {
          ListItem() {
            AppListDataInfoComponent({
              item: item,
              index: index,
              totalCount: this.searchArray.length,
              onAppItemClicked: this.onSearchItemClicked,
            })
          }
        }, (item: AppInfo) => item.name)
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring, {
        alwaysEnabled: !this.isSplitScreenMode,
      })
      .scrollBar(BarState.Off)
      .height('100%')
      .padding({
        start: PADDING_12,
        end: PADDING_24,
      })
    }
    .layoutWeight(1)
    .transition(TransitionEffect.OPACITY.animation({
      duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
    }))
    .visibility(this.showSearchResult ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder
  contentsView(): void {
    Column() {
      SheetTittleComponent({
        isSearching: this.isSearching,
        closeSheetPage: this.closeSheetPage,
        title: $r('app.string.by_application'),
        clickBackImage: () => {
          this.isSearching = false;
          this.changeValue = '';
          this.searchDataComplete = false;
          this.controller.stopEditing();
        },
      })

      Scroll(this.scroller) {
        Column() {
          if (!this.isSearching && !this.isAdd) {
            this.switchMenu()
          }
          this.searchBarView()
          this.normalView()
          if (this.isSearching) {
            this.searchView()
          }
        }
        .height(this.isSplitScreenMode ? this.splitModeMaxScrollHeight : '100%')
      }
      .width('100%')
      .padding({
        bottom: this.isSplitScreenMinMode ? 0 : 64,
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

  build() {
    Stack() {
      Stack() {
        this.contentsView()
      }
      .alignContent(Alignment.BottomStart)

      if (this.loadDataComplete && !this.isListEmpty) {
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
    if ((AppStorage.get('isAdd') as boolean) === true) {
      this.isAdd = true;
    }
    if ((AppStorage.get('enabled') as boolean) === true) {
      this.isOpen = true;
    }
    EventBus.getInstance().on('EVENT_ID_LOADING', this.loadingCallback);
    EventBus.getInstance().on('APP_INFO_LOADED', this.appInfoLoadedCallBack);
    const windowMode: string = IntelligentSceneWindowManager.getWindowMode();
    this.isSplitScreenMode = IntelligentSceneWindowManager.isSplitScreenMode(windowMode);
    this.setMaxScrollHeight();
    this.baseHeight = IntelligentSceneFontScaleUtil.isHUGE4Mode(getContext(this)) ? 58 : 52;
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

  private addToSelectedGroups(item: AppInfo): void {
    this.selectAppGroups.getArray().push(item);
    this.selectAppGroups.getArray().sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
    this.selectAppGroups.notifyDataReload();
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
    this.showNoResultView = this.searchArray.length === 0;
  }

  private updateSelectApp(item: AppInfo) {
    this.selectAppGroups.getArray().forEach(element => {
      if (element.name === item.name) {
        const index = this.selectAppGroups.getArray().indexOf(element);
        if (index > -1) {
          this.selectAppGroups.removeDataByIndex(index);
        }
      }
    })
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

  private searchItemByKeyWord(word: string): void {
    let appEntries: AppInfo[] = this.appGroups.getArray();
    this.searchArray = [];
    for (let element of appEntries) {
      if (element.label?.toUpperCase().includes(word.toUpperCase())) {
        this.searchArray.push(element);
      }
    }
  }

  private closeSheetPage(isFinishEdit?: boolean): void {
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (session === undefined) {
      return;
    }
    let selectData: string = '';
    if (isFinishEdit) {
      let appConditionList: AppData[] = [];
      for (let element of this.selectAppGroups.getArray()) {
        let appData: AppData = {
          bundleName: element.name,
          index: element.appIndex,
        };
        appConditionList.push(appData);
      }
      try {
        selectData = JSON.stringify({
          enable: this.isAdd ? true : this.isOpen,
          appConditionList,
        });
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

  private setMaxScrollHeight(height?: number): void {
    let maxSize: number = Math.max(DisplayUtils.getScreenHeight(), DisplayUtils.getScreenWidth());
    if (this.isSplitScreenMinMode) {
      this.splitModeMaxScrollHeight = SPLIT_MIN_SCROLL * maxSize;
    } else {
      this.splitModeMaxScrollHeight = SPLIT_MAX_SCROLL * maxSize;
    }
    if (height && maxSize && (height / maxSize) > SPLIT_PORTRAIT_RATE) {
      this.splitModeMaxScrollHeight = height - SPLIT_PORTRAIT_BOTTOM;
    }
    LogUtil.showInfo(TAG, `setMaxScrollHeight height: ${this.splitModeMaxScrollHeight}, phoneHeight: ${maxSize}, component height: ${height}`);
  }

  private isDeviceExpandState(displayMode?: display.FoldDisplayMode): boolean {
    try {
      let foldDisplayMode: display.FoldDisplayMode = displayMode ?? display.getFoldDisplayMode();
      // 双折叠完全展开，三折叠展开两屏或三屏
      return foldDisplayMode === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL ||
        foldDisplayMode === FULL_DISPLAY_MODE;
    } catch (error) {
      LogUtil.error(`${TAG} isDeviceExpandState failed: ${error?.code}, ${error?.message}`);
    }
    return false;
  }

  private showDeleteDialog(): void {
    if (!this.dialogControllerConfirm) {
      this.dialogControllerConfirm = new CustomDialogController({
        autoCancel: false,
        builder: AlertDialog({
          content: $r('app.string.confirm_del_clone_app',
            $r('app.plural.user_select_app', this.savedAppCount, this.savedAppCount)),
          primaryButton: {
            value: $r('app.string.dialog_cancel'),
            action: () => {
            },
          },
          secondaryButton: {
            value: $r('app.string.delete'),
            role: ButtonRole.ERROR,
            action: () => {
              this.selectAppGroups.clearAll();
              this.closeSheetPage(true);
            }
          },
        }),
      });
    }
    this.dialogControllerConfirm?.open();
  }
}