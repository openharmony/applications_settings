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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
//import {ScreenModeModel} from '../model/displayAndBrightnessImpl/display/ScreenMode.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';


/**
 * brightness setting
 */
@Entry
@Component
struct ScreenMode {
  //@State screenModeModel:ScreenModeModel = new ScreenModeModel();
  private TAG = ConfigData.TAG + 'ScreenMode ';

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.screenResolution'), isActive: true });
      Text($r('app.string.screenResolutionWarning'))
        .fontSize($r('app.float.font_18'))
        .textAlign(TextAlign.Start)
        .margin({top:$r('app.float.distance_24'), bottom:$r('app.float.distance_24')})
        .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24'),})
        .width(ConfigData.WH_100_100)

      List(){
        ForEach([0], (item) => {
          ListItem(){
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }){
              Column(){
                Text($r('app.string.high'))
                  .fontSize($r('app.float.font_22'))
                  .margin({top:$r('app.float.distance_16'), bottom:$r('app.float.distance_4')})
                  .textAlign(TextAlign.Start);

                Text($r('app.string.highText', '3120 x 1440'))
                  .fontSize($r('app.float.font_18'))
                  .margin({bottom:$r('app.float.distance_16')})
                  .textAlign(TextAlign.Start);

              }
              .alignItems(HorizontalAlign.Start)

              Radio( {value: this.TAG} )
                .height($r('app.float.radio_component_height'))
                .margin({ right: $r('app.float.radio_component_margin_bottom_right') })
                .align(Alignment.End)
                .enabled(false)
                .checked(true)
                .onChange(() => {
                  LogUtil.info('settings RadioListComponent : onChange: settingValue = ' + item.settingValue)
                  //this.screenModeModel.setSysScreenMode(0);
                })
            }
          }
          .height($r('app.float.wh_value_80'))
          .width(ConfigData.WH_100_100)

        }, item => JSON.stringify(item));
      }
      .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
      .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey")})
      .borderRadius($r("app.float.radius_24"))
      .backgroundColor($r("app.color.white_bg_color"));

    }
    .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
    .align(Alignment.Start)
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_D8D8D8_grey"));
  }

  @Log
  private aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    //this.screenModeModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  private aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    //this.screenModeModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }
}