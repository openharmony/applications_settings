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
import display from '@ohos.display';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { AccessibilityOobeImageSizeAdjust } from '../utils/AccessibilityImageSizeAdjust';

const NUMBER_THREE: number = 3;
const FULL_WIDTH: string = '100%';
const START_PHONE = ['resources/rawfile/oobe_zoom_gesture_start_phone.json', 'app.string.on_zoom_gesture_title',
  'app.string.on_zoom_gesture_summary'];
const RESIZE_PHONE = ['resources/rawfile/oobe_zoom_gesture_resize_phone.json', 'app.string.resize_zoom_gesture_title',
  'app.string.resize_zoom_gesture_summary'];
const MOVE_PHONE = ['resources/rawfile/oobe_zoom_gesture_move_phone.json', 'app.string.move_zoom_gesture_title',
  'app.string.move_zoom_gesture_summary'];
const START_PAD_LAND = ['resources/rawfile/oobe_zoom_gesture_start_pad_land.json', 'app.string.on_zoom_gesture_title',
  'app.string.on_zoom_gesture_summary'];
const RESIZE_PAD_LAND =
  ['resources/rawfile/oobe_zoom_gesture_resize_pad_land.json', 'app.string.resize_zoom_gesture_title',
    'app.string.resize_zoom_gesture_summary'];
const MOVE_PAD_LAND = ['resources/rawfile/oobe_zoom_gesture_move_pad_land.json', 'app.string.move_zoom_gesture_title',
  'app.string.move_zoom_gesture_summary'];
const START_PAD = ['resources/rawfile/oobe_zoom_gesture_start_pad.json', 'app.string.on_zoom_gesture_title',
  'app.string.on_zoom_gesture_summary'];
const RESIZE_PAD = ['resources/rawfile/oobe_zoom_gesture_resize_pad.json', 'app.string.resize_zoom_gesture_title',
  'app.string.resize_zoom_gesture_summary'];
const MOVE_PAD = ['resources/rawfile/oobe_zoom_gesture_move_pad.json', 'app.string.move_zoom_gesture_title',
  'app.string.move_zoom_gesture_summary'];

class CanvasDataStruct {
  public mainCanvasRenderingContext: CanvasRenderingContext2D | null = null;
  public dataPath: string = '';
  public title: string = '';
  public summary: string = '';

  constructor(mainRenderingSettings: RenderingContextSettings, datalist: string[]) {
    this.mainCanvasRenderingContext = new CanvasRenderingContext2D(mainRenderingSettings);
    this.dataPath = datalist[0];
    this.title = datalist[1];
    this.summary = datalist[2];
  }
}

