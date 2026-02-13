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

import { vpn } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import type common from '@ohos.app.ability.common';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import VpnConfig from './VpnConfig';
import VpnConstant from './VpnConstant';

/* instrument ignore file */
const MODULE_TAG: string = 'VpnConnectModel:';
AppStorage.setOrCreate(VpnConstant.STORAGE_KEY_CONNECT_STATE, VpnConstant.VPN_STATE_NONE);

/**
 * VPN connect model
 *
 * @since 2024-06-15
 */
export class VpnConnectModel {
  private static instance: VpnConnectModel;
  private connection: vpn.VpnConnection | undefined = undefined;
  private timeoutId: number = undefined;
  private connectedVpnId: string = undefined;
  private connectState: number = VpnConstant.VPN_STATE_NONE;
  private replaceConnectVpnConfig: VpnConfig = undefined;

  public static getInstance(): VpnConnectModel {
    if (!this.instance) {
      this.instance = new VpnConnectModel();
    }
    return this.instance;
  }

  setReplaceConnectVpn(vpnConfig: VpnConfig): void {
    if (!vpnConfig) {
      LogUtil.error(`${MODULE_TAG} setReplaceConnectVpn faild, invalid param.`);
      return;
    }
    this.replaceConnectVpnConfig = vpnConfig;
  }

  setConnectState(state: number, id?: string): void {
    if (id) {
      this.connectedVpnId = id;
    }
    LogUtil.info(`${MODULE_TAG} setConnectState: ${this.connectState} -> ${state}, id:${this.connectedVpnId}`);
    this.connectState = state;
    AppStorage.setOrCreate(VpnConstant.STORAGE_KEY_CONNECT_STATE, state);
  }

  getConnectedVpnId(): string {
    return this.connectedVpnId;
  }

  isConnecting(vpnId: string): boolean {
    return (vpnId === this.connectedVpnId) &&
      (this.connectState === VpnConstant.VPN_STATE_CONNECTING);
  }

  isConnectedOrConnecting(vpnId: string): boolean {
    let connectState = this.connectState;
    return (vpnId === this.connectedVpnId) &&
      ((connectState === VpnConstant.VPN_STATE_CONNECTING) ||
        (connectState === VpnConstant.VPN_STATE_CONNECTED));
  }

  onConnectStateChange(isConnected: boolean): void {
    LogUtil.info(`${MODULE_TAG} onConnectStateChange isConnected = ${isConnected}`);
    this.removeTimeout();
    if (isConnected) {
      vpn.getConnectedSysVpnConfig().then((data) => {
        if (data && data.addresses && data.vpnId) {
          this.setConnectState(VpnConstant.VPN_STATE_CONNECTED, data.vpnId);
        }
      });
      return;
    }
    if (this.replaceConnectVpnConfig) {
      let config = this.replaceConnectVpnConfig;
      this.replaceConnectVpnConfig = undefined;
      this.setUp(config);
      return;
    }
    if (this.connectState === VpnConstant.VPN_STATE_CONNECTING) {
      this.setConnectState(VpnConstant.VPN_STATE_CONNECT_FAILED);
      return;
    }
    if (this.connectState === VpnConstant.VPN_STATE_DISCONNECTING ||
      this.connectState === VpnConstant.VPN_STATE_CONNECTED) {
      this.setConnectState(VpnConstant.VPN_STATE_DISCONNECTED);
    }
  }

  init(context: common.UIAbilityContext): void {
    if (!context) {
      LogUtil.error(`${MODULE_TAG} init faild, invalid param.`);
      return;
    }
    this.connection = vpn.createVpnConnection(context);
    try {
      LogUtil.info(`${MODULE_TAG} vpn on start`);
      vpn.on('connect', (data) => {
        this.onConnectStateChange(data?.isConnected);
      });
    } catch (error) {
      LogUtil.error(`${MODULE_TAG} vpn on error = ${error}`);
    }
    this.getConnectedVpn();
  }

  release(): void {
    try {
      LogUtil.info(`${MODULE_TAG} vpnConnection on subscribe off start`);
      vpn.off('connect', (data) => {
        LogUtil.info(`${MODULE_TAG} vpnConnection off data = ${data}`);
      });
    } catch (error) {
      LogUtil.error(`${MODULE_TAG} vpnConnection off error = ${error}`);
    }
  }

  removeTimeout(): void {
    if (this.timeoutId !== undefined) {
      LogUtil.info(`${MODULE_TAG} removeTimeout timeoutId = ${this.timeoutId}`);
      clearTimeout(this.timeoutId);
    }
  }

  async setUp(vpnConfig: VpnConfig): Promise<void> {
    if (!vpnConfig) {
      LogUtil.error(`${MODULE_TAG} setUp failed, invalid param.`);
      return;
    }
    LogUtil.info(`${MODULE_TAG} setUp vpn : ${vpnConfig.vpnId}`);
    this.setConnectState(VpnConstant.VPN_STATE_CONNECTING, vpnConfig.vpnId);
    this.removeTimeout();
    this.timeoutId = setTimeout(() => {
      LogUtil.info(`${MODULE_TAG} setUp timeout vpnId=` + vpnConfig.vpnId);
      this.setConnectState(VpnConstant.VPN_STATE_DISCONNECTING, vpnConfig.vpnId);
      this.destroy((error: string) => {
        if (error) {
          LogUtil.error(`${MODULE_TAG} vpn destroy failed, error : ${error}`);
        }
        this.setConnectState(VpnConstant.VPN_STATE_CONNECT_FAILED, vpnConfig.vpnId);
      });
    }, VpnConstant.VPN_CONNECT_TIME_OUT_DURATION);
    try {
      await this.connection.setUp(vpnConfig);
    } catch (err) {
      LogUtil.error(`${MODULE_TAG} setUp error = ${err}`);
      this.removeTimeout();
      this.setConnectState(VpnConstant.VPN_STATE_CONNECT_FAILED, vpnConfig.vpnId);
      this.destroy((error: string) => {
        if (error) {
          LogUtil.error(`${MODULE_TAG} vpn destroy failed, error : ${error}`);
        }
      });
    }
  }

  getConnectedVpn(): void {
    try {
      LogUtil.info(`${MODULE_TAG} getConnectedVpn start`);
      vpn.getConnectedSysVpnConfig().then((data) => {
        if (data && data.addresses && data.vpnId) {
          this.setConnectState(VpnConstant.VPN_STATE_CONNECTED, data.vpnId);
        } else {
          this.setConnectState(VpnConstant.VPN_STATE_NONE);
        }
      });
    } catch (error) {
      LogUtil.error(`${MODULE_TAG} getConnectedVpn error:  ${error}`);
      this.setConnectState(VpnConstant.VPN_STATE_NONE);
    }
  }

  isHapAvailable(): boolean {
    return this.timeoutId !== undefined;
  }

  destroy(callback): void {
    this.removeTimeout();
    this.connection?.destroy((error: BusinessError) => {
      if (error) {
        LogUtil.error(`${MODULE_TAG} destroy error = ${error}`);
      }
      callback(error?.message);
    });
  }
}