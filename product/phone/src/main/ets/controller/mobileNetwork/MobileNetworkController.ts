/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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
import connection from '@ohos.net.connection';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import type ISettingsController
  from '../../../../../../../common/component/src/main/ets/default/controller/ISettingsController';
import SwitchController from '../../../../../../../common/component/src/main/ets/default/controller/SwitchController';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { LogAll } from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import parameter from '@ohos.systemparameter';

const MODULE_TAG = ConfigData.TAG + '.mobileNetworkController -> ';

@LogAll
export default class MobileNetworkController extends SwitchController {
    /**
     * Initialize data.
     */
    initData(): ISettingsController {
        super.initData();
        return this;
    }
    /**
     * Subscribe listeners.
     */
    subscribe(): ISettingsController {
        return this;
    };
    /**
     * Get MobileNetwork current functions state
     */
  getMobileNetworkCurrentFunctions(): void {
  }

    /**
     * After current value changed event
     */
  afterCurrentValueChanged(): void {
    LogUtil.info(MODULE_TAG + 'fff1111 isOn' + this.isOn);
    if (this.isOn) {
      connection.enableAirplaneMode().catch((err) => {
        LogUtil.info(MODULE_TAG + 'set enableAirplaneMode error' + JSON.stringify(err));
      });
    } else {
      connection.disableAirplaneMode().catch((err) => {
        LogUtil.info(MODULE_TAG + 'set disableAirplaneMode error' + JSON.stringify(err));
      });
    };
  }
}