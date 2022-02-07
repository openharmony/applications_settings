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
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import Audio from '@ohos.multimedia.audio';
import settings from '@ohos.settings';
import featureAbility from '@ohos.ability.featureAbility';

export class VolumeModel extends BaseModel{
  private dataAbilityHelper;
  private urivar:string;
  private settingsDataKey:string;
  private volume:number = 150;
  private defaultVolumeStr = '150';
  private volumeType;
  private str2Enum = {
    'settings.audio.ringtone': Audio.AudioVolumeType.RINGTONE,
    'settings.audio.media': Audio.AudioVolumeType.MEDIA,
    'settings.audio.voicecall': Audio.AudioVolumeType.VOICE_CALL
  }
  private TAG = ConfigData.TAG + 'VolumeModel ';

  constructor(settingsDataKey:string){
    super();
    this.settingsDataKey = settingsDataKey;
    this.volumeType = this.str2Enum[this.settingsDataKey];
    this.urivar = settings.getUri(this.settingsDataKey);
    this.dataAbilityHelper = featureAbility.acquireDataAbilityHelper(this.urivar);
    this.updateValue();
  }

  /**
   * Get volume value in the VolumeModel
   */
  @Log
  public getValue(){
    return this.volume;
  }

  /**
   * Set value
   */
  @Log
  public setValue(volume:number, sliderChangeMode:number){
    if(sliderChangeMode === ConfigData.SLIDER_CHANG_MODE_END){
      LogUtil.info(this.TAG + `setValue [volume:${volume}, sliderChangeMode:${sliderChangeMode}]`);
      this.setSettingsData(volume);
    }else{
      this.setSystemVolume(volume);
    }
    return;
  }

  /**
   * Set the volume value in the SettingsData
   */
  @Log
  private setSettingsData(volume:number){
    LogUtil.info(this.TAG + `setSettingsData [type:${this.volumeType}, value:${volume}]`);
    this.volume = volume;
    settings.setValue(this.dataAbilityHelper, this.settingsDataKey, volume.toString());
    LogUtil.info(this.TAG + `setSettingsData [type:${this.volumeType}, value:${volume}] success`);
    return;
  }

  /**
   * Set the system volume value
   */
  @Log
  private setSystemVolume(volume:number){
    this.volume = volume;
    Audio.getAudioManager().setVolume(this.volumeType, volume).then(() => {
    });
    return;
  }

  /**
   * Update the volume value in the VolumeModel
   */
  @Log
  private updateValue(){
    LogUtil.info(this.TAG + 'updateValue');
    this.volume = parseInt(settings.getValue(this.dataAbilityHelper, this.settingsDataKey, this.defaultVolumeStr));
    LogUtil.info(this.TAG + `updateValue success, [volume:${this.volume}]`);
    return;
  }

  /**
   * Register observer
   */
  @Log
  public registerObserver(){
    LogUtil.info(this.TAG + 'registerObserver');
    this.dataAbilityHelper.on("dataChange", this.urivar, (err)=>{
      this.updateValue();
    })
    LogUtil.info(this.TAG + 'registerObserver success');
    return;
  }

  /**
   * Unregister observer
   */
  @Log
  public unregisterObserver() {
    LogUtil.info(this.TAG + 'unregisterObserver');
    this.dataAbilityHelper.off("dataChange", this.urivar, (err)=>{
      LogUtil.info(this.TAG + 'unregisterObserver success');
    })
    return;
  }
}

export class RingerModel extends BaseModel{
  private TAG = ConfigData.TAG + 'RingerModel ';

  /**
   * Set volume ringer volume
   */
  @Log
  public setRingerMode(audioRingMode/* AudioRingMode */, callback: (value: number) => void) {
    Audio.getAudioManager().setRingerMode(audioRingMode).then(() => {
      LogUtil.info(this.TAG + `setRingerMode [mode:${audioRingMode}] success`);
      callback(audioRingMode);
    });
    return;
  }

  /**
   * Get volume ringer volume
   */
  @Log
  public getRingerMode(callback: (value: number) => void) {
    Audio.getAudioManager().getRingerMode().then((value/*AudioRingMode*/) => {
      LogUtil.info(this.TAG + `getRingerMode success : value = ${value}`);
      callback(value);
    })
    return;
  }
}

