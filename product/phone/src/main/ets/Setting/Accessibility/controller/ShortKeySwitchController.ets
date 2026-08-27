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
import { BusinessError } from '@ohos.base';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { a11yInitData } from '../sendable/A11yInitData';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  SHORTCUT_ENABLED,
} from '../constant/Constants';

const TAG: string = 'ShortKeySwitchController : ';

export class ShortKeySwitchController implements ComponentControl {
  public shortKeyState: boolean = false;
  protected isRegister: boolean = false;
  private static switchState: boolean = true;
  private compId: string = '';
  private configObserver = (data: boolean): void => {
    if (ShortKeySwitchController.switchState === data) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.ACCESSIBILITY_SHORTCUT_SWITCH, data ? 'on' : 'off');
      ShortKeySwitchController.switchState = !data;
    }
    this.shortKeyState = data;
    a11yInitData.shortkeyState = data;
    LogUtil.info(`${TAG} shortKey state change:${data}`);
    this.updateStatus();
  };
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`)
    this.handleCheckedChange(isChecked);
  };

  async getAccessibilityConfig(): Promise<void> {
    let result: boolean = false;
    result = SettingsDataUtils.getSecureValue(SHORTCUT_ENABLED, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} reload shortKeyState success:${result}`);
    this.shortKeyState = result;
    a11yInitData.shortkeyState = result;
  }

  /**
   * 返回开关的实时状态
   */
  updateStatus(): void {
    ShortKeySwitchController.switchState = this.shortKeyState;
    this.refreshUi();
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    AccessibilitySettingModel.accessibilityConfigSetting('shortKey', isChecked);
    if (ShortKeySwitchController.switchState || isChecked) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.ACCESSIBILITY_SHORTCUT_SWITCH, isChecked ? 'on' : 'off');
      ShortKeySwitchController.switchState = true;
    }
    return true;
  }

  protected registerDataChange(): void {
    try {
      config.shortkey.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe shortKey, because ${err?.message}`);
    }
    this.registerStatusChange();
  }

  protected registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = true;
    }
  }

  protected readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.compId ?? ' ';
    },
    onBundleAdd: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback add`);
    },
    onBundleRemove: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove`);
      config.shortkey.get().then((data: boolean) => {
        LogUtil.info(`${TAG} shortkey state is:${data}`);
        this.shortKeyState = data;
        this.updateStatus();
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} short key get failed: ${error?.message}`);
      });
    },
    onBundleUpdate: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback update`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    try {
      config.shortkey.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe shortKey, because ${err?.message}`);
    }
    this.unRegisterStatusChange();
  }

  private unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = false;
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.shortkeyState}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.info(`${TAG} this.compId: ${this.compId}`);
    // 从onpageshow中转移到init中处理
    await this.getAccessibilityConfig();
    this.refreshUi();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterDataChange();
  }

  async onPageShow(): Promise<void> {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.shortKeyState } } as SettingResultState]]));
  }
}
