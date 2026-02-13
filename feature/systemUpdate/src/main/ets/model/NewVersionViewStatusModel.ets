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
 * 新版本页面状态
 *
 * @since 2024-08-22
 */
export enum NewVersionViewStatus {
  /**
   * 无版本
   */
  VIEW_INIT,

  /**
   * 搜到新版本
   */
  VIEW_CHECK_SUCCESS,

  /**
   * 下载中
   */
  VIEW_DOWNLOADING,

  /**
   * 下载暂停
   */
  VIEW_DOWNLOAD_PAUSE,

  /**
   * 下载校验中
   */
  VIEW_DOWNLOAD_VERIFYING,

  /**
   * 下载成功
   */
  VIEW_DOWNLOAD_SUCCESS,

  /**
   * 安装校验中
   */
  VIEW_UPGRADE_VERIFYING,

  /**
   * 重启中
   */
  VIEW_UPGRADE_REBOOTING,

  /**
   * 热安装中
   */
  VIEW_UPGRADE_HOT_INSTALLING,

  /**
   * 安装环境准备中
   */
  VIEW_PRE_INSTALLING,

  /**
   * 安装中
   */
  VIEW_INSTALLING,

  /**
   * 安装完成
   */
  VIEW_INSTALL_SUCCESS,

  /**
   * 等待安装
   */
  VIEW_INSTALL_WAIT,
}

/**
 * 系统升级状态显示信息
 *
 * @since 2024-08-22
 */
export class SystemUpdateStatusShowInfo {
  /**
   * 系统升级状态显示文字
   */
  public systemUpdateStatusText: ResourceStr = '';

  /**
   * 是否显示角标
   */
  public isShowBadge: boolean = false;
}