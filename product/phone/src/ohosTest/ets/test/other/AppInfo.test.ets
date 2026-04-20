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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { AppInfo } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/model/AppInfo';

export default function appInfoTest() {
  describe('appInfoTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('AppInfoTest_constructor', 0, () => {
      let appInfo: AppInfo = new AppInfo('name', 'label', 'filePath');
      expect(appInfo.getPkgName()).assertEqual('name');
      expect(appInfo.getLicenseFilePath()).assertEqual('filePath');
    })

    it('setPkgName', 0, () => {
      let appInfo = new AppInfo('test', 'label', 'licenseFilePath');
      expect(appInfo.getPkgName()).assertEqual('test');
      appInfo.setPkgName("test1");
      expect(appInfo.getPkgName()).assertEqual('test1');
    })

    it('AppInfoTest_getPkgName', 0, () => {
      let appInfo = new AppInfo('name', 'label', 'filePath');
      appInfo.setPkgName('pkgName');
      let result = appInfo.getPkgName();
      expect(result).assertEqual('pkgName');
    })

    it('AppInfoTest_setLabel', 0, () => {
      let appInfo = new AppInfo('a', 'b', 'c');
      appInfo.setLabel('d');
      expect(appInfo.label).assertEqual('d');
    })

    it('AppInfoTest_setLicenseFilePath', 0, () => {
      let appInfo = new AppInfo("", "", "");
      appInfo.setLicenseFilePath("licenseFilePath")
      expect(appInfo.getLicenseFilePath()).assertEqual("licenseFilePath")
    })

    it('AboutServiceTest_getLicenseFilePath', 0, () => {
      let appInfo = new AppInfo("", "", "")
      appInfo.setLicenseFilePath("licenseFilePath")
      let licenseFilePath = appInfo.getLicenseFilePath();
      expect(licenseFilePath).assertEqual('licenseFilePath')
    })

    it('AboutServiceTest_getLicenseFilePath2', 0, () => {
      let appInfo = new AppInfo('', 'two', 'three');
      let licenseFilePath = appInfo.getLicenseFilePath();
      expect(licenseFilePath).assertEqual('three');
    })

    it('AboutServiceTest_getLicenseFilePath3', 0, () => {
      let appInfo = new AppInfo('', '', 'one');
      let licenseFilePath = appInfo.getLicenseFilePath();
      expect(licenseFilePath).assertEqual('one');
    })

    it('AboutServiceTest_getPkgName2', 0, () => {
      let appInfo = new AppInfo('pkg_one', '', '');
      let packageName = appInfo.getPkgName();
      expect(packageName).assertEqual('pkg_one');
    })

    it('AboutServiceTest_getPkgName3', 0, () => {
      let appInfo = new AppInfo('pkg_one', 'lable_one', '');
      let packageName = appInfo.getPkgName();
      expect(packageName).assertEqual('pkg_one');
    })
  })
}

