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

import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';

export class StorageEventConstant {
  // 系统数据组件初始化事件
  public static readonly EVENT_STORAGE_SYS_DATA_GROUP_INIT: string = 'settings.event.storage.SystemDataGroup.init';
  public static readonly EVENT_NOTDISTURB_GROUP_INIT: string = 'settings.event.notdisturb.init';
  public static readonly HAS_HWBACKUP_RECORD: string = 'has_hwbackup_record';
  public static readonly HAS_NEXT_HWBACKUP_RECORD: string = 'has_next_hwbackup_record';
  public static readonly LOCAL_BACKUP_INFORMATION: string = 'local_backup_information';
  public static readonly EVENT_REFRESH_STORAGE_DATA: string = 'event_refresh_storage_data';
}

export class AppEntryStorage extends AppEntry {
  public abilityPrevAccessTime: number = 0;
  public unusedDaysDescription: ResourceStr = '';
  public isSelected: boolean = false;
}

export enum NoGetBundleStatsFlag {
  GET_BUNDLE_WITH_ALL_SIZE = 0x00000000,
  GET_BUNDLE_WITHOUT_INSTALL_SIZE = 0x00000001,
  GET_BUNDLE_WITHOUT_DATA_SIZE = 0x00000002,
  GET_BUNDLE_WITHOUT_CACHE_SIZE = 0x00000004,
}

// 无可清理缓存时 卡片自动消失延时
export const CARD_DISAPPEAR_DELAY: number = 1000;

// 接入卡片显示内存阈值
export const MAX_PROPORTION: number = 90;

// 文件管理显示内存最小内存
export const FILE_MIN_PROPORTION: number = 50;

// 清理卡片显示内存阈值
export const CLEAR_CARD_MAX_PROPORTION: number = 90;

// 清理卡片有缓存清理阈值
export const CLEAR_CARD_STORAGE_PROPORTION: number = 1024 * 1000 * 10;

// 主应用appIndex
export const MAIN_APP_INDEX: number = 0;

// 保留两位小数
export const DECIMAL_PLACE_NUMBER: number = 2;

// 获取应用占用存储大小超时时间
export const GET_APP_STATS_TIMEOUT: number = 600;

// 不常用应用卡片显示最小内存阈值
export const MIN_PROPORTION: number = 20;

export const LONGEST_UNUSED_TIME = DateTimeUtil.getPerDayInMillis() * 30;

export const CLEAR_CACHE_URL: string = '../controller/StorageCleanController';

export const CLOUD_GALLERY_URL: string = '../controller/CloudGalleryCardController';

export const FILE_MANAGER_URL: string = '../controller/FileManagerCardController';

export const FILE_MANAGER_LOW_URL: string = '../controller/FileManagerLowCardController';

export const GALLERY_URL: string = '../controller/GalleryCardController';

export const UNINSTALL_APP_URL: string = '../controller/StorageAppUninstallController';

export const INVALID_CARD_NAME: string = 'invalid';

export const DEFAULT_DATA_SIZE: number = 0;