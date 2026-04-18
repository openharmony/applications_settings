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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Driver, ON } from '@ohos.UiTest';
import { BusinessError } from '@ohos.base';
import { Constant } from '../../constant/Constant';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

/**
 * wlan IP测试，其中IP地址、网关、网络前缀长度、域名1是必填项
 */
export default function connectPersonalWlanWithIp() {
  describe('connectPersonalWlanWithIp', () => {
    LogUtil.info(`${Constant.TAG} describe start`);

    // beforeAll(async () => {
    //   DELEGATOR.startAbility({
    //     bundleName: Constant.SETTINGS_BUNDLE_NAME,
    //     abilityName: Constant.SETTINGS_MAIN_ABILITY_NAME,
    //   }).then(() => {
    //     LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    //   }).catch((exception: BusinessError) => {
    //     LogUtil.error(`Failed to startAbility. code: ${(exception as BusinessError).code}`);
    //   });
    //
    //   // 定义Driver类
    //   let dr: Driver = await Driver.create();
    //   await dr.delayMs(COMMON_DELAY);
    //   // 点击设置中的wlan入口
    //   let wlanTab = await dr.waitForComponent(ON.text(Constant.WIFI), WAIT_DELAY);
    //   await wlanTab.click();
    //   await dr.delayMs(COMMON_DELAY);
    //   LogUtil.info(`${Constant.TAG} wlanTab clicked`);
    //
    //   // 点击WLAN页面的WIFI开关
    //   let wlanSwitch = await dr.waitForComponent(ON.id(Constant.WIFI_SWITCH_ID), WAIT_DELAY);
    //   await wlanSwitch.click();
    //   LogUtil.info(`${Constant.TAG} wlanSwitch clicked`);
    //   LogUtil.info(`${Constant.TAG} describe end`);
    // });
    //
    // /**
    //  * 进入wif连接页面，输入密码，切换IP为静态
    //  */
    // beforeEach(async () => {
    //   LogUtil.info(`${Constant.TAG} beforeEach start`);
    //   // 定义Driver类
    //   let dr: Driver = await Driver.create();
    //   await dr.delayMs(COMMON_DELAY);
    //   // 点击各人热点
    //   let wifiTab = await dr.waitForComponent(ON.text(Constant.WIFI_CONNECT_NAME), WAIT_DELAY);
    //   await wifiTab.click();
    //   // 输入wifi设置中的密码
    //   let text = await dr.waitForComponent(ON.id(Constant.WIFI_PASSWORD_INPUT_ID), WAIT_DELAY);
    //   await text.inputText(Constant.WIFI_CONNECT_PASSWORD);
    //   // 滑动到IP菜单
    //   await dr.swipe(84, 1152, 84, 950, 3000);
    //   // 点击IP菜单
    //   let ipSelect = await dr.waitForComponent(ON.id(Constant.WIFI_IP_SELECT_ID), WAIT_DELAY);
    //   await ipSelect.click();
    //   // IP从DHCP默认值切换成静态
    //   let staticMenu = await dr.waitForComponent(ON.text(Constant.WIFI_IP_STATIC_ID), WAIT_DELAY);
    //   await staticMenu.click();
    //   await dr.delayMs(COMMON_DELAY);
    //   // 滑动到IP地址设置处
    //   await dr.swipe(84, 1152, 84, 850, 3000);
    //   LogUtil.info(`${Constant.TAG} beforeEach clicked`);
    // });
    //
    // /**
    //  * 删除连接成功的wifi
    //  */
    // afterEach(async () => {
    //   LogUtil.info(`${Constant.TAG} afterEach start`);
    //   // // 定义Driver类
    //   let dr: Driver = await Driver.create();
    //   await dr.delayMs(COMMON_DELAY);
    //   await dr?.pressBack();
    //   // 检验wlan是否连接成功
    //   let connectTab = await dr.waitForComponent(ON.text(Constant.WIFI_STATUS_CONNECTED), WAIT_DELAY);
    //   if (!connectTab) {
    //     LogUtil.info(`${Constant.TAG} no connect wlan`);
    //     return;
    //   }
    //   expect(connectTab).assertNull();
    //   LogUtil.info(`${Constant.TAG} afterEach clicked`);
    // });
    //
    // /**
    //  * 关闭wifi开关，返回设置主页
    //  */
    // afterAll(async () => {
    //   LogUtil.info(`${Constant.TAG} afterAll start`);
    //   // 定义Driver类
    //   let dr: Driver = await Driver.create();
    //   await dr.delayMs(COMMON_DELAY);
    //   await dr.assertComponentExist(ON.text(Constant.SETTINGS));
    //   LogUtil.info(`${Constant.TAG} afterAll end`);
    // });
    //
    // /**
    //  * @tc.number:connectPersonalWlanWithIp_001
    //  * @tc.name: 设置静态IP信息，仅设置IP地址
    //  * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    //  * @tc.desc: 连接wifi验证
    //  */
  //   it('connectPersonalWlanWithIp_001', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_001 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_001 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_002
  //    * @tc.name: 设置静态IP信息，仅设置网关
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_002', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_002 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_002 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_003
  //    * @tc.name: 设置静态IP信息，仅设置网络前缀
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_003', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_003 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_003 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_004
  //    * @tc.name: 设置静态IP信息，仅设置域名1
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_004', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_004 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 滑动到域名1菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_004 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_005
  //    * @tc.name: 设置静态IP信息，仅设置域名2
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_005', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_005 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 滑动到域名2菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写域名2
  //     let ipDnsServer2Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer2Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_005 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_006
  //    * @tc.name: 设置静态IP信息，仅设置IP地址和网关
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_006', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_006 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_006 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_007
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关和网络前缀
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_007', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_007 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_007 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_008
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关，网络前缀和域名1
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_008', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_008 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_008 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_009
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关，网络前缀，域名1和域名2
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_009', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_009 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT);
  //
  //     // 填写域名2
  //     let ipDnsServer2Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer2Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_TEXT);
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_009 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_010
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关，网络前缀和域名2
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_010', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_010 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 填写域名2
  //     let ipDnsServer2Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer2Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_010 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_011
  //    * @tc.name: 设置静态IP信息，仅设置错误的IP地址，网关，网络前缀，域名1
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_011', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_011 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入错误的IP地址
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_ERROR_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_011 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_012
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，错误的网关，网络前缀，域名1
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_012', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_012 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_ERROR_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_012 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_013
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关，网络前缀，错误的域名1
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_013', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_013 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ERROR_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_013 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_014
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关，网络前缀，错误的域名1和域名2
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_014', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_014 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ERROR_TEXT);
  //
  //     // 填写域名2
  //     let ipDnsServer2Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_ID),
  //       WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipDnsServer2Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_2_TEXT);
  //
  //     // 查看连接按钮状态
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     let isClickable = await confirmTab.isEnabled();
  //     LogUtil.info(`${Constant.TAG} isClickable ${isClickable}`);
  //     await expect(isClickable).assertEqual(false);
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_014 end`);
  //   });
  //
  //   /**
  //    * @tc.number:connectPersonalWlanWithIp_015
  //    * @tc.name: 设置静态IP信息，仅设置IP地址，网关，网络前缀，域名1，切换IP为DHCP
  //    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  //    * @tc.desc: 连接wifi验证
  //    */
  //   it('connectPersonalWlanWithIp_015', 0, async () => {
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_015 start`);
  //     // 定义Driver类
  //     let dr: Driver = await Driver.create();
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写IP地址
  //     let ipAddressText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_ADDRESS_ID), WAIT_DELAY);
  //     // 输入符合正则的信息
  //     await ipAddressText.inputText(Constant.WIFI_IP_STATIC_IP_ADDRESS_TEXT);
  //
  //     // 填写网关
  //     let ipGatewayText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_GATEWAY_ID), WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipGatewayText.inputText(Constant.WIFI_IP_STATIC_IP_GATEWAY_TEXT);
  //
  //     // 滑动到网络前缀菜单
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 填写网络前缀
  //     let ipPrefixLengthText = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_ID),
  //       WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipPrefixLengthText.inputText(Constant.WIFI_IP_STATIC_IP_PREFIX_LENGTH_TEXT);
  //     await dr.swipe(84, 1152, 84, 477, 3000);
  //     // 填写域名1
  //     let ipDnsServer1Text = await dr.waitForComponent(ON.id(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_ID),
  //       WAIT_DELAY);
  //     // 输入不符合正则的信息
  //     await ipDnsServer1Text.inputText(Constant.WIFI_IP_STATIC_IP_DNS_SERVERS_1_TEXT);
  //
  //     // 滑动到IP菜单
  //     await dr.swipe(84, 500, 84, 1152, 3000);
  //     await dr.delayMs(COMMON_DELAY);
  //
  //     // 点击IP菜单
  //     let ipSelect = await dr.waitForComponent(ON.id(Constant.WIFI_IP_SELECT_ID), WAIT_DELAY);
  //     await ipSelect.click();
  //     LogUtil.info(`${Constant.TAG} ipSelect clicked`);
  //     // IP从静态换成DHCP
  //     let dhcpMenu = await dr.waitForComponent(ON.text(Constant.WIFI_IP_DHCP_ID), WAIT_DELAY);
  //     await dhcpMenu.click();
  //     LogUtil.info(`${Constant.TAG} dhcpMenu clicked`);
  //
  //     // 点击连接按钮
  //     let confirmTab = await dr.waitForComponent(ON.id(Constant.WIFI_CONNECT_BUTTON_ID), WAIT_DELAY);
  //     await confirmTab.click();
  //     LogUtil.info(`${Constant.TAG} connect button clicked`);
  //
  //     // 等待连接结果
  //     await dr.delayMs(COMMON_DELAY * 10);
  //     await dr.assertComponentExist(ON.text(Constant.WIFI_STATUS_CONNECTED));
  //
  //     LogUtil.info(`${Constant.TAG} connectPersonalWlanWithIp_015 end`);
  //   });

    LogUtil.info(`${Constant.TAG} describe end`);
  });
}