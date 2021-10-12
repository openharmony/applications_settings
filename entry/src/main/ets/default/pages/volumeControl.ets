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
import VolumeModel from '../model/volumeControlImpl/VolumeModel.ets';
import HeadComponent from './component/headComponent.ets';
import ConfigData from '../common/baseUtil/ConfigData.ets';
import LogUtil from '../common/baseUtil/LogUtil.ets';
import SubscriberUtils from '../common/baseUtil/SubscriberUtil.ets';
import Router from '@system.router';
import Audio from '@ohos.multimedia.audio';

const VOLUME_TYPE = Audio.AudioVolumeType.MEDIA;
const SENT_EVENT_IN_VOLUME_PAGES = '-1';

@Entry
@Component
export
struct VolumeControl {
  @State minVol: number = 0;
  @State maxVol: number = 10;
  @StorageLink('VolumeSetValue') currentVol: number = 0;
  private audioManager = Audio.getAudioManager();
  private volumeModel = new VolumeModel();

  initVolume() {
    this.volumeModel.getMaxVolume(this.getMaxVolumeCallback.bind(this), VOLUME_TYPE);
    this.volumeModel.getMinVolume(this.getMinVolumeCallback.bind(this), VOLUME_TYPE);
    this.volumeModel.getVolume(this.getCurrentVolumeCallback.bind(this), VOLUME_TYPE);
  }

  getMinVolumeCallback(val) {
    this.minVol = val;
    LogUtil.info(`settings getMinVolumeCallback ${this.minVol} `);
  }

  getMaxVolumeCallback(val) {
    this.maxVol = val;
    LogUtil.info(`settings getMaxVolumeCallback ${this.maxVol} `);
  }

  getCurrentVolumeCallback(val) {
    this.currentVol = val;
    LogUtil.info(`settings getCurrentVolumeCallback ${this.currentVol} `);
  }

  setVolume(volumeValue, volumeType) {
    LogUtil.info(`settings setVolume = ${volumeValue} Type = ${volumeType}`)
    Audio.getAudioManager().setVolume(volumeType, volumeValue).then(() => {
      this.currentVol = volumeValue;
      LogUtil.info('settings Promise returned to indicate a successful volume setting')
    })
  }

  aboutToAppear() {
    LogUtil.info('settings Start init Volume!')
    this.initVolume()
    SubscriberUtils.sendEvent(SENT_EVENT_IN_VOLUME_PAGES, ConfigData.SENT_EVENT_BROADCAST_VOLUME_VALUE);
    SubscriberUtils.registerStatusListener();
    LogUtil.info('settings Finished init Volume!')
  }

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.volumeControl'), isActive: true });
      Row() {
        Slider({
          value: this.currentVol,
          min: this.minVol,
          max: this.maxVol,
          step: 1,
          style: SliderStyle.INSET
        })
        .size({ width: 300 })
        .width('100%')
        .blockColor(Color.Blue)
        .trackColor(Color.Grey)
        .selectedColor(Color.Blue)
        .onChange((value: number) => {
          this.setVolume(value, VOLUME_TYPE)
        })
      }
      .padding({
        left: $r('app.float.wh_value_15'),
        right: $r('app.float.wh_value_15')
      });
    }
    .width('85%')
    .align(Alignment.Center)
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }
}
