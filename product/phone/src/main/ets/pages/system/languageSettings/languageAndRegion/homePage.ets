/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import router from '@system.router';
import LogUtil from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { SubHeader } from '../../../../../../../../../common/component/src/main/ets/default/textComponent';
import ConfigData from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LanguageAndRegionModel from '../../../../model/systemImpl/languageSettings/LanguageAndRegionModel';
import HeadComponent from '../../../../../../../../../common/component/src/main/ets/default/headComponent';

/**
 * Home Page Of LanguageAndRegion Settings
 */
@Entry
@Component
struct LanguageAndRegion {
  @StorageLink('addedLanguages') addedLanguages: Array<string> = LanguageAndRegionModel.getAddedLanguages();
  private TAG = `${ConfigData.TAG} LanguageAndRegion `;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.languageAndRegion'), isActive: true });

          List() {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text($r("app.string.languageTab"))
                  .fontSize($r("app.float.font_14"))
                  .lineHeight($r("app.float.lineHeight_19"))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .textAlign(TextAlign.Start)

                Text($r("app.string.edit"))
                  .fontColor($r("app.color.font_color_007DFF"))
                  .fontSize($r("app.float.font_14"))
                  .fontWeight(FontWeight.Medium)
                  .lineHeight($r("app.float.lineHeight_19"))
                  .textAlign(TextAlign.End)
                  .opacity(this.addedLanguages.length == 1 ? $r('sys.float.ohos_fa_alpha_disabled') : 1)
                  .onClick(() => {
                    if (this.addedLanguages.length > 1) {
                      router.push({ uri: 'pages/system/languageSettings/languageAndRegion/editLanguage' })
                    }
                  })
              }
              .margin({
                left: $r("sys.float.ohos_id_card_margin_start"),
                right: $r("sys.float.ohos_id_card_margin_end")
              })
              .height($r("app.float.wh_value_48"))
              .padding({top:$r('app.float.distance_19_5'),bottom:$r('app.float.distance_9_5')})
            }

            ListItem() {
              AddedList();
            }
            .margin({ bottom:$r("app.float.distance_12") })

            ListItem() {
              AddText();
            }

            ListItem() {
              SubHeader({ titleContent: $r('app.string.region') })
            }

            ListItem() {
              Region();
            }
          }
          .flexShrink(1)
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}

/**
 * List Of Added Languages
 */
@Component
struct AddedList {
  @StorageLink('addedLanguages') addedLanguages: Array<string> = LanguageAndRegionModel.getAddedLanguages();
  @State touchedItem:string = '';

  build(){
    List(){
      ForEach(this.addedLanguages, (item) => {
        ListItem(){
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
            Column(){
              Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
                .fontSize($r("sys.float.ohos_id_text_size_body1"))
                .lineHeight($r("app.float.wh_value_22"))
                .fontWeight(FontWeight.Medium)
                .padding(LanguageAndRegionModel.isSystemLanguage(item) ? {top: $r("app.float.distance_21"), bottom: $r("app.float.distance_21")} : {top: $r("app.float.distance_10"), bottom: $r("app.float.distance_2")})
                .fontColor(LanguageAndRegionModel.isSystemLanguage(item) ? $r("app.color.font_color_007DFF") : $r("app.color.font_color_182431"))
                .textAlign(TextAlign.Start)

              Text(LanguageAndRegionModel.getDisplayLanguage(item))
                .fontSize($r("sys.float.ohos_id_text_size_body2"))
                .lineHeight($r("app.float.wh_value_19"))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.ohos_id_color_primary'))
                .opacity($r('sys.float.ohos_fa_alpha_content_secondary'))
                .margin({ bottom: $r("app.float.distance_11") })
                .fontColor($r("app.color.font_color_182431"))
                .textAlign(TextAlign.Start)
                .visibility(LanguageAndRegionModel.isSystemLanguage(item) ? Visibility.None : Visibility.Visible)
            }
            .alignItems(HorizontalAlign.Start)

            Image($r("app.media.ic_ok"))
              .width($r('app.float.wh_value_24'))
              .height($r('app.float.wh_value_24'))
              .fillColor($r("sys.color.ohos_id_color_primary"))
              .objectFit(ImageFit.Contain)
              .visibility(LanguageAndRegionModel.isSystemLanguage(item) ? Visibility.Visible : Visibility.None);
          }
          .height($r('app.float.wh_value_64'))
          .padding({left: $r("app.float.distance_8"), right: $r("app.float.distance_8")})
        }
        .align(Alignment.Start)
        .borderRadius($r("app.float.radius_20"))
        .linearGradient(item === this.touchedItem ? {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
           } : {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
        .width(ConfigData.WH_100_100)
        .onClick(() => {
          LanguageAndRegionModel.setSystemLanguage(item);
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.touchedItem = item;
          }
          if (event.type === TouchType.Up) {
            this.touchedItem = '';
          }
        })
      });
    }
    .padding($r("app.float.distance_4"))
    .borderRadius($r("app.float.radius_24"))
    .divider({
      strokeWidth: $r('app.float.divider_wh'),
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r("app.float.distance_8"), 
      endMargin: $r("app.float.distance_8")
    })
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
  }
}


