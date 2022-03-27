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
import LogUtil from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import HeadComponent from '../../../../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import BasicDataSource from '../../../../../../../../../../common/utils/src/main/ets/default/model/BasicDataSource';
import LanguageAndRegionModel from '../../../../../default/model/systemImpl/languageSettings/LanguageAndRegionModel'
import ResourceUtil from '../../../../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import {SubHeader} from '../../../../../../../../../../common/component/src/main/ets/default/textComponent.ets';

/**
 * Home Page Of AddLanguage
 */
@Entry
@Component
struct AddLanguage {
  private TAG = `${ConfigData.TAG} AddLanguage`;
  private listSpace = '10vp'

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
            HeadComponent({ headName: $r('app.string.addLanguage'), isActive: true })
            List({space: this.listSpace}){
              ListItem() {
                SubHeader({ titleContent: $r('app.string.addedLanguage') })
              }

              ListItem() {
                AddedLanguagesList();
              }

              ListItem() {
                SubHeader({ titleContent: $r('app.string.allLanguage') })
              }

              ListItem() {
                AllLanguagesList();
              }
            }
            .edgeEffect(EdgeEffect.Spring);
          }
          .padding({left: $r("app.float.distance_24"), right: $r("app.float.distance_24")})
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
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
    ResourceUtil.getString($r('app.float.distance_10')).then(value => this.listSpace = value);
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
    List(){
      ForEach(this.addedLanguages, (item) => {
        ListItem(){
          Column(){
            Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
              .fontSize($r("app.float.font_16"))
              .height($r("app.float.wh_value_22"))
              .fontWeight(FontWeight.Medium)
              .margin({top: $r("app.float.distance_10"), bottom: $r("app.float.distance_2")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
            Text(LanguageAndRegionModel.getDisplayLanguage(item))
              .fontSize($r("app.float.font_14"))
              .height($r("app.float.wh_value_19"))
              .fontWeight(FontWeight.Regular)
              .margin({bottom: $r("app.float.distance_11")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
          }
          .alignItems(HorizontalAlign.Start);
        }
        .align(Alignment.Start)
        .width(ConfigData.WH_100_100)
        .padding({left: $r("app.float.distance_8"), right: $r("app.float.distance_8")})
        .borderRadius($r("app.float.radius_20"))
        .linearGradient(item === this.touchedItem ? {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
           } : {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
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
 * List Of All Language
 */
@Component
struct AllLanguagesList {
  private allLanguages: AllLanguages = new AllLanguages(LanguageAndRegionModel.getAllLanguages());
  @State touchedItem:string = '';

  build(){
    List(){
      LazyForEach(this.allLanguages, (item) => {
        ListItem(){
          Column(){
            Text(LanguageAndRegionModel.getSysDisplayLanguage(item))
              .fontSize($r("app.float.font_16"))
              .height($r("app.float.wh_value_22"))
              .fontWeight(FontWeight.Medium)
              .margin({top: $r("app.float.distance_10"), bottom: $r("app.float.distance_2")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
            Text(LanguageAndRegionModel.getDisplayLanguage(item))
              .fontSize($r("app.float.font_14"))
              .height($r("app.float.wh_value_19"))
              .fontWeight(FontWeight.Regular)
              .margin({bottom: $r("app.float.distance_11")})
              .fontColor($r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
          }
          .alignItems(HorizontalAlign.Start);
        }
        .align(Alignment.Start)
        .width(ConfigData.WH_100_100)
        .padding({left: $r("app.float.distance_8"), right: $r("app.float.distance_8")})
        .borderRadius($r("app.float.radius_20"))
        .linearGradient(item === this.touchedItem ? {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
           } : {
           angle: 90,
           direction: GradientDirection.Right,
           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
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
    .padding($r("app.float.distance_4"))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .borderRadius($r("app.float.radius_24"))
    .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey"), startMargin: $r("app.float.distance_8"), endMargin: $r("app.float.distance_8")});
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

  public getData(index: number): string {
    return this.languagesArray[index];
  }
}