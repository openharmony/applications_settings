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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import lazy { harmonyShareAdapter } from '../../HarmonyShareAdapter';
import { SharableTargetListener } from '../../HarmonyShareAdapter';
import { AccessPoint, CONNECTED_DATA_CHANGE_EVENT, WifiSecurityType } from '../../model/WifiModel';
import { hmShareDataManager } from '../../HarmonyShareDataManager';
import { ShareDataType, ShareTipsCode } from '../../model/ShareModel';
import { WifiUtils } from '../../WifiUtils';

/* instrument ignore file */
const TAG: string = 'ShareWlanController:';

/**
 * wifi分享控制器
 *
 * @since 2024-09-06
 */
export class ShareWlanController implements SharableTargetListener {
  private accessPoint: AccessPoint | undefined;
  private isRegister: boolean = false;
  private isShow: boolean = false;
  private shareDataFileUri: string = '';
  private isDynamic: boolean = true;
  private shareWifiDataChange = (accessPoint: AccessPoint | undefined) => {
    LogUtil.info(`${TAG} shareWifiDataChange`);
    this.accessPoint = accessPoint;
    if (accessPoint !== undefined) {
      this.registerHMShareListener();
    } else {
      this.unRegisterHMShareListener();
    }
  }

  private registerHMShareListener(): void {
    LogUtil.info(`${TAG} registerHMShareListener isRegister:${this.isRegister}`);
    if (!this.isRegister && this.isShow) {
      harmonyShareAdapter.setListener(this);
      this.isRegister = true;
    }
  }

  private unRegisterHMShareListener(): void {
    LogUtil.info(`${TAG} unRegisterHMShareListener isRegister:${this.isRegister}`);
    if (this.isRegister) {
      harmonyShareAdapter.releaseListener(this);
      this.isRegister = false;
    }
  }

  public setAccessPoint(accessPoint: AccessPoint | undefined): void {
    this.isDynamic = false;
    this.accessPoint = accessPoint;
  }

  init(): void {
    LogUtil.info(`${TAG} init`);
    this.shareDataFileUri = AppStorage.get('shareDataFileUri') as string;
    if (!CheckEmptyUtils.checkStrIsEmpty(this.shareDataFileUri)) {
      hmShareDataManager.processShareWifi(this.shareDataFileUri);
      AppStorage.setOrCreate('shareDataFileUri', '');
    }
    if (this.isDynamic) {
      EventBus.getInstance().on(CONNECTED_DATA_CHANGE_EVENT, this.shareWifiDataChange);
    }
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(CONNECTED_DATA_CHANGE_EVENT, this.shareWifiDataChange);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.isShow = true;
    if (this.accessPoint !== undefined) {
      this.registerHMShareListener();
    }
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.isShow = false;
    this.unRegisterHMShareListener();
  }

  getShareTag(): ShareDataType {
    return ShareDataType.WIFI;
  }

  getSharePreviewImage(): Resource {
    LogUtil.info(`${TAG} getSharePreviewImage`);
    return $r('app.media.share_wifi');
  }

  async getShareConfig(): Promise<wifiManager.WifiDeviceConfig | wifiManager.HotspotConfig | undefined> {
    LogUtil.info(`${TAG} getShareConfig`);
    if (this.accessPoint === undefined) {
      return undefined;
    }
    let config: wifiManager.WifiDeviceConfig | undefined = this.accessPoint.getBestConfig();
    if (config === undefined) {
      return undefined;
    }
    if (!WifiUtils.isSupportQrcodeShare(config.securityType)) {
      harmonyShareAdapter.finishShare(ShareTipsCode.SEND_API_NOTIFY_INFO_DATA_INVALID_TO_SHARE);
      return undefined;
    }
    return config;
  }
}