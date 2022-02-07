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
import LogUtil from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import HeadComponent from '../../../../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LanguageAndRegionModel from '../../../../../default/model/systemImpl/languageSettings/LanguageAndRegionModel.ets'

/**
 * Home Page Of LanguageAndRegion Settings
 */
@Entry
@Component
struct LanguageAndRegion {
  private TAG = `${ConfigData.TAG} LanguageAndRegion`;

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.languageAndRegion'), isActive: true });
      List({space:10, initialIndex:0}){
        ListItem(){
          Flex({justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center}){
            Text($r("app.string.languageTab"))
              .fontSize($r("app.float.font_22"))
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start)
              .height(ConfigData.WH_100_100);
            Navigator({target: 'pages/system/languageSettings/languageAndRegion/editLanguage'}){
              Text($r("app.string.edit"))
                .fontSize($r("app.float.font_22"))
                .fontColor($r("app.color.font_color_007DFF"))
                .textAlign(TextAlign.End)
                .height(ConfigData.WH_100_100);
            }
          }
          .margin({left:$r("app.float.distance_24"),right:$r("app.float.distance_24"), bottom:$r("app.float.distance_8")})
          .height($r("app.float.wh_value_56"));
        }

        ListItem(){
          AddedList();
        }

        ListItem(){
          AddText();
        }

        ListItem(){
          Text($r("app.string.region"))
            .fontSize($r("app.float.font_22"))
            .fontColor($r("app.color.font_color_182431"))
            .textAlign(TextAlign.Start)
            .padding({left:$r("app.float.distance_24"), right:$r("app.float.distance_24"), top:$r("app.float.distance_8"), bottom:$r("app.float.distance_8")})
            .height($r("app.float.wh_value_56"));
        }

        ListItem(){
         Region();
        }
      }
      .margin({left:$r("app.float.distance_24"), right:$r("app.float.distance_24"), top:$r("app.float.distance_16")});
    }
    .height(ConfigData.WH_100_100)
    .width(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_E3E3E3_grey"));
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
    List({space:0}){
      ForEach(this.addedLanguages, (item) => {
        ListItem(){
          Column(){
            Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
              .fontSize($r("app.float.font_28"))
              .height(LanguageAndRegionModel.isSystemLanguage(item) ? $r("app.float.wh_value_56") : $r("app.float.wh_value_44"))
              .padding({left:$r("app.float.distance_16"),right:$r("app.float.distance_16")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
            Text(LanguageAndRegionModel.getDisplayLanguage(item))
              .fontSize($r("app.float.font_22"))
              .height($r("app.float.wh_value_32"))
              .padding({left:$r("app.float.distance_16"),right:$r("app.float.distance_16"),bottom:$r("app.float.distance_8")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start)
              .visibility(LanguageAndRegionModel.isSystemLanguage(item) ? Visibility.None : Visibility.Visible);
          }
          .alignItems(HorizontalAlign.Start)
        }
        .align(Alignment.Start)
        .borderRadius($r("app.float.radius_24"))
        .backgroundColor(item === this.touchedItem ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
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
    .borderRadius($r("app.float.radius_40"))
    .padding({left:$r("app.float.distance_8"),right:$r("app.float.distance_8"),top:$r("app.float.distance_24"),bottom:$r("app.float.distance_24")})
    .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey"), startMargin:$r("app.float.distance_16"), endMargin:$r("app.float.distance_16")})
    .backgroundColor($r("app.color.white_bg_color"));
  }
}


/**
 * Text Component
 */
@Component
struct AddText {
  @State touched:boolean = false;

  build(){
    Navigator({ target: 'pages/system/languageSettings/languageAndRegion/addLanguage' }) {
      Row(){
        Text($r("app.string.addLanguage"))
          .fontSize($r("app.float.font_28"))
          .fontColor($r("app.color.font_color_007DFF"))
          .padding({left:$r("app.float.distance_16"),right:$r("app.float.distance_16")})
          .height($r("app.float.wh_value_70"))
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Start)
          .backgroundColor(this.touched ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
          .borderRadius($r("app.float.radius_24"))
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.touched = true;
            }
            if (event.type === TouchType.Up) {
              this.touched = false;
            }
          });
      }
      .borderRadius($r("app.float.radius_24"))
      .padding({ left: $r("app.float.distance_8"), right: $r("app.float.distance_8"), top: $r("app.float.distance_8"), bottom: $r("app.float.distance_8") })
      .backgroundColor($r("app.color.white_bg_color"));
    }
  }
}


/**
 * Region Component
 */
@Component
struct Region {
  @StorageLink('currentRegion') currentRegion:string = LanguageAndRegionModel.getSysDisplayRegion();
  @State touched:boolean = false;

  build(){
    Navigator({ target: 'pages/system/languageSettings/languageAndRegion/selectRegion' }) {
      Row(){
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text($r("app.string.currentRegion"))
            .fontSize($r("app.float.font_28"))
            .fontColor($r("app.color.font_color_182431"))
            .textAlign(TextAlign.Start);
          Row() {
            Text(this.currentRegion)
              .fontSize($r("app.float.font_28"))
              .fontColor($r("app.color.font_color_007DFF"));
            Image('/res/image/ic_settings_arrow.svg')
              .width($r('app.float.wh_value_40'))
              .height($r('app.float.wh_value_40'));
          }
        }
        .height($r("app.float.wh_value_70"))
        .backgroundColor(this.touched ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
        .borderRadius($r("app.float.radius_24"))
        .padding({left:$r("app.float.distance_16"),right:$r("app.float.distance_16")})
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.touched = true;
          }
          if (event.type === TouchType.Up) {
            this.touched = false;
          }
        });
      }
      .borderRadius($r("app.float.radius_24"))
      .padding({ left: $r("app.float.distance_8"), right: $r("app.float.distance_8"), top: $r("app.float.distance_8"), bottom: $r("app.float.distance_8") })
      .backgroundColor($r("app.color.white_bg_color"));
    }
  }
}
