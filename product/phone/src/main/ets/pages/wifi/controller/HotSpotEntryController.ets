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

import smartHotspot from '@hms.net.smartHotspot';
import wifiManager from '@ohos.wifiManager';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HotSpotMenu } from '@ohos/settings.wifi';
import { BusinessError } from '@ohos.base';

const TAG: string = 'HotSpotEntryController';
const ERROR_CODE_TYPE1: string = '2200002';
const ERROR_CODE_TYPE2: string = '2200003';
const ERROR_CODE_TYPE3: string = '1004500002';
const ERROR_CODE_TYPE4: string = '1004500003';
const SMART_HOTSPOT_KEY: string = 'smartHotSpot';
const SMART_HOTSPOT_KEY_CLICK: string = 'smartHotSpotClick';

export class HotSpotEntryController extends MenuController {
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;

  static createHotSpotEntryController(menu: SettingsBaseMenu): Controller {
    return new HotSpotEntryController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear: ${this.menu.title}`);
  }

  onMenuClick(): boolean {
    if (!(this.menu instanceof HotSpotMenu)) {
      LogUtil.error(`${TAG} menu error`);
      return false;
    }
    this.connectHotSpotDevice();
    return true;
  }

  /**
   * 连接smartHotspot
   * @returns
   */
  async connectHotSpotDevice(): Promise<void> {
    LogUtil.info(`${TAG} start to connectHotSpot: ${this.menu.title}`);
    AppStorage.SetOrCreate<boolean>(SMART_HOTSPOT_KEY_CLICK, true);
    if (wifiManager.isConnected()) {
      LogUtil.info(`${TAG} wifi isConnected`);
      this.lastLinkedInfo = await wifiManager.getLinkedInfo();
      LogUtil.info(`${TAG} connState: ${this.lastLinkedInfo?.connState}`);
      wifiManager.disconnect();
      AppStorage.SetOrCreate<string>(SMART_HOTSPOT_KEY, '');
      SettingsDataUtils.setSettingsData(SMART_HOTSPOT_KEY, '');
    }
    if (!(this.menu instanceof HotSpotMenu)) {
      LogUtil.error(`${TAG} menu type error`);
      return;
    }
    LogUtil.info(`${TAG} onMenuClick menu networkId: ${this.menu?.networkId}`);
    let smartHotSpotDeviceName = this.menu.deviceName;
    LogUtil.info(`${TAG} onMenuClick menu smartHotSpotDeviceName: ${smartHotSpotDeviceName}`);
    smartHotspot.autoConnectHotspot({
      'networkId': this.menu?.networkId
    }, (err: BusinessError) => {
      if (!err) {
        this.saveSmartHotSpotInfo(smartHotSpotDeviceName);
        LogUtil.info(`${TAG} smartHotspot autoConnect end`);
      } else {
        LogUtil.error(`${TAG} smartHotspot autoConnect error: ${err?.message}`);
        this.showAlertDialog(`${err.code}`);
      }
    })
  }

  /**
   * 本地保存智能热点信息
   * @param smartHotSpotDeviceName 智能热点信息
   */
  saveSmartHotSpotInfo(smartHotSpotDeviceName: string): void {
    AppStorage.SetOrCreate<string>(SMART_HOTSPOT_KEY, smartHotSpotDeviceName);
    SettingsDataUtils.setSettingsData(SMART_HOTSPOT_KEY, smartHotSpotDeviceName);
  }

  /**
   * 发送告警弹窗
   * @param messageInfo 弹窗消息内容
   */
  showAlertDialog(errorCode: string): void {
    LogUtil.info(`${TAG} showAlertDialog errorCode : ${errorCode}`);
    let messageInfo: ResourceStr = $r('app.string.bt_connect_failed_title');
    if (errorCode === ERROR_CODE_TYPE1 || errorCode === ERROR_CODE_TYPE4) {
      messageInfo = $r('app.string.smart_hotspot_connect_operation_failed');
    } else if (errorCode === ERROR_CODE_TYPE2) {
      messageInfo = $r('app.string.smart_hotspot_connect_system_failed');
    } else if (errorCode === ERROR_CODE_TYPE3) {
      messageInfo = $r('app.string.smart_hotspot_connect_setup_failed');
    }
    AlertDialog.show(
      {
        message: messageInfo,
        primaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.button_title_ok')),
          fontColor: $r('sys.color.ohos_id_color_emphasize'),
          action: () => {
            LogUtil.info(`${TAG} cancel`);
          }
        },
      });
  }
}