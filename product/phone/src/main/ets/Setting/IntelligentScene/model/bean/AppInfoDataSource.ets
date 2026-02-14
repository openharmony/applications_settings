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

import { AppInfo } from './AppInfo';
import { BasicDataSource } from './BasicDataSource';

/* instrument ignore file */
export const alphabets = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

export class AppInfoDataSource extends BasicDataSource {
  private dataArray: AppInfo[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getArray(): AppInfo[] {
    return this.dataArray;
  }

  public getData(index: number): AppInfo {
    return this.dataArray[index];
  }

  public removeDataByIndex(index: number): void {
    if (this.dataArray.length <= index) {
      return;
    }
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public updateData(index: number, newData?: AppInfo): void {
    if (this.dataArray.length <= index) {
      return;
    }
    if (newData) {
      this.dataArray[index] = newData;
    }
    this.notifyDataChange(index);
  }

  public addData(index: number, data: AppInfo): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: AppInfo): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clearAll(): void {
    this.dataArray.length = 0;
  }

  public getPrefixIndex(index: number): number {
    let str = this.dataArray[index]?.prefix ?? '';
    return alphabets.indexOf(str);
  }
  
  public getSelectedAppString(): string[] {
    let appString: string[] = [];
    for (let i = 0; i < this.dataArray.length; i++) {
      let item: AppInfo = this.dataArray[i];
      if (item.isSelected) {
        appString.push(`${item.name}_${item.appIndex}`);
      }
    }
    return appString;
  }

  public getListScrollIndex(index: number): number {
    if (index < 0) {
      return -1;
    }
    let str = alphabets[index];
    let i = 0;
    for (const item of this.dataArray) {
      if (str === item.prefix) {
        return i;
      }
      i++;
    }
    return -1;
  }

  public getPrefixList(index: number): string[] {
    let result: string[] = [];
    if (index < 0 || index > alphabets.length) {
      return result;
    }
    let prefixSet: Set<string> = new Set();
    for (let item of this.dataArray) {
      let str: string = alphabets[index];
      if (str == item.prefix && item.label) {
        prefixSet.add(item.label[0]);
      }
    }
    result = Array.from(prefixSet);
    return result;
  }
}