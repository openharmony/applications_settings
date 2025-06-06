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

import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import RestoreFactorySettingsController from '../controller/restoreFactorySettings/RestoreFactorySettingsController';

/**
 * Developer options
 */
@Entry
@Component
struct restoreFactorySettings {
  @State isTouched: boolean = false;
  private controller: RestoreFactorySettingsController = new RestoreFactorySettingsController();

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r("app.string.resetPhone"), isActive: true });

          Text($r("app.string.resetPhonePromptInfo"))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r("app.float.font_18"))
            .align(Alignment.Start)
            .margin({
              left: $r('app.float.distance_12'),
              right: $r("app.float.distance_18"),
              top: $r("app.float.distance_24"),
            })
            .width(ConfigData.WH_100_100)

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
          .margin({ top: $r("app.float.distance_16"), bottom: $r("app.float.distance_24") })
          .backgroundColor(!this.isTouched ? '#E6E9EB' : $r("sys.color.ohos_id_color_foreground_contrary"))
          .onClick(() => {
            this.controller.restoreFactorySettings();
          })
          .onTouch((event?: TouchEvent | undefined) => {
            if (event?.type === TouchType.Down) {
              this.isTouched = true;
            }

            if (event?.type === TouchType.Up) {
              this.isTouched = false;
            }
          })
        }
        .height(ConfigData.WH_100_100)
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
}
