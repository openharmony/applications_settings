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

export class Constants {
  // 网络以太网输入地址正则匹配
  public static readonly IP_REGEXP: RegExp =
    new RegExp('^(([1-9]|[1-9]\\d|1[0-1]\\d|12[0-68-9]|1[3-9]\\d|2[0-4]\\d|25[0-5])\\.)(([1-9]?\\d|1\\d{2}|2[0-4]\\d|25[0-5])\\.){2}([1-9]?\\d|1\\d{2}|2[0-4]\\d|25[0-5])$');
  public static readonly NETMASK_REGEXP: RegExp =
    new RegExp('^((254|252|248|240|224|192|128)\\.0\\.0\\.0)$|^(255\\.(254|252|248|240|224|192|128|0)\\.0\\.0)$|^(255\\.255\\.(254|252|248|240|224|192|128|0)\\.0)$|^(255\\.255\\.255\\.(255|254|252|248|240|224|192|128|0))$');
  public static readonly DNS_REGEXP: RegExp =
    new RegExp('^(([1-9]?\\d|1\\d{2}|2[0-4]\\d|25[0-5])\\.){3}([1-9]?\\d|1\\d{2}|2[0-4]\\d|25[0-5])$');
  // 50% width
  public static readonly PERCENT_50_WIDTH: string = '50%';
  // 代理服务器设置失败错误码
  public static readonly EC_HOST_DEFAULT: number = 500;
  public static readonly EC_HOST_IS_NULL: number = 501;
  public static readonly EC_HOST_LENGTH_EXCEED_LIMIT: number = 502;
  public static readonly EC_HOST_REGULAR_MISMATCH: number = 503;
  public static readonly EC_IGNORE_LIST_REGULAR_MISMATCH: number = 504;
  public static readonly MAX_HOST_NAME_LEN: number = 2048;
  // 代理半模态弹框显示事件
  public static readonly PROXY_DIALOG_SHOW: string = 'PROXY_DIALOG_SHOW';
  // 代理半模态弹框消失事件
  public static readonly PROXY_DIALOG_DISMISS_EVENT: string = 'PROXY_DIALOG_DISMISS_EVENT';
  // 代理开启状态事件
  public static readonly PROXY_SETTINGS_DIALOG_ID: string =
    'Setting.pc_proxy_settings_page.pc_proxy_settings_group.pc_proxy_settings';
  // 以太网网络可用事件
  public static readonly ETHERNET_INTERNET_AVAILABLE_EVENT: string = 'ETHERNET_INTERNET_AVAILABLE_EVENT';
  // 以太网网络改变事件
  public static readonly ETHERNET_CHANGE_EVENT: string = 'ETHERNET_CHANGE_EVENT';
  // 高级设置弹框消失事件
  public static readonly ADVANCED_ETHERNET_DIALOG_DISMISS_EVENT: string = 'ADVANCED_ETHERNET_DIALOG_DISMISS_EVENT';
}