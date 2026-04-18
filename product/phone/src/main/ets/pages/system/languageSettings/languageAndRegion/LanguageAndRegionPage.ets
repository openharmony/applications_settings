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

import { BusinessError } from '@ohos.base';
import CommonEventManager from '@ohos.commonEventManager';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_2,
  PADDING_4,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { Params, PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  AccessibilityLevelType,
  AccessibilityUtils,
  TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS,
  TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS
} from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { languageAndRegionModel } from '@ohos/settings.language/src/main/ets/model/LanguageAndRegionModel';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { PageUrl } from '../../../PageUrl';
import { SubHeaderComponent } from '../SubHeader';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const STROKE_WIDTH_1_PX: string = '1px';
const TAG: string = 'Settings LanguageAndRegion: ';
const DEFAULT_COMB_ID:string = 'comb_id_language';

@Styles
function pressedStateIconStyles() {
  .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) ?
  $r('sys.color.ohos_id_color_click_effect') : null)
}

/**
 * Home Page Of LanguageAndRegion Settings
 */
@Builder
export function LanguageAndRegionPageLoader($$: Params): void {
  LanguageAndRegionPage({ params: $$ as Object as PushParam });
}

@Component
export struct LanguageAndRegionPage {
  @State isEditable: boolean = false;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  @State params: PushParam | null = null;
  latestLanguage: string = '';

