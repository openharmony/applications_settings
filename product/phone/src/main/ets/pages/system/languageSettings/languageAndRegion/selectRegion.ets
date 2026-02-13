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

import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { languageAndRegionModel } from '@ohos/settings.language/src/main/ets/model/LanguageAndRegionModel';
import { BasicDataSource } from '@ohos/settings.language/src/main/ets/model/BasicDataSource';
import { CountryAndRegion } from '@ohos/settings.language/src/main/ets/model/CountryAndRegion';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { FOCUS_BOX_PADDING_METRICS, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { SubHeaderComponent } from '../SubHeader';
/* instrument ignore file */
const CHOOSE_REGION_ENTRY: string = 'choose_region_entry';
const ENTER_REGION_ENTRY: string = 'enter_region_entry';
const ROUTER_NAME = 'select_region_entry';
const COMMON_GRID_COL_OPTIONS: GridColOptions = {
  span: {
    xs: 12,
    sm: 12,
    md: 12,
    lg: 12,
  },
  offset: {
    xs: 0,
    md: 0,
    sm: 0,
    lg: 0,
  },
};

/**
 * Home Page of  Select Region
 */
@Builder
export function SelectRegionLoader($$: Params): void {
  SelectRegion();
}

@Component
export struct SelectRegion {
  @State touchedItemName: string = '';
  private regionList: RegionDataSource = new RegionDataSource(languageAndRegionModel.getSystemRegions());
  private TAG: string = `Settings SelectRegion`;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State clickable: boolean = true;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  isScrolling: boolean = false;
  timeoutId: number | undefined = undefined;

  @Builder
  regionAllList(): void {
    GridRow() {
      GridCol(COMMON_GRID_COL_OPTIONS) {
        Column() {
          Blank().height($r('app.float.navigation_56'))
          Scroll() {
            List() {
              ListItem() {
                SubHeaderComponent({ titleContent: $r('app.string.currentRegion') })
              }

              ListItem() {
                CurrentRegion();
              }

              ListItem() {
                SubHeaderComponent({ titleContent: $r('app.string.allRegion') })
              }

              ListItem() {
                this.allRegionList()
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }
          .margin({bottom: $r('app.float.navigation_56')})
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .padding({
            left: $r('app.float.distance_16'),
            right: $r('app.float.distance_16'),
            bottom: $r('app.float.distance_16')
          })
          .scrollBar(BarState.Auto)
          .align(Alignment.TopStart)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
          .height('100%')
          .onScroll((xOffset: number, yOffset: number) => {
            this.isScrolling = true;
          })
          .onScrollStop(() => {
            this.isScrolling = false;
          })
        }
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .width('100%')
        .height('100%');
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .zIndex(1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  build() {
    NavDestination() {
      Stack() {
        this.regionAllList()

        Column() {
        }.width('100%')
        .height('100%')
        .zIndex(this.clickable ? 0 : 2)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title($r('app.string.selectRegion'))
    // .titleBar({content: {title: {mainTitle: ResourceUtil.getStringSync($r('app.string.selectRegion'))}}})
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .hideTitleBar(false)
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .onShown(() => {
      LogUtil.info(`${this.TAG} onPageShow`);
      DynamicLoader.getInstance().pageTransitionSuccess(this.TAG);
    })
    .onHidden(() => {
      LogUtil.info(`${this.TAG} onPageHide`);
    })
  }

  @Builder
  allRegionList(): void {
    List() {
      LazyForEach(this.regionList, (item: CountryAndRegion, index: number) => {
        RegionItem({
          item: item, clickable: this.clickable, onClickedRegion: () => {
            HiSysEventUtil.reportEntryEvent(CHOOSE_REGION_ENTRY, item?.getCountry());
            setTimeout(() => {
              languageAndRegionModel.setSystemRegion(item?.getCountry());
              this.setClickable();
            }, 0);
          }
        })
      }, (item: string) => item);
    }
    .id('allRegions')
    .scrollBar(BarState.Off)
    .padding($r('app.float.distance_4'))
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .divider({
      strokeWidth: '1px',
      startMargin: $r('app.float.distance_8'),
      endMargin: $r('app.float.distance_8'),
      color: $r('sys.color.comp_divider'),
    });
  }

  private setClickable() {
    this.clickable = false;
    this.timeoutId = setTimeout(() => {
      this.clickable = true;
      const pathNames: string[] = this.pathInfos?.getAllPathName() ?? [];
      if (pathNames.length === 0) {
        return;
      }
      const topName: string = pathNames[pathNames.length - 1];
      if (ROUTER_NAME !== topName) {
        return;
      }
      this.pathInfos?.pop();
      AccessibilityUtils.requestFocusAccessibility('languageAndRegionPage.selectRegion.column');
    }, 1500);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    HiSysEventUtil.reportEntryEvent(ENTER_REGION_ENTRY, '');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    clearTimeout(this.timeoutId);
  }
}

@Component
struct RegionItem {
  @Prop item: CountryAndRegion;
  @State isHover: boolean = false;
  @State isTouched: boolean = false;
  @State clickable: boolean = true;
  onClickedRegion: () => void = () => {
  };

  build() {
    Row() {
      Text(this.item?.getRegion())
        .fontSize($r('app.float.font_16'))
        .fontWeight(FontWeight.Medium)
        .constraintSize({ minHeight: $r('app.float.wh_value_48') })
        .width('100%')
        .margin({ start: PADDING_8,
          top: FontScaleUtils.getCurrentContentPadding(),
          bottom: FontScaleUtils.getCurrentContentPadding() })
        .fontColor(languageAndRegionModel.isSystemRegion(this.item?.getCountry()) ?
        $r('sys.color.ohos_fa_text_activated') : $r('sys.color.ohos_fa_text_primary'))
        .textAlign(TextAlign.Start);
    }
    .backgroundColor(this.isTouched ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width('100%')
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event)
    })
    .onHover((isHovered: boolean) => {
      this.isHover = isHovered;
    })
    .onClick(()=>{
      this.onClickedRegion();
    })
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStateIconStyles,
    })
  }

  @Styles
  normalStateIconStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.ohos_id_color_hover') : Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  private onTouchEvent(event: TouchEvent) {
    if (event?.type === TouchType.Down) {
      this.isTouched = true;
    }
    if (event?.type === TouchType.Up) {
      this.isTouched = false;
    }
  }
}

/**
 * Text Component
 */
@Component
struct CurrentRegion {
  @StorageProp('currentRegion') currentRegion: string = languageAndRegionModel.getSysDisplayRegion();

  build() {
    Column() {
      Row() {
        Text(this.currentRegion)
          .fontSize($r('app.float.font_16'))
          .constraintSize({ minHeight: $r('app.float.wh_value_48') })
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_fa_text_activated'))
          .width('100%')
          .padding({
            start: PADDING_8,
            top: FontScaleUtils.getCurrentContentPadding(),
            bottom: FontScaleUtils.getCurrentContentPadding(),
            end: PADDING_8
          })
          .textAlign(TextAlign.Start);
      }
      .height('auto')
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level8'))
    }
    .justifyContent(FlexAlign.Center)
    .padding($r('app.float.distance_4'))
    .constraintSize({ minHeight: $r('app.float.wh_value_56') })
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'));
  }
}

/**
 * RegionDataSource For Lazy Loading
 */
class RegionDataSource extends BasicDataSource {
  private regionArray: CountryAndRegion[] = [];

  constructor(regionArray: CountryAndRegion[]) {
    super();
    this.regionArray = regionArray;
  }

  public totalCount(): number {
    return this.regionArray.length;
  }

  public getData(index: number): CountryAndRegion {
    return this.regionArray[index];
  }
}
