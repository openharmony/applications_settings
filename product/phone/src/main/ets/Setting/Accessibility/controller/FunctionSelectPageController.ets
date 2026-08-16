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

import config from '@ohos.accessibility.config';
import dataShare from '@ohos.data.dataShare';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AccessibilityCommonModel } from '../utils/AccessibilityCommonModel';
import { FunctionSelectMenuController } from './FunctionSelectMenuController';
import { ACCESSIBILITY_FUNCTION_SELECT_TARGETS } from '../constant/Constants';

/* instrument ignore file */
const TAG: string = 'FunctionSelectPageController';
const SHORTKEY_CLOSE: string = '已关闭';
const DATA_CHANGE_TIMEOUT: number = 10;

export class FunctionSelectPageController implements ComponentControl {
  private compId: string = '';
  private shortKeyTargets: string[] = [];
  protected dataHelper?: dataShare.DataShareHelper;
  private selectTargetsName: ResourceStr = '';
  private itemModel?: SettingItemModel | undefined;
  private isInitFlag: boolean = false;
  private timeoutId: number | undefined = undefined;

  async getAccessibilityConfig(): Promise<void> {
    await config.shortkeyMultiTargets.get().then((value) => {
      this.shortKeyTargets = value;
    });
    await this.findTargetsName();
    await new FunctionSelectMenuController().getAccessibilityConfig();
    this.refreshUi();
  }

  async findTargetsName(): Promise<void> {
    const context: Context = getContext(this);
    LogUtil.info(`${TAG} findTargetsName shortKeyTargets: ${this.shortKeyTargets}`);
    this.selectTargetsName =
      await AccessibilityCommonModel.getSelectAbilityResourceName(context, this.shortKeyTargets[0]);
    if (this.shortKeyTargets.length > 1) {
      this.selectTargetsName = $r('app.string.multi_targets', this.selectTargetsName);
    }
    LogUtil.info(`${TAG} findTargetsName  ${ResourceUtil.getStringSync(this.selectTargetsName)}`);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.itemModel = compParam.component as SettingItemModel;
    await this.getAccessibilityConfig();
    this.isInitFlag = true;
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unRegisterDataChange();
  }

  async onPageShow(): Promise<void> {
    LogUtil.info(`${TAG} onPageShow`);
    if (!this.isInitFlag) {
      await this.getAccessibilityConfig();
    }
    this.isInitFlag = false;
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  registerDataChange() {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, ACCESSIBILITY_FUNCTION_SELECT_TARGETS, this.onDataChange)
    } else {
      (SettingsDataUtils.createDataHelper(ACCESSIBILITY_FUNCTION_SELECT_TARGETS) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerDataChange(this.dataHelper, ACCESSIBILITY_FUNCTION_SELECT_TARGETS,
            this.onDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} funtion select page listener registerd`);
  }

  unRegisterDataChange() {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper,
      ACCESSIBILITY_FUNCTION_SELECT_TARGETS);
    LogUtil.info(`${TAG} funtion select page listener unregisterd`);
  }

  /**
   * 开关状监听回调
   */
  public onDataChange = () => {
    if (this.timeoutId !== undefined) {
      return;
    }
    this.timeoutId = setTimeout(() => {
      LogUtil.info(`${TAG} funtion select page status data change`);
      this.selectTargetsName = SettingsDataUtils.getSettingsData(ACCESSIBILITY_FUNCTION_SELECT_TARGETS, SHORTKEY_CLOSE);
      this.getAccessibilityConfig();
      this.refreshUi();
      this.timeoutId = undefined;
    }, DATA_CHANGE_TIMEOUT);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: this.selectTargetsName }
        } as SettingResultState]]));
  }
}