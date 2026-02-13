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

import constant from '@ohos.bluetooth.constant';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ProfileId } from '../../model/BluetoothModel';
import { BluetoothStrategySwitchMenuController } from './BluetoothStrategySwitchMenuController';

/* instrument ignore file */
export class HfpStrategySwitchMenuController extends BluetoothStrategySwitchMenuController {
  public tag: string = 'HfpStrategySwitchMenuController: ';
  public compId?: string;

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    this.compId = compParam.compId;
    LogUtil.info(`${this.tag} init compId: ${this.compId}`);
    super.init(compParam);
  }

  protected getProfileId(): ProfileId {
    return ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY;
  }

  protected getConnectProfileId(): constant.ProfileId {
    return constant.ProfileId.PROFILE_HANDSFREE_AUDIO_GATEWAY;
  }

  getListenKey(): string {
    return 'Hfp_Strategy_Switch_Menu_Controller';
  }
}