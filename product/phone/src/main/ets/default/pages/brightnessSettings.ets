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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import {BrightnessSettingModel} from '../model/brightnessImpl/BrightnessSettingModel.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';


const BRIGHTNESS_MIN_VALUE = 4;
const BRIGHTNESS_MAX_VALUE = 100;
const BRIGHTNESS_STEP_VALUE = 1;

/**
 * brightness setting
 */
@Entry
@Component
struct BrightnessSettings {
  @State brightnessSettingModel:BrightnessSettingModel = new BrightnessSettingModel();
  private TAG = ConfigData.TAG + 'BrightnessSettings ';

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.brightnessTab'), isActive: true });
      Row() {
        Image($r('app.media.ic_settings_brightness_minimum'))
          .width($r('app.float.wh_value_40'))
          .height($r('app.float.wh_value_40'))
          .objectFit(ImageFit.Contain);
        Slider({
          value: this.brightnessSettingModel.getValue(),
          min: BRIGHTNESS_MIN_VALUE,
          max: BRIGHTNESS_MAX_VALUE,
          step: BRIGHTNESS_STEP_VALUE
        })
          .selectedColor(Color.Blue)
          .blockColor(Color.Blue)
          .width(ConfigData.WH_83_100)
          .onChange((number, mode:SliderChangeMode) => {
            this.brightnessSettingModel.setValue(number, mode);
          });
        Image($r('app.media.ic_settings_brightness_maximum'))
          .width($r('app.float.wh_value_40'))
          .height($r('app.float.wh_value_40'))
          .objectFit(ImageFit.Contain);
      }.padding({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') });
    }
    .align(Alignment.Center)
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Log
  private aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    this.brightnessSettingModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  private aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    this.brightnessSettingModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }
}