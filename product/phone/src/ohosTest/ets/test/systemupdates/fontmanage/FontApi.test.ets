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

import { describe, expect, it, TestType } from '@ohos/hypium'
import { FontApiRetCode } from '@ohos/settings.font-manager/src/main/ets/controller/FontApi';

export default function FontApiTest() {
  enum FontInstallRetCode {
    SUCCESS = 0,
    FILE_VERIFY_FAIL = 31100102,
    INSTALLED_ALREADY = 31100104,
    MAX_FILE_COUNT = 31100105,
    INSTALL_FAIL = 31100106
  }

  enum FontUninstallRetCode {
    SUCCESS = 0,
    UNINSTALL_FILE_NOT_EXISTS = 31100107,
    UNINSTALL_REMOVE_FAIL = 31100108,
    UNINSTALL_FAIL = 31100109
  }

  describe('FontApiTest', () => {
    /**
     * 安装接口返回值相关用例
     */
    it('FontApiTest_000', TestType.FUNCTION, async () => {
      let ns: ESObject = await import('@ohos/settings.font-manager/src/main/ets/controller/FontApi');
      // success
      let successRes: number = ns.FontApi.processInstallResult(FontInstallRetCode.SUCCESS);
      expect(FontApiRetCode.SUCCESS).assertEqual(successRes);
      // verifyFail
      let verifyFailRes: number = ns.FontApi.processInstallResult(FontInstallRetCode.FILE_VERIFY_FAIL);
      expect(FontApiRetCode.FILE_VERIFY_FAIL).assertEqual(verifyFailRes);
      // installedAlready
      let installedAlreadyRes: number = ns.FontApi.processInstallResult(FontInstallRetCode.INSTALLED_ALREADY);
      expect(FontApiRetCode.INSTALLED_ALREADY).assertEqual(installedAlreadyRes);
      // maxFileCount
      let maxFileCountRes: number = ns.FontApi.processInstallResult(FontInstallRetCode.MAX_FILE_COUNT);
      expect(FontApiRetCode.MAX_FILE_COUNT).assertEqual(maxFileCountRes);
      // installFail
      let installFailRes: number = ns.FontApi.processInstallResult(FontInstallRetCode.INSTALL_FAIL);
      expect(FontApiRetCode.INSTALL_FAIL).assertEqual(installFailRes);
      // default
      let defaultRes: number = ns.FontApi.processInstallResult(123456);
      expect(FontApiRetCode.INSTALL_FAIL).assertEqual(defaultRes);
    });

    /**
     * 卸载接口返回值相关用例
     */
    it('FontApiTest_001', TestType.FUNCTION, async () => {
      let ns: ESObject = await import('@ohos/settings.font-manager/src/main/ets/controller/FontApi');
      // success
      let successRes: number = ns.FontApi.processUninstallResult(FontUninstallRetCode.SUCCESS);
      expect(FontApiRetCode.SUCCESS).assertEqual(successRes);
      // uninstallFileNotExists
      let uninstallFileNotExistslRes: number = ns.FontApi.processUninstallResult(FontUninstallRetCode.UNINSTALL_FILE_NOT_EXISTS);
      expect(FontApiRetCode.SUCCESS).assertEqual(uninstallFileNotExistslRes);
      // uninstallRemoveFail
      let uninstallRemoveFailRes: number = ns.FontApi.processUninstallResult(FontUninstallRetCode.UNINSTALL_REMOVE_FAIL);
      expect(FontApiRetCode.UNINSTALL_FAIL).assertEqual(uninstallRemoveFailRes);
      // uninstallFail
      let uninstallFailRes: number = ns.FontApi.processUninstallResult(FontUninstallRetCode.UNINSTALL_FAIL);
      expect(FontApiRetCode.UNINSTALL_FAIL).assertEqual(uninstallFailRes);
      // default
      let defaultRes: number = ns.FontApi.processUninstallResult(123456);
      expect(FontApiRetCode.UNINSTALL_FAIL).assertEqual(defaultRes);
    });
  });

}