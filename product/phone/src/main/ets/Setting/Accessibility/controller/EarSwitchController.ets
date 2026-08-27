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
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { dataShare } from '@kit.ArkData';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { BluetoothAdapter, BluetoothProfileStateChangeListener } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { ProfileId, StateChangeParam } from '@ohos/settings.fusionconnectivity/src/main/ets/models/FusionModel';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityHearingAidModel } from '../utils/AccessibilityCommonModel';

export const SWITCH_NULL: string = 'null';
export const DEFAULT_VOLUME: number = -64;
export const MAX_VOLUME: number = 0;
export const MIN_VOLUME: number = -128;

/**
 * 助听器左右耳开关控制器
 *
 * @since 2025-04-28
 */
export class EarSwitchController implements ComponentControl, BluetoothProfileStateChangeListener {
  private compId: string = '';
  private tag: string = 'EarSwitchController: ';
  private dataSource?: OrderedDataSource;
  protected dataHelper?: dataShare.DataShareHelper;

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    this.registerHearingAidConnected();
    this.initMenus();
    EventBus.getInstance().on(`${this.compId}.hearing_aid_left_era_switch.toggle`, this.leftStateChangeCallback);
    EventBus.getInstance().on(`${this.compId}.hearing_aid_right_era_switch.toggle`, this.rightStateChangeCallback);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.hearing_aid_left_era_switch.toggle`,
      this.leftStateChangeCallback);
    EventBus.getInstance().detach(`${this.compId}.hearing_aid_right_era_switch.toggle`,
      this.rightStateChangeCallback);
  }

  private initMenus(): void {
    this.getLeftEarSwitchState();
    this.getRightEarSwitchState();
    this.leftEarSwitchItem();
    this.rightEarSwitchItem();
  }

  private leftStateChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} left toggleState ${toggleState.state}`);
    AccessibilityHearingAidModel.leftSwitchState = toggleState.state;
    if (AccessibilityHearingAidModel.leftSwitchState) {
      let value: string =
        SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SLIDER_VALUE, SWITCH_NULL);
      LogUtil.info(`${this.tag} leftEar volume value is ${value}`);
      let valueDb: number = AccessibilityHearingAidModel.volumeToDb(parseInt(value));
      AccessibilityHearingAidModel.setVolume(AccessibilityHearingAidModel.leftMacId, valueDb);
      SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SWITCH_KEY, '1');
    } else {
      SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SWITCH_KEY, '0');
      AccessibilityHearingAidModel.setVolume(AccessibilityHearingAidModel.leftMacId, MIN_VOLUME);
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ENTER_LEFT_EAR_SWITCH_CHANGE, AccessibilityHearingAidModel.leftSwitchState? 'on' : 'off');
  };

  private rightStateChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} right toggleState ${toggleState.state}`);
    AccessibilityHearingAidModel.rightSwitchState = toggleState.state;
    if (AccessibilityHearingAidModel.rightSwitchState) {
      let value: string =
        SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SLIDER_VALUE, SWITCH_NULL);
      LogUtil.info(`${this.tag} rightEar volume value is ${value}`);
      let valueDb: number = AccessibilityHearingAidModel.volumeToDb(parseInt(value));
      AccessibilityHearingAidModel.setVolume(AccessibilityHearingAidModel.rightMacId, valueDb);
      SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SWITCH_KEY, '1');
    } else {
      SettingsDataUtils.setSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SWITCH_KEY, '0');
      AccessibilityHearingAidModel.setVolume(AccessibilityHearingAidModel.rightMacId, MIN_VOLUME);
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ENTER_RIGHT_EAR_SWITCH_CHANGE, AccessibilityHearingAidModel.rightSwitchState? 'on' : 'off');
  };

  private leftEarSwitchItem(): void {
    this.dataSource?.pushData({
      id: 'hearing_aid_left_era_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.hearing_aid_left_era_device'),
        style: {
          textOverflow: TextOverflow.None
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: AccessibilityHearingAidModel.leftSwitchState },
      },
    });
  }

  private rightEarSwitchItem(): void {
    this.dataSource?.pushData({
      id: 'hearing_aid_right_era_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.hearing_aid_right_era_device'),
        style: {
          textOverflow: TextOverflow.None
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: AccessibilityHearingAidModel.rightSwitchState },
      },
    });
  }

  private getLeftEarSwitchState(): void {
    let leftSwitchState: string =
      SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.LEFT_EAR_SWITCH_KEY, SWITCH_NULL);
    LogUtil.info(`${this.tag} leftSwitchState is ${leftSwitchState}`);
    if (leftSwitchState === 'null' || leftSwitchState === '1') {
      AccessibilityHearingAidModel.leftSwitchState = true;
    } else if (leftSwitchState === '0') {
      AccessibilityHearingAidModel.leftSwitchState = false;
      AccessibilityHearingAidModel.setVolume(AccessibilityHearingAidModel.leftMacId, MIN_VOLUME);
    }
  }

  private getRightEarSwitchState(): void {
    let rightSwitchState: string =
      SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SWITCH_KEY, SWITCH_NULL);
    LogUtil.info(`${this.tag} rightSwitchState is ${rightSwitchState}`);
    if (rightSwitchState === 'null' || rightSwitchState === '1') {
      AccessibilityHearingAidModel.rightSwitchState = true;
    } else if (rightSwitchState === '0') {
      AccessibilityHearingAidModel.rightSwitchState = false;
      AccessibilityHearingAidModel.setVolume(AccessibilityHearingAidModel.rightMacId, MIN_VOLUME);
    }
  }

  private registerHearingAidConnected(): void {
    BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
    BluetoothAdapter.getInstance().registerProfileStateChangeListener(this);
  }

  getListenKey(): string {
    return 'Hearing_Aid_Controller';
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
    if (!stateChangeParam) {
      LogUtil.error(`${this.tag} stateChangeParam is null`);
      return;
    }
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
    if (!isSuccess) {
      LogUtil.error(`${this.tag} onConnectResult isSuccess is false`);
      return;
    }
  }
}