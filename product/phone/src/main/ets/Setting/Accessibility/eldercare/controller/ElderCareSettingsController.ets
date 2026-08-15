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
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ElderCareUtils } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED } from '../../constant/Constants';

const TAG: string = 'ElderCareSettingsController : ';

export class ElderCareSettingsController implements ComponentControl {
  public elderCareSwitch: boolean = false;
  public simpleUiModeSwitch: boolean = false;
  protected dataHelper?: dataShare.DataShareHelper;
  private compId: string = '';

  registerDataChange() {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
        this.onDataChange)
    } else {
      (SettingsDataUtils.createSecurityDataHelper(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerSecurityDataChange(this.dataHelper, ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED,
            this.onDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} elder care key listener registerd`);
  }

  unRegisterDataChange() {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED);
    LogUtil.info(`${TAG} elder care key listener unregisterd`);
  }

  /**
   * 关怀模式开关状监听回调
   */
  public onDataChange = () => {
    LogUtil.info(`${TAG} elder care status data change`);
    this.refreshUi();
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.refreshUi();
    // 监听界面开关状态变化
    this.registerDataChange();
    let elderCareFontScale: number =
      Number(SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_ZOOM_DISPLAY_LEVEL, '0'));
    LogUtil.info(`${TAG} current eldercare font scale: ${elderCareFontScale}`);
    let isFirstOpenElderCare: boolean =
      SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'false') === 'true';
    if (elderCareFontScale !== 0 && !isFirstOpenElderCare) {
      SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'true');
    }
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterDataChange();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    let elderCareStatus: boolean =
      SettingsDataUtils.getSecureValue(ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, '0') === '1';
    LogUtil.info(`${TAG} elder care status : ${elderCareStatus}`);
    let statusResult: ResourceStr = elderCareStatus ? $r('app.string.accessibility_on') :
    $r('app.string.accessibility_off');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
    if (elderCareStatus) {
      SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'true');
    }
  }
}