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
import lottie, { AnimationItem } from '@ohos/lottie';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';

const FULL_WIDTH: string = '100%';

@Component
export struct AccessibilityCanvasComponent {
  public tag: string = 'AccessibilityCanvasComponent: ';
  public dataPath: string = '';
  public title: string = '';
  public summary: string = '';
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.mainRenderingSettings);
  private accessibilityImageSizeAdjust: AccessibilityImageSizeAdjust = new AccessibilityImageSizeAdjust();
  private animateItem: AnimationItem | null = null;

  private addEventListener() {
    this.animateItem?.addEventListener('loopComplete', (args: Object): void => {
      LogUtil.info(`${this.tag} loopComplete --> ${this.title} `);
    });
    this.animateItem?.addEventListener('complete', (args: Object): void => {
      LogUtil.info(`${this.tag} complete --> ${this.title}`);
    });
    this.animateItem?.addEventListener('destroy', (args: Object): void => {
      LogUtil.info(`${this.tag} destroy --> ${this.title}`);
    });
    this.animateItem?.addEventListener('DOMLoaded', (args: Object): void => {
      LogUtil.info(`${this.tag} DOMLoaded --> ${this.title}`);
    });
  }

  private startAnimation() {
    LogUtil.info(`${this.tag} --> Lottie startAnimation for --> ${this.title}`);
    lottie.destroy(this.title);
    this.animateItem?.resize();
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: this.title,
      frameRate: 40,
      contentMode: 'Contain',
      path: this.dataPath,
    });
    this.addEventListener();
    LogUtil.info(`${this.tag} --> Lottie startAnimation for --> ${this.title} end`);
  }

  build() {
    Column() {
      Stack() {
        Column() {
          Canvas(this.canvasRenderingContext)
            .size({
              width: `${(this.accessibilityImageSizeAdjust.getImageSize())}vp`,
              height: `${(this.accessibilityImageSizeAdjust.getImageSize())}vp`,
            })
            .onReady(() => {
              LogUtil.info(`${this.tag} --> Canvas onReady... --> ${this.title} `);
              this.startAnimation();
            })

          Row() {
            Text($r(this.title))
              .fontSize($r('sys.float.Title_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .textAlign(TextAlign.Center)
              .wordBreak(WordBreak.HYPHENATION)
              .margin({
                top: $r('app.float.margin_16'),
                bottom: $r('app.float.margin_8')
              })
              .maxFontSize($r('app.float.font_56'))
          }
          Row() {
            Text($r(this.summary))
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textAlign(TextAlign.Center)
              .wordBreak(WordBreak.HYPHENATION)
              .align(Alignment.Top)
              .lineHeight($r('app.float.font_19'))
          }
          .width(FULL_WIDTH)
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Center)
        }
        .accessibilityGroup(true)
        .margin({
          left: $r('app.float.margin_12'),
          right: $r('app.float.margin_12'),
        })
      }
      .width(FULL_WIDTH)
      .clip(true)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width(FULL_WIDTH)
  }
}