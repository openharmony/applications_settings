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

import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { WlanItemModel } from './model/WlanItemModel';

/* instrument ignore file */
const NOT_LAST_ITEM: string = 'false';
const IS_LAST_ITEM: string = 'true';

/**
 * Wifi列表dataSource工具类
 *
 * @since 2025-07-19
 */
export class WifiDataSourceUtils {
  /**
   * 移除指定索引的wifi项
   * @param dataSource 数据源
   * @param index 移除索引
   */
  public static removeWifiItemByIndex(dataSource: OrderedDataSource | undefined, index: number) {
    if (!dataSource) {
      return;
    }
    // 移除wifi列表，若移除的是最后一个需要刷新倒数第二个的底部横线
    if (index - 1 >= 0 && index === dataSource.length - 1 && dataSource[index -1]) {
      dataSource[index -1].subId = IS_LAST_ITEM;
    }
    dataSource.removeDataByIndex(index);
  }

  /**
   * 插入wifi项到顶部
   * @param dataSource 数据源
   * @param menu 数据列表
   */
  public static insertWifiItemToFirst(dataSource: OrderedDataSource | undefined, menu: WlanItemModel) {
    if (!dataSource || !menu) {
      return;
    }
    menu.subId = dataSource.length === 0 ? IS_LAST_ITEM : NOT_LAST_ITEM;
    dataSource.insertData(0, menu);
  }

  /**
   * 根据索引插入wifi项
   * @param dataSource 数据源
   * @param menu 数据列表
   */
  public static insertWifiItemByIndex(dataSource: OrderedDataSource | undefined, index: number, menu: WlanItemModel) {
    if (!dataSource || !menu) {
      return;
    }
    // 如果插入的是末尾
    if (dataSource.length === index) {
      // 原末尾项添加横线
      if (dataSource.length > 0 && dataSource[dataSource.length - 1]) {
        dataSource[dataSource.length - 1].subId = NOT_LAST_ITEM;
      }
      menu.subId = IS_LAST_ITEM;
    } else {
      menu.subId = NOT_LAST_ITEM;
    }
    dataSource.insertData(index, menu);
  }

  /**
   * 插入wifi列表
   * @param dataSource 数据源
   * @param menu 数据列表
   */
  public static insertWifiItemList(dataSource: OrderedDataSource | undefined, menus: WlanItemModel[]) {
    if (!dataSource || !menus) {
      return;
    }
    // 刷新末尾项（底部横线刷新）
    if (dataSource.length !== 0 && dataSource[dataSource.length - 1]) {
      dataSource[dataSource.length - 1].subId = NOT_LAST_ITEM;
    }
    menus.forEach((item, index) => {
      if (item) {
        item.subId = index === menus.length - 1 ? IS_LAST_ITEM : NOT_LAST_ITEM;
      }
    })
    dataSource.pushDataArray(menus);
  }
}