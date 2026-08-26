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

/* instrument ignore file */
import { dataShare } from '@kit.ArkData';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import type common from '@ohos.app.ability.common';

const TAG: string = 'SoundRepairSettingsController : ';
const VOICE_FIX_SWITCH: string = 'vassistant_voicefix_on';

/**
 * 声音修复控制器
 *
 * @since 2024-08-08
 */
export class SoundRepairSettingsController implements ComponentControl {
  public enableState: string = '';
  protected dataHelper?: dataShare.DataShareHelper;
  private compId: string = '';

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus success`);
    const context: Context = getContext(this);
    let soundRepairSwitchState: string = settings.getValueSync(context, VOICE_FIX_SWITCH, 'false', settings.domainName.DEVICE_SHARED);
    if (soundRepairSwitchState === 'true' || soundRepairSwitchState === 'false') {
      LogUtil.info(`${TAG} get sound repair state success: ${soundRepairSwitchState}`);
      this.updateAbilityName(JSON.parse(soundRepairSwitchState));
    } else {
      LogUtil.info(`${TAG} get sound repair state failed: ${soundRepairSwitchState}`);
      this.updateAbilityName(false);
    }
  }

  async updateAbilityName(data: boolean): Promise<void> {
    LogUtil.info(`${TAG} updateAbilityName success`);
    if (data) {
      this.enableState = await ResourceUtil.getString($r('app.string.location_switch_on_text'));
    } else {
      this.enableState = await ResourceUtil.getString($r('app.string.location_switch_off_text'));
    }
    this.refreshUi(this.enableState);
    LogUtil.info(`${TAG} sound repaire state: ${this.enableState}`);
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    LogUtil.info(`${TAG} zoom gesture status data change`);
    this.updateStatus();
  }

  /**
   * 监听声音修复的实时状态
   */
  protected async registerSecurityDataChange(): Promise<void> {
    let context: common.Context | undefined = getContext(this);
    try {
      settings.registerKeyObserver(context, VOICE_FIX_SWITCH, settings.domainName.DEVICE_SHARED, () => {
        this.onDataChange();
      });
      LogUtil.info(`${TAG} zoom gesture key listener registerd`);
    } catch (e) {
      LogUtil.error(`${TAG} settings registerKeyObserver err, because ${e?.message}`);
    }
  }

  /**
   * 取消监听声音修复的实时状态
   */
  protected async unRegisterSecurityDataChange(): Promise<void> {
    let context: common.Context | undefined = getContext(this);
    settings.unregisterKeyObserver(context, VOICE_FIX_SWITCH, settings.domainName.DEVICE_SHARED);
    LogUtil.info(`${TAG} zoom gesture key listener unregisterd`);
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.updateStatus();
    this.registerSecurityDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterSecurityDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(statusResult: string): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
  }
}
