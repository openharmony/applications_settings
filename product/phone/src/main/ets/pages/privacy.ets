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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import { SubEntryComponent } from '../../../../../../common/component/src/main/ets/default/subEntryComponent';
import { OuterLayoutComponentNoParam } from '../../../../../../common/component/src/main/ets/default/outerLayoutComponent';

/**
 * Home Page Of Privacy Settings
 */
@Entry
@Component
struct PrivacySettings {
  private TAG = `${ConfigData.TAG} PrivacySettings `;

  @Builder mPrivacySettings() {
    Column() {
      HeadComponent({ headName: $r('app.string.privacy'), isActive: true });

      Column() {
        PermissionComponent()
          .margin({ bottom: $r('sys.float.ohos_id_card_margin_start') })

        SubEntryComponent({ targetPage: 'pages/locationServices', title: $r('app.string.locationServicesTab') });
      }
      .margin({ top: $r("app.float.distance_8") })
    }
  }

  build() {
    Column(){
      OuterLayoutComponentNoParam({
        mContentComponentNoParam: this.mPrivacySettings
      })
    }
  }

  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}

/**
 * Permission Manager Component
 */
@Component
export struct PermissionComponent {
  private TAG = `${ConfigData.TAG} PrivacySettings PermissionComponent `;
  @State isTouched: boolean = false;

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text($r('app.string.permissionManager'))
            .fontSize($r('app.float.font_16'))
            .lineHeight($r('app.float.wh_value_22'))
            .fontColor($r('app.color.font_color_182431'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: $r('app.float.distance_8') })
            .textAlign(TextAlign.Start);
        }

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
                                             colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                           })
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
    .backgroundColor('#FFFFFF')
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_24'))
    .onClick(() => {
      globalThis.settingsAbilityContext.startAbility({
        bundleName: ConfigData.PERMISSION_MANAGER_BUNDLE_NAME,
        abilityName: ConfigData.PERMISSION_MANAGER_ABILITY_NAME,
      })
        .then((data) => {
          LogUtil.info(`${this.TAG}, ${ConfigData.PERMISSION_MANAGER_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
        })
        .catch((error) => {
          ResourceUtil.getString($r("app.string.permissionFailed")).then(value => {
            prompt.showToast({
              message: value,
              duration: 2000,
            });
            LogUtil.error(`${this.TAG}, ${ConfigData.PERMISSION_MANAGER_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
          })
        })
    });
  }
}