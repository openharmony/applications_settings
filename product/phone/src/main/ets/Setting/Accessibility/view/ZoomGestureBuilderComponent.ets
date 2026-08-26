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
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

const OPACITY_PERCENT_FULL: number = 1;
const NUMBER_THREE: number = 3;
const CLICK_NUMBER: number = 888;
const FULL_WIDTH: string = '100%';
const START_PHONE = ['resources/rawfile/oobe_zoom_gesture_start_phone.json', 'app.string.on_zoom_gesture_title',
  'app.string.on_zoom_gesture_summary'];
const RESIZE_PHONE = ['resources/rawfile/oobe_zoom_gesture_resize_phone.json', 'app.string.resize_zoom_gesture_title',
  'app.string.resize_zoom_gesture_summary'];
const MOVE_PHONE = ['resources/rawfile/oobe_zoom_gesture_move_phone.json', 'app.string.move_zoom_gesture_title',
  'app.string.move_zoom_gesture_summary'];
const START_PAD_LAND = ['resources/rawfile/oobe_zoom_gesture_start_pad_land.json', 'app.string.on_zoom_gesture_title',
  'app.string.on_zoom_gesture_summary'];
const RESIZE_PAD_LAND = ['resources/rawfile/oobe_zoom_gesture_resize_pad_land.json', 'app.string.resize_zoom_gesture_title',
  'app.string.resize_zoom_gesture_summary'];
const MOVE_PAD_LAND = ['resources/rawfile/oobe_zoom_gesture_move_pad_land.json', 'app.string.move_zoom_gesture_title',
  'app.string.move_zoom_gesture_summary'];
const START_PAD = ['resources/rawfile/oobe_zoom_gesture_start_pad.json', 'app.string.on_zoom_gesture_title',
  'app.string.on_zoom_gesture_summary'];
const RESIZE_PAD = ['resources/rawfile/oobe_zoom_gesture_resize_pad.json', 'app.string.resize_zoom_gesture_title',
  'app.string.resize_zoom_gesture_summary'];
const MOVE_PAD = ['resources/rawfile/oobe_zoom_gesture_move_pad.json', 'app.string.move_zoom_gesture_title',
  'app.string.move_zoom_gesture_summary'];

@Component
export struct ZoomGestureImageComponent {
  public tag: string = 'ZoomGestureImageComponent: ';
  @State isConfigInit: Boolean = false;

  private getImage(): ResourceStr | PixelMap {
    if (DeviceUtil.isDevicePhone()) {
      return $r('app.media.ic_accessibility_zoom_gesture');
    }
    if (DeviceUtil.isDevicePortrait()) {
      return $r('app.media.ic_accessibility_zoom_gesture_pad_land');
    }
    return $r('app.media.ic_accessibility_zoom_gesture_pad');
  }

  private getImageSize(): number {
    let length = AppStorage.get<number>('AccessibilityImageSize') as number;
    LogUtil.info(`${this.tag} GetImageSize: ${length}`);
    return length;
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  build() {
    Column() {
      Stack() {
        Column() {
          Image(this.getImage())
            .visibility(Visibility.Visible)
            .interpolation(ImageInterpolation.Medium)
            .autoResize(false)
            .size({
              width: `${(this.getImageSize())}vp`,
              height: `${(this.getImageSize())}vp`,
            })
            .objectFit(ImageFit.Cover)
        }
      }
      .size({
        width: '100%',
        height: `${(this.getImageSize())}vp`,
      })
      .clip(true)
      .margin({ bottom: $r('app.float.margin_24') })
    }
    .width('100%')
  }
}

@Component
export struct ZoomGestureSummaryComponent {
  public tag: string = 'ZoomGestureSummaryComponent: ';
  @State isConfigInit: Boolean = false;

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.zoom_gesture_risk_warning'))
            .id(`text_title_screen_reader_help`)
            .visibility(Visibility.Visible)
            .font({
              size: $r('sys.float.Subtitle_S'),
              weight: FontWeight.Medium,
            })
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .height('auto')
        .margin({
          top: $r('app.float.wh_value_24'),
          bottom: $r('app.float.wh_value_8'),
        })
        .justifyContent(FlexAlign.Start)
      }
      .enabled(true)
      .constraintSize({
        minHeight: '48vp'
      })
      .opacity(OPACITY_PERCENT_FULL)
      .margin({
        left: $r('app.float.wh_value_12'),
        right: $r('app.float.wh_value_12'),
        top: $r('app.float.wh_value_0'),
        bottom: $r('app.float.wh_value_0'),
      })
      .visibility(Visibility.Visible);

