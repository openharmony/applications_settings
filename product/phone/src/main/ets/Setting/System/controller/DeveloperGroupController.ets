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
import { CompCtrlParam, ComponentControl} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SystemPageMenuManager } from './SystemPageMenuManager';

const TAG = 'DeveloperGroupController: ';

export class DeveloperGroupController implements ComponentControl {
  private compId: string = '';
  public dataSource?: OrderedDataSource;

  async init(compParam: CompCtrlParam): Promise<void> {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    if (!this.dataSource) {
      LogUtil.info(`${TAG} dataSource is invalid`);
      return;
    }
    let isCurrentPrivateUser: boolean = await AccountUtil.isCurrentPrivate();
    LogUtil.info(`${TAG} onPageShow isCurrentPrivateUser ${isCurrentPrivateUser} ${this.compId}`);
    this.initMenus(isCurrentPrivateUser);
  }

  initMenus(isPrivateUser: boolean): void {
    let developerMenu: ComparableSettingItemModel = {
      id: 'developer_options_settings',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.developer_options_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.DEVELOP_OPTION_ENTRY,
      },
      needHide: () => {
        return SystemPageMenuManager.getInstance().isDevelopOptionNotSupport() || SystemParamUtil.isSimulatorMode;
      }
    };
    let isPengLaiModeOpen: boolean = PenglaiUtil.isPengLaiModeOpen();
    if (isPengLaiModeOpen) {
      if (DeviceUtil.isBetaVersion) {
        this.pushDeveloperItem(isPrivateUser, developerMenu);
      }
      return;
    }
    this.pushDeveloperItem(isPrivateUser, developerMenu);
  }

  private pushDeveloperItem(isPrivateUser: boolean, developerMenu: ComparableSettingItemModel) {
    let developerStatus: boolean = SystemParamUtil.getParam('const.security.developermode.state', 'false') === 'true';
    let isDeviceEmulator: boolean = DeviceUtil.isDeviceEmulator();
    if (!isDeviceEmulator && !isPrivateUser && developerStatus) {
      this.dataSource?.pushData(developerMenu);
    }
  }

  destroy(): void {
  }
}