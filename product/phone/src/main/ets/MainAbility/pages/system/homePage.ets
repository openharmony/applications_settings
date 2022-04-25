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
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../../../common/component/src/main/ets/default/headComponent';
import {SubEntryComponent} from '../../../../../../../../common/component/src/main/ets/default/subEntryComponent';
import ResourceUtil from '../../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import prompt from '@system.prompt';
import FeatureAbility from '@ohos.ability.featureAbility';

/**
 * Home Page Of System Settings
 */
@Entry
@Component
struct SystemSettings {
  @State touchedItem:boolean = false;
  @State columnMargin: string = '12vp';
  private TAG = `${ConfigData.TAG} SystemSettings`;

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
            HeadComponent({headName: $r('app.string.systemTab'), isActive: true})
            Column({space: this.columnMargin}){
              SoftwareUpdateComponent({title: $r("app.string.softwareUpdates")})

              SubEntryComponent({targetPage: "pages/restoreFactorySettings", title:$r("app.string.restoreFactoryTab")})

              SubEntryComponent({targetPage: 'pages/system/languageSettings/homePage', title: $r("app.string.setlanguage")})

              SubEntryComponent({targetPage: "pages/dateAndTime", title: $r("app.string.dateAndTimeTab")})

              SubEntryComponent({targetPage: "pages/developerOptions", title: $r("app.string.developerOptionsTab")})
            }
            .width(ConfigData.WH_100_100)
          }
          .padding({left: $r('app.float.distance_24'), right: $r('app.float.distance_24')})
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
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
    ResourceUtil.getString($r('app.float.distance_12')).then(value => this.columnMargin = value);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  aboutToDisappear(){
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
  }
}


/**
 * Software updates
 */
@Component
struct SoftwareUpdateComponent {
  @State isTouched:boolean = false;
  private title:string | Resource;
  private TAG = `${ConfigData.TAG} SystemSettings SoftwareUpdates`;

  build(){
    Row(){
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
        Row() {
          Text(this.title)
            .fontSize($r('app.float.font_16'))
            .lineHeight($r('app.float.wh_value_22'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_182431'))
            .margin({left: $r('app.float.distance_8')})
            .textAlign(TextAlign.Start);
        }
        Image('/res/image/ic_settings_arrow.svg')
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .margin({right: $r('app.float.distance_8')});
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
      })
    }
    .padding($r('app.float.distance_4'))
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .onClick(() => {
      FeatureAbility.startAbility({
        want: {
          bundleName: ConfigData.SOFTWARE_UPDATES_BUNDLE_NAME,
          abilityName: ConfigData.SOFTWARE_UPDATES_ABILITY_NAME,
        }
      })
        .then((data) => {
          LogUtil.info(`${this.TAG}, ${ConfigData.SOFTWARE_UPDATES_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
        })
        .catch((error) => {
          ResourceUtil.getString($r("app.string.softwareUpdateFailed")).then(value => {
            prompt.showToast({
              message: value,
              duration: 2000,
            });
            LogUtil.error(`${this.TAG}, ${ConfigData.SOFTWARE_UPDATES_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
          })
        })
    })
  }

}
