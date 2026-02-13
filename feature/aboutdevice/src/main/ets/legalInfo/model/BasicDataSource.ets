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
import { AppInfo } from './AppInfo';
/* instrument ignore file */
const TAG = 'BasicDataSource';
const POSITION_VALID: number = 0;

/**
 * 懒加载数据源
 */
export class BasicDataSource implements IDataSource {
  // 数据改变监听器
  private listeners: DataChangeListener[] = [];

  /**
   * 获取数据源列表长度
   */
  public totalCount(): number {
    return 0;
  }

  /**
   * 从数据源获取指定索引值的数据项
   *
   * @param index 数据源索引值
   * @return 对应索引值的数据项
   */
  public getData(index: number): AppInfo | null {
    return null;
  }

  /**
   * 注册数据改变的监听器
   * @param listener
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < POSITION_VALID) {
      LogUtil.info(`${TAG} Add listener`);
      this.listeners.push(listener);
    }
  }

  /**
   * 注销数据改变的监听器
   * @param listener
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= POSITION_VALID) {
      LogUtil.info(`${TAG} Move listener`);
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * 通知组件重新加载所有数据
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}