      Column() {
        Row() {
          Text($r('app.string.zoom_gesture_risk_warning_summary', ResourceUtil.getLocalNumberFormat(CLICK_NUMBER)))
            .id(`text_title_tips`)
            .visibility(Visibility.Visible)
            .font({
              size: $r('sys.float.Body_M'),
              weight: FontWeight.Regular,
            })
            .fontColor($r('sys.color.font_secondary'))
            .constraintSize({
              minHeight: $r('app.float.length_19')
            })
            .wordBreak(WordBreak.HYPHENATION)
        }
        .visibility(Visibility.Visible)
        .width('100%')
        .height('auto')
        .margin({
          top: $r('app.float.wh_value_8'),
          bottom: $r('app.float.wh_value_8'),
        })
        .justifyContent(FlexAlign.Start)
      }
      .enabled(true)
      .margin({
        left: $r('app.float.wh_value_12'),
        right: $r('app.float.wh_value_12'),
        top: $r('app.float.wh_value_0'),
        bottom: $r('app.float.wh_value_0'),
      })
      .opacity(OPACITY_PERCENT_FULL)
    }
    .width('100%')
  }
}

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
export struct ZoomGestureLottieComponent {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  public tag: string = 'ZoomGestureLottieComponent: ';
  @State isConfigInit: Boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private animateItem: AnimationItem | null = null;
  @State params: PushParam | null = null;
  static pageCnt = 0;
  private swiperIndex: number = 0;
  @State sourceDataList: CanvasDataStruct[] = [];

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
    let length = AppStorage.get<number>('AccessibilityImageSize') as number;
    LogUtil.info(`${this.tag} GetImageSize: ${length}`);
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
    lottiePathList = this.getLottiesPathList();

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

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.updataSourceData();
    this.destroyLottie();
    let param: string = this.params?.itemName as string;
    LogUtil.info(`${this.tag} itemName = ${param}`);
    if (param === MOVE_PHONE[1]) {
      this.swiperIndex = 2;
    } else if (param === RESIZE_PHONE[1]) {
      this.swiperIndex = 1;
    } else {
      this.swiperIndex = 0;
    }
    ZoomGestureLottieComponent.pageCnt++;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    ZoomGestureLottieComponent.pageCnt--;
    if (ZoomGestureLottieComponent.pageCnt === 0) {
      LogUtil.info(`${this.tag} page disappear`);
      this.destroyLottie();
    }
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
      LogUtil.info(`${this.tag} swiperr onChange. index: ${index}, swiperIndex: ${this.swiperIndex}`);
    })
    .accessibilityGroup(true)
    .indicator(Indicator.dot())
    .cachedCount(1)
    .curve(Curve.Linear)
    .loop(false)
    .margin({
      left: $r('app.float.margin_12'),
      right: $r('app.float.margin_12'),
    })
  }

  @Builder
  buildLottie() {
    ForEach(this.sourceDataList, (item: CanvasDataStruct, index: number) => {
      Column() {
        Canvas(item.mainCanvasRenderingContext)
          .size({
            width: `${(this.getImageSize())}vp`,
            height: `${(this.getImageSize())}vp`,
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
              .wordBreak(WordBreak.HYPHENATION)
              .textAlign(TextAlign.Center)
              .margin({
                top: $r('app.float.margin_24'),
                bottom: $r('app.float.margin_8')
              })
          }

          Row() {
            Text(this.replaceSummaryStr(innerItem.summary))
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .wordBreak(WordBreak.HYPHENATION)
              .textAlign(TextAlign.Center)
              .align(Alignment.Top)
          }
          .width(FULL_WIDTH)
          .margin({
            bottom: $r('app.float.margin_48')
          })
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Center)
        }
        .visibility((index === innerIndex) ? Visibility.Visible : Visibility.Hidden)
      })
    }
  }

  build() {
    Column() {
      Stack() {
        Column() {
          this.buildCanvas();
        }
      }
      .width(FULL_WIDTH)
      .clip(true)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .width(FULL_WIDTH)
  }
}