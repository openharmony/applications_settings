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

/* instrument ignore file */
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { QrCodeModel } from '../model/QrCodeModel';

const TAG: string = 'WlanQrCodeComponent : ';

export const WLAN_OR_CODE_REFRESH: string = 'WLAN_OR_CODE_REFRESH';

@Component
export struct WlanQrCodeComponent {
  param?: object;
  tag: string = 'WlanQrCodeComponent : ';
  @State qrCodeString: string = '';

  private qrCodeRefreshCallBack = (qrCodeString: string) => {
    this.qrCodeString = qrCodeString;
  }

  build() {
    Column() {
      Column() {
        QRCode(this.qrCodeString ?? '')
          .width(208)
          .height(208)
          .color($r('sys.color.comp_foreground_primary'))
          .backgroundColor($r('sys.color.background_primary'))
          .accessibilityDescription(' ')
          .focusable(false)
      }
      .width(240)
      .height(240)
      .backgroundColor($r('sys.color.background_primary'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius($r('sys.float.corner_radius_level6'))

      Text($r('app.string.Scan_to_connect_to_this_WLAN_network_Pay_attention_to_privacy_and_security'))
        .fontSize($r('sys.float.Body_M'))
        .constraintSize({ minHeight: $r('app.float.wh_value_19') })
        .width('100%')
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          top: $r('sys.float.padding_level6')
        })
        .textAlign(TextAlign.Center)
    }
    .accessibilityGroup(true)
    .padding({
      top: $r('sys.float.padding_level8')
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (this.param) {
      this.qrCodeString = (this.param as QrCodeModel).qrCodeString;
    }
    EventBus.getInstance().on(WLAN_OR_CODE_REFRESH, this.qrCodeRefreshCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(WLAN_OR_CODE_REFRESH, this.qrCodeRefreshCallBack);
  }
}