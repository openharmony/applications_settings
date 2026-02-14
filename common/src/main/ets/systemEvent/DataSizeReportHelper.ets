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

import { storageStatistics } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { DateTimeUtil } from '../utils/DateTimeUtil';
import { LogUtil } from '../utils/LogUtil';
import { HiSysEventUtil } from './HiSysEventUtil';

/* instrument ignore file */
const TAG: string = 'DataSizeReportHelper';
const FILE_OR_FOLDER_PATH_LIST: string[] =
  ['/data/storage/el1/bundle', '/data/storage/el1/base', '/data/storage/el2/base', '/data/storage/el1/database',
    '/data/storage/el2/database'];
const KEY_LAST_REPORT_DATA_SIZE_TIMESTAMP: string = 'LAST_REPORT_DATA_SIZE_TIMESTAMP';
const COMPONENT_NAME_SETTINGS: string = 'settings';
const PARTITION_NAME_DATA: string = '/data';
const EVENT_NAME: string = 'USER_DATA_SIZE';
const DOMAIN_NAME: string = 'FILEMANAGEMENT';

interface DataSizeParams {
  COMPONENT_NAME: string;
  PARTITION_NAME: string;
  FILE_OR_FOLDER_PATH: string[];
  FILE_OR_FOLDER_SIZE: number[];
}

/**
 * 应用Data分区数据占用打点上报
 *
 * @since 2025-05-14
 */
export class DataSizeReportHelper {
  /**
   * 设置应用data分区占用打点上报
   */
  public static reportDataSize(): void {
    if (DataSizeReportHelper.isLastReportLessThan24Hour()) {
      return;
    }
    storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
      let dataSizeArray: number[] = [0, 0, 0, 0, 0]; // 目录占用大小和FILE_OR_FOLDER_PATH数组对应
      dataSizeArray[0] = bundleStats.appSize;
      // 上层应用占用目录固定，所以统一上报data分区占用即可，放在数组末尾，数组第1-3位留空即可
      dataSizeArray[4] = bundleStats.dataSize;

      let params: DataSizeParams = {
        COMPONENT_NAME: COMPONENT_NAME_SETTINGS,
        PARTITION_NAME: PARTITION_NAME_DATA,
        FILE_OR_FOLDER_PATH: FILE_OR_FOLDER_PATH_LIST,
        FILE_OR_FOLDER_SIZE: dataSizeArray
      };
      try {
        HiSysEventUtil.reportStatisticEventByDomain(EVENT_NAME, params, EVENT_NAME, DOMAIN_NAME);
        DataSizeReportHelper.saveTimestamp();
        LogUtil.showInfo(TAG, `success report data size at ${new Date().getTime()}`);
      } catch (error) {
        LogUtil.showInfo(TAG, `report data size err ${(error as BusinessError)?.message}`);
      }
    }).catch((err: BusinessError) => {
      LogUtil.showError(TAG, `getCurrentBundleStats err ${err?.message}`);
    });
  }

  private static saveTimestamp(): void {
    let currentTimestamp: number = new Date().getTime();
    PreferencesUtil.putSync(KEY_LAST_REPORT_DATA_SIZE_TIMESTAMP, currentTimestamp);
  }

  /**
   * 当前时间距离上次上报是否小于24小时
   *
   * @returns true: 小于24小时; false: 大于24小时
   */
  public static isLastReportLessThan24Hour(): boolean {
    let lastReportTimestamp: number = PreferencesUtil.getSync(KEY_LAST_REPORT_DATA_SIZE_TIMESTAMP, 0) as number;
    let currentTimestamp: number = new Date().getTime();
    LogUtil.showInfo(TAG, `lastReportTime ${lastReportTimestamp}, currentTime ${currentTimestamp}`)
    return (currentTimestamp - lastReportTimestamp) < DateTimeUtil.getPerDayInMillis();
  }
}