@Component
export struct OobeZoomGestureBuilderComponent {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  public tag: string = 'OobeZoomGestureBuilderComponent: ';
  @State isConfigInit: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private animateItem: AnimationItem | null = null;
  static pageCnt = 0;
  private swiperIndex: number = 0;
  @State sourceDataList: CanvasDataStruct[] = [];
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();
  @State imageSize: number = this.getImageSize();
  private accessibilityOobeImageSizeAdjust: AccessibilityOobeImageSizeAdjust = new AccessibilityOobeImageSizeAdjust();
  private foldStatusChangeCallback = (foldStatus: display.FoldDisplayMode) => {
    LogUtil.debug(`${this.tag} foldStatusChangeCallback ${foldStatus}`);
    this.accessibilityOobeImageSizeAdjust.setImageSize();
    this.imageSize = this.getImageSize();
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL) { //全屏
      this.foldState = display.FoldStatus.FOLD_STATUS_EXPANDED;
      this.updataSourceData();
      return;
    }
    if (foldStatus === display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN) { //折叠
      this.foldState = display.FoldStatus.FOLD_STATUS_FOLDED;
      this.updataSourceData();
      return;
    }
  };

  /**
   * 获取HOPE设备的path list
   * @returns
   */
  private getSuperFoldLottiesPathList(): string[][] {
    let lottiePathList: string[][] = [];
    if (this.foldState === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      lottiePathList = [START_PAD, RESIZE_PAD, MOVE_PAD];
    } else {
      lottiePathList = [START_PHONE, RESIZE_PHONE, MOVE_PHONE];
    }
    return lottiePathList;
  }

  private getLottiesPathList(): string[][] {
    let lottiePathList: string[][] = [];
    if (DeviceUtil.isDevicePhone()) {
      lottiePathList = [START_PHONE, RESIZE_PHONE, MOVE_PHONE];
    } else if (DeviceUtil.isDevicePortrait()) {
      lottiePathList = [START_PAD_LAND, RESIZE_PAD_LAND, MOVE_PAD_LAND];
    } else {
      lottiePathList = [START_PAD, RESIZE_PAD, MOVE_PAD];
    }
    return lottiePathList;
  }

  private getImageSize(): number {
    if (AppStorage.get<number>('AccessibilityOobeImageSize') === undefined) {
      LogUtil.error(`${this.tag} getImageSize length undefined`);
      return 0;
    }
    let length: number = AppStorage.get<number>('AccessibilityOobeImageSize') as number;
    LogUtil.info(`${this.tag} getImageSize: ${length}`);
    return length;
  }

  private replaceSummaryStr(resStr: string): ResourceStr {
    LogUtil.info(`${this.tag} resStr: ${resStr}`);
    if (resStr === START_PHONE[2]) {
      let formatStr: string = ResourceUtil.getLocalNumberFormat(NUMBER_THREE);
      return $r(resStr, formatStr, formatStr);
    }
    return $r(resStr);
  }

  private updataSourceData() {
    LogUtil.info(`${this.tag} updataSourceData`);
    let lottiePathList: string[][] = [];
    lottiePathList = DeviceUtil.isNextSuperFoldProduct() ? this.getSuperFoldLottiesPathList() :
    this.getLottiesPathList();

    for (let i = 0; i < lottiePathList.length; i++) {
      let item = this.sourceDataList[i];
      if (item) {
        item.dataPath = lottiePathList[i][0];
      } else {
        this.sourceDataList.push(new CanvasDataStruct(this.mainRenderingSettings, lottiePathList[i]))
      }
    }
    this.sourceDataList.length = lottiePathList.length;
    let tempElement = this.sourceDataList.pop();
    if (tempElement) {
      this.sourceDataList.push(tempElement);
    }
  }

  private startAnimation(item: CanvasDataStruct) {
    LogUtil.info(`${this.tag} --> Lottie startAnimation for --> ${item.title}`);
    lottie.destroy(item.title);
    this.animateItem?.resize();
    this.animateItem = lottie.loadAnimation({
      container: item.mainCanvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: item.title,
      frameRate: 40,
      contentMode: 'Contain',
      path: item.dataPath,
    });
    this.addEventListener(item);
    LogUtil.info(`${this.tag} --> Lottie startAnimation for --> ${item.title} end`);
  }

  private destroyLottie() {
    let destroyLottieList: string[] = [];
    if (DeviceUtil.isDevicePhone()) {
      destroyLottieList = [START_PHONE[1], RESIZE_PHONE[1], MOVE_PHONE[1]];
    } else if (DeviceUtil.isDevicePortrait()) {
      destroyLottieList = [START_PAD_LAND[1], RESIZE_PAD_LAND[1], MOVE_PAD_LAND[1]];
    } else {
      destroyLottieList = [START_PAD[1], RESIZE_PAD[1], MOVE_PAD[1]];
    }
    for (let i = 0; i < destroyLottieList.length; i++) {
      lottie.destroy(destroyLottieList[i])
    }
  }

  private addEventListener(item: CanvasDataStruct) {
    this.animateItem?.addEventListener('loopComplete', (args: Object): void => {
      LogUtil.info(`${this.tag} loopComplete --> ${item.title} `);
    });
    this.animateItem?.addEventListener('complete', (args: Object): void => {
      LogUtil.info(`${this.tag} complete --> ${item.title}`);
    });
    this.animateItem?.addEventListener('destroy', (args: Object): void => {
      LogUtil.info(`${this.tag}   destroy --> ${item.title}`);
    });
    this.animateItem?.addEventListener('DOMLoaded', (args: Object): void => {
      LogUtil.info(`${this.tag}   DOMLoaded --> ${item.title}`);
    });
  }

  private registerFoldState(): void {
    try {
      display.on('foldDisplayModeChange', this.foldStatusChangeCallback);
    } catch (e) {
      LogUtil.error(`${this.tag} on foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  private unregisterFoldState(): void {
    try {
      display.off('foldDisplayModeChange', this.foldStatusChangeCallback);
      LogUtil.info(`${this.tag} off foldStatusChangeCallback success`);
    } catch (e) {
      LogUtil.error(`${this.tag} off foldStatusChangeCallback error`);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.updataSourceData();
    this.destroyLottie();
    this.registerFoldState();
    OobeZoomGestureBuilderComponent.pageCnt++;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    OobeZoomGestureBuilderComponent.pageCnt--;
    if (OobeZoomGestureBuilderComponent.pageCnt === 0) {
      LogUtil.info(`${this.tag} page disappear`);
      this.destroyLottie();
    }
    this.unregisterFoldState();
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.pageRoot.onPageShow();
    this.updataSourceData();
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
    this.pageRoot.onPageHide();
  }

  @Builder
  buildCanvas() {
    Swiper(this.swiperController) {
      this.buildLottie();
    }
    .index(this.swiperIndex)
    .onChange((index: number) => {
      LogUtil.info(`${this.tag} swiper onChange. index: ${index}, swiperIndex: ${this.swiperIndex}`);
    })
    .accessibilityGroup(true)
    .cachedCount(1)
    .curve(Curve.Linear)
    .loop(false)
    .margin({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
      bottom: $r('app.float.margin_16')
    })
  }

  @Builder
  buildLottie() {
    ForEach(this.sourceDataList, (item: CanvasDataStruct, index: number) => {
      Column() {
        Canvas(item.mainCanvasRenderingContext)
          .size({
            width: `${(this.imageSize)}vp`,
            height: `${(this.imageSize)}vp`,
          })
          .onReady(() => {
            LogUtil.info(`${this.tag} --> Canvas onReady... --> ${item.title} `);
            this.startAnimation(item);
          })
        this.loadContent(index);
      }
      .width(FULL_WIDTH)
    }, (item: CanvasDataStruct) => item.dataPath + item.title)
  }

  @Builder
  loadContent(index: number) {
    Stack({ alignContent: Alignment.Top }) {
      ForEach(this.sourceDataList, (innerItem: CanvasDataStruct, innerIndex: number) => {
        Column() {
          Row() {
            Text($r(innerItem.title))
              .fontSize($r('sys.float.Title_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .textAlign(TextAlign.Center)
              .margin({
                top: $r('app.float.margin_24'),
                bottom: $r('app.float.margin_8')
              })
              .wordBreak(WordBreak.HYPHENATION)
              .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
          }

          Row() {
            Text(this.replaceSummaryStr(innerItem.summary))
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .textAlign(TextAlign.Center)
              .wordBreak(WordBreak.HYPHENATION)
              .align(Alignment.Top)
              .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
          }
          .width(FULL_WIDTH)
          .padding({
            bottom: $r('app.float.margin_32')
          })
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Center)
        }
        .visibility((index === innerIndex) ? Visibility.Visible : Visibility.Hidden)
      })
    }
  }

  build() {
    Scroll() {
      Column() {
        Stack() {
          Column() {
            this.buildCanvas();
          }
        }
        .width(FULL_WIDTH)
        .clip(true)
      }
      .width(FULL_WIDTH)
    }
    .scrollBar(BarState.Auto)
    .align(Alignment.TopStart)
    .edgeEffect(EdgeEffect.Spring)
    .constraintSize({
      maxHeight: '100%'
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
  }
}