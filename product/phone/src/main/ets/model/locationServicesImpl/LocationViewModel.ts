/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import LocationService from './LocationService';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

export const LocationServiceOpenStatusKey = "LocationServiceStatus";

export class LocationVM {
  mIsStart: boolean = false;

  initViewModel() {
    if (this.mIsStart) {
      return;
    }
    LogUtil.info(ConfigData.TAG + 'init location view model')
    this.mIsStart = true;
    LocationService.registerListener(this);
    LocationService.startService();
  }

  updateServiceState(state) {
    LogUtil.info(ConfigData.TAG + `update location service state, state: ${state} `)
    AppStorage.SetOrCreate(LocationServiceOpenStatusKey, state);
  }

  enableLocation() {
    LogUtil.info(ConfigData.TAG + 'enable location')
    LocationService.enableLocation();
  }

  disableLocation() {
    LogUtil.info(ConfigData.TAG + 'disable location')
    LocationService.disableLocation();
  }
}

let locationVM = new LocationVM();

export default locationVM as LocationVM;
