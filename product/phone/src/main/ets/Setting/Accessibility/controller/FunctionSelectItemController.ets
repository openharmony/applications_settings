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

import dataShare from '@ohos.data.dataShare';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FunctionSelectMenuController } from '../controller/FunctionSelectMenuController';
import { FunctionSelectTargetNameValue, FunctionSelectOriginNameValue } from '../constant/Constants'

/* instrument ignore file */
const TAG: string = 'FunctionSelectItemController';

export class FunctionSelectItemController {
  private dataHelper: dataShare.DataShareHelper | null = null;
  private compId: string = '';
  private itemName: string = '';
  public isSelected: boolean = false;
  protected isRegister: boolean = false;

  public checkItemName(itemName: string): string {
    return itemName;
  }

  onMenuChange(isChecked: boolean): void {
    LogUtil.info(`${TAG} ${this.itemName} onMenuChange: ${isChecked}`);
    if (this.itemName !== undefined) {
      if (isChecked && !FunctionSelectMenuController.shortKeyTargetsIdListCache.includes(this.itemName)) {
        FunctionSelectMenuController.shortKeyTargetsIdListCache.push(this.itemName);
        this.isSelected = true;
      } else if (!isChecked &&
      FunctionSelectMenuController.shortKeyTargetsIdListCache.includes(this.itemName)) {
        FunctionSelectMenuController.shortKeyTargetsIdListCache.splice(
          FunctionSelectMenuController.shortKeyTargetsIdListCache.indexOf(this.itemName), 1);
        this.isSelected = false;
      }
      LogUtil.info(`${TAG} ShortKeyTargetsIdListCache: ${FunctionSelectMenuController.shortKeyTargetsIdListCache},
        ShortKeyTargetsIdList: ${FunctionSelectMenuController.shortKeyTargetsIdList}`);
    } else {
      LogUtil.error(`${TAG} onMenuChange get targetName fail`);
    }
  }

  async init(itemName: string): Promise<void> {
    LogUtil.info(`${TAG} init`);
    this.itemName = itemName;
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unRegisterDataChange();
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    if (FunctionSelectMenuController.shortKeyTargetsIdList.indexOf(this.itemName) > -1) {
      this.isSelected = true;
      LogUtil.info(`${TAG} set Checkbox success`);
    }
  }

  protected registerDataChange(): void {
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
      return this.compId;
    },
    onBundleAdd: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback add`);
    },
    onBundleRemove: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove`);
      this.updateStatus();
    },
    onBundleUpdate: (bundleName: string, userId: number) => {
      LogUtil.info(`${TAG} bundleStatusCallback update`);
    }
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
  }
}