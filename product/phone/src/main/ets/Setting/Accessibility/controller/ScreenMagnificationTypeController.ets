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

import { dataShare } from '@kit.ArkData';
import account_osAccount from '@ohos.account.osAccount';
import { BusinessError } from '@ohos.base';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingBaseState,
  SettingSelectMenuState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ScreenMagnificationType, MAGNIFICATION_TYPES_ARRAY } from '../constant/Constants';

/* instrument ignore file */
const SCREEN_MAGNIFICATION_TYPE_KEY: string = 'accessibility_magnification_capability';
const TAG: string = 'ScreenMagnificationTypeController: ';

export class ScreenMagnificationTypeController implements ComponentControl {
  public static screenMagnificationType: number = ScreenMagnificationType.TYPE_ALL;
  protected dataHelper?: dataShare.DataShareHelper;
  public settingItemModel?: SettingItemModel;
  private compId: string = '';

  public static updateTouchScreenType(type: number): void {
    let selectType: number = type + 1;
    LogUtil.info(`${TAG} updateTouchScreenType ${selectType}`);
    ScreenMagnificationTypeController.screenMagnificationType = selectType;
    SettingsDataUtils.setSecureValue(SCREEN_MAGNIFICATION_TYPE_KEY, String(selectType));
  }

  updateStatus(): void {
    this.refreshUi();
  }

  getScreenMagnificationType(): string {
    // accessibility_magnification_capability  1-全局放大 2-局部放大 3-缩放区域切换
    let type: string = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION_TYPE_KEY, '1')
    ScreenMagnificationTypeController.screenMagnificationType = Number.parseInt(type);
    return type;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    if (this.dataHelper) {
      this.registerStatusChange();
    } else {
      (SettingsDataUtils.createDataHelper(SCREEN_MAGNIFICATION_TYPE_KEY) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            this.registerStatusChange();
          }
        })
    }
    LogUtil.info(`{TAG} zoom gesture state listener registerd`);
  }

  public onDataChange = () => {
    this.getScreenMagnificationType();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ZOOM_GESTUIRE_TYPE,
      String(ScreenMagnificationTypeController.screenMagnificationType));
    this.refreshUi();
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    this.unRegisterStatusChange();
  }

  protected async registerStatusChange(): Promise<void> {
    if (!this.dataHelper) {
      LogUtil.error(`${TAG} dataHelper is null`);
      return;
    }
    SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION_TYPE_KEY, this.onDataChange);
  }

  protected async unRegisterStatusChange(): Promise<void> {
    if (!this.dataHelper) {
      return;
    }
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION_TYPE_KEY);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getScreenMagnificationType();
    this.refreshUi();
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterDataChange()
  }

  private refreshUi(): void {
    // 刷新文本
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: MAGNIFICATION_TYPES_ARRAY[ScreenMagnificationTypeController.screenMagnificationType - 1] }
        } as SettingResultState]]));
    // 刷新菜单列表
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: MAGNIFICATION_TYPES_ARRAY,
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          LogUtil.info(`${TAG} onSelect screen magnification index: ${index}`);
          ScreenMagnificationTypeController.updateTouchScreenType(index);
        },
        defaultFocus: ScreenMagnificationTypeController.screenMagnificationType - 1,
      } as SettingSelectMenuState]]));
  }
}
