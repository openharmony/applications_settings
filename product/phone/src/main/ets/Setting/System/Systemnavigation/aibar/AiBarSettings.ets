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
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import settings from '@ohos.settings';
import { LengthMetrics } from '@kit.ArkUI';
import { SwitchItem } from './model/SwitchItem';
import AiBarSwiper from './view/AiBarSwiper';
import { SCBGestureNavSetManager } from './SCBGestureNavSetManager';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { FloatingNavigationExchangeView } from './view/FloatingnavigationExchangeView';
import { NavSwitchType } from './model/NavSwitchType';
import {
  AI_BAR_TYPE,
  FLOATING_NAVIGATION_TYPE,
  SWITCH_TERTIARY_FONTCOLOR,
  SWITCH_TITLE_FONTCOLOR
} from './viewmodel/AiBarSwitchManager';
import { AiBarSwitchManager } from './viewmodel/AiBarSwitchManager';
import { FloatingNavigationBallView } from './view/FloatingNavigationBallView';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types'
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

const TAG: string = 'AiBar-Setting-UIExtensionAbility';

@Component
export struct AiBarSettings {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Provide('refreshSnap') refreshSnap: number = 0;
  @Provide('closeSnap') closeSnap: number = 0;
  @Provide('jumpIndex') jumpIndex: number = -1;
  @Provide('exchangeButton') isExchangeButton: boolean = false;
  private controller: Scroller = new Scroller();
  @State aiBarSwitchItems: SwitchItem[] = [{
    index: 0,
    content: $r('app.string.Ai_bar_back_click_navigation'),
    switchStatus: false,
    name: NavSwitchType.CLICK_BACK_STATUS,
    switchType: AI_BAR_TYPE,
  }];
  readonly aiBarSettingDoMain: string = AiBarSwitchManager.getInstance().aiBarSettingDoMain;
  readonly floatingSettingDoMain: string = AiBarSwitchManager.getInstance().floatingSettingDoMain;
  readonly EXCHANGE_BUTTON_KEY: string = 'floatingnavigation_exchange_button';
  @State params: PushParam | null = null;
  @State isSupportGestureNavigation: boolean = true;
  // 是否支持悬浮导航开关
  @State isSupportFloatBall: boolean = true;
  @State floatingSwitchItems: SwitchItem[] = [{
    index: -1,
    content: $r('app.string.floating_three_button_navigation_new'),
    switchStatus: false,
    name: NavSwitchType.FLOATING_NAV_STATUS,
    detail: $r('app.string.floating_three_button_navigation_detail_new'),
    switchType: FLOATING_NAVIGATION_TYPE,
  }];
  @State isFloatingOpen: boolean = false;
  @State isClickBarOpen: boolean = false;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  private isDestroy: boolean = false;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  private aiBarSettingsId: number = -1;
  private onFloatingNavigationDataChange = () => {
    // 三键开关改变
    let isFloatingNavigationOpen = this.isFloatingNavigationOpen();
    let floatingSwitchItems = this.floatingSwitchItems[0];
    LogUtil.showInfo(TAG, `on floatingNavigation dataChange: ${isFloatingNavigationOpen}`);
    this.refreshToggleState(floatingSwitchItems?.name, isFloatingNavigationOpen);
    // 三键开关打开，关闭悬浮开关
    AiBarSwitchManager.getInstance().closeThreeButtonOrFloating(isFloatingNavigationOpen, false);
    if (isFloatingNavigationOpen) {
      LogUtil.showInfo(TAG, `scroll to end `);
      this.controller?.scrollEdge(Edge.End);
    }
  }
  private onExchangeButtonDataChange = () => {
    // back键位置信息改变
    this.isExchangeButton = !this.isExchangeButton;
    LogUtil.info(`${TAG} onExchangeButtonDataChange: ${this.isExchangeButton}`);
  }

