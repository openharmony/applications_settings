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
// import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
// import { Driver, MatchPattern, ON } from '@ohos.UiTest';
// import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
// import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
// import { BusinessError } from '@ohos.base';
// import { COMMON_DELAY, WAIT_DELAY } from '../../types';
// import { Constant } from '../../constant/Constant';
//
// const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
// const TAG: string = 'Settingstest';
//
// export default function LanguageChangeInTimeZoneList() {
//   describe('LanguageChangeInTimeZoneList', () => {
//     // 定义Driver类
//     let dr: Driver | null = null;
//
//     // 切换语言到英语
//     beforeAll(async () => {
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': Constant.SETTINGS_BUNDLE_NAME,
//           'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
//           'uri': 'system_and_updates',
//         }).then(() => {
//           LogUtil.info(`${Constant.TAG} system_and_updates start success`);
//         });
//       } catch (exception) {
//         LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
//       }
//       ;
//       // 定义Driver类
//       let dr: Driver = await Driver.create();
//       let AddLanguageLabel = await dr?.findComponent(ON.text('Add language'))
//       // 如果当前不是英语需要切换到英语
//       if (AddLanguageLabel === null || AddLanguageLabel === undefined) {
//         let languageAndInputTab = await dr.waitForComponent(ON.text(Constant.LANGUAGE_AND_INPUT), WAIT_DELAY);
//         await languageAndInputTab.click();
//         LogUtil.info(`${Constant.TAG} languageAndInputTab clicked`);
//         let languageAndRegionTab = await dr.waitForComponent(ON.text(Constant.LANGUAGE_AND_REGION), WAIT_DELAY);
//         await languageAndRegionTab.click();
//         let languageAddTab = await dr.waitForComponent(ON.text(Constant.ADD_LANGUAGE), WAIT_DELAY);
//         await languageAddTab.click();
//         languageAddTab = await dr.waitForComponent(ON.text(Constant.ENGLISH), WAIT_DELAY);
//         await languageAddTab.click();
//         //选择英语为系统语言
//         await dr.delayMs(COMMON_DELAY);
//         languageAddTab = await dr.waitForComponent(ON.text(Constant.CHOOSE_MODIFY), WAIT_DELAY);
//         await languageAddTab.click();
//         LogUtil.info(`${Constant.TAG} English choosed`);
//       }
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
//     * @tc.number:LanguageChangeInTimeZoneList_001
//     * @tc.name: 切换语言后，时区列表语言自动更新
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 在英语环境下选择北京时区
//     */
//     it('LanguageChangeInTimeZoneList_001', 0, async () => {
//       let dr: Driver = await Driver.create();
//       // 跳转到系统和更新界面
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': Constant.SETTINGS_BUNDLE_NAME,
//           'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
//           'uri': 'system_and_updates',
//         }).then(() => {
//           LogUtil.info(`${Constant.TAG} system_and_updates start success`);
//         });
//       } catch (exception) {
//         LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
//       }
//       ;
//       await dr?.delayMs(COMMON_DELAY);
//       let dateAndTimeTab = await dr.waitForComponent(ON.id('entry_image_date_and_time'), WAIT_DELAY);
//       await dateAndTimeTab.click();
//       LogUtil.info(`${TAG} dateAndTimeTab clicked`);
//
//       let timeMenu = await dr?.findComponent(ON.text('Date'))
//       if (timeMenu === null || timeMenu === undefined) {
//         let hourTab = await dr?.waitForComponent(ON.id('entry_toggle_auto_timezone'), WAIT_DELAY);
//         await hourTab?.click();
//         LogUtil.info(`${TAG} close automatic timezone setting`);
//       }
//
//       LogUtil.info(`${TAG} enter timezone`);
//       // 点击时区入口
//       await dr?.delayMs(COMMON_DELAY);
//       let timeZoneTab = await dr?.waitForComponent(ON.id('entry_image_time_zone_settings'), WAIT_DELAY);
//       await timeZoneTab?.click();
//       LogUtil.info(`${TAG} timeZoneTab clicked`);
//       // 滑动选择Beijing (China)
//       let text = await dr?.findComponent(ON.text('Beijing (China)'));
//       const START_X: number = 260;
//       const START_Y: number = 1900;
//       const END_X: number = 200;
//       const END_Y: number = 397;
//       const SPEED: number = 6000;
//       // 此处需先取值保证第一个不会被滑走
//       text = await dr?.findComponent(ON.text('Abidjan (Côte d’Ivoire)'));
//       while (!text) {
//         await dr?.swipe(START_X, START_Y, END_X, END_Y, SPEED);
//         text = await dr?.findComponent(ON.text('Beijing (China)'));
//       }
//       await dr?.delayMs(COMMON_DELAY);
//       await text.click();
//       //校验时区选择正确
//       await dr?.delayMs(COMMON_DELAY);
//       let zone = await dr?.waitForComponent(ON.text('GMT+08:00 ', MatchPattern.CONTAINS), WAIT_DELAY);
//       expect(await zone?.getText()).assertContain("GMT+08:00 ");
//       LogUtil.info(`${TAG} LanguageChangeInTimeZoneList_001 end`);
//     });
//
//     /*
//     * @tc.number:LanguageChangeInTimeZoneList_002
//     * @tc.name: 切换语言后，时区列表首个城市（Abidjan (Côte d’Ivoire)）
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 切换语言后，选择时区列表首个城市（Abidjan），检测首个menu是否能被选中
//     */
//     it('LanguageChangeInTimeZoneList_002', 0, async () => {
//       let dr: Driver = await Driver.create();
//       // 跳转到系统和更新界面
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': Constant.SETTINGS_BUNDLE_NAME,
//           'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
//           'uri': 'system_and_updates',
//         }).then(() => {
//           LogUtil.info(`${Constant.TAG} system_and_updates start success`);
//         });
//       } catch (exception) {
//         LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
//       }
//       ;
//       await dr?.delayMs(COMMON_DELAY);
//       let dateAndTimeTab = await dr.waitForComponent(ON.id('entry_image_date_and_time'), WAIT_DELAY);
//       await dateAndTimeTab.click();
//       LogUtil.info(`${TAG} dateAndTimeTab clicked`);
//
//       let timeMenu = await dr?.findComponent(ON.id('entry_text_time_settings'));
//       if (timeMenu === null || timeMenu === undefined) {
//         let hourTab = await dr?.waitForComponent(ON.id('entry_toggle_auto_timezone'), WAIT_DELAY);
//         await hourTab?.click();
//         LogUtil.info(`${TAG} close automatic timezone setting`);
//       }
//
//       LogUtil.info(`${TAG} enter timezone`);
//       // 点击时区入口
//       await dr?.delayMs(COMMON_DELAY);
//       let timeZoneTab = await dr?.waitForComponent(ON.id('entry_image_time_zone_settings'), WAIT_DELAY);
//       await timeZoneTab?.click();
//       LogUtil.info(`${TAG} timeZoneTab clicked`);
//       // 滑动选择Beijing (China)
//       let text = await dr?.findComponent(ON.text('Abidjan (Côte d’Ivoire)'));
//       const START_X: number = 260;
//       const START_Y: number = 1900;
//       const END_X: number = 200;
//       const END_Y: number = 397;
//       const SPEED: number = 6000;
//       text = await dr?.findComponent(ON.text('Abidjan (Côte d’Ivoire)'));
//       while (!text) {
//         await dr?.swipe(START_X, START_Y, END_X, END_Y, SPEED);
//         text = await dr?.findComponent(ON.text('Abidjan (Côte d’Ivoire)'));
//       }
//       await dr?.delayMs(COMMON_DELAY);
//       await text.click();
//       //校验时区选择正确
//       await dr?.delayMs(COMMON_DELAY);
//       let zone = await dr?.waitForComponent(ON.text('GMT+00:00 ', MatchPattern.CONTAINS), WAIT_DELAY);
//       expect(await zone?.getText()).assertContain("GMT+00:00 ");
//       LogUtil.info(`${TAG} LanguageChangeInTimeZoneList_002 end`);
//     });
//
//     /*
//     * @tc.number:LanguageChangeInTimeZoneList_003
//     * @tc.name: 切换语言后，测试列表滑动，并选择最后一个作为时区选定
//     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
//     * @tc.desc: 切换语言后，测试列表滑动，并选择最后一个作为时区选定。（此处需设置较长time out时间）
//     */
//     it('LanguageChangeInTimeZoneList_003', 0, async () => {
//       let dr: Driver = await Driver.create();
//       // 跳转到系统和更新界面
//       try {
//         await DELEGATOR.startAbility({
//           'bundleName': Constant.SETTINGS_BUNDLE_NAME,
//           'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
//           'uri': 'system_and_updates',
//         }).then(() => {
//           LogUtil.info(`${Constant.TAG} system_and_updates start success`);
//         });
//       } catch (exception) {
//         LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
//       }
//       ;
//       await dr?.delayMs(COMMON_DELAY);
//       let dateAndTimeTab = await dr.waitForComponent(ON.id('entry_image_date_and_time'), WAIT_DELAY);
//       await dateAndTimeTab.click();
//       LogUtil.info(`${TAG} dateAndTimeTab clicked`);
//
//       let timeMenu = await dr?.findComponent(ON.id('entry_text_time_settings'));
//       if (timeMenu === null || timeMenu === undefined) {
//         let hourTab = await dr?.waitForComponent(ON.id('entry_toggle_auto_timezone'), WAIT_DELAY);
//         await hourTab?.click();
//         LogUtil.info(`${TAG} close automatic timezone setting`);
//       }
//
//       LogUtil.info(`${TAG} enter timezone`);
//       // 点击时区入口
//       await dr?.delayMs(COMMON_DELAY);
//       let timeZoneTab = await dr?.waitForComponent(ON.id('entry_image_time_zone_settings'), WAIT_DELAY);
//       await timeZoneTab?.click();
//       LogUtil.info(`${TAG} timeZoneTab clicked`);
//       // 滑动选择Zurich (Switzerland)
//       let text = await dr?.findComponent(ON.text('Zurich (Switzerland)'));
//       const START_X: number = 260;
//       const START_Y: number = 2500;
//       const END_X: number = 200;
//       const END_Y: number = 397;
//       const SPEED: number = 40000;
//       text = await dr?.findComponent(ON.text('Zurich (Switzerland)'));
//       while (!text) {
//         await dr?.swipe(START_X, START_Y, END_X, END_Y, SPEED);
//         text = await dr?.findComponent(ON.text('Zurich (Switzerland)'));
//       }
//       await dr?.delayMs(COMMON_DELAY);
//       await text.click();
//       //校验时区选择正确
//       await dr?.delayMs(COMMON_DELAY);
//       let zone = await dr?.waitForComponent(ON.text('GMT+01:00 ', MatchPattern.CONTAINS), WAIT_DELAY);
//       expect(await zone?.getText()).assertContain("GMT+01:00 ");
//       LogUtil.info(`${TAG} LanguageChangeInTimeZoneList_003 end`);
//     });
//   });
// }