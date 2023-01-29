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
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import Audio from '@ohos.multimedia.audio';
const groupId = Audio.DEFAULT_VOLUME_GROUP_ID;

function getAudioManager() {
  if (!globalThis['audioManager']) {
    globalThis['audioManager'] = Audio.getAudioManager();
  }
  return globalThis['audioManager'];
}

function audioVolumeGroupManager() {
  if (!globalThis['audioVolumeGroupManager']) {
    globalThis['audioVolumeGroupManager'] = getAudioManager().getVolumeManager().getVolumeGroupManager(groupId);
  }
  return globalThis['audioVolumeGroupManager'];
}

export async function registerObserver(){
  let audioManager = getAudioManager();
  let getaudioVolumeGroupManager = await audioVolumeGroupManager();
  getaudioVolumeGroupManager.on('ringerModeChange', (mode)=>{
    AppStorage.SetOrCreate('ringerModeSilent', mode === Audio.AudioRingMode.RINGER_MODE_SILENT);
    AppStorage.SetOrCreate('ringerModeNormal', mode === Audio.AudioRingMode.RINGER_MODE_NORMAL);
  })

  audioManager.on('volumeChange', (data) => {
    if(data.volumeType === Audio.AudioVolumeType.RINGTONE){
      AppStorage.SetOrCreate('volume_ringtone', data.volume);
    } else if(data.volumeType === Audio.AudioVolumeType.VOICE_CALL){
      AppStorage.SetOrCreate('volume_voicecall', data.volume);
    } else if(data.volumeType === Audio.AudioVolumeType.MEDIA){
      AppStorage.SetOrCreate('volume_media', data.volume);
    }
  })

  audioManager.on('deviceChange', () => {
   audioManager.getVolume(Audio.AudioVolumeType.RINGTONE,(err,data)=>{
    AppStorage.SetOrCreate('volume_ringtone', data);
   })
   audioManager.getVolume(Audio.AudioVolumeType.VOICE_CALL,(err,data)=>{
    AppStorage.SetOrCreate('volume_voicecall', data);
   })
   audioManager.getVolume(Audio.AudioVolumeType.MEDIA,(err,data)=>{
    AppStorage.SetOrCreate('volume_media', data);
   })
  })
}


export class VolumeModel extends BaseModel{
  private volumeType;
  private audioManager;
  private volume;
  private TAG = ConfigData.TAG + 'VolumeModel ';
  private oldVolume;

  constructor(volumeType){
    super();
    this.volumeType = volumeType;
    this.audioManager = getAudioManager();
    this.audioManager.getVolume(this.volumeType, (err, data) => {
      this.initState(data);
      this.oldVolume = data;
    })
  }

  /**
   * Get volume value in the VolumeModel
   */
  @Log
  public initState(volume){
    if(this.volumeType === Audio.AudioVolumeType.RINGTONE){
      AppStorage.SetOrCreate('volume_ringtone', volume);
    } else if(this.volumeType === Audio.AudioVolumeType.MEDIA){
      AppStorage.SetOrCreate('volume_media', volume);
    } else if(this.volumeType === Audio.AudioVolumeType.VOICE_CALL){
      AppStorage.SetOrCreate('volume_voicecall', volume);
    }
    return;
  }

  /**
   * Set value
   */
  @Log
  public setVolume(volume:number){
    if(volume === this.oldVolume){
      return;
    } else {
      LogUtil.info(`${this.TAG} setVolume start, volume: ${volume}`);
      this.audioManager.setVolume(this.volumeType, volume).then(() => {
        LogUtil.info(`${this.TAG} setVolume callback in, volume: ${volume}`);
      });
      this.oldVolume = volume;
      LogUtil.info(`${this.TAG} setVolume end, volume: ${volume}`);
      return;
    }
  }
}

export class RingerModel extends BaseModel{
  private modeTag;
  private TAG = ConfigData.TAG + 'RingerModel ';

  constructor(mode){
    super();
    this.modeTag = mode;
    this.initState();
  }

  /**
   * Update ringer Mode
   */
  @Log
  public async initState(){
    let getaudioVolumeGroupManager = await audioVolumeGroupManager();
    getaudioVolumeGroupManager.getRingerMode((error, action) => {
      LogUtil.info(`${this.TAG} updateMode.`);
      if (error) {
        return;
      }
      AppStorage.SetOrCreate('ringerModeSilent', action === Audio.AudioRingMode.RINGER_MODE_SILENT);
      AppStorage.SetOrCreate('ringerModeNormal', action === Audio.AudioRingMode.RINGER_MODE_NORMAL);
      LogUtil.info(`${this.TAG} updateMode sucess.`);
    });
  }

  /**
   * Set  ringer mode
   */
  @Log
  public async setRingerMode(){
    let getaudioVolumeGroupManager = await audioVolumeGroupManager();
    getaudioVolumeGroupManager.setRingerMode(this.modeTag, (err, data) => {
      LogUtil.info(`${this.TAG} setRingerMode.`);
      LogUtil.info(`${this.TAG} setRingerMode sucess.`);
    });
    return;
  }
}

