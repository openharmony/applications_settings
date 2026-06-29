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
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
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
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State qrCodeString: string = '';

  build() {
    Column() {
      QRCode(this.qrCodeString)
        .width('132vp')
        .height('132vp')
        .color($r('sys.color.comp_foreground_primary'))
        .backgroundColor($r('sys.color.background_primary'))

      Text($r('app.string.scan_for_hotspots'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_hint'))
        .opacity(0.6)
        .margin({
          top: '12vp',
        })
    }
    .width('100%')
    .padding({
      top: '20vp',
      bottom: '20vp',
    })
    .alignItems(HorizontalAlign.Center)
  }

  aboutToAppear(): void {
    if (!this.menu) {
      LogUtil.error(`${this.tag} aboutToAppear: menu is empty.`);
      return;
    }
    this.style = this.menu.style;
    this.controller = this.menu.getControllerInstance(this.uiRefresher);
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
      LogUtil.error(`${this.tag} getHotspotConfig error: ${err?.message}`);
    }
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
    this.unRegisterEvent();
  }
}