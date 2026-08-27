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
import collections from '@arkts.collections';
import {
  BundleStatusChangeManager,
  BundleStatusChangeListener
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AccessibilityCommonModel } from '../utils/AccessibilityCommonModel';
import { a11yInitData } from '../sendable/A11yInitData';

const TAG: string = 'ShortKeySettingsController : ';

/**
 *辅助功能快捷键
 *
 * @since 2024-08-08
 */
export class ShortKeySettingsController implements ComponentControl {
  public selectName: ResourceStr = '';
  public shortkeyMultiTargets: string[] = [];
  public isEnabled = false;
  private isRegister: boolean = false;
  private compId: string = '';
  private configObserverTargets = (data: string[]): void => {
    this.shortkeyMultiTargets = data;
    a11yInitData.shortkeyMultiTargets = collections.Array.from(data);
    LogUtil.info(`${TAG} shortkeyMultiTargets changed:${data}`);
    this.updateAbilityName(this.isEnabled);
  };
  private configObserverShortkey = (data: boolean): void => {
    this.isEnabled = data;
    a11yInitData.shortkeyState = data;
    LogUtil.info(`${TAG} shortkey state changed:${data}`);
    this.updateAbilityName(this.isEnabled);
  };

  async getAccessibilityConfig(): Promise<void> {
    let initializationState: boolean | undefined = a11yInitData.shortkeyState;
    if (initializationState === undefined) {
      LogUtil.error(`${TAG} a11yInitData shortKeyState is undefined, try reload`);
      try {
        await config.shortkey.get().then((value: boolean) => {
          if (this.isEnabled !== value) {
            LogUtil.info(`${TAG} shortkeyState refresh`);
            this.isEnabled = value;
            a11yInitData.shortkeyState = value;
          }
        });
        await config.shortkeyMultiTargets.get().then((value: string[]) => {
          if (this.shortkeyMultiTargets !== value) {
            LogUtil.info(`${TAG} shortkeyMultiTargets refresh`);
            this.shortkeyMultiTargets = value;
            a11yInitData.shortkeyMultiTargets = collections.Array.from(value);
          }
        });
        LogUtil.info(`${TAG} reload success, shortKeyState: ${this.isEnabled},
          shortkeyMultiTargets: ${this.shortkeyMultiTargets}`);
      } catch (err) {
        LogUtil.error(`${TAG} reload shortKeyState error: ${err?.message}`);
      }
    } else {
      this.shortkeyMultiTargets = [...a11yInitData.shortkeyMultiTargets];
      this.isEnabled = a11yInitData.shortkeyState as boolean;
    }
  }

  async updateAbilityName(data: boolean): Promise<void> {
    const context: Context = getContext(this);
    if (data) {
      this.selectName = await AccessibilityCommonModel.getSelectAbilityResourceName(
        context, this.shortkeyMultiTargets[0]);
      if (this.shortkeyMultiTargets.length > 1) {
        this.selectName = $r('app.string.multi_targets', this.selectName);
      }
      LogUtil.info(`${TAG} selectName: ${this.selectName}`);
    } else {
      this.selectName = $r('app.string.shortkey_close');
    }
    this.refreshUi();
  }

  protected registerDataChange(): void {
    try {
      this.registerStatusChange();
    } catch (error) {
      LogUtil.error(`${TAG} register status change failed: ${error?.message}`);
    }
  }

  protected registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      config.shortkeyMultiTargets.on(this.configObserverTargets);
      config.shortkey.on(this.configObserverShortkey);
      this.isRegister = true;
    }
  }

  protected readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.compId ?? ' ';
    },
    onBundleAdd: (bundleName, userId) => {
    },
    onBundleRemove: (bundleName, userId) => {
      this.updateAbilityName(this.isEnabled);
    },
    onBundleUpdate: (bundleName, userId) => {
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    try {
      this.unRegisterStatusChange();
    } catch (error) {
      LogUtil.error(`${TAG} unRegister status change failed: ${error?.message}`);
    }
  }

  private unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      config.shortkeyMultiTargets.off(this.configObserverTargets);
      config.shortkey.off(this.configObserverShortkey);
      this.isRegister = false;
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.shortkeyState}, shortkeyMultiTargets:${this.shortkeyMultiTargets}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.updateAbilityName(this.isEnabled);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.selectName } } as SettingResultState]]));
  }
}