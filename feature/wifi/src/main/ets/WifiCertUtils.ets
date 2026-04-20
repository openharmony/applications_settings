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

import certManager from '@ohos.security.certManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'WifiCertUtils : ';

/**
 * Wifi cert工具类
 *
 * @since 2024-05-22
 */
export class WifiCertUtils {
  /**
   * 获取用户安装得CA证书
   */
  static async getAllUserTrustedCertificates(): Promise<certManager.CertAbstract[]> {
    LogUtil.info(`${TAG} certManager.getAllUserTrustedCertificates`);
    try {
      const cmResult = await certManager.getAllUserTrustedCertificates();
      return cmResult?.certList || [];
    } catch (error) {
      LogUtil.error(`${TAG} failed getAllUserTrustedCertificates code:${error?.code} message:${error?.message}`);
    }
    return [];
  }

  /**
   * 获取用户安装得用户凭据
   */
  static async getAllSystemAppCertificates(): Promise<certManager.CredentialAbstract[]> {
    LogUtil.info(`${TAG} certManager.getAllSystemAppCertificates`);
    try {
      const cmResult = await certManager.getAllSystemAppCertificates();
      return cmResult?.credentialList || [];
    } catch (error) {
      LogUtil.error(`${TAG} failed getAllSystemAppCertificates code:${error?.code} message:${error?.message}`);
    }
    return [];
  }
}