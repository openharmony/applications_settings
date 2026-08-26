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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BusinessError } from '@ohos.base';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
  SettingSelectMenuState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED,
  COLOR_FILTER_CORRECTION_MODE_ARRAY,
  ColorFilterType,
  SelectColorFilterCorrectionValue
} from '../constant/Constants';
import { a11yInitData } from '../sendable/A11yInitData';

const TAG: string = 'CorrectionModeController : ';
const CORRECTION_MODE_SWITCH_ON = '1';
const CORRECTION_MODE_SWITCH_OFF = '0';

export class CorrectionModeController implements ComponentControl {
  public static selectColorFilterType: number = ColorFilterType.COLOR_FILTER_DEFAULT;
  public static selectColorFilterContent: ResourceStr = '';
  public static colorFilterState: boolean = false;
  private itemModel?: SettingItemModel;
  private compId: string = '';
  private configObserverState = (data: boolean): void => {
    CorrectionModeController.colorFilterState = data;
    a11yInitData.daltonizationState = data;
    this.refreshUi();
    LogUtil.info(`${TAG} Register color filter state change ${data}`);
  };
  private configObserverColorFilter = (data: config.DaltonizationColorFilter): void => {
    CorrectionModeController.selectColorFilterContent =
      CorrectionModeController.getColorFilterTypeResourceStr(data);
    CorrectionModeController.selectColorFilterType = this.fromStrToNumber(data);
    this.refreshContent();
    LogUtil.info(`${TAG} Register color filter mode change ${data}`);
  };

