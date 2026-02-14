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
import displaySync from '@ohos.graphics.displaySync';
import { DynamicGroupDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicGroupDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  SettingItemModel,
  ItemResultType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingDetailState,
  SettingIconState,
  SettingLayoutState,
  SettingStateType,
  SettingTextState,
  SettingResultState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import {
  TOUCH_DISABLE_MODE_KEY,
  SWITCH_ON_VAL
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { getFirstFrameGroups, getSecondFrameGroups } from '../SystemPage';

const TAG: string = 'SystemPageControl:';
const DELAY_FRAME: number = 1;

export class SystemPageControl implements ComponentControl {
  private isTouchDisableEnabled: boolean = true;
  private dataSource: DynamicGroupDataSource = new DynamicGroupDataSource();
  private displaySync: displaySync.DisplaySync = displaySync.create();
  private displaySyncCount: number = 0;
  private addDataCallback = (intervalInfo: displaySync.IntervalInfo) => {
    if (this.displaySyncCount === DELAY_FRAME) {
      LogUtil.info(`${TAG} second frame to show SystemGroups.`);
      this.dataSource.pushAndFilterItems(...getSecondFrameGroups());
      this.setDisable();
    }
    this.displaySyncCount++;
    if (this.displaySyncCount > DELAY_FRAME) {
      this.displaySync.stop();
    }
  };

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.showInfo(TAG, 'onInit');
    if (!compParam || !compParam.component) {
      LogUtil.showInfo(TAG, 'Init failed, component is empty');
      return;
    }
    this.dataSource = compParam.dataSource as DynamicGroupDataSource;
    this.dataSource.pushAndFilterItems(...getFirstFrameGroups());
    this.setDisable();
    if (!PenglaiUtil.isPengLaiModeOpen()) {
      this.setDisplaySync();
    }
    this.isTouchDisableEnabled =
      SettingsDataUtils.getSettingsData(TOUCH_DISABLE_MODE_KEY, SWITCH_ON_VAL) == SWITCH_ON_VAL;
  }

  private setDisable(): void {
    let groupLen: number = this.dataSource.length;
    for (let groupIndex: number = 0; groupIndex < groupLen; groupIndex++) {
      const group: SettingGroupModel = this.dataSource[groupIndex];
      if (!group.items) {
        continue;
      }
      for (let itemIndex: number = 0; itemIndex < group.items.length; itemIndex++) {
        const item: SettingItemModel = group.items[itemIndex];
        if (PreferencesUtil.hasSync(item.id)) {
          item.enabled = !PreferencesUtil.getSync(item.id, true) as boolean;
          LogUtil.showInfo(TAG, `disable item:${item.id}, enabled: ${item.enabled}`);
        }
      }
    }
  }

  private setDisplaySync() {
    this.displaySync.on('frame', this.addDataCallback);
    this.displaySync.start();
  }

  private disableDisplaySync() {
    this.displaySync.off('frame', this.addDataCallback);
  }

  private setTouchDisableState(): void {
    let isEnabled = SettingsDataUtils.getSettingsData(TOUCH_DISABLE_MODE_KEY, SWITCH_ON_VAL) == SWITCH_ON_VAL;
    if (this.isTouchDisableEnabled === isEnabled) {
      return;
    }
    this.isTouchDisableEnabled = isEnabled;
    notifyCompStateChange('Setting.System.quick_gestures_group.touch_disable_mode_entry',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isEnabled }
        } as SettingResultState]]));
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.showInfo(TAG, 'onPageShow');
    this.setTouchDisableState();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.showInfo(TAG, 'onPageHide');
    this.isTouchDisableEnabled =
      SettingsDataUtils.getSettingsData(TOUCH_DISABLE_MODE_KEY, SWITCH_ON_VAL) == SWITCH_ON_VAL;
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    this.disableDisplaySync();
  }

}