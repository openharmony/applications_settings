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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { BusinessError } from '@ohos.base';
import { SingleChoiceListController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import radio from '@ohos.telephony.radio';
import data from '@ohos.telephony.data';
import { SingleChoiceEntryMenu, SingleSelectMenuItem } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import observer from '@ohos.telephony.observer';
/* instrument ignore file */
const TAG: string = 'NrModeController : ';
const SLOT_ID_UNDEFINED: number = -1;

export default class NrModeController extends SingleChoiceListController {
  public menuList: SingleSelectMenuItem[] = [];
  public defaultSlotId = SLOT_ID_UNDEFINED;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateNrModeController(menu: SettingsBaseMenu): Controller {
    return new NrModeController(menu);
  }

  async aboutToAppear(): Promise<void> {
    this.defaultSlotId = await data.getDefaultCellularDataSlotId();
    LogUtil.info(`${TAG} aboutToAppear  defaultSlotId  ${this.defaultSlotId}`);
    if ((this.menu instanceof SingleChoiceEntryMenu) && this.menu.singleChoiceData != null) {
      this.menuList = this.menu.singleChoiceData;
    }
    observer.on('simStateChange', (simStateData: observer.SimStateData) => {
      this.defaultSlotId = data.getDefaultCellularDataSlotIdSync();
      LogUtil.info(`${TAG} simStateChange defaultSlotId = ${this.defaultSlotId}`);
      this.updateStatus();
    });

    observer.on('iccAccountInfoChange', value => {
      this.defaultSlotId = data.getDefaultCellularDataSlotIdSync();
      LogUtil.info(`${TAG} iccAccountInfoChange defaultSlotId = ${this.defaultSlotId}`);
      this.updateStatus();
    });
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    observer.off('simStateChange');
    observer.off('iccAccountInfoChange');
    super.aboutToDisappear();
  }

  onSelectMenuChanged(key: number): void {
    LogUtil.info(`${TAG} setNROptionMode data = ${key}`);
    radio.setNROptionMode(this.defaultSlotId, key).then(() => {
      LogUtil.info(`${TAG} setNROptionMode success data = ${key}`);
      this.updateStatus();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} setNROptionMode failed, promise: err->${err?.message}`);
    });
  }

  onBindMenuAppear(): void {
    LogUtil.info(`${TAG} onBindMenuAppear`);
    this.updateStatus();
  }

  onBindMenuDisAppear(): void {
    LogUtil.info(`${TAG} onBindMenuDisAppear`);
    this.updateStatus();
  }

  isNeedShowNrMode(): boolean {
    let isSupport = radio.isNRSupported();
    const isEflForbidden = SystemParamUtil.isEflForbidden();
    LogUtil.info(`${TAG} isNeedShowNrMode, isSupport = ${isSupport}, defaultSlotId = ${this.defaultSlotId}, isEflForbidden = ${isEflForbidden}`);
    return this.defaultSlotId !== SLOT_ID_UNDEFINED && isSupport && !isEflForbidden;
  }

  updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus begin`);
    if (!this.menuList || this.menuList.length === 0) {
      LogUtil.error(`${TAG} menuList is null.`);
      return;
    }
    if (this.isNeedShowNrMode()) {
      this.setVisible(true);
    } else {
      this.setVisible(false);
      return;
    }
    radio.getNROptionMode(this.defaultSlotId).then((data: radio.NROptionMode) => {
      LogUtil.info(`${TAG} updateStatus data = ${data}`);
      for (let item of this.menuList) {
        item.isSelect = item?.key === data;
      }
      this.refreshUi();
    }).catch((error: BusinessError) => {
      LogUtil.error('NrModeController updateStatus failed. Cause: ' + error?.message);
    }).finally(() => {
      LogUtil.debug('NrModeController updateStatus finally ');
    })
  }

  public getObserverKey = (): string => {
    LogUtil.info(`${TAG} getObserverKey`);
    return this.menu?.key as string;
  }
}