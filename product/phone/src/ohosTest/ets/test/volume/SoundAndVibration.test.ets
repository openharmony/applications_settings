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
// import { LogUtil } from '@ohos/settings.common/index';
// import { BusinessError } from '@ohos.base';
// import { COMMON_DELAY, WAIT_DELAY, SWIPE_DELAY } from '../types';
// import { Constant } from '../constant/Constant';
// import sim from '@ohos.telephony.sim';
//
// const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
//
// export default function soundAndVibrationTest() {
//   describe('soundAndVibrationTest', () => {
//     // 定义Driver类
//     let dr: Driver | null = null;
//     beforeAll(async () => {
//       dr = Driver?.create();
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': Constant.SETTINGS_BUNDLE_NAME,
//           'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
//           'uri': 'volume_settings',
//         }).then(() => {
//           LogUtil.info(`${Constant.TAG} volume_settings start success`);
//         });
//       } catch (exception) {
//         LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
//       }
//       ;
//       await dr.delayMs(COMMON_DELAY);
//     })
//     ;
//
//     afterAll(async () => {
//       // 定义Driver类
//       let dr = Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       await dr.pressHome();
//       await dr.delayMs(COMMON_DELAY);
//     });
//
//     /*
//     * @tc.number:soundAndVibrationTest_001
//     * @tc.name: 来电铃声切换测试
//     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
//     * @tc.desc: 来电铃声切换
//     */
//     it('soundAndVibrationTest_001', 0, async () => {
//       LogUtil.info(`${Constant.TAG} soundAndVibrationTest_001 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验来电铃声存在，并点击
//       await dr.assertComponentExist(ON.text('来电铃声'));
//       let ringTone = await dr.waitForComponent(ON.text('来电铃声'), WAIT_DELAY);
//       await ringTone.click();
//       // 先判断SIM卡的数量
//       if (sim.getMaxSimCount() === 2) {
//         // 卡1-随机选择铃声切换
//         let bell_001 = await dr.waitForComponent(ON.text('Amusement Park'), COMMON_DELAY);
//         await bell_001.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_002 = await dr.waitForComponent(ON.text('Breathe Freely'), COMMON_DELAY);
//         await bell_002.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_003 = await dr.waitForComponent(ON.text('Concentrate'), COMMON_DELAY);
//         await bell_003.click();
//         await dr.delayMs(COMMON_DELAY);
//         // list下拉滑动条随机选择铃声
//         await dr.swipe(628, 2000, 616, 1321, 600);
//         let bell_004 = await dr.waitForComponent(ON.text('Dream It Possible'), COMMON_DELAY);
//         await bell_004.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_005 = await dr.waitForComponent(ON.text('Free Rafting'), COMMON_DELAY);
//         await bell_005.click();
//         await dr.delayMs(COMMON_DELAY);
//         // 返回上一页
//         let wifiBackIcon1 = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//         await wifiBackIcon1.click();
//         await dr.assertComponentExist(ON.text('Free Rafting'));
//         await ringTone.click();
//
//         // 卡2-随机选择铃声切换
//         let card2 = await dr.waitForComponent(ON.text('卡2'), WAIT_DELAY);
//         await card2.click();
//         let bell2_001 = await dr.waitForComponent(ON.text('Amusement Park'), COMMON_DELAY);
//         await bell2_001.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell2_002 = await dr.waitForComponent(ON.text('Breathe Freely'), COMMON_DELAY);
//         await bell2_002.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell2_003 = await dr.waitForComponent(ON.text('Concentrate'), COMMON_DELAY);
//         await bell2_003.click();
//         await dr.delayMs(COMMON_DELAY);
//         // list下拉滑动条随机选择铃声
//         await dr.swipe(645, 2213, 637, 1544, 600);
//         let bell2_004 = await dr.waitForComponent(ON.text('Dream It Possible'), COMMON_DELAY);
//         await bell2_004.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell2_005 = await dr.waitForComponent(ON.text('Free'), COMMON_DELAY);
//         await bell2_005.click();
//         LogUtil.info(`${Constant.TAG} soundAndVibrationTest_001 end`);
//         // 返回上一页
//         let wifiBackIcon2 = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//         await wifiBackIcon2.click();
//         await dr.assertComponentExist(ON.text('Free'));
//         LogUtil.info(`${Constant.TAG} soundAndVibrationTest_001 end`);
//       } else {
//         // 只有卡1随机选择铃声切换
//         let bell_001 = await dr.waitForComponent(ON.text('Amusement Park'), COMMON_DELAY);
//         await bell_001.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_002 = await dr.waitForComponent(ON.text('Breathe Freely'), COMMON_DELAY);
//         await bell_002.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_003 = await dr.waitForComponent(ON.text('Concentrate'), COMMON_DELAY);
//         await bell_003.click();
//         await dr.delayMs(COMMON_DELAY);
//         // list下拉滑动条随机选择铃声
//         await dr.swipe(628, 2000, 616, 1321, 600);
//         let bell_004 = await dr.waitForComponent(ON.text('Dream It Possible'), COMMON_DELAY);
//         await bell_004.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_005 = await dr.waitForComponent(ON.text('Free Rafting'), COMMON_DELAY);
//         await bell_005.click();
//         await dr.delayMs(COMMON_DELAY);
//         // 返回上一页
//         let wifiBackIcon = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//         await wifiBackIcon.click();
//         await dr.assertComponentExist(ON.text('Free Rafting'));
//         await ringTone.click();
//       }
//     });
//
//     /*
//     * @tc.number:soundAndVibrationTest_002
//     * @tc.name: 信息铃声切换测试
//     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
//     * @tc.desc: 信息铃声切换
//     */
//     it('soundAndVibrationTest_002', 0, async () => {
//       LogUtil.info(`${Constant.TAG} soundAndVibrationTest_002 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验信息铃声存在，并点击
//       await dr.assertComponentExist(ON.text('信息铃声'));
//       let messageTone = await dr.waitForComponent(ON.text('信息铃声'), COMMON_DELAY);
//       await messageTone.click();
//       // 先判断SIM卡的数量
//       if (sim.getMaxSimCount() === 2) {
//         // 卡1-随机选择铃声切换
//         let bell_001 = await dr.waitForComponent(ON.text('Bell'), COMMON_DELAY);
//         await bell_001.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_002 = await dr.waitForComponent(ON.text('Breeze'), COMMON_DELAY);
//         await bell_002.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_003 = await dr.waitForComponent(ON.text('Chess'), COMMON_DELAY);
//         await bell_003.click();
//         await dr.delayMs(COMMON_DELAY);
//         // list下拉滑动条随机选择铃声
//         await dr.swipe(671, 2575, 620, 1548, 600);
//         let bell_004 = await dr.waitForComponent(ON.text('Fountain'), COMMON_DELAY);
//         await bell_004.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_005 = await dr.waitForComponent(ON.text('Freeze'), COMMON_DELAY);
//         await bell_005.click();
//         await dr.delayMs(COMMON_DELAY);
//         // 返回上一页
//         let wifiBackIcon1 = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//         await wifiBackIcon1.click();
//         await dr.assertComponentExist(ON.text('Freeze'));
//         messageTone = await dr.waitForComponent(ON.text('信息铃声'), COMMON_DELAY);
//         await messageTone.click();
//
//         // 卡2-随机选择铃声切换
//         let card2 = await dr.waitForComponent(ON.text('卡2'), WAIT_DELAY);
//         await card2.click();
//         let bell2_001 = await dr.waitForComponent(ON.text('Bell'), COMMON_DELAY);
//         await bell2_001.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell2_002 = await dr.waitForComponent(ON.text('Breeze'), COMMON_DELAY);
//         await bell2_002.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell2_003 = await dr.waitForComponent(ON.text('Chess'), COMMON_DELAY);
//         await bell2_003.click();
//         await dr.delayMs(COMMON_DELAY);
//         // list下拉滑动条随机选择铃声
//         await dr.swipe(671, 2575, 620, 1548, 600);
//         let bell2_004 = await dr.waitForComponent(ON.text('Fountain'), COMMON_DELAY);
//         await bell2_004.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell2_005 = await dr.waitForComponent(ON.text('Drip'), COMMON_DELAY);
//         await bell2_005.click();
//         LogUtil.info(`${Constant.TAG} soundAndVibrationTest_002 end`);
//         // 返回上一页
//         let wifiBackIcon2 = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//         await wifiBackIcon2.click();
//         await dr.assertComponentExist(ON.text('Drip'));
//         LogUtil.info(`${Constant.TAG} soundAndVibrationTest_002 end`);
//       } else {
//         // 信息铃声随机选择铃声切换
//         let bell_001 = await dr.waitForComponent(ON.text('Birdsong'), COMMON_DELAY);
//         await bell_001.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_002 = await dr.waitForComponent(ON.text('Breeze'), COMMON_DELAY);
//         await bell_002.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_003 = await dr.waitForComponent(ON.text('Cave'), COMMON_DELAY);
//         await bell_003.click();
//         await dr.delayMs(COMMON_DELAY);
//         // list下拉滑动条随机选择铃声
//         await dr.swipe(671, 2575, 620, 1548, 600);
//         let bell_004 = await dr.waitForComponent(ON.text('Fountain'), COMMON_DELAY);
//         await bell_004.click();
//         await dr.delayMs(COMMON_DELAY);
//         let bell_005 = await dr.waitForComponent(ON.text('Gush'), COMMON_DELAY);
//         await bell_005.click();
//         await dr.delayMs(COMMON_DELAY);
//         // 返回上一页
//         let wifiBackIcon = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//         await wifiBackIcon.click();
//         await dr.assertComponentExist(ON.text('Gush'));
//         await messageTone.click();
//       }
//     });
//
//     /*
//     * @tc.number:soundAndVibrationTest_003
//     * @tc.name: 通知铃声切换测试
//     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
//     * @tc.desc: 通知铃声切换
//     */
//     it('soundAndVibrationTest_003', 0, async () => {
//       LogUtil.info(`${Constant.TAG} soundAndVibrationTest_003 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验通知铃声存在，并点击
//       await dr.assertComponentExist(ON.text('通知铃声'));
//       let notificationTone = await dr.waitForComponent(ON.text('通知铃声'), WAIT_DELAY);
//       await notificationTone.click();
//       // 随机选择铃声切换
//       let bell_001 = await dr.waitForComponent(ON.text('Bell'), SWIPE_DELAY);
//       await bell_001.click();
//       await dr.delayMs(COMMON_DELAY);
//       let bell_002 = await dr.waitForComponent(ON.text('Breeze'), SWIPE_DELAY);
//       await bell_002.click();
//       await dr.delayMs(COMMON_DELAY);
//       let bell_003 = await dr.waitForComponent(ON.text('Chess'), SWIPE_DELAY);
//       await bell_003.click();
//       await dr.delayMs(COMMON_DELAY);
//       // list下拉滑动条随机选择铃声
//       await dr.swipe(658, 2606, 693, 1351, 600);
//       let bell_004 = await dr.waitForComponent(ON.text('Fountain'), SWIPE_DELAY);
//       await bell_004.click();
//       await dr.delayMs(COMMON_DELAY);
//       let bell_005 = await dr.waitForComponent(ON.text('Jump'), SWIPE_DELAY);
//       await bell_005.click();
//       // 返回上一页
//       let wifiBackIcon3 = await dr.waitForComponent(ON.type('BackButton'), COMMON_DELAY);
//       await wifiBackIcon3.click();
//       await dr.assertComponentExist(ON.text('Jump'));
//       LogUtil.info(`${Constant.TAG} soundAndVibrationTest_003 end`);
//     });
//   });
// }