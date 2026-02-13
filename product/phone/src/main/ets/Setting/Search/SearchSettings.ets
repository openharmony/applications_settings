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

import { curves, LengthUnit } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import CommonEventManager from '@ohos.commonEventManager';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_16,
  PADDING_24,
  PADDING_6,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { HiSysSearchEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { RenderItemInfo } from '@ohos/settings.search/src/main/ets/model/type';
import { SearchCheckUtil } from '@ohos/settings.search/src/main/ets/util/SearchCheckUtil';
import { HistoryDataDto, SearchSettingsController } from './controller/SearchSettingsController';
import lazy { SearchSettingsResultCard } from './model/SearchSettingsResultCard';
import {
  changePrivacySearchItem
} from '../../pages/biometricsandpassword/module/privacyPassword/common/PrivacyPassword';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';

/* instrument ignore file */
const TAG = 'SearchSettings';
const SEARCH_INTERVAL: number = 300;
const MAX_SEARCH_LEN: number = 128;
const FOCUS_SEARCH_DELAY: number = 10;
const SEARCH_FILED_ID: string = '__SearchField__searchComponent';

@Component
export struct SearchSettingsComponent {
  controller: SearchController = new SearchController();
  scroller: Scroller = new Scroller();
  searchController: SearchSettingsController = new SearchSettingsController();
  private timer: number = 0;
  private onBackButtonClicked: () => void = () => {
    return
  };
  @State changeValue: string = '';
  @State submitValue: string = '';
  @State historyList: HistoryDataDto[] = [];
  @State resultList: RenderItemInfo[] = [];
  @State isInSearching: boolean = true;
  @State buttonBackGroundColor: Color | ResourceStr = Color.Transparent;
  hoverColor: ResourceStr | ResourceColor = $r('sys.color.ohos_id_color_hover');
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED,
    ]
  };
  private localeChange: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} locale changed: ${data?.event}`);
    if (data?.event !== CommonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED) {
      return;
    }

    this.searchController.inputChangeEvent(this.changeValue, 'onChange').then((resultList) => {
      this.resultList = resultList;
      if (this.changeValue.length !== 0) {
        this.isInSearching = false;
      }
    })
  })

  aboutToAppear() {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.searchController.getHistoryData().then(res => {
      this.historyList = res;
    });

    import('@ohos/settings.search/src/main/ets/controller/SearchController').then(
      (controller) => {
        controller.SearchDataController.updateSearchData();
        SearchCheckUtil.isDevelopModeSupport().then(support => {
          LogUtil.info(`${TAG} isDevelopModeSupport: ${support}`);
          controller.SearchDataController.getInstance().updateChildItemSearchStatus('developer_options',
            support, ['debug_outer_app']);
        });
      }
    );
    this.localeChange.registerCommonEvent();
    let entryKeyList: string[] = [];

    import('@ohos/settings.search/src/main/ets/controller/SettingPageDescController').then(
      (controller) => controller.SettingPageDescController.getParentPage(NavEntryKey.WIFI_ENTRY, entryKeyList));

    import('@ohos/settings.common/src/main/ets/passwordManager/PasswordManager').then(
      (passwordManager) => passwordManager.PasswordManager.updateEdmPolicy());

    this.initSearchSession();
    changePrivacySearchItem();
    emitter.on({
      eventId: EVENT_ID_SETTING_SEARCH_BACK,
    }, (eventData: emitter.EventData) => {
      this.onSearchBackClick();
    })
  }

  onNavigationModeChange(): void {
    if (this.navigationMode === NavigationMode.Split) {
      // 在搜索页监听到分栏变化的时候，如果路由为空则push默认页面
      if (this.pathInfos.size() === 0) {
        LogUtil.showInfo(TAG, 'searchSettings onNavigationModeChange to split push default page.');
        PageRouter.push(NavEntryKey.ABOUT_DEVICE_ENTRY);
        AppStorage.setOrCreate('currentHomeKey', NavEntryKey.ABOUT_DEVICE_ENTRY);
      }
      setTimeout(() => {
        focusControl.requestFocus('searchComponent');
      }, FOCUS_SEARCH_DELAY);
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.localeChange.unRegisterCommonEvent();
    this.endSearchSession();
    emitter.off(EVENT_ID_SETTING_SEARCH_BACK);
  }

  private async initSearchSession(): Promise<void> {
    // try {
    //   const searchSession: search.SearchSession = await search.beginSearch([]);
    //   AppStorage.setOrCreate<search.SearchSession>('SettingsSearchSession', searchSession);
    // } catch (err) {
    //   LogUtil.showError(TAG, `initSearchSession error: ${err?.message}`);
    // }
  }

  private async endSearchSession(): Promise<void> {
    // try {
    //   let searchSession: search.SearchSession =
    //     AppStorage.get<search.SearchSession>('SettingsSearchSession') as search.SearchSession;
    //   if (!CheckEmptyUtils.isEmpty(searchSession)) {
    //     await search.endSearch(searchSession);
    //   }
    // } catch (err) {
    //   LogUtil.showError(TAG, `endSearchSession error: ${err?.message}`);
    // }
  }

  private onSearchBackClick(): void {
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    HiSysEventUtil.reportButtonEvent(TAG, 'backHomePage');
    this.onBackButtonClicked();
  }

  private processSubmitEvent(searchValue: string, event?: SubmitEvent): void {
    if (searchValue.trim().length === 0) {
      this.isInSearching = true;
      // 搜索框没有内容的情况下点击搜索, 软键盘不用收起
      event?.keepEditableState();
    }

    this.submitValue = searchValue;
    this.searchController.inputChangeEvent(this.submitValue, 'onSubmit')
      .then((resultList) => {
        this.resultList = resultList;
        if (this.changeValue.length !== 0) {
          this.isInSearching = false;
        }
      })
  }

  private processChangeEvent(searchValue: string): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSearchEventGroup.SEARCH_INPUT_VALUE, '');
    if (searchValue.trim().length === 0) {
      // 清空搜索内容时不需要查询，避免在SEARCH_INTERVAL时间间隔内清空了内容，但上一次输入的内容依然会去搜索
      clearTimeout(this.timer);
      HiSysEventUtil.reportButtonEvent(TAG, 'clearSearchValue');
      this.changeValue = '';
      this.isInSearching = true;
      this.searchController.getHistoryData().then(res => {
        this.historyList = res;
      });
      this.resultList = [];
      return;
    }

    clearTimeout(this.timer);
    this.changeValue = searchValue;
    this.timer = setTimeout(() => {
      this.searchController.inputChangeEvent(this.changeValue, 'onChange').then((resultList) => {
        if (this.changeValue.length !== 0) {
          this.resultList = resultList;
          this.isInSearching = false;
        }
      })
      this.timer = 0;
    }, SEARCH_INTERVAL);
  }

  private onSearchHistoryClick(item: HistoryDataDto): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSearchEventGroup.QUERY_SEARCH_HISTORY_DATA, '');
    this.changeValue = item.query;
    this.searchController.getSettingsData(this.changeValue);
    AccessibilityUtils.requestFocusAccessibilityWithBundleName(SEARCH_FILED_ID);
  }

  @Builder
  searchBackButton(): void {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph($r('sys.symbol.chevron_backward'))
        .width($r('app.float.height_24'))
        .height($r('app.float.height_24'))
        .draggable(false)
        .fontSize($r('app.float.height_24'))
        .fontColor([$r('sys.color.ohos_id_color_primary')])
    }
    .id('searchBackButton')
    .draggable(false)
    .width('40vp')
    .height('40vp')
    .margin({
      start: PADDING_16,
      end: PADDING_8,
    })
    .backgroundColor($r('sys.color.ohos_id_color_text_field_sub_bg'))
    .accessibilityText($r('app.string.back_to_parent_menu'))
    .onClick(() => {
      this.controller.stopEditing()
      this.onSearchBackClick();
    })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({
        duration: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), delay: 200
      }),
      TransitionEffect.OPACITY.animation({
        duration: 200, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
      }),
    ))
  }

  @Builder
  searchComponent(): void {
    Search({
      value: this.changeValue,
      placeholder: $r('app.string.set_search_terms'),
      controller: this.controller
    })
      .id('searchComponent')
      // .focusable(this.searchFocus)
      .geometryTransition('SEARCH_ONE_SHOT_ID', { follow: true })
      .width('calc(100% - 16vp - 16vp - 48vp)')
      .backgroundColor($r('sys.color.ohos_id_color_text_field_sub_bg'))
      .placeholderColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
      .textFont({ size: $r('sys.float.Body_L') })
      .maxLength(MAX_SEARCH_LEN)
      .margin({
        end: PADDING_16,
        top: PADDING_8,
        bottom: PADDING_8
      })
      .onAppear(() => {
        focusControl.requestFocus('searchComponent');
        AccessibilityUtils.requestFocusAccessibilityWithBundleName(SEARCH_FILED_ID);
      })
      .onSubmit((value: string, event?: SubmitEvent) => {
        this.processSubmitEvent(value, event);
      })
      .onChange((value: string) => {
        this.processChangeEvent(value);
      })
      .defaultFocus(true)
  }

  @Builder
  searchHistoryTitle(): void {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text($r('app.string.search_history'))
        .fontSize($r('sys.float.ohos_id_text_size_sub_title1'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .maxFontScale(2)
      Button({ stateEffect: false }) {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize('24vp')
          .draggable(false)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .backgroundColor(this.buttonBackGroundColor)
      .accessibilityText($r('app.string.clear_history_search'))
      .onClick(() => {
        HiSysEventUtil.reportButtonEvent(TAG, 'clear history words');
        this.historyList = [];
        this.searchController.delHistoryData();
        AccessibilityUtils.requestFocusAccessibilityWithBundleName(SEARCH_FILED_ID);
      })
      .buttonStyle(ButtonStyleMode.TEXTUAL)
      .type(ButtonType.Normal)
      .width(32)
      .height(32)
      // image与页面的边距为栅格边距，按压态的时候，超出的部分与边距重叠)
      .margin({
        end: { value: -4, unit: LengthUnit.VP },
        bottom: { value: 4, unit: LengthUnit.VP }
      })
      .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
      .accessibilityLevel('yes')
      .flexShrink(0)
      .onHover((isHover) => {
        if (isHover) {
          this.buttonBackGroundColor = this.hoverColor
        } else {
          this.buttonBackGroundColor = Color.Transparent
        }
      })
      .stateStyles({
        pressed: this.pressedStyle
      })
    }
    .width('calc(100% - 32vp)')
    .margin({
      top: PADDING_24,
      end: PADDING_16,
      bottom: PADDING_8,
      start: PADDING_16
    })
  }

  @Styles
  pressedStyle() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderWidth(0)
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
  }

  @Builder
  searchHistoryContent(): void {
    Scroll(this.scroller) {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, alignContent: FlexAlign.Start }) {
        ForEach(this.historyList, (item: HistoryDataDto, index?: number) => {
          Text(`${item.query}`)
            .fontSize('12fp')
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .constraintSize({ minWidth: $r('app.float.margin_32'), minHeight: '28vp' })
            .textAlign(TextAlign.Center)
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .maxFontScale(2)
            .maxLines(1)
            .margin({
              top: PADDING_8,
              end: PADDING_8
            })
            .stateStyles({
              pressed: this.pressedStyle
            })
            .padding({
              top: PADDING_6,
              end: PADDING_8,
              bottom: PADDING_6,
              start: PADDING_8
            })
            .borderRadius('14vp')
            .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
            .onClick(() => {
              this.onSearchHistoryClick(item);
            })
        })
      }
      .clip(true)
    }
    .width('calc(100% - 32vp)')
    .height('calc(100% - 79fp)')
    .margin({
      start: PADDING_16,
      end: PADDING_16
    })
    .align(Alignment.TopStart)
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ alignItems: ItemAlign.Center }) {
          this.searchBackButton();
          this.searchComponent();
        }

        Column() {
          if (this.resultList.length === 0 && this.isInSearching) {
            if (this.historyList.length > 0 && this.changeValue.length === 0) {
              this.searchHistoryTitle();
              this.searchHistoryContent();
            }
          } else {
            SearchSettingsResultCard({
              searchResultList: this.resultList,
              searchString: this.changeValue
            })
          }
        }
        .size({ width: '100%', height: '100%' })
        .onTouch((event: TouchEvent) => {
          if (event?.type == TouchType.Down) {
            this.controller.stopEditing();
          }
        })
      }
      .size({ width: '100%', height: '100%' })
      .transition(TransitionEffect.translate({ y: 64 }))
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .transition(TransitionEffect.OPACITY)
  }
}