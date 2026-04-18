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
//
// import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium';
// import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
// import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
// import { BusinessError } from '@ohos.base';
// import { Driver, ON } from '@ohos.UiTest';
// import { Constant } from '../../constant/Constant';
// import { COMMON_DELAY, WAIT_DELAY } from '../../types';
// import { WifiBaseConfigManager } from '@ohos/settings.wifi'
//
// const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
// const TAG: string = 'ConnectDetailsWlan';
// enum WlanDisconnectedReason {
//   FAILEDDEFAULT = 0,
//   WRONGPWD = 1,
//   FAILEDCONNECTIONFULL = 2,
//   DISC_REASON_CONNECTION_REJECTED = 3,
//   DISC_REASON_IGNORE = 4,
// };
//
// export default function ConnectDetailsWlan() {
//   describe('ConnectDetailsWlan', () => {
//     LogUtil.info(`${TAG} describe start`);
//     beforeAll(async () => {
//       DELEGATOR.startAbility({
//         bundleName: Constant.SETTINGS_BUNDLE_NAME,
//         abilityName: Constant.SETTINGS_MAIN_ABILITY_NAME,
//       }).then(() => {
//         LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
//       }).catch((exception: BusinessError) => {
//         LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}`);
//       });
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 点击设置中的wlan入口
//       let wlanTab = await dr.waitForComponent(ON.text(Constant.WIFI), WAIT_DELAY);
//       await wlanTab.click();
//       await dr.delayMs(COMMON_DELAY);
//       LogUtil.info(`${TAG} wlanTab clicked`);
//       // 点击WLAN页面的WIFI开关
//       LogUtil.info(`${TAG} wlanSwitch clicked`);
//       LogUtil.info(`${TAG} describe end`);
//     });
//     /**
//      * 进入wif连接页面.
//      */
//     beforeEach(async () => {
//       LogUtil.info(`${TAG} beforeEach start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       await dr.click(675, 928)
//       LogUtil.info(`${TAG} beforeEach clicked`);
//     });
//
//     it('convertString2Number', 0, () => {
//       let result: number = WifiBaseConfigManager.convertString2Number(undefined);
//       expect(result === Number.NaN)
//     })
//
//     it('getDisconnectedReasonMessage0', 0, () => {
//       let result: ResourceStr = WifiBaseConfigManager.getDisconnectedReasonMessage(WlanDisconnectedReason.FAILEDDEFAULT);
//       expect(result === $r('app.string.wifi_status_failed_default'))
//     })
//
//     it('getDisconnectedReasonMessage1', 0, () => {
//       let result: ResourceStr = WifiBaseConfigManager.getDisconnectedReasonMessage(WlanDisconnectedReason.WRONGPWD);
//       expect(result === $r('app.string.wifi_status_wrong_pwd'))
//     })
//
//     it('getDisconnectedReasonMessage2', 0, () => {
//       let result: ResourceStr = WifiBaseConfigManager.getDisconnectedReasonMessage(WlanDisconnectedReason.FAILEDCONNECTIONFULL);
//       expect(result === $r('app.string.wifi_status_failed_connection_full'))
//     })
//
//     it('getDisconnectedReasonMessage3', 0, () => {
//       let result: ResourceStr = WifiBaseConfigManager.getDisconnectedReasonMessage(WlanDisconnectedReason.FAILEDDEFAULT);
//       expect(result === $r('app.string.wifi_status_failed_default'))
//     });
//
//     it('getDisconnectedReasonMessage4', 0, () => {
//       let result: ResourceStr = WifiBaseConfigManager.getDisconnectedReasonMessage(WlanDisconnectedReason.DISC_REASON_CONNECTION_REJECTED);
//       expect(result === $r('app.string.wifi_status_failed_rejected'))
//     });
//
//     afterEach(async () => {
//       LogUtil.info(`${TAG} afterEach start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 检验wlan是否连接成功
//       let connectTab = await dr.waitForComponent(ON.text(Constant.WIFI_STATUS_CONNECTED), WAIT_DELAY);
//       if (!connectTab) {
//         LogUtil.info(`${TAG} no connect wlan`);
//         // 返回wlan列表
//         let wlanBackIcon = await dr.waitForComponent(ON.id(Constant.WIFI_CANCEL_BUTTON_ID), WAIT_DELAY);
//         await wlanBackIcon.click();
//         await dr.assertComponentExist(ON.id(Constant.WIFI_SWITCH_ID));
//         LogUtil.info(`${TAG} backto wlanlist`);
//         return;
//       }
//       // 点击已连接热点
//       let wifiTab = await dr.waitForComponent(ON.text(Constant.WIFI_CONNECT_EAP_NAME), WAIT_DELAY);
//       await wifiTab.click();
//       // 删除热点
//       let deleteTab = await dr.waitForComponent(ON.id(Constant.CONNECT_WIFI_DELETE_ID), WAIT_DELAY);
//       await deleteTab.click();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验删除成功
//       expect(connectTab).assertNull();
//       LogUtil.info(`${TAG} afterEach clicked`);
//     });
//     afterAll(async () => {
//       LogUtil.info(`${TAG} afterAll start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 点击返回按钮到设置页面
//       let wlanBackIcon = await dr.waitForComponent(ON.id(Constant.WIFI_CANCEL_BUTTON_ID), WAIT_DELAY);
//       await wlanBackIcon.click();
//       await dr.assertComponentExist(ON.text(Constant.SETTINGS));
//       LogUtil.info(`${TAG} afterAll end`);
//     });
//   });
// }