  build() {
    NavDestination() {
      Column() {
        this.scrollBuilder();
      }
      .padding({ left: 16, right: 16 }).width('100%').height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
    .hideBackButton(this.navigationMode === NavigationMode.Split &&
      (PageStartModeManager.getInstance().getStartReason() === PageStartReason.FROM_SEARCH ||
        PageStartModeManager.getInstance().getStartReason() === PageStartReason.FROM_EXTERNAL))
    .hideTitleBar(false)
    .title($r('app.string.Ai_bar_setting'))
    // .titleBar({ content: { title: { mainTitle: $r('app.string.Ai_bar_setting') } } })
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onWillAppear(() => {
      LogUtil.showInfo(TAG, 'onWillAppear');
      this.init();
    })
    .onWillDisappear(() => {
      LogUtil.showInfo(TAG, 'onWillDisappear');
      this.onDestroy();
    })
    .onDisAppear(() => {
      LogUtil.showInfo(TAG, 'onDisAppear');
      this.onDestroy();
    })
    .bindToScrollable([this.controller])
  }

  @Builder
  scrollBuilder() {
    Scroll(this.controller) {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        // 轮播组件
        AiBarSwiper();
        Row() {
          // 导航条
          Text($r('app.string.Ai_bar'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .textAlign(TextAlign.Start)
            .margin({
              left: 12,
              right: 12,
            })
        }
        .width('100%')
        .padding({
          top: 12,
          bottom: 12,
        })
        .justifyContent(FlexAlign.Start)

        // aiBar开关组件
        this.switchGroup(AI_BAR_TYPE);

        if (this.isSupportGestureNavigation) {
          // 更多设置
          Row() {
            Text($r('app.string.more_settings'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .fontSize(14)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .textAlign(TextAlign.Start)
              .margin({
                left: 12,
                right: 12,
              })
          }
          .width('100%')
          .padding({
            top: 24,
            bottom: 8,
          })
          .justifyContent(FlexAlign.Start)

          // 悬浮导航开关组件
          this.switchGroup(FLOATING_NAVIGATION_TYPE);

          this.ExchangeView()
        }
        if (this.isSupportFloatBall) {
          this.FloatingBallView();
        }
      }
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .padding({ bottom: LengthMetrics.vp(16) })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  // 切换三键导航按钮位置视图
  @Builder
  ExchangeView() {
    Column() {
      Blank().height('16vp');
      // 三键位置
      FloatingNavigationExchangeView();
    }.visibility(this.isFloatingOpen ? Visibility.Visible : Visibility.None)
  }

  // 悬浮导航开关
  @Builder
  FloatingBallView() {
    Blank().height('16vp');
    // 三键位置
    FloatingNavigationBallView();
  }

  private init() {
    this.aiBarSettingsId = AiBarSwitchManager.getInstance().getPageId() + 1;
    AiBarSwitchManager.getInstance().setPageId(this.aiBarSettingsId);
    this.isDestroy = false;
    SCBGestureNavSetManager.getInstance().init();
    this.isSupportGestureNavigation = SCBGestureNavSetManager.getInstance().getSupportFloatNavigation();
    this.isSupportFloatBall = SCBGestureNavSetManager.getInstance().getSupportFloatBall();
    this.registerKeyObserver();
  }

  private registerKeyObserver() {
    try {
      this.unregisterKeyObserver();
      let isRegisterSuccess = SettingsDataUtils.registerKeyObserverWithDomain(this.floatingSwitchItems[0].name,
        this.floatingSettingDoMain, this.onFloatingNavigationDataChange);
      let isExchangeButtonRegister = SettingsDataUtils.registerKeyObserverWithDomain(this.EXCHANGE_BUTTON_KEY,
        this.floatingSettingDoMain, this.onExchangeButtonDataChange);
      LogUtil.showInfo(TAG,
        `isFloatingRegisterSuccess is ${isRegisterSuccess} isAccessRegister is ${isExchangeButtonRegister}`);
    } catch (e) {
      LogUtil.showError(TAG, `registerKeyObserver Error: ${e?.message}`);
    }
  }

  private onDestroy() {
    let pageId = AiBarSwitchManager.getInstance().getPageId();
    if (!this.isDestroy && this.aiBarSettingsId === pageId) {
      this.unregisterKeyObserver();
      this.isDestroy = true;
      LogUtil.showInfo(TAG, 'onDestroy');
    }
  }

  private unregisterKeyObserver() {
    let unRegisterSuccess = SettingsDataUtils.unregisterKeyObserverWithDomain(this.floatingSwitchItems[0].name,
      this.floatingSettingDoMain);
    let unExchangeButtonRegister = SettingsDataUtils.unregisterKeyObserverWithDomain(this.EXCHANGE_BUTTON_KEY,
      this.floatingSettingDoMain);
    LogUtil.showInfo(TAG,
      `unFloatingRegisterSuccess is ${unRegisterSuccess} unAccessRegister is ${unExchangeButtonRegister}`);
  }

  private async loadState(): Promise<void> {
    try {
      let clickBackStatusValue =
        settings.getValueSync(getContext(), NavSwitchType.CLICK_BACK_STATUS, 'false', this.aiBarSettingDoMain);
      let clickBackStatus = clickBackStatusValue === 'true';

      let floatingNavigationStatus = this.isFloatingNavigationOpen();
      LogUtil.showInfo(TAG, `[%{public}s] Get clickBackStatus value: %{public}s, floatingNavigation value: %{public}s`,
        TAG, clickBackStatus, floatingNavigationStatus);
      this.refreshToggleState(NavSwitchType.CLICK_BACK_STATUS, clickBackStatus);
      this.refreshToggleState(NavSwitchType.FLOATING_NAV_STATUS, floatingNavigationStatus);
    } catch (e) {
      this.refreshToggleState(NavSwitchType.CLICK_BACK_STATUS, false);
      this.refreshToggleState(NavSwitchType.FLOATING_NAV_STATUS, false);
      LogUtil.showError(TAG, `Preference Error: ${e?.message}`);
    }
  }

  private isFloatingNavigationOpen(): boolean {
    return AiBarSwitchManager.getInstance().isFloatingNavigationOpen();
  }

  private refreshToggleState(type: string, isOn: boolean): void {
    try {
      switch (type) {
        case NavSwitchType.CLICK_BACK_STATUS:
          this.setSwitchItem(0, isOn, AI_BAR_TYPE);
          break;
        case NavSwitchType.FLOATING_NAV_STATUS:
          this.setSwitchItem(0, isOn, FLOATING_NAVIGATION_TYPE);
          break;
        default:
          break;
      }
    } catch (e) {
      LogUtil.showError(TAG, `refreshToggleState Error: ${e?.message}`);
    }
  }

  private setSwitchItem(index: number, isOn: boolean, type: number) {
    LogUtil.showInfo(TAG, `setSwitchItem index is ${index}, isOn is ${isOn}, type is ${type}`);
    switch (type) {
      case AI_BAR_TYPE:
        this.aiBarSwitchItems[index].switchStatus = isOn;
        if (index === 0) {
          this.isClickBarOpen = isOn;
        }
        break;
      case FLOATING_NAVIGATION_TYPE:
        this.floatingSwitchItems[index].switchStatus = isOn;
        this.isFloatingOpen = isOn;
        break;
    }
  }

  private changeToggleState(type: string, isOn: boolean): void {
    LogUtil.showInfo(TAG, `changeToggleState type is ${type}, isOn is ${isOn}`);
    try {
      switch (type) {
        case NavSwitchType.CLICK_BACK_STATUS:
          this.aiBarSwitchItems[0].switchStatus = isOn;
          this.isClickBarOpen = isOn;
          break;
        case NavSwitchType.FLOATING_NAV_STATUS:
          this.floatingSwitchItems[0].switchStatus = isOn;
          this.isFloatingOpen = isOn;
          break;
        default:
          break;
      }
    } catch (e) {
      LogUtil.showError(TAG, `[%{public}s] changeToggleState Error, %{public}s`, TAG, e?.message);
    }
  }

  onPageShow(): void {
    LogUtil.showInfo('[%{public}s] onPageShow', TAG);
    this.pageRoot.onPageShow();
    this.refreshSnap++;
    this.loadState();
  }

  onPageHide(): void {
    LogUtil.showInfo('[%{public}s] onPageHide', TAG);
    this.pageRoot.onPageHide();
    this.closeSnap++;
  }

  @Styles
  settingItemStyle() {
    .padding({
      top: 10,
      bottom: 10,
      left: 8,
      right: 8
    })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(16)
    .width('100%')
  }

  @Builder
  aiBarSwitchItem(switchItem: SwitchItem) {
    Row() {
      Column() {
        Text(switchItem.content)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .fontColor(this.isToggleEnabled(switchItem) ? SWITCH_TITLE_FONTCOLOR : SWITCH_TERTIARY_FONTCOLOR)

        Text(switchItem.detail)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize(14)
          .margin({ top: 2 })
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .visibility(CheckEmptyUtils.isEmpty(switchItem.detail) ? Visibility.None : Visibility.Visible)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({
        type: ToggleType.Switch,
        isOn: this.getToggleIsOn(switchItem),
      })
        .enabled(this.isToggleEnabled(switchItem))
        .onChange((toggleIsOn: boolean) => {
          LogUtil.showInfo(TAG, 'onChange');
          if (toggleIsOn === this.getToggleIsOn(switchItem)) {
            LogUtil.showInfo(TAG, 'is same no need refresh');
            return;
          }
          let isOn: boolean = false;
          switch (switchItem.name) {
            case NavSwitchType.CLICK_BACK_STATUS:
              isOn = this.aiBarSwitchItems[0].switchStatus;
              break;
            case NavSwitchType.FLOATING_NAV_STATUS:
              isOn = this.isFloatingOpen
              break;
            default:
              LogUtil.showError(TAG, `toggleStatusChange  toggleName: ${switchItem.name}`);
              break;
          }
          LogUtil.showInfo(TAG, `toggleStatus name: ${switchItem.name}  isOn: ${!isOn}`);
          this.changeToggleState(switchItem.name, !isOn);
          this.saveData(switchItem, !isOn);
        })
        .accessibilityLevel(AccessibilityLevelType.YES)
        .hoverEffect(HoverEffect.None)
    }
    .accessibilityGroup(true)
    .justifyContent(FlexAlign.SpaceBetween)
    .settingItemStyle();
  }

  private saveData(switchItem: SwitchItem, isOn: boolean) {
    if (isOn) {
      LogUtil.showInfo(TAG, `toggleStatusChange index:%{public}d`, switchItem.index);
      this.jumpIndex = switchItem.index;
      this.jumpIndex = -1;
    }
    this.setValueToSettingsData(switchItem, isOn);
  }

  private getToggleIsOn(switchItem: SwitchItem): boolean | undefined {
    if (this.isFloatingOpen && switchItem.switchType === AI_BAR_TYPE) {
      // 三键打开时，点击长按开关关闭
      return false;
    }
    switch (switchItem.name) {
      case NavSwitchType.CLICK_BACK_STATUS:
        return this.isClickBarOpen;
      case NavSwitchType.FLOATING_NAV_STATUS:
        return this.isFloatingOpen;
      default:
        LogUtil.showError(TAG, `toggleStatusChange  toggleName: ${switchItem.name}`);
        return false;
    }
  }

  private isToggleEnabled(switchItem: SwitchItem): boolean {
    if (this.isFloatingOpen && switchItem.switchType === AI_BAR_TYPE) {
      // 三键打开时，点击长按开关关闭
      return false;
    }
    return true;
  }

  private setValueToSettingsData(switchItem: SwitchItem, isOn: boolean) {
    try {
      AiBarSwitchManager.getInstance()
        .setValueToSettingsData(getContext(), switchItem?.name, switchItem.switchType, isOn);
    } catch (e) {
      LogUtil.showError(TAG, `setValue is error ${e?.message}`);
    }
  }

  @Builder
  switchGroup(type: number) {
    List() {
      ForEach(type === AI_BAR_TYPE ? this.aiBarSwitchItems : this.floatingSwitchItems, (item: SwitchItem) => {
        ListItem() {
          this.aiBarSwitchItem(item);
        }
      })
    }
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r('app.float.distance_8'),
      endMargin: $r('app.float.distance_8'),
    })
    .switchCardStyle()
  }

  @Styles
  switchCardStyle() {
    .padding({
      left: 4,
      right: 4,
      top: 4,
      bottom: 4,
    })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(16)
    .width('100%')
  }
}