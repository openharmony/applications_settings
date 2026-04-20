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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import fs from '@ohos.file.fs';
import fileUri from "@ohos.file.fileuri";
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import wifiManager from '@ohos.wifiManager';
import { hmShareDataManager } from '@ohos/settings.wifi/src/main/ets/HarmonyShareDataManager';

export default function HarmonyShareDataManagerTest() {
  describe('HarmonyShareDataManagerTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    //undefined的uri
    it('processShareWifi_01', 0, () => {
      let uri: string | undefined;
      hmShareDataManager.processShareWifi(uri);
      expect(uri).assertUndefined();
    })
    //错误的uri
    it('processShareWifi_02', 0, () => {
      let uri: string = 'a';
      hmShareDataManager.processShareWifi(uri);
      expect(uri).assertEqual('a');
    })
    //文件内容为空的uri
    it('processShareWifi_03', 0, () => {
      let context = AppStorage.get<Context>('pageContext') as Context;
      let pathInSandbox = context.filesDir + '/share.hmoswifi';
      let file = fs.openSync(pathInSandbox, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.closeSync(file);
      let uri: string = fileUri.getUriFromPath(pathInSandbox);
      hmShareDataManager.processShareWifi(uri);
      fs.unlinkSync(pathInSandbox);
      expect(uri).assertContain('file')
    })
    //文件内容正常的uri
    it('processShareWifi_04', 0, async () => {
      let context = AppStorage.get<Context>('pageContext') as Context;
      let pathInSandbox = context.filesDir + '/share.hmoswifi';
      let file = fs.openSync(pathInSandbox, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      try {
        fs.writeSync(file.fd,
          `WIFI:T:WPA;S:abcdefghi;P:12345678;;`);
      } catch (error) {
      } finally {
        fs.closeSync(file);
      }
      let uri: string = fileUri.getUriFromPath(pathInSandbox);
      await hmShareDataManager.processShareWifi(uri);
      fs.unlinkSync(pathInSandbox);
      expect(uri).assertContain('file')
    })

    // 文件内容加\:\;的uri
    it('processShareWifi_05', 0, async () => {
      let context = AppStorage.get<Context>('pageContext') as Context;
      let pathInSandbox = context.filesDir + '/share.hmoswifi';
      let file = fs.openSync(pathInSandbox, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      try {
        fs.writeSync(file.fd,
          `WIFI:T:WPA;S:abcde\\:\\;fghi;P:12345678;;`);
      } catch (error) {
      } finally {
        fs.closeSync(file);
      }
      let uri: string = fileUri.getUriFromPath(pathInSandbox);
      await hmShareDataManager.processShareWifi(uri);
      fs.unlinkSync(pathInSandbox);
      expect(uri).assertContain('file')
    })
    //文件内容ssid为空字符串 的uri
    it('processShareWifi_06', 0, async () => {
      let context = AppStorage.get<Context>('pageContext') as Context;
      let pathInSandbox = context.filesDir + '/share.hmoswifi';
      let file = fs.openSync(pathInSandbox, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      try {
        fs.writeSync(file.fd,
          `WIFI:T:WPA;S:;P:12345678;;`);
      } catch (error) {
      } finally {
        fs.closeSync(file);
      }
      let uri: string = fileUri.getUriFromPath(pathInSandbox);
      await hmShareDataManager.processShareWifi(uri);
      fs.unlinkSync(pathInSandbox);
      expect(uri).assertContain('file')
    })
    //文件内容与已连接的wifi相同
    it('processShareWifi_07', 0, async () => {
      let context = AppStorage.get<Context>('pageContext') as Context;
      let pathInSandbox = context.filesDir + '/share.hmoswifi';
      let file = fs.openSync(pathInSandbox, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      try {
        fs.writeSync(file.fd,
          `WIFI:T:WPA;S:abcdefghi;P:12345678;;`);
      } catch (error) {
      } finally {
        fs.closeSync(file);
      }
      let uri: string = fileUri.getUriFromPath(pathInSandbox);

      let mocker: MockKit = new MockKit();
      let func_1: Function = mocker.mockFunc(WifiUtils, WifiUtils.getConnectConfig);
      when(func_1)().afterReturn({
        ssid: 'abcdefghi',
        preSharedKey: '12345678',
        securityType: 3,
      } as wifiManager.WifiDeviceConfig);
      await hmShareDataManager.processShareWifi(uri);
      mocker.clear(WifiUtils);
      fs.unlinkSync(pathInSandbox);
      expect(uri).assertContain('file')
    })
  })
}