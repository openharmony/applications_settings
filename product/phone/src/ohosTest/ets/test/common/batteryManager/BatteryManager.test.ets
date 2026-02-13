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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { BatteryManager } from '@ohos/settings.common/src/main/ets/batteryManager/BatteryManager'
import { common } from '@kit.AbilityKit';
import xPowerManager from '@hms.xpower';

export default function BatteryManagerTest() {
  describe('BatteryManagerTest', () => {
    let batteryManagerInstance = BatteryManager;
    it('BatteryManagerTest_getAppPowerDataFun', 0,async (done: Function) => {
      try {
        let context: Context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        let result = await batteryManagerInstance.getAppPowerDataFun(context);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('BatteryManagerTest_getAppPowerDataFunSync', 0, async (done: Function) => {
      try {
        let result = await batteryManagerInstance.getAppPowerDataFunSync();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done();
      }
    });

    it('BatteryManagerTest_getAppPowerDataFunSync_01', 0, async (done: Function) => {
      let params: xPowerManager.AppPowerDataReply =
        AppStorage.get<xPowerManager.AppPowerDataReply>('xPowerManager') as xPowerManager.AppPowerDataReply;
      try {
        let result = await batteryManagerInstance.getStatisticPower(params);
        expect(result !== null).assertTrue();
        let params2: xPowerManager.AppPowerDataReply = {
          appDatas: [],
          capacity: 0
        }
        let result2 = await batteryManagerInstance.getStatisticPower(params2);
        expect(result2 !== null).assertTrue();

        let paramsAppData = AppStorage.get<Array<xPowerManager.AppData>>('appDatas') as Array<xPowerManager.AppData>;
        let params3: xPowerManager.AppPowerDataReply = {
          capacity: 0,
          appDatas: paramsAppData
        }
        let result3 = await batteryManagerInstance.getStatisticPower(params3);
        expect(result3 !== null).assertTrue();

        let appDataParams: Array<xPowerManager.AppData> = [{
          timestamp: 1000,
          charge: 10,
          gasGauge: 100,
          appEnergies: []
        }];
        let params4: xPowerManager.AppPowerDataReply = {
          capacity: 0,
          appDatas: appDataParams,
        }
        let result4 = await batteryManagerInstance.getStatisticPower(params4);
        expect(result4 !== null).assertTrue();

        let appDatas: Array<xPowerManager.AppData> = [];
        let params5: xPowerManager.AppPowerDataReply = {
          capacity: 0,
          appDatas: appDatas,
        }
        let result5 = await batteryManagerInstance.getStatisticPower(params5);
        expect(result5 !== null).assertTrue();

      } catch (e) {
      } finally {
        done();
      }
    });

    it('BatteryManagerTest_getAppPowerData', 0, (done: Function) => {
      try {
        let appDataParams: Array<xPowerManager.AppData> = [{
          timestamp: 1000,
          charge: 10,
          gasGauge: 100,
          appEnergies: []
        }];
        let params: xPowerManager.AppPowerDataReply = {
          capacity: 0,
          appDatas: appDataParams,
        };
        let context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        let result = batteryManagerInstance.getAppPowerData(params, context);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done();
      }
    });

    it('BatteryManagerTest_disassemblesLineData', 0, (done: Function) => {
      try {
        let params: xPowerManager.AppData = {
          timestamp: 1000,
          charge: -1,
          gasGauge: -1,
          appEnergies: []
        };
        let result2 = batteryManagerInstance.disassemblesLineData(params, 0);
        expect(result2 !== null).assertTrue();

        let params2: xPowerManager.AppData = {
          timestamp: 1000,
          charge: -1,
          gasGauge: 10,
          appEnergies: []
        };
        let result3 = batteryManagerInstance.disassemblesLineData(params2, 10);
        expect(result3 !== null).assertTrue();

        let params3: xPowerManager.AppData = {
          timestamp: 1000,
          charge: -1,
          gasGauge: 10,
          appEnergies: []
        };
        let result4 = batteryManagerInstance.disassemblesLineData(params3, 1);
        expect(result4 !== null).assertTrue();

        let params4: xPowerManager.AppData = {
          timestamp: 1000,
          charge: 10,
          gasGauge: -1,
          appEnergies: []
        };
        let result5 = batteryManagerInstance.disassemblesLineData(params4, 100);
        expect(result5 !== null).assertTrue();
      } catch (e) {
      } finally {
        done();
      }
    });

    it('BatteryManagerTest_disassemblesPowerList', 0, (done: Function) => {
      try {
        let params: Array<xPowerManager.AppEnergy> = [{
          name: 'test',
          foregroundTime: 1,
          foregroundPower: 1,
          backgroundTime: 1,
          backgroundPower: 1,
          appType: 1
        }];
        let result = batteryManagerInstance.disassemblesPowerList(params, 10, 1000);
        expect(result !== null).assertTrue();

        let params2: Array<xPowerManager.AppEnergy> = [{
          name: 'test',
          foregroundTime: 1,
          foregroundPower: 1,
          backgroundTime: 1,
          backgroundPower: 1,
          appType: 1
        }];
        let result2 = batteryManagerInstance.disassemblesPowerList(params2, 0, 1000);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done();
      }
    });
  })
}