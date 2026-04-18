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
import { AppInfoDataSource } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/model/AppInfoDataSource';

export default function appInfoDataSourceTest() {
  describe('appInfoDataSourceTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('AppInfoDataSourceTest_constructor', 0, () => {
      let appInfoList: Array<AppInfo> = [];
      let appInfoDataSource = new AppInfoDataSource(appInfoList);
      expect(appInfoDataSource.appInfoList).assertEqual(appInfoList);
    })

    it('AppInfoDataSourceTest_totalCount', 0, () => {
      let appInfoList: Array<AppInfo> = []
      let appInfoDataSource = new AppInfoDataSource(appInfoList)
      let result = appInfoDataSource.totalCount()
      expect(result).assertEqual(0)
    })

    it('AppInfoDataSourceTest_pushDataList', 0, () => {
      let appInfo: AppInfo = new AppInfo('a', 'b', 'c')
      let appInfoList: AppInfo[] = []
      appInfoList.push(appInfo)
      let AppInfoDataSource1 = new AppInfoDataSource(appInfoList)
      AppInfoDataSource1.pushDataList(appInfoList)
      expect(AppInfoDataSource1.appInfoList).assertEqual(appInfoList)
    })

  })
}

