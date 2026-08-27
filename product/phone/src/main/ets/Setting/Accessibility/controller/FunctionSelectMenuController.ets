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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BusinessError } from '@ohos.base';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  ACCESSIBILITY_FUNCTION_SELECT_TARGETS,
  FUNCTION_SELECT_SERVICES_ARRAY,
  FunctionSelectTargetNameValue
} from '../constant/Constants';
import { AccessibilityCommonModel } from '../utils/AccessibilityCommonModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG: string = 'FunctionSelectMenuController';

export class FunctionSelectMenuController {
  private dataHelper: dataShare.DataShareHelper | null = null;
  private compId: string = '';
  public static accessibilitySystemServiceList: string[] = ['HIGH_CONTRAST_TEXT', 'AUDIO_MONO', 'INVERT_COLOR'];
  public static shortKeyTargetsIdListCache: string[] = [];
  public static shortKeyTargetsIdList: string[] = [];
  public static selectExtensionService: string = '';
  public static selectNewExtensionService?: string[] = [];
  public isSelected: boolean = false;
  public static shortKeyTargets: string[] = [];
  protected isRegister: boolean = false;
  private configObserver = (data: string[]): void => {
    LogUtil.info(`${TAG} TargetList change  ${data}`);
    FunctionSelectMenuController.shortKeyTargets = data;
    this.updateStateStatus();
  };

  async getAccessibilityConfig(): Promise<void> {
    await config.shortkeyMultiTargets.get().then((value) => {
      FunctionSelectMenuController.shortKeyTargets = value;
    });
    FunctionSelectMenuController.setTargetsInfoList();
    LogUtil.info(`${TAG} get shortkeyMultiTargets success:${FunctionSelectMenuController.shortKeyTargets}`);
  }

  onMenuChange(itemName: string, isChecked: boolean,): void {
    LogUtil.info(`${TAG} ${itemName} onMenuChange: ${isChecked}`);
    if (itemName !== undefined) {
      if (isChecked && !FunctionSelectMenuController.shortKeyTargetsIdListCache.includes(itemName)) {
        FunctionSelectMenuController.shortKeyTargetsIdListCache.push(itemName);
      } else if (!isChecked &&
      FunctionSelectMenuController.shortKeyTargetsIdListCache.includes(itemName)) {
        FunctionSelectMenuController.shortKeyTargetsIdListCache.splice(
          FunctionSelectMenuController.shortKeyTargetsIdListCache.indexOf(itemName), 1);
      }
      LogUtil.info(`${TAG} ShortKeyTargetsIdListCache: ${FunctionSelectMenuController.shortKeyTargetsIdListCache},
        ShortKeyTargetsIdList: ${FunctionSelectMenuController.shortKeyTargetsIdList}`);
    } else {
      LogUtil.error(`${TAG} onMenuChange get targetName fail`);
    }
  }

  public static getFromStrToResourceStr(targetName: string): ResourceStr {
    let resourceStrValue: ResourceStr = '';
    switch (targetName) {
      case FunctionSelectTargetNameValue.HIGH_CONTRAST_TEXT:
        resourceStrValue = FUNCTION_SELECT_SERVICES_ARRAY[0];
        break;
      case FunctionSelectTargetNameValue.SINGLE_AUDIO:
        resourceStrValue = FUNCTION_SELECT_SERVICES_ARRAY[1];
        break;
      case FunctionSelectTargetNameValue.INVERT_COLOR:
        resourceStrValue = FUNCTION_SELECT_SERVICES_ARRAY[2];
        break;
      default:
        break;
    }
    return resourceStrValue;
  }

  async init(): Promise<void> {
    LogUtil.info(`${TAG} init`);
    await this.getAccessibilityConfig();
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unRegisterDataChange();
  }

  protected registerDataChange(): void {
    this.registerStatusChange();
  }

