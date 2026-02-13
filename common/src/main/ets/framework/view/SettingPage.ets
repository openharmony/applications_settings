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

import { ComponentContent, LengthMetrics } from '@ohos.arkui.node';
import { BusinessError } from '@ohos.base';
import { TextModifier } from '@kit.ArkUI';
import window from '@ohos.window';
import lazy displaySync from '@ohos.graphics.displaySync';
// import {
//   DividerShowType,
//   HdsNavDestination,
//   HdsNavDestinationAttribute,
//   HdsNavigationBadgeIconOptions
// } from '@kit.UIDesignKit';
// import { BackgroundBrightnessLevel } from '@hms.hds.hdsBaseComponent';
import {
  PADDING_0,
  PADDING_12,
  PADDING_8,
  PADDING_1_PX
} from '../../constant/StyleConstant';
import { AccessibilityLevelType } from '../../utils/AccessibilityUtils';
import { DeviceUtil, TipsHelper } from '../../utils/BaseUtils';
import { DisplayUtils } from '../../utils/DisplayUtils';
import { CommonUtils } from '../../utils/CommonUtils';
import { INIT_AVOID_WIDTH,
  INIT_DEFAULT_WIDTH,
  INVALID_AVOID_WIDTH,
  TITLE_BAR_DEFAULT_PADDING
} from '../../utils/Consts';
import { TabIndexConstants } from '../../constant/TabIndexConstants';
import { DataVerify } from '../common/DataVerify';
import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { PageConfigVerify } from '../common/PageConfigVerify';
import { PageParams } from '../common/PageLoader';
import { LazyDataSource } from '../model/LazyDataSource';
import { SettingBaseModel } from '../model/SettingBaseModel';
import { GroupType, SettingContentModel, SettingContentTextStyle, SettingGroupModel } from '../model/SettingGroupModel';
import { EVENT_ID_PAGE_RENDER_GROUP_CHANGE } from '../../event/types';
import {
  ItemPos,
  ItemResultType,
  ItemType,
  SegmentButtonModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel,
  SettingMenuStyle,
  SettingTextModel
} from '../model/SettingItemModel';
import {
  DefaultSettingPageModel,
  PageType,
  SettingPageLayout,
  SettingPageMenu,
  SettingPageModel,
  SettingSheetPageContext,
} from '../model/SettingPageModel';
import { SettingBaseState, SettingCompState, SettingContentState, SettingStateType } from '../model/SettingStateModel';
import { SettingTabsModel } from '../model/SettingTabsModel';
import { SettingGroup } from './SettingGroup';
import { SettingGroupFooter } from './SettingGroupFooter';
import { SettingGroupHeader } from './SettingGroupHeader';
import { SettingItemStandard } from './SettingItemStandard';
import { BaseDataSource } from '../model/BaseDataSource';
import { DynamicGroupDataSource } from '../model/DynamicGroupDataSource';
import { LogUtil } from '../../utils/LogUtil';
import lazy {segmentButtonLoader} from './SegmentButtonLoader';

enum SettingListItemType {
  ITEM_TYPE_CUSTOM_GROUP = 0,
  ITEM_TYPE_NORMAL = 1,
  ITEM_TYPE_GROUP_HEADER = 2,
  ITEM_TYPE_GROUP_FOOTER = 3,
  ITEM_TYPE_PAGE_HEADER = 4,
  ITEM_TYPE_PAGE_FOOTER = 4,
}

interface SettingListItem extends SettingBaseModel {
  type: SettingListItemType;
  item: SettingBaseModel;
  itemPos?: ItemPos;
  backgroundColor?: ResourceColor;
  borderRadius?: BorderRadiuses;
  padding?: LocalizedPadding;
  margin?: LocalizedPadding;
}

interface PageContentParam {
  groups: SettingGroupModel[];
  compId?: string;
  hasFixedGroup?: boolean;
  dataSource?: BaseDataSource<SettingGroupModel>;
  tabIndex?: number;
  ignoreSizeChange?: boolean;
}

interface MenuBuildParam {
  menu: SettingPageMenu;
  iconStyle: SettingIconStyle;
  count: number;
  index: number;
}

const TAG: string = 'SettingPage';

