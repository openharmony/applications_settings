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

import PluginMgr from '@ohos.pluginComponent';
import { LogUtil } from './LogUtil';

/**
 * 用于给插件组件的使用者请求组件与数据，使用者发送组件模板和数据
 */
export class PluginComponentUtil {
  /**
   * 组件提供者向组件使用者主动发送组件与数据
   *
   * @param ownerBundleName 组件提供方Ability信息
   * @param wantBundleName 组件使用者Ability信息
   * @param name 组件名称
   * @param isCloseWindow 是否请求关闭弹框
   */
  static pushPluginAndData(ownerBundleName: string, wantBundleName: string,
                           name: string, isCloseWindow: boolean): void {
    LogUtil.info('pushPluginAndData, name: ${name}');
    PluginMgr.push({
      owner: {
        bundleName: ownerBundleName
      },
      // 自身包名
      target: {
        bundleName: wantBundleName
      },
      // 模板名，与配置json串中pluginTemplateName字段保持一致
      name: name,
      data: {},
      // 额外数据，请求关闭弹窗
      extraData: {
        requestCloseWindow: isCloseWindow
      }
    }, () => {
      LogUtil.info(`Close window complete`);
    });
  }
}