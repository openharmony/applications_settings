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

import { abilityDelegatorRegistry } from '@kit.TestKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { describe, it, beforeAll, afterAll, expect } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NewVersionViewStatus } from '@ohos/settings.systemUpdate/src/main/ets/model/NewVersionViewStatusModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { COMMON_DELAY, WAIT_DELAY } from '../types';

const TAG: string = 'DeviceBadgeTest';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const HW_NEW_SYSTEM_UPDATE_STATUS = 'hw_new_system_update_status';
const HW_NEW_SYSTEM_UPDATE = 'hw_new_system_update';

export default function DeviceBadgeTest() {
  describe('DeviceBadgeTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      // 跳转至关于本机页面
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      }
      catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code},`
          + ` message: ${(exception as BusinessError).message}`);
      };
    });

    afterAll(async () => {
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击返回按钮到设置页面
      let settingsBackIcon = await dr.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
      await settingsBackIcon.click();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:DeviceBadgeTest_001
    * @tc.name: 无版本
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 无角标
    */
    it('DeviceBadgeTest_001', 0, DeviceBadgeTest_001);

    /*
    * @tc.number:DeviceBadgeTest_002
    * @tc.name: 升级过程
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 设备名称右边显示升级状态
    */
    it('DeviceBadgeTest_002', 0, DeviceBadgeTest_002);
  });
}

async function DeviceBadgeTest_001() {
  LogUtil.info(`${TAG} DeviceBadgeTest_001 start`);
  try {
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE, '0');
    // 定义Driver类
    let dr = await Driver.create();
    await dr.delayMs(COMMON_DELAY);
    let badgeText1 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text1'), WAIT_DELAY);
    let badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(badgeText1).assertNull();
    expect(badgeText2).assertNull();
  } catch {
    LogUtil.error(`${TAG} DeviceBadgeTest_001 execute exception failed!`);
  }
}

async function DeviceBadgeTest_002() {
  LogUtil.info(`${TAG} DeviceBadgeTest_002 start`);
  try {
    // 定义Driver类
    let dr = await Driver.create();
    await dr.delayMs(COMMON_DELAY);

    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE, '1');
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_INIT.toString());
    let badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2.getText() === '').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_CHECK_SUCCESS.toString());
    let badgeText1 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text1'), WAIT_DELAY);
    expect(await badgeText1.getText() === '发现新版本').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_DOWNLOADING.toString());
    badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2.getText() === '新版本下载中').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_DOWNLOAD_PAUSE.toString());
    badgeText1 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text1'), WAIT_DELAY);
    expect(await badgeText1.getText() === '新版本下载暂停').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_DOWNLOAD_VERIFYING.toString());
    badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2.getText() === '新版本下载中').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_DOWNLOAD_SUCCESS.toString());
    badgeText1 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text1'), WAIT_DELAY);
    expect(await badgeText1.getText() === '新版本待安装').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_UPGRADE_VERIFYING.toString());
    badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2.getText() === '').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_UPGRADE_REBOOTING.toString());
    badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2.getText() === '').assertTrue();

    await dr.delayMs(COMMON_DELAY);
    SettingsDataUtils.setSettingsData(HW_NEW_SYSTEM_UPDATE_STATUS, NewVersionViewStatus.VIEW_UPGRADE_HOT_INSTALLING.toString());
    badgeText2 = await dr.waitForComponent(ON.id('AboutDeviceItemView_badge_text2'), WAIT_DELAY);
    expect(await badgeText2.getText() === '').assertTrue();
  } catch {
    LogUtil.error(`${TAG} DeviceBadgeTest_002 execute exception failed!`);
  }
}