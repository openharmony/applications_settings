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
import config from '@ohos.accessibility.config';
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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BusinessError } from '@ohos.base';
import { SelectTouchDurationValue, TOUCH_DURATION_TYPES_ARRAY, TouchScreenType } from '../constant/Constants';
import { AccessibilityCommonModel } from '../utils/AccessibilityCommonModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'TouchDurationTypeController: ';

export class TouchDurationTypeController implements ComponentControl {
  public static touchDurationType: number = TouchScreenType.TOUCH_SCREEN_SHORT;
  public settingItemModel?: SettingItemModel;
  public clickResponseTime: ResourceStr = '';
  public selectClickResponseTime: ResourceStr = '';
  private compId: string = '';
  private configObserver = (data: config.ClickResponseTime): void => {
    this.clickResponseTime = AccessibilityCommonModel.getSelectTouchDurationName(data);
    TouchDurationTypeController.touchDurationType = this.fromTouchScreenStrToNumber(data);
    this.updateStatus();
    LogUtil.info(`${TAG} TargetName change  ${data}`);
  };

  public static updateTouchScreenType(touchScreenType: number): void {
    LogUtil.info(`${TAG} onMenuChange: ${touchScreenType}`);
    let targetName: config.ClickResponseTime = SelectTouchDurationValue.DEFAULTSHORT;
    switch (touchScreenType) {
      case TouchScreenType.TOUCH_SCREEN_SHORT:
        targetName = SelectTouchDurationValue.DEFAULTSHORT;
        break;
      case TouchScreenType.TOUCH_SCREEN_MEDIUM:
        targetName = SelectTouchDurationValue.MEDIUM;
        break;
      case TouchScreenType.TOUCH_SCREEN_LONG:
        targetName = SelectTouchDurationValue.LONG;
        break;
      default:
        targetName = SelectTouchDurationValue.DEFAULTSHORT;
    }
    AppStorage.setOrCreate<config.ClickResponseTime>('ClickResponseTime', targetName);
    config.clickResponseTime.set(targetName).then(() => {
      LogUtil.info(`${TAG} accessibilityConfigSetting touch duration success: ${targetName}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityConfigSetting touch duration fail: ${targetName} err: ${err?.message}`);
    });
    TouchDurationTypeController.touchDurationType = touchScreenType;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.CHOOSE_TOUCH_DURATION_RADIO, targetName);
  }

  findTargetName(): void {
    this.selectClickResponseTime = this.clickResponseTime;
    LogUtil.info(`${TAG} find select color filter  ${this.selectClickResponseTime}`);
  }

  updateStatus(): void {
    this.findTargetName();
    this.refreshUi();
  }

  public getTouchScreenTypeResourceStr(touchScreenType: number): ResourceStr {
    LogUtil.info(`${TAG} getTouchScreenTypeResourceStr: ${touchScreenType}`);
    let touchScreenTypeResourceStr: ResourceStr = '';
    switch (touchScreenType) {
      case TouchScreenType.TOUCH_SCREEN_SHORT:
        touchScreenTypeResourceStr = TOUCH_DURATION_TYPES_ARRAY[0];
        break;
      case TouchScreenType.TOUCH_SCREEN_MEDIUM:
        touchScreenTypeResourceStr = TOUCH_DURATION_TYPES_ARRAY[1];
        break;
      case TouchScreenType.TOUCH_SCREEN_LONG:
        touchScreenTypeResourceStr = TOUCH_DURATION_TYPES_ARRAY[2];
        break;
      default:
        touchScreenTypeResourceStr = TOUCH_DURATION_TYPES_ARRAY[0];
        break;
    }
    return touchScreenTypeResourceStr;
  }

  public fromTouchScreenStrToNumber(targetName: string): number {
    let touchScreenType: TouchScreenType = TouchScreenType.TOUCH_SCREEN_SHORT;
    switch (targetName) {
      case SelectTouchDurationValue.DEFAULTSHORT:
        touchScreenType = TouchScreenType.TOUCH_SCREEN_SHORT;
        break;
      case SelectTouchDurationValue.MEDIUM:
        touchScreenType = TouchScreenType.TOUCH_SCREEN_MEDIUM;
        break;
      case SelectTouchDurationValue.LONG:
        touchScreenType = TouchScreenType.TOUCH_SCREEN_LONG;
        break;
      default:
        touchScreenType = TouchScreenType.TOUCH_SCREEN_SHORT;
    }
    return touchScreenType;
  }

  public getTouchScreenTypeStr(touchScreenType: number): string {
    let targetName: config.ClickResponseTime = SelectTouchDurationValue.DEFAULTSHORT;
    switch (touchScreenType) {
      case TouchScreenType.TOUCH_SCREEN_SHORT:
        targetName = SelectTouchDurationValue.DEFAULTSHORT;
        break;
      case TouchScreenType.TOUCH_SCREEN_MEDIUM:
        targetName = SelectTouchDurationValue.MEDIUM;
        break;
      case TouchScreenType.TOUCH_SCREEN_LONG:
        targetName = SelectTouchDurationValue.LONG;
        break;
      default:
        targetName = SelectTouchDurationValue.DEFAULTSHORT;
    }
    return targetName;
  }

  async getTouchDurationTypeConfig(): Promise<void> {
    await config.clickResponseTime.get().then((data: config.ClickResponseTime) => {
      let selectTouchDuration = data;
      if (selectTouchDuration !== this.getTouchScreenTypeStr(TouchDurationTypeController.touchDurationType)) {
        TouchDurationTypeController.touchDurationType = this.fromTouchScreenStrToNumber(selectTouchDuration);
        LogUtil.info(`${TAG} getTouchDurationTypeConfig success`);
      }
      this.selectClickResponseTime = this.getTouchScreenTypeResourceStr(
        TouchDurationTypeController.touchDurationType);
      LogUtil.info(`${TAG} get touch duration success：${data}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get touch duration, because：${err?.message}`);
    });
  }

  protected registerDataChange(): void {
    this.registerStatusChange();
  }

  protected registerStatusChange(): void {
    try {
      config.clickResponseTime.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} shortkeyTarget config on fail, err: ${err?.message}`);
    }
  }

  /**
   * 取消监听实时状态
   */
  protected unRegisterDataChange(): void {
    this.unRegisterStatusChange();
  }

  private unRegisterStatusChange(): void {
    try {
      config.clickResponseTime.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe shortkeyTarget, because ${err?.message}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getTouchDurationTypeConfig();
    this.refreshUi();
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterDataChange();
  }

  private refreshUi(): void {
    // 刷新文本
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: this.selectClickResponseTime }
        } as SettingResultState]]));
    // 刷新菜单列表
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: TOUCH_DURATION_TYPES_ARRAY,
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          LogUtil.info(`${TAG} onSelect touchscreen index: ${index}`);
          TouchDurationTypeController.updateTouchScreenType(index);
        },
        defaultFocus: TouchDurationTypeController.touchDurationType,
      } as SettingSelectMenuState]]));
  }
}
