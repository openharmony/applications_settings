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
// import { describe, beforeAll,expect, it, afterAll } from '@ohos/hypium';
// import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
// import { LogUtil, NavEntryKey, SettingsDataUtils } from '@ohos/settings.common';
// import { BusinessError } from '@ohos.base';
// import { Driver, ON } from '@ohos.UiTest';
// import { COMMON_DELAY, SWIPE_DELAY, WAIT_DELAY } from '../types';
// import { Constant } from '../constant/Constant';
//
// const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
// const TAG: string = 'Settings Color adjustment and color temperature setting test';
//
//
// export default function ColorAndColorTemperaturePageTest() {
//   describe('ColorAndColorTemperaturePageTest', () => {
//     /*
//     * @tc.number:RefreshRatePageTest_001
//     * @tc.name: 色彩与色温菜单入口验证
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 对于支持设备，进入色彩调节与色温设置
//     */
//
//     beforeAll(async () => {
//       let dr: Driver = await Driver.create();
//       // 跳转色彩与色温菜单
//       dr = Driver.create();
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': 'com.ohos.settings',
//           'abilityName': 'com.ohos.settings.MainAbility',
//           'uri': NavEntryKey.DISPLAY_ENTRY,
//         }).then(() => {
//           LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success.`);
//         })
//       } catch (exception) {
//         LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
//       };
//       let colorAdjustmentTab = await dr.waitForComponent(ON.text(Constant.COLOR_ADJUSTMENT_AND_COLOR_TEMPERATURE), COMMON_DELAY);
//       await colorAdjustmentTab.click();
//     });
//
//     afterAll(async () => {
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 调整色彩模式为标准
//       let colorAdjustmentTab = await dr.waitForComponent(ON.text(Constant.COLOR_ADJUSTMENT_STANDARD), COMMON_DELAY);
//       await colorAdjustmentTab.click();
//       LogUtil.info(`${Constant.TAG} Color adjustment standard to clicked`);
//       // 设置色温模式为默认
//       let colorTemperatureTab = await dr.waitForComponent(ON.text(Constant.COLOR_TEMPERATURE_DEFAULT), COMMON_DELAY);
//       await colorTemperatureTab.click();
//       LogUtil.info(`${Constant.TAG} colorTemperatureTab clicked`)
//       // 点击返回按钮到显示与亮度界面
//       let displayBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), COMMON_DELAY);
//       await displayBackIcon.click();
//     });
//
//     afterAll(async () => {
//       // 定义Driver类
//       let dr = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 点击返回按钮到设置页面
//       let settingsBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
//       await settingsBackIcon.click();
//       await dr.delayMs(COMMON_DELAY);
//       await dr.pressHome();
//       await dr.delayMs(COMMON_DELAY);
//     });
//
//     /*
//     * @tc.number:sleepSettingsTest_001
//     * @tc.name: 色彩调节为标准模式
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 色彩调节为标准模式
//     */
//     it('ColorAdjustmentTest_001', 0, async () => {
//       LogUtil.info(`${Constant.TAG} ColorAdjustmentTest_001 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验标准存在，并且点击
//       await dr.assertComponentExist(ON.text(Constant.COLOR_ADJUSTMENT_STANDARD));
//       // 调整色彩模式为标准
//       let colorAdjustmentTab = await dr.waitForComponent(ON.text(Constant.COLOR_ADJUSTMENT_STANDARD), COMMON_DELAY);
//       await colorAdjustmentTab.click();
//       await dr.delayMs(SWIPE_DELAY);
//       LogUtil.info(`${Constant.TAG} Color adjustment standard to clicked`);
//       // 校验调整色彩模式设置成功
//       let colorPattern = SettingsDataUtils.getSettingsData('settings.color_mode', 'standard');
//       expect(colorPattern).assertEqual('standard')
//       LogUtil.info(`${Constant.TAG} ColorAdjustmentTest_001 end`);
//     });
//
//     /*
//     * @tc.number:sleepSettingsTest_002
//     * @tc.name: 色彩调节为鲜艳模式
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 色彩调节为鲜艳模式成功
//     */
//     it('ColorAdjustmentTest_002', 0, async () => {
//       LogUtil.info(`${Constant.TAG} ColorAdjustmentTest_002 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验鲜艳存在，并且点击
//       await dr.assertComponentExist(ON.text(Constant.COLOR_ADJUSTMENT_VIVID));
//       // 调整色彩模式为鲜艳
//       let colorAdjustmentTab = await dr.waitForComponent(ON.text(Constant.COLOR_ADJUSTMENT_VIVID), COMMON_DELAY);
//       await colorAdjustmentTab.click();
//       await dr.delayMs(SWIPE_DELAY);
//       LogUtil.info(`${Constant.TAG} colorAdjustmentTab clicked`);
//       // 校验调整色彩模式设置成功
//       let colorPattern = SettingsDataUtils.getSettingsData('settings.color_mode', 'standard');
//       expect(colorPattern).assertEqual('bright')
//       LogUtil.info(`${Constant.TAG} ColorAdjustmentTest_002 end`);
//     });
//
//     /*
//     * @tc.number:ColorTemperatureTest_001
//     * @tc.name: 色温设置为默认模式
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 色温设置为默认模式成功
//     */
//     it('ColorTemperatureTest_001', 0, async () => {
//       LogUtil.info(`${Constant.TAG} ColorTemperatureTest_001 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验默认存在，并且点击
//       await dr.assertComponentExist(ON.text(Constant.COLOR_TEMPERATURE_DEFAULT));
//       // 设置色温模式为默认
//       let colorTemperatureTab = await dr.waitForComponent(ON.text(Constant.COLOR_TEMPERATURE_DEFAULT), COMMON_DELAY);
//       await colorTemperatureTab.click();
//       await dr.delayMs(SWIPE_DELAY);
//       LogUtil.info(`${Constant.TAG} colorTemperatureTab clicked`);
//       // 校验设置色温模式设置成功
//       let colorTemperaturePattern = SettingsDataUtils.getSettingsData('settings.color_temperature', 'default');
//       expect(colorTemperaturePattern).assertEqual('default')
//       LogUtil.info(`${Constant.TAG} ColorTemperatureTest_001 end`);
//     });
//
//     /*
//     * @tc.number:ColorTemperatureTest_002
//     * @tc.name: 色温设置为暖色模式
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 色温设置为暖色模式成功
//     */
//     it('ColorTemperatureTest_002', 0, async () => {
//       LogUtil.info(`${Constant.TAG} ColorTemperatureTest_001 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验暖色存在，并且点击
//       await dr.assertComponentExist(ON.text(Constant.COLOR_TEMPERATURE_WARM));
//       // 设置色温模式为暖色
//       let colorTemperatureTab = await dr.waitForComponent(ON.text(Constant.COLOR_TEMPERATURE_WARM), COMMON_DELAY);
//       await colorTemperatureTab.click();
//       await dr.delayMs(SWIPE_DELAY);
//       LogUtil.info(`${Constant.TAG} colorTemperatureTab clicked`);
//       // 校验设置色温模式设置成功
//       let colorTemperaturePattern = SettingsDataUtils.getSettingsData('settings.color_temperature', 'default');
//       expect(colorTemperaturePattern).assertEqual('warm')
//       LogUtil.info(`${Constant.TAG} ColorTemperatureTest_002 end`);
//     });
//
//
//     /*
//     * @tc.number:ColorTemperatureTest_003
//     * @tc.name: 色温设置为冷色模式
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 色温设置为冷色模式成功
//     */
//     it('ColorTemperatureTest_003', 0, async () => {
//       LogUtil.info(`${Constant.TAG} ColorTemperatureTest_003 start`);
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       await dr.delayMs(COMMON_DELAY);
//       // 校验冷色存在，并且点击
//       await dr.assertComponentExist(ON.text(Constant.COLOR_TEMPERATURE_COOL));
//       // 设置色温模式为冷色
//       let colorTemperatureTab = await dr.waitForComponent(ON.text(Constant.COLOR_TEMPERATURE_COOL), COMMON_DELAY);
//       await colorTemperatureTab.click();
//       await dr.delayMs(SWIPE_DELAY);
//       LogUtil.info(`${Constant.TAG} colorTemperatureTab clicked`);
//       // 校验设置色温模式设置成功
//       let colorTemperaturePattern = SettingsDataUtils.getSettingsData('settings.color_temperature', 'default');
//       expect(colorTemperaturePattern).assertEqual('cold')
//       LogUtil.info(`${Constant.TAG} ColorTemperatureTest_003 end`);
//     });
//   })
// }