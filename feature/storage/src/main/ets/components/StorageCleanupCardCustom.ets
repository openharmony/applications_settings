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
import { common } from '@kit.AbilityKit';
import { curves } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import {
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageConfig } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingContentTextStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysStorageEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ButtonInfo, CardInfo } from '../model/CardInfo';
import StorageCleanupCardManager, { SHOW_CARD_MAX_LENGTH } from '../model/StorageCleanupCardManager';

const TAG = 'StorageCleanupCardCustom';
const CARD_LIST_LENGTH: number = 0;
const EXTRA_LARGE_FONT_1: number = 1.15;

@Builder
export function StorageCleanupCardCustomBuilder(param: object): void {
  StorageCleanupCardCustom({ param: param as SettingItemModel })
}

// 卡片组
@Component
export struct StorageCleanupCardCustom {
  private param?: SettingItemModel;
  private style: SettingContentTextStyle = {};
  private effect: TransitionEffect = TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
    delay: 10,
    curve: curves.interpolatingSpring(0, 1, 180, 27)
  }).combine(TransitionEffect.scale({ x: 0.9, y: 0.9 })),
    TransitionEffect.OPACITY.animation({ curve: curves.interpolatingSpring(0, 1, 180, 27) })
      .combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }))
  )
  @State cardList: CardInfo[] = [];
  @State @Watch('lengthChange') totalLength: number = 0;
  @State @Watch('fullLengthChange') fullLength: number = 0;
  @State headerIsShow: boolean = false;
  @State headerIsShowMore: boolean = false;

  lengthChange(): void {
    if (this.totalLength === CARD_LIST_LENGTH) {
      this.headerIsShow = false;
    } else {
      this.headerIsShow = true;
    }
  }

  fullLengthChange(): void {
    if (this.fullLength > SHOW_CARD_MAX_LENGTH) {
      this.headerIsShowMore = true;
    } else {
      this.headerIsShowMore = false;
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.style = PageConfig.getInstance().getGroupHeaderStyle();
    EventBus.getInstance().on('handleCardInfo', this.handleCardInfoCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisAppear`);
    EventBus.getInstance().detach('handleCardInfo', this.handleCardInfoCallBack);
  }

  private getHeaderHeight(): Length | undefined {
    let height: Length | undefined = this.style.height;
    LogUtil.debug(`${TAG} getHeaderHeight: ${height}`)
    if (height) {
      return height;
    }
    return DeviceUtil.isDevicePc() ? 40 : 56;
  }

  private getHeaderPadding(): LocalizedPadding | undefined {
    let padding: LocalizedPadding | undefined = this.style.padding;
    LogUtil.debug(`${TAG} getHeaderPadding: ${JSON.stringify(padding)}`)
    if (padding) {
      return padding;
    }
    return {
      start: PADDING_12,
      end: PADDING_12,
      bottom: PADDING_8,
      top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_16 : PADDING_0
    };
  }

  private handleCardInfoCallBack = (cardList: CardInfo[]) => {
    this.totalLength = cardList.length;
    this.fullLength = StorageCleanupCardManager.getAllNotSilentCardList().length;
    this.lengthChange();
    this.fullLengthChange();
    LogUtil.info(`${TAG} handleCardInfoCallBack totalLength ${this.totalLength} and fullLength ${this.fullLength}`);
    // 页面展示页强制设置一个卡片，防止Manager数据限制不生效
    this.cardList = (cardList.length <= 1) ? cardList : cardList.slice(0, 1);
  }

  build() {
    Column() {
      Column() {
        StorageCleanupCardGroupHeaderComponent({ isShowMore: this.headerIsShowMore })
      }
      .padding(this.getHeaderPadding())
      .constraintSize({ minHeight: this.getHeaderHeight() })
      .justifyContent(FlexAlign.End)

      ForEach(this.cardList, (item: CardInfo, index: number) => {
        Row() {
          StorageCleanupCardComponent({ cardInfo: item, totalLength: this.totalLength, fullLength: this.fullLength })
        }
        .margin((this.totalLength === 1) ? '' : ((index > 0) ? { bottom: 0 } : { bottom: 10 }))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .constraintSize({ maxHeight: 480 })
      }, (item: CardInfo, index: number) => {
        return `${index}_${item.cardName}_${item.abilityName}_${item.serviceName}_${item.title}_${item.summary}_` +
          `${typeof item.titleString === 'string' ? item.titleString : (item.titleString as Resource)?.id}_` +
          `${typeof item.summaryString === 'string' ? item.summaryString : (item.summaryString as Resource)?.id}`;
      })
    }
    .visibility(this.headerIsShow ? Visibility.Visible : Visibility.None)
    .animation({
      curve: curves.interpolatingSpring(0, 1, 240, 31)
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
    .width('100%')
    .transition(this.effect)
  }
}

@Component
export struct StorageCleanupCardGroupHeaderComponent {
  @Prop isShowMore: boolean = false;

  aboutToAppear(): void {
    LogUtil.info(`${TAG} header aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} header aboutToDisappear`);
  }

  handleShowMoreClick(): void {
    LogUtil.info(`${TAG} more page push`);
    // 点击更多卡片打点操作
    let reportParams: Record<string, Object> = {};
    reportParams.TYPE = 3;
    reportParams.BUTTON_NAME = $r('app.string.load_more_data');
    // 跳转到更多页面
    PageRouter.push('setting_storage_moreCard');
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      if (this.isShowMore) {
        Text($r('app.string.load_more_data'))
          .fontSize($r('sys.float.Subtitle_S'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            this.handleShowMoreClick()
          })
          .accessibilityRole(AccessibilityRoleType.BUTTON)
      }
    }
    .width('100%')
  }
}

// 卡片内容
@Component
export struct StorageCleanupCardComponent {
  @State isShowSelf: boolean = true;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  @State cardInfo: CardInfo = {};
  @Link totalLength: number;
  @Link fullLength: number;
  @State title?: ResourceStr = '';
  @State summary?: ResourceStr = '';
  @State buttonList: ButtonInfo[] | undefined = [{ buttonString: '' }];
  @State icon: ResourceStr | PixelMap | null = null;
  @State isBigFont: boolean = (FontScaleUtils.getCurrentScale(getContext(this)) >= EXTRA_LARGE_FONT_1);
  private context = getContext(this) as common.UIAbilityContext;
  @State currentFontSize: number = FontScaleUtils.getCurrentScale(getContext(this));

  @Styles
  pressStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
    .borderRadius($r('sys.float.corner_radius_level7'))
  }

  /**
   * “立即优化”无状态样式
   */
  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_default_s'))
  }

  aboutToAppear(): void {
    if (!this.cardInfo) {
      return;
    }
    this.title = this.cardInfo.titleString;
    this.summary = this.cardInfo.summaryString;
    this.buttonList = this.cardInfo.buttonList;
    if (this.cardInfo.cardName === 'clearCache') {
      this.icon = $r('app.media.clean_cache');
      return;
    }
    if (this.cardInfo.iconImg) {
      let imageSource = image.createImageSource(this.cardInfo.iconImg.buffer);
      imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
        this.icon = pixelMap;
      })
    }
  }

  onHandleCancelClick(): void {
    this.isShowSelf = false;
    this.totalLength--;
    this.fullLength--;
    StorageCleanupCardManager.refreshCardSilentTime(this.cardInfo);
    // 打点事件上报
    let reportParams: Record<string, Object> = {};
    if (this.cardInfo.serviceName) {
      reportParams.BUNDLE_NAME = this.cardInfo.serviceName;
    }
    if (this.cardInfo.cardName) {
      reportParams.CARD_NAME = this.cardInfo.cardName;
    }
    // 关闭事件类型
    reportParams.TYPE = 1;
    reportParams.BUTTON_NAME = '';
    // (无障碍修改)关闭卡片后聚焦到“应用数据”
    AccessibilityUtils.requestFocusAccessibility('storage_app_data_size');
  }

  onHandleButtonClick(item: ButtonInfo): void {
    StorageCleanupCardManager.clickButton(this.context, item, this.cardInfo, this.pathInfos,
      !(this.navigationMode === NavigationMode.Split));
    let reportParams: Record<string, Object> = {};
    if (this.cardInfo.serviceName) {
      reportParams.BUNDLE_NAME = this.cardInfo.serviceName;
    }
    if (this.cardInfo.cardName) {
      reportParams.CARD_NAME = this.cardInfo.cardName;
    }
    // 点击事件类型
    reportParams.TYPE = 2
    if (item.buttonString) {
      reportParams.BUTTON_NAME = item.buttonString;
    }
  }

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Image(this.icon)
        .width(32)
        .aspectRatio(1)
        .border({ width: '1px', color: '#99808080', style: BorderStyle.Solid })
        .borderRadius(8)
        .syncLoad(true)
        .draggable(false)
      Column() {
        Row() {
          Text(this.title)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .maxFontScale(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('80%')
          Blank()
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.xmark'))
              .draggable(false)
              .fontSize((this.currentFontSize === 0) ? 18 : 18 / this.currentFontSize)
              .fontColor([$r('sys.color.icon_primary')])
          }
          .stateStyles({
            pressed: this.pressStyles,
            normal: this.normalStyles
          })
          .height(26)
          .aspectRatio(1)
          .margin({ start: PADDING_12 })
          .accessibilityText($r('app.string.dialog_disable'))
          .onClick(() => {
            this.onHandleCancelClick()
          })
        }
        .alignItems(VerticalAlign.Top)
        .width('100%')

        Text(this.summary)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .maxLines(5)
          .maxFontScale(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 2 })
          .width('100%')
        Row() {
          ForEach(this.buttonList, (item: ButtonInfo) => {
            Text(item.buttonString)
              .margin({ top: PADDING_8, end: PADDING_16 })
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
              .maxFontScale(2)
              .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
              .minFontSize(9)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor($r('sys.color.font_emphasize'))
              .onClick(() => {
                this.onHandleButtonClick(item)
              })
              .stateStyles({
                pressed: this.pressStyles,
                normal: this.normalStyles
              })
              .accessibilityRole(AccessibilityRoleType.BUTTON)
          })
        }
      }
      .margin({ start: PADDING_12 })
      .alignItems(HorizontalAlign.Start)
    }
    .visibility((this.isShowSelf) ? Visibility.Visible : Visibility.None)
    .width('100%')
    .padding({
      start: PADDING_12,
      end: PADDING_12,
      top: PADDING_12,
      bottom: PADDING_12
    })
  }
}