  build() {
    NavDestination() {
      Column() {
        GridContainer({
          columns: 12,
          sizeType: SizeType.MD,
          gutter: '12vp',
          margin: '0vp'
        }) {
          Row() {
            Column() {
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .width('100%')
            .height('100%')
            .useSizeType({
              xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
              md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
            });

            Column() {
              Blank().height($r('app.float.navigation_56'))
              Scroll() {
                List() {
                  ListItem() {
                    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                      Text($r('app.string.languageTab'))
                        .fontSize($r('app.float.font_14'))
                        .constraintSize({ minHeight: $r('app.float.distance_20') })
                        .maxFontScale(2)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                        .textAlign(TextAlign.Start)
                        .width('50%')
                        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
                        .margin({ top: $r('app.float.wh_value_28'), bottom: $r('app.float.distance_8') })

                      Button(){
                        Text($r('app.string.edit'))
                          .fontColor($r('sys.color.font_emphasize'))
                          .fontSize($r('sys.float.Subtitle_S'))
                          .fontWeight(FontWeight.Medium)
                          .constraintSize({ minHeight: $r('app.float.distance_20') })
                          .maxFontScale(2)
                      }
                        .margin({ top: $r('app.float.wh_value_24'), bottom: $r('app.float.distance_4') })
                        .borderRadius($r('sys.float.corner_radius_level4'))
                        .padding({ start: PADDING_2, end: PADDING_2,top: PADDING_4, bottom: PADDING_4 })
                        .opacity(this.isEditable ? 1 : 0.4)
                        .enabled(this.isEditable)
                        .accessibilityLevel(AccessibilityLevelType.YES)
                        .stateStyles({
                          normal: {
                            .backgroundColor(Color.Transparent)
                          },
                          pressed: {
                            .backgroundColor(this.isEditable ? $r('sys.color.interactive_click') : Color.Transparent)
                          },
                        })
                        .onClick((event) => {
                          if (!this.isEditable) {
                            return;
                          }
                          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.EDIT_LANGUAGE,
                            'pageUrl: ' + NavEntryKey.EDIT_LANGUAGE_ENTRY);
                          this.pushName(NavEntryKey.EDIT_LANGUAGE_ENTRY, null);
                        })
                    }
                    .margin({
                      start: PADDING_12,
                      end: PADDING_12
                    })
                    .constraintSize({ minHeight: $r('app.float.wh_value_56') })
                    .id('language_title');
                  }

                  ListItem() {
                    AddedList();
                  }.margin({ bottom: $r('app.float.distance_12') })

                  ListItem() {
                    AddText();
                  }

                  ListItem() {
                    SubHeaderComponent({ titleContent: $r('app.string.region') })
                  }

                  ListItem() {
                    Region();
                  }
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                .flexShrink(1)
                .padding({ start: PADDING_16, end: PADDING_16, bottom: PADDING_16 })
              }
              .margin({bottom: $r('app.float.navigation_56')})
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .height('100%')
              .scrollBar(BarState.On)
              .align(Alignment.TopStart)
              .edgeEffect(EdgeEffect.Spring)
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .height('100%')
            .width('100%')
            .useSizeType({
              xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
              md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
            });

            Column() {
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .width('100%')
            .height('100%')
            .useSizeType({
              xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
              md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
            })
          }
          .width('100%')
          .height('100%');
        }
        .width('100%')
        .height('100%');
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(false)
    .title($r('app.string.languageAndRegion'))
    // .titleBar({content: {title: {mainTitle: ResourceUtil.getStringSync($r('app.string.languageAndRegion'))}}})
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} onPageHide`);
    })
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED
    ]
  }

  private languageState: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err: BusinessError, data) => {
    if (data?.event === CommonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED) {
      let currentSystemLanguage: string = languageAndRegionModel.getSystemLanguage();
      languageAndRegionModel.setSystemLanguageEffects(currentSystemLanguage);
      LogUtil.info(`${TAG} setSystemLanguageEffects ${currentSystemLanguage}`);
      // 切换语言后更新编辑按钮的状态
      this.updateEditable();
      if (this.latestLanguage !== currentSystemLanguage) {
        this.latestLanguage = currentSystemLanguage;
        // 如果是添加后选择的切换语言则不用主动获焦
        if (!languageAndRegionModel.isAddLanguageChange()) {
          AccessibilityUtils.requestFocusAccessibilityWithBundleName(DEFAULT_COMB_ID);
        }
        languageAndRegionModel.setAddLanguageChange(false);
      }
    } else {
      LogUtil.error(`${TAG} languageState subscribe failed ${err?.code}`);
    }
  })

  aboutToAppear(): void {
    languageAndRegionModel.setAddLanguageChange(false);
    LogUtil.info(`${TAG} aboutToAppear in`);
    this.latestLanguage = languageAndRegionModel.getSystemLanguage();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.ENTER_LANGUAGE_AND_REGION,
      'pageUrl: ' + PageUrl.LANGUAGE_AND_REGION_PAGE_URL);
    this.updateEditable();
    this.languageState.registerCommonEvent();
    AppStorage.set('addedLanguages', languageAndRegionModel.getAddedLanguages());
    LogUtil.info(`${TAG} aboutToAppear out`);
  }

  aboutToDisappear(): void {
    this.languageState.unRegisterCommonEvent();
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private updateEditable(): void {
    this.isEditable = languageAndRegionModel.getAddedLanguages().length > 1;
  }

  onPageShow(): void {
    this.updateEditable();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
  }
}


/**
 * List Of Added Languages
 */
@Component
struct AddedList {
  @StorageLink('addedLanguages') addedLanguages: Array<string> = languageAndRegionModel.getAddedLanguages();
  @State clickable: boolean = true;

  build() {
    List() {
      ForEach(this.addedLanguages, (item: string) => {
        AddedItem({
          item: item,
          isSystemLanguage: languageAndRegionModel.isSystemLanguage(item),
          clickable: this.clickable
        })
      });
    }
    .padding($r('app.float.distance_4'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .divider({
      strokeWidth: STROKE_WIDTH_1_PX,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r('app.float.distance_8'),
      endMargin: $r('app.float.distance_8')
    })
    .backgroundColor($r('sys.color.comp_background_list_card'));
  }
}

@Component
struct AddedItem {
  @State item: string = '';
  @State isHover: boolean = false;
  @State clickable: boolean = true;
  @State isTouched: boolean = false;
  @Prop isSystemLanguage: boolean = false;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Text(languageAndRegionModel.getSysDisplayLanguage(this.item))
          .fontSize($r('app.float.font_16'))
          .constraintSize({ minHeight: $r('app.float.wh_value_22') })
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isSystemLanguage ?
          $r('sys.color.ohos_id_color_text_hyperlink') :
          $r('sys.color.ohos_id_color_text_primary'))
          .wordBreak(WordBreak.BREAK_WORD)
          .textAlign(TextAlign.Start)
        Text(languageAndRegionModel.getDisplayLanguage(this.item))
          .fontSize($r('app.float.font_14'))
          .constraintSize({ minHeight: $r('app.float.wh_value_19') })
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({
            top: $r('app.float.distance_2'),
          })
          .wordBreak(WordBreak.BREAK_WORD)
          .textAlign(TextAlign.Start)
          .visibility(this.isSystemLanguage ? Visibility.None : Visibility.Visible)
      }
      .padding({
        top: $r('app.float.distance_8'),
        bottom: $r('app.float.distance_8')
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .constraintSize({ minHeight: this.isSystemLanguage ? $r('app.float.wh_value_48') : $r('app.float.wh_value_64') })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
        .fontSize($r('app.float.length_22'))
        .fontWeight(FontWeight.Regular)
        .renderingStrategy(SymbolRenderingStrategy.SINGLE)
        .fontColor([$r('sys.color.ohos_id_color_activated')])
        .visibility(this.isSystemLanguage ? Visibility.Visible : Visibility.None)
        .draggable(false)
    }
    .padding({ start: PADDING_8, end: PADDING_8 })
    .hitTestBehavior(this.clickable ? HitTestMode.Default : HitTestMode.Block)
    .id(DEFAULT_COMB_ID)
    .align(Alignment.Start)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor(this.isTouched ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
    .stateStyles({
      normal: this.normalStateStyles,
      pressed: pressedStateIconStyles,
    })
    .width('100%')
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .onClick(() => {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.UPDATES_LANGUAGE, this.item);
      languageAndRegionModel.setSystemLanguage(this.item);
      this.clickable = false;
      setTimeout(() => {
        this.clickable = true;
      }, 2000);
      AccessibilityUtils.announceRadioSelected();
    })
    .accessibilityText(this.getAccessibilityText(this.item))
    .accessibilityDescription(this.isSystemLanguage ?
      TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS : TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS)
    .onTouch((event?: TouchEvent) => {
      if (event?.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event?.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
  }

  @Styles
  normalStateStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.ohos_id_color_hover') : Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  private getAccessibilityText(language: string): string {
    if (!AccessibilityUtils.isAccessibilityMode()) {
      return '';
    }
    if (languageAndRegionModel.isSystemLanguage(language)) {
      return ResourceUtil.getStringSync($r('app.string.be_chosen')) + ',' +
      languageAndRegionModel.getSysDisplayLanguage(language);
    } else {
      return languageAndRegionModel.getSysDisplayLanguage(language) + ',' +
      languageAndRegionModel.getDisplayLanguage(language);
    }
  }
}

/**
 * Text Component
 */
@Component
struct AddText {
  @State isTouched: boolean = false;
  @State isHover: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Column() {
      Row() {
        Text($r('app.string.addLanguage'))
          .fontSize($r('app.float.font_16'))
          .constraintSize({ minHeight: $r('app.float.wh_value_48') })
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_hyperlink'))
          .margin({
            start: PADDING_8,
            top: FontScaleUtils.getCurrentContentPadding(),
            bottom: FontScaleUtils.getCurrentContentPadding()
          })
          .textAlign(TextAlign.Start);
      }
      .height('auto')
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor(this.isTouched ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
      .stateStyles({
        normal: this.normalStateStyles,
        pressed: pressedStateIconStyles,
      })
      .onHover((hover: boolean) => {
        this.isHover = hover;
      })
      .onTouch((event?: TouchEvent) => {
        if (event?.type === TouchType.Down) {
          this.isTouched = true;
        }
        if (event?.type === TouchType.Up) {
          this.isTouched = false;
        }
      });
    }
    .padding($r('app.float.distance_4'))
    .constraintSize({ minHeight: $r('app.float.wh_value_56') })
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .onClick(() => {
      this.onEntryClick();
    })
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    LogUtil.info('LanguageAndRegionPage onEntryClick');
    this.pushName(NavEntryKey.ADD_LANGUAGE_ENTRY, null);
  }

  @Styles
  normalStateStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.ohos_id_color_hover') : Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}

/**
 * Region Component
 */
@Component
struct Region {
  @StorageProp('currentRegion') currentRegion: string = languageAndRegionModel.getSysDisplayRegion();
  @State isTouched: boolean = false;
  @State isHover: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FontScaleUtils
        .isExtraLargeFontMode() ? FlexWrap.Wrap : FlexWrap.NoWrap,
        justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text($r('app.string.currentRegion'))
            .fontSize($r('app.float.font_16'))
            .constraintSize({ minHeight: $r('app.float.wh_value_48') })
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .margin({ start: PADDING_8,
              top: FontScaleUtils.getCurrentContentPadding() })
            .textAlign(TextAlign.Start);
        }
        .width(FontScaleUtils.isExtraLargeFontMode() ? '100%' : 'auto')

        Row() {
          Text(this.currentRegion)
            .fontSize($r('app.float.font_14'))
            .constraintSize({ minHeight: $r('app.float.wh_value_19') })
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ end: PADDING_4 })
          Image($r('app.media.ic_settings_arrow'))
            .fillColor($r('sys.color.icon_fourth'))
            .width($r('app.float.wh_value_12'))
            .height($r('app.float.wh_value_24'))
            .margin({ end: PADDING_8 })
            .draggable(false)
            .matchTextDirection(true);
        }
        .width(FontScaleUtils.isExtraLargeFontMode() ? '95%' : 'auto')
        .margin({
          start: FontScaleUtils.isExtraLargeFontMode() ? PADDING_8 : PADDING_0,
          bottom: FontScaleUtils.getCurrentContentPadding()
        })
        .justifyContent(FontScaleUtils.isExtraLargeFontMode() ?
          FlexAlign.SpaceBetween : FlexAlign.End)
      }
      .height('auto')
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor(this.isTouched ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
      .stateStyles({
        normal: this.normalStateStyles,
        pressed: pressedStateIconStyles,
      })
      .onHover((hover: boolean) => {
        this.isHover = hover;
      })
      .onClick(() => {
        this.onEntryClick();
      })
      .onTouch((event?: TouchEvent) => {
        if (event?.type === TouchType.Down) {
          this.isTouched = true;
        }
        if (event?.type === TouchType.Up) {
          this.isTouched = false;
        }
      })
    }
    .id('languageAndRegionPage.selectRegion.column')
    .justifyContent(FlexAlign.Center)
    .padding($r('app.float.distance_4'))
    .constraintSize({ minHeight: $r('app.float.wh_value_56') })
    .width('100%')
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
  }

  @Styles
  normalStateStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.ohos_id_color_hover') : Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    LogUtil.info('Region onEntryClick');
    this.pushName(NavEntryKey.SELECT_REGION_ENTRY, null);
  }
}