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

import lottie, { AnimationItem } from '@ohos/lottie';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';

const TAG: string = 'SwitchCanvasComponent';
const FULL_WIDTH: string = '100%';
const FULL_HEIGHT: string = '100%';
const BUILD_HEIGHT: number = 386;
const ANIMATE_SECONDARY_CLICK: string = 'secondary_click_gesture';
const ANIMATE_TAP: string = 'tab_gesture';
const LOTTIE_GESTURE_SECONDARY_CLICK: string = 'touch_pad_gesture_secondary_click.json';
const LOTTIE_GESTURE_TAP: string = 'touch_pad_gesture_tap.json';
const ANIMATION_TIMEOUT: number = 100;
const INTRODUCE_TEXT_MAX_HEIGHT: number = 66;

/**
 * 触控板导航动画
 *
 * @since 2024-06-05
 */
@Component
export struct TouchpadGuideComponent {
  @State isSecondSelected: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private scrollerController: Scroller = new Scroller();

  build() {
    Column() {
      this.buildSwiperLayout();
    }
    .width(FULL_WIDTH)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear in`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  @Builder
  buildSwiperLayout() {
    RelativeContainer() {
      Row() {
        Scroll(this.scrollerController) {
          this.buildPageSelectText()
        }
        .scrollBar(BarState.Off)
      }
      .alignRules({
        top: { anchor: 'title', align: VerticalAlign.Bottom },
        bottom: { anchor: 'bottom_layout', align: VerticalAlign.Top },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .alignItems(VerticalAlign.Top)
      .id('touchpad_gesture_swiper_layout')
    }
    .height('auto')
  }

  @Builder
  buildPageSelectText() {
    Column() {
      Swiper(this.swiperController) {
        TouchpadCanvasPage({
          scrollerController: this.scrollerController,
          name: ANIMATE_TAP,
          image: LOTTIE_GESTURE_TAP,
          content: ResourceUtil.getStringSync($r('app.string.touchpad_gesture_tap'))
        });
        TouchpadCanvasPage({
          scrollerController: this.scrollerController,
          name: ANIMATE_SECONDARY_CLICK,
          image: LOTTIE_GESTURE_SECONDARY_CLICK,
          content: ResourceUtil.getStringSync($r('app.string.touchpad_gesture_secondary_click'))
        });
      }
    }
    .width(FULL_WIDTH)
  }
}

@Component
export struct TouchpadCanvasPage {
  renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  @State animateItem: AnimationItem | null = null;
  @State name: string = '';
  @State image: string = '';
  @State content: string = '';
  @State scrollerController: Scroller | null = null;
  @State isPortraitOrientation: boolean = false;

  build() {
    Column() {
      Canvas(this.canvasRenderingContext)
        .width(FULL_WIDTH)
        .height($r('app.float.mouse_image_background'))
        .onReady(() => {
          LogUtil.info(`${TAG} ${this.image} Canvas ready to start...`);
          setTimeout(() => {
            this.startAnimation();
          }, ANIMATION_TIMEOUT)

        })
        .onAppear(() => {
          LogUtil.info(`${TAG} ${this.image} Canvas onAppear...`);
        })
        .onDisAppear(() => {
          LogUtil.info(`${TAG} ${this.image} Canvas onDisAppear...`);
          this.destroyAnimation();
        })
      Column() {
        this.buildIntroduceText(this.content)
      }
      .margin({ bottom: '40vp' })
    }
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      LogUtil.info(`${TAG} ${this.image} onVisibleAreaChange isVisible=${isVisible}, currentRatio=${currentRatio}`);
    })
  }

  @Builder
  buildIntroduceText(content: string) {
    Column() {
      Text(content)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
        .width(FULL_WIDTH)
    }
    .alignItems(HorizontalAlign.Start)
  }

  private async startAnimation(): Promise<void> {
    LogUtil.info(`${TAG} startAnimation lottie.${this.image}`);
    const data: object = await RawFileUtil.getJsonRawFile(this.image);
    this.animateItem?.destroy(this.name);
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: this.name,
      contentMode: 'Contain',
      animationData: data,
    })
  }

  private destroyAnimation(): void {
    LogUtil.info(`${TAG} destroy lottie.${this.image}`);
    this.animateItem?.destroy(this.name);
    this.animateItem = null;
  }
}