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

import { PADDING_16, PADDING_8, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EditLanguageController, languageAndRegionModel } from '@ohos/settings.language';
import { DefaultNavPageHeaderStyle, PageTitleTextStyle, } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { HiSysSystemAndUpdatesEventGroup,
  HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

/* instrument ignore file */
const DELETE_LANGUAGE_BUTTON: string = 'delete_language_button';
const EDIT_LANGUAGE_CONFIRM_BUTTON: string = 'edit_language_confirm_button';
const STROKE_WIDTH_1_PX: string = '1px';

/**
 * Home Page Of EditLanguage
 */
@Builder
export function EditLanguageLoader($$: Params): void {
  EditLanguage();
}

class HeadComponentStyle extends DefaultNavPageHeaderStyle {
  constructor() {
    super();
    LogUtil.info(`rootContainer: ${this.rootContainer?.toString() || ''}  is: ${!!this.rootContainer}`);
    if (this.rootContainer) {
      this.rootContainer.padding = { left: $r('app.float.distance_16'), right: $r('app.float.distance_16') };
    }
  }
}

@Component
export struct EditLanguage {
  private TAG = `Settings EditLanguage`;
  @State private controller: EditLanguageController = new EditLanguageController();
  @Consume('pathInfos') pathInfos: NavPathStack;
  private headComponentStyle = new HeadComponentStyle();

  build() {
    NavDestination() {
      Column() {
        GridContainer({
          columns: 12,
          sizeType: SizeType.MD,
          gutter: vp2px(1) === 2 ? '12vp' : '0vp',
          margin: '0vp',
        }) {
          Row() {
            Column() {
            }
            .width('100%')
            .height('100%')
            .useSizeType({
              xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
              md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
            });

            Column() {
              HeadComponent({
                headName: $r('app.string.editLanguage'),
                controller: $controller,
                style: this.headComponentStyle
              });
              EditList({ controller: $controller });
            }
            .height('100%')
            .width('100%')
            .useSizeType({
              xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
              md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
            });

            Column() {
            }
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
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width('100%')
      .height('100%');
    }.hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      LogUtil.info(`${this.TAG} onPageShow`);
      DynamicLoader.getInstance().pageTransitionSuccess(this.TAG);
    })
    .onHidden(() => {
      LogUtil.info(`${this.TAG} onPageHide`);
    })
    .onBackPressed(() => {
      this.controller.cancelDeleteLanguage();
      this.pathInfos?.pop();
      return true;
    })
  }
}

@Styles
function normalStateIconStyles() {
  .backgroundColor(Color.Transparent)
}

@Styles
function pressedStateIconStyles() {
  .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
    ? $r('sys.color.ohos_id_color_click_effect') : null)
  .borderRadius('12vp')
}

/**
 * Edit List Of Added Language
 */
@Component
struct EditList {
  @Link controller: EditLanguageController;
  @State touchedItem: string = ''

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
      ? $r('sys.color.ohos_id_color_click_effect') : null)
  }

  build() {
    List() {
      ListItemGroup() {
        ForEach(this.controller.getDelAfterLanguages(), (item: string, index: number) => {
          EditLanguageItem({ item: item, controller: this.controller })
        }, (item: string) => item);
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .divider({
        strokeWidth: STROKE_WIDTH_1_PX,
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: $r('app.float.distance_8'),
        endMargin: $r('app.float.distance_8')
      })
      .padding($r('app.float.distance_4'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .margin({ top: PADDING_16, start: PADDING_16, end: PADDING_16 })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .flexShrink(1)
  }
}

@CustomDialog
export struct EditLanguageDialog {
  private tag = `EditLanguageDialog`;
  private controller?: CustomDialogController;
  private message: ResourceStr = '';

  build() {
    Column() {
      Text(this.message)
        .fontFamily('HarmonyHeiTi')
        .fontSize('16fp')
        .maxFontScale(2)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .constraintSize({ minHeight: '21vp' })
        .margin({
          top: PADDING_24,
          end: PADDING_24,
          bottom: PADDING_8,
          start: PADDING_24,
        })
      Button(ResourceUtil.getStringSync($r('app.string.confirm')),
        {
          stateEffect: false,
        })
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .width('calc(100% - 32vp)')
        .constraintSize({ minHeight: '40vp' })
        .margin({ bottom: PADDING_16, start: PADDING_16, end: PADDING_16 })
        .stateStyles({
          normal: normalStateIconStyles,
          pressed: pressedStateIconStyles,
        })
        .onClick(() => {
          LogUtil.info(`${this.tag} click change.`);
          this.controller?.close();
        })
    }
    .borderRadius('32vp')
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }
}


@Component
struct EditLanguageItem {
  @Prop item: string;
  @State isHover: boolean = false;
  @State isTouched: boolean = false;
  @Link controller: EditLanguageController;

  private editLanguageController = new CustomDialogController({
    builder: EditLanguageDialog({
      message: $r('app.string.saveLanguage')
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
  });

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Column() {
          Text(languageAndRegionModel.getSysDisplayLanguage(this.item))
            .fontSize($r('app.float.font_16'))
            .constraintSize({ minHeight: $r('app.float.wh_value_22') })
            .fontWeight(FontWeight.Medium)
            .margin(languageAndRegionModel.isSystemLanguage(this.item) ? {
              top: $r('app.float.wh_value_13'),
              bottom: $r('app.float.wh_value_13')
            } : {
              top: $r('app.float.distance_10'),
              bottom: $r('app.float.distance_2')
            })
            .fontColor(languageAndRegionModel.isSystemLanguage(this.item) ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_primary'))
            .textAlign(TextAlign.Start);
          Text(languageAndRegionModel.getDisplayLanguage(this.item))
            .fontSize($r('app.float.font_14'))
            .constraintSize({ minHeight: $r('app.float.wh_value_19') })
            .margin({ bottom: $r('app.float.distance_11') })
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .visibility(languageAndRegionModel.isSystemLanguage(this.item) ? Visibility.None : Visibility.Visible);
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .alignItems(HorizontalAlign.Start)
        .accessibilityGroup(true)
      }

      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.minus_circle_fill'))
          .fontSize($r('app.float.length_22'))
          .fontWeight(FontWeight.Regular)
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .fontColor([$r('sys.color.warning')])
          .draggable(false);
      }
      .id(`delete_button_${languageAndRegionModel.getSysDisplayLanguage(this.item)}`)
      .backgroundColor(Color.Transparent)
      .accessibilityText($r('app.string.delete'))
      .onClick(() => {
        let addedLanguages: string[] = this.controller?.getDelAfterLanguages();
        if (addedLanguages.length <= 1) {
          this.editLanguageController.open();
        } else {
          HiSysEventUtil.reportButtonEvent(DELETE_LANGUAGE_BUTTON, this.item);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.DELETE_LANGUAGE, this.item);
          this.controller?.deleteSingleLanguage(this.item);
          let nextFocusItem: string = addedLanguages[0];
          let index: number = addedLanguages.indexOf(this.item);
          if (index === (addedLanguages.length - 1)) {
            nextFocusItem = addedLanguages[index - 1];
          } else {
            nextFocusItem = addedLanguages[index + 1];
          }
          let id: string = 'delete_button_' + languageAndRegionModel.getSysDisplayLanguage(nextFocusItem);
          AccessibilityUtils.requestFocusAccessibility(id);
        }
      });
    }
    .width('100%')
    .padding({ start: PADDING_8, end: PADDING_8 })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor(this.isTouched ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event)
    })
    .onHover((isHovered: boolean) => {
      this.isHover = isHovered;
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
 * Head Component
 */
@Component
struct HeadComponent {
  private headName: string | Resource = '';
  @Link controller: EditLanguageController;
  @Consume('pathInfos') pathInfos?: NavPathStack;
  style?: DefaultNavPageHeaderStyle;

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .borderRadius('20vp')
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .borderRadius('20vp')
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize($r('app.float.wh_value_24'))
            .fontColor([$r('sys.color.ohos_id_color_primary')])
            .draggable(false);
        }
        .id('EditLanguage_closeButton')
        .hoverEffect(HoverEffect.Highlight)
        .width('40vp')
        .height('40vp')
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .margin({ end: PADDING_8 })
        .accessibilityText($r('app.string.dialog_disable'))
        .onClick(() => {
          HiSysEventUtil.reportDefaultBehaviorEvent(HiSysSystemEventGroup.CANCEL_LANGUAGE_EDIT);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.EDIT_LANGUAGE);
          this.controller.cancelDeleteLanguage();
          this.pathInfos?.pop();
        })

        Row() {
          Text(this.headName)
            .textStyle(this.style?.title as PageTitleTextStyle)
        }
      }

      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize($r('app.float.wh_value_24'))
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .draggable(false);
      }
      .onClick(() => {
        HiSysEventUtil.reportButtonEvent(EDIT_LANGUAGE_CONFIRM_BUTTON, '');
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.EDIT_LANGUAGE_CONFIRM);
        languageAndRegionModel.setAddedLanguages(this.controller.getDelAfterLanguages());
        this.pathInfos?.pop();
        if (this.controller.languageList.length === 1) {
          AccessibilityUtils.requestFocusAccessibilityWithBundleName('comb_id_language');
        }
      })
      .id('EditLanguage_saveButton')
      .hoverEffect(HoverEffect.Highlight)
      .width('40vp')
      .height('40vp')
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .accessibilityText($r('app.string.done'))
    }
    .width((this.style)?.rootContainer?.size?.width as Length)
    .height(this.style?.rootContainer?.size?.height)
    .padding(this.style?.rootContainer?.padding)
    .margin(this.style?.rootContainer?.margin as Margin)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .layoutWeight(this.style?.rootContainer?.layoutWeight)
    .clip(this.style?.rootContainer?.clip)
    .borderRadius(this.style?.rootContainer?.borderRadius)
    .backgroundColor(this.style?.rootContainer?.backgroundColor);
  }
}

@Extend(Text)
function textStyle(textStyle: PageTitleTextStyle) {
  .width(textStyle?.size?.width as Length)
  .height(textStyle?.size?.height as Length)
  .constraintSize(textStyle?.constraintSize)
  .padding(textStyle?.padding ?? 0)
  .margin(textStyle?.margin ?? 0)
  .layoutWeight(textStyle?.layoutWeight ?? 0)
  .fontColor(textStyle?.fontColor)
  .fontSize(textStyle?.font?.size)
  .fontWeight(textStyle?.font?.weight)
  .fontFamily(textStyle?.font?.family)
  .fontStyle(textStyle?.font?.style)
  .textAlign(textStyle?.textAlign ?? TextAlign.Start)
  .textOverflow({ overflow: textStyle?.overflow ?? TextOverflow.Ellipsis })
  .maxLines(textStyle?.maxLines)
  .align(textStyle?.align)
  .backgroundColor(textStyle?.backgroundColor)
  .borderRadius(textStyle?.borderRadius as Length)
  .minFontSize(textStyle?.font?.minFontSize as Length ?? textStyle?.font?.size)
  .maxFontSize(textStyle?.font?.maxFontSize as Length ?? textStyle?.font?.size)
}