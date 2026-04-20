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

import i18n from '@ohos.i18n';
import {
  MenuSection,
  MenuPage,
  SettingsBaseMenu,
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { MenuDataSource } from '@ohos/settings.common/src/main/ets/core/model/datasource/MenuDataSource';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { HeaderPageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { TimeZonePageController } from '@ohos/settings.datetime/src/main/ets/controller/TimeZonePageController';
import { TimeZoneReusableEntryComponent } from '@ohos/settings.uikit/src/main/ets/component/BaseComponent';
import { MenusArray, MenuItemComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuGroupComponent';
import {
  CardSectionStyle,
  DefaultListStyle,
  PaddingCardSectionListStyle,
  EntryMenu,
  DefaultEntryMenuStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { TimeZoneListController } from '../controller/TimeZoneListController';
/* instrument ignore file */
const TAG: string = 'TimeZoneComponent : ';
const DEFAULT_CACHE_COUNT = 3;

interface Obj {
  A?: number,
  B?: number,
  C?: number,
  D?: number,
  E?: number,
  F?: number,
  G?: number,
  H?: number,
  I?: number,
  J?: number,
  K?: number,
  L?: number,
  M?: number,
  N?: number,
  O?: number,
  P?: number,
  Q?: number,
  R?: number,
  S?: number,
  T?: number,
  U?: number,
  V?: number,
  W?: number,
  X?: number,
  Y?: number,
  Z?: number,
}

@Component
export struct TimeZoneMenuPageComponent {
  @State menuPage?: MenuPage = undefined;
  @State pageStyle?: PageStyle = undefined;
  @State navPageStyle?: HeaderPageStyle = undefined;
  @State controller?: TimeZonePageController = undefined;
  scroller: Scroller = new Scroller;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;
  @State value: string[] = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z'];
  @State @Watch('selectTop') select: string = '';
  @State num: number = 1;
  @Provide scrollDistance: number = -1;
  @State objs: Obj = {};

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  selectTop() {
    this.num = this.value.indexOf(this.select);
  }

  build() {
    Column() {
      GridContainer({ columns: 12, sizeType: SizeType.MD, gutter: '12vp', margin: '0vp' }) {
        Column() {
          Flex({
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.Start,
            alignItems: ItemAlign.Center,
          }) {
            // 页中
            Row() {
              TimeZoneMenuListComponent({
                menusArray: this.menusArray,
                style: this.pageStyle?.listStyle as DefaultListStyle,
                uiRefresher: $uiRefresher,
                select: this.select,
                objs: this.objs,
              });
              AlphabetIndexer({ arrayValue: this.value, selected: this.num })
                .popupPosition({
                  x: 60,
                  y: 196
                })
                .margin({
                  top: $r('app.float.margin_16')
                })
                .alignSelf(ItemAlign.Start)
                .selectedColor($r('sys.color.ohos_id_color_text_primary_activated'))// 选中项文本颜色
                .popupColor($r('sys.color.ohos_id_color_text_primary_activated'))// 弹出框文本颜色
                .popupBackground($r('sys.color.ohos_id_color_card_bg'))// 弹出框背景颜色
                .usingPopup(true)// 是否显示弹出框
                .selectedFont({ size: $r('sys.float.ohos_id_text_size_caption'),
                  weight: FontWeight.Medium })// 选中项字体样式
                .font({ size: $r('sys.float.ohos_id_text_size_caption'), weight: FontWeight.Medium })
                .popupFont({ size: $r('sys.float.ohos_id_text_size_headline7'),
                  weight: FontWeight.Medium })// 弹出框内容的字体样式
                .itemSize(16)// 每一项的尺寸大小
                .alignStyle(IndexerAlign.Right)// 弹出框在索引条左侧弹出
                .onSelect((index: number) => {
                  if (this.value[index] == '#') {
                    this.scrollDistance = 0;
                    setTimeout(() => {
                      this.select = '#';
                    }, 50)
                  } else if (this.value[index] === 'A') {
                    this.scrollDistance = 0;
                  } else if (this.value[index] === 'B') {
                    this.scrollDistance = this.objs?.B as number;
                  } else if (this.value[index] === 'C') {
                    this.scrollDistance = this.objs?.C as number;
                  } else if (this.value[index] === 'D') {
                    this.scrollDistance = this.objs?.D as number;
                  } else if (this.value[index] === 'E') {
                    this.scrollDistance = this.objs?.E as number;
                  } else if (this.value[index] === 'F') {
                    this.scrollDistance = this.objs?.F as number;
                  } else if (this.value[index] === 'G') {
                    this.scrollDistance = this.objs?.G as number;
                  } else if (this.value[index] === 'H') {
                    this.scrollDistance = this.objs?.H as number;
                  } else if (this.value[index] === 'I') {
                    this.scrollDistance = this.objs?.I as number;
                  } else if (this.value[index] === 'J') {
                    this.scrollDistance = this.objs?.J as number;
                  } else if (this.value[index] === 'K') {
                    this.scrollDistance = this.objs?.K as number;
                  } else if (this.value[index] === 'L') {
                    this.scrollDistance = this.objs?.L as number;
                  } else if (this.value[index] === 'M') {
                    this.scrollDistance = this.objs?.M as number;
                  } else if (this.value[index] === 'N') {
                    this.scrollDistance = this.objs?.N as number;
                  } else if (this.value[index] === 'O') {
                    this.scrollDistance = this.objs?.O as number;
                  } else if (this.value[index] === 'P') {
                    this.scrollDistance = this.objs?.P as number;
                  } else if (this.value[index] === 'Q') {
                    this.scrollDistance = this.objs?.Q as number;
                  } else if (this.value[index] === 'R') {
                    this.scrollDistance = this.objs?.R as number;
                  } else if (this.value[index] === 'S') {
                    this.scrollDistance = this.objs?.S as number;
                  } else if (this.value[index] === 'T') {
                    this.scrollDistance = this.objs?.T as number;
                  } else if (this.value[index] === 'U') {
                    this.scrollDistance = this.objs?.U as number;
                  } else if (this.value[index] === 'V') {
                    this.scrollDistance = this.objs?.V as number;
                  } else if (this.value[index] === 'W') {
                    this.scrollDistance = this.objs?.W as number;
                  } else if (this.value[index] === 'X') {
                    this.scrollDistance = this.objs?.X as number;
                  } else if (this.value[index] === 'Y') {
                    this.scrollDistance = this.objs?.Y as number;
                  } else if (this.value[index] === 'Z') {
                    this.scrollDistance = this.objs?.Z as number;
                    setTimeout(() => {
                      this.select = 'Z';
                    }, 50)
                  }
                })
                .onRequestPopupData((index: number) => {
                  return [];
                })
            }
            .width('100%')
          }
          .padding({
            start: PADDING_16,
            end: PADDING_24,
          })
          .width('100%')
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .height('100%')
        .useSizeType({
          xs: { span: 12, offset: 0 },
          sm: { span: 12, offset: 0 },
          md: { span: 12, offset: 0 },
          lg: { span: 8, offset: 2 }
        })
      }
      .size({ width: '100%', height: '100%' })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding(this.pageStyle?.pagePadding as Padding)
    .size(this.pageStyle?.size as SizeOptions)
    .clip(this.pageStyle?.clip as boolean | CircleAttribute | EllipseAttribute | PathAttribute | RectAttribute)
    .borderRadius(this.pageStyle?.borderRadius as Length)
    .backgroundColor(this.pageStyle?.backgroundColor as ResourceColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .id('time_zone');
  }

  private getMenus(): MenusArray {
    let menus = this.menuPage?.getMenus();
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus?.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  aboutToAppear() {
    if (this.menuPage) {
      LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage.getMenus().length}`);
      this.bindScroller();
      if (this.menuPage.style instanceof PageStyle) {
        this.pageStyle = this.menuPage.style;
      }
      if (this.menuPage.navHeaderStyle instanceof PageStyle) {
        this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
      }
      this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as TimeZonePageController;
      this.menusArray = this.getMenus();
    }
  }

  private bindScroller(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.controller?.aboutToDisappear();
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setDialogPageRoot(undefined);
    }
  }
}

@Component
export struct TimeZoneMenuListComponent {
  @ObjectLink menusArray: MenusArray;
  style?: DefaultListStyle;
  @Link uiRefresher: UiRefresher;
  @Link select: string;
  @Link objs: Obj;
  scroller?: Scroller;

  build() {
    if (this.menusArray) {
      ForEach(this.menusArray.menus, (menu: SettingsBaseMenu) => {
        if (menu instanceof MenuSection) {
          TimeZoneMenuSectionComponent({ menuSection: menu, select: this.select, objs: this.objs });
        } else {
          MenuItemComponent({ menu: menu });
        }
      }, (menu: SettingsBaseMenu) => {
        return menu.toString();
      });
    }
  }
}

@Component
export struct TimeZoneMenuSectionComponent {
  tag: string = 'TimeZoneMenuSectionComponent : ';
  menuSection?: MenuSection;
  @State style?: CardSectionStyle = undefined;
  @State controller?: TimeZoneListController = undefined;
  // setup callback on change to uiRefresher, we will update menu in it
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  // define as @State, observed. Changes will be pased to children
  @State menusArray?: MenusArray = undefined;
  @Link select: string;
  @Link objs: Obj;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      // 内容
      Column() {
        Stack({ alignContent: Alignment.TopEnd }) {
          // Pass this.menusArray instead of call to getMenus, that creates new object on every call
          LazyMenuListComponent({
            menusArray: this.menusArray,
            style: new PaddingCardSectionListStyle() as PaddingCardSectionListStyle,
            uiRefresher: this.uiRefresher,
            isMenuFlat: true,
            parentKey: this.menuSection?.key,
            select: this.select,
            objs: this.objs,
          })
        }
        .onHover((isHover?: boolean) => {
          this.controller?.handleHoverEvent(isHover as boolean);
        })
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .constraintSize(this.style?.constraintSize as ConstraintSizeOptions)
    .flexGrow(1)
    .padding(this.style?.padding as Padding)
    .clip(this.style?.clip as boolean | CircleAttribute | EllipseAttribute | PathAttribute | RectAttribute)
    .borderRadius(this.style?.borderRadius as Length)
    .backgroundColor(this.style?.backgroundColor as ResourceColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private getMenus(): MenusArray {
    if (this.menuSection) {
      let menus = this.menuSection.getMenus();
      if (!menus) {
        menus = []
      }
      LogUtil.debug(`${this.tag} getMenus ${menus?.length},  key ${this.menuSection.getLogKey()}`);
      this.style = this.menuSection.style as CardSectionStyle;
      return new MenusArray(menus);
    }
    return new MenusArray([]);
  }

  aboutToAppear(): void {
    if (this.menuSection) {
      LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection.getLogKey()}`);
      this.style = this.menuSection.style as CardSectionStyle;
      this.controller = this.menuSection.getControllerInstance(this.uiRefresher) as TimeZoneListController;
      // initialize this.menusArray on appear
      this.menusArray = this.getMenus();
    }

  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct LazyMenuListComponent {
  @ObjectLink @Watch('uiRefresherWatch') menusArray: MenusArray;
  style?: PaddingCardSectionListStyle | CardSectionStyle;
  @Link @Watch('uiRefresherWatch') uiRefresher: UiRefresher;
  @Link select: string;
  @Link objs: Obj;
  @Consume @Watch('change') scrollDistance?: number;
  flag: boolean = true;
  flags: boolean = false;
  scroller?: Scroller = new Scroller();
  lazyMenus: MenuDataSource = new MenuDataSource([]);
  isMenuFlat: boolean = false;
  parentKey: string = '';
  pinyin = i18n.Transliterator.getInstance('Han-Latin');
  pinyins = i18n.Transliterator.getInstance('Latin-ASCII');

  uiRefresherWatch(): void {
    this.getLazyMenus();
  }

  change(): void {
    this.scroller?.scrollToIndex(this.scrollDistance);
    this.scrollDistance = -1;
  }

  build() {
    if (this.menusArray && this.lazyMenus.totalCount() > 0) {

      List({ scroller: this.scroller }) {
        LazyForEach(this.lazyMenus, (menu: SettingsBaseMenu, index) => {
          if (menu.isVisible()) {
            ListItem() {
              if (this.parentKey === 'time_zone_list_group') {
                // 此处特判时钟列表采用reusable组件
                TimeZoneReusableEntryComponent({
                  menu: menu as EntryMenu,
                  style: menu.style as DefaultEntryMenuStyle,
                  controller: menu.getControllerInstance(this.uiRefresher) as MenuController,
                  uiRefresher: this.uiRefresher,
                  showTitle: menu.title?.toString(),
                  showSummary: menu.summary?.toString(),
                })
                  .padding(this.getListItemPaddings(index))
              } else {
                MenuItemComponent({ menu: menu, isMenuFlat: this.isMenuFlat })
              }
            }
            .backgroundColor(this.style?.backgroundColor)
            .borderRadius(this.getListItemBorderRadius(index))
          }
        }, (menu: SettingsBaseMenu) => {
          if (this.parentKey === 'time_zone_list_group') {
            return `${menu.title?.toString()} + ${menu.summary?.toString()}`;
          } else {
            return menu.toString();
          }
        });
      }
      .contentStartOffset(PADDING_16.value)
      .contentEndOffset(PADDING_16.value)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .onScrollIndex((start: number, end: number) => {
        let str = this.lazyMenus.mDataSource[start].title;
        let res = this.pinyin.transform(str as string);
        let res1 = this.pinyins.transform(res);
        if (this.flag) {
          this.flag = false;
          let obj: Obj = {};
          for (let i = 0; i < this.lazyMenus.mDataSource.length; i++) {
            let k = '';
            if (this.lazyMenus.mDataSource[i].title === '长春 (中国)' ||
              this.lazyMenus.mDataSource[i].title === '长沙 (中国)') {
              k = 'C';
            } else {
              let head = this.pinyin.transform(this.lazyMenus.mDataSource[i].title as string);
              let heads = this.pinyins.transform(head);
              k = heads[0].toLocaleUpperCase();
            }
            if (k === 'A' && !obj.A) {
              obj.A = i;
            } else if (k === 'B' && !obj.B) {
              obj.B = i;
            } else if (k === 'C' && !obj.C) {
              obj.C = i;
            } else if (k === 'D' && !obj.D) {
              obj.D = i;
            } else if (k === 'E' && !obj.E) {
              obj.E = i;
            } else if (k === 'F' && !obj.F) {
              obj.F = i;
            } else if (k === 'G' && !obj.G) {
              obj.G = i;
            } else if (k === 'H' && !obj.H) {
              obj.H = i;
            } else if (k === 'I' && !obj.I) {
              obj.I = i;
            } else if (k === 'J' && !obj.J) {
              obj.J = i;
            } else if (k === 'K' && !obj.K) {
              obj.K = i;
            } else if (k === 'L' && !obj.L) {
              obj.L = i;
            } else if (k === 'M' && !obj.M) {
              obj.M = i;
            } else if (k === 'N' && !obj.N) {
              obj.N = i;
            } else if (k === 'O' && !obj.O) {
              obj.O = i;
            } else if (k === 'P' && !obj.P) {
              obj.P = i;
            } else if (k === 'Q' && !obj.Q) {
              obj.Q = i;
            } else if (k === 'R' && !obj.R) {
              obj.R = i;
            } else if (k === 'S' && !obj.S) {
              obj.S = i;
            } else if (k === 'T' && !obj.T) {
              obj.T = i;
            } else if (k === 'U' && !obj.U) {
              obj.U = i;
            } else if (k === 'V' && !obj.V) {
              obj.V = i;
            } else if (k === 'W' && !obj.W) {
              obj.W = i;
            } else if (k === 'X' && !obj.X) {
              obj.X = i;
            } else if (k === 'Y' && !obj.Y) {
              obj.Y = i;
            } else if (k === 'Z' && !obj.Z) {
              obj.Z = i;
            }
          }
          this.objs = obj;
        }

        if (str === '长春 (中国)' || str === '长沙 (中国)') {
          this.select = 'C';
        } else {
          if (this.flags) {
            this.select = res1[0].toLocaleUpperCase();
          } else {
            this.flags = true;
          }
        }
      })
      .scrollBar(BarState.Off)
      .height('100%')
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: this.getListStrokeWidth() > 1 ? this.style?.divider?.strokeWidth as Length : 0,
        color: this.style?.divider?.color,
        startMargin: this.style?.divider?.startMargin,
        endMargin: this.style?.divider?.endMargin,
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .lanes(this.style?.lanes as number)
      .padding({
        left: $r('app.float.padding_4'),
        right: $r('app.float.padding_4')
      })
      .margin({
        left: this.style?.margin?.left,
        right: this.style?.margin?.right
      })
      .id('time_list')
    }
  }

  private getListItemBorderRadius(index: number): Length | BorderRadiuses {
    let radius = $r('app.float.padding_20');
    if (index === 0) {
      return { topLeft: radius, topRight: radius };
    }
    let len = this.menusArray?.menus?.length;
    if (len === index + 1) {
      return { bottomLeft: radius, bottomRight: radius };
    }
    return 0;
  }

  private getListItemPaddings(index: number): Length | LocalizedPadding | Padding {
    let padding = $r('app.float.padding_4');
    if (index === 0) {
      return { left: padding, right: padding, top: padding };
    }
    let len = this.menusArray?.menus?.length;
    if (len === index + 1) {
      return { left: padding, right: padding, bottom: padding };
    }
    return { left: padding, right: padding };
  }

  private getLazyMenus(): void {
    let menus = this.menusArray.menus;
    if (!menus) {
      menus = []
    }
    this.lazyMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    this.getLazyMenus();
  }

  private getListStrokeWidth(): number {
    if (this.menusArray.menus.length <= 1) {
      return 0;
    }

    let num = this.menusArray.menus.filter((menu: SettingsBaseMenu) => {
      return menu.isVisible();
    }).length;
    return num;
  }
}