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

import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import RestoreFactorySettingsController from '../controller/restoreFactorySettings/restoreFactorySettingsController'
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

/**
 * Developer options
 */
@Entry
@Component
struct restoreFactorySettings {
  private controller: RestoreFactorySettingsController = new RestoreFactorySettingsController();
  @State isTouched: boolean = false;

  build() {
    Column() {
      GridContainer({
        columns: 12,
        sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'
      }) {
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
            HeadComponent({ headName: $r("app.string.resetPhone"), isActive: true });
            Row() {
              Text($r("app.string.resetPhonePromptInfo"))
                .fontSize($r("app.float.font_18"))
                .align(Alignment.Start)
                .fontWeight(500)
                .margin({
                  left: $r('app.float.wh_24'),
                  right: $r("app.float.distance_18"),
                  top: $r("app.float.distance_24"),
                })
            }.width(ConfigData.WH_100_100)

            Blank()
            Button() {
              Text($r("app.string.resetPhone"))
                .fontColor(Color.Red)
                .fontSize($r('sys.float.ohos_id_text_size_button1'))
                .fontWeight(500)
            }
            .width($r('app.float.wh_263'))
            .height($r('app.float.restore_factory_button_height'))
            .align(Alignment.Center)
            .margin({ bottom: $r("app.float.distance_24") })
            .backgroundColor(!this.isTouched ? '#E6E9EB' : $r("sys.color.ohos_id_color_foreground_contrary"))
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isTouched = true;
              }
              if (event.type === TouchType.Up) {
                this.isTouched = false;
              }
            })
            .onClick(() => {
              this.controller.restoreFactorySettings();
            })
          }
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .padding({ left: $r('app.float.wh_24'), right: $r('app.float.wh_24') })
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
}



