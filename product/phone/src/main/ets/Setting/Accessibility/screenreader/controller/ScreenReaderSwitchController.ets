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
import accessibility from '@ohos.accessibility';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SCREEN_READER_SWITCH, SECURITY_NOTIFICATION_MODEL_SHOW_EVENT } from '../../constant/Constants';
import { SettingsDataObserverUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataObserverUtils';

const SCREEN_READER_ON_KEY = 'accessibility_screenreader_enabled';
const SCREENREADER_NAME = 'com.ohos.screenreader/AccessibilityExtAbility';
const CAPACITY : accessibility.Capability[] = ['retrieve', 'touchGuide', 'keyEventObserver', 'gesture'];
const SCREEN_READER_TOGGLE: string = 'Setting.AccessibilityScreenReaderSettings.screenreader_switch_group.screenreader_switch';
const TAG: string = 'ScreenReaderSwitchController : ';

export class ScreenReaderSwitchController implements ComponentControl {
  public screenReaderState: boolean = false;
  public isChecked: boolean = false;
  public compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`)
    this.handleCheckedChange(isChecked);
  };
  private setTargetsAndRefreshCallback = (isOpen: boolean) => {
    LogUtil.info(`${TAG} setTargets success: ${isOpen}`);
    if (isOpen) {
      config.enableAbility(SCREENREADER_NAME, CAPACITY).then(() => {
        LogUtil.info(`${TAG} enable screenreader success`);
        this.setChecked(isOpen);
        this.setSettingsScreenReaderState(isOpen);
      }).catch((err: object) => {
        LogUtil.error(`${TAG} failed to enable screenreader`);
        this.updateStatus();
      })
    } else {
      this.isChecked = isOpen;
      notifyCompStateChange(SCREEN_READER_TOGGLE,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: isOpen } } as SettingResultState]]));
    }
  };

  async getAccessibilityConfig(): Promise<void> {
    let initializationState: boolean = this.screenReaderState;
    let status: boolean = SettingsDataUtils.getSettingsData(SCREEN_READER_ON_KEY, '0') === '1';
    this.screenReaderState = status;
    if (initializationState !== status) {
      LogUtil.info(`${TAG} initializationState refresh`);
      this.refreshUi();
    }
    LogUtil.info(`${TAG} get screenReader success:${this.screenReaderState}`);
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.updateStatus();
  }

  /**
   * 更新屏幕朗读开关的当前状态
   */
  updateStatus(): void {
    let status: string = SettingsDataUtils.getSettingsData(SCREEN_READER_ON_KEY, '0');
    LogUtil.info(`${TAG} Screen reader now page checked info is, ${this.isChecked}. new status is ${status}`);
    if (status === '1') {
      this.setChecked(true);
    } else {
      this.setChecked(false);
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (isChecked) {
      let screenReaderAlreadyEnable = SettingsDataUtils.getSettingsData(SCREEN_READER_ON_KEY, '0') === '1';
      if (!screenReaderAlreadyEnable) {
        LogUtil.info(`${TAG} switch button clicked from disable to enable`);
        EventBus.getInstance().emit(SECURITY_NOTIFICATION_MODEL_SHOW_EVENT, true);
      }
    } else {
      if (this.screenReaderState) {
        config.disableAbility(SCREENREADER_NAME).then(() => {
          LogUtil.info(`${TAG} disable accessibility success`);
          this.setChecked(false);
          this.setSettingsScreenReaderState(false);
        }).catch((err: object) => {
          LogUtil.error(`${TAG} failed to disable accessibility service, error`);
        })
      } else {
        this.setChecked(false);
      }
    }
    return true;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    LogUtil.info(`${TAG} ScreenReader key listener registerd`);
    SettingsDataObserverUtils.registerKeyObserver(SCREEN_READER_ON_KEY, this.onDataChange);
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    SettingsDataObserverUtils.unregisterKeyObserver(SCREEN_READER_ON_KEY, this.onDataChange);
  }

  /**
   * 设置开关的状态
   */
  setChecked(isChecked: boolean): void {
    LogUtil.info(`${TAG} setChecked ${isChecked}`);
    this.isChecked = isChecked;
    this.screenReaderState = isChecked;
    this.refreshUi();
  }

  setSettingsScreenReaderState(enableState?: boolean): void {
    if (enableState) {
      SettingsDataUtils.setSettingsData(SCREEN_READER_ON_KEY, '1');
    } else {
      SettingsDataUtils.setSettingsData(SCREEN_READER_ON_KEY, '0');
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.screenReaderState = SettingsDataUtils.getSettingsData(SCREEN_READER_ON_KEY, '0') === '1';
    this.refreshUi();
    this.getAccessibilityConfig();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().on(SCREEN_READER_SWITCH, this.setTargetsAndRefreshCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().detach(SCREEN_READER_SWITCH, this.setTargetsAndRefreshCallback);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    LogUtil.info(`${TAG} refreshUi, refresh : ${this.screenReaderState}`);
    notifyCompStateChange(SCREEN_READER_TOGGLE,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: this.screenReaderState }
        } as SettingResultState]]));
  }
}