/**
 * Text Component
 */
@Component
struct AddText {
  @State isTouched:boolean = false;

  build() {
    Navigator({ target: 'pages/system/languageSettings/languageAndRegion/addLanguage' }) {
      Text($r("app.string.addLanguage"))
        .fontSize($r('app.float.font_16'))
        .lineHeight($r('app.float.wh_value_22'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.font_color_007DFF"))
        .margin({ left: $r('app.float.distance_8') })
        .textAlign(TextAlign.Start)
        .height(ConfigData.WH_100_100)
        .width(ConfigData.WH_100_100)
        .borderRadius($r('app.float.radius_20'))
        .linearGradient(this.isTouched ? {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                         } : {
                                               angle: 90,
                                               direction: GradientDirection.Right,
                                               colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                             })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isTouched = true;
          }
          if (event.type === TouchType.Up) {
            this.isTouched = false;
          }
        });
    }
    .padding($r("app.float.distance_4"))
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
  }
}

/**
 * Region Component
 */
@Component
struct Region {
  @StorageProp('currentRegion') currentRegion: string = LanguageAndRegionModel.getSysDisplayRegion();
  @State isTouched: boolean = false;

  build() {
    Navigator({ target: 'pages/system/languageSettings/languageAndRegion/selectRegion' }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r("app.string.currentRegion"))
          .fontSize($r('app.float.font_16'))
          .lineHeight($r('app.float.wh_value_22'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_primary"))
          .margin({ left: $r('app.float.distance_8') })
          .textAlign(TextAlign.Start);

        Row() {
          Text(this.currentRegion)
            .fontSize($r('app.float.font_14'))
            .lineHeight($r('app.float.wh_value_19'))
            .fontColor($r("sys.color.ohos_id_color_primary"))
            .margin({ right: $r('app.float.distance_4') })
            .textAlign(TextAlign.End);

          Image('/res/image/ic_settings_arrow.svg')
            .width($r('app.float.wh_value_12'))
            .height($r('app.float.wh_value_24'))
            .margin({ right: $r('app.float.distance_8') })
            .fillColor($r("sys.color.ohos_id_color_primary"))
            .opacity($r("app.float.opacity_0_2"))
        }
      }
      .height(ConfigData.WH_100_100)
      .width(ConfigData.WH_100_100)
      .borderRadius($r('app.float.radius_20'))
      .linearGradient(this.isTouched ? {
         angle: 90,
         direction: GradientDirection.Right,
         colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
         } : {
         angle: 90,
         direction: GradientDirection.Right,
         colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isTouched = true;
        }
        if (event.type === TouchType.Up) {
          this.isTouched = false;
        }
      });
    }
    .padding($r("app.float.distance_4"))
    .height($r('app.float.wh_value_56'))
    .width(ConfigData.WH_100_100)
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
  }
}