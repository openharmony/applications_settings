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

import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import rpc from '@ohos.rpc';
import Want from '@ohos.app.ability.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import SearchItemInfoManager from '@ohos/settings.common/src/main/ets/data/SearchItemInfoManager';
import SettingPageDescManager from '@ohos/settings.common/src/main/ets/data/SettingPageDescManager';
import { RdbStoreHelper } from '@ohos/settings.common/src/main/ets/rdb/RdbStoreHelper';
import { NotDisturbUtils } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { SettingsExtServiceStub } from '../stub/SettingExtServiceStub';

/* instrument ignore file */
const TAG: string = 'SettingsExtServiceAbility';

export default class SettingsExtServiceAbility extends ServiceExtensionAbility {
  private readonly settingsExtServiceStub = new SettingsExtServiceStub(TAG);

  async onCreate(want: Want) {
    LogUtil.showInfo(TAG, 'onCreate');
    AbilityContextManager.setExtContext(this.context);
    this.setCacheProcess(false);
    // 双升单场景，数据已经在settings data迁移完成，但是settings data发送广播时，设置还未安装，设置无法感知到免打扰数据已经迁移
    // 所以为了设置感知到免打扰数据，启动免打扰功能定时器，因此需要在此处触发免打扰启动定时器相关逻辑
    await NotDisturbUtils.handleHmosToNextNotDisturbRestore();
  }

  onRequest(want: Want, startId: number) {
    LogUtil.showInfo(TAG, `onRequest abilityName:${want.abilityName} bundleName:${want.bundleName} startId:${startId}`);
  }

  onConnect(want: Want): rpc.RemoteObject | Promise<rpc.RemoteObject> {
    LogUtil.showInfo(TAG, 'onConnect');
    return this.settingsExtServiceStub;
  }

  onDisconnect(want: Want) {
    LogUtil.showInfo(TAG, 'onDisconnect');
  }

  onDestroy() {
    LogUtil.showInfo(TAG, 'onDestroy');
    AbilityContextManager.setExtContext(undefined);
    SearchItemInfoManager.resetRdbStore();
    SettingPageDescManager.resetRdbStore();
    RdbStoreHelper.getInstance().setRdbStore(undefined);
  }

  private setCacheProcess(isNeedCache: boolean): void {
    try {
      const applicationContext = this.context.getApplicationContext();
      applicationContext.setSupportedProcessCache(isNeedCache);
    } catch (e) {
      LogUtil.error(`SettingsAbilityStage setSupportedProcessCache fail, code: ${e?.code}, msg: ${e?.message}`);
    }
  }
}