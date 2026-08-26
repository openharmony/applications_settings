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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';

const TAG: string = 'AccessibilityZoomGestureSettingsController : ';
const SCREEN_MAGNIFICATION: string = 'accessibility_display_magnification_enabled';
const A11Y_CONFIG_CLONE: string = 'accessibility_config_clone';
const STATUS_ON: string = '1';
const STATUS_OFF: string = '0';

/**
 * 放大手势控制器
 *
 * @since 2024-08-08
 */
export class ZoomGestureSettingsController implements ComponentControl {
  public zoomGestureState: boolean = false;
  protected dataHelper?: dataShare.DataShareHelper;
  private compId: string = '';

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    LogUtil.info(`${TAG} zoom gesture status data change`);
    this.zoomGestureState = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION, STATUS_OFF) === STATUS_ON;
    this.refreshUi();
  }

  /**
   * 克隆场景，监听克隆事件变化回调
   */
  public onCloneDataChange = () => {
    let cloneConfigState: boolean = SettingsDataUtils.getSettingsData(A11Y_CONFIG_CLONE, STATUS_OFF) === STATUS_ON;
    if (cloneConfigState === true) {
      LogUtil.info(`${TAG} on clone config state change: ${cloneConfigState}`);
      this.zoomGestureState = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION, STATUS_OFF) === STATUS_ON;
      this.refreshUi();
    }
  }

  async getAccessibilityConfig(): Promise<void> {
    let isEnabled: boolean = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION, STATUS_OFF) === STATUS_ON;
    this.zoomGestureState = isEnabled;
    LogUtil.info(`${TAG} get zoomGestureState success:${isEnabled}`);
  }

  /**
   * 监听手势放大开关的实时状态以及克隆完成状态
   */
  protected async registerSecurityDataChange(): Promise<void> {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION, this.onDataChange);
      SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SCREEN_MAGNIFICATION) as Promise<dataShare.DataShareHelper>).then((
        dataShareHelper?: dataShare.DataShareHelper | undefined) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SCREEN_MAGNIFICATION, this.onDataChange);
          SettingsDataUtils.registerDataChange(this.dataHelper, A11Y_CONFIG_CLONE, this.onCloneDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} zoom gesture key listener registerd`);
  }

  /**
   * 取消监听屏幕朗读开关的实时状态以及克隆完成状态
   */
  protected async unRegisterSecurityDataChange(): Promise<void> {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper, SCREEN_MAGNIFICATION);
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, A11Y_CONFIG_CLONE);
    LogUtil.info(`${TAG} zoom gesture key listener unregisterd`);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi();
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

  private refreshUi(): void {
    let statusResult: ResourceStr =
      this.zoomGestureState ? $r('app.string.accessibility_on') : $r('app.string.accessibility_off');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
  }
}
