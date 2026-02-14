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

import { Params, PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PADDING_16, PADDING_24, PADDING_4, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import DpiManager from '@ohos/settings.common/src/main/ets/utils/DpiManager';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { BasicDataSource } from '@ohos/settings.language/src/main/ets/model/BasicDataSource';
import { languageAndRegionModel } from '@ohos/settings.language/src/main/ets/model/LanguageAndRegionModel';
import { SubHeaderComponent } from '../SubHeader';
/* instrument ignore file */
const ADD_LANGUAGE_ENTRY: string = 'add_language_entry';
const RETAIN_CURRENT_LANGUAGE: string = 'retain_current_language';
const CHANGE_CURRENT_LANGUAGE: string = 'change_current_language';
const ENTER_ADD_LANGUAGE_ENTRY: string = 'enter_add_language_entry';
const STROKE_WIDTH_1_PX: string = '1px';

@Styles
function normalStateIconStyles() {
  .backgroundColor(Color.Transparent)
}

@Styles
function pressedStateIconStyles() {
  .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
    ? $r('sys.color.ohos_id_color_click_effect') : $r('sys.color.ohos_id_color_click_effect'))
  .borderRadius('20vp')
}

/**
 * Home Page Of AddLanguage
 */
@Builder
export function AddLanguageLoader($$: Params): void {
  AddLanguage({ params: $$ as Object as PushParam });
}

@Component
export struct AddLanguage {
  private TAG: string = `Settings AddLanguage`;
  private listSpace: string = '10vp';
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  @State params: PushParam | null = null;
  title: string = ResourceUtil.getStringSync($r('app.string.addLanguage'));

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
              md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 },
            });

            Column() {
              Blank().height($r('app.float.navigation_56'))
              List() {
                ListItem() {
                  SubHeaderComponent({ titleContent: $r('app.string.addedLanguage') })
                }

                ListItem() {
                  AddedLanguagesList();
                }

                ListItem() {
                  SubHeaderComponent({ titleContent: $r('app.string.allLanguage') })
                }

                ListItem() {
                  AllLanguagesList();
                }
              }
              .flexShrink(1)
              .padding({ start: PADDING_16, end: PADDING_16 })
              .edgeEffect(EdgeEffect.Spring);
            }
            .height('100%')
            .width('100%')
            .useSizeType({
              xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
              md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 },
            });

            Column() {
            }
            .width('100%')
            .height('100%')
            .useSizeType({
              xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
              md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 },
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
    }.hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      LogUtil.info(`${this.TAG} onPageShow`);
      DynamicLoader.getInstance().pageTransitionSuccess(this.TAG);
    })
    .onHidden(() => {
      LogUtil.info(`${this.TAG} onPageHide`);
    })
  }

  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    ResourceUtil.getString($r('app.float.distance_10')).then(value => this.listSpace = value);
    HiSysEventUtil.reportEntryEvent(ENTER_ADD_LANGUAGE_ENTRY, '');
  }
}


/**
 * List Of Added Language
 */
@Component
struct AddedLanguagesList {
  @StorageLink('addedLanguages') addedLanguages: Array<string> = languageAndRegionModel.getAddedLanguages();

