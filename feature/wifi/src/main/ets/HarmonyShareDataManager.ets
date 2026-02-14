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

import fs from '@ohos.file.fs';
import wifiManager from '@ohos.wifiManager';
import { buffer } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysHarmonyShareEvent } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ShareEventType } from './model/ShareModel';
import { apConnectManager, WifiConnectListener } from './WifiTracker';
import { WifiBaseConfigManager } from './WifiBaseConfigManager';
import { WifiUtils } from './WifiUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';

/* instrument ignore file */
const TAG: string = 'hmShareDataManager:';
const SECURITY_TYPE_START_TAG: string = 'T:';
const SECURITY_TYPE_END_TAG: string = ';S:';
const SSID_START_TAG: string = 'S:';
const SSID_END_TAG: string = ';P:';
const SHARE_KEY_START_TAG: string = 'P:';
const SHARE_KEY_END_TAG: string = ';;';
const MAX_RETRY_CONNECT_COUNT: number = 3;
const RETRY_CONNECT_DELAY: number = 600;

export class HMShareDataManager implements WifiConnectListener {
  private countToConnect: number = 0;
  private recvShareConfig: wifiManager.WifiDeviceConfig | null = null;
  private wifiBaseConfigManager: WifiBaseConfigManager | null = null;
  private timerId: number | null = null;

  private getShareConfig(shareWifiData: string): wifiManager.WifiDeviceConfig | null {
    let ssidStr: string = this.unEscapeWlanChars(shareWifiData, SSID_START_TAG, SSID_END_TAG);
    let preSharedKeyStr: string = this.unEscapeWlanChars(shareWifiData, SHARE_KEY_START_TAG, SHARE_KEY_END_TAG);
    let securityTypeStr: string =
      this.unEscapeWlanChars(shareWifiData, SECURITY_TYPE_START_TAG, SECURITY_TYPE_END_TAG);

    if (CheckEmptyUtils.checkStrIsEmpty(ssidStr) || CheckEmptyUtils.checkStrIsEmpty(securityTypeStr)) {
      LogUtil.info(`${TAG} shareWifiData parse error`);
      return null;
    }
    let securityType: wifiManager.WifiSecurityType = WifiUtils.str2securityType(securityTypeStr);
    if (CheckEmptyUtils.checkStrIsEmpty(preSharedKeyStr) && !WifiUtils.isOpenAp(securityType)) {
      LogUtil.info(`${TAG} preSharedKey is empty`);
      return null;
    }
    return {
      ssid: ssidStr,
      preSharedKey: preSharedKeyStr,
      securityType: securityType,
    };
  }

  private unEscapeWlanChars(str: string, start: string, end: string): string {
    let startIndex: number = str.indexOf(start) + start.length;
    let endIndex: number = str.indexOf(end);
    if (end === ';;') {
      endIndex = str.length - 2;
    }
    let result: string = '';
    let tempChar: string = '';
    for (let index = startIndex; index < endIndex; index++) {
      tempChar = str[index];
      if (tempChar === '\\' && index + 1 < endIndex) {
        index++;
        result = result.concat(str[index]);
        continue;
      }
      result = result.concat(tempChar);
    }
    return result;
  }

