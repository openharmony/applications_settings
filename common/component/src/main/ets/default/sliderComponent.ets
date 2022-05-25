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
import ComponentConfig from './ComponentConfig';

/**
 * Slider component
 */
@Component
export default struct SliderComponent {
  private visible: boolean = true;
  private min: number = 0;
  private max: number = 100;
  private step?: number = 1;
  private leftImage: string = '';
  private rightImage: string = '';
  @State clickConfirm: boolean = true;
  @State showStep: boolean = false;
  @State value: number = 0;
  private onChange?: (value: number, mode: SliderChangeMode) => void
  private summary: string | Resource; // Text details
  @State fontSize: number = 18; // Font size

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Column() {
        Image(this.leftImage)
          .width($r('app.float.slider_image_width'))
          .height($r('app.float.slider_image_height'))
          .objectFit(ImageFit.Contain);
      }
      .align(Alignment.TopStart)
      .visibility(this.visible ? Visibility.Visible : Visibility.None)
      .padding({ left: $r('app.float.slider_image_margin') })
      .onClick(() => {
        if (this.value != this.min && this.clickConfirm) {
          this.value = Math.max(this.min, this.value - this.step);
          this.onChangeHandler(this.value, SliderChangeMode.End);
        }
      })
      .align(Alignment.Center)

      Column() {
        Row() {
          Text(this.summary)
            .fontSize(this.fontSize)
            .textAlign(TextAlign.Start);
        }
        .width(ComponentConfig.WH_83_100)

        Slider({
          value: this.value,
          min: this.min,
          max: this.max,
          step: this.step
        })
          .selectedColor(Color.Blue)
          .blockColor(Color.Blue)
          .width(ComponentConfig.WH_100_100)
          .showSteps(this.showStep)
          .onChange((value, mode) => {
            this.onChangeHandler(value, mode)
          });
      }.align(Alignment.Center).flexGrow(1)

      Column() {
        Image(this.rightImage)
          .width($r('app.float.slider_image_width'))
          .height($r('app.float.slider_image_height'))
          .align(Alignment.Start)
          .objectFit(ImageFit.Contain);
      }
      .align(Alignment.TopEnd)
      .visibility(this.visible ? Visibility.Visible : Visibility.None)
      .padding({ right: $r('app.float.slider_image_margin') })
      .onClick(() => {
        if (this.value != this.max && this.clickConfirm) {
          this.value = Math.min(this.max, this.value + this.step);
          this.onChangeHandler(this.value, SliderChangeMode.End);
        }
      })
      .align(Alignment.Center)

    }.width(ComponentConfig.WH_100_100).align(Alignment.TopStart)
  }

  /**
     * Change handler
     *
     * @param value - Change value
     * @param mode - State
     */
  onChangeHandler(value, mode) {
    if (this.onChange) {
      this.onChange(value, mode);
    }
  }
}