  build() {
    List() {
      ForEach(this.addedLanguages, (item: string) => {
        LanguageItem({ item: item, isClickable: false })
      }, (item: string) => item);
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding({
      start: PADDING_4,
      end: PADDING_4,
      bottom: PADDING_4,
      top: PADDING_4
    })
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
struct LanguageItem {
  @State item: string = '';
  @State isHover: boolean = false;
  @State isTouched: boolean = false;
  @Prop isClickable: boolean = false;

  build() {
    Column() {
      Text(languageAndRegionModel.getSysDisplayLanguage(this.item))
        .fontSize($r('app.float.font_16'))
        .constraintSize({ minHeight: $r('app.float.wh_value_22') })
        .fontWeight(FontWeight.Medium)
        .margin({ top: $r('app.float.distance_10'), bottom: $r('app.float.distance_2') })
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .textAlign(TextAlign.Start);
      Text(languageAndRegionModel.getDisplayLanguage(this.item))
        .fontSize($r('app.float.font_14'))
        .constraintSize({ minHeight: $r('app.float.wh_value_19') })
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: $r('app.float.distance_11') })
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Start);
    }
    .align(LanguageUtils.isLtrDirection() ? Alignment.Start : Alignment.End)
    .width('100%')
    .padding({ start: PADDING_8, end: PADDING_8 })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor(this.isTouched ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
    .accessibilityGroup(true)
    .stateStyles({
      normal: this.normalStateStyles,
      pressed: this.pressedStateStyles,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .alignItems(HorizontalAlign.Start)
    .onHover((hover: boolean) => {
      if (!this.isClickable) {
        return;
      }
      this.isHover = hover;
    })
    .onTouch((event?: TouchEvent) => {
      if (!this.isClickable) {
        return;
      }
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

  @Styles
  pressedStateStyles() {
    .backgroundColor(this.isClickable
      ? $r('sys.color.ohos_id_color_click_effect') : null)
  }
}

/**
 * Addlanguage dialog
 */
@CustomDialog
export struct AddLanguageDialog {
  @Consume('pathInfos') pathInfos: NavPathStack;
  private tag = `AddLanguageDialog`;
  private controller?: CustomDialogController;
  private message: ResourceStr = '';
  private item: string = '';

  private isExtraLargeFontMode() {
    return FontScaleUtils.isExtraLargeFontMode();
  }

  private needWrap() {
    let result: boolean = FontScaleUtils.isLargeFontMode();
    if (result) {
      let dpi: string = SettingsDataUtils.getSettingsData(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE,
        DpiManager.defaultDensityDpi.toString());
      try {
        result = Number(dpi) >= DpiManager.maxDensityDpi;
      } catch (error) {
        LogUtil.showError(this.tag, `convert number error ${error?.message}, code: ${error?.code}`);
      }
    }
    // 字体>=特大一档 或者 字体特大且显示大小最大时换行显示
    return this.isExtraLargeFontMode() || result;
  }

  build() {
    Column() {
      Text(this.message)
        .fontFamily('HarmonyHeiTi')
        .fontSize('16fp')
        .maxFontScale(2)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_primary'))
        .constraintSize({ minHeight: '21vp' })
        .margin({
          top: PADDING_24,
          end: PADDING_24,
          bottom: PADDING_8,
          start: PADDING_24,
        })
      Flex({ wrap: this.needWrap() ? FlexWrap.Wrap : FlexWrap.NoWrap,
        justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Button($r('app.string.keepCurrent'),
          {
            stateEffect: false,
          })
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .width(this.needWrap() ? '100%' : 'calc(50% - 8vp)')
          .constraintSize({ minHeight: '40vp' })
          .stateStyles({
            normal: normalStateIconStyles,
            pressed: pressedStateIconStyles,
          })
          .onClick(() => {
            LogUtil.info(`${this.tag} click keepCurrent.`);
            AppStorage.set('addedLanguages', languageAndRegionModel.getAddedLanguages());
            this.controller?.close();
            this.pathInfos?.pop();
            HiSysEventUtil.reportButtonEvent(RETAIN_CURRENT_LANGUAGE, '');
          })
        Divider()
          .vertical(true)
          .strokeWidth(px2vp(2))
          .height($r('app.float.padding_24'))
          .color($r('sys.color.comp_divider'))
          .visibility(this.needWrap() ? Visibility.None : Visibility.Visible)
        Button(ResourceUtil.getStringSync($r('app.string.change')),
          {
            stateEffect: false,
          })
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .width(this.needWrap() ? '100%' : 'calc(50% - 8vp)')
          .constraintSize({ minHeight: '40vp' })
          .stateStyles({
            normal: normalStateIconStyles,
            pressed: pressedStateIconStyles,
          })
          .onClick(() => {
            LogUtil.info(`${this.tag} click change.`);
            this.controller?.close();
            languageAndRegionModel.setSystemLanguage(this.item);
            languageAndRegionModel.setAddLanguageChange(true);
            this.pathInfos?.pop();
            HiSysEventUtil.reportButtonEvent(CHANGE_CURRENT_LANGUAGE, this.item);
          })
      }.margin({ bottom: PADDING_16, start: PADDING_16, end: PADDING_16 })
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

/**
 * List Of All Language
 */
@Component
struct AllLanguagesList {
  private TAG = `Settings AllLanguagesList`;
  private allLanguages: AllLanguages = new AllLanguages(languageAndRegionModel.getAllLanguages());
  @State touchedItem: string = '';
  @Consume('pathInfos') pathInfos: NavPathStack;

  private item = '';
  private addLanguageController = new CustomDialogController({
    builder: AddLanguageDialog({
      message: $r('app.string.changeLanguage', languageAndRegionModel.getSysDisplayLanguage(this.item)),
      item: this.item
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
  });

  build() {
    List() {
      LazyForEach(this.allLanguages, (item: string, index: number) => {
        LanguageItem({ item: item, isClickable: true })
        .onClick(() => {
          HiSysEventUtil.reportEntryEvent(ADD_LANGUAGE_ENTRY, item);
          if (!languageAndRegionModel.isInAddedLanguage(item)) {
            languageAndRegionModel.addLanguage(item);
            AppStorage.set('addedLanguages', languageAndRegionModel.getAddedLanguages());
            this.item = item;
            LogUtil.info(`${this.TAG} item value: ${this.item}`);
            this.addLanguageController.open();
          } else {
            ResourceUtil.getString($r('app.string.hasAdded')).then(value => {
              ToastUtil.showToast(value, ToastUtil.SHORT_DURATION)
            })
          }
        })
      }, (item: string) => item);
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding($r('app.float.distance_4'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .divider({
      strokeWidth: STROKE_WIDTH_1_PX,
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r('app.float.distance_8'),
      endMargin: $r('app.float.distance_8')
    });
  }

  aboutToDisappear(): void {
    this.addLanguageController?.close();
    LogUtil.info(`${this.TAG} Settings AddLanguageDialog onPageHide`);
  }
}

/**
 * Array Of AllLanguages For Lazy Loading
 */
class AllLanguages extends BasicDataSource {
  private languagesArray: string[] = [];

  constructor(languagesArray: string[]) {
    super();
    this.languagesArray = languagesArray;
  }

  public totalCount(): number {
    return this.languagesArray.length;
  }

  public getData(index: number): string {
    return this.languagesArray[index];
  }
}