  protected registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = true;
    }
    try {
      config.shortkeyMultiTargets.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} shortkeyTarget config on fail, err: ${err?.message}`);
    }
  }

  protected readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.compId ?? ' ';
    },
    onBundleAdd: (bundleName, userId) => {
      this.listenIntermediateMethod();
    },
    onBundleRemove: (bundleName, userId) => {
      this.listenIntermediateMethod();
    },
    onBundleUpdate: (bundleName, userId) => {
      this.listenIntermediateMethod();
    }
  }

  async listenIntermediateMethod(): Promise<void> {
    this.updateStateStatus();
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    this.unRegisterStatusChange();
  }

  private unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = false;
    }
    try {
      config.shortkeyMultiTargets.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe shortkeyTarget, because ${err?.message}`);
    }
  }

  async setTargets(): Promise<void> {
    let targets = FunctionSelectMenuController.shortKeyTargetsIdListCache.filter((target: string) =>
      FunctionSelectMenuController.accessibilitySystemServiceList.includes(target));
    FunctionSelectMenuController.shortKeyTargetsIdListCache = JSON.parse(JSON.stringify(targets));
    let value = 'OK';
    HiSysEventUtil.abilityReportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.CLICK_SELECT_FUNCTION, targets.join(','), value);
    await config.shortkeyMultiTargets.set(targets).then(() => {
      FunctionSelectMenuController.shortKeyTargetsIdList = targets;
      this.configObserver(targets);
      LogUtil.info(`${TAG} shortkey targets set success: ${targets}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} shortkey set failed, err: ${err?.message}`);
    });
  }

  async findTargetsName(): Promise<void> {
    const context: Context = getContext(this);
    FunctionSelectMenuController.selectExtensionService =
      await AccessibilityCommonModel.getSelectAbilityName(context, FunctionSelectMenuController.shortKeyTargets[0]);
    if (FunctionSelectMenuController.shortKeyTargets.length > 1) {
      FunctionSelectMenuController.selectExtensionService =
        ResourceUtil.getFormatStringSync($r('app.string.multi_targets'),
          FunctionSelectMenuController.selectExtensionService);
    }
    LogUtil.info(`${TAG} findTargetsName shortKeyTargets: ${FunctionSelectMenuController.shortKeyTargets},
      findTargetsName  ${FunctionSelectMenuController.selectExtensionService}`);
  }

  async setTargetsAndRefresh(): Promise<void> {
    await this.setTargets();
    LogUtil.info(`${TAG} setTargets success`);
    this.updateStateStatus();
  }

  async updateStateStatus(): Promise<void> {
    await this.findTargetsName();
    LogUtil.info(`${TAG} updateStatus ${this.compId}`);
    SettingsDataUtils.setSettingsData(ACCESSIBILITY_FUNCTION_SELECT_TARGETS,
      FunctionSelectMenuController.selectExtensionService);
  }

  static setTargetsInfoList(): void {
    FunctionSelectMenuController.shortKeyTargetsIdList =
      JSON.parse(JSON.stringify(FunctionSelectMenuController.shortKeyTargets));
    FunctionSelectMenuController.shortKeyTargetsIdListCache =
      JSON.parse(JSON.stringify(FunctionSelectMenuController.shortKeyTargets));
    LogUtil.info(`${TAG} ShortKeyTargetsIdListCache: ${FunctionSelectMenuController.shortKeyTargetsIdListCache},
      ShortKeyTargetsIdList: ${FunctionSelectMenuController.shortKeyTargetsIdList}`);
  }

  async getNewExtensionService(): Promise<void> {
    let newTargets: string[] = FunctionSelectMenuController.shortKeyTargetsIdListCache;
    let historyTargets: string[] = FunctionSelectMenuController.shortKeyTargetsIdList;
    let systemServiceTargets: string[] = FunctionSelectMenuController.accessibilitySystemServiceList;
    LogUtil.info(`${TAG} shortKeyTargetsIdListCache newTargets : ${newTargets}, historyTargets: ${historyTargets}`);
    FunctionSelectMenuController.selectNewExtensionService = newTargets.filter(
      item => !historyTargets.includes(item) && !systemServiceTargets.includes(item));
    LogUtil.info(`${TAG} selectNewExtensionService result: ${FunctionSelectMenuController.selectNewExtensionService}`);
    if (FunctionSelectMenuController.selectNewExtensionService.length > 0) {
      // 识别到有新增扩展服务
      LogUtil.info(`${TAG} find new services.`);
      new FunctionSelectMenuController().setTargetsAndRefresh();
    } else {
      this.setTargetsAndRefresh();
    }
  }
}