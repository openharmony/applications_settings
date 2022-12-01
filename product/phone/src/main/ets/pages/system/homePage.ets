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

import prompt from '@system.prompt';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import { SubEntryComponent } from '../../../../../../../common/component/src/main/ets/default/subEntryComponent';

/**
 * Home Page Of System Settings
 */
@Entry
@Component
struct SystemSettings {
  @State touchedItem: boolean = false;
  private TAG = `${ConfigData.TAG} SystemSettings `;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.systemTab'), isActive: true });

          Column() {
            SoftwareUpdateComponent({ title: $r("app.string.softwareUpdates") })
              .margin({ bottom: $r('sys.float.ohos_id_card_margin_start') })

            SubEntryComponent({ targetPage: "pages/restoreFactorySettings", title:$r("app.string.restoreFactoryTab") })
              .margin({ bottom: $r('sys.float.ohos_id_card_margin_start') })

            SubEntryComponent({ targetPage: 'pages/system/languageSettings/homePage', title: $r("app.string.setlanguage") })
              .margin({ bottom: $r('sys.float.ohos_id_card_margin_start') })

            SubEntryComponent({ targetPage: "pages/dateAndTime", title: $r("app.string.dateAndTimeTab") })
              .margin({ bottom: $r('sys.float.ohos_id_card_margin_start') })

            SubEntryComponent({ targetPage: "pages/developerOptions", title: $r("app.string.developerOptionsTab") })
          }
          .margin({ top:$r("app.float.distance_8") })
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
 * Software updates
 */
@Component
struct SoftwareUpdateComponent {
  @State isTouched: boolean = false;
  private title: string | Resource;
  private TAG = `${ConfigData.TAG} SystemSettings SoftwareUpdates `;

  build(){
    Row(){
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.title)
          .fontSize($r('app.float.font_16'))
          .lineHeight($r('app.float.wh_value_22'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_182431'))
          .margin({ left: $r('app.float.distance_8') })
          .textAlign(TextAlign.Start);

        Image('/res/image/ic_settings_arrow.svg')
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .margin({ right: $r('app.float.distance_8') })
          .fillColor($r("sys.color.ohos_id_color_primary"))
          .opacity($r("app.float.opacity_0_2"))
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
      globalThis.settingsAbilityContext.startAbility({
        bundleName: ConfigData.SOFTWARE_UPDATES_BUNDLE_NAME,
        abilityName: ConfigData.SOFTWARE_UPDATES_ABILITY_NAME,
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
