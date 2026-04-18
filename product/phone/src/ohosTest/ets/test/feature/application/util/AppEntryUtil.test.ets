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

import { describe, expect, it } from '@ohos/hypium';
import { AppEntry, AppType } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppEntryUtil, sortEntryByName } from '@ohos/settings.application/src/main/ets/util/AppEntryUtil';
import { AppInfoModel } from '@ohos/settings.common/src/main/ets/data/AppInfoDataType';

export default function AppEntryUtilTest() {
  describe('AppEntryUtilTest', (): void => {
    it('AppEntryUtilTest_001', 0, (done: Function) => {
      // 测试buildFromAppInfoEntry方法
      try {
        let appInfo: AppInfoModel = {
          bundleName: 'bundleName',
          appInfoName: 'infoName',
          versionName: '001',
          updateTime: 123
        };
        let appEntry: AppEntry = AppEntryUtil.buildFromAppInfoEntry(appInfo);
        expect(appEntry !== null).assertTrue();
        expect(appEntry.appInfo !== null).assertTrue();
        expect(appEntry.name).assertEqual('bundleName');
        expect(appEntry.appInfo?.name).assertEqual('infoName');
        expect(appEntry.versionName).assertEqual('001');
        expect(appEntry.updateTime).assertEqual(123);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppEntryUtilTest_002', 0, async (done: Function) => {
      // 测试transferSingleEntryToInfo方法
      try {
        let appEntry: AppEntry = new AppEntry();
        appEntry.name = 'test';
        appEntry.versionName = '001';
        appEntry.updateTime = 123;
        let appInfo: AppInfoModel = await AppEntryUtil.transferSingleEntryToInfo(appEntry);
        expect(appInfo !== null).assertTrue();
        expect(appInfo.bundleName).assertEqual('test');
        expect(appInfo.versionName).assertEqual('001');
        expect(appInfo.updateTime).assertEqual(123);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppEntryUtilTest_003', 0, async (done: Function) => {
      // 测试transferEntryListToInfo方法
      try {
        let appEntry1: AppEntry = new AppEntry();
        appEntry1.name = 'test01';
        appEntry1.versionName = '001';
        appEntry1.updateTime = 123;
        let appEntry2: AppEntry = new AppEntry();
        appEntry2.name = 'test02';
        appEntry2.versionName = '002';
        appEntry2.updateTime = 234;
        let appEntries: AppEntry[] = [];
        appEntries.push(appEntry1);
        appEntries.push(appEntry2);
        let appInfos: AppInfoModel[] = await AppEntryUtil.transferEntryListToInfo(appEntries);
        expect(appInfos !== null).assertTrue();
        expect(appInfos.length).assertEqual(2);
        expect(appInfos[0]?.bundleName).assertEqual('test01');
        expect(appInfos[1]?.bundleName).assertEqual('test02');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppEntryUtilTest_004', 0, (done: Function) => {
      // 测试getEntryAppType方法
      try {
        let appInfo: AppInfoModel = {
          bundleName: 'bundleName',
          appInfoName: 'infoName',
          versionName: '001',
          updateTime: 123,
          bundleType: 1
        };
        let type: AppType = AppEntryUtil.getEntryAppType(appInfo);
        expect(type).assertEqual(AppType.SERVICE_APP);

        appInfo.bundleType = 2;
        type = AppEntryUtil.getEntryAppType(appInfo);
        expect(type).assertEqual(AppType.UNKNOWN_TYPE);

        appInfo.bundleType = 0;
        appInfo.codePath = '/aa/bb';
        appInfo.systemApp = true;
        type = AppEntryUtil.getEntryAppType(appInfo);
        expect(type).assertEqual(AppType.SYSTEM_APP);

        appInfo.systemApp = false;
        type = AppEntryUtil.getEntryAppType(appInfo);
        expect(type).assertEqual(AppType.UN_SYSTEM_APP);

        appInfo.bundleType = 0;
        appInfo.codePath = '';
        type = AppEntryUtil.getEntryAppType(appInfo);
        expect(type).assertEqual(AppType.CONTAINER_APP);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppEntryUtilTest_005', 0, (done: Function) => {
      // 测试sortEntryByName方法，英文
      try {
        let appInfo1: AppInfoModel = {
          bundleName: 'bundleNameB',
          versionName: '002',
          label: 'B_Hap',
          updateTime: 123
        };
        let appInfo2: AppInfoModel = {
          bundleName: 'bundleNameA',
          versionName: '001',
          label: 'A_Hap',
          updateTime: 123
        };
        let appInfos: AppInfoModel[] = [];
        appInfos.push(appInfo1);
        appInfos.push(appInfo2);
        let sortedAppInfos: AppInfoModel[] = sortEntryByName(appInfos);
        expect(sortedAppInfos !== null).assertTrue();
        expect(sortedAppInfos.length).assertEqual(2);
        expect(sortedAppInfos[0]?.bundleName).assertEqual('bundleNameA');
        expect(sortedAppInfos[1]?.bundleName).assertEqual('bundleNameB');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('AppEntryUtilTest_006', 0, (done: Function) => {
      // 测试sortEntryByName方法，中文
      try {
        let appInfo1: AppInfoModel = {
          bundleName: 'ToadyNews',
          versionName: '002',
          label: '今日头条',
          updateTime: 123
        };
        let appInfo2: AppInfoModel = {
          bundleName: 'DouYin',
          versionName: '001',
          label: '抖音',
          updateTime: 123
        };
        let appInfos: AppInfoModel[] = [];
        appInfos.push(appInfo1);
        appInfos.push(appInfo2);
        let sortedAppInfos: AppInfoModel[] = sortEntryByName(appInfos);
        expect(sortedAppInfos !== null).assertTrue();
        expect(sortedAppInfos.length).assertEqual(2);
        expect(sortedAppInfos[0]?.bundleName).assertEqual('DouYin');
        expect(sortedAppInfos[1]?.bundleName).assertEqual('ToadyNews');
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}