  private async readShareFile(uri: string): Promise<string> {
    let file: fs.File | undefined = undefined;
    let wifiInfo: string = '';
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
      if (file) {
        let arrayBuffer = new ArrayBuffer(4096);
        let readLen: number = fs.readSync(file.fd, arrayBuffer);
        LogUtil.info(`${TAG}  read file data succeed`);
        wifiInfo = buffer.from(arrayBuffer, 0, readLen).toString();
      }
    } catch (err) {
      LogUtil.error(`${TAG}  open or read file fail: ${err?.code} message: ${err?.message},uri:${uri}`);
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (e) {
          LogUtil.error(`${TAG} file close error`);
        }
      }
    }
    return wifiInfo;
  }

  /**
   * 处理接收到的wifi数据
   * @param shareWifi
   */
  public async processShareWifi(uri: string | undefined): Promise<void> {
    let reportParams: Record<string, Object> = {};
    reportParams.EVENT_TYPE = ShareEventType.ACCEPTING;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysHarmonyShareEvent.EVENT_NAME, reportParams);
    if (uri === undefined) {
      LogUtil.error(`${TAG}  processShareWifi uri is empty`);
      return;
    }
    let shareWifi: string = uri as string;
    if (shareWifi.toLowerCase().startsWith('file://')) {
      shareWifi = await this.readShareFile(uri);
      LogUtil.info(`${TAG} Use file connection`);
    }
    if (CheckEmptyUtils.checkStrIsEmpty(shareWifi)) {
      LogUtil.error(`${TAG}  processShareWifi shareWifi is empty`);
      return;
    }
    this.recvShareConfig = this.getShareConfig(shareWifi);
    if (this.recvShareConfig == null) {
      LogUtil.error(`${TAG}  processShareWifi parse cofig err`);
      return;
    }
    let connectedConfig: wifiManager.WifiDeviceConfig | null = await WifiUtils.getConnectConfig();
    if (connectedConfig !== null &&
      (WifiUtils.getApKeyWithConfig(this.recvShareConfig) === WifiUtils.getApKeyWithConfig(connectedConfig))) {
      promptAction.showToast({
        message: this.getStringByNameSync('hotspot_repeated_connection'),
        showMode: promptAction.ToastShowMode.SYSTEM_TOP_MOST
      });
      return;
    }
    if (WifiUtils.isOpenAp(this.recvShareConfig.securityType)) {
      // 未保存的开放网络直接连
      apConnectManager.startConnect(this.recvShareConfig, false, this)
    } else {
      this.wifiBaseConfigManager = new WifiBaseConfigManager(this.recvShareConfig);
      this.wifiBaseConfigManager.connectToWifiDevice(this, true);
    }
    this.countToConnect++;
  }

  private getStringByNameSync(resName: string): string | Resource {
    const context = AbilityContextManager.getInstantShareServiceAbilityContext();
    if (context) {
      return context.resourceManager.getStringByNameSync(resName);
    }
    return $r(`app.string.${resName}`);
  }

  private finishConnect() {
    this.recvShareConfig = null;
    this.wifiBaseConfigManager = null;
    this.countToConnect = 0;
    this.timerId = null;
  }

  private connectFail() {
    if (this.countToConnect >= MAX_RETRY_CONNECT_COUNT) {
      this.finishConnect();
      promptAction.showToast({
        message: this.getStringByNameSync('wifi_connected_failed'),
        showMode: promptAction.ToastShowMode.SYSTEM_TOP_MOST,
      });
      return;
    }

    this.timerId = setTimeout(() => {
      if (this.recvShareConfig !== null && !apConnectManager.isNewConnect(this.recvShareConfig)) {
        LogUtil.info(`${TAG} Delayed reconnection`);
        if (WifiUtils.isOpenAp(this.recvShareConfig.securityType)) {
          apConnectManager.startConnect(this.recvShareConfig, false, this, true);
        } else {
          this.wifiBaseConfigManager?.connectToWifiDevice(this, false, true);
        }
        this.countToConnect++;
      }
      this.timerId = null;
    }, RETRY_CONNECT_DELAY);
  }

  //连接wifi结果回调
  onConnectResult(result: number): void {
    LogUtil.info(`${TAG}  onConnectResult result: ${result}`);
    if (result === 1) {
      this.finishConnect();
      promptAction.showToast({
        message: this.getStringByNameSync('wifi_connected_successful'),
        showMode: promptAction.ToastShowMode.SYSTEM_TOP_MOST,
      });
    } else {
      this.connectFail();
    }
  }
}

export let hmShareDataManager = new HMShareDataManager();