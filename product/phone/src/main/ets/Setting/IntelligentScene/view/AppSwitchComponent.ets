/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';

/* instrument ignore file */
@Component
export struct AppSwitchComponent {
  private tag: string = 'AppSwitchComponent: ';
  @Link isOn: boolean;
  private appSwitchDataInitCallBack = (isOn: boolean) => {
    this.isOn = isOn;
  }

  build() {
    Stack() {
      Row() {
        Text($r('app.string.timer_open'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .lineHeight(21)
          .fontFamily('HarmonyHeiTi')
          .layoutWeight(1)
          .fontWeight(FontWeight.Medium)

        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .id('IntelligenceAppSwitch')
          .enabled(true)
          .hoverEffect(HoverEffect.None)
          .onChange((isOn: boolean) => {
            this.isOn = isOn;
          })
          .width(36)
      }
      .width('100%')
      .padding({
        start: PADDING_12,
        end: PADDING_12,
        top: FontScaleUtils.getSafetyPadding(),
        bottom: FontScaleUtils.getSafetyPadding(),
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('sys.float.corner_radius_level10'))
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .constraintSize({
        minHeight: 56,
      })
    }
    .width('100%')
    .padding({
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16'),
    })
    .margin({
      top: $r('app.float.padding_12')
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    EventBus.getInstance().on('appSwitchDataLoaded', this.appSwitchDataInitCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach('appSwitchDataLoaded', this.appSwitchDataInitCallBack);
  }
}