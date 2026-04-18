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

import { PADDING_24, PADDING_8 } from '../../constant/StyleConstant';
import { DeviceUtil } from '../../utils/BaseUtils';
import { LanguageUtils } from '../../utils/LanguageUtils';
import { DefaultPageConfig } from '../common/DefaultPageConfig';
import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { PageParams } from '../common/PageLoader';
import { SettingItemModel, SettingSheetTitleStyle } from '../model/SettingItemModel';
import {
  DefaultSettingPageModel,
  SettingPageLayout,
  SettingPageModel,
  SettingSheetPageContext
} from '../model/SettingPageModel';
import { SettingBaseState, SettingCompState, SettingContentState, SettingStateType } from '../model/SettingStateModel';
import { SettingPage } from './SettingPage';
/* instrument ignore file */
const TAG: string = 'SettingSheet';

@Extend(Image)
function iconStyle(width: Length, height: Length, margin?: LocalizedPadding) {
  .width(width)
  .height(height)
  .draggable(false)
  .syncLoad(true)
  .matchTextDirection(true)
  .margin(margin)
}

@Component
struct SettingSheet {
  pageParam?: PageParams;
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();
  private compId: string = '';
  private layout?: SettingPageLayout;
  private sheetTitleLayout?: SettingSheetTitleStyle;
  private sheetPageCtx?: SettingSheetPageContext;
  private isSheetHome: boolean = false;
  @State pathStack: NavPathStack = new NavPathStack();
  @State pageTitle: ResourceStr = '';

  private procTitleEvent(value: SettingBaseState): void {
    let titleContent = value as SettingContentState;
    if (!titleContent?.content) {
      LogHelper.error(TAG, 'invaild title state event');
      return;
    }
    LogHelper.info(TAG, `enabled state change.`);
    this.pageTitle = titleContent.content;
  }

  private registerPageEvent(): void {
    EventBus.getInstance().on(this.compId, (data: object) => {
      if (!(data instanceof Map)) {
        LogHelper.error(TAG, 'invaild eventbus data type.');
      }

      let eventData = data as Map<SettingStateType, SettingBaseState>;
      eventData.forEach((value: SettingBaseState, key: SettingStateType) => {
        switch (key) {
          case SettingStateType.STATE_TYPE_PAGE_TITLE:
            this.procTitleEvent(value);
            break;
          default:
            LogHelper.error(TAG, `invaild event data key: ${key}`);
            break;
        }
      })
    });
  }

  private unregisterPageEvent(): void {
    EventBus.getInstance().off(this.compId);
  }

  @Builder
  sheetTitle(): void {
    Row() {
      if (this.pageInfo.titleIcon) {
        Image(this.pageInfo.titleIcon)
          .iconStyle(40, 40, { end: PADDING_8 })
      }
      if (this.pageInfo.showBackIcon) {
        Button({ type: DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .fontSize('24vp')
            .fontColor([$r('sys.color.ohos_id_color_primary')])
            .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
            .draggable(false)
            .accessibilityText($r('app.string.back_to_parent_menu'))
            .accessibilityRole(AccessibilityRoleType.BUTTON)
        }
        .width(40)
        .height(40)
        .backgroundColor(DeviceUtil.isDevicePc() ? Color.Transparent :
          $r('sys.color.comp_background_tertiary'))
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') :
          $r('sys.float.corner_radius_level10'))
        .margin({ end: PADDING_8 })
        .onClick(() => {
          this.pageInfo.backIconAction?.action();
          LogHelper.info(TAG, `click to back sheet page ${this.compId}`);
        })
      }
      Text(this.pageTitle)
        .fontSize('20fp')
        .maxFontScale(1.75)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)

      Button({ type: DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Circle }) {
        Image($r('app.media.ic_close'))
          .iconStyle(18, 18)
          .fillColor($r('sys.color.icon_primary'))
      }
      .accessibilityText($r('app.string.dialog_disable'))
      .width(40)
      .height(40)
      .backgroundColor(DeviceUtil.isDevicePc() ? Color.Transparent :
        $r('sys.color.comp_background_tertiary'))
      .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') :
        $r('sys.float.corner_radius_level10'))
      .stateEffect(true)
      .margin({ start: PADDING_24 })
      .onClick(() => {
        this.pageInfo.closeIconAction?.action();
        LogHelper.info(TAG, `click to close sheet page ${this.compId}`);
        if (this.sheetPageCtx?.itemComp) {
          let item: SettingItemModel = this.sheetPageCtx.itemComp as SettingItemModel;
          item.onItemEvent?.(new Map([[
            SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingCompState
          ]]));
        }
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ start: this.layout?.padding?.start, end: this.layout?.padding?.end, top: PADDING_8 })
    .backgroundColor(DeviceUtil.isDevicePc() ?
      this.layout?.backgroundColor : $r('app.color.component_ultra_thick_panel'))
  }

  @Builder
  sheetPageBuilder(param: PageParams): void {
    if (param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  @Builder
  pagesMap(name: string, param: object): void {
    if (param) {
      this.sheetPageBuilder(param as PageParams)
    }
  }

  aboutToAppear(): void {
    this.compId = `${this.pageParam?.router}.SheetPage.${this.pageInfo.id}`;
    LogHelper.info(TAG, `sheet page ${this.compId} appear`);

    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    this.layout = PageConfig.getInstance().getPageLayout(this.pageInfo);
    LogHelper.info(TAG, `sheet page ${this.compId} appear tk-- ${this.layout.padding?.start?.value}`);
    this.sheetTitleLayout = DefaultPageConfig.getInstance().getDefaultSheetTitleLayout();
    this.pageTitle = this.pageInfo.title ?? '';
    this.registerPageEvent();
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
      this.isSheetHome = true;
    }
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `sheet page ${this.compId} disappear`);
    this.unregisterPageEvent();
  }

  build() {
    if (this.isSheetHome) {
      Navigation(this.pathStack) {
        SettingPage({ pageParam: this.pageParam, pageInfo: this.pageInfo,
          scroller: this.pageParam?.listScroller ?? new Scroller() })
      }
      .id(this.compId)
      .size({ width: '100%', height: '100%' })
      .backgroundColor(this.layout?.backgroundColor)
      .backgroundBlurStyle(this.layout?.blurStyle)
      .title({ builder: this.sheetTitle(), height: this.sheetTitleLayout?.titleHeight })
      .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .navDestination(this.pagesMap)
    } else {
      NavDestination() {
        SettingPage({ pageParam: this.pageParam, pageInfo: this.pageInfo,
          scroller: this.pageParam?.listScroller ?? new Scroller() })
      }
      .id(this.compId)
      .size({ width: '100%', height: '100%' })
      .title(this.pageTitle as string)
      .backgroundColor(this.layout?.backgroundColor)
      .backgroundBlurStyle(this.layout?.blurStyle)
      .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .padding({ top: 8 })
      .onBackPressed(() => {
        if (this.pageInfo.compControl?.onBackPressed) {
          return this.pageInfo.compControl.onBackPressed(this.pageInfo);
        }
        return false;
      })
    }
  }
}

@Builder
export function settingSheetBuilder(param: object): void {
  SettingSheet({
    pageParam: (param as PageParams),
    pageInfo: (param as PageParams).pageCtx.configGenerator(),
  });
}