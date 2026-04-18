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

export default class VpnConstant {
  static readonly VPN_LIST_PAGE_URL: string = '../Setting/MoreConnection/VpnHomePage';
  static readonly VPN_NAME_MAX_LENGTH: number = 30;
  static readonly VPN_USER_NAME_MAX_LENGTH: number = 30;
  static readonly VPN_PASSWORD_MAX_LENGTH: number = 30;
  static readonly INPUT_MAX_LENGTH: number = 100;

  static readonly STORAGE_KEY_CONNECT_STATE: string = 'vpnConnectState';

  static readonly VPN_STATE_NONE: number = 0;
  static readonly VPN_STATE_CONNECTING: number = 1;
  static readonly VPN_STATE_CONNECTED: number = 2;
  static readonly VPN_STATE_DISCONNECTING: number = 3;
  static readonly VPN_STATE_DISCONNECTED: number = 4;
  static readonly VPN_STATE_CONNECT_FAILED: number = 5;

  static readonly VPN_CONNECT_TIME_OUT_DURATION: number = 60000;

  static readonly REGEX_IP: RegExp =
    /^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
  static readonly REGEX_PORT: RegExp =
    /^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$/;

  static readonly OVPN_AUTH_TYPE_TLS: number = 0;
  static readonly OVPN_AUTH_TYPE_PWD: number = 1;
  static readonly OVPN_AUTH_TYPE_TLS_PWD: number = 2;

  static readonly SELECTOR_VPN_TYPE: number = 1;
  static readonly SELECTOR_OVPN_PROTOCOL: number = 2;
  static readonly SELECTOR_OVPN_AUTH: number = 3;
  static readonly SELECTOR_CERT: number = 4;

  static readonly INPUT_TYPE_IP: number = 1;
  static readonly INPUT_TYPE_PORT: number = 2;
  static readonly INPUT_TYPE_PWD: number = 3;

  static readonly VPN_NUM_MAX: number = 50;
}