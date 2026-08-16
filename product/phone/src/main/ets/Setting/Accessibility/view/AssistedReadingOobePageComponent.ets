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

import { i18n } from '@kit.LocalizationKit';
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import Display from '@ohos.display';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ElderCareManager } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { PADDING_0, PADDING_16, PADDING_4, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { ColumnSystemManager } from '@ohos/settings.common/src/main/ets/window/ColumnSystemManager';
import { AssistedReadingOobeTextSizeComponent } from './AssistedReadingOobeTextSizeComponent';
import { AssistedReadingOobeZoomGestureComponent } from './AssistedReadingOobeZoomGestureComponent';
import { AccessibilityCardContainerComp } from './AccessibilityCardContainerComp';
import {
  ASSISTED_READING_TEXT_SIZE_NAME_LIST,
  FONT_SIZE_SCALE_LIST,
  TRANSACTION_TIME,
  SCREEN_MAGNIFICATION,
  CLICK_SWITCH_ON,
  CLICK_SWITCH_OFF
} from '../constant/Constants';
import { AccessibilityOobeImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';
import { CardMaterialManager } from '../../Wlan/view/manager/CardMaterialManager';

/* instrument ignore file */
const TAG: string = 'AssistedReadingOobePageComponent : ';

interface AssistedReadingItem {
  icon: Resource,
  title: Resource | string
}

const ASSISTED_READING_ITEM_LIST: AssistedReadingItem[] = [
  {
    icon: $r('app.media.assisted_reading_text_size'),
    title: $r('app.string.elder_care_search_item_font_size')
  },
  {
    icon: $r('app.media.assisted_reading_zoom_gesture'),
    title: $r('app.string.zoom_gesture')
  }
]

@Entry
@Component
export struct AssistedReadingOobePageComponent {
  @State isMainPage: boolean = true;
  @State fontSizeName: Resource | string = '';
  @State zoomGestureName: ResourceStr = '';
  @State isNextClick: boolean = false;
  @State isTextSizePage: boolean = true;
  @State isWideScreen: boolean =
    DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() && DeviceUtil.isLargeInFoldProduct();
  private secondPageIndex: number = 0;
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器
  private accessibilityOobeImageSizeAdjust: AccessibilityOobeImageSizeAdjust = new AccessibilityOobeImageSizeAdjust();
  private isJustified: boolean =
    i18n.System.getSystemLanguage() === 'zh-Hans' || i18n.System.getSystemLanguage() === 'zh-Hant';
  private transitionEffect: TransitionEffect = TransitionEffect.asymmetric(
    TransitionEffect.OPACITY.animation({ duration: TRANSACTION_TIME })
      .combine(TransitionEffect.move(TransitionEdge.END)),
    TransitionEffect.OPACITY.animation({ duration: TRANSACTION_TIME })
      .combine(TransitionEffect.move(TransitionEdge.START)))
  private isSupportNewMaterial: boolean = CardMaterialManager.getInstance().isSupportNewMaterial;

  @Builder
  promptTextComponent() {
    Row() {
      Text($r('app.string.assisted_reading_prompt_text'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .textAlign(this.isWideScreen ? TextAlign.Center : (this.isJustified ? TextAlign.JUSTIFY : TextAlign.Start))
        .width('100%')
    }.width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Styles
  pressStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_component_normal'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Styles
  normalStyles() {
    .backgroundColor('')
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Builder
  assistedReadingListComponent() {
    Row() {
      List({ space: 12, scroller: this.scroller }) {
        this.promptTextComponent()
        ForEach(ASSISTED_READING_ITEM_LIST, (item: AssistedReadingItem, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Row() {
                  Image(item.icon)
                    .width($r('app.float.wh_value_24'))
                    .height($r('app.float.wh_value_24'))
                    .objectFit(ImageFit.Contain)
                    .draggable(false)
                }
                .margin({
                  start: PADDING_0,
                  end: PADDING_16
                })

                Row() {
                  Text(item.title)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontFamily('HarmonyHeiTi')
                    .constraintSize({ maxWidth: '67%' })
                    .wordBreak(WordBreak.HYPHENATION)
                    .padding({ end: PADDING_16 })
                    .flexShrink(0)

                  Text(index === 0 ? this.fontSizeName : this.zoomGestureName)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                    .fontFamily('HarmonyHeiTi')
                    .fontColor($r('sys.color.font_secondary'))
                    .constraintSize({ minWidth: '33%' })
                    .textAlign(TextAlign.End)
                    .wordBreak(WordBreak.HYPHENATION)
                    .flexShrink(1)
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontColor([$r('sys.color.icon_fourth')])
                    .fontSize('24vp')
                }
                .margin({
                  start: PADDING_4,
                  end: PADDING_0
                })
              }
              .width('100%')
              .constraintSize({ minHeight: $r('app.float.height_56') })
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressStyles
              })
              .padding({ start: PADDING_8, end: PADDING_8 })
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .alignSelf(ItemAlign.End)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.wh_value_64') })
            .borderRadius($r('sys.float.corner_radius_level10'))
            .backgroundColor(this.isSupportNewMaterial ? $r('app.color.card_bg_color_60') :
              $r('app.color.oobe_wlan_bg_color'))
            .padding({
              start: PADDING_4,
              end: PADDING_4,
              top: PADDING_4,
              bottom: PADDING_4
            })
          }
          .margin({ top: index === 0 ? PADDING_4 : PADDING_0 })
          .onClick(() => {
            this.transitionEffect = TransitionEffect.OPACITY.combine(TransitionEffect.move(TransitionEdge.START));
            this.secondPageIndex = index;
            animateTo({ duration: TRANSACTION_TIME }, () => {
              this.isMainPage = false;
            })
          })
        }
        )

      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

      ScrollBar({ scroller: this.scroller, direction: ScrollBarDirection.Vertical, state: BarState.Auto })
        .accessibilityLevel('no')
        .margin({
          bottom: 8
        })
    }
    .padding({ left: $r('app.float.length_16'), right: $r('app.float.length_16') })
    .width('100%')
    .height('100%')
  }

  @Builder
  contentBuilder(): void {
    Column() {
      this.assistedReadingListComponent()
    }
  }

  @Builder
  loadAssistedReadingHomePage(): void {
    Stack() {
      AccessibilityCardContainerComp({
        bodyContent: () => this.contentBuilder(),
        mHeadName: $r('app.string.assisted_reading_page_title'),
        onButtonClick: () => this.onBackBtnClick(),
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.End)
    .alignContent(Alignment.Bottom)
    .transition(this.transitionEffect)
  }

  /**
   * 加载辅助阅读二级页面
   */
  @Builder
  loadAssistedReadingSecondPage(): void {
    if (ResourceUtil.getStringSync(ASSISTED_READING_ITEM_LIST[this.secondPageIndex].title) ===
    ResourceUtil.getStringSync($r('app.string.zoom_gesture'))) {
      this.loadZoomGesturePage();
    } else {
      this.loadTextSizePage();
    }
  }

  /**
   * 加载辅助阅读-字体大小页面
   */
  @Builder
  loadTextSizePage(): void {
    AssistedReadingOobeTextSizeComponent({
      isMainPage: this.isMainPage,
      fontSizeName: this.fontSizeName,
    })
      .transition(TransitionEffect.OPACITY.combine(TransitionEffect.move(TransitionEdge.END)))
  }

  /**
   * 加载辅助阅读-放大手势页面
   */
  @Builder
  loadZoomGesturePage(): void {
    AssistedReadingOobeZoomGestureComponent({
      isMainPage: this.isMainPage,
      zoomGestureName: this.zoomGestureName,
    })
      .transition(TransitionEffect.OPACITY.combine(TransitionEffect.move(TransitionEdge.END)))
  }

  @Builder
  buildPageContent(): void {
    if (this.isMainPage) {
      this.loadAssistedReadingHomePage();
    } else {
      this.loadAssistedReadingSecondPage();
    }
  }

  build() {
    HdsNavDestination() {
      Column() {
        this.buildPageContent();
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onAppear(() => {
      LogUtil.info(`${TAG} onAppear`);
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.accessibilityOobeImageSizeAdjust.setImageSize();
    this.accessibilityOobeImageSizeAdjust.registerDisplayChangeListener();
    this.initFontSizeScaleName();
    this.initZoomGestureState();
    ColumnSystemManager.getInstance().registerMediaQuery();
    if (DeviceUtil.isLargeInFoldProduct()) {
      DisplayUtils.registerFoldStatusChange(this.onFoldChangeCallBack);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.accessibilityOobeImageSizeAdjust.unregisterDisplayChangeListener();
    ColumnSystemManager.getInstance().unregisterMediaQuery();
    if (DeviceUtil.isLargeInFoldProduct()) {
      DisplayUtils.unRegisterFoldStatusChange(this.onFoldChangeCallBack);
    }
  }

  private onFoldChangeCallBack(status: number): void {
    LogUtil.info(`${TAG} on fold status changed: ${status}`);
    this.isWideScreen = status === Display.FoldStatus.FOLD_STATUS_EXPANDED;
  }

  /**
   * 点击上一步按钮触发功能
   */
  private onBackBtnClick(): void {
    LogUtil.info(`${TAG} backSheetPage`);
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (session === undefined) {
      LogUtil.info(`${TAG} session undefined`);
      return;
    }
    session.sendData({
      action: 'backSheet',
    });
  }

  private initFontSizeScaleName(): void {
    let fontSizeScale: number = ElderCareManager.getFontScale();
    const index = FONT_SIZE_SCALE_LIST.findIndex(item => item === fontSizeScale);
    if (index !== -1) {
      this.fontSizeName = ASSISTED_READING_TEXT_SIZE_NAME_LIST[index];
    } else {
      this.fontSizeName = $r('app.string.display_mode_font_size_normal');
    }
  }

  private initZoomGestureState(): void {
    let isEnabled: boolean =
      SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.zoomGestureName = isEnabled ? $r('app.string.accessibility_on') : $r('app.string.assisted_reading_not_enable');
  }
}