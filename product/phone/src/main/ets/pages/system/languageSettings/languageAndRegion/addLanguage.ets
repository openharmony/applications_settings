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
import prompt from '@system.prompt';
import deviceInfo from '@ohos.deviceInfo';
import LogUtil from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { SubHeader } from '../../../../../../../../../common/component/src/main/ets/default/textComponent';
import ConfigData from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LanguageAndRegionModel from '../../../../model/systemImpl/languageSettings/LanguageAndRegionModel';
import HeadComponent from '../../../../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import BasicDataSource from '../../../../../../../../../common/utils/src/main/ets/default/model/BasicDataSource';

const deviceTypeInfo = deviceInfo.deviceType;

/**
 * Home Page Of AddLanguage
 */
@Entry
@Component
struct AddLanguage {
  private TAG = `${ConfigData.TAG} AddLanguage`;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.addLanguage'), isActive: true });

          List(){
            ListItem() {
              SubHeader({ titleContent: $r('app.string.addedLanguage') })
            }

            ListItem() {
              AddedLanguagesList();
            }

            ListItem() {
              SubHeader({ titleContent: $r('app.string.allLanguage') });
            }

            ListItem() {
              AllLanguagesList();
            }
          }
          .flexShrink(1)
          .edgeEffect(EdgeEffect.Spring);
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
              .fontColor($r('sys.color.ohos_id_color_primary'))
              .opacity($r('sys.float.ohos_fa_alpha_content_secondary'))
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
    .divider({
      strokeWidth: $r('app.float.divider_wh'),
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r("app.float.distance_8"), 
      endMargin: $r("app.float.distance_8")
    })
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
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
              .fontColor($r('sys.color.ohos_id_color_primary'))
              .opacity($r('sys.float.ohos_fa_alpha_content_secondary'))
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
                alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
                offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
                cancel: () => {
                  LogUtil.info(ConfigData.TAG + 'cancel');
                }
              }
            )
          } else {
            ResourceUtil.getString($r("app.string.hasAdded")).then(value => {
              prompt.showToast({
                message: value,
                duration: 2000,
              })
            })
          }
        })
      }, item => item);
    }
    .padding($r("app.float.distance_4"))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .borderRadius($r("app.float.radius_24"))
    .divider({
      strokeWidth: $r('app.float.divider_wh'),
      color: $r('sys.color.ohos_id_color_list_separator'),
      startMargin: $r("app.float.distance_8"),
      endMargin: $r("app.float.distance_8")
    });
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