@Component
export struct SettingPage {
  pageParam?: PageParams;
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();
  private compId: string = '';
  private taskId: number | null = null;
  private layout?: SettingPageLayout;
  private pageNavTitleOptions: NavigationTitleOptions | undefined;
  @Require private scroller: Scroller;
  private dataSource: LazyDataSource<SettingListItem> = new LazyDataSource();
  private isCircleScreen: boolean = PageConfig.getInstance().isCircleScreen();
  private sheetPageCtx?: SettingSheetPageContext;
  private swiperController?: SwiperController;
  private selectedPageHeigth: number[] = [0, 0];
  private tempTabIndex: number = -1;
  private maxWidthPrec: Length = DisplayUtils.getScreenWidth() * 0.67;
  @Consume('pathInfos') pathInfos: NavPathStack;
  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invaild eventbus data type.');
      return;
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };

  private titleButtonRectWidth: number = INIT_AVOID_WIDTH;
  @State avoidDefaultWidth: number = INIT_DEFAULT_WIDTH;
  @State pageTitle: ResourceStr = '';
  @State needRenderGroup: boolean = false;
  @State cardWidth: number = 0;
  @State cardHeight: number = 0;
  @State @Watch('selectIndexesUpdated') selectedIndexes: number[] = [0];
  @State tabContents: ResourceStr[] = ['', ''];
  @State tabGroupPageChange: boolean = false;
  @State dynamicDataSource: BaseDataSource<SettingGroupModel> = [];
  @State menuHoverIndex: number = -1;
  @State enableScrollInteraction: boolean = true;
  @State barState: BarState | undefined = undefined;
  @BuilderParam segmentButtonLoader: (param: SegmentButtonModel) => void;
  @StorageProp('navDesDynamicPadding')
  @Watch('onNavDesDynamicPaddingChange') navDesDynamicPadding: number =
    AppStorage.get<number>('navDesDynamicPadding') as number;
  // 监听窗口焦点变化
  @StorageLink('windowFocused') isWindowFocused: boolean = true;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Auto;
  @State curFrameCount: number = 0;
  private displaySync: displaySync.DisplaySync | undefined;
  private renderGroupEventCb = (state: boolean) => {
    LogHelper.info(TAG, `HomePage PageRenderGroupChange change to ${state}`);
    this.needRenderGroup = state;
  };

  // 使用HdsNavDestination的页面
  private useHdsNavUx(): boolean {
    return this.pageInfo.hdsNavDestinationUx === true;
  }

  onNavDesDynamicPaddingChange(): void {
    this.setAvoidDefaultWidth();
  }

  private enableListenFrame(): void {
    if (this.pageInfo?.frameCount === undefined) {
      return;
    }
    try {
      this.displaySync = displaySync.create();
      this.displaySync?.on('frame', this.frameCallback);
      this.displaySync?.start();
    } catch (e) {
      LogHelper.error(TAG, `listen frame change fail: ${e?.message} - ${e?.code}`);
      this.curFrameCount = this.pageInfo.frameCount;
    }
  }

  private disableListenFrame(): void {
    if (this.pageInfo?.frameCount === undefined) {
      return;
    }
    try {
      this.displaySync?.off('frame', this.frameCallback);
    } catch (e) {
      LogHelper.error(TAG, `off listen frame change fail: ${e?.message} - ${e?.code}`);
    }
  }

  private frameCallback = (intervalInfo: displaySync.IntervalInfo) => {
    this.curFrameCount ++;
    if (this.curFrameCount >= (this.pageInfo?.frameCount ?? 0)) {
      try {
        this.displaySync?.stop();
      } catch (e) {
        LogHelper.error(TAG, `stop listen frame change fail: ${e?.message} - ${e?.code}`);
      }
    }
  };

  private selectIndexesUpdated(): void {
    LogHelper.info(TAG, `change tabs to index ${this.selectedIndexes[0]}`);
    this.cardHeight = this.selectedPageHeigth[this.selectedIndexes[0]];
    this.swiperController?.changeIndex(this.selectedIndexes[0]);
    this.pageInfo.onTabSelected?.(this.selectedIndexes[0]);
  }

  private procTitleEvent(value: SettingBaseState): void {
    let titleContent = value as SettingContentState;
    if (!titleContent?.content) {
      LogHelper.error(TAG, 'invaild title state event');
      return;
    }

    LogHelper.info(TAG, `enabled state change.`);
    this.pageTitle = titleContent.content;
  }

  private enableScrollInteractionEvent(value: SettingBaseState): void {
    let enableScroll = value as SettingCompState;
    if (enableScroll?.state === undefined) {
      LogHelper.error(TAG, 'invaild enableScrollInteraction state event');
      return;
    }

    LogHelper.info(TAG, `enableScrollInteraction state change.`);
    this.enableScrollInteraction = enableScroll?.state;
  }

  private scrollBarStateChangeEvent(value: SettingBaseState): void {
    let scrollBarState = value as SettingCompState;
    if (scrollBarState?.state === undefined) {
      LogHelper.error(TAG, 'invalid ScrollBar state event');
      return;
    }
    LogHelper.info(TAG, 'ScrollBar state change.');
    this.barState = scrollBarState?.state ? BarState.Auto : BarState.Off;
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (!value) {
        return;
      }

      switch (key) {
        case SettingStateType.STATE_TYPE_PAGE_TITLE:
          this.procTitleEvent(value);
          break;
        case SettingStateType.STATE_TYPE_PAGE_SCROLL_TO_TOP:
          this.scroller.scrollToIndex(0);
          break;
        case SettingStateType.STATE_TYPE_PAGE_CHANGE:
          this.tabGroupPageChange = (value as SettingCompState).state;
          this.tabGroupPageChange ? this.onPageHide() : this.onPageShow();
          break;
        case SettingStateType.STATE_TYPE_PAGE_SCROLLABLE:
          this.enableScrollInteractionEvent(value);
          break;
        case SettingStateType.STATE_TYPE_SCROLLBAR:
          this.scrollBarStateChangeEvent(value);
          break;
        default:
          LogHelper.error(TAG, `invaild event data key: ${key}`);
          break;
      }
    })
  }

  private getSettingItemBorderRadius(itemIndex: number, itemTotal: number,
    cfgBorderRadiuses?: Length): BorderRadiuses | undefined {
    if (itemIndex > 0 && itemIndex < itemTotal - 1) {
      return undefined;
    }

    if (!cfgBorderRadiuses) {
      cfgBorderRadiuses = PageConfig.getInstance().getGroupLayout().borderRadius;
    }
    if (this.isCircleScreen) {
      return { topLeft: cfgBorderRadiuses, topRight: cfgBorderRadiuses,
        bottomLeft: cfgBorderRadiuses, bottomRight: cfgBorderRadiuses };
    }

    let borderRadius: BorderRadiuses = {};
    if (itemIndex === 0) {
      borderRadius.topLeft = cfgBorderRadiuses;
      borderRadius.topRight = cfgBorderRadiuses;
    }
    if (itemIndex === itemTotal - 1) {
      borderRadius.bottomLeft = cfgBorderRadiuses;
      borderRadius.bottomRight = cfgBorderRadiuses;
    }
    return borderRadius;
  }

  private getSettingItemPadding(itemIndex: number, itemTotal: number,
    cfgPad?: LocalizedPadding): LocalizedPadding | undefined {
    if (this.isCircleScreen) {
      return undefined;
    }

    return {
      start: cfgPad?.start,
      end: cfgPad?.end,
      top: (itemIndex === 0) ? cfgPad?.top : PADDING_0,
      bottom: (itemIndex === itemTotal - 1) ? cfgPad?.bottom : PADDING_0
    };
  }

  // 保持一致，已上边距计算
  private getSettingItemMargin(firstItem: boolean,
    group: SettingGroupModel, previousGroup: SettingGroupModel): LocalizedPadding | undefined {
    if (this.isCircleScreen) {
      return undefined;
    }

    if (!firstItem || !previousGroup || group.header) {
      return undefined
    }

    let groupLayout = PageConfig.getInstance().getGroupLayout(group, previousGroup);
    if (!previousGroup.footer) {
      return groupLayout.margin;
    } else {
      return undefined;
    }
  }

  private getItemPos(itemIndex: number, itemTotal: number): number {
    let itemPos: number = 0;
    if (itemIndex === 0) {
      itemPos |= ItemPos.ITEM_POS_START;
    }
    if (itemIndex > 0 && itemIndex < itemTotal - 1) {
      itemPos |= ItemPos.ITEM_POS_CENTER;
    }
    if (itemIndex === itemTotal - 1) {
      itemPos |= ItemPos.ITEM_POS_END;
    }
    return itemPos;
  }

  private setHomePageItemMaxLines(textCtx?: SettingTextModel): void {
    if (!textCtx) {
      return;
    }
    if (!textCtx.style) {
      textCtx.style = { maxLines: 4, textOverflow: TextOverflow.Ellipsis };
    }
  }

  private fillGroupItems(compId: string, inItems: SettingItemModel[],
    outItems: SettingListItem[], group: SettingGroupModel, previousGroup: SettingGroupModel): void {
    LogHelper.info(TAG, `compId ${compId} fillGroupItems group.tabIndex${group.tabIndex}`);
    let groupLayout =
      PageConfig.getInstance().getGroupLayout(undefined, undefined, this.pageInfo.type === PageType.PAGE_TYPE_HOME);
    for (let itemIndex: number = 0; itemIndex < inItems.length; itemIndex++) {
      let item: SettingItemModel = inItems[itemIndex];
      // 在这里统一设置主页一行显示
      if (!this.isCircleScreen) {
        this.setHomePageItemMaxLines(item.title);
        if (item.result?.type === ItemResultType.RESULT_TYPE_TEXT) {
          this.setHomePageItemMaxLines(item.result.result as SettingTextModel);
        }
      }
      outItems.push({
        id: `${compId}.${item.id}`,
        type: SettingListItemType.ITEM_TYPE_NORMAL,
        item: item,
        itemPos: this.getItemPos(itemIndex, inItems.length),
        backgroundColor: groupLayout.backgroupColor,
        borderRadius: this.getSettingItemBorderRadius(itemIndex, inItems.length, groupLayout.borderRadius),
        padding: this.getSettingItemPadding(itemIndex, inItems.length, groupLayout.padding),
        margin: this.getSettingItemMargin(itemIndex === 0, group, previousGroup),
      });
    }
  }

  private initDataSource(page: SettingPageModel): void {
    const pageId: string = this.compId;
    if (this.pageInfo.type === PageType.PAGE_TYPE_HOME) {
      this.initHomeItems(page, pageId);
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_DYNAMIC) {
      this.dynamicDataSource.push(...(page.groups ?? []));
    }
  }

  private initHomeItems(page: SettingPageModel, pageId: string) {
    let items: SettingListItem[] = [];
    if (page.header) {
      items.push({
        id: `${pageId}.header`,
        type: SettingListItemType.ITEM_TYPE_PAGE_HEADER,
        item: page.header,
      });
    }
    if (page.groups) {
      for (let groupIndex: number = 0; groupIndex < page.groups.length; groupIndex++) {
        const group: SettingGroupModel = page.groups[groupIndex];
        if (group.type === GroupType.GROUP_TYPE_CUSTOM && group.builder) {
          items.push({
            id: `${pageId}.${group.id}`,
            type: SettingListItemType.ITEM_TYPE_CUSTOM_GROUP,
            item: group,
            borderRadius: this.getSettingItemBorderRadius(0, 1),
            margin: this.getSettingItemMargin(true, group, page.groups[groupIndex - 1]),
          });
          continue;
        }

        if (group.items) {
          this.fillGroupItems(`${pageId}.${group.id}`, group.items, items, group, page.groups[groupIndex - 1]);
        }
      }
    }
    this.dataSource.push(...items);
    this.dataSource.notifyDataReload();
  }

  private registerHomePageEvent(): void {
    EventBus.getInstance().on('HomePageScroll', (targetEntry: string) => {
      let targetIndex = this.dataSource.findIndex((value: SettingListItem) => {
        return value.item.id === targetEntry;
      });
      if (targetIndex < 0) {
        this.scroller.scrollToIndex(0);
      } else {
        this.scroller.scrollToIndex(targetIndex);
      }
    });
    EventBus.getInstance().on(EVENT_ID_PAGE_RENDER_GROUP_CHANGE, this.renderGroupEventCb);
  }

  private unregisterHomePageEvent(): void {
    EventBus.getInstance().off('HomePageScroll');
    EventBus.getInstance().detach(EVENT_ID_PAGE_RENDER_GROUP_CHANGE, this.renderGroupEventCb);
  }

  private onListSizeChange(newValue: SizeOptions, tabIndex?: number): void {
    let padding: LengthMetrics = this.layout?.padding?.start ? this.layout?.padding?.start : PADDING_0;
    this.cardWidth = vp2px(newValue.width as number - padding.value * 2);
    if (DeviceUtil.isDevicePc()) {
      this.cardWidth += 2;
    }
    this.cardHeight = vp2px(newValue.height as number);
    if (this.pageInfo.tabs && this.pageInfo.tabs.length === 2 && tabIndex !== undefined) {
      this.selectedPageHeigth[tabIndex] = this.cardHeight;
      if (tabIndex !== this.selectedIndexes[0]) {
        this.cardHeight = this.selectedPageHeigth[this.selectedIndexes[0]];
      }
      LogHelper.info(TAG, `page ${this.compId} tab ${tabIndex} heigth change to ${this.cardHeight}`);
    }
  }

  @Builder pageHeader(header: SettingContentModel, style: SettingContentTextStyle): void {
    Column() {
      if (header.builder) {
        header.builder.builder(header);
      } else {
        Text(header.content)
          .width('100%')
          .fontSize(style.fontSize)
          .fontWeight(style.fontWeight)
          .fontColor(style.fontColor)
          .fontFamily(style.fontFamily)
          .textAlign(style.textAlign)
          .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
      }
    }
    .width('100%')
    .height(style.height)
    .padding(style.padding)
    .justifyContent(style.justifyContent)
  }

  @Builder pageHomeContent(): void {
    Column() {
      List({ scroller: this.scroller }) {
        if (DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) {
          ListItem() {
            Row().height(120)
          }
        }
        LazyForEach(this.dataSource, (item: SettingListItem) => {
          ListItem() {
            this.contentAreaBuilder(item)
          }
        }, (item: SettingListItem) => item.id)
      }
      .backToTop(!(this.pageInfo.type === PageType.PAGE_TYPE_HOME && this.navigationMode === NavigationMode.Split))
      .onScrollStart(()=>{
        LogUtil.showInfo(TAG, 'onScrollStart');
        AppStorage.setOrCreate('scrollingState', true);
      })
      .onScrollStop(()=>{
        LogUtil.showInfo(TAG, 'onScrollStop');
        AppStorage.setOrCreate('scrollingState', false);
      })
      .defaultFocus(PageConfig.getInstance().isCircleScreen() ? true : undefined)
      .width('100%')
      .height('100%')
      .cachedCount(25)
      .edgeEffect(EdgeEffect.Spring)
      .borderRadius(this.getSettingItemBorderRadius(0, 1))
      .scrollBar(BarState.Off)
      .contentEndOffset(this.layout?.padding?.bottom?.value)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .transition(TransitionEffect.translate({ y: -64 }))
    .useEffect(DeviceUtil.isSupportSidebarBlur(), EffectType.WINDOW_EFFECT)
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
    })

    ScrollBar({
      scroller: this.scroller,
      direction: ScrollBarDirection.Vertical,
      state: this.layout?.barState ?? BarState.Auto
    }).margin({
      top: DeviceUtil.isDevicePc() ? 0 : 120,
      bottom: DeviceUtil.isDevicePc() ? ((this.layout?.padding?.bottom?.value ?? 0) + 4) : 0
    })
  }

  @Builder
  contentAreaBuilder(item: SettingListItem) {
    Column() {
      if (item.type === SettingListItemType.ITEM_TYPE_CUSTOM_GROUP) {
        (item.item as SettingGroupModel).builder?.builder((item.item as SettingGroupModel));
      } else if (item.type === SettingListItemType.ITEM_TYPE_NORMAL) {
        if ((item.item as SettingItemModel).type === ItemType.ITEM_TYPE_CUSTOM) {
          // lcxlcxlcx
          (item.item as SettingItemModel).builder?.builder((item.item as SettingItemModel));
        } else {
          SettingItemStandard({
            itemInfo: item.item as SettingItemModel,
            itemPos: item.itemPos,
            compId: `${item.item.id}`,
            homePageComp: true
          });
        }
      } else if (item.type === SettingListItemType.ITEM_TYPE_PAGE_HEADER) {
        this.pageHeader(item.item as SettingContentModel,
          PageConfig.getInstance().getPageHeaderStyle(item.item as SettingContentModel));
      }
    }.backgroundColor(item.backgroundColor)
    .borderRadius(item.borderRadius)
    .padding(item.padding)
    .margin(item.margin)
    .renderGroup(item.id === 'Setting.Home.search_group' ? false : this.needRenderGroup)
  }

  private preprocessGroups(groups: SettingGroupModel[]): void {
    for (let groupIndex = 0; groupIndex < groups.length; ) {
      let group = groups[groupIndex];
      group.tabIndex = this.tempTabIndex;
      if (group.items && group.items.length > 0) {
        for (let itemIndex = 0; itemIndex < group.items.length; ) {
          let item = group.items[itemIndex];
          if (item.needHide?.()) {
            group.items.splice(itemIndex, 1);
            continue;
          }
          item.tabIndex = group.tabIndex
          itemIndex++;
        }
        this.tempTabIndex++;
        if (group.items.length == 0) {
          groups.splice(groupIndex, 1);
          continue;
        }
      }
      groupIndex++;
    }
  }

  private preprocessTabs(tabs: SettingTabsModel[]): void {
    for (let tabIndex = 0; tabIndex < tabs.length; tabIndex++) {
      let tab = tabs[tabIndex];
      if (tab.groups && tab.groups.length > 0) {
        this.preprocessGroups(tab.groups);
      }
    }
  }

  private preprocess(page: SettingPageModel): void {
    if (page.tabs && page.tabs.length > 0) {
      this.preprocessTabs(page.tabs);
    }
    if (page.fixedGroups && page.fixedGroups.length > 0) {
      this.preprocessGroups(page.fixedGroups);
      if (page.fixedGroups.length === 0) {
        page.fixedGroups = undefined;
      }
    }
    if (page.groups && page.groups.length > 0) {
      this.preprocessGroups(page.groups);
      if (page.groups.length === 0) {
        page.groups = undefined;
      }
    }
  }

  private getMenuIconStyle(menuItem: SettingPageMenu): SettingIconStyle {
    menuItem.iconType = SettingIconType.ICON_TYPE_TIP;
    return PageConfig.getInstance().getIconStyle(menuItem);
  }

  private getTitleButtonRectWidth() {
    if (!DeviceUtil.isDevicePc()) {
      return;
    }
    this.setAvoidDefaultWidth();
    try {
      window.getLastWindow(getContext(), (error: BusinessError, win: window.Window) => {
        if (!win || !win.getTitleButtonRect() || win.getTitleButtonRect().width === 0) {
          LogHelper.warn(TAG, `errorMsg: ${win?.getTitleButtonRect()?.width}`);
          return;
        }
        this.titleButtonRectWidth = win.getTitleButtonRect().width;
        AppStorage.setOrCreate('titleButtonRectWidth', this.titleButtonRectWidth);
        this.setAvoidDefaultWidth();
        LogHelper.info(TAG, `Avoidance Width: ${win.getTitleButtonRect().width}`);
      })
    } catch (error) {
      LogUtil.error(`${TAG} getLastWindow error: ${error?.code}, ${error?.message}`);
    }
  }

  private setAvoidDefaultWidth() {
    let avoidWidth: number = CommonUtils.calculateAvoidWidth(this.titleButtonRectWidth, this.navDesDynamicPadding);
    if (avoidWidth !== INVALID_AVOID_WIDTH) {
      this.avoidDefaultWidth = avoidWidth;
    }
    LogHelper.info(TAG, `defaultwidth ${this.avoidDefaultWidth}`);
  }

  @Builder menuBuilder(bindMenu: MenuElement[], menuIndex: number, menuStyle: SettingMenuStyle): void {
    if (bindMenu !== undefined && bindMenu.length >= 0) {
      Menu() {
        ForEach(bindMenu, (item: MenuElement, index: number) => {
          MenuItem({ content: item.value })
            .id(`${this.compId}.menuItem${index}`)
            .contentFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium,
            })
            .contentFontColor($r('sys.color.font_primary'))
            .constraintSize({
              minHeight: menuStyle.itemHeight,
              maxWidth: this.maxWidthPrec
            })
            .width(DeviceUtil.isDevicePc() ? undefined : menuStyle.width)
            .onClick(() => {
              item.action();
            })
        })
      }
      .id(`${this.compId}.menu${menuIndex}`)
      .radius(menuStyle.borderRadius as Dimension || $r('sys.float.corner_radius_level4'))
    }
  }

  @Builder pageMenuItem(menu: SettingPageMenu, index: number, total: number, style: SettingIconStyle): void {
    if (menu && menu.icon) {
      Button({ type: DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Circle }) {
        if (style.fillColor !== undefined) {
          Image(menu.icon)
            .width(style.width)
            .height(style.height)
            .fillColor(style.fillColor)
            .draggable(false)
            .focusable(true)
        } else {
          Image(menu.icon)
            .width(style.width)
            .height(style.height)
            .draggable(false)
            .focusable(true)
        }
      }
      .accessibilityText(menu.style?.accessibilityText)
      .id(`${this.compId}.menu${index}.button`)
      .width(40)
      .height(40)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor(DeviceUtil.isDevicePc() ? this.layout?.backgroundColor :
        $r('sys.color.comp_background_tertiary'))
      .stateEffect(true)
      .margin({
        top: PADDING_8,
        end: DeviceUtil.isDevicePc() ? PADDING_0 : (((index + 1) === total) ? this.layout?.padding?.end : PADDING_0)
      })
      .onClick(menu.onClick ?? undefined)
      .onHover((isHover) => {
        TipsHelper.timeOutForOnHover(isHover, (isHover)=>{
          this.menuHoverIndex = isHover ? index : -1;
        });
      })
      .bindMenu(menu.builder ? menu.builder.builder(menu) : this.menuBuilder(menu.bindMenu, index,
        PageConfig.getInstance().getMenuStyle(menu.menuStyle)),
          { placement: Placement.BottomRight, showInSubWindow: false })
      .bindPopup(menu?.popup && this.menuHoverIndex === index,
        {
          builder: pageMenuPopup(menu?.popup?.message ?? ''),
          mask: menu?.popup?.mask ?? false,
          placement: menu?.popup?.placement ?? Placement.BottomLeft,
          targetSpace: menu?.popup?.targetSpace ?? '8vp',
          enableArrow: menu?.popup?.enableArrow ?? false,
        })
    } else {
      menu.builder?.builder(menu);
    }
  }

  @Builder pageMenu(): void {
    if (DataVerify.checkArray(this.pageInfo.menus)) {
      Row() {
        ForEach(this.pageInfo.menus, (item: SettingPageMenu, index: number) => {
          this.pageMenuItem(item, index, this.pageInfo.menus?.length ?? 0, this.getMenuIconStyle(item));
        })
      }
      .margin({
        top: DeviceUtil.isDevicePc() ? 4 : 0,
      })
    }
  }

  @Builder groupHeaderBuilder(group: SettingGroupModel, fixedPreviousGroup: boolean, fixed?: boolean): void {
    if (group.header) {
      if (fixed) {
        SettingGroupHeader({ group: group, compId: `${this.compId}.${group.id}.header` })
      } else {
        ListItem() {
          SettingGroupHeader({
            group: group,
            compId: `${this.compId}.${group.id}.header`,
            fixedPreviousGroup: fixedPreviousGroup,
          })
        }
      }
    }
  }

  @Builder groupFooterBuilder(group: SettingGroupModel, fixed?: boolean): void {
    if (group.footer) {
      if (fixed) {
        SettingGroupFooter({ group: group, compId: `${this.compId}.${group.id}.footer` })
      } else {
        ListItem() {
          SettingGroupFooter({ group: group, compId: `${this.compId}.${group.id}.footer` })
        }
      }
    }
  }

  @Builder pageGroup(group: SettingGroupModel, compId?: string, previous?: SettingGroupModel): void {
    if (group) {
      if (group.type === GroupType.GROUP_TYPE_CUSTOM) {
        if (group.builder) {
          ListItem() {
            group.builder.builder(group);
          }
        }
      } else {
        SettingGroup({
          groupInfo: group,
          compId: compId !== undefined ? `${compId}.${group.id}` : `${this.compId}.${group.id}`,
          pageCached: this.pageInfo.cached ? true : false,
          layout: PageConfig.getInstance().getGroupLayout(group, previous),
          sheetPageCtx: this.sheetPageCtx ?? undefined,
        })
      }
    }
  }

  // TODO: 当前仅处理了非fixed group
  private getPreviousGroup(index: number, groups?: SettingGroupModel[]): SettingGroupModel | undefined {
    if (index > 0) {
      return groups?.[index - 1];
    } else if (this.pageInfo.fixedGroups) {
      let fixedLen = this.pageInfo.fixedGroups.length;
      LogHelper.info(TAG, `fixed group.`);
      return this.pageInfo.fixedGroups[fixedLen - 1];
    }
    return undefined;
  }

  @Builder pageClipMask(radius: number): void {
    if (!this.isCircleScreen) {
      Row()
        .width(px2vp(this.cardWidth))
        .height(20)
        .clip(new Path({ commands:
          `M 0 0
          L 0 ${radius}
          Q 0 0 ${radius} 0
          L ${this.cardWidth - radius} 0
          Q ${this.cardWidth} 0 ${this.cardWidth} ${radius}
          L ${this.cardWidth} 0
          L 0 0`
        }))
        .backgroundColor(this.layout?.backgroundColor)
        .hitTestBehavior(HitTestMode.Transparent)
      Row()
        .offset({ x: 0, y: px2vp(this.cardHeight) - 20 })
        .width(px2vp(this.cardWidth))
        .height(20)
        .clip(new Path({ commands:
          `M 0 0
          Q 0 ${radius} ${radius} ${radius}
          L ${this.cardWidth - radius} ${radius}
          Q ${this.cardWidth} ${radius} ${this.cardWidth} 0
          L ${this.cardWidth} ${radius}
          L 0 ${radius}`
        }))
        .backgroundColor(this.layout?.backgroundColor)
    }
  }

  @Builder customContentBuilder(customContent?: SettingContentModel): void {
    if (customContent && customContent.builder) {
      customContent.builder.builder(customContent);
    }
  }

  @Builder
  pageTitleBar(titleBar?: SettingBaseModel): void {
    if (titleBar && titleBar.builder) {
      titleBar.builder.builder(titleBar);
    }
  }

  @Builder
  modalPageContent(param: PageContentParam): void {
    // 半模态界面有fixedGroups的场景
    if (this.pageInfo.fixedGroups) {
      Column() {
        this.pageFixedGroup()
        Stack({ alignContent: Alignment.Bottom }) {
          List({ scroller: this.scroller }) {
            if (this.pageInfo.header) {
              ListItem() {
                this.pageHeader(this.pageInfo.header, PageConfig.getInstance().getPageHeaderStyle(this.pageInfo.header))
              }
            }
            ForEach(param.groups, (item: SettingGroupModel, index: number) => {
              this.groupHeaderBuilder(item, (index === 0 && DataVerify.checkArray(this.pageInfo.fixedGroups)))
              this.pageGroup(item, param.compId, this.getPreviousGroup(index, param.groups))
              this.groupFooterBuilder(item)
            }, (item: SettingGroupModel) => item.id)
          }
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .onSizeChange((this.isCircleScreen || this.sheetPageCtx) ? undefined :
            (oldValue: SizeOptions, newValue: SizeOptions) => {
              this.onListSizeChange(newValue, param.tabIndex);
            })
          .onScrollStop(this.pageInfo.scrollListener?.onScrollStop)
          .onScrollStart(this.pageInfo.scrollListener?.onScrollStart)
          .onReachStart(this.pageInfo.scrollListener?.onReachStart)
          .onScroll(this.pageInfo.scrollListener?.onScroll)
          .borderRadius($r('sys.float.corner_radius_level10'))
        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          top: PADDING_12,
          bottom: PADDING_12,
          start: this.layout?.padding?.start,
          end: this.layout?.padding?.end
        })
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%')
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        List({ scroller: this.scroller }) {
          if (this.pageInfo.header) {
            ListItem() {
              this.pageHeader(this.pageInfo.header, PageConfig.getInstance().getPageHeaderStyle(this.pageInfo.header))
            }
          }

          ForEach(param.groups, (item: SettingGroupModel, index: number) => {
            this.groupHeaderBuilder(item, (index === 0 && DataVerify.checkArray(this.pageInfo.fixedGroups)))
            this.pageGroup(item, param.compId, this.getPreviousGroup(index, param.groups))
            this.groupFooterBuilder(item)
          }, (item: SettingGroupModel) => item.id)
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .padding({ start: this.layout?.padding?.start, end: this.layout?.padding?.end,
          bottom: this.layout?.padding?.bottom ?? null })
        .contentStartOffset(param.hasFixedGroup ? undefined : this.layout?.padding?.top?.value)
        .contentEndOffset(this.layout?.padding?.bottom?.value)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .onSizeChange((this.isCircleScreen || this.sheetPageCtx) ? undefined :
          (oldValue: SizeOptions, newValue: SizeOptions) => {
            this.onListSizeChange(newValue, param.tabIndex);
          })
        .onScrollStop(this.pageInfo.scrollListener?.onScrollStop)
        .onScrollStart(this.pageInfo.scrollListener?.onScrollStart)
        .onReachStart(this.pageInfo.scrollListener?.onReachStart)
        .onScroll(this.pageInfo.scrollListener?.onScroll)
        this.customContentBuilder(this.pageInfo.groupForeground)
      }
      .layoutWeight(1)
      this.customContentBuilder(this.pageInfo.stickBottomContent)
    }
  }

  @Builder pageContent(param: PageContentParam): void {
    List({ scroller: this.scroller }) {
      if (this.pageInfo.header) {
        ListItem() {
          this.pageHeader(this.pageInfo.header, PageConfig.getInstance().getPageHeaderStyle(this.pageInfo.header))
        }
      }

      ForEach(this.getGroups(param), (item: SettingGroupModel, index: number) => {
        // 若存在分帧加载机制，判断参数合法性后，再从小到大加载group卡片内容
        if (this.pageInfo?.frameCount === undefined || item.targetFrame === undefined ||
          item.targetFrame <= this.curFrameCount ) {
          this.groupHeaderBuilder(item, (index === 0 && DataVerify.checkArray(this.pageInfo.fixedGroups)))
          this.pageGroup(item, param.compId, this.getPreviousGroup(index, this.getGroups(param)))
          this.groupFooterBuilder(item)
        }
      }, (item: SettingGroupModel) => item.id)
    }
    .defaultFocus(PageConfig.getInstance().isCircleScreen() ? true : undefined)
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .clip(!this.useHdsNavUx())
    .scrollBar(PageConfig.getInstance().isCircleScreen() ? BarState.Off : this.barState ?? BarState.Auto)
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
    })
    .contentStartOffset(param.hasFixedGroup ? undefined : this.layout?.padding?.top?.value)
    .contentEndOffset(this.layout?.padding?.bottom?.value)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onSizeChange((this.isCircleScreen || this.sheetPageCtx) ? undefined :
      (oldValue: SizeOptions, newValue: SizeOptions) => {
        if (param?.ignoreSizeChange) {
          LogUtil.showInfo(TAG, `ignoreSizeChange, ${this.compId}`);
          return;
        }
        this.onListSizeChange(newValue, param.tabIndex);
      })
    .onScrollStop(this.pageInfo.scrollListener?.onScrollStop)
    .onScrollStart(this.pageInfo.scrollListener?.onScrollStart)
    .onReachStart(this.pageInfo.scrollListener?.onReachStart)
    .onScroll(this.pageInfo.scrollListener?.onScroll)
    .enableScrollInteraction(this.enableScrollInteraction)
  }

  private getGroups(param: PageContentParam): SettingGroupModel[] | BaseDataSource<SettingGroupModel> {
    if (this.pageInfo.type === PageType.PAGE_TYPE_DYNAMIC && param.dataSource) {
      return param.dataSource;
    }
    return param.groups;
  }

  @Builder pageContentWithScrollBar(param: PageContentParam): void {
    Stack({ alignContent: Alignment.TopEnd }) {
      List({ scroller: this.scroller }) {
        if (this.pageInfo.header) {
          ListItem() {
            this.pageHeader(this.pageInfo.header, PageConfig.getInstance().getPageHeaderStyle(this.pageInfo.header))
          }
        }
        ForEach(this.getGroups(param), (item: SettingGroupModel, index: number) => {
          this.groupHeaderBuilder(item, (index === 0 && DataVerify.checkArray(this.pageInfo.fixedGroups)))
          this.pageGroup(item, param.compId, this.getPreviousGroup(index, this.getGroups(param)))
          this.groupFooterBuilder(item)
        }, (item: SettingGroupModel) => item.id)
      }
      .borderRadius(20)
      .margin({
        start: this.layout?.padding?.start,
        end: this.layout?.padding?.end,
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .contentStartOffset(param.hasFixedGroup ? undefined : this.layout?.padding?.top?.value)
      .contentEndOffset(this.layout?.padding?.bottom?.value)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .onSizeChange((this.isCircleScreen || this.sheetPageCtx) ? undefined :
        (oldValue: SizeOptions, newValue: SizeOptions) => { this.onListSizeChange(newValue, param.tabIndex); })
      .onScrollStop(this.pageInfo.scrollListener?.onScrollStop)
      .onScrollStart(this.pageInfo.scrollListener?.onScrollStart)
      .onReachStart(this.pageInfo.scrollListener?.onReachStart)
      .onScroll(this.pageInfo.scrollListener?.onScroll)

      ScrollBar({
        scroller: this.scroller,
        direction: ScrollBarDirection.Vertical,
        state: this.barState ?? BarState.Auto
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder pageHome(): void {
    NavRouter() {
      Stack({ alignContent: Alignment.End }) {
        this.pageHomeContent();
      }
    }
    .id(this.compId)
    .backgroundColor(this.layout?.backgroundColor)
    .accessibilityLevel(AccessibilityLevelType.NO)
  }

  @Builder pageFixedGroup(): void {
    Column() {
      ForEach(this.pageInfo.fixedGroups, (item: SettingGroupModel) => {
        this.groupHeaderBuilder(item, false, true)
        SettingGroup({
          groupInfo: item,
          compId: `${this.compId}.${item.id}`,
          fixed: true,
          pageCached: this.pageInfo.cached ? true : false,
          layout: PageConfig.getInstance().getGroupLayout(item),
        })
        this.groupFooterBuilder(item, true)
      }, (item: SettingGroupModel) => item.id)
    }
    .width('100%')
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
      top: this.layout?.padding?.top,
    })
  }

  /**
   * 懒加载SegmentButton, 避免冷启动时就加载
   */
  loadSegmentButton(): boolean {
    if (!this.segmentButtonLoader) {
      this.segmentButtonLoader = segmentButtonLoader;
    }
    return true;
  }

  @Builder pageTabsButton(isTabsShow: boolean): void {
    if (isTabsShow && this.loadSegmentButton()) {
      this.segmentButtonLoader({
        tabContents: this.tabContents, compId: this.compId, selectedIndexes: this.selectedIndexes, layout: this.layout
      })
    }
  }

  @Builder pageTabsSwiper(tabs: SettingTabsModel[]): void {
    Swiper(this.swiperController) {
      ForEach(tabs, (item: SettingTabsModel, index: number) => {
        this.pageContent({
          groups: item.groups,
          compId: `${this.compId}.${item.id}`,
          hasFixedGroup: true,
          tabIndex: index
        })
      }, (item: SettingTabsModel) => item.id)
    }
    .id(`${this.compId}.Swiper`)
    .onChange((index: number) => {
      this.selectedIndexes = [index];
    })
    .index(this.selectedIndexes[0] ?? undefined)
    .disableSwipe(true)
    .indicator(false)
    .loop(false)
    .vertical(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder pageStandard(): void {
    NavDestination() {
      if(this.pageInfo.titleBar){
        this.pageTitleBar(this.pageInfo.titleBar);
      }
      if (this.pageInfo.fixedGroups) {
        this.pageFixedGroup()
        Stack({ alignContent: Alignment.Top }) {
          // oobe wlan界面,ux样式需要定制
          if (this.compId === 'Setting.Wlan' && this.pageInfo.layout?.hideTitleBar) {
            this.pageContentWithScrollBar({ groups: this.pageInfo.groups ?? [], hasFixedGroup: true,
              dataSource: this.dynamicDataSource })
          } else {
            this.pageContent({ groups: this.pageInfo.groups ?? [], hasFixedGroup: true,
              dataSource: this.dynamicDataSource })
          }
          this.pageClipMask(vp2px(20))
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .layoutWeight(1)
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      } else if (this.pageInfo.tabs) {
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            this.pageTabsButton(this.pageInfo.tabs.length === 2)
            Stack({ alignContent: Alignment.Top }) {
              this.pageTabsSwiper(this.pageInfo.tabs)
              this.pageClipMask(vp2px(20))
            }
            .layoutWeight(1)
          }.visibility(this.tabGroupPageChange ? Visibility.Hidden : Visibility.Visible)
          this.customContentBuilder(this.pageInfo.groupForeground)
          if(this.pageInfo.groups) {
            Stack({ alignContent: this.pageInfo.layout?.pageAlign ?? Alignment.Top }) {
              this.pageContent({
                groups: this.pageInfo.groups ?? [],
                dataSource: this.dynamicDataSource,
                ignoreSizeChange: !this.tabGroupPageChange
              })
              this.pageClipMask(vp2px(20))
            }
            .visibility(this.tabGroupPageChange ? Visibility.Visible : Visibility.None)
          }
        }
        .layoutWeight(1)
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      } else {
        Stack({ alignContent: this.pageInfo.layout?.pageAlign ?? Alignment.Top }) {
          this.pageContent({ groups: this.pageInfo.groups ?? [], dataSource: this.dynamicDataSource })
          this.pageClipMask(vp2px(20))
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .layoutWeight(1)
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      }
    }
    .id(this.compId)
    .size({ width: '100%', height: '100%' })
    .title(this.pageTitle as string, this.pageNavTitleOptions)
    .backgroundColor(this.layout?.backgroundColor)
    .hideTitleBar(this.layout?.hideTitleBar !== undefined ? this.layout?.hideTitleBar : this.isCircleScreen)
    .menus(this.isCircleScreen ? undefined : this.pageMenu())
    .onShown(() => { this.onPageShow(); })
    .onHidden(() => { this.onPageHide(); })
    .padding({
      left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
      right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
    })
    .onTouch((event: TouchEvent) => {
      this.pageInfo.onTouchEvent?.(event.type);
    })
    .onBackPressed(() => {
      if (this.pageInfo.compControl?.onBackPressed) {
        LogUtil.showInfo(TAG, `custom onBackPressed ${this.pageInfo.id}`);
        return this.pageInfo.compControl.onBackPressed(this.pageInfo);
      }
      return false;
    })
  }

  // private pageMenuHds(): Array<HdsNavigationBadgeIconOptions> {
  //   let menuItems: Array<HdsNavigationBadgeIconOptions> = [];
  //   if (this.pageInfo.menus) {
  //     let length: number = this.pageInfo.menus.length;
  //     for (let index = 0; index < length; index++) {
  //       let item: SettingPageMenu = this.pageInfo.menus[index];
  //       // menu builder param
  //       let menuParam: MenuBuildParam = {
  //         menu: item, iconStyle: this.getMenuIconStyle(item), count: length, index: index
  //       }
  //       menuItems.push(
  //         {
  //           content: {
  //             label: menuParam.iconStyle.accessibilityText,
  //             icon: item.icon || $r('sys.symbol.dot_grid_2x2'),
  //             componentId: `menu_${index}`,
  //             isEnabled: true,
  //             action: () => {
  //               let uiContext = this.getUIContext();
  //               let promptAction = uiContext.getPromptAction();
  //               let contentNode = new ComponentContent(uiContext, wrapBuilder(pageMenuBuilder), menuParam);
  //               try {
  //                 promptAction.openMenu(contentNode, { id: `menu_${index}` },
  //                   { placement: Placement.BottomRight });
  //               } catch (error) {
  //                 let message = (error as BusinessError).message;
  //                 let code = (error as BusinessError).code;
  //                 LogHelper.error(TAG, `SettingPage openMenu args error code is ${code}, message is ${message}`);
  //               }
  //             }
  //           }
  //         }
  //       );
  //     }
  //   }
  //   return menuItems;
  // }

  @Builder pageStandardHds(): void {
    NavDestination() {
      if(this.pageInfo.titleBar){
        this.pageTitleBar(this.pageInfo.titleBar);
      }
      if (this.pageInfo.fixedGroups) {
        this.pageFixedGroup()
        Stack({ alignContent: Alignment.Top }) {
          // oobe wlan界面,ux样式需要定制
          if (this.compId === 'Setting.Wlan' && this.pageInfo.layout?.hideTitleBar) {
            this.pageContentWithScrollBar({ groups: this.pageInfo.groups ?? [], hasFixedGroup: true,
              dataSource: this.dynamicDataSource })
          } else {
            this.pageContent({ groups: this.pageInfo.groups ?? [], hasFixedGroup: true,
              dataSource: this.dynamicDataSource })
          }
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .padding({
          left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
          right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
        })
        .layoutWeight(1)
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      } else if (this.pageInfo.tabs) {
        Stack({ alignContent: Alignment.Top }) {
          Column() {
            this.pageTabsButton(this.pageInfo.tabs.length === 2)
            Stack({ alignContent: Alignment.Top }) {
              this.pageTabsSwiper(this.pageInfo.tabs)
            }
            .layoutWeight(1)
          }.visibility(this.tabGroupPageChange ? Visibility.Hidden : Visibility.Visible)
          this.customContentBuilder(this.pageInfo.groupForeground)
          if(this.pageInfo.groups) {
            Stack({ alignContent: this.pageInfo.layout?.pageAlign ?? Alignment.Top }) {
              this.pageContent({ groups: this.pageInfo.groups ?? [], dataSource: this.dynamicDataSource })
            }
            .visibility(this.tabGroupPageChange ? Visibility.Visible : Visibility.None)
          }
        }
        .layoutWeight(1)
        .padding({
          left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
          right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
        })
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      } else {
        Stack({ alignContent: this.pageInfo.layout?.pageAlign ?? Alignment.Top }) {
          this.pageContent({ groups: this.pageInfo.groups ?? [], dataSource: this.dynamicDataSource })
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .padding({
          left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
          right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
        })
        .layoutWeight(1)
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      }
    }
    .id(this.compId)
    .size({ width: '100%', height: '100%' })
    .title(this.pageTitle)
    .backgroundColor(this.layout?.backgroundColor)
    .hideTitleBar(this.layout?.hideTitleBar !== undefined ? this.layout?.hideTitleBar : this.isCircleScreen)
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .onShown(() => { this.onPageShow(); })
    .onHidden(() => { this.onPageHide(); })
    .onTouch((event: TouchEvent) => {
      this.pageInfo.onTouchEvent?.(event.type);
    })
    .onBackPressed(() => {
      if (this.pageInfo.compControl?.onBackPressed) {
        LogUtil.showInfo(TAG, `custom onBackPressed ${this.pageInfo.id}`);
        return this.pageInfo.compControl.onBackPressed(this.pageInfo);
      }
      return false;
    })
  }

  @Builder pageCustom(builder?: WrappedBuilder<[object]>): void {
    builder?.builder(this.pageParam?.param);
  }

  aboutToAppear(): void {
    this.barState = this.pageInfo.barState;
    this.compId = `${this.pageParam?.router}.${this.pageInfo.id}`;
    if (this.pageInfo.type === PageType.PAGE_TYPE_MODAL) {
      this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    }
    LogHelper.info(TAG, `setting page ${this.compId} appear`);

    this.getTitleButtonRectWidth();

    this.dynamicDataSource = new DynamicGroupDataSource();
    if (this.pageInfo.compControl) {
      this.pageInfo.compControl.init({
        compId: this.compId,
        component: this.pageInfo,
        dataSource: this.dynamicDataSource as DynamicGroupDataSource,
        param: this.pageParam?.param
      });
    }
    if (!this.pageInfo.tabIndex) {
      this.pageInfo.tabIndex = this.pageInfo.type === PageType.PAGE_TYPE_HOME ?
        TabIndexConstants.TAB_INDEX_LEVEL1_PAGE : TabIndexConstants.TAB_INDEX_LEVEL2_PAGE;
    }
    this.tempTabIndex = this.pageInfo.tabIndex;

    if (!PageConfigVerify.checkSettingPageVaild(this.pageInfo)) {
      throw new Error(`invaild page config, page id: ${this.pageInfo.id}`);
    }

    this.preprocess(this.pageInfo);
    this.initDataSource(this.pageInfo);
    this.layout = PageConfig.getInstance().getPageLayout(this.pageInfo);
    this.pageNavTitleOptions =
      this.isCircleScreen ? undefined : {
        paddingStart: DeviceUtil.isDevicePc() ? undefined : this.layout?.padding?.start,
        mainTitleModifier: new TextModifier().id(this.compId + '.title_id')
          .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
      };

    let tabs = this.pageInfo.tabs;
    if (tabs) {
      this.swiperController = new SwiperController();
      if (tabs.length === 2) {
        this.segmentButtonLoader = segmentButtonLoader;
        this.tabContents = [tabs[0].content, tabs[1].content];
      }
    }

    if (this.pageInfo.type === PageType.PAGE_TYPE_HOME) {
      this.taskId = setTimeout(() => {
        this.needRenderGroup = true;
        clearTimeout(this.taskId);
      }, 150);
      this.registerHomePageEvent();
    } else {
      this.pageTitle = this.pageInfo.title ?? '';
      EventBus.getInstance().on(this.compId, this.eventCb);
    }

    let selectTabIndex: number[] | undefined = this.pageInfo.selectTabIndex;
    if (selectTabIndex) {
      this.selectedIndexes = selectTabIndex;
    }

    this.enableListenFrame();
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `setting page ${this.compId} disappear`);
    if (this.pageInfo.compControl) {
      this.pageInfo.compControl.destroy();
    }
    if (this.pageInfo.type === PageType.PAGE_TYPE_HOME) {
      this.taskId = null;
      this.unregisterHomePageEvent();
    } else {
      EventBus.getInstance().detach(this.compId, this.eventCb);
    }
    this.disableListenFrame();
  }

  onPageShow(): void {
    LogHelper.info(TAG, `page show, ${this.pageInfo.id}`);
    if (this.pageInfo.compControl?.onPageShow) {
      this.pageInfo.compControl.onPageShow(this.pageInfo);
    }
  }

  onPageHide(): void {
    LogHelper.info(TAG, `page hide, ${this.pageInfo.id}`);
    if (this.pageInfo.compControl?.onPageHide) {
      this.pageInfo.compControl.onPageHide(this.pageInfo);
    }
  }

  build() {
    if (this.pageInfo.type === PageType.PAGE_TYPE_CUSTOM) {
      this.pageCustom(this.pageParam?.pageCtx.pageBuilder)
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_STANDARD && this.useHdsNavUx()) {
      this.pageStandardHds()
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_STANDARD) {
      this.pageStandard()
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_HOME) {
      this.pageHome()
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_MODAL) {
      this.modalPageContent({ groups: this.pageInfo.groups ?? [] })
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_DYNAMIC && this.useHdsNavUx()) {
      this.pageStandardHds()
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_DYNAMIC) {
      this.pageStandard()
    }
  }
}

@Builder export function pageMenuPopup(message: string): void {
  Row() {
    Text(message)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_primary'))
      .lineHeight(20)
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
  .padding(8)
}

@Builder export function pageNavTitle(pageTitle: ResourceStr, padding: LengthMetrics | undefined)
  : CustomBuilder {
  Column() {
    Text(pageTitle)
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('sys.color.font_primary'))
      .padding(padding?.value)
      .fontWeight(FontWeight.Bold)
      .margin({
        top: -3
      })
  }
}

@Builder export function settingPageBuilder(param: object): void {
  SettingPage({
    pageParam: (param as PageParams),
    pageInfo: (param as PageParams).pageCtx.configGenerator(),
    scroller: (param as PageParams).listScroller ?? new Scroller()
  });
}

@Builder export function pageMenuBuilder(menuParam: MenuBuildParam) : void {
  if (menuParam && menuParam.menu.icon) {
    hdsMenuBuilder(menuParam.menu.bindMenu ?? [],
      menuParam.index,PageConfig.getInstance().getMenuStyle(menuParam.menu.menuStyle));
  } else {
    menuParam.menu.builder?.builder(menuParam.menu);
  }
}

@Builder export function hdsMenuBuilder(bindMenu: MenuElement[], menuIndex: number, menuStyle: SettingMenuStyle): void {
  if (bindMenu !== undefined && bindMenu.length >= 0) {
    Menu() {
      ForEach(bindMenu, (item: MenuElement, index: number) => {
        MenuItem({ content: item.value })
          .id(`.menuItem${index}`)
          .contentFont({
            size: $r('sys.float.Body_L'),
            weight: FontWeight.Medium,
          })
          .contentFontColor($r('sys.color.font_primary'))
          .onClick(() => {
            item.action();
          })
      })
    }
    .width(224).menuItemDivider({ strokeWidth: PADDING_1_PX, color: $r('sys.color.comp_divider') })
    .id(`.menu${menuIndex}`)
    .radius(menuStyle.borderRadius as Dimension || $r('sys.float.corner_radius_level4'))
  }
}