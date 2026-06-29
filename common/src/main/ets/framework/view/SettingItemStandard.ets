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

import { SymbolGlyphModifier } from '@ohos.arkui.modifier';
import { LengthMetrics } from '@ohos.arkui.node';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_1_5,
  PADDING_1_PX,
  PADDING_2,
  PADDING_4,
  PADDING_8
} from '../../constant/StyleConstant';
import {
  AccessibilityLevelType,
  AccessibilityUtils,
  TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS,
  TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS
} from '../../utils/AccessibilityUtils';
import { DeviceUtil } from '../../utils/BaseUtils';
import { DisplayUtils } from '../../utils/DisplayUtils';
import { FontScaleUtils } from '../../utils/FontScaleUtils';
import { ResourceUtil } from '../../utils/ResourceUtil';
import { DataVerify } from '../common/DataVerify';
import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import { ModalLoader } from '../common/ModalLoader';
import { Optional } from '../common/Optional';
import { PageConfig } from '../common/PageConfig';
import { PageContext, PageParams } from '../common/PageLoader';
import { PageRouter } from '../common/PageRouter';
import { SettingBaseModel } from '../model/SettingBaseModel';
import {
  DefaultSettingItemModel,
  ItemDetailType,
  ItemPos,
  ItemResultType,
  ItemType,
  SettingCheckboxModel,
  SettingCheckboxStyle,
  SettingDialogModel,
  SettingIconModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemDetailModel,
  SettingItemDividerModel,
  SettingItemLayout,
  SettingItemModel,
  SettingItemResultModel,
  SettingMenuStyle,
  SettingRadioModel,
  SettingRadioStyle,
  SettingSelectMenu,
  SettingTextModel,
  SettingTextStyle,
  SettingTextType,
  SettingToggleModel,
  SettingToggleStyle,
} from '../model/SettingItemModel';
import { SettingSheetPageContext } from '../model/SettingPageModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCheckboxState,
  SettingCompState,
  SettingDetailState,
  SettingDialogState,
  SettingIconState,
  SettingLayoutState,
  SettingModalState,
  SettingRadioState,
  SettingResultState,
  SettingSelectMenuState,
  SettingStateType,
  SettingTextState,
  SettingToggleState
} from '../model/SettingStateModel';

@Extend(Image)
function iconStyle(style: SettingIconStyle, iconState?: SettingIconVM) {
  .width(style.width)
  .height(style.height)
  .objectFit(style.objectFit)
  .borderRadius(style.borderRadius)
  .draggable(style.draggable)
  .interpolation(style.interpolation)
  .edgeAntialiasing(style.edgeAntialiasing)
  .border(style.border)
  .clip(style.clip)
  .syncLoad(true)
  .matchTextDirection(style.mirrored)
  .accessibilityText(style?.accessibilityText)
  .accessibilityLevel(style?.accessibilityLevel)
  .opacity(iconState?.opacity ?? style.opacity)
}

@Extend(SymbolGlyph)
function symbolIconStyle(style: SettingIconStyle) {
  .fontSize(style.height)
  .fontColor([style?.fillColor])
  .borderRadius(style.borderRadius)
  .draggable(style.draggable)
  .renderingStrategy(style.renderingStrategy)
  .accessibilityText(style?.accessibilityText)
  .accessibilityLevel(style?.accessibilityLevel)
  .fontWeight(style?.fontWeight)
}

@Extend(Text)
function textStyle(style: SettingTextStyle, fontColor?: ResourceColor, titleState?: SettingTextVM) {
  .fontSize(style.fontSize)
  .fontColor(fontColor ?? style.fontColor)
  .fontWeight(style.fontWeight)
  .fontFamily(style.fontFamily)
  .textAlign(style.textAlign)
  .maxLines(style.maxLines)
  .textOverflow({ overflow: style.textOverflow })
  .minFontSize(style.minFontSize)
  .maxFontSize(style.maxFontSize)
  .wordBreak(style.wordBreak)
  .lineHeight(style.lineHeight)
  .opacity(titleState?.opacity ?? style.opacity)
  .direction(style.direction)
  .copyOption(style.copyOption)
}

@Extend(Toggle)
function toggleStyle(style?: SettingToggleStyle) {
  .margin(style?.margin)
  .hoverEffect(style?.hoverEffect ?? HoverEffect.None)
  .width(style?.width)
  .height(style?.height)
}

@Observed
class SettingIconVM {
  public icon?: ResourceStr | PixelMap = '';
  public opacity?: number | Resource;
}

@Observed
class SettingTextVM {
  public content: ResourceStr = '';
  public fontColor?: ResourceColor;
  public opacity?: number | Resource;
}

@Observed
class SettingToggleVM {
  public state: boolean = false;
  public enabled?: boolean = true;
  public onAllowChanged?: (isOn: boolean) => boolean;
}

type SheetDetents = [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?]

@Observed
class SettingRadioVM {
  public state: boolean = false;
}

@Observed
class SettingDetailVM {
  public onItemClick?: (component: SettingBaseModel) => void;
}

const TAG: string = 'SettingItemStandard';
const UX_DESIGN_SHEET_HEIGHT_PAD: number = 320;

