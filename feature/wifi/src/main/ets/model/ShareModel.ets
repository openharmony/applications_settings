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

/**
 * 碰一碰分享事件类型
 *
 * @since 2024-09-04
 */
export enum ShareEventType {
  SHARING = 1,
  ACCEPTING = 2
}

/**
 * 分享数据类型
 *
 * @since 2024-09-04
 */
export enum ShareDataType {
  WIFI = 1,
  HOTSPOT = 2
}

/**
 * 提示语异常结束码
 *
 * @since 2024-10-28
 */
export enum ShareTipsCode {
  SEND_API_NOTIFY_INFO_DATA_INVALID_TO_SHARE = 1202,
  SEND_API_NOTIFY_INFO_OPEN_HOTPOINT_TO_SHARE = 1205
}