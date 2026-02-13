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

import wifiManager from '@ohos.wifiManager';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EVENT_ID_CHANGE_HOT_SPOT_QRCODE } from '@ohos/settings.common/src/main/ets/event/types';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
/* instrument ignore file */
enum WifiSecurityType {
  NO_PASS = 'nopass',
  WEP = 'WEP',
  WPA = 'WPA',
  OWE = 'OWE',
  SAE = 'SAE',
}

@Component
export struct QrcodeComponent {
  public tag: string = 'QrcodeComponent : ';
  @State qrCodeString: string = '';

  build() {
    Column() {
      QRCode(this.qrCodeString)
        .width(132)
        .height(132)
        .color($r('sys.color.comp_foreground_primary'))
        .backgroundColor($r('sys.color.background_primary'))

      Text($r('app.string.scan_for_hotspots'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          top: $r('sys.float.padding_level6'),
        })
    }
    .accessibilityGroup(true)
    .width('100%')
    .padding({
      top: $r('sys.float.padding_level10'),
      bottom: $r('sys.float.padding_level10'),
    })
    .alignItems(HorizontalAlign.Center)
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.refreshQrCodeInfo();
    this.registerEvent();
  }

  private registerEvent(): void {
    emitter.on({
      eventId: EVENT_ID_CHANGE_HOT_SPOT_QRCODE,
    }, (event) => {
      LogUtil.info(`${this.tag} receive refresh qrcode event.`);
      this.refreshQrCodeInfo();
    });
  }

  private unRegisterEvent(): void {
    emitter.off(EVENT_ID_CHANGE_HOT_SPOT_QRCODE);
  }

  refreshQrCodeInfo(): void {
    try {
      let config: wifiManager.HotspotConfig = wifiManager.getHotspotConfig();
      let securityType: string = '';
      switch (config.securityType) {
        case wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN:
          securityType = WifiSecurityType.NO_PASS;
          break;
        case wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WEP:
          securityType = WifiSecurityType.WEP;
          break;
        case wifiManager.WifiSecurityType.WIFI_SEC_TYPE_PSK:
          securityType = WifiSecurityType.WPA;
          break;
        case wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OWE:
          securityType = WifiSecurityType.OWE;
          break;
        case wifiManager.WifiSecurityType.WIFI_SEC_TYPE_SAE:
          securityType = WifiSecurityType.SAE;
          break;
        default:
          securityType = WifiSecurityType.NO_PASS;
          break;
      }
      this.qrCodeString = `WIFI:T:${securityType};S:${StringUtil.escapeSpecialCharacters(config.ssid)};P:${StringUtil.escapeSpecialCharacters(config.preSharedKey)};;`;
    } catch (err) {
      LogUtil.error(`${this.tag} getHotspotConfig error: ${(err as BusinessError).message}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.qrCodeString = '';
    this.unRegisterEvent();
  }
}