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
import LogUtil from '../../common/baseUtil/LogUtil.ets';
import ConfigData from '../../common/baseUtil/ConfigData.ets';
import Audio from '@ohos.multimedia.audio';

export default class VolumeModel {
  constructor() {
  }

  setVolume(volumeValue, volumeType){
    LogUtil.info(`settings setVolume volumeValue: ${JSON.stringify(volumeValue)} volumeType：${JSON.stringify(volumeType)} `);

    Audio.getAudioManager().setVolume(volumeType, volumeValue).then(() => {
      LogUtil.info('settings Promise returned to indicate a successful volume setting.')
    });
  }

  getVolume(callback, volumeType) {
    LogUtil.info(`settings getVolume volumeType：${volumeType} `);
    Audio.getAudioManager().getVolume(volumeType, (err, value) => {
      if (err) {
        LogUtil.info(`settings Failed to obtain the volume. ${err.message}`);
        return;
      }
      LogUtil.info('settings Callback invoked to indicate that the volume is obtained.' + value);
      callback(value);
    })
  }

  getMaxVolume(callback, volumeType) {
    LogUtil.info(`settings getMaxVolume volumeType：${volumeType} `);
    Audio.getAudioManager().getMaxVolume(volumeType, (err, value) => {
      if (err) {
        LogUtil.info(`settings Failed to obtain the volume. ${err.message}`);
        return;
      }
      LogUtil.info('settings Callback invoked to indicate that the volume is obtained.' + value);
      callback(value);
    })
  }

  getMinVolume(callback, volumeType) {
    LogUtil.info(`settings getMaxVolume volumeType：${volumeType} `);
    Audio.getAudioManager().getMinVolume(volumeType, (err, value) => {
      if (err) {
        LogUtil.info(`settings Failed to obtain the volume. ${err.message}`);
        return;
      }
      LogUtil.info('settings Callback invoked to indicate that the volume is obtained.' + value);
      callback(value);
    })
  }
}
