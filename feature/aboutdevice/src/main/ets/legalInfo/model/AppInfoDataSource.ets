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

import { BasicDataSource } from './BasicDataSource';
import { AppInfo } from './AppInfo';

export class AppInfoDataSource extends BasicDataSource {
  public appInfoList: Array<AppInfo> = [];

  constructor(appInfoList: Array<AppInfo>) {
    super();
    this.appInfoList = appInfoList;
  }

  public totalCount(): number {
    return this.appInfoList.length;
  }

  public getData(index: number): AppInfo {
    return this.appInfoList[index];
  }

  /**
   * 添加数据项
   * @param index 下标
   * @returns 数据列表
   */
  public pushDataList(data: Array<AppInfo>): void {
    if (data) {
      for (let element of data) {
        if (this.appInfoList.indexOf(element) > -1) {
          continue;
        }
        this.appInfoList.push(element);
      }
      this.notifyDataAdd(this.appInfoList.length - 1);
    }
  }
}