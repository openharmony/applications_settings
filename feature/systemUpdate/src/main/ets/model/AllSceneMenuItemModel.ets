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
 * 协同设备视图信息
 *
 * @since 2024-09-18
 */
export interface AllSceneMenuItemInfo {
  /**
   * 是否显示菜单项
   */
  isShowMenuItem: boolean;

  /**
   * 是否显示小红点
   */
  isShowBadge: boolean;

  /**
   * 协同设备状态视图标题
   */
  menuItemTitle: ResourceStr;

  /**
   * 协同设备状态视图标题资源名
   */
  menuItemTitleResourceName: string;

  /**
   * 协同设备状态视图富文本
   */
  menuItemContent: ResourceStr;

  /**
   * 设备数量
   */
  deviceCount: number;

  /**
   * 首个设备的名称
   */
  firstDeviceName: string;

  /**
   * 设备数量单复数资源名
   */
  deviceCountResourceName: string;

  /**
   * 协同设备状态视图富文本格式资源名
   */
  multipleContentResourceName: string;

  /**
   * 是否全部更新完成
   */
  isAllCompleted: boolean;
}
