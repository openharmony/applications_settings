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
import {VolumeModel, RingerModel} from '../model/volumeControlImpl/VolumeControlModel.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import SliderComponent from '../../../../../../../common/component/src/main/ets/default/sliderComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import SubscriberUtils from '../../../../../../../common/utils/src/main/ets/default/baseUtil/SubscriberUtil.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import Audio from '@ohos.multimedia.audio';

const SUBSCRIBE_INFO_EVENT_VOLUME_TYPE = "AUDIO_VOLUME_TYPE_SYSTEM_UI"
const SUBSCRIBE_INFO_EVENT_RING_MODE = "AUDIO_RING_MODE_SYSTEM_UI"
const mCommonEventSubscribeInfo = {
  events: [SUBSCRIBE_INFO_EVENT_VOLUME_TYPE, SUBSCRIBE_INFO_EVENT_RING_MODE]
};
const VOLUME_MIN_VALUE = 0;
const VOLUME_MAX_VALUE = 15;

/**
 * Volume control
 */
@Entry
@Component
export struct VolumeControl {

  build() {
    Column() {
      // head
      HeadComponent({ headName: $r('app.string.volumeAndVibrationControl'), isActive: true });
      // sound mode
      AudioRingerModeComponent();
      // volume control
      VolumeControlComponent();
    }
  }
}

/**
 * AudioRingerMode component
 */
@Component
struct AudioRingerModeComponent {
  @StorageLink('AudioRingerMode') audioRingerMode: number = Audio.AudioRingMode.RINGER_MODE_NORMAL;
  private ringerModel = new RingerModel();
  private TAG = ConfigData.TAG + 'AudioRingerModeComponent ';

  @Log
  private aboutToAppear() {
    LogUtil.info(this.TAG + 'aboutToAppear in');
    SubscriberUtils.registerStatusListener(mCommonEventSubscribeInfo, this.commonEventCallback.bind(this));
    this.updateRingerMode();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  private aboutToDisappear(): void {
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    AppStorage.SetOrCreate('AudioRingerMode', '');
    SubscriberUtils.unSubscriberListener();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
      Text($r('app.string.soundMode'))
        .margin({
          left: $r('app.float.audio_subtitle_margin_left'),
          bottom: $r('app.float.audio_subtitle_margin_bottom')
        })
        .fontSize($r('app.float.audio_subtitle_font'))
        .fontColor($r('app.color.color_333333_grey'));

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        RowSplit() {
          AudioRingerModeItem({
            image: $r('app.media.ic_settings_audio_sound_mode_sound'),
            desc: $r('app.string.soundModeSound'),
            value: Audio.AudioRingMode.RINGER_MODE_NORMAL,
            checkedValue: $audioRingerMode,
            onItemClick: (ringerMode) => { this.onItemClick(ringerMode) }
          })
          AudioRingerModeItem({
            image: $r('app.media.ic_settings_audio_sound_mode_vibration'),
            desc: $r('app.string.soundModeVibration'),
            value: Audio.AudioRingMode.RINGER_MODE_VIBRATE,
            checkedValue: $audioRingerMode,
            onItemClick: (ringerMode) => { this.onItemClick(ringerMode) }
          })
          AudioRingerModeItem({
            image: $r('app.media.ic_settings_audio_sound_mode_silent'),
            desc: $r('app.string.soundModeSilent'),
            value: Audio.AudioRingMode.RINGER_MODE_SILENT,
            checkedValue: $audioRingerMode,
            onItemClick: (ringerMode) => { this.onItemClick(ringerMode) }
          })
        }
        .resizeable(false)
        .align(Alignment.BottomEnd)
        .alignSelf(ItemAlign.End);
      }
      .margin({top: $r('app.float.audio_subtitle_margin_top')  })
      .padding({
        top: $r('app.float.audio_sound_mode_inner_padding_top'),
        bottom: $r('app.float.audio_sound_mode_inner_padding_bottom')
      })
      .border({
        width: $r('app.float.audio_sound_mode_border_width'),
        color: $r('app.color.color_999999_grey'),
        radius: $r('app.float.audio_sound_mode_border_radius')
      });
    }
    .padding($r('app.float.audio_sound_mode_outer_padding'))
    .height($r('app.float.audio_sound_mode_outer_height'))
    .margin({ bottom: $r('app.float.item_common_vertical_margin') });
  }

/**
   * AudioRingerMode Change
   */
  @Log
  onItemClick(audioRingerMode: number) {
    LogUtil.info(this.TAG + `onItemClick: ${audioRingerMode} `);
    this.ringerModeCheckedCallback(audioRingerMode);
  }

/**
   * common event callback
   */
  @Log
  commonEventCallback(err, data) {
    LogUtil.info(this.TAG + `SubscriberUtils statusSubscriberCallBack data.data volume : ` + JSON.stringify(data));
    this.updateRingerMode();
  }

