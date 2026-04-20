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

export class HiSysNFCStateException {
  public static readonly EVENT_NAME = 'NFC_STATE_EXCEPTION';
  public static readonly NFC_STATE_CHANGE_TIMEOUT = 'NFC_STATE_CHANGE_TIMEOUT';
}

export class HiSysHotspotStateException {
  public static readonly EVENT_NAME = 'HOTSPOT_STATE_EXCEPTION';
  public static readonly HOTSPOT_STATE_CHANGE_TIMEOUT = 'HOTSPOT_STATE_CHANGE_TIMEOUT';
}

export class HiSysWIFIStateException {
  public static readonly EVENT_NAME = 'WIFI_STATE_EXCEPTION';
  public static readonly WIFI_STATE_CHANGE_TIMEOUT = 'WIFI_STATE_CHANGE_TIMEOUT';
}

export class HiSysBluetoothStateException {
  public static readonly EVENT_NAME = 'BLUETOOTH_STATE_EXCEPTION';
  public static readonly BLUETOOTH_STATE_CHANGE_TIMEOUT = 'BLUETOOTH_STATE_CHANGE_TIMEOUT';
}

export class HiSysAccessibilityException {
  public static readonly SOUND_NOTIFICATION_FAILED = 'SOUND_NOTIFICATION_FAILED';
  public static readonly SOUND_NOTIFY_WEARENGINE_FAILED = 'SOUND_NOTIFY_WEARENGINE_FAILED';
  public static readonly IS_SUPPORT_FLASH_FAILED = 'IS_SUPPORT_FLASH_FAILED';
}

export class HiSysAddUserException {
  public static readonly EVENT_NAME = 'ADD_USER_EXCEPTION';
  public static readonly CREATE_NORMAL_USER_FAILED = 'CREATE_NORMAL_USER_FAILED';
  public static readonly CREATE_GUEST_FAILED = 'CREATE_GUEST_FAILED';
}

export class HiSysLoadExternalMenuResException {
  public static readonly EVENT_NAME = 'LOAD_EXTERNAL_MENU_RES_EXCEPTION';
  public static readonly LOAD_OS_ACCOUNT_DISTRIBUTED_INFO_FAILED = 'LOAD_OS_ACCOUNT_DISTRIBUTED_INFO_FAILED';
  public static readonly LOAD_RES_FROM_RESOURCE_MANAGER_FAILED = 'LOAD_RES_FROM_RESOURCE_MANAGER_FAILED';
}

export class HiSysApplicationException {
  public static readonly LOAD_BMS_ICON_NULL = 'LOAD_BMS_ICON_NULL';
}

export class HiSysUsersException {
  public static readonly PREFIX = 'USERS_';
  // 查询所有用户
  public static readonly EVENT_NAME_QUERY_ALL_USERS = `${HiSysUsersException.PREFIX}QUERY_ALL_USERS_FAULT`;
  public static readonly QUERY_ALL_OS_ACCOUNTS_FAILED = 'QUERY_ALL_OS_ACCOUNTS_FAILED';
  // 删除用户
  public static readonly EVENT_NAME_DEL_USER = `${HiSysUsersException.PREFIX}DEL_USER_FAULT`;
  public static readonly REMOVE_ACCOUNT_FAILED = 'REMOVE_ACCOUNT_FAILED';
  public static readonly REMOVE_SERVER_CONFIG_FAILED = 'REMOVE_SERVER_CONFIG_FAILED';
  // 添加用户
  public static readonly EVENT_NAME_ADD_USER = `${HiSysUsersException.PREFIX}ADD_USER_FAULT`;
  public static readonly EVENT_NAME_OOBE_ADD_USER = `${HiSysUsersException.PREFIX}OOBE_ADD_USER_FAULT`;
  public static readonly CREATE_ACCOUNT_FAILED = 'CREATE_ACCOUNT_FAILED';
  // 设置锁屏密码
  public static readonly EVENT_NAME_SET_PIN = `${HiSysUsersException.PREFIX}SET_PIN_FAULT`;
  public static readonly CLOSE_IAM_SESSION_FAILED = 'CLOSE_IAM_SESSION_FAILED';
  public static readonly OPEN_IAM_SESSION_FAILED = 'OPEN_IAM_SESSION_FAILED';
  public static readonly ADD_PIN_CRED_FAILED = 'ADD_PIN_CRED_FAILED';
  // 添加服务器配置
  public static readonly EVENT_NAME_ADD_SERVER_CONFIG = `${HiSysUsersException.PREFIX}ADD_SERVER_CONFIG_FAULT`;
  public static readonly ADD_SERVER_CONFIG_FAILED = 'ADD_SERVER_CONFIG_FAILED';
  // 验证企业账号
  public static readonly EVENT_NAME_AUTH_ENT_ACCT = `${HiSysUsersException.PREFIX}AUTH_ENT_ACCT_FAULT`;
  public static readonly AUTH_FAILED = 'AUTH_FAILED';
  // 添加企业用户
  public static readonly EVENT_NAME_ADD_DOMAIN_USER = `${HiSysUsersException.PREFIX}ADD_DOMAIN_USER_FAULT`;
  public static readonly CREATE_DOMAIN_ACCOUNT_FAILED = 'CREATE_DOMAIN_ACCOUNT_FAILED';
  // 本地用户绑定企业账号
  public static readonly BIND_DOMAIN_ACCT = 'BIND_DOMAIN_FAULT';
  public static readonly SET_LOCAL_NAME_FAILED = 'SET_LOCAL_NAME_FAILED';
  public static readonly BIND_DOMAIN_ACCT_FAILED = 'BIND_DOMAIN_ACCT_FAILED';
  // 企业用户相关操作
  public static readonly OPERATE_DOMAIN_FAULT = 'OPERATE_DOMAIN_FAULT';
}