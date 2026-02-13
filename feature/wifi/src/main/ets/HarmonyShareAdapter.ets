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

import resourceManager from '@ohos.resourceManager';
import wifiManager from '@ohos.wifiManager';
import common from '@ohos.app.ability.common';
// import { harmonyShare, systemShare } from '@kit.ShareKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysHarmonyShareEvent } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ShareDataType, ShareEventType, ShareTipsCode } from './model/ShareModel';
import { WifiUtils } from './WifiUtils';

/* instrument ignore file */
const TAG: string = 'harmonyShareAdapter:';

/**
 * 碰一碰监听回调
 *
 * @since 2024-08-12
 */
export interface SharableTargetListener {
  getShareTag(): ShareDataType;

  getSharePreviewImage(): Resource;

  getShareConfig(): Promise<wifiManager.WifiDeviceConfig | wifiManager.HotspotConfig | undefined>;
}

/**
 * harmony分享后台管理类
 *
 * @since 2024-08-21
 */
export class HarmonyShareAdapter {
  private sharableTargetListener: SharableTargetListener | undefined;
  // private sharableTarget: harmonyShare.SharableTarget | undefined;
  private isRegister: boolean = false;

  constructor() {
  }

  private getTitle(shareTag: ShareDataType): string {
    switch (shareTag) {
      case ShareDataType.WIFI:
        return ResourceUtil.getStringSync($r('app.string.wifi_settings_title'));
      case ShareDataType.HOTSPOT:
        return ResourceUtil.getStringSync($r('app.string.hotspot_settings_title'));
      default:
        return '';
    }
  }

  private async shareWifiOrHotspot(): Promise<void> {
    if (this.sharableTargetListener === undefined) {
      LogUtil.warn(`${TAG} shareWifiOrHotspot sharableTargetListener undefined`);
      return;
    }
    let config: wifiManager.WifiDeviceConfig | wifiManager.HotspotConfig | undefined =
      await this.sharableTargetListener.getShareConfig();
    if (config === undefined) {
      LogUtil.warn(`${TAG} shareWifiOrHotspot config undefined`);
      return;
    }
    // if (this.sharableTarget === undefined) {
    //   LogUtil.error(`${TAG} shareWifiOrHotspot sharableTarget undefined`);
    //   return;
    // }
    let securityType: string = WifiUtils.securityType2str(config.securityType);
    let ssid: string = config.ssid;
    let passWord: string = StringUtil.escapeSpecialCharacters(config.preSharedKey);
    let info: string =
      `WIFI:T:${securityType};S:${StringUtil.escapeSpecialCharacters(ssid)};P:${passWord};;`;
    let img: Uint8Array = new Uint8Array();
    try {
      let resourceManager: resourceManager.ResourceManager =
        (AppStorage.get<common.UIAbilityContext>('pageContext') as common.UIAbilityContext).resourceManager;
      img = await resourceManager.getMediaContent(this.sharableTargetListener.getSharePreviewImage());
    } catch (err) {
      LogUtil.error(`${TAG} getMediaContent SharePreviewImage failed`);
    }
    let shareTag: ShareDataType = this.sharableTargetListener.getShareTag();
    let utdFlag: string = 'com.ohos.settings.wifi';
    if (shareTag === ShareDataType.HOTSPOT) {
      utdFlag = 'com.ohos.settings.hotspot';
    }
    // let data: systemShare.SharedData = new systemShare.SharedData({
    //   utd: utdFlag,
    //   thumbnail: img,
    //   content: info,
    //   title: this.getTitle(shareTag),
    //   description: ssid
    // });
    // this.sharableTarget.share(data);
    let reportParams: Record<string, Object> = {};
    reportParams.EVENT_TYPE = ShareEventType.SHARING;
    reportParams.SERVICE_TYPE = shareTag;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysHarmonyShareEvent.EVENT_NAME, reportParams);
  }

  // private shareDataCallback = (sharableTarget: harmonyShare.SharableTarget): void => {
  //   LogUtil.info(`${TAG} shareDataCallback`);
  //   // this.sharableTarget = sharableTarget;
  //   this.shareWifiOrHotspot();
  // };
  // private offShareDataCallback = (sharableTarget: harmonyShare.SharableTarget): void => {
  //   LogUtil.info(`${TAG} offShareDataCallback`);
  //   // this.sharableTarget = undefined;
  // };

  /**
   * 监听碰一碰事件
   * @param listener SharableTargetListener
   */
  public setListener(listener: SharableTargetListener): void {
    LogUtil.info(`${TAG} setListener isRegister ${this.isRegister}`);
    this.sharableTargetListener = listener;
    if (!this.isRegister) {
      try {
        // harmonyShare.on('knockShare', this.shareDataCallback);
        this.isRegister = true;
      } catch (error) {
        LogUtil.error(`${TAG} harmonyShare setListener error: ${error?.message}`);
      }
    }
  }

  /**
   * 取消监听碰一碰事件
   *
   * @param listener SharableTargetListener
   */
  public releaseListener(listener: SharableTargetListener): boolean {
    LogUtil.info(`${TAG} harmonyShare releaseListener isRegister ${this.isRegister}`);
    if (!this.isRegister) {
      return false;
    }
    try {
      // harmonyShare.off('knockShare', this.offShareDataCallback);
      this.isRegister = false;
    } catch (error) {
      LogUtil.error(`${TAG} harmonyShare releaseListener error: ${error?.message}`);
    }
    this.sharableTargetListener = undefined;
    return true;
  }

  /**
   * 结束分享
   *
   * @param tipsCode
   */
  public finishShare(code: ShareTipsCode) {
    LogUtil.info(`${TAG} finishShare`);
    try {
      // (this.sharableTarget as ESObject).notifyInfo(code);
    } catch (error) {
      LogUtil.error(`${TAG} finishShare error: ${error?.message}`);
    }
    // this.sharableTarget = undefined;
  }
}

export let harmonyShareAdapter = new HarmonyShareAdapter();