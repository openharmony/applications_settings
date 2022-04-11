/**
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

import geolocation from '@ohos.geolocation';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

export class LocationService {
  mIsStart: boolean = false;
  mListener: any;

  startService() {
    if (this.mIsStart) {
      return;
    }
    LogUtil.info(ConfigData.TAG + 'start location service')
    this.mIsStart = true;
    this.getServiceState();
    geolocation.on('locationServiceState', (isChanged: boolean) => {
      LogUtil.info(ConfigData.TAG + `start location service isChanged: ${JSON.stringify(isChanged)}`)
      this.getServiceState();
    });
  }

  registerListener(listener: {
    'updateServiceState': Function,
  }) {
    LogUtil.info(ConfigData.TAG + `register locations listener : ${listener}`)
    this.mListener = listener;
  }

  getServiceState() {
    LogUtil.info(ConfigData.TAG + 'get location state')
    geolocation.isLocationEnabled().then((data) => {
      LogUtil.info(ConfigData.TAG + `get location state, data: ${JSON.stringify(data)}`)
      this.mListener?.updateServiceState(data);
    });
  }

  enableLocation() {
    LogUtil.info(ConfigData.TAG + 'enable location')
    geolocation.enableLocation()
      .then((res) => LogUtil.info(ConfigData.TAG + `enable location, result: ${JSON.stringify(res)}`));
  }

  disableLocation() {
    LogUtil.info(ConfigData.TAG + 'disable location')
    geolocation.disableLocation()
      .then((res) => LogUtil.info(ConfigData.TAG + `disable location, result: ${JSON.stringify(res)}`));
  }
}

let locationService = new LocationService();

export default locationService as LocationService;