@Component
export struct SettingItemStandard {
  itemInfo: SettingItemModel = DefaultSettingItemModel.get();
  compId: string = '';
  homePageComp: boolean = false;
  parentId?: string;
  openDialog?: (item: SettingItemModel, dialog: SettingDialogModel) => void;
  closeDialog?: () => void;
  sheetPageCtx?: SettingSheetPageContext;
  private isCircleScreen: boolean = PageConfig.getInstance().isCircleScreen();
  private layout?: SettingItemLayout;
  private maxWidthPrec: Length = DisplayUtils.getScreenWidth() * 0.67;
  private currentFontSizeScale?: number;
  private isLargeFontMode: boolean = false;
  private detailState: SettingDetailVM = new SettingDetailVM();
  @State itemPos: number = 0;
  @State isSelected: boolean = false;
  @State isShowSelectedBackColor: boolean = false;
  @State enabledState: boolean = true;
  @State iconState: SettingIconVM = new SettingIconVM();
  @State titleIconState: SettingIconVM = new SettingIconVM();
  @State titleState: SettingTextVM = new SettingTextVM();
  @State despState: SettingTextVM = new SettingTextVM();
  @State resultState: SettingTextVM | SettingIconVM | SettingToggleVM | SettingRadioVM = new SettingTextVM();
  @State minHeigth: Length = 0;
  @State isModalShow: boolean = false;
  @State menuSelectIndex: number = this.itemInfo.detail?.menu?.defaultFocus !== undefined ?
    this.itemInfo.detail?.menu?.defaultFocus : 0;
  @State itemRadioChecked: boolean = false;
  @State itemCheckboxSelected: boolean = false;
  @State isHover: boolean = false;
  @State isVisible: boolean = true;
  @State sheetHeight?: SheetSize | Length = undefined;
  @State sheetKeyboardAvoidMode?: SheetKeyboardAvoidMode = undefined;
  @State sheetDetents?: SheetDetents = undefined;
  @State isSheetCenter: boolean = false;
  @State isMenuShow: boolean = false;
  private oldToggleState:boolean = false;

  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invalid eventbus data type.');
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };

  private buildPageParam(pageUrl: string, pageCtx: PageContext, item?: SettingItemModel): PageParams {
    if (item && this.sheetPageCtx) {
      this.sheetPageCtx.param = item;
    }
    return {
      router: this.compId.split('.')[0],
      pageUrl: pageUrl,
      pageCtx: {
        configGenerator: pageCtx.configGenerator,
        pageBuilder: pageCtx.pageBuilder
      },
      param: this.sheetPageCtx ? this.sheetPageCtx :
        {
          itemComp: this.itemInfo,
          param: item,
        } as SettingSheetPageContext
    }
  }

  private hasBindSheet(detail?: SettingItemDetailModel): boolean {
    if (!detail) {
      return false;
    }
    if (detail.type === ItemDetailType.DETAIL_TYPE_CUSTOM) {
      return detail.destination !== undefined || detail.sheetBuilder !== undefined;
    }
    return (detail.type === ItemDetailType.DETAIL_TYPE_MODAL) && (detail.destination !== undefined ||
      detail.sheetBuilder !== undefined);
  }

  private getSheetHeight(): SheetSize | Length | undefined {
    if (this.isLargeFontMode) {
      return SheetSize.LARGE;
    }
    if (this.isSheetCenter) {
      const firstSize: SheetSize | Length | undefined = this.sheetDetents ? this.sheetDetents[0] : undefined;
      // 如果sheetDetents第一个就是SheetSize.LARGE，说明需要一个大窗口（不是320的高度规格）
      return firstSize === SheetSize.LARGE ? SheetSize.LARGE : (this.sheetHeight || UX_DESIGN_SHEET_HEIGHT_PAD);
    } else {
      return this.sheetHeight;
    }
  }

  private getSheetDetents(): SheetDetents | undefined {
    if (this.isLargeFontMode) {
      return [SheetSize.LARGE];
    }
    return this.isSheetCenter ? undefined : this.sheetDetents;
  }

  private buildSheetOptions(userCfg?: SheetOptions): SheetOptions {
    return {
      height: this.getSheetHeight(),
      width: userCfg?.width ?? undefined,
      detents: this.getSheetDetents(),
      showInSubWindow: userCfg?.showInSubWindow ?? false,
      keyboardAvoidMode: this.sheetKeyboardAvoidMode,
      dragBar: userCfg?.dragBar !== undefined ? userCfg.dragBar : false,
      showClose: userCfg?.showClose !== undefined ? userCfg.showClose : false,
      title: userCfg?.title ?? undefined,
      preferType: userCfg?.preferType ?? SheetType.CENTER,
      backgroundColor: userCfg?.backgroundColor ?? $r('sys.color.ohos_id_color_dialog_bg'),
      maskColor: userCfg?.maskColor ?? $r('sys.color.mask_fourth'),
      blurStyle: userCfg?.blurStyle ?? BlurStyle.NONE,
      onTypeDidChange: (sheetType: SheetType) => {
        LogHelper.info(TAG, `item bind sheet type change, compID: ${this.compId} sheetType: ${sheetType}`);
        // pad 分屏场景会改变模态框的形式
        this.isSheetCenter = sheetType === SheetType.CENTER;
      },
      shouldDismiss: (sheetDismiss: SheetDismiss) => {
        LogHelper.info(TAG, `item bind sheet dismiss, compID: ${this.compId}`);
        userCfg?.shouldDismiss?.(sheetDismiss);
        sheetDismiss.dismiss();
      },
      onWillAppear: () => {
        LogHelper.info(TAG, `item bind sheet will appear, compID: ${this.compId}`);
        userCfg?.onWillAppear?.();
      },
      onAppear: () => {
        LogHelper.info(TAG, `item bind sheet appear, compID: ${this.compId}`);
        userCfg?.onAppear?.();
      },
      onDisappear: () => {
        LogHelper.info(TAG, `item bind sheet disappear, compID: ${this.compId}`);
        userCfg?.onDisappear?.();
      },
      onWillDisappear: () => {
        LogHelper.info(TAG, `item bind sheet will disappear, compID: ${this.compId}`);
        this.isModalShow = false;
      },
      onWillDismiss: (action: DismissSheetAction) => {
        LogHelper.info(TAG, `item bind sheet will dismiss, compID: ${this.compId}`);
        userCfg?.onWillDismiss?.(action);
      },
      onWillSpringBackWhenDismiss: (springBackAction: SpringBackAction) => {
        LogHelper.info(TAG, `item bind sheet will springBack when dismiss, compID: ${this.compId}`);
        userCfg?.onWillSpringBackWhenDismiss?.(springBackAction);
      }
    };
  }

  private supportMenu(detail?: SettingItemDetailModel): boolean {
    if (!detail) {
      return false;
    }
    return detail.type === ItemDetailType.DETAIL_TYPE_MENU && detail.menu !== undefined;
  }

  private isSupportClick(item: SettingItemModel): boolean {
    if (!item.detail && !item.compControl?.onClick) {
      if (item.result?.type === ItemResultType.RESULT_TYPE_RADIO ||
        item.result?.type === ItemResultType.RESULT_TYPE_CHECKBOX ||
        (PageConfig.getInstance().isCircleScreen() && item.result?.type === ItemResultType.RESULT_TYPE_TOGGLE)) {
        return true;
      }
      return false;
    }
    return true;
  }

  private onHomePageSelected(): boolean {
    LogHelper.info(TAG, `${this.compId} change to selected`);
    this.isShowSelectedBackColor = PageConfig.getInstance().isSplitMode();
    let lastKey: string = AppStorage.get('currentHomeKey') as string;
    if (lastKey === this.compId) {
      return false;
    }
    notifyCompStateChange(lastKey,
      new Map([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
        { state: false } as SettingCompState]]));
    AppStorage.setOrCreate('currentHomeKey', this.compId);
    return true;
  }

  private getItemDividerMargin(divider?: SettingItemDividerModel, icon?: SettingIconModel): LocalizedPadding {
    if (divider?.leftPadding) {
      return { start: divider.leftPadding };
    }

    if (!icon) {
      return {};
    }

    let iconStyle = PageConfig.getInstance().getIconStyle(icon);
    return { start: LengthMetrics.vp((iconStyle.width as number) + (this.layout?.leftMiddleSpace?.value ?? 0)) };
  }

  private initTextState(state: SettingTextVM, textCtx: SettingTextModel): void {
    state.content = textCtx.content;
    state.fontColor = PageConfig.getInstance().getTextStyle(textCtx).fontColor;
  }

  private storeTextState(state: SettingTextVM, textCtx: SettingTextModel): void {
    textCtx.content = state.content;
    if (!textCtx.style) {
      textCtx.style = {};
    }
    textCtx.style.fontColor = state.fontColor;
  }

  private initItemContent(item: SettingItemModel): void {
    if (item.enabled !== undefined) {
      this.enabledState = item.enabled;
    }
    if (item.icon) {
      this.iconState.icon = item.icon.icon;
    }
    if (item.icon?.style?.opacity) {
      this.iconState.opacity = item.icon.style.opacity;
    }
    if (item.title) {
      item.title.textType = SettingTextType.TEXT_TYPE_PRIMARY;
      this.initTextState(this.titleState, item.title);
    }
    if (item.title?.style?.opacity) {
      this.titleState.opacity = item.title.style.opacity;
    }
    if (item.titleIcon) {
      this.titleIconState.icon = item.titleIcon.icon;
    }
    if (item.desc) {
      item.desc.textType = SettingTextType.TEXT_TYPE_SECONDARY;
      this.initTextState(this.despState, item.desc);
    }
    if (item.detail && (item.detail.iconType === undefined)) {
      item.detail.iconType = SettingIconType.ICON_TYPE_ARROW;
    }
    if (item.detail?.menu?.defaultFocus) {
      this.menuSelectIndex = item.detail.menu.defaultFocus;
    }
    if (item.detail?.onItemClick) {
      this.detailState.onItemClick = item.detail.onItemClick;
    }
    if (item.result) {
      if (item.result.type === ItemResultType.RESULT_TYPE_TEXT) {
        (item.result.result as SettingTextModel).textType = SettingTextType.TEXT_TYPE_SECONDARY;
        this.initTextState(this.resultState as SettingTextVM, item.result.result as SettingTextModel);
      } else if (item.result.type === ItemResultType.RESULT_TYPE_IMAGE) {
        (item.result.result as SettingIconModel).iconType = SettingIconType.ICON_TYPE_TIP;
        (this.resultState as SettingIconVM).icon = (item.result.result as SettingIconModel).icon;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_TOGGLE) {
        (this.resultState as SettingToggleVM).state = (item.result.result as SettingToggleModel).state;
        (this.resultState as SettingToggleVM).enabled = (item.result.result as SettingToggleModel).enabled ?? true;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_RADIO) {
        if ((item.result.result as SettingRadioModel).checked) {
          this.itemRadioChecked = true;
        }
      } else if (item.result.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
        if ((item.result.result as SettingCheckboxModel).selected) {
          this.itemCheckboxSelected = true;
        }
      }
    }
    if (this.hasBindSheet(item.detail)) {
      this.sheetHeight = item.detail?.sheetOptions?.height ?? undefined;
      this.sheetDetents = item.detail?.sheetOptions?.detents;
      this.sheetKeyboardAvoidMode = item.detail?.sheetOptions?.keyboardAvoidMode;
    }
  }

  /* instrument ignore next */
  private storeItemContent(item: SettingItemModel): void {
    item.enabled = this.enabledState;
    if (item.icon) {
      item.icon.icon = this.iconState.icon;
    }
    if (item.title) {
      this.storeTextState(this.titleState, item.title);
    }
    if (item.desc) {
      this.storeTextState(this.despState, item.desc);
    }
    if (item.result) {
      if (item.result.type === ItemResultType.RESULT_TYPE_TEXT) {
        this.storeTextState(this.resultState as SettingTextVM, item.result.result as SettingTextModel);
      } else if (item.result.type === ItemResultType.RESULT_TYPE_IMAGE) {
        (item.result.result as SettingIconModel).icon = (this.resultState as SettingIconVM).icon;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_TOGGLE) {
        (item.result.result as SettingToggleModel).state = (this.resultState as SettingToggleVM).state;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_RADIO) {
        (item.result.result as SettingRadioModel).checked = this.itemRadioChecked;
      }
    }
  }

  private updateTextState(value: SettingBaseState, state: SettingTextVM): void {
    let textState = value as SettingTextState;
    if (!textState) {
      LogHelper.error(TAG, 'invalid text state event');
      return;
    }

    if (textState.content !== undefined && textState.content !== state.content) {
      state.content = textState.content;
    }
    if (textState.fontColor && textState.fontColor !== state.fontColor) {
      state.fontColor = textState.fontColor;
    }
    if (textState.opacity && textState.opacity !== state.opacity) {
      state.opacity = textState.opacity;
    }
  }

  /* instrument ignore next */
  private updateItemEnabled(value: SettingBaseState, state: boolean): void {
    let enabledState = value as SettingCompState;
    if (!enabledState) {
      LogHelper.error(TAG, 'invalid enabled state event');
      return;
    }

    LogHelper.info(TAG, `enabled state change: ${JSON.stringify(enabledState)}`);
    if (enabledState.state !== undefined && enabledState.state !== this.enabledState) {
      this.enabledState = enabledState.state;
    }
  }

  /* instrument ignore next */
  private updateIconState(value: SettingBaseState, state: SettingIconVM): void {
    let iconState = value as SettingIconState;
    if (!iconState) {
      LogHelper.error(TAG, 'invalid icon state event');
      return;
    }

    LogHelper.info(TAG, `icon state change: ${JSON.stringify(iconState)}`);
    if (iconState.icon && iconState.icon !== state.icon) {
      state.icon = iconState.icon;
    }
    if (iconState.opacity && iconState.opacity !== state.opacity) {
      state.opacity = iconState.opacity;
    }
  }

  /* instrument ignore next */
  private updateDetailState(value: SettingBaseState, state: SettingDetailVM): void {
    let detailState = value as SettingDetailState;
    if (!detailState) {
      LogHelper.error(TAG, 'invalid detail state event');
      return;
    }
    LogHelper.info(TAG, 'detail state change');
    if (detailState.onItemClick) {
      state.onItemClick = detailState.onItemClick;
    }
  }

  /* instrument ignore next */
  private updateLayoutState(value: SettingBaseState, state: SettingItemLayout | undefined): void {
    let layoutState = value as SettingLayoutState;
    if (!layoutState) {
      LogHelper.error(TAG, 'invalid layout state event');
      return;
    }
    LogHelper.info(TAG, 'layout state change');
    if (state?.background && layoutState?.background?.pressedBackgroundColor !==
      state?.background?.pressedBackgroundColor) {
      state.background.pressedBackgroundColor = layoutState?.background?.pressedBackgroundColor;
    }
  }

  /* instrument ignore next */
  private updateTitleIconState(value: SettingBaseState, state: SettingIconVM): void {
    let titleIconState = value as SettingIconState;
    if (!titleIconState) {
      LogHelper.error(TAG, 'invaild titleIcon state event');
      return;
    }
    LogHelper.info(TAG, 'titleIcon state change');
    state.icon = titleIconState.icon;
  }

  /* instrument ignore next */
  private updateToggleState(value: SettingBaseState, state: SettingToggleVM): void {
    let toggleState = value as SettingToggleState;
    if (!toggleState) {
      LogHelper.error(TAG, 'invalid toggle state event');
      return;
    }

    LogHelper.info(TAG, `toggle state change: ${JSON.stringify(toggleState)}`);
    if (toggleState.state !== undefined && toggleState.state !== state.state) {
      state.state = toggleState.state;
    }
    if (toggleState.enabled !== undefined && toggleState.enabled !== state.enabled) {
      state.enabled = toggleState.enabled;
    }
    if (toggleState.onAllowChanged !== undefined && toggleState.onAllowChanged !== state.onAllowChanged) {
      state.onAllowChanged = toggleState.onAllowChanged;
    }
  }

  /* instrument ignore next */
  private updateRadioState(value: SettingBaseState): void {
    const radioState: SettingRadioState = value as SettingRadioState;
    if (!radioState) {
      LogHelper.error(TAG, 'invalid radio state event');
      return;
    }

    LogHelper.info(TAG, `radio state change: ${JSON.stringify(radioState)}`);
    if (radioState.checked !== this.itemRadioChecked) {
      this.itemRadioChecked = radioState.checked;
    }
  }

  /* instrument ignore next */
  private updateCheckboxState(value: SettingBaseState): void {
    let checkboxState: SettingCheckboxState = value as SettingCheckboxState;
    if (!checkboxState) {
      LogHelper.error(TAG, 'invalid checkbox state event');
      return;
    }

    LogHelper.info(TAG, `checkbox state change: ${checkboxState.selected}`);
    if (checkboxState.selected !== this.itemCheckboxSelected) {
      this.itemCheckboxSelected = checkboxState.selected;
    }
  }

  private updateResultState(value: SettingBaseState, state: SettingTextVM | SettingIconVM | SettingToggleVM | SettingRadioVM): void {
    let result = value as SettingResultState;
    if (!result || result.type !== this.itemInfo.result?.type) {
      LogHelper.error(TAG, 'invalid result state event');
      return;
    }

    LogHelper.info(TAG, `item component result update, compId: ${this.compId}`);
    switch (result.type) {
      case ItemResultType.RESULT_TYPE_TEXT:
        this.updateTextState(result.result, state as SettingTextVM);
        break;

      case ItemResultType.RESULT_TYPE_IMAGE:
        this.updateIconState(result.result, state as SettingIconVM);
        break;

      case ItemResultType.RESULT_TYPE_TOGGLE:
        this.updateToggleState(result.result, state as SettingToggleVM);
        break;

      case ItemResultType.RESULT_TYPE_RADIO:
        this.updateRadioState(result.result);
        break;

      case ItemResultType.RESULT_TYPE_CHECKBOX:
        this.updateCheckboxState(result.result);
        break;

      default:
        LogHelper.error(TAG, `invalid result type: ${result.type}`);
        break;
    }
  }

  /* instrument ignore next */
  private updateItemSelected(value: SettingBaseState): void {
    let state = value as SettingCompState;
    LogHelper.info(TAG, `set item selected state to ${state.state}, compId: ${this.compId}`);
    if (state.state) {
      if (this.homePageComp) {
        this.isShowSelectedBackColor = PageConfig.getInstance().isSplitMode();
      }
    } else {
      // 消除之前的选中状态
      this.isShowSelectedBackColor = false;
    }
  }

  /* instrument ignore next */
  private procDialogEvent(item: SettingItemModel, dialog: SettingDialogModel): void {
    LogHelper.info(TAG, `item ${dialog?.contentBuilder ? 'open' : 'close'} dialog event, compId: ${this.compId}`);
    if (!dialog || (!dialog.contentBuilder && !dialog.message)) {
      this.closeDialog?.();
    } else {
      this.openDialog?.(item, dialog);
    }
  }

  /* instrument ignore next */
  private procSheetEvent(state: SettingModalState): void {
    if (state.state === false) {
      LogHelper.info(TAG, `close item modal sheet, compId: ${this.compId}`);
      this.isModalShow = false;
      return;
    }
    this.sheetDetents = state.sheetDetents;
    this.sheetHeight = state.sheetHeight;
    this.sheetKeyboardAvoidMode = state.keyboardAvoidMode;
    if (state.state === true) {
      LogHelper.info(TAG, `open item modal sheet, compId: ${this.compId}`);
      this.isModalShow = true;
    }
  }

  private procItemPosChange(state: SettingCompState) {
    LogHelper.info(TAG, `item pos change to ${state.state}, compId: ${this.compId}`);
    if (state.state) {
      this.itemPos |= ItemPos.ITEM_POS_END;
    } else {
      this.itemPos &= ~ItemPos.ITEM_POS_END;
    }
  }

  private procItemIsGroupStartChange(state: SettingCompState) {
    LogHelper.info(TAG, `group start pos change to ${state.state}, compId: ${this.compId}`);
    if (state.state) {
      this.itemPos |= ItemPos.ITEM_POS_START;
    } else {
      this.itemPos &= ~ItemPos.ITEM_POS_START;
    }
  }

  /* instrument ignore next */
  private updateDespState(value: SettingTextState): void {
    if (value.content !== undefined && value.content !== this.despState.content) {
      this.minHeigth = PageConfig.getInstance().getItemMinHeigth(this.itemInfo, (value.content !== ''));
      LogHelper.info(TAG, `update min heigth to ${this.minHeigth}`);
    }

    this.updateTextState(value, this.despState);

    if (!this.itemInfo.desc) {
      this.itemInfo.desc = { content: '', textType: SettingTextType.TEXT_TYPE_SECONDARY };
    } else {
      this.itemInfo.desc.textType = SettingTextType.TEXT_TYPE_SECONDARY;
    }
  }

  private procItemMenuChange(item: SettingItemModel, menu: SettingSelectMenuState): void {
    if (!menu || !DataVerify.checkArray(menu.items)) {
      LogHelper.error(TAG, 'invalid item menu state change');
      return;
    }

    if (item.detail?.type !== ItemDetailType.DETAIL_TYPE_MENU) {
      return;
    }

    item.detail.menu = menu;
    this.menuSelectIndex = (menu?.defaultFocus !== undefined) ? menu?.defaultFocus : 0;
  }

  private procItemVisible(state: SettingCompState): void {
    LogHelper.info(TAG, `item visible to ${state.state}, compId: ${this.compId}`);
    if (state.state === undefined || state.state === this.isVisible) {
      LogHelper.warn(TAG, 'the state is not empty or no update required');
      return;
    }
    this.isVisible = state.state;
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      switch (key) {
        case SettingStateType.STATE_TYPE_ITEM_ENABLED:
          this.updateItemEnabled(value, this.enabledState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_ICON:
          this.updateIconState(value, this.iconState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_TITLE:
          this.updateTextState(value, this.titleState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_DESP:
          this.updateDespState(value as SettingTextState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_RESULT:
          this.updateResultState(value, this.resultState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_SELECTED:
          this.updateItemSelected(value);
          break;

        case SettingStateType.STATE_TYPE_ITEM_DIALOG:
          this.procDialogEvent(this.itemInfo, value as SettingDialogState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_SHEET:
          this.procSheetEvent(value as SettingModalState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_POS:
          this.procItemPosChange(value as SettingCompState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START:
          this.procItemIsGroupStartChange(value as SettingCompState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_MENU:
          this.procItemMenuChange(this.itemInfo, value as SettingSelectMenuState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_VISIBLE:
          this.procItemVisible(value as SettingCompState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_TITLE_ICON:
          this.updateTitleIconState(value, this.titleIconState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_DETAIL:
          this.updateDetailState(value, this.detailState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_LAYOUT:
          this.updateLayoutState(value, this.layout);
          break;

        default:
          LogHelper.error(TAG, `invalid event data key: ${key}`);
          break;
      }
    })
  }

  private onDetailInteraction(item: SettingItemModel, detail: SettingItemDetailModel, isSelectionChanged: boolean): void {
    if (detail.type === ItemDetailType.DETAIL_TYPE_CUSTOM) {
      LogHelper.info(TAG, `custom detail onClick, item: ${this.compId}`);
      this.detailState.onItemClick?.(item);
    } else if (detail.type === ItemDetailType.DETAIL_TYPE_NAVIGATE) {
      LogHelper.info(TAG, `navigate to ${detail.destination}`);
      PageRouter.push(detail.destination as string, this.itemInfo, false, undefined, false, undefined, isSelectionChanged);
    } else if (detail.type === ItemDetailType.DETAIL_TYPE_DIALOG) {
      if (detail.dialog) {
        this.openDialog?.(item, detail.dialog);
      }
    } else if (detail.type === ItemDetailType.DETAIL_TYPE_MODAL) {
      if (this.sheetPageCtx) {
        let pageCtx = ModalLoader.getPageContext(detail.destination as string);
        if (!pageCtx.isPresent()) {
          LogHelper.info(TAG, `jump modal page ${detail.destination} failed, item ${this.compId}`);
          return;
        }
        LogHelper.info(TAG, `jump modal page, item ${this.compId}`);
        // 添加新页面到绑定的设置项上
        this.sheetPageCtx.pathStack?.pushPathByName(detail.destination,
          this.buildPageParam(detail.destination as string, pageCtx.get(), item));
      } else {
        LogHelper.info(TAG, `entry modal page, item ${this.compId}`);
        this.isModalShow = true;
      }
    }
  }

  private onItemClick(item: SettingItemModel): void {
    console.log("zzzzzz onItemClick")
    let isSelectionChanged: boolean = false;
    if (this.homePageComp) {
      // 主页分栏场景，点击才能选中
      isSelectionChanged = this.onHomePageSelected();
    }

    if (item.detail && !item.detail.ignoreClick) {
      if (item.compControl?.onRouterPrepare) {
        item.compControl.onRouterPrepare(item);
      }
      this.onDetailInteraction(item, item.detail, isSelectionChanged);
    } else if (item.compControl?.onClick) {
      LogHelper.info(TAG, `comp ctrl onClick, item: ${this.compId}`);
      item.compControl?.onClick(item);
    } else if (item.result?.type === ItemResultType.RESULT_TYPE_RADIO) {
      if (!this.itemRadioChecked) {
        (item.result.result as SettingRadioModel).onCheck?.(true, this.itemInfo);
        this.itemRadioChecked = true;
      }
    } else if (item.result?.type === ItemResultType.RESULT_TYPE_TOGGLE && PageConfig.getInstance().isCircleScreen()) {
      let isOn = (this.resultState as SettingToggleVM).state;
      LogHelper.info(TAG, `Toggle switch is ${isOn}, compId: ${this.compId}`);
      (this.resultState as SettingToggleVM).state = !isOn;
      EventBus.getInstance().emit(`${this.compId}.toggle`, { state: !isOn });
      (item.result.result as SettingToggleModel).onChanged?.(!isOn);
    }
    if (item.result?.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
      this.itemCheckboxSelected = !this.itemCheckboxSelected;
    }
  }

  private onItemTouch(item: SettingItemModel, touchType: TouchType): void {
    // 没有detail时，不支持选中背景
    if (!item.detail) {
      return;
    }

    item.onTouchEvent?.(touchType);
    if (touchType === TouchType.Down) {
      this.isSelected = true;
    } else if (touchType === TouchType.Up) {
      this.isSelected = false;
    }
  }

  /* instrument ignore next */
  private onMouseEvent(item: SettingItemModel, event: MouseEvent): void {
    // 没有detail时，不支持选中背景
    if (!item.detail) {
      return;
    }

    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private getNormalColor(): ResourceColor | undefined {
    if (this.isShowSelectedBackColor) {
      return $r('app.color.item_standard_background_color');
    }
    if (this.isHover && this.isSupportClick(this.itemInfo)) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return this.layout?.background?.normalBackgroundColor;
  }

  private getPressedColor(): ResourceColor | undefined {
    if (PageConfig.getInstance().isSplitMode() && this.homePageComp && this.isShowSelectedBackColor) {
      return $r('sys.color.interactive_click');
    }
    return this.layout?.background?.pressedBackgroundColor;
  }

  private getItemPressedColor(item: SettingItemModel): ResourceColor | undefined {
    if (this.isSupportClick(item)) {
      return this.getPressedColor();
    }

    if (this.isCircleScreen) {
      return this.layout?.background?.normalBackgroundColor;
    }
    return undefined;
  }

  private titleSizeRestricted(result?: SettingItemResultModel): boolean {
    return !!result && (result.type === ItemResultType.RESULT_TYPE_TEXT ||
      result.type === ItemResultType.RESULT_TYPE_CUSTOM);
  }

  @Builder itemIconBuilder(iconStyle: SettingIconStyle, iconMargin?: LocalizedPadding): void {
    if (iconStyle.builder) {
      iconStyle.builder?.builder(this.itemInfo)
    } else if (iconStyle.fillColor !== undefined) {
      Image(this.iconState.icon)
        .id(`${this.compId}.icon`)
        .iconStyle(iconStyle, this.iconState)
        .fillColor(iconStyle.fillColor)
        .margin(iconMargin)
    } else {
      Image(this.iconState.icon)
        .id(`${this.compId}.icon`)
        .iconStyle(iconStyle, this.iconState)
        .margin(iconMargin)
    }
  }

  @Builder itemSymbolIconBuilder(iconStyle: SettingIconStyle, iconMargin?: LocalizedPadding): void {
    SymbolGlyph(this.iconState.icon as Resource)
      .id(`${this.compId}.symbolIcon`)
      .symbolIconStyle(iconStyle)
      .margin(iconMargin)
  }

  @Builder itemTitleBuilder(item: SettingItemModel): void {
    if (this.titleIconState.icon) {
      this.itemTitleWithIconBuilder(PageConfig.getInstance().getTextStyle(item.title),
        PageConfig.getInstance().getIconStyle(item.titleIcon), { start: PADDING_4 });
    } else {
      Text(this.titleState.content)
        .id(`${this.compId}.title`)
        .textStyle(PageConfig.getInstance().getTextStyle(item.title), this.titleState.fontColor, this.titleState)
    }
  }

  @Builder
  itemTitleWithIconBuilder(textStyle: SettingTextStyle, iconStyle: SettingIconStyle,
    iconMargin?: LocalizedPadding): void {
    Row() {
      Column() {
        Text(this.titleState.content)
          .id(`${this.compId}.title`)
          .textStyle(textStyle, this.titleState.fontColor, this.titleState)
      }
      .alignItems(HorizontalAlign.Start)
      .flexShrink(1)
      Image(this.titleIconState.icon)
        .id(`${this.compId}.icon`)
        .iconStyle(iconStyle, this.iconState)
        .margin(iconMargin)
        .fillColor(iconStyle?.fillColor)
    }
    .width('100%')
    .flexShrink(1)
  }

  @Builder itemDespBuilder(textStyle: SettingTextStyle, textMargin: Padding): void {
    Text(this.despState.content)
      .id(`${this.compId}.desp`)
      .textStyle(textStyle, this.despState.fontColor, this.titleState)
      .margin(textMargin)
      .wordBreak(WordBreak.BREAK_WORD)
  }

  @Builder itemRadioBuilder(radio: SettingRadioModel, style: SettingRadioStyle): void {
    if (this.itemRadioChecked || style.showUnchecked) {
      Radio({ value: this.itemInfo.id, group: this.parentId, indicatorType: style.indicatorType })
        .id(`${this.compId}.result`)
        .width(style.width)
        .height(style.height)
        .checked(this.itemRadioChecked)
        .radioStyle(style.radioStyle)
        .margin(0) // 覆盖掉ark组件自带margin
        .hitTestBehavior(HitTestMode.None)
        .onChange((isChecked: boolean) => {
          if (isChecked === false) {
            this.itemRadioChecked = false;
            radio.onCheck?.(false, this.itemInfo);
          }
        })
    }
  }

  @Builder itemCheckboxBuilder(checkbox: SettingCheckboxModel, style: SettingCheckboxStyle): void {
    if (this.itemCheckboxSelected || style.showUnSelected) {
      Row() {
        Checkbox({ name: this.itemInfo.id, group: this.parentId })
          .id(`${this.compId}.result`)
          .width(style.width)
          .height(style.height)
          .select(this.itemCheckboxSelected)
          .selectedColor(style.selectedColor)
          .shape(style.shape)
          .margin(0)
          .onChange((isSelected: boolean) => {
            this.itemCheckboxSelected = isSelected;
            checkbox.onSelected?.(isSelected, this.itemInfo);
          })
      }
      .width(PageConfig.getInstance().getCheckboxStyle().width)
      .height(PageConfig.getInstance().getCheckboxStyle().height)
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder itemResultIconBuilder(iconStyle: SettingIconStyle): void {
    if (iconStyle.fillColor !== undefined) {
      Image((this.resultState as SettingIconVM).icon)
        .id(`${this.compId}.result`)
        .iconStyle(iconStyle, this.iconState)
        .fillColor(iconStyle.fillColor)
    } else {
      Image((this.resultState as SettingIconVM).icon)
        .id(`${this.compId}.result`)
        .iconStyle(iconStyle, this.iconState)
    }
  }

  @Builder itemResultBuilder(result: SettingItemResultModel): void {
    if (result.type === ItemResultType.RESULT_TYPE_CUSTOM) {
      Column() {
        result.builder?.builder(this.itemInfo)
      }
      .id(`${this.compId}.result`)
      .constraintSize({ minWidth: '33%' })
      .flexShrink(1)
    } else if (result.type === ItemResultType.RESULT_TYPE_TEXT) {
      Text((this.resultState as SettingTextVM).content)
        .id(`${this.compId}.result`)
        .textStyle(PageConfig.getInstance().getTextStyle((result.result as SettingTextModel)),
          (this.resultState as SettingTextVM).fontColor, this.titleState)
        .textAlign(this.isLargeFontMode ? TextAlign.Start : TextAlign.End)
        .constraintSize({ minWidth: this.isLargeFontMode ? '33%' : undefined })
        .flexShrink(1)
        .wordBreak(WordBreak.HYPHENATION)
    } else if (result.type === ItemResultType.RESULT_TYPE_TOGGLE && this.recordOldToggleState()) {
      Toggle({ type: ToggleType.Switch, isOn: (this.resultState as SettingToggleVM).state })
        .id(`${this.compId}.result`)
        .onChange((isOn: boolean) => {
          const log = `isOn:${isOn} oldState:${(this.resultState as SettingToggleVM).state}`;
          LogHelper.info(TAG, `Toggle switch, ${log}, compId: ${this.compId}`);
          if ((this.resultState as SettingToggleVM).state !== isOn) {
            if (this.oldToggleState !== (this.resultState as SettingToggleVM).state && DeviceUtil.isDevicePad()) {
              LogHelper.info(TAG, `Toggle ${this.compId} oldToggleState not equal this.resultState`);
              return;
            }
            (this.resultState as SettingToggleVM).state = isOn;
            // 是否允许点击切换状态 如果自定义函数onAllowChanged返回false则把状态还原(ark组件点击了必改变按钮视图 只能手动还原状态)
            const isAllowChange = (this.resultState as SettingToggleVM).onAllowChanged?.(isOn) ?? true;
            if (!isAllowChange) {
              LogHelper.info(TAG, `Toggle switch, isAllowChange:${isAllowChange}, compId: ${this.compId}`);
              (this.resultState as SettingToggleVM).state = !isOn;
              return;
            }
            EventBus.getInstance().emit(`${this.compId}.toggle`, { state: isOn });
            (result.result as SettingToggleModel).onChanged?.(isOn);
          } else {
            EventBus.getInstance().emit(`${this.compId}.toggle`, { state: isOn });
            (result.result as SettingToggleModel).onChanged?.(isOn);
          }
        })
        .enabled((this.resultState as SettingToggleVM).enabled)
        .accessibilityLevel(PageConfig.getInstance().isCircleScreen() ? AccessibilityLevelType.NO :
        AccessibilityLevelType.YES)
        .hitTestBehavior(PageConfig.getInstance().isCircleScreen() ? HitTestMode.None : undefined)
        .toggleStyle((result.result as SettingToggleModel).style)
    } else if (result.type === ItemResultType.RESULT_TYPE_IMAGE) {
      this.itemResultIconBuilder(PageConfig.getInstance().getIconStyle((result.result as SettingIconModel)))
    } else if (result.type === ItemResultType.RESULT_TYPE_RADIO) {
      this.itemRadioBuilder(result.result as SettingRadioModel,
        PageConfig.getInstance().getRadioStyle(result.result as SettingRadioModel))
    } else if (result.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
      this.itemCheckboxBuilder(result.result as SettingCheckboxModel,
        PageConfig.getInstance().getCheckboxStyle(result.result as SettingCheckboxModel))
    }
  }

  private recordOldToggleState(): boolean {
    this.oldToggleState = (this.resultState as SettingToggleVM).state;
    return true;
  }

  @Builder itemDetailBuilder(detail: SettingItemDetailModel, style: SettingIconStyle,
    iconMargin: LocalizedPadding, independentClick: boolean): void {
    if (detail.builder) {
      detail.builder.builder(this.itemInfo);
    } else if (detail.icon !== '') {
      if (detail.isSymbolIcon) {
        SymbolGlyph(detail.icon as Resource)
          .id(`${this.compId}.detail`)
          .margin(iconMargin)
          .symbolIconStyle(style)
          .fontSize(typeof style?.height === 'number' ? (style?.height + 'vp') : style?.height)
          .onTouch(independentClick ? (event: TouchEvent) => {
            event.stopPropagation();
          } : undefined)
          .onClick(independentClick ? () => {
            detail.onSelfClick?.(this.itemInfo);
          } : undefined)
      } else {
        if (style.fillColor) {
          Image(detail.icon)
            .id(`${this.compId}.detail`)
            .iconStyle(style, this.iconState)
            .fillColor(style.fillColor)
            .margin(iconMargin)
            .responseRegion(independentClick ? detail.responseRegion : undefined)
            .onTouch(independentClick ? (event: TouchEvent) => {
              event.stopPropagation();
            } : undefined)
            .onClick(independentClick ? () => {
              detail.onSelfClick?.(this.itemInfo);
            } : undefined)
        } else {
          Image(detail.icon)
            .id(`${this.compId}.detail`)
            .iconStyle(style, this.iconState)
            .margin(iconMargin)
            .responseRegion(independentClick ? detail.responseRegion : undefined)
            .onTouch(independentClick ? (event: TouchEvent) => {
              event.stopPropagation();
            } : undefined)
            .onClick(independentClick ? () => {
              detail.onSelfClick?.(this.itemInfo);
            } : undefined)
        }
      }
    }
  }

  @Builder itemDividerBuilder(dividerPad?: LocalizedPadding, dividerMargin?: LocalizedPadding): void {
    Divider()
      .height(px2vp(2))
      .strokeWidth(0.5)
      .color($r('sys.color.ohos_id_color_list_separator'))
      .lineCap(LineCapStyle.Square)
      .padding(dividerPad)
      .margin(dividerMargin)
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  @Styles
  normalStateIconStyles() {
    .backgroundColor(this.getNormalColor())
  }

  @Styles
  pressedStyles() {
    .backgroundColor(this.getItemPressedColor(this.itemInfo))
  }

  @Styles
  accessibilityStyle() {
    .accessibilityGroup(this.getAccessibilityGroup(this.itemInfo))
    .accessibilityText(this.getAccessibilityText(this.itemInfo))
    .accessibilityDescription(this.getAccessibilityDescription(this.itemInfo))
    .accessibilityLevel(this.itemInfo?.layout?.accessibilityLevel)
  }

  @Builder itemSheet(pageUrl: string, pageCtx: Optional<PageContext>): void {
    if (DataVerify.checkStr(pageUrl) && pageCtx.isPresent()) {
      pageCtx.get().pageBuilder?.builder(this.buildPageParam(pageUrl, pageCtx.get(), undefined))
    }
  }

  @Builder sheetBuilder(detail: SettingItemDetailModel): void {
    Column() {
      if (detail.sheetBuilder) {
        detail.sheetBuilder.builder(this.itemInfo)
      } else if (detail.destination) {
        this.itemSheet(detail.destination, ModalLoader.getPageContext(detail.destination))
      }
    }
  }

  @Builder menuIcon(menu: SettingSelectMenu, index: number, style: SettingIconStyle): void {
    if (style.fillColor !== undefined) {
      Image(menu.selectIcon)
        .id(`${this.compId}.menu${index}.icon`)
        .iconStyle(style, this.iconState)
        .fillColor(style.fillColor)
        .margin({ start: PADDING_8 })
    } else {
      Image(menu.selectIcon)
        .id(`${this.compId}.menu${index}.icon`)
        .iconStyle(style, this.iconState)
        .margin({ start: PADDING_8 })
    }
  }

  @Builder menuBuilder(menu: SettingSelectMenu, menuStyle: SettingMenuStyle): void {
    if (menu.items.length > 0) {
      Menu() {
        ForEach(menu.items, (item: ResourceStr, index: number) => {
          MenuItem({
            content: item,
            symbolEndIcon:
            this.menuSelectIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .accessibilityGroup(true)
            .accessibilityText(item as Resource)
            .accessibilitySelected(this.menuSelectIndex === index)
            .onClick(() => {
              (this.resultState as SettingTextState).content = item;
              this.menuSelectIndex = index;
              menu.onSelected?.(index);
              AccessibilityUtils.announceRadioSelected();
            })
            .constraintSize({
              minHeight: menuStyle.itemHeight,
              maxWidth: this.maxWidthPrec
            })
            .width(DeviceUtil.isDevicePc() ? undefined : menuStyle.width)
            .margin({ bottom: index !== menu.items.length - 1 && DeviceUtil.isDevicePc() ? PADDING_1_5 : PADDING_0 })
        })
      }
      .onDisAppear(() => {
        this.isMenuShow = false;
      })
      .menuItemDivider({
        strokeWidth: PADDING_1_PX,
        color: DeviceUtil.isDevicePc() ? Color.Transparent : $r('sys.color.ohos_id_color_list_separator')
      })
      .borderRadius(menuStyle.borderRadius)
    }
  }

  @Builder standardItemBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        if (item.icon.isSymbolIcon) {
          this.itemSymbolIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        } else {
          this.itemIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        }
      }

      Row() {
        if (this.despState.content !== '') {
          Column() {
            if (item.title) {
              this.itemTitleBuilder(item)
            }
            if (this.despState.content !== '') {
              this.itemDespBuilder(PageConfig.getInstance().getTextStyle(item.desc),
                { top: this.layout?.middleColumnSpace?.value })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .constraintSize({ maxWidth: this.titleSizeRestricted(item.result) ? '67%' : undefined })
          .flexShrink(this.titleSizeRestricted(item.result) ? 0 : 1)
          .padding({ end: this.layout?.middleRowSpace })
        } else {
          if (item.title) {
            Text(this.titleState.content)
              .id(`${this.compId}.title`)
              .wordBreak(WordBreak.BREAK_WORD)
              .textStyle(PageConfig.getInstance().getTextStyle(item.title), this.titleState.fontColor, this.titleState)
              .constraintSize({ maxWidth: this.titleSizeRestricted(item.result) ? '67%' : undefined })
              .flexShrink(this.titleSizeRestricted(item.result) ? 0 : 1)
              .padding({ end: this.layout?.middleRowSpace })
              .layoutWeight(item.title.layoutWeight ?? undefined)
              .fontWeight((DeviceUtil.isDevicePc() && this.isShowSelectedBackColor) ?
                FontWeight.Bold : PageConfig.getInstance().getTextStyle(item.title).fontWeight)
          }
        }

        if (item.result) {
          this.itemResultBuilder(item.result)
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .padding({ top: this.layout?.safetyPadding, bottom: this.layout?.safetyPadding })
      .constraintSize({ minHeight: this.minHeigth })

      if (item.detail) {
        Row() {
          this.itemDetailBuilder(item.detail, PageConfig.getInstance().getIconStyle(item.detail),
            { start: this.layout?.rightMiddleSpace }, item.detail.onSelfClick !== undefined)
        }
        .visibility((item.detail.visible) ?? (this.enabledState ? Visibility.Visible : Visibility.None))
        .bindMenu(this.isMenuShow, this.supportMenu(item.detail)?
        this.menuBuilder(item.detail?.menu, PageConfig.getInstance().getMenuStyle(item.detail?.menu?.style)) :
          undefined, {offset: { x: 0, y: 0 }, placement: Placement.BottomRight, showInSubWindow: false })
      }
    }
    .accessibilityStyle()
    .id(this.compId)
    .width('100%')
    .borderRadius(this.layout?.borderRadius)
    .enabled(this.enabledState)
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .opacity(this.enabledState === false ? $r('sys.float.ohos_id_alpha_disabled') : 1)
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .defaultFocus(true)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles
    })
    .padding({ start: this.layout?.innerLeftSpace, end: this.layout?.innerRightSpace })
    .onClick(() => {
      this.onItemClick(item);
      this.isMenuShow = true ;
      if (item?.result?.type === ItemResultType.RESULT_TYPE_RADIO) {
        AccessibilityUtils.announceText($r('app.string.be_chosen'));
      }
      if (item?.result?.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
        AccessibilityUtils.announceText(this.itemCheckboxSelected ? $r('app.string.be_chosen') : $r('app.string.not_be_chosen'));
      }
    })
    .focusable(item.focusable ?? true)
    .onTouch((event: TouchEvent) => {
      this.onItemTouch(item, event.type);
    })
    .onMouse((event: MouseEvent) => {
      if (event) {
        this.onMouseEvent(item, event);
      }
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .bindSheet(this.isModalShow, this.hasBindSheet(item.detail) ? this.sheetBuilder(item.detail) : undefined,
      this.buildSheetOptions(item.detail?.sheetOptions))
  }

  @Builder extraLargeStandardItemBuilder(item: SettingItemModel): void {
    Row() {
      Column() {
        this.extraLargeItemResultBuilder(item);
        if (this.despState.content !== '') {
          this.extraLargeItemDespBuilder(item);
        }
        this.extraLargeItemTextBuilder(item);

      }
      .width('100%')
      .padding({ top: this.layout?.safetyPadding, bottom: this.layout?.safetyPadding })
      .constraintSize({ minHeight: this.minHeigth })
    }
    .accessibilityStyle()
    .id(this.compId)
    .width('100%')
    .borderRadius(this.layout?.borderRadius)
    .enabled(this.enabledState)
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .opacity(this.enabledState === false ? $r('sys.float.ohos_id_alpha_disabled') : 1)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles
    })
    .padding({ start: this.layout?.innerLeftSpace, end: this.layout?.innerRightSpace })
    .onClick(() => {
      this.onItemClick(item);
    })
    .onTouch((event: TouchEvent) => {
      this.onItemTouch(item, event.type);
    })
    .onMouse((event: MouseEvent) => {
      if (event) {
        this.onMouseEvent(item, event);
      }
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .bindMenu(this.supportMenu(item.detail) ? this.menuBuilder(item.detail?.menu,
      PageConfig.getInstance().getMenuStyle(item.detail?.menu?.style)) : undefined,
      { placement: Placement.BottomRight, showInSubWindow: false })
    .bindSheet(this.isModalShow, this.hasBindSheet(item.detail) ? this.sheetBuilder(item.detail) : undefined,
      this.buildSheetOptions(item.detail?.sheetOptions))
  }

  @Builder extraLargeItemResultBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        if (item.icon.isSymbolIcon) {
          this.itemSymbolIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        } else {
          this.itemIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        }
      }

      Row() {
        if (item.title) {
          Text(this.titleState.content)
            .id(`${this.compId}.title`)
            .textStyle(PageConfig.getInstance().getTextStyle(item.title), this.titleState.fontColor, this.titleState)
            .wordBreak(WordBreak.BREAK_WORD)
            .flexShrink(this.titleSizeRestricted(item.result) ? 0 : 1)
            .padding({ end: this.layout?.middleRowSpace })
        }
      }
      .layoutWeight(1)

      if (item.detail) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.detail).width)
        .margin({ end: this.layout?.innerRightSpace })
      }
    }
  }

  @Builder extraLargeItemDespBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.icon).width)
        .margin({ end: this.layout?.leftMiddleSpace })
      }

      Row() {
        this.itemDespBuilder(PageConfig.getInstance().getTextStyle(item.desc),
          { top: this.layout?.middleColumnSpace?.value })
      }
      .layoutWeight(1)

      if (item.detail) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.detail).width)
        .margin({ end: this.layout?.innerRightSpace })
      }
    }
  }

  @Builder extraLargeItemTextBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.icon).width)
        .margin({ end: this.layout?.leftMiddleSpace })
      }

      Row() {
        if (item.result) {
          this.itemResultBuilder(item.result)
        }
      }
      .layoutWeight(1)

      if (item.detail) {
        this.itemDetailBuilder(item.detail, PageConfig.getInstance().getIconStyle(item.detail),
          { start: this.layout?.innerRightSpace }, item.detail.onSelfClick !== undefined)
      }
    }
    .padding({ top: this.despState.content !== '' ? '16vp' : '2vp' })
  }

  @Builder circleScreenItemBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        this.itemIconBuilder(PageConfig.getInstance().getIconStyle(item.icon), { start: this.layout?.innerLeftSpace })
      }

      Column() {
        if (item.title) {
          this.itemTitleBuilder(item)
        }
        if (this.despState.content !== '') {
          this.itemDespBuilder(PageConfig.getInstance().getTextStyle(item.desc),
            { top: this.layout?.middleColumnSpace?.value })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({ start: this.layout?.leftMiddleSpace, end: this.layout?.rightMiddleSpace })

      if (item.result || item.detail) {
        Column() {
          if (item.detail) {
            this.itemDetailBuilder(item.detail, PageConfig.getInstance().getIconStyle(item.detail),
              { end: this.layout?.innerRightSpace }, item.detail.onSelfClick !== undefined)
          } if (item.result) {
            this.itemResultBuilder(item.result)
          }
        }
        .size({ width: '92px', height: '92px' })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
    }
    .accessibilityGroup(item?.layout?.accessibilityGroup)
    .id(this.compId)
    .accessibilityDescription(PageConfig.getInstance().getAccessibilityDescription(item,
      (this.resultState as SettingToggleVM).state, this.itemRadioChecked, this.itemCheckboxSelected, this.enabledState))
    .width('100%')
    .borderRadius(this.layout?.borderRadius)
    .enabled(this.enabledState)
    .opacity(this.enabledState === false ? $r('sys.float.ohos_id_alpha_disabled') : 1)
    .padding({ top: this.layout?.safetyPadding, bottom: this.layout?.safetyPadding })
    .margin({ top: '6px', bottom: '6px' })
    .constraintSize({ minHeight: this.minHeigth })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles,
    })
    .onClick(() => {
      this.onItemClick(item);
    })
    .onTouch((event: TouchEvent) => {
      this.onItemTouch(item, event.type);
    })
  }

  @Builder itemBuilder(item: SettingItemModel): void {
    if (this.isCircleScreen) {
      if (item.type === ItemType.ITEM_TYPE_CUSTOM) {
        item.builder?.builder(item);
      } else {
        this.circleScreenItemBuilder(item)
      }
    } else {
      this.standardScreenItemBuilder(item);
    }
  }

  @Builder standardScreenItemBuilder(item: SettingItemModel): void {
    Column() {
      if (item.type === ItemType.ITEM_TYPE_CUSTOM) {
        item.builder?.builder(item);
      } else {
        if (this.isLargeFontMode && item.result?.type === ItemResultType.RESULT_TYPE_TEXT) {
          this.extraLargeStandardItemBuilder(item);
        } else {
          this.standardItemBuilder(item)
        }
      }
      if (!(this.itemPos & ItemPos.ITEM_POS_END) && !this.layout?.noNeedDivider) {
        this.itemDividerBuilder({ start: this.layout?.innerLeftSpace, end: this.layout?.innerRightSpace },
          this.getItemDividerMargin(item.divider, item.icon))
      }
    }
    .padding({ top: DeviceUtil.isDevicePc() && (!(this.itemPos & ItemPos.ITEM_POS_START)) &&
      this.layout?.noNeedDivider? PADDING_2 : undefined })
  }

  aboutToAppear(): void {
    // 兼容设置老框架页面路由，首页已配置的id作为compId，已支持分屏场景指定item获焦
    if (this.homePageComp) {
      this.compId = this.itemInfo.id;
      let currentKey: string = AppStorage.get('currentHomeKey') as string;
      this.isShowSelectedBackColor = this.compId === currentKey && PageConfig.getInstance().isSplitMode();
    }
    LogHelper.info(TAG, `setting item ${this.compId} appear.`);

    let item = this.itemInfo;
    this.layout = PageConfig.getInstance().getItemLayout(item, this.homePageComp);
    this.minHeigth = this.layout.minHeight ?? 0;
    this.currentFontSizeScale = FontScaleUtils.getFontScaleSize();
    this.isLargeFontMode = FontScaleUtils.isExtraLargeFontMode();
    this.initItemContent(item);

    // 注册事件
    EventBus.getInstance().on(this.compId, this.eventCb);
    item.onItemEvent = (datas: Map<SettingStateType, SettingBaseState>) => {
      this.procEvent(datas);
    };

    if (this.itemInfo.compControl) {
      this.itemInfo.compControl.init({ compId: this.compId, component: this.itemInfo });
    }
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `setting item ${this.compId} disappear.`);
    let item = this.itemInfo;
    EventBus.getInstance().detach(this.compId, this.eventCb);
    item.onItemEvent = undefined;
    if (this.itemInfo.compControl) {
      this.itemInfo.compControl.destroy();
    }
  }

  onItemLayoutChange(): boolean {
    if (this.currentFontSizeScale !== FontScaleUtils.getFontScaleSize()) {
      this.isLargeFontMode = FontScaleUtils.isExtraLargeFontMode();
      this.layout = PageConfig.getInstance().getItemLayout(this.itemInfo, this.homePageComp);
      this.currentFontSizeScale = FontScaleUtils.getFontScaleSize();
    }
    return true;
  }

  getAccessibilityGroup(item: SettingItemModel): boolean {
    if (item?.result?.type === ItemResultType.RESULT_TYPE_RADIO ||
      item?.result?.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
      return true;
    }
    return item?.layout?.accessibilityGroup ?? false;
  }

  getAccessibilityText(item: SettingItemModel): string | undefined {
    if (item?.layout?.accessibilityText?.toString()) {
      return item?.layout?.accessibilityText?.toString()
    }
    if (item?.result?.type === ItemResultType.RESULT_TYPE_RADIO ||
      item?.result?.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
      return ResourceUtil.getStringSync((this.itemRadioChecked || this.itemCheckboxSelected) ?
        ResourceUtil.getStringSync($r('app.string.be_chosen')) + ',' : ' ') +
        `${ResourceUtil.getStringSync(this?.titleState?.content)}
        ${ResourceUtil.getStringSync(this?.despState?.content)}`;
    }
    return undefined;
  }

  getAccessibilityDescription(item: SettingItemModel): string | undefined {
    if (item?.result?.type === ItemResultType.RESULT_TYPE_RADIO) {
      return ResourceUtil.getStringSync(this.itemRadioChecked ?
        TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS : TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS);
    }
    if (item?.result?.type === ItemResultType.RESULT_TYPE_CHECKBOX) {
      return ResourceUtil.getStringSync(this.itemCheckboxSelected ?
      $r('app.string.has_selected_click_tips') : $r('app.string.no_selected_click_tips'))
    }
    if (item?.layout?.accessibilityDescription) {
      return ResourceUtil.getStringSync(item?.layout?.accessibilityDescription);
    }
    if (this.isSupportClick(item)) {
      // 支持点击时朗读单指双击
      return '';
    }
    // 朗读默认不朗读单指双击
    return ' ';
  }

  build() {
    if (this.onItemLayoutChange()) {
      this.itemBuilder(this.itemInfo)
    }
  }
}