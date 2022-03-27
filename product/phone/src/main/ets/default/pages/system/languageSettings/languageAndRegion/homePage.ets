/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import HeadComponent from '../../../../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LanguageAndRegionModel from '../../../../../default/model/systemImpl/languageSettings/LanguageAndRegionModel'
import ResourceUtil from '../../../../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import {SubHeader} from '../../../../../../../../../../common/component/src/main/ets/default/textComponent.ets';

/**
 * Home Page Of LanguageAndRegion Settings
 */
@Entry
@Component
struct LanguageAndRegion {
  private TAG = `${ConfigData.TAG} LanguageAndRegion`;

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            HeadComponent({headName: $r('app.string.languageAndRegion'), isActive: true});
            List() {
              ListItem() {
                Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                  Text($r("app.string.languageTab"))
                    .fontSize($r("app.float.font_14"))
                    .lineHeight($r("app.float.lineHeight_19"))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .textAlign(TextAlign.Start)
                    .margin({top: $r("app.float.distance_19_5"), bottom: $r("app.float.distance_9_5")});
                  Navigator({target: 'pages/system/languageSettings/languageAndRegion/editLanguage'}) {
                    Text($r("app.string.edit"))
                      .fontColor($r("app.color.font_color_007DFF"))
                      .fontSize($r("app.float.font_14"))
                      .fontWeight(FontWeight.Medium)
                      .lineHeight($r("app.float.lineHeight_19"))
                      .textAlign(TextAlign.End)
                      .margin({top: $r("app.float.distance_19_5"), bottom: $r("app.float.distance_9_5")});
                  }
                }
                .margin({left: $r("sys.float.ohos_id_card_margin_start"), right: $r("sys.float.ohos_id_card_margin_end")})
                .height($r("app.float.wh_value_48"));
              }

              ListItem() {
                AddedList();
              }.margin({ bottom:$r("app.float.distance_12") })

              ListItem() {
                AddText();
              }

              ListItem() {
                SubHeader({ titleContent: $r('app.string.region') })
              }

              ListItem() {
                Region();
              }

              ListItem() {
                RegionExample();
              }

            }
          }
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .padding({left: $r("app.float.distance_24"), right: $r("app.float.distance_24")})
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  aboutToDisappear(){
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
  }

}


/**
 * List Of Added Languages
 */
@Component
struct AddedList {
  @StorageLink('addedLanguages') addedLanguages:Array<string> = LanguageAndRegionModel.getAddedLanguages();
  @State touchedItem:string = '';

  build(){
    List(){
      ForEach(this.addedLanguages, (item) => {
        ListItem(){
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
            Column(){
              Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
                .fontSize($r("app.float.font_16"))
                .lineHeight($r("app.float.wh_value_22"))
                .fontWeight(FontWeight.Medium)
                .padding(LanguageAndRegionModel.isSystemLanguage(item) ? {top: $r("app.float.distance_21"), bottom: $r("app.float.distance_17")} : {top: $r("app.float.distance_10"), bottom: $r("app.float.distance_2")})
                .fontColor(LanguageAndRegionModel.isSystemLanguage(item) ? $r("app.color.font_color_007DFF") : $r("app.color.font_color_182431"))
                .textAlign(TextAlign.Start);
              Text(LanguageAndRegionModel.getDisplayLanguage(item))
                .fontSize($r("app.float.font_14"))
                .lineHeight($r("app.float.wh_value_19"))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                .margin({ bottom: $r("app.float.distance_11") })
                .fontColor($r("app.color.font_color_182431"))
                .textAlign(TextAlign.Start)
                .visibility(LanguageAndRegionModel.isSystemLanguage(item) ? Visibility.None : Visibility.Visible);
            }
            .alignItems(HorizontalAlign.Start)

            Image($r("app.media.ic_ok"))
              .width($r('app.float.wh_value_24'))
              .height($r('app.float.wh_value_24'))
              .objectFit(ImageFit.Contain)
              .visibility(LanguageAndRegionModel.isSystemLanguage(item) ? Visibility.Visible : Visibility.None);
          }
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
        .onClick(()=>{
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
      }, item => item);
    }
    .padding($r("app.float.distance_4"))
    .borderRadius($r("app.float.radius_24"))
    .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey"), startMargin: $r("app.float.distance_8"), endMargin: $r("app.float.distance_8")})
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
      Row() {
        Text($r("app.string.addLanguage"))
          .fontSize($r('app.float.font_16'))
          .lineHeight($r('app.float.wh_value_22'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("app.color.font_color_007DFF"))
          .margin({left: $r('app.float.distance_8')})
          .textAlign(TextAlign.Start);
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
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
  }
}


/**
 * Region Component
 */
@Component
struct Region {
  @StorageProp('currentRegion') currentRegion:string = LanguageAndRegionModel.getSysDisplayRegion();
  @State isTouched:boolean = false;

  build() {
    Navigator({target: 'pages/system/languageSettings/languageAndRegion/selectRegion'}) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text($r("app.string.currentRegion"))
            .fontSize($r('app.float.font_16'))
            .lineHeight($r('app.float.wh_value_22'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_182431'))
            .margin({left: $r('app.float.distance_8')})
            .textAlign(TextAlign.Start);
        }

        Row() {
          Text(this.currentRegion)
            .fontSize($r('app.float.font_14'))
            .lineHeight($r('app.float.wh_value_19'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .margin({ right: $r('app.float.distance_4') })
            .textAlign(TextAlign.End);
          Image('/res/image/ic_settings_arrow.svg')
            .width($r('app.float.wh_value_12'))
            .height($r('app.float.wh_value_24'))
            .margin({right: $r('app.float.distance_8')});
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


/**
 * Region Example
 */
@Component
struct RegionExample {
  private textList = [
    $r("app.string.regionExampleLanguage"),
    $r("app.string.regionExampleDate"),
    $r("app.string.regionExampleTime"),
    $r("app.string.regionExampleNumber"),
    $r("app.string.regionExamplePercent"),
    $r("app.string.regionExampleMoney")]
  private TAG = `${ConfigData.TAG} RegionExample `;
  private listItemSpace: string;

  build(){
    Column(){
      Text($r("app.string.regionExample"))
        .fontSize($r('app.float.font_14'))
        .lineHeight($r('app.float.wh_value_19'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Medium)
        .margin({top:$r("app.float.distance_19_5"), bottom:$r("app.float.distance_9_5")})
        .width(ConfigData.WH_100_100);
      List({space: this.listItemSpace}){
        ForEach(this.textList, (item) => {
          ListItem(){
            Text(item)
              .fontSize($r('app.float.font_14'))
              .lineHeight($r('app.float.wh_value_19'))
              .fontColor($r("app.color.color_E3E3E3_grey"))
              .textAlign(TextAlign.Start)
              .width(ConfigData.WH_100_100);
          }
          .align(Alignment.Start)
          .width(ConfigData.WH_100_100);
        })
      }
    }
    .padding({left: $r("sys.float.ohos_id_card_margin_start"), right: $r("sys.float.ohos_id_card_margin_end")})
    .width(ConfigData.WH_100_100)
  }

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    ResourceUtil.getString($r("app.float.distance_2")).then(value => this.listItemSpace = value);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}