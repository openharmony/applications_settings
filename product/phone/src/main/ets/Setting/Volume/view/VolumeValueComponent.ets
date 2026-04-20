/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

/* instrument ignore file */
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { VolumeSliderController } from '../controller/VolumeSliderController';
import { VolumeParams } from '../model/VolumeType';
import { VolumeUtils } from '../utils/VolumeUtils';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { RINGTONE_TOP_ICONS, MEDIA_TOP_ICONS, NO_VIBRATE_ICONS } from '../constant/VolumeConstant';
import { RingtoneVolumeSliderController } from '../controller/RingtoneVolumeSliderController';
import { AlarmVolumeSliderController } from '../controller/AlarmVolumeSliderController';
import { MediaVolumeSliderController } from '../controller/MediaVolumeSliderController';
import { CallVolumeSliderController } from '../controller/CallVolumeSliderController';
import { VassistantVolumeSliderController } from '../controller/VassistantVolumeSliderController';

const MAX_REFRESH_ID: number = 1000;

@Component
export struct SliderMenuComponent {
  private tag: string = 'SliderMenuComponent : ';
  comId: string = '';
  title?: ResourceStr;
  controller?: VolumeSliderController;
  item?: SettingBaseModel;
  @State icon: Resource = $r('sys.color.icon_primary');
  @State sliderValue: number = 0;
  @State refreshId: number = 1;

  build() {
    Column() {
      Row() {
        SymbolGlyph(this.icon)
          .fontColor([$r('sys.color.icon_primary')])
          .draggable(false)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)

        Text(this.title)
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .constraintSize({
            maxWidth:'80%'
          })
      }
      .justifyContent(FlexAlign.Start)
      .constraintSize({ minHeight: $r('app.float.wh_value_56') })
      .padding({
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6'),
        top: FontScaleUtils.getCurrentTopPadding(),
        bottom: FontScaleUtils.getCurrentTopPadding()
      })

      Slider({
        value: this.refreshId ? this.sliderValue : this.sliderValue,
        min: this.controller?.getSliderMin(),
        max: this.controller?.getSliderMax(),
        step: this.controller?.getSliderStep(),
        style: SliderStyle.InSet
      })
        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.controller?.onSliderChange(value, mode);
        })
        .id(`slider_${this.comId}`)
        .selectedColor($r('sys.color.brand'))
        .blockColor('#ffffff')
        .constraintSize({ minHeight: $r('app.float.wh_value_40') })
        .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .size({ width: '100%' })
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear`);
    if (this.controller) {
      this.controller.init();
      this.sliderValue = this.controller.getSliderValue();
    }
    EventBus.getInstance().off(`slider_${this.comId}_value`);
    EventBus.getInstance().off(`slider_${this.comId}_mode`);
    EventBus.getInstance().on(`slider_${this.comId}_value`, (value: number) => {
      this.sliderValue = value;
      this.refreshId++;
      if (this.refreshId > MAX_REFRESH_ID) {
        this.refreshId = 1;
      }
    })
    EventBus.getInstance().on(`slider_${this.comId}_mode`, (mode: number) => {
      if (this.comId === 'ringTone_volume' && mode < RINGTONE_TOP_ICONS.length) {
        this.icon = VibratorUtil.isSupportVibrate() ? RINGTONE_TOP_ICONS[mode] : NO_VIBRATE_ICONS[mode];
      } else if ( this.comId === 'media_volume' && mode < MEDIA_TOP_ICONS.length ) {
        this.icon = MEDIA_TOP_ICONS[mode];
      } else {
        LogUtil.showInfo(this.tag, 'invalid mode change');
      }
    })
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear`);
    this.controller?.destroy();
  }
}

@Component
export struct VolumeValueComponent {
  volumeParam: VolumeParams = VolumeUtils.getVolumeParams();
  item?: SettingBaseModel;

  build() {
    Column() {
      SliderMenuComponent({
        comId: 'ringTone_volume',
        item: this.item,
        icon: VibratorUtil.isSupportVibrate() ?
        RINGTONE_TOP_ICONS[this.volumeParam.ringMode] : NO_VIBRATE_ICONS[this.volumeParam.ringMode],
        title: !RingtonesUtils.isVoiceCapabilityDisable() ? $r('app.string.ringtone_volume_new_title') :
        $r('app.string.ringtone_volume_title1'),
        controller: new RingtoneVolumeSliderController(this.volumeParam.ringMode),
      })

      SliderMenuComponent({
        comId: 'alarm_volume',
        icon: $r('sys.symbol.alarm'),
        title: $r('app.string.alarm_volume_title'),
        controller: new AlarmVolumeSliderController(),
      })

      SliderMenuComponent({
        comId: 'media_volume',
        icon: MEDIA_TOP_ICONS[this.volumeParam.mediaMode],
        title: $r('app.string.media_volume_new_title'),
        controller: new MediaVolumeSliderController(),
      })

      if (!RingtonesUtils.isVoiceCapabilityDisable()) {
        SliderMenuComponent({
          comId: 'call_volume',
          icon: $r('sys.symbol.phone'),
          title: $r('app.string.call_volume_title'),
          controller: new CallVolumeSliderController(),
        })
      }

      // SliderMenuComponent({
      //   comId: 'vassistant_volume',
      //   icon: $r('sys.symbol.Celia'),
      //   title: $r('app.string.vassistant_settings'),
      //   controller: new VassistantVolumeSliderController(),
      // })
    }
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level8') })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }
}