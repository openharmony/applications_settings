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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'SearchStatisticsDataUtils';

const DEFAULT_DATA_SIZE: number = 0;

export interface StatisticsRes {
  statisticsFileCount: number; // 被统计文件个数
  statisticsValue: number; // 被统计文件总大小单位B
}

export interface StatisticsParam {
  searchType: number; // 统计类型，按类型统计大小传0
  fileType: number; // 统计文件类型 图片 1 视频 2 音频 3 文档 4 压缩包 5
}

/**
 * 文件数据查询工具类
 *
 * @since 2025-3-3
 */
export class SearchStatisticsDataUtils {
  private static readonly allType = -1; // 查询所有类型文件数据
  private static readonly imageType = 1; // 查询图片类型文件数据
  private static readonly videoType = 2; // 查询视频类型文件数据
  private static readonly audioType = 3; // 查询音频类型文件数据
  private static readonly documentType = 4; // 查询文档类型文件数据
  private static readonly zipType = 5; // 查询压缩包类型文件数据

  private constructor() {
  }

  /**
   * 获取音频统计数据大小
   *
   * @param fileTypeList 查询的文件类型
   * @returns 音频统计数据
   */
  public static async getAudioStatisticsData(): Promise<number> {
    let param: StatisticsParam = {
      searchType: 0, // 接口固定查询类型
      fileType: this.audioType,
    };
    const startTime = new Date().getTime();
    let res: StatisticsRes = await SearchStatisticsDataUtils.getStatisticsData(param);
    const endTime = new Date().getTime();
    LogUtil.info(`${TAG} getAudioStatisticsData : ${res?.statisticsValue}, costTime: ${endTime - startTime}`);
    return res ? res.statisticsValue : DEFAULT_DATA_SIZE;
  }

  /**
   * 获取文件查询信息
   *
   * @param statisticsParam 文件查询参数
   * @returns 文件查询信息
   */
  private static async getStatisticsData(param: StatisticsParam): Promise<StatisticsRes> {
    let defaultRes: StatisticsRes = {
      statisticsFileCount: DEFAULT_DATA_SIZE,
      statisticsValue: DEFAULT_DATA_SIZE
    };
    try {
      let indexInsertNapi: ESObject = loadNativeModule('@ohos.index_insert_napi');
      let res = await indexInsertNapi.SearchStatisticsData(param);
      LogUtil.info(`${TAG} getStatisticsData finished fileType: ${param.fileType}, fileCount: ${res?.statisticsFileCount}, value: ${res?.statisticsValue}`);
      return res ?? defaultRes;
    } catch (err) {
      LogUtil.error(`${TAG} 'getStatisticsData error, code: ${err?.code}, msg: ${err?.message}`);
    }
    return defaultRes;
  }
}