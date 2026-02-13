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

import { describe, it, beforeAll, afterAll } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { BusinessError } from '@ohos.base';
import { Driver, ON } from '@ohos.UiTest';
import { Constant } from '../constant/Constant';
import { COMMON_DELAY, WAIT_DELAY } from '../types';

const TAG: string = 'SearchSettingsPageTest: ';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function searchSettingsPageTest() {
  describe('searchSettingsPageTest', () => {
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      ;
    });

    afterAll(async () => {
      let dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number: searchSettingsResultTest.
    * @tc.name: 全局的搜索
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 打开设置的页面, 点击搜索, 输入文本, 检查并点击搜索结果, 清空搜索记录
    */
    // it('searchSettingsResultTest', 0, searchSettingsResultTest);
  })
}

/**
 *  设置搜索界面用例.
 */
async function searchSettingsResultTest() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('ly');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_001() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('手机管家');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_002() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('管家');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_003() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('手机管理');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_004() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清理加速');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_005() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清理垃圾');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_006() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('垃圾');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_007() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清理');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_008() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清理内存');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_009() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('应用清理');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')),WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_010() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('自动清理');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_011() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清理数据');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_012() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('删除数据');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_013() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清除安装包');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_014() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('应用数据');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_015() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('应用数据');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_016() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('清理应用');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_017() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('手机管家');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_018() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('管家');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}

async function searchSettingsResultTest_019() {
  LogUtil.info(`${TAG} start to searchSettingsResultTest`);

  // 定义Driver的类;
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);

  // 点击'设置搜索'菜单
  let searchSettingsTab = await dr.findComponent(ON.id('searchIcon'));
  await searchSettingsTab.click();
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} searchSettingsTab clicked`);

  // 搜索框中输入内容
  let searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('手机管理');

  // 点击第一个搜索结果;
  let firstSearchTab = await dr.waitForComponent(ON.type('ListItem').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await firstSearchTab.click();
  LogUtil.info(`${Constant.TAG} firstSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 点击返回按钮到返回上一页;
  let locationBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await locationBackIcon.click();
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索框;
  let clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 搜索框中输入内容后清空
  searchTab = await dr.waitForComponent(ON.id('searchComponent'), WAIT_DELAY);
  await searchTab.inputText('wlan');
  clearSearchTab = await dr.waitForComponent(ON.type('Button').isAfter(ON.id('searchComponent')), WAIT_DELAY);
  await clearSearchTab.click();
  LogUtil.info(`${Constant.TAG} clearSearchTab again clicked`);
  await dr.delayMs(COMMON_DELAY);

  // 清空搜索历史;
  let clearRecord = await dr.waitForComponent(ON.text('清空'), WAIT_DELAY);
  await clearRecord.click();
  LogUtil.info(`${Constant.TAG} clearRecord clicked`);
  await dr.delayMs(COMMON_DELAY);
  LogUtil.info(`${TAG} searchSettingsPage_001 end`);
}