  public static onMenuChange(colorFilterType: number): void {
    LogUtil.info(`${TAG} onMenuChange: ${colorFilterType}`);
    let targetName: config.DaltonizationColorFilter = SelectColorFilterCorrectionValue.DEFAULT;
    switch (colorFilterType) {
      case ColorFilterType.COLOR_FILTER_DEUTERANOMALY:
        targetName = SelectColorFilterCorrectionValue.DEUTERANOMALY;
        break;
      case ColorFilterType.COLOR_FILTER_PROTANOMALY:
        targetName = SelectColorFilterCorrectionValue.PROTANOMALY;
        break;
      case ColorFilterType.COLOR_FILTER_TRITANOMALY:
        targetName = SelectColorFilterCorrectionValue.TRITANOMALY;
        break;
      default:
        targetName = SelectColorFilterCorrectionValue.DEFAULT;
    }
    config.daltonizationColorFilter.set(targetName).then(() => {
      LogUtil.info(`${TAG} accessibilityConfigSetting color filter success: ${targetName}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityConfigSetting color filter fail: ${targetName} err: ${err?.message}`);
    });
    CorrectionModeController.selectColorFilterType = colorFilterType;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.CHOOSE_COLOR_FILTER_RADIO, targetName);
  }

  public static getColorFilterTypeResourceStr(colorFilterType: string): ResourceStr {
    LogUtil.info(`${TAG} getColorFilterTypeResourceStr: ${colorFilterType}`);
    let colorFilterTypeResourceStr: ResourceStr = '';
    switch (colorFilterType) {
      case SelectColorFilterCorrectionValue.DEUTERANOMALY:
        colorFilterTypeResourceStr = COLOR_FILTER_CORRECTION_MODE_ARRAY[0];
        break;
      case SelectColorFilterCorrectionValue.PROTANOMALY:
        colorFilterTypeResourceStr = COLOR_FILTER_CORRECTION_MODE_ARRAY[1];
        break;
      case SelectColorFilterCorrectionValue.TRITANOMALY:
        colorFilterTypeResourceStr = COLOR_FILTER_CORRECTION_MODE_ARRAY[2];
        break;
      case SelectColorFilterCorrectionValue.DEFAULT:
        colorFilterTypeResourceStr = COLOR_FILTER_CORRECTION_MODE_ARRAY[3];
        break;
      default:
        colorFilterTypeResourceStr = COLOR_FILTER_CORRECTION_MODE_ARRAY[3];
        LogUtil.error(`${TAG} failed to find color filter type`);
        break;
    }
    return colorFilterTypeResourceStr;
  }

  public getColorFilterTypeStr(colorFilterType: number): string {
    let targetName: config.DaltonizationColorFilter = SelectColorFilterCorrectionValue.DEFAULT;
    switch (colorFilterType) {
      case ColorFilterType.COLOR_FILTER_DEUTERANOMALY:
        targetName = SelectColorFilterCorrectionValue.DEUTERANOMALY;
        break;
      case ColorFilterType.COLOR_FILTER_PROTANOMALY:
        targetName = SelectColorFilterCorrectionValue.PROTANOMALY;
        break;
      case ColorFilterType.COLOR_FILTER_TRITANOMALY:
        targetName = SelectColorFilterCorrectionValue.TRITANOMALY;
        break;
      default:
        targetName = SelectColorFilterCorrectionValue.DEFAULT;
    }
    return targetName;
  }

  public fromStrToNumber(targetName: string): number {
    let colorFilterType: ColorFilterType = ColorFilterType.COLOR_FILTER_DEFAULT;
    switch (targetName) {
      case SelectColorFilterCorrectionValue.DEUTERANOMALY:
        colorFilterType = ColorFilterType.COLOR_FILTER_DEUTERANOMALY;
        break;
      case SelectColorFilterCorrectionValue.PROTANOMALY:
        colorFilterType = ColorFilterType.COLOR_FILTER_PROTANOMALY;
        break;
      case SelectColorFilterCorrectionValue.TRITANOMALY:
        colorFilterType = ColorFilterType.COLOR_FILTER_TRITANOMALY;
        break;
      default:
        colorFilterType = ColorFilterType.COLOR_FILTER_DEFAULT;
    }
    return colorFilterType;
  }

  private setColorFilterEnableState(data: boolean): void {
    if (data) {
      SettingsDataUtils.setSettingsData(ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED, CORRECTION_MODE_SWITCH_ON);
    } else {
      SettingsDataUtils.setSettingsData(ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED, CORRECTION_MODE_SWITCH_OFF);
    }
  }

  async getColorFilterStateConfig(): Promise<void> {
    let initializationState: boolean | undefined = a11yInitData.daltonizationState;
    if (initializationState === undefined) {
      LogUtil.error(`${TAG} a11yInitData shortKeyState is undefined, try reload`);
      try {
        await config.daltonizationState.get().then((value: boolean) => {
          if (CorrectionModeController.colorFilterState !== value) {
            LogUtil.info(`${TAG} initializationState refresh`);
            CorrectionModeController.colorFilterState = value;
            a11yInitData.daltonizationState = value;
            this.setColorFilterEnableState(value);
          }
        });
        LogUtil.info(`${TAG} reload shortKeyState success:${CorrectionModeController.colorFilterState}`);
      } catch (err) {
        LogUtil.error(`${TAG} reload shortKeyState error: ${err?.message}`);
      }
    } else {
      CorrectionModeController.colorFilterState = a11yInitData.daltonizationState as boolean;
      this.setColorFilterEnableState(CorrectionModeController.colorFilterState);
    }
  }

  async getColorFilterTypeConfig(): Promise<void> {
    await config.daltonizationColorFilter.get().then((data: config.DaltonizationColorFilter) => {
      let selectColorFilter = data;
      if (selectColorFilter !== this.getColorFilterTypeStr(CorrectionModeController.selectColorFilterType)) {
        CorrectionModeController.selectColorFilterType = this.fromStrToNumber(selectColorFilter);
        LogUtil.info(`${TAG} getColorFilterTypeConfig success`);
      }
      CorrectionModeController.selectColorFilterContent = CorrectionModeController.getColorFilterTypeResourceStr(data);
      LogUtil.info(`${TAG} get selectColorFilter success：${data}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get selectColorFilter, because：${err?.message}`);
    });
  }

  public static isColorFilterEnable(): boolean {
    let colorFilterState: boolean = SettingsDataUtils.getSettingsData(
      ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED, CORRECTION_MODE_SWITCH_OFF) === CORRECTION_MODE_SWITCH_ON;
    LogUtil.info(`${TAG} isColorFilterEnable: ${colorFilterState}`)
    return colorFilterState;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    try {
      config.daltonizationState.on(this.configObserverState);
      config.daltonizationColorFilter.on(this.configObserverColorFilter);
    } catch (err) {
      CorrectionModeController.colorFilterState = false;
      LogUtil.error(`${TAG} failed subscribe color filter state, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unregisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.daltonizationState.off(this.configObserverState);
      config.daltonizationColorFilter.off(this.configObserverColorFilter);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe color filter state, because ${err?.message}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.daltonizationState}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.itemModel = compParam.component as SettingItemModel;
    this.compId = compParam.compId;
    await this.getColorFilterStateConfig();
    await this.getColorFilterTypeConfig();
    this.refreshUi();
    this.refreshContent();
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unregisterDataChange();
  }

  private refreshUi(): void {
    this.itemModel?.onItemEvent?.(new Map<SettingStateType, SettingBaseState>([[
      SettingStateType.STATE_TYPE_ITEM_ENABLED,
      { state: CorrectionModeController.colorFilterState } as SettingCompState]]));
  }

  private refreshContent(): void {
    // 刷新文本
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: CorrectionModeController.selectColorFilterContent }
        } as SettingResultState]]));
    // 刷新菜单列表
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: COLOR_FILTER_CORRECTION_MODE_ARRAY,
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          LogUtil.info(`${TAG} onSelect color filter index: ${index}`);
          CorrectionModeController.onMenuChange(index);
        },
        defaultFocus: CorrectionModeController.selectColorFilterType,
      } as SettingSelectMenuState]]));
  }
}