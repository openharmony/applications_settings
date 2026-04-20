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

export class ErrorCodeConstant {

  public static readonly COOP_FAIL_CODE_BLE = 401;
  public static readonly COOP_FAIL_CODE_TIMEOUT = 402;
  public static readonly COOP_FAIL_REJECTED = 403;
  public static readonly COOP_FAIL_DRAG_NOT_ALLOW = 404;
  public static readonly COOP_FAIL_DRAG_TIMEOUT = 405;
  public static readonly ADD_DEVICE_EXCEEDED = 406;
  public static readonly CAPSULE_SHOW_FAIL = 407;
  public static readonly SPATIAL_AWARENESS_FAIL_NULL = 501;
  public static readonly SPATIAL_AWARENESS_FAIL_ERROR = 502;
  /** 协商失败错误码 */
  public static readonly ERROR_NEGOTIATE_RESPONSE_TIME_OUT = 10602;
  public static readonly ERROR_NEGOTIATE_VERSION_EXCEPTION = 10603;
  public static readonly ERROR_NEGOTIATE_GET_RESPONSE_INFO_EXCEPTION = 10604;
  public static readonly ERROR_NEGOTIATE_GET_REQUEST_INFO_EXCEPTION = 10605;
  public static readonly ERROR_NEGOTIATE_CONNECT_INFO_EXCEPTION = 10606;

  /** 穿越管理多次穿越错误码 */
  public static readonly ERROR_UNABLE_COOPERATE_CODE = 20900004;

  /** 软总线连接超时 */
  public static readonly SOFTBUS_ERROR_CONNECT_TIMEOUT: number = -425918311;
  /** 本端WiFi关闭 */
  public static readonly SOFTBUS_ERROR_WIFI_OFF_LOCAL: number = -425992167;
  /** 对端WiFi关闭 */
  public static readonly SOFTBUS_ERROR_WIFI_OFF_REMOTE: number = -425992163;
  /** 本端热点打开 */
  public static readonly SOFTBUS_ERROR_REMOTE_CLOSE_CHIP_LOCAL: number = -425917452;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_AP_STA_CHIP_CONFLICT: number = -425917457;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_AP_P2P_CHIP_CONFLICT: number = -425917455;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_AP_HML_CHIP_CONFLICT: number = -425917453;
  /** 对端热点打开 */
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_AP_STA_HML_CHIP_CONFLICT: number = -425917451;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_AP_STA_P2P_CHIP_CONFLICT: number = -425917449;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_AP_P2P_HML_CHIP_CONFLICT: number = -425917447;
  private static readonly ERROR_PEER_THREE_VAP_CONFLICT: number = -206604;
  /** 对端热点冲突 （请对方设备关闭个人热点后再试）*/
  public static readonly SOFTBUS_ERROR_CHIP_CONFLICT: number[] = [
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_AP_STA_CHIP_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_AP_P2P_CHIP_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_AP_HML_CHIP_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_AP_STA_HML_CHIP_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_AP_STA_P2P_CHIP_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_AP_P2P_HML_CHIP_CONFLICT,
    ErrorCodeConstant.ERROR_PEER_THREE_VAP_CONFLICT
  ];
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_HML_NUM_LIMITED_CONFLICT: number = -425917431;
  private static readonly SOFTBUS_CONN_PV1_PEER_GC_CONNECTED_TO_ANOTHER_DEVICE: number = -425917848;
  private static readonly SOFTBUS_CONN_PV2_PEER_GC_CONNECTED_TO_ANOTHER_DEVICE: number = -425917814;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_55_CONFLICT: number = -425917445;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_225_CONFLICT: number = -425917443;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_255_CONFLICT: number = -425917441;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_525_CONFLICT: number = -425917439;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_555_CONFLICT: number = -425917437;
  private static readonly SOFTBUS_CONN_PASSIVE_TYPE_P2P_GO_GC_CONFLICT: number = -425917435;
  /** 对端连接超限 （对方设备正在与其他设备进行互联，请稍后再试）*/
  public static readonly SOFTBUS_ERROR_HML_CONFLICT: number[] = [
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_HML_NUM_LIMITED_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PV1_PEER_GC_CONNECTED_TO_ANOTHER_DEVICE,
    ErrorCodeConstant.SOFTBUS_CONN_PV2_PEER_GC_CONNECTED_TO_ANOTHER_DEVICE,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_55_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_225_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_255_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_525_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_STA_P2P_HML_555_CONFLICT,
    ErrorCodeConstant.SOFTBUS_CONN_PASSIVE_TYPE_P2P_GO_GC_CONFLICT
  ];
}
