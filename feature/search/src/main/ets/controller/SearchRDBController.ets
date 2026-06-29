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

import { BusinessError } from '@ohos.base';
import { relationalStore } from "@kit.ArkData";
import { ContextUtils, LogUtil } from "@ohos/settings.common";
import { ResultItemInfo } from "../model/type";
import { SearchSecurityUtil } from "../util/SearchSecurityUtil";
import { i18n } from "@kit.LocalizationKit";
import { fileIo, ReadOptions } from '@kit.CoreFileKit';
import { resourceManager } from '@kit.LocalizationKit';
import { common } from "@kit.AbilityKit";

const TAG = 'SearchRDBController : '

export class SearchRDBController {
  static rdbStore: relationalStore.RdbStore | null = null;
  static RDBDirectory: string = ''

  static async initialize() {
    const config: relationalStore.StoreConfig = {
      name: 'SettingsApp.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    try {
      const context = ContextUtils.getContext();
      if (!context) {
        LogUtil.error(TAG + 'initialize context is null');
        return;
      }
      SearchRDBController.rdbStore = await relationalStore.getRdbStore(context, config);
      LogUtil.info(TAG + 'initialize')
    } catch (err) {
      const bizErr = err as BusinessError;
      LogUtil.error(TAG + 'initialize' + 'ErrorCode:' + bizErr?.code + ' ErrorMessage:' + bizErr?.message);
    }
  }

  static async queryAllItems(searchKey: string): Promise<ResultItemInfo[] | null> {
    if (!SearchRDBController.rdbStore) {
      LogUtil.error(TAG + ' rdbStore no init');
      return null;
    }
    const sanitizedKey = SearchSecurityUtil.sanitizeSearchInput(searchKey);
    if (!sanitizedKey) {
      return null;
    }
    LogUtil.info(TAG + 'queryAllItems Start')
    try {
      let curLocale: string = i18n.System.getSystemLocale();
      const predicates = new relationalStore.RdbPredicates('ITEMINFO_TABLE');
      predicates.equalTo('locale', curLocale).and();
      // 纯英文关键词只匹配 itemTitle，不匹配 alias，避免 "sound" 匹配到 "声音" 等
      if (SearchRDBController.isPureLatin(sanitizedKey)) {
        predicates.contains('itemTitle', sanitizedKey);
      } else {
        predicates.beginWrap()
          .contains('itemTitle', sanitizedKey)
          .or()
          .contains('alias', sanitizedKey)
          .endWrap();
      }
      const columns = [
        'itemTitle',
        'locale',
        'itemName',
        'bundleName',
        'itemDescription',
        'entryKey',
        'pageTitle',
        'enable',
        'path',
        'icon'
      ];
      const data: ResultItemInfo[] = []
      const resultSet = SearchRDBController.rdbStore.querySync(predicates, columns)
      if (resultSet?.rowCount > 0) {
        resultSet.goToFirstRow();
        do {
          const itemTitle = resultSet.getString(resultSet.getColumnIndex('itemTitle'));
          const locale = resultSet.getString(resultSet.getColumnIndex('locale'));
          const itemName = resultSet.getString(resultSet.getColumnIndex('itemName'));
          const bundleName = resultSet.getString(resultSet.getColumnIndex('bundleName'));
          const itemDescription = resultSet.getString(resultSet.getColumnIndex('itemDescription'));
          const entryKey = resultSet.getString(resultSet.getColumnIndex('entryKey'));
          const pageTitle = resultSet.getString(resultSet.getColumnIndex('pageTitle'));
          const enable = resultSet.getString(resultSet.getColumnIndex('enable'));
          const path = resultSet.getString(resultSet.getColumnIndex('path'));
          const icon = resultSet.getString(resultSet.getColumnIndex('icon'));
          data.push({
            locale,
            title: itemTitle,
            parentKey: '',
            path,
            icon,
            entryKey,
            uriParams: '',
            itemName,
            bundleName,
            appName: 'com.ohos.settings',
            appStatus: JSON.parse(enable),
            installSource: ''
          })
          // 处理数据...
        } while (resultSet.goToNextRow());
      }
      return data ?? null;
    } catch (err) {
      const bizErr = err as BusinessError;
      LogUtil.error(TAG + `查询失败: ${bizErr?.message}`);
      return null;
    }
  }

  /** 判断是否为纯拉丁字符（仅 a-z、A-Z、数字、空格），纯英文关键词不参与 alias 匹配 */
  private static isPureLatin(key: string): boolean {
    if (!key || key.length === 0) {
      return false;
    }
    return /^[a-zA-Z0-9\s]+$/.test(key);
  }

  static async saveFileToCache(file: resourceManager.RawFileDescriptor, dbName: string) {
    // 创建缓存文件(当前是覆盖式创建)
    let cFile = SearchRDBController.RDBDirectory + '/phone/rdb/' + dbName;
    LogUtil.info(TAG+'cFile :'+cFile)
    let cacheFile = fileIo.openSync(cFile, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);

    // 读取缓冲区大小
    let bufferSize = 30000;
    let buffer = new ArrayBuffer(bufferSize); //创建buffer缓冲区

    // 要copy的文件的offset
    let currentOffset = file.offset;

    let readOption: ReadOptions = {
      offset: currentOffset, //期望读取文件的位置。可选，默认从当前位置开始读
      length: bufferSize //每次期望读取数据的长度。可选，默认缓冲区长度
    };

    // 后面len会一直减，直到没有
    while (true) {
      // 读取buffer容量的内容
      let readLength = fileIo.readSync(file.fd, buffer, readOption);
      // 写入buffer容量的内容
      fileIo.writeSync(cacheFile.fd, buffer, { length: readLength }); //写到cacheFile里
      // 判断后续内容 修改读文件的参数
      // buffer没读满代表文件读完了
      if (readLength < bufferSize) {
        break;
      }
      if (readOption.offset != undefined) {
        readOption.offset += readLength;
      }
    }
    LogUtil.info(TAG + 'Copy Success!!!')
    fileIo.close(cacheFile);
  }


}