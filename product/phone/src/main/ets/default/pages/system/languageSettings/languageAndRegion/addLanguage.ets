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
import router from '@system.router';
import prompt from '@system.prompt';
import LogUtil from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import HeadComponent from '../../../../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import BasicDataSource from '../../../../../../../../../../common/utils/src/main/ets/default/model/BasicDataSource.ets';
import LanguageAndRegionModel from '../../../../../default/model/systemImpl/languageSettings/LanguageAndRegionModel.ets'

/**
 * Home Page Of AddLanguage
 */
@Entry
@Component
struct AddLanguage {
  private TAG = `${ConfigData.TAG} AddLanguage`;

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.addLanguage'), isActive: true })
      List({space: 10, initialIndex: 0}){
        ListItem() {
          Text($r("app.string.addedLanguage"))
            .fontSize($r("app.float.font_22"))
            .fontColor($r("app.color.font_color_182431"))
            .width(ConfigData.WH_100_100)
            .height($r("app.float.wh_value_26"))
            .textAlign(TextAlign.Start)
        }.padding($r("app.float.distance_24"));

        ListItem() {
          AddedLanguagesList();
        }

        ListItem() {
          Text($r("app.string.allLanguage"))
            .fontSize($r("app.float.font_22"))
            .fontColor($r("app.color.font_color_182431"))
            .width(ConfigData.WH_100_100)
            .height($r("app.float.wh_value_26"))
            .textAlign(TextAlign.Start)
        }.padding($r("app.float.distance_24"));

        ListItem() {
          AllLanguagesList();
        }
      }
      .margin({ left:$r("app.float.distance_24"), right:$r("app.float.distance_24"), top:$r("app.float.distance_16"), bottom:$r("app.float.distance_80") })
      .edgeEffect(EdgeEffect.Spring);
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
 * List Of Added Language
 */
@Component
struct AddedLanguagesList {
  @StorageLink('addedLanguages') addedLanguages:Array<string> = LanguageAndRegionModel.getAddedLanguages();
  @State touchedItem:string = '';

  build(){
    List({space:0}){
      ForEach(this.addedLanguages, (item) => {
        ListItem(){
          Column(){
            Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
              .fontSize($r("app.float.font_28"))
              .height($r("app.float.wh_value_32"))
              .margin({right:$r("app.float.distance_16"),top:$r("app.float.distance_20"),bottom:$r("app.float.distance_8")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
            Text(LanguageAndRegionModel.getDisplayLanguage(item))
              .fontSize($r("app.float.font_22"))
              .height($r("app.float.wh_value_26"))
              .margin({right:$r("app.float.distance_16"),bottom:$r("app.float.distance_20")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
          }
          .alignItems(HorizontalAlign.Start);
        }
        .align(Alignment.Start)
        .width(ConfigData.WH_100_100)
        .padding({ left: $r("app.float.distance_16"), right: $r("app.float.distance_16") })
        .borderRadius($r("app.float.radius_24"))
        .backgroundColor(item === this.touchedItem ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
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
    .padding($r("app.float.distance_8"))
    .borderRadius($r("app.float.radius_40"))
    .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey"), startMargin:$r("app.float.distance_16"), endMargin:$r("app.float.distance_16")})
    .backgroundColor($r("app.color.white_bg_color"));
  }
}


/**
 * List Of All Language
 */
@Component
struct AllLanguagesList {
  private allLanguages: AllLanguages = new AllLanguages(LanguageAndRegionModel.getAllLanguages());
  @State touchedItem:string = '';

  build(){
    List({space:0}){
      LazyForEach(this.allLanguages, (item) => {
        ListItem(){
          Column(){
            Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
              .fontSize($r("app.float.font_28"))
              .height($r("app.float.wh_value_32"))
              .margin({right:$r("app.float.distance_16"),top:$r("app.float.distance_20"),bottom:$r("app.float.distance_8")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
            Text(LanguageAndRegionModel.getDisplayLanguage(item))
              .fontSize($r("app.float.font_22"))
              .height($r("app.float.wh_value_26"))
              .margin({right:$r("app.float.distance_16"),bottom:$r("app.float.distance_20")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
          }
          .alignItems(HorizontalAlign.Start);
        }
        .align(Alignment.Start)
        .width(ConfigData.WH_100_100)
        .padding({ left: $r("app.float.distance_16"), right: $r("app.float.distance_16") })
        .borderRadius($r("app.float.radius_24"))
        .backgroundColor(item === this.touchedItem ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.touchedItem = item;
          }
          if (event.type === TouchType.Up) {
            this.touchedItem = '';
          }
        })
        .onClick(() => {
          if(! LanguageAndRegionModel.isInAddedLanguage(item)){
            LanguageAndRegionModel.addLanguage(item);
            AlertDialog.show(
              {
                message: $r("app.string.changeLanguage", LanguageAndRegionModel.getSysDisplayLanguage(item)),
                primaryButton:{
                  value: $r("app.string.keepCurrent"),
                  action:() => {
                    router.back();
                    LogUtil.info(ConfigData.TAG + 'callback when first button clicked');
                  }
                },
                secondaryButton:{
                  value: $r("app.string.change"),
                  action:() => {
                    LanguageAndRegionModel.setSystemLanguage(item);
                    router.back();
                    LogUtil.info(ConfigData.TAG + 'callback when first button clicked');
                  }
                },
                cancel: () => {
                  LogUtil.info(ConfigData.TAG + 'cancel');
                }
              }
            )
          }else{
            prompt.showToast({
              message: $r("app.string.hasAdded"),
              duration: 2000,
            })
          }
        })
      }, item => item);
    }
    .padding($r("app.float.distance_8"))
    .backgroundColor($r("app.color.white_bg_color"))
    .borderRadius($r("app.float.radius_40"))
    .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey"), startMargin:$r("app.float.distance_16"), endMargin:$r("app.float.distance_16")});
  }
}

/**
 * Array Of AllLanguages For Lazy Loading
 */
class AllLanguages extends BasicDataSource {
  private languagesArray: string[] = [];

  constructor(languagesArray:string[]){
    super();
    this.languagesArray = languagesArray;
  }

  public totalCount(): number {
    return this.languagesArray.length;
  }

  public getData(index: number): any {
    return this.languagesArray[index];
  }
}