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
import { SettingsPerformanceDfx } from './SettingsPerformanceDfx'
import { pagePathMap } from './Consts'
import { LogUtil } from './LogUtil';
import { Params } from '../core/controller/Controller';

/**
 * 动态加载回调类，用于回调页面加载接口
 * 同时集成部分DFX功能: 页面转场时延，页面加载失败 DFX事件report
 *
 * @since 2023-08-16
 */
export class DynamicLoader {
  public tag: string = 'DynamicLoader: ';
  public dynamicLoaderCB: ((key: string) => Promise<boolean>) | null = null;
  public loaderMap: Map<String, ($$: Params) => void> = new Map<String, ($$: Params) => void>();
  private static instance: DynamicLoader | null = null;
  // dfx global pointer
  private dfx: SettingsPerformanceDfx | null = null;

  constructor() {
    this.dfx = SettingsPerformanceDfx.getInstance();
  }

  // use late when both let & import support constant string variable.
  getImportPath(key: string): string {
    return pagePathMap.get(key) as string;
  }

  register(loaderCallback: (key: string) => Promise<boolean>): void {
    this.dynamicLoaderCB = loaderCallback;
  }

  async fire(key: string): Promise<boolean> {
    this.dfx?.setPageTransitionStart();
    // reformat, Dynamic load not supported on PC/PAD.
    if (this.dynamicLoaderCB === null) {
      return true;
    }
    let value = await this.dynamicLoaderCB(key);

    if (!value) {
      this.dfx?.reportLoadFailureEvent(key, this.getImportPath(key));
      LogUtil.error(`${this.tag} Page Load Failure: key:  ${key}`);
    } else {
      LogUtil.info(`${this.tag} Page Load success: key: ${key} path: ${this.getImportPath(key)}`);
    }
    return value;
  }

  pageTransitionSuccess(pageName: string): void {
    LogUtil.info(`${this.tag}  Page transition to: ${pageName}`);
    this.dfx?.dumpPageTransitionTime(pageName);
  }

  public static getInstance(): DynamicLoader {
    if (DynamicLoader.instance === null) {
      LogUtil.info(`create DynamicLoader instance`);
      DynamicLoader.instance = new DynamicLoader();
      DynamicLoader.instance.dfx?.setPageTransitionStart();
    }
    return DynamicLoader.instance;
  }
}