/**
   * update RingerMode
   */
  @Log
  updateRingerMode() {
    this.ringerModel.getRingerMode((audioRingMode/* AudioRingMode */) => {
      this.audioRingerMode = audioRingMode;
      AppStorage.SetOrCreate('AudioRingerMode', audioRingMode);
      LogUtil.info(this.TAG + 'updateRingerMode : AppStorage audioRingMode：' + audioRingMode);
    });
  }

/**
   * ringer mode checked callback
   */
  @Log
  ringerModeCheckedCallback(audioRingerMode/* AudioRingerMode */) {
    LogUtil.info(this.TAG + `AudioRingerModeChangeCallback init: ${audioRingerMode} `);
    this.ringerModel.setRingerMode(audioRingerMode, (value) => {
      this.audioRingerMode = value;
      AppStorage.SetOrCreate('AudioRingerMode', value);

      // send event
      let info = { 'value': 0 };
      info.value = value;
      SubscriberUtils.sendEvent(JSON.stringify(info), ConfigData.SENT_EVENT_AUDIO_RINGER_MODE);
    });
  }
}

/**
 * AudioRingerMode item
 */
@Component
struct AudioRingerModeItem {
  private image: PixelMap;
  private desc: string;
  private value: number;
  @Link checkedValue: number;
  private onItemClick?: (ringerMode) => void;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Image(this.image)
        .width($r('app.float.audio_sound_mode_image_size'))
        .height($r('app.float.audio_sound_mode_image_size'))
        .objectFit(ImageFit.Contain);

      Text(this.desc)
        .margin({ top: $r('app.float.audio_sound_mode_text_margin_top') })
        .fontSize($r('app.float.audio_sound_mode_font_size'))
        .fontColor($r('app.color.color_333333_grey'))
        .textAlign(TextAlign.Center)
        .align(Alignment.Center);

      Radio({ value: this.value.toString() })
        .width($r('app.float.audio_sound_mode_radio_size'))
        .height($r('app.float.audio_sound_mode_radio_size'))
        .checked(this.checkedValue === this.value)
        .enabled(false);
    }
    .width(ConfigData.WH_33_100)
    .height(ConfigData.WH_100_100)
    .padding({ top: $r('app.float.audio_sound_mode_item_inner_padding_top') })
    .onClick(() => {
      LogUtil.info(ConfigData.TAG + 'AudioRingerModeItem : item is clicked : ' + this.value)
      this.onItemClick(this.value);
    });
  }
}


/**
 * Volume control component
 */
@Component
struct VolumeControlComponent {
  @State ringtoneModel:VolumeModel = new VolumeModel(ConfigData.SETTINGSDATA_VOLUME_RINGTONE);
  @State mediaModel:VolumeModel = new VolumeModel(ConfigData.SETTINGSDATA_VOLUME_MEDIA);
  @State voiceCallModel:VolumeModel = new VolumeModel(ConfigData.SETTINGSDATA_VOLUME_CALL);
  private TAG = ConfigData.TAG + 'VolumeControlComponent ';

  @Log
  private aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    this.ringtoneModel.registerObserver();
    this.mediaModel.registerObserver();
    this.voiceCallModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  private aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    this.ringtoneModel.unregisterObserver();
    this.mediaModel.unregisterObserver();
    this.voiceCallModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
      Text($r('app.string.volumeControl'))
        .margin({
          left: $r('app.float.audio_subtitle_margin_left'),
          bottom: $r('app.float.audio_subtitle_margin_bottom')
        })
        .fontSize($r('app.float.audio_subtitle_font'))
        .fontColor($r('app.color.color_333333_grey'));

      Column() {
        SliderComponent({
          summary: $r('app.string.volumeControlRing'),
          min: VOLUME_MIN_VALUE,
          max: VOLUME_MAX_VALUE,
          value: this.ringtoneModel.getValue(),
          visible: false,
          onChange: (value: number, mode: SliderChangeMode) => {
            this.ringtoneModel.setValue(value, mode);
          }
        });
        SliderComponent({
          summary: $r('app.string.volumeControlMedia'),
          min: VOLUME_MIN_VALUE,
          max: VOLUME_MAX_VALUE,
          value: this.mediaModel.getValue(),
          visible: false,
          onChange: (value: number, mode: SliderChangeMode) => {
            this.mediaModel.setValue(value, mode);
          }
        });
        SliderComponent({
          summary: $r('app.string.volumeControlCall'),
          min: VOLUME_MIN_VALUE,
          max: VOLUME_MAX_VALUE,
          value: this.voiceCallModel.getValue(),
          visible: false,
          onChange: (value: number, mode: SliderChangeMode) => {
            this.voiceCallModel.setValue(value, mode);
          }
        });
      }
      .margin({top: $r('app.float.audio_subtitle_margin_top')})
      .border({
        width: $r('app.float.audio_border_width'),
        color: Color.Gray,
        radius: $r('app.float.audio_border_radius')
      })
      .padding($r('app.float.item_common_vertical_margin'))
    }
    .padding($r('app.float.audio_volume_component_padding'))
  }
}