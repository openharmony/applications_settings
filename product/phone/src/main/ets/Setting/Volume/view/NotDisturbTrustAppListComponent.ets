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
import osAccount from '@ohos.account.osAccount';
import { BusinessError } from '@ohos.base';
import bundleManager from '@ohos.bundle.bundleManager';
import launcherBundleResource from '@ohos.bundle.launcherBundleManager';
import curves from '@ohos.curves';
import relationalStore from '@ohos.data.relationalStore';
import notificationManager from '@ohos.notificationManager';
import {
  PADDING_24,
  PADDING_28,
  PADDING_32,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  DefaultSettingPageModel,
  SettingPageModel,
  SettingSheetPageContext
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import {
  SettingCompState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppBundleAndUid } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import {
  FOCUS_MODE_CALLUI_BUNDLE_NAME,
  FOCUS_MODE_CLOCK_BUNDLE_NAME,
  NotDisturbTimerManager
} from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { AppInfoData, AppInfoDataGroups, AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import NotDisturbTrustAppItemComponent, {
  AppDataInfoComponent,
  AppGroupsComponent
} from './NotDisturbTrustAppItemComponent';

@Extend(Image)
function iconStyle(width: Length, height: Length, margin?: Padding) {
  .width(width)
  .height(height)
  .draggable(false)
  .syncLoad(true)
  .matchTextDirection(true)
  .margin(margin)
}

@Component
export struct NotDisturbTrustAppListComponent {
  tag: string = 'NotDisturbTrustAppListComponent: ';
  item?: object;
  pageParam?: PageParams;
  @State isSecondSelected: boolean = false;
  @State changeValue: string = '';
  @State isSearching: boolean = false;
  @State selectCount: number = 0;
  @State private appInfoGroups: AppInfoDataSource = new AppInfoDataSource();
  private bundleMap: Map<number, string> = new Map();
  private prefixMap: Map<string, AppInfoDataGroups> = new Map();
  private selectAppInfoArray: AppInfoData[] = [];
  private appDataInfoList: AppBundleAndUid[] = [];
  private sheetPageCtx?: SettingSheetPageContext;
  @State pathStack: NavPathStack = new NavPathStack();
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();
  @State loadDataComplete: boolean = false;
  @State searchDataComplete: boolean = false;
  @State searchAppGroup: AppInfoDataGroups = new AppInfoDataGroups('');
  @State searchAppInfoArray: AppInfoData[] = [];
  selectedAppGroup: AppInfoDataGroups = new AppInfoDataGroups('');
  private controller: SearchController = new SearchController();
  private selectedViewUnfolded: boolean = true;
  @State isShowSelected: boolean = false;
  private allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
  private launcherAppList: string[] = [];
  private whiteUidList: number[] = [];
  private whiteAppList: string[] = [];
  private userID: number = 100;
  private delay: number = 1000;
  private taskId: number | null = null;
  private clockAppUid: number = 0;
  private calluiAppUid: number = 0;
  private mmsAppUid: number = 0;
  @State showSearchResult: boolean = false;
  @State showNoResultView: boolean = false;

  private upDateSearchView(item: AppInfoData): void {
    if (this.isSearching) {
      this.searchAppInfoArray.forEach(element => {
        if (element.bundleName === item.bundleName && element.uid === item.uid) {
          // 属性变化触发ForEach 渲染
          element.isSelected = true;
          element.isSelected = false;
        }
      })
    }
  }

  private onAppItemClicked: (index: number, indexChild: number, item: AppInfoData) =>
  void = (index: number, indexChild: number, item: AppInfoData) => {
    this.appInfoGroups?.appInfoDataGroupsArr[index].appInfoDataGroups.forEach(element => {
      if (element.bundleName === item.bundleName && element.uid === item.uid) {
        // 属性变化触发ForEach 渲染
        element.isSelected = true;
        element.isSelected = false;
      }
    })
    if (this.selectCount == 0) {
      this.isShowSelected = false;
    }
    this.upDateSearchView(item);
  };

  private updateSelectApp(item: AppInfoData) {
    this.selectAppInfoArray.forEach(element => {
      if (element.bundleName === item.bundleName && element.uid === item.uid) {
        const index = this.selectAppInfoArray.indexOf(element);
        if (index > -1) {
          this.selectAppInfoArray.splice(index, 1)
        }
      }
    })
  }

  private onAppChildItemClicked: (selected: boolean, item: AppInfoData,
    index: number, indexChild: number) =>
  void = (selected: boolean, item: AppInfoData,
    index: number, indexChild: number) => {
    const i = this.searchAppInfoArray.indexOf(item);
    if (i > -1) {
      this.searchAppInfoArray[i].isSelected = selected;
    }
    if (selected) {
      if (this.selectAppInfoArray.indexOf(item) < 0) {
        this.selectAppInfoArray.push(item);
      }
    } else {
      this.updateSelectApp(item);
    }
    this.selectCount = this.selectAppInfoArray.length;
  };

  private async getLauncherBundleList(): Promise<void> {
    try {
      let osAccountManager = osAccount.getAccountManager();
      osAccountManager.getActivatedOsAccountLocalIds((err, dataArray) => {
        this.userID = dataArray[0];
      });
    } catch (error) {
      LogUtil.error(`${this.tag} getActivatedOsAccountLocalIds failed`);
    }
    try {
      this.allLauncherBundleLabelList = await launcherBundleResource.getAllLauncherAbilityInfo(this.userID);
    } catch (error) {
      LogUtil.info(`${this.tag} allLauncherBundleLabelList catch error: ${error?.message}`);
    }
    this.allLauncherBundleLabelList.forEach(item => {
      this.launcherAppList.push(item.elementName.bundleName)
    })
  }

  private async getAppBundleNameList(): Promise<void> {
    await this.getLauncherBundleList();
    let appFlags = bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT;
    try {
      let clockAppInfo = await bundleManager.getApplicationInfo(FOCUS_MODE_CLOCK_BUNDLE_NAME, appFlags);
      if (clockAppInfo && clockAppInfo.systemApp) {
        this.whiteUidList.push(clockAppInfo.uid);
        this.whiteAppList.push(FOCUS_MODE_CLOCK_BUNDLE_NAME);
      }
    } catch (error) {
      LogUtil.error(`${this.tag} getApplicationInfo clockAppInfo : ${(error as BusinessError).message}`);
    }
    try {
      let calluiAppInfo = await bundleManager.getApplicationInfo(FOCUS_MODE_CALLUI_BUNDLE_NAME, appFlags);
      if (calluiAppInfo && calluiAppInfo.systemApp) {
        this.whiteUidList.push(calluiAppInfo.uid);
        this.whiteAppList.push(FOCUS_MODE_CALLUI_BUNDLE_NAME);
      }
    } catch (error) {
      LogUtil.error(`${this.tag} getApplicationInfo calluiAppInfo : ${(error as BusinessError).message}`);
    }
    let data = await notificationManager.getAllNotificationEnabledBundles();
    data.forEach(element => {
      let bundleName = JSON.stringify(element.bundle).replace(/"/g, '');
      let uid = parseInt(JSON.stringify(element.uid).replace(/"/g, ''));
      if (this.launcherAppList.includes(bundleName) && !this.whiteAppList.includes(bundleName)) {
        this.bundleMap.set(uid, bundleName);
      }
    });
  }

  private async getAllNotificationEnableAppInfo(): Promise<void> {
    for (let item of this.bundleMap) {
      let appInfo = new AppInfoData(item[1], item[0]);
      let ret = await appInfo.init();
      if (!ret) {
        continue;
      }
      this.appDataInfoList.forEach(element => {
        if (element.bundleName === item[1] && element.uid === item[0]) {
          appInfo.isSelected = true;
          this.selectAppInfoArray.push(appInfo);
        }
      })
      let appGroup = this.prefixMap.get(appInfo.prefix);
      if (appGroup !== undefined) {
        appGroup.setData(appInfo);
      } else {
        let group = new AppInfoDataGroups(appInfo.prefix);
        group.setData(appInfo);
        this.prefixMap.set(appInfo.prefix, group);
        this.appInfoGroups.setData(group);
      }
    }
    this.selectCount = this.selectAppInfoArray.length;
    this.appInfoGroups.sort();
  }

  private async getTrustAppList(): Promise<void> {
    this.appDataInfoList = await NotDisturbTimerManager.getInstance().queryTrustAppDataInfo();
    this.selectCount = this.appDataInfoList.length;
  }

  private async removeTrustAppList(): Promise<void> {
    let templates: notificationManager.DoNotDisturbProfile[] = [
      {
        id: 1,
        name: 'Not disturb'
      }
    ]
    await notificationManager.removeDoNotDisturbProfile(templates).then(() => {
      LogUtil.info(`${this.tag} removeDoNotDisturbProfile success.`);
    }).catch((error: BusinessError) => {
      console.error(`${this.tag} removeDoNotDisturbProfile fail: ${error?.message}`);
    });
  }

  private async updateTrustListCount(item: SettingItemModel): Promise<void> {
    let res: ResourceStr = await ResourceUtil.getString($r('app.string.none_selected_app'));
    let count = this.selectAppInfoArray.length;
    if (count >= 1) {
      res = $r('app.plural.user_select_app', count, count);
    }

    item?.onItemEvent?.(new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
      { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: res } } as SettingResultState]]));
  }

  private async closeSheetPage(): Promise<void> {
    if (this.sheetPageCtx?.itemComp) {
      let item: SettingItemModel = this.sheetPageCtx.itemComp as SettingItemModel;
      item?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingCompState
      ]]));
      await this.updateTrustListCount(item);
      LogUtil.info(`${this.tag} click to close sheet page`);
    }
  }

  private async saveTrustAppListToDataBase(): Promise<void> {
    let appDataInfoList: relationalStore.ValuesBucket[] = [];
    this.selectAppInfoArray.forEach(appInfo => {
      appDataInfoList.push({ bundleName: appInfo.bundleName, uid: appInfo.uid })
    })
  }

  private async setTrustAppList(): Promise<void> {
    let trustList: notificationManager.BundleOption[] = [];
    for (let index = 0; index < this.whiteUidList.length; index++) {
      trustList.push({ bundle: this.whiteAppList[index], uid: this.whiteUidList[index] }); //默认添加白名单
    }
    this.selectAppInfoArray.forEach(appInfo => {
      trustList.push({ bundle: appInfo.bundleName, uid: appInfo.uid });
    })
    await this.saveTrustAppListToDataBase();
    let templates: notificationManager.DoNotDisturbProfile[] = [
      {
        id: 1,
        name: 'Not disturb',
        trustlist: trustList
      }
    ]
    await notificationManager.addDoNotDisturbProfile(templates).then(() => {
      LogUtil.info(`${this.tag} addDoNotDisturbProfile success.`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} addDoNotDisturbProfile fail: ${error?.message}`);
    });
  }

  async aboutToAppear(): Promise<void> {
    if (this.taskId) {
      clearTimeout(this.taskId);
    }
    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    await this.getTrustAppList();
    await this.getAppBundleNameList();
    await this.getAllNotificationEnableAppInfo();
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
    }

    this.taskId = setTimeout(()=> {
      this.loadDataComplete = true;
      this.taskId = null;
    }, this.delay);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    if (this.taskId) {
      clearTimeout(this.taskId);
    }
    this.appInfoGroups.releaseResource();
  }

  @Builder
  sheetTitleSearchView(): void {
    Column() {
      Image($r('app.media.back_light'))
        .fillColor($r('sys.color.icon_primary'))
        .objectFit(ImageFit.Contain)
        .width('24vp')
        .height('24vp')
    }
    .margin({ end: PADDING_8 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(40)
    .height(40)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .onClick(() => {
      this.isSearching = false;
      this.changeValue = '';
      this.searchDataComplete = false;
      this.searchAppInfoArray.slice(0);
      this.controller.stopEditing();
    })
  }

  @Builder
  sheetTitle(): void {
    Row() {
      if (this.isSearching) {
        this.sheetTitleSearchView();
      }
      Text($r('app.string.select_app'))
        .fontSize(`20vp`)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_close'))
          .iconStyle(18, 18)
          .fillColor($r('sys.color.icon_primary'))
      }
      .accessibilityText($r('app.string.dialog_disable'))
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .margin({ start: PADDING_24 })
      .onClick(() => {
        let item: SettingItemModel = this.sheetPageCtx?.itemComp as SettingItemModel;
        item?.onItemEvent?.(new Map([[
          SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingCompState
        ]]));
      })
    }
    .width('100%')
    .height('56vp')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .margin({ top: $r('sys.float.padding_level4') })
  }

  private onSelectedTextClick(): void {
    if (this.selectCount > 0) {
      if (!this.isShowSelected) {
        this.selectedAppGroup.appInfoDataGroups.splice(0);
        this.selectAppInfoArray.sort((a, b) => a.pinyin.localeCompare(b.pinyin));
        this.selectAppInfoArray.forEach(item => {
          this.selectedAppGroup.appInfoDataGroups.push(item);
        })
        this.isShowSelected = true;
      } else {
        this.isShowSelected = false;
      }
    } else {
      this.isShowSelected = false;
    }
  }

  @Builder
  toolBarView(bottomHeight: number): void {
    Column() {
      RelativeContainer() {
        Text($r('app.plural.selected_app', this.selectCount, this.selectCount))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectCount > 0 ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .maxFontScale(2.0)
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .constraintSize({ minHeight: '19vp'})
          .onClick(() => {
            this.onSelectedTextClick();
          })

        Button({ type: ButtonType.Capsule, buttonStyle: ButtonStyleMode.EMPHASIZED }) {
          Text($r('app.string.done'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2.0)
            .textAlign(TextAlign.Center)
            .constraintSize({minWidth: '72vp', minHeight: '28vp'})
            .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
        }
        .onClick(async () => {
          await this.removeTrustAppList()
          await this.setTrustAppList();
          await this.closeSheetPage();
        })
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
      }
    }
    .width('100%')
    .height(88)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      top: $r('sys.float.padding_level6'),
      bottom: bottomHeight
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  selectedView(): void {
    Stack() {
      Column() {
      }
      .backgroundColor('#19000000')
      .height('100%')
      .width('100%')
      .visibility(this.selectedViewUnfolded === true ? Visibility.Visible : Visibility.Hidden)
      .onClick(() => {
        this.isShowSelected = false;
      })

      Column() {
        NotDisturbTrustAppItemComponent({
          data: this.selectedAppGroup,
          selectAppInfoArray: this.selectAppInfoArray,
          onAppItemClicked: this.onAppItemClicked,
          onClickRemoveItem: true,
          selectCountChild: this.selectCount
        })
          .width('90%')

      }
      .backgroundColor($r('sys.color.comp_background_gray'))
      .width('100%')
      .margin({ top: 265, bottom: 88 })
      .alignItems(HorizontalAlign.Center)
      .clip(true)
      .padding({
        top: $r('sys.float.padding_level2'),
        left: $r('sys.float.padding_level2'),
        right: $r('sys.float.padding_level2')
      })
      .borderRadius({
        topLeft: 32,
        topRight: 32
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
  searchListView(): void {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.searchAppInfoArray, (item: AppInfoData, index: number) => {
          ListItem() {
            AppDataInfoComponent({
              item: item,
              index: index,
              count: this.searchAppInfoArray.length,
              onAppChildItemClicked: this.onAppChildItemClicked
            })
          }
        }, (item: AppInfoData) => JSON.stringify(item))
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .layoutWeight(1)
    .transition(TransitionEffect.OPACITY.animation({
      duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
    }))
    .visibility(this.showSearchResult ? Visibility.Visible : Visibility.Hidden)
  }

  private onSearchBarChange(value: string): void {
    if (value.length !== 0) {
      this.searchAppGroup = this.appInfoGroups.searchItemByKeyWord(value);
      if (this.searchAppGroup.appInfoDataGroups.length === 0) {
        this.searchAppGroup.appInfoDataGroups.slice(0);
      }
      this.searchDataComplete = true;
      this.showSearchResult = true;
    } else {
      this.searchAppGroup.appInfoDataGroups.splice(0);
      this.showSearchResult = false;
    }
    this.searchAppInfoArray = this.searchAppGroup.appInfoDataGroups;
    this.showNoResultView = this.searchAppInfoArray.length === 0;
  }

  @Builder
  searchBarView(): void {
    Search({ value: $$this.changeValue, placeholder: $r('app.string.search_app'), controller: this.controller })
      .searchIcon({
        color: $r('sys.color.icon_secondary'),
      })
      .margin({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level4')
      })
      .constraintSize({
        minHeight: 40
      })
      .width('92%')
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({
        size: ($r('sys.float.Body_L')),
        weight: FontWeight.Regular
      })
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .enableKeyboardOnFocus(false)
      .onChange((value: string) => {
        this.onSearchBarChange(value);
      })
      .onClick(() => {
        this.isSearching = true;
      })
      .enabled(true)
  }

  @Builder
  normalView(): void {
    if (this.loadDataComplete) {
      Row() {
        Text($r('app.string.all_app'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .constraintSize({
        minHeight: 56
      })
      .padding({ start: PADDING_28, top: PADDING_8, end: PADDING_32 })
      .enabled(true)

      AppGroupsComponent({
        appGroups: this.appInfoGroups,
        selectAppInfoArray: this.selectAppInfoArray,
        selectCount: this.selectCount
      })
        .padding({ bottom: 265 })
    } else {
      Column() {
        LoadingProgress()
          .color($r('sys.color.icon_secondary'))
          .size({ height: '72vp', width: '72vp' })
          .visibility(this.loadDataComplete ? Visibility.Hidden : Visibility.Visible)
          .id('loading_progress_')

        Text($r('app.string.app_loading'))
          .padding({ top: '16vp' })
      }
      .height('100%')
      .offset({ y: '30%' })
    }
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
    .height('100%')
    .width('90%')
  }

  @Builder
  contentsView(): void {
    Column() {
      this.sheetTitle();
      this.searchBarView();
      if (!this.isSearching) {
        this.normalView();
      } else {
        this.searchView();
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)

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
        this.contentsView();
      }
      .alignContent(Alignment.BottomStart)

      if (this.loadDataComplete) {
        this.toolBarView(34)
      }
    }
    .alignContent(Alignment.BottomStart)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width('100%')
    .height('100%')
  }
}