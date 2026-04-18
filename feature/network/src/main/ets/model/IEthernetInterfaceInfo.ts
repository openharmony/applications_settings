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

import type ethernet from '@ohos.net.ethernet';

enum IPAddressingMode {
  DHCP = 1,
  STATIC = 0
}

interface IEthernetInterfaceInfo {
  mode: ethernet.IPSetMode,
  ipAddr: string,
  route: string,
  netMask: string,
  gateway?: string,
  dnsServers?: string,
  dns0?: string,
  dns1?: string,
  domain?: string,
  errorInputKeys?: Array<string>,
}

export type { IPAddressingMode, IEthernetInterfaceInfo };
