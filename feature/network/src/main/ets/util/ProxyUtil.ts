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

/* instrument ignore file */
import type { AsyncCallback } from '@ohos.base';
import connection from '@ohos.net.connection';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'ProxyUtil : ';

export class ProxyUtil {
  /**
   * 从系统查询代理是否启用了
   */
  public static getGlobalHttpProxyInfo(): Promise<connection.HttpProxy> {
    return connection.getGlobalHttpProxy();
  }

  /**
   * 获取全局代理设置信息
   */
  public static setGlobalHttpProxy(httpProxy: connection.HttpProxy, callback: AsyncCallback<void>): void {
    LogUtil.info(`${TAG} setGlobalHttpProxy`);
    return connection.setGlobalHttpProxy(httpProxy, callback);
  }

  /**
   * 设定全局代理配置
   */
  public static isHttpProxyEnabled(cb: (boolean: boolean) => void): void {
    connection.getGlobalHttpProxy((error, data) => {
      LogUtil.info(`${TAG} Query http proxy cfg result: ${data.host !== ''}`);
      cb(data.host !== '');
      if (error) {
        LogUtil.error(`${TAG} getGlobalHttpProxy error: ${error.code}`);
      }
    });
  }
}
