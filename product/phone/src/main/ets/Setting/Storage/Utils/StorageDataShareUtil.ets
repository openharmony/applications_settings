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
import { Context } from '@kit.AbilityKit';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import rdb from '@ohos.data.rdb';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const TAG: string = 'StorageDataShareUtil';

export const VIDEO_SIZE_QUERY_URI: string =
  'datashare:///com.ohos.photos.setting.card?queryScene=queryVideoSize';

export const IMAGE_SIZE_QUERY_URI: string =
  'datashare:///com.ohos.photos.setting.card?queryScene=queryImageSize';

export const FILE_MANAGER_QUERY_URI: string = 'datashare:///com.ohos.filemanager.DataShare.bigFileClean';

export const FILE_MANAGER_AUDIO_QUERY_URI: string =
  'datashare:///com.ohos.filemanager.DataShare.bigFileClean?queryScene=audioDataClean';

export class StorageDataShareUtil {
  /**
   * 根据uir获取对应的DataShareHelper
   *
   * @param uri 目标链接uri
   * @param context 上下文
   * @returns 目标uri对应的DataShareHelper
   */
  public static async getDataShareHelper(uri: string,
    context: Context): Promise<dataShare.DataShareHelper | undefined> {
    if (CheckEmptyUtils.isEmpty(uri)) {
      LogUtil.error(`${TAG} getDataShareHelper uri invalid!`);
      return undefined;
    }
    if (!context) {
      LogUtil.error(`${TAG} getDataShareHelper context invalid!`);
      return undefined;
    }
    try {
      return await dataShare.createDataShareHelper(context, uri);
    } catch (err) {
      LogUtil.error(`${TAG} createDataShareHelper error ${err?.code} ${err?.message}`);
    }
    return undefined;
  }

  /**
   * 根据入参查询单列首行数据
   *
   * @param uri 需要查询的uri
   * @param predicates 过滤条件
   * @param columnName 需要查询数据对应的列名
   * @param context 上下文
   * @returns 单列首行对应数据
   */
  public static async queryDataByOneColumn(uri: string, predicates: dataSharePredicates.DataSharePredicates,
    columnName: string, context: Context): Promise<string | undefined> {
    if (CheckEmptyUtils.checkStrIsEmpty(uri) || CheckEmptyUtils.isEmpty(predicates) ||
    CheckEmptyUtils.checkStrIsEmpty(columnName)) {
      LogUtil.warn(`${TAG} queryDataByOneColumn invalid parameters!`);
      return undefined;
    }
    let dataShareHelper = await StorageDataShareUtil.getDataShareHelper(uri, context);
    if (!dataShareHelper) {
      LogUtil.warn(`${TAG} dataShareHelper invalid!`);
      return undefined;
    }
    let resultSet: DataShareResultSet | undefined;
    try {
      let start = Date.now();
      resultSet = await dataShareHelper.query(uri, predicates, [columnName]);
      LogUtil.info(`${TAG} query ${columnName} cost time ${Date.now() - start}, row count: ${resultSet?.rowCount}`);
    } catch (err) {
      LogUtil.error(`${TAG} query ${columnName} error ${err?.code} ${err?.message}`);
    }
    if (!resultSet) {
      LogUtil.warn(`${TAG} query ${columnName} resultSet invalid!`);
      StorageDataShareUtil.closeDataShareResource(resultSet, dataShareHelper);
      return undefined;
    }
    resultSet.goToFirstRow();
    let resultStr: string = resultSet.getString(resultSet.getColumnIndex(columnName));
    StorageDataShareUtil.closeDataShareResource(resultSet, dataShareHelper);
    return resultStr;
  }

  /**
   * 主动关闭DataShare资源
   *
   * @param resultSet 结果集
   * @param dataShareHelper DataShareHelper实例
   */
  public static closeDataShareResource(resultSet: rdb.ResultSet | DataShareResultSet | undefined,
    dataShareHelper: dataShare.DataShareHelper) {
    resultSet?.close();
    dataShareHelper?.close();
  }
}