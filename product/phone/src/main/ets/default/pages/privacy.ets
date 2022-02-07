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
import prompt from '@system.prompt';
import FeatureAbility from '@ohos.ability.featureAbility';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';

/**
 * Home Page Of Privacy Settings
 */
@Entry
@Component
struct PrivacySettings {
  private TAG = `${ConfigData.TAG} PrivacySettings`;

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.privacy'), isActive: true })
      Row(){
        ChildComponent({textStr: $r('app.string.permissionManager')})
      }
      .onClick(()=>{
        FeatureAbility.startAbility({
          want: {
            bundleName: ConfigData.PERMISSION_MANAGER_BUNDLE_NAME,
            abilityName: ConfigData.PERMISSION_MANAGER_ABILITY_NAME,
          }
        })
          .then((data) => {
            LogUtil.info(`${this.TAG}, ${ConfigData.PERMISSION_MANAGER_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
          })
          .catch((error) => {
            prompt.showToast({
              message: $r("app.string.permissionFailed"),
              duration: 2000,
            });
            LogUtil.error(`${this.TAG}, ${ConfigData.PERMISSION_MANAGER_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
          })
      });

      Navigator({ target: 'pages/locationServices' }) {
        ChildComponent({ textStr: $r('app.string.locationServicesTab') });
      }
    }
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
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


@Component
struct ChildComponent{
  private textStr;
  @State isTouched:boolean = false;

  build(){
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center }) {
      Row() {
        Text(this.textStr)
          .fontSize($r('app.float.font_22'))
          .fontColor($r('app.color.font_color_182431'))
          .margin({left:$r('app.float.distance_24'), top:$r('app.float.distance_8'), bottom:$r('app.float.distance_8'), right:0})
          .textAlign(TextAlign.Start);
      }
      Image('/res/image/ic_settings_arrow.svg')
        .width($r('app.float.wh_value_40'))
        .height($r('app.float.wh_value_40'));
    }
    .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
    .height($r('app.float.wh_value_56'))
    .margin({left:$r('app.float.distance_24'), right:$r('app.float.distance_24'), top:$r('app.float.distance_16')})
    .borderRadius($r('app.float.radius_24'))
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    });
  }
}

