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

import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { NFCUtil } from '@ohos/settings.moreconnection/src/main/ets/NFCUtil';
import { NFCSwitchController } from './NFCSwitchController';

/* instrument ignore file */

const TAG: string = 'NFCPageControl';

export class NFCPageControl implements ComponentControl {
  private nfcSwitchController: NFCSwitchController;

  constructor(control: NFCSwitchController) {
    this.nfcSwitchController = control;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    NFCUtil.getInstance().start();
  };

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    if (!CommonUtils.isPageExist(NavEntryKey.MORE_CONNECTION_ENTRY) &&
      !CommonUtils.isPageExist(NavEntryKey.NFC_ENTRY)) {
      NFCUtil.getInstance().stop();
    } else {
      LogUtil.info(`${TAG} more_connection_entry or nfc_entry exist, do not stop`);
    }
  };

  onPageShow(component: SettingBaseModel): void {
    this.nfcSwitchController.onPageShow(component);
  };

  onPageHide(component: SettingBaseModel): void {
  };
}