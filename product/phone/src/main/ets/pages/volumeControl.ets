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

import Audio from '@ohos.multimedia.audio';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import { SubHeader } from '../../../../../../common/component/src/main/ets/default/textComponent';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { VolumeModel, RingerModel, registerObserver } from '../model/volumeControlImpl/VolumeControlModel';

const VOLUME_MIN_VALUE = 0;
const VOLUME_MAX_VALUE = 15;

/**
 * Volume control
 */
@Entry
@Component
export struct VolumeControl {
  private TAG = ConfigData.TAG + ' VolumeControl ';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          //head
          HeadComponent({ headName: $r('app.string.volumeControlTab') });

          SubHeader({ titleContent: $r('app.string.soundMode') });

          // sound mode
          AudioRingerModeComponent();

          SubHeader({ titleContent: $r('app.string.volumeControl') });

          // volume control
          VolumeControlComponent();
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  @Log
  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    registerObserver();
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}

/**
 * AudioRingerMode component
 */
@Component
struct AudioRingerModeComponent {
  @StorageLink('ringerModeNormal') ringerModeNormal: boolean = false;
  @StorageLink('ringerModeSilent') ringerModeSilent: boolean = false;
  private ringerSilentModel: RingerModel = new RingerModel(Audio.AudioRingMode.RINGER_MODE_SILENT);
  private ringerNormalModel: RingerModel = new RingerModel(Audio.AudioRingMode.RINGER_MODE_NORMAL);
  private TAG = ConfigData.TAG + ' AudioRingerModeComponent ';

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceAround }) {
      Row() {
        Blank()

        AudioRingerModeItem({
          checked: $ringerModeNormal,
          audioRingerModel: this.ringerNormalModel,
          image: $r("app.media.ic_ring"),
          text: $r('app.string.soundModeSound')
        });

        Blank()

        Divider()
          .vertical(true)
          .margin({ bottom: 14 })
          .color($r('sys.color.ohos_id_color_list_separator'))

        Blank()

        AudioRingerModeItem({
          checked: $ringerModeSilent,
          audioRingerModel: this.ringerSilentModel,
          image: $r("app.media.ic_ring_off"),
          text: $r('app.string.soundModeSilent')
        });

        Blank()
      }
      .width(ConfigData.WH_100_100)
    }
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .width(ConfigData.WH_100_100)
    .height($r('app.float.wh_value_119'))
    .padding({
      top: $r('app.float.distance_14'),
      bottom: $r('app.float.distance_2')
    })
  }

  @Log
  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}

/**
 * AudioRingerMode item
 */
@Component
struct AudioRingerModeItem {
  @Link checked: boolean;
  private audioRingerModel: RingerModel;
  private image;
  private text: string | Resource;

  build() {
    Column() {
      Image(this.image)
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .objectFit(ImageFit.Contain)
        .fillColor($r("sys.color.ohos_fa_icon_secondary"))

      Text(this.text)
        .fontColor($r("app.color.font_color_182431"))
        .fontSize($r("sys.float.ohos_id_text_size_body2"))
        .lineHeight($r("app.float.lineHeight_19"))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .margin({ top: $r('app.float.distance_8') });

      Radio({ value: '', group: '' })
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .margin({ top: $r('app.float.distance_4') })
        .checked(this.checked)
        .onChange((vue) => {
          if(vue) {
            this.audioRingerModel.setRingerMode();
          }
        })
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      LogUtil.info(ConfigData.TAG + 'AudioRingerModeItem : item is clicked');
      this.audioRingerModel.setRingerMode();
    });
  }
}

/**
 * Volume control component
 */
@Component
struct VolumeControlComponent {
  @StorageLink('volume_ringtone') volumeRingTone: number = 2;
  @StorageLink('volume_media') volumeMedia: number = 2;
  @StorageLink('volume_voicecall') volumeVoiceCall: number = 2;
  private voiceCallModel:VolumeModel = new VolumeModel(Audio.AudioVolumeType.VOICE_CALL);
  private ringtoneModel:VolumeModel = new VolumeModel(Audio.AudioVolumeType.RINGTONE);
  private mediaModel:VolumeModel = new VolumeModel(Audio.AudioVolumeType.MEDIA);
  private TAG = ConfigData.TAG + ' VolumeControlComponent ';

  build() {
    Column() {
      VolumeControlItem({
        image: this.volumeRingTone === 0 ? $r("app.media.ic_ring_off") : $r("app.media.ic_ring"),
        volumeValue: $volumeRingTone,
        volumeModel: this.ringtoneModel,
        text: $r("app.string.volumeControlRing")})

      VolumeControlItem({
        image: this.volumeMedia === 0 ? $r("app.media.ic_media_off") : $r("app.media.ic_media"),
        volumeValue: $volumeMedia,
        volumeModel: this.mediaModel,
        text: $r("app.string.volumeControlMedia")})

      VolumeControlItem({
        image: $r("app.media.ic_call"),
        volumeValue: $volumeVoiceCall,
        volumeModel: this.voiceCallModel,
        text: $r("app.string.volumeControlCall")})
    }
    .width(ConfigData.WH_100_100)
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .padding($r('app.float.distance_12'))
  }

  @Log
  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}

/**
 * Volume control item
 */
@Component
struct VolumeControlItem {
  @Link volumeValue: number;
  private volumeModel;
  private image;
  private text;

  build(){
    Column(){
      Row(){
        Image(this.image)
          .width($r('app.float.wh_value_20'))
          .height($r('app.float.wh_value_20'))
          .fillColor($r("sys.color.ohos_fa_icon_secondary"))
          .objectFit(ImageFit.Contain)

        Text(this.text)
          .fontSize($r("app.float.font_16"))
          .lineHeight($r("app.float.lineHeight_22"))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .textAlign(TextAlign.Start)
          .margin({left: $r('app.float.distance_12')})
          .width(ConfigData.WH_100_100);
      }
      .margin({ bottom: $r('app.float.distance_1') })
      .width(ConfigData.WH_100_100)
      .align(Alignment.Center);

      Slider({
        value: this.volumeValue,
        min: VOLUME_MIN_VALUE,
        max: VOLUME_MAX_VALUE,
        style: SliderStyle.InSet
      })
        .selectedColor($r('app.color.font_color_007DFF'))
        .blockColor(Color.White)
        .height($r('app.float.wh_value_40'))
        .width(ConfigData.WH_100_100)
        .onChange((value: number) => {
          this.volumeModel.setVolume(value);
        });
    }
    .margin({ top: $r("app.float.distance_12") })
    .width(ConfigData.WH_100_100);
  }
}