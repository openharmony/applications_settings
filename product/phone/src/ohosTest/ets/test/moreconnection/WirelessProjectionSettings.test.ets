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
// import { describe, it, beforeAll, afterAll } from '@ohos/hypium';
// import { Driver, ON } from '@ohos.UiTest';
// import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
// import { LogUtil, NavEntryKey } from '@ohos/settings.common';
// import { COMMON_DELAY, WAIT_DELAY } from '../types';
// import { Constant } from '../constant/Constant';
//
// const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
// const TAG: string = 'ProjectionSettingsTest';
//
// export default function ProjectionSettingsTest() {
//   describe('ProjectionSettingsTest', ()=> {
//     beforeAll(async ()=> {
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': Constant.SETTINGS_BUNDLE_NAME,
//           'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
//           'uri': NavEntryKey.WIRELESS_PROJECTION_ENTRY,
//         }).then(() => {
//           LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
//         });
//       } catch (exception) {
//         LogUtil.error(`Failed to startAbility. Code: ${exception.code}, message: ${exception.message}`);
//       };
//     });
//
//     afterAll(async () => {
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       await dr.pressHome();
//       await dr.delayMs(COMMON_DELAY);
//     });
//
//     it('ProjectionSettingsTest_001', 0, async ()=> {
//       LogUtil.info(`${TAG} ProjectionSettingsTest_001 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 点击无线投屏进入无线投屏页面
//       let WirelessProjection = await dr.waitForComponent(ON.text(Constant.WIRELESS_PROJECTION), WAIT_DELAY);
//       await WirelessProjection.click();
//       LogUtil.info(`${TAG} ProjectionSettingsTest_001 clicked`);
//       await dr.delayMs(COMMON_DELAY);
//       await dr.assertComponentExist(ON.text(Constant.WIRELESS_PROJECTION));
//       // 点击返回按钮到更多连接页面
//       await dr.delayMs(COMMON_DELAY);
//       await dr.pressBack();
//       await dr.delayMs(COMMON_DELAY);
//       await dr.assertComponentExist(ON.text(Constant.MORE_CONNECTION));
//       await dr.delayMs(COMMON_DELAY);
//       await dr.assertComponentExist(ON.text(Constant.MORE_CONNECTION_SWITCH_OFF));
//     });
//   });
// }