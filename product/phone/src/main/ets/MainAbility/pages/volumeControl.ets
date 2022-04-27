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
import {VolumeModel, RingerModel, registerObserver} from '../model/volumeControlImpl/VolumeControlModel';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import Audio from '@ohos.multimedia.audio';
import {SubHeader} from '../../../../../../../common/component/src/main/ets/default/textComponent';

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
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            // head
            HeadComponent({ headName: $r('app.string.volumeControlTab'), isActive: true });

            SubHeader({ titleContent: $r('app.string.soundMode') })

            // sound mode
            AudioRingerModeComponent();

            SubHeader({ titleContent: $r('app.string.volumeControl') })

            // volume control
            VolumeControlComponent();
          }
          .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
          .align(Alignment.Center)
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Log
  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    registerObserver();
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  @Log
  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
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
    Row(){
      RowSplit() {
        AudioRingerModeItem({checked: $ringerModeNormal, audioRingerModel: this.ringerNormalModel, image: $r("app.media.ic_ring"), text: $r('app.string.soundModeSound')});
        AudioRingerModeItem({checked: $ringerModeSilent, audioRingerModel: this.ringerSilentModel, image: $r("app.media.ic_ring_off"), text: $r('app.string.soundModeSilent')});
      }
      .resizeable(false)
    }
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
    .width(ConfigData.WH_100_100)
    .height($r('app.float.wh_value_119'))
    .padding({top: $r('app.float.distance_14'), bottom: $r('app.float.distance_14')});
  }

  @Log
  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  @Log
  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
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
        .objectFit(ImageFit.Contain);

      Text(this.text)
        .fontSize($r("app.float.font_14"))
        .lineHeight($r("app.float.lineHeight_19"))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .margin({top: $r('app.float.distance_8')});

      Radio({ value: '', group: '' })
        .width($r('app.float.wh_value_24'))
        .height($r('app.float.wh_value_24'))
        .checked(this.checked)
        .enabled(false)
    }
    .alignItems(HorizontalAlign.Center)
    .width(ConfigData.WH_50_100)
    .height(ConfigData.WH_100_100)
    .onClick(() => {
      LogUtil.info(ConfigData.TAG + 'AudioRingerModeItem : item is clicked')
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
        image: $r("app.media.ic_media"),
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
    .padding($r('app.float.distance_12'));
  }

  @Log
  aboutToAppear(): void{
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  @Log
  aboutToDisappear(): void{
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
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
          .objectFit(ImageFit.Contain)
          .margin({ top: $r('app.float.distance_13'), bottom: $r('app.float.distance_1')});
        Text(this.text)
          .fontSize($r("app.float.font_16"))
          .lineHeight($r("app.float.lineHeight_22"))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .textAlign(TextAlign.Start)
          .padding({left: $r('app.float.distance_12'), right: $r('app.float.distance_12'), top: $r('app.float.distance_12')})
          .width(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .align(Alignment.Start);
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
    .width(ConfigData.WH_100_100);
  }
}