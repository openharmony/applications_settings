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
import { AudioBalanceController } from '../controller/AudioBalanceController';

const MAX_REFRESH_ID: number = 1000;
const MAX_LINES_10: number = 10;
const TAG: string = 'accessiblility_audio_balance_slider_component';

@Component
export struct SliderComponent {
  private tag: string = '';
  private title: ResourceStr = '';
  private controller: AudioBalanceController = new AudioBalanceController();
  private leftSummary: ResourceStr = '';
  private rightSummary: ResourceStr = '';
  @State sliderValue: number = 0;
  @State refreshId: number = 1;

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    await this.controller.init();
    this.sliderValue = this.controller.getSliderValue();
    EventBus.getInstance().on(`accessiblility_audio_balance_slider_value`, (value: number) => {
      LogUtil.showInfo(this.tag, `slider value: ${value}`);
      this.sliderValue = value;
      this.refreshId++;
      if (this.refreshId > MAX_REFRESH_ID) {
        this.refreshId = 1;
      }
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().off(`accessiblility_audio_balance_slider_value`);
    this.controller.destroy();
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Slider({
          value: this.refreshId ? this.sliderValue : this.sliderValue,
          min: this.controller.getSliderMin(),
          max: this.controller.getSliderMax(),
          step: this.controller.getSliderStep(),
          style: SliderStyle.OutSet
        })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.controller.onSliderChange(value, mode);
          })
          .id(`${this.tag}_slider`)
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .selectedColor('#00000000')
          .blockColor('#ffffff')
          .showSteps(this.controller.isShowSteps())
          .direction(Direction.Ltr)
      }

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.leftSummary)
          .id(`${this.tag}_leftSummary`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .wordBreak(WordBreak.HYPHENATION)

        Text(this.rightSummary)
          .id(`${this.tag}_rightSummary`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.HYPHENATION)
      }
      .direction(Direction.Ltr)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .margin({ bottom: $r('sys.float.padding_level4') })
    .constraintSize({ minHeight: '82vp' })
    .visibility(Visibility.Visible)
    .width('100%')
  }
}