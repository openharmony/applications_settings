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
import curves from '@ohos.curves';
import lottie from '@ohos/lottie';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { SwiperViewData } from '../viewmodel/SwiperViewData';
import { SwiperViewModel } from '../viewmodel/SwiperViewModel';
import { SwiperItem } from '../model/SwiperItem';

const TAG: string = 'AiBarSwiper';

@Component
export default struct AiBarSwiper {
  @State viewData: SwiperViewData = new SwiperViewData();
  private viewModel: SwiperViewModel = new SwiperViewModel(this.viewData);
  @Consume('refreshSnap') @Watch('refreshLottieState') refreshSnap: number;
  @Consume('closeSnap') @Watch('closeLottieState') closeSnap: number;
  @Consume('jumpIndex') @Watch('jumpIndexChange') jumpIndex: number;
  @State isOpen: boolean = false;

  private jumpIndexChange(): void {
    LogUtil.showInfo(TAG, 'jumpIndexChange index is %{public}d', this.jumpIndex);
    this.viewModel.jumpIndexChange(this.jumpIndex);
  }

  private clickJumpLottie(jumpIndex: number): void {
    this.viewModel.clickJumpLottie(jumpIndex);
  }

  private refreshLottieState(): void {
    LogUtil.showInfo(TAG, 'index %{public}d refreshLottieState', this.viewData.currentIndex);
    this.viewModel.refreshLottieState();
  }

  private closeLottieState(): void {
    LogUtil.showInfo(TAG, '[%{public}s] closeLottieState, currentIndex is %{public}d', TAG, this.viewData.currentIndex);
    this.viewModel.closeLottieState();
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, '%{public}s aboutToAppear', TAG);
    this.viewModel.initViewData();
    this.viewModel.updateLottie();
    this.viewModel.registerScreenListener();
    this.isOpen = AccessibilityUtils.isAccessibilityMode();
    LogUtil.showInfo(TAG, `isAccessibilityMode is:${this.isOpen}`);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, '%{public}s aboutToDisAppear', TAG);
    this.viewModel.unRegisterScreenListener();
    const diff = Date.now() - (AppStorage.get<number>('CanvasOnReadyTime') as number) ?? 0;
    LogUtil.showInfo(TAG, `lottie ondisappear ${diff}`);
    if (diff > 1000) {
      lottie.destroy();
    }
  }

  build() {
    Column() {
      this.buildSwiperContent();
    }
  }

  @Builder
  swiperItemBuilder(index: number) {
    Canvas(this.viewData.canvasRenderingContextList[index])
      .width(this.viewData.canvasWidth)
      .height(this.viewData.canvasHeight)
      .onReady(() => {
        AppStorage.setOrCreate('CanvasOnReadyTime', Date.now());
        let item = this.viewData.swiperItems[index];
        LogUtil.showInfo(TAG,
          `onReady,item name is %{public}s,loadCount is %{public}d,width is %{public}d,height is %{public}d`,
          item.name, item.loadCount, this.viewData.canvasRenderingContextList[index].width,
          this.viewData.canvasRenderingContextList[index].height);
        this.viewModel.playLottie(index);
      })
      .onAppear(() => {
      })
      .onDisAppear(() => {
        this.viewData.canvasRenderingContextList[index].setTransform(1, 0, 0, 1, 0, 0);
        this.viewData.canvasRenderingContextList[index].clearRect(0, 0,
          this.viewData.canvasRenderingContextList[index].width,
          this.viewData.canvasRenderingContextList[index].height);
      })
  }

  @Builder
  buildSwiperContent() {
    Swiper(this.viewData.swiperController) {
      ForEach(this.viewData.swiperItems, (item: SwiperItem, index: number) => {
        Column() {
          this.swiperItemBuilder(index)
          Text(item.function)
            .margin({ top: 10 })
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .fontSize(20)
            .textAlign(TextAlign.Center)
          Text(item.detail)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .margin({ top: 8 })
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .textAlign(TextAlign.Center)
        }.padding({ bottom: 40, left: 20, right: 20 })
      }, (item: SwiperItem) => item.name)
    }
    // 无障碍模式下，关闭自动播放。
    .autoPlay(!this.isOpen)
    .curve(curves.springMotion(0.628, 1))
    .interval(this.viewData.lottieTime)
    .indicator(Indicator.dot())
    .loop(!this.isOpen)
    .itemSpace(0)
    .onChange((index: number) => {
      LogUtil.showInfo(TAG, 'lastIndex is %{public}d onChange index is %{public}d', this.viewData.currentIndex, index);
    })
    .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
      LogUtil.showInfo(TAG, 'onAnimationStart index is %{public}d, targetIndex is %{public}d', index, targetIndex);
      this.viewData.lottieItems[index]?.goToAndStop(0, true);
      this.viewData.swiperItems[index].isPlaying = false;
      LogUtil.showInfo(TAG, 'goToAndStop')
    })
    .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
      let item = this.viewData.swiperItems[index];
      item.loadCount++;
      this.viewData.lottieTime = this.viewData.lottieTimes[index];
      LogUtil.showInfo(TAG, 'onAnimationEnd index is %{public}d,load count is %{public}d,lottieTime is %{public}d',
        index,
        item.loadCount, this.viewData.lottieTimes[index]);
      if (item.loadCount >= 1 && !this.viewData.swiperItems[index].isPlaying) {
        this.viewData.lottieItems[index]?.goToAndPlay(0, true);
        LogUtil.showInfo(TAG, 'goToAndPlay')
      }
      this.viewData.currentIndex = index;
    })
  }
}

