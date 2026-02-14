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

import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { MASK_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HotspotUsbController } from './HotspotUsbController';
/* instrument ignore file */
const TAG: string = 'HotspotDeviceGroupController: ';

export class HotspotDeviceGroupController implements ComponentControl {

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    const dataSource = (compParam.dataSource) as OrderedDataSource;
    const hotspotUsbController = new HotspotUsbController();
    dataSource.push({
      id: 'hotspot_device_usb',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.hotspot_usb'), style: { opacity: MASK_OPACITY } },
      desc: {
        content: hotspotUsbController.getDespContent(false, false), style: { opacity: MASK_OPACITY }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: false,
          enabled: false,
        }
      },
      compControl: hotspotUsbController,
    });
  }

  destroy(): void {
  }
}