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
import { LogUtil } from './LogUtil';

const TAG: string = 'ControllerCounter : ';

/**
 * Controller计数器
 * 解决快速切换菜单，导致新对象被旧对象解注册监听。
 */
class ControllerCounter {
  public useCount: Map<string, number> = new Map();

  addController(source: string): void {
    let count = this.useCount.get(source) ?? 0;
    this.useCount.set(source, ++count);
    LogUtil.info(`${TAG} addController ${source}: ${count}`);
  }

  removeController(source: string): boolean {
    let count = this.useCount.get(source);
    if (count === undefined || count <= 1) {
      this.useCount.set(source, 0);
      LogUtil.info(`${TAG} removeController ${source} true`);
      return true;
    }
    this.useCount.set(source, --count);
    LogUtil.info(`${TAG} removeController ${source} false: ${count}`);
    return false;
  }
}

export let controllerCounter = new ControllerCounter();
