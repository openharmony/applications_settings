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
import settings from '@ohos.settings';
import display from '@ohos.display';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import lottie, { AnimationItem } from '@ohos/lottie';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  AccessibilityLevelType,
  AccessibilityUtils
} from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  PADDING_4,
  PADDING_8,
  PADDING_10,
  PADDING_12,
  PADDING_14,
  PADDING_16,
  PADDING_24,
  PADDING_40
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';

const TAG: string = 'MultiWindowSettings :';

const MULTI_WINDOW_CHANGE_VIEWS_TITLE = 'app.string.MultiWindow_change_views_title';
const MULTI_WINDOW_CHANGE_VIEWS_CONTENTS = 'app.string.MultiWindow_change_views_contents';
const MULTI_WINDOW_FLOATING_WINDOWS_TITLE = 'app.string.MultiWindow_floating_windows_title';
const MULTI_WINDOW_FLOATING_WINDOWS_CONTENTS = 'app.string.MultiWindow_floating_windows_contents';
const MULTI_WINDOW_DOCK_TITLE = 'app.string.MultiWindow_dock_title';
const MULTI_WINDOW_DOCK_CONTENTS = 'app.string.MultiWindow_dock_contents';
const MULTI_WINDOW_SPLIT_SCREEN_TITLE = 'app.string.MultiWindow_split_screen_title';
const MULTI_WINDOW_SPLIT_SCREEN_CONTENTS = 'app.string.MultiWindow_split_screen_contents';
const MULTI_WINDOW_MID_VIEW_TITLE = 'app.string.MultiWindow_Mid_View_title';
const MULTI_WINDOW_MID_VIEW_CONTENTS = 'app.string.MultiWindow_Mid_View_contents';

const PAGE_BACKGROUND_COLOR = $r('sys.color.background_secondary');
const SWIPER_TITLE_FONTSIZE = $r('sys.float.Title_S');
const SWIPER_CONTENT_FONTSIZE = $r('sys.float.Body_M');
const SWIPER_CONTENT_FONTCOLOR = $r('sys.color.font_secondary');
const SWITCH_DOCK_TITLE = $r('app.string.MultiWindow_dock_switch_title');
const SWITCH_DOCK_CONTENTS = $r('app.string.MultiWindow_dock_switch_contents');
const SWITCH_TITLE_FONTSIZE = $r('sys.float.Body_L');
const SWITCH_TITLE_FONTCOLOR = $r('sys.color.font_primary');
const SWITCH_TITLE_RADIUS = $r('sys.float.corner_radius_level10');
const SWITCH_BACKGROUND_COLOR = $r('sys.color.comp_background_list_card');
const SWITCH_CONTENT_FONTSIZE = $r('sys.float.Body_S');
const SWITCH_CONTENT_FONTCOLOR = $r('sys.color.font_secondary');
const SWITCH_PIP_TITLE = $r('app.string.MultiWindow_pip_switch_title');
const SWITCH_PIP_CONTENTS = $r('app.string.MultiWindow_pip_switch_desc');
const MULTI_WINDOW_FORCE_SWITCH_PAGE_TITLE = $r('app.string.multi_window_force_switch');
const MULTI_WINDOW_FORCE_SWITCH_PAGE_ARROW_IMG = $r('app.media.ic_settings_arrow');
const MULTI_WINDOW_FORCE_SWITCH_PAGE_ARROW_COLOR = $r('sys.color.icon_fourth');
const MULTI_WINDOW_FORCE_SWITCH_PAGE_PRESS_COLOR = $r('sys.color.interactive_click');
const SWITCH_LINKAGE_SCENE_TITLE = $r('app.string.MultiWindow_split_switch_title');
const SWITCH_LINKAGE_SCENE_CONTENTS_DECLARATION = $r('app.string.MultiWindow_split_switch_desc_declaration');
const SWITCH_LINKAGE_SCENE_CONTENTS = $r('app.string.MultiWindow_split_switch_desc_last');

const CHANGE_VIEWS_PHONE = ['resources/rawfile/multiWindowLottie/multiwindow_change_views_phone.json', MULTI_WINDOW_CHANGE_VIEWS_TITLE, MULTI_WINDOW_CHANGE_VIEWS_CONTENTS];
const FLOATING_WINDOWS_PHONE = ['resources/rawfile/multiWindowLottie/multiwindow_floating_windows_phone.json', MULTI_WINDOW_FLOATING_WINDOWS_TITLE, MULTI_WINDOW_FLOATING_WINDOWS_CONTENTS];
const DOCK_PHONE = ['resources/rawfile/multiWindowLottie/multiwindow_dock_phone.json', MULTI_WINDOW_DOCK_TITLE, MULTI_WINDOW_DOCK_CONTENTS];
const SPLIT_SCREEN_PHONE = ['resources/rawfile/multiWindowLottie/multiwindow_split_screen_phone.json', MULTI_WINDOW_SPLIT_SCREEN_TITLE, MULTI_WINDOW_SPLIT_SCREEN_CONTENTS];

const CHANGE_VIEWS_FOLD = ['resources/rawfile/multiWindowLottie/multiwindow_change_views_fold.json', MULTI_WINDOW_CHANGE_VIEWS_TITLE, MULTI_WINDOW_CHANGE_VIEWS_CONTENTS];
const FLOATING_WINDOWS_FOLD = ['resources/rawfile/multiWindowLottie/multiwindow_floating_windows_fold.json', MULTI_WINDOW_FLOATING_WINDOWS_TITLE, MULTI_WINDOW_FLOATING_WINDOWS_CONTENTS];
const DOCK_FOLD = ['resources/rawfile/multiWindowLottie/multiwindow_dock_fold.json', MULTI_WINDOW_DOCK_TITLE, MULTI_WINDOW_DOCK_CONTENTS];
const SPLIT_SCREEN_FOLD = ['resources/rawfile/multiWindowLottie/multiwindow_split_screen_fold.json', MULTI_WINDOW_SPLIT_SCREEN_TITLE, MULTI_WINDOW_SPLIT_SCREEN_CONTENTS];
const MID_VIEW_FOLD = ['resources/rawfile/multiWindowLottie/multiwindow_mid_view_fold.json', MULTI_WINDOW_MID_VIEW_TITLE, MULTI_WINDOW_MID_VIEW_CONTENTS];

const CHANGE_VIEWS_PAD = ['resources/rawfile/multiWindowLottie/multiwindow_change_views_pad.json', MULTI_WINDOW_CHANGE_VIEWS_TITLE, MULTI_WINDOW_CHANGE_VIEWS_CONTENTS];
const FLOATING_WINDOWS_PAD = ['resources/rawfile/multiWindowLottie/multiwindow_floating_windows_pad.json', MULTI_WINDOW_FLOATING_WINDOWS_TITLE, MULTI_WINDOW_FLOATING_WINDOWS_CONTENTS];
const DOCK_PAD = ['resources/rawfile/multiWindowLottie/multiwindow_dock_pad.json', MULTI_WINDOW_DOCK_TITLE, MULTI_WINDOW_DOCK_CONTENTS];
const SPLIT_SCREEN_PAD = ['resources/rawfile/multiWindowLottie/multiwindow_split_screen_pad.json', MULTI_WINDOW_SPLIT_SCREEN_TITLE, MULTI_WINDOW_SPLIT_SCREEN_CONTENTS];
const MID_VIEW_PAD = ['resources/rawfile/multiWindowLottie/multiwindow_mid_view_pad.json', MULTI_WINDOW_MID_VIEW_TITLE, MULTI_WINDOW_MID_VIEW_CONTENTS];

const PAD_LOTTIE_RATIO = 1920 / 1280;
const PIP_AUTO_START_KEY: string = 'auto_start_pip_status';
const MULTI_DOCK_STATUS: string = 'multi_dock_status';
const LINKAGE_SCENE_STATUS: string = 'linkage_scene_status';

@Observed
class MultiWindowSettingDataStruct {
  public mainCanvasRenderingContext: CanvasRenderingContext2D | null = null;
  public dataPath: string = '';
  public title: string = '';
  public content: string = '';

  constructor(mainRenderingSettings: RenderingContextSettings, datalist: string[]) {
    this.mainCanvasRenderingContext = new CanvasRenderingContext2D(mainRenderingSettings);
    this.dataPath = datalist[0];
    this.title = datalist[1];
    this.content = datalist[2];
  }
}

@Component
export struct MultiWindowSettings {
  @State params: PushParam | null = null;
  @State sourceDataList: MultiWindowSettingDataStruct[] = [];
  @State multiDockSwitchState: boolean = true;
  @State pipSwitchState: boolean = true;
  @State linkageSceneSwitchState: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private lottieItems: AnimationItem[] = [];
  private isLargeFoldDevice: boolean = false;
  private lottieRatio = 1;
  private isPad: boolean = DeviceUtil.isDevicePad();
  private isMidConfigSupport: boolean = false;
  private isLinkageConfigSupport: boolean = false;
  @State pagePadding: LengthMetrics = PADDING_16;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    try {
      this.isMidConfigSupport = systemParameterEnhance.getSync('const.window.supportMidScene', 'false') === 'true';
      this.isLinkageConfigSupport = systemParameterEnhance.getSync('const.window.supportLinkageScene', 'false') === 'true';
      LogUtil.info(`${TAG} Get support mid scene support result: ${this.isMidConfigSupport},` +
        `linkage scene support result: ${this.isLinkageConfigSupport}`);
    } catch (error) {
      LogUtil.info(`${TAG} Get support mid scene failed: ${error}`);
      this.isMidConfigSupport = false;
    }
    this.destroyLottie();
    this.initSwitchStatus();
    this.initIsLargeFoldDeviceFlag();
    this.registerObserver();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.destroyLottie();
    this.unRegisterObserver();
  }

  private foldStatusChangeCallback: () => void = () => {
    this.initSourceData();
  };

  private initSwitchStatus(): void {
    this.multiDockSwitchState =
      SettingsDataUtils.getSettingsData(MULTI_DOCK_STATUS, 'true', settings.domainName.USER_PROPERTY) === 'true';
    this.pipSwitchState =
      SettingsDataUtils.getSettingsData(PIP_AUTO_START_KEY, 'true', settings.domainName.USER_PROPERTY) === 'true';
    this.linkageSceneSwitchState =
      SettingsDataUtils.getSettingsData(LINKAGE_SCENE_STATUS, '1', settings.domainName.USER_PROPERTY) === '1';
    LogUtil.info(`${TAG} init multi dock switch state is ${this.multiDockSwitchState},` +
      `pip switch state is ${this.pipSwitchState}, linkage scene switch state is ${this.linkageSceneSwitchState}`);
  }

  private registerObserver(): void {
    SettingsDataUtils.registerKeyObserverUser(MULTI_DOCK_STATUS, () => {
      this.multiDockSwitchState =
        SettingsDataUtils.getSettingsData(MULTI_DOCK_STATUS, 'true', settings.domainName.USER_PROPERTY) === 'true';
    })
    SettingsDataUtils.registerKeyObserverUser(PIP_AUTO_START_KEY, () => {
      this.pipSwitchState =
        SettingsDataUtils.getSettingsData(PIP_AUTO_START_KEY, 'true', settings.domainName.USER_PROPERTY) === 'true';
    })
    SettingsDataUtils.registerKeyObserverUser(LINKAGE_SCENE_STATUS, () => {
      this.linkageSceneSwitchState =
        SettingsDataUtils.getSettingsData(LINKAGE_SCENE_STATUS, '1', settings.domainName.USER_PROPERTY) === '1';
    })
  }

  private unRegisterObserver(): void {
    if (this.isLargeFoldDevice) {
      try {
        display.off('foldStatusChange', this.foldStatusChangeCallback);
      } catch (e) {
        LogUtil.error(`${TAG} off foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
      }
    }
    SettingsDataUtils.unregisterKeyObserverUser(PIP_AUTO_START_KEY);
    SettingsDataUtils.unregisterKeyObserverUser(MULTI_DOCK_STATUS);
    SettingsDataUtils.unregisterKeyObserverUser(LINKAGE_SCENE_STATUS);
  }

  private initSourceData() {
    let lottiePathList: string[][] = [];

    if (this.isPad) {
      lottiePathList = [CHANGE_VIEWS_PAD, FLOATING_WINDOWS_PAD, DOCK_PAD, SPLIT_SCREEN_PAD];
      this.pagePadding = PADDING_24;
      this.lottieRatio = PAD_LOTTIE_RATIO;
      if (this.isMidConfigSupport) {
        lottiePathList.push(MID_VIEW_PAD);
      }
    } else if (this.isLargeFoldDevice && DisplayUtils.getFoldStatus() !== display.FoldStatus.FOLD_STATUS_FOLDED) {
      lottiePathList = [CHANGE_VIEWS_FOLD, FLOATING_WINDOWS_FOLD, DOCK_FOLD, SPLIT_SCREEN_FOLD];
      if (this.isMidConfigSupport) {
        lottiePathList.push(MID_VIEW_FOLD);
      }
    } else {
      lottiePathList = [CHANGE_VIEWS_PHONE, FLOATING_WINDOWS_PHONE, DOCK_PHONE, SPLIT_SCREEN_PHONE];
    }

    for (let i = 0; i < lottiePathList.length; i++) {
      let index = this.sourceDataList[i]
      if (index) {
        index.dataPath = lottiePathList[i][0];
      } else {
        this.sourceDataList.push(new MultiWindowSettingDataStruct(this.mainRenderingSettings, lottiePathList[i]))
      }
    }
    this.sourceDataList.length = lottiePathList.length;

    let tempElement = this.sourceDataList.pop();
    if (tempElement) {
      this.sourceDataList.push(tempElement);
    }
  }

  async initIsLargeFoldDeviceFlag(): Promise<void> {
    try {
      const foldScreenFlag = await systemParameterEnhance.get('const.window.foldscreen.type', '0,0,0,0');
      if (foldScreenFlag === '' || foldScreenFlag === null) {
        this.isLargeFoldDevice = false;
      }
      this.isLargeFoldDevice = foldScreenFlag.substring(0, 1) === '1';
    } catch (error) {
      LogUtil.error(`${TAG} foldScreenFlag init  error: ${error}`);
    }
    this.initSourceData();
    if (this.isLargeFoldDevice) {
      try {
        display.on('foldStatusChange', this.foldStatusChangeCallback);
      } catch (e) {
        LogUtil.error(`${TAG} on foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
      }
    }
  }

  private destroyLottie() {
    LogUtil.info(`${TAG} destroyLottie`);
    let destroyLottieList = [CHANGE_VIEWS_PAD[0], FLOATING_WINDOWS_PAD[0],
      DOCK_PAD[0], SPLIT_SCREEN_PAD[0], MID_VIEW_PAD[0]];
    for (let i = 0; i < destroyLottieList.length; i++) {
      lottie.destroy(destroyLottieList[i])
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    this.initSourceData();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Blank().height($r('app.float.navigation_56'))
          this.guide();
          this.dockSwitch();
          this.pipSwitch();
          if (this.isLinkageConfigSupport) {
            this.MultiWindowLinkageSceneSwitch();
          }
          this.MultiWindowForceSwitchPageBuilder();
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({ start: this.pagePadding, end: this.pagePadding })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .size({
        width: '100%',
        height: '100%'
      })
    }
    .hideTitleBar(false)
    .title($r('app.string.MultiWindow_title'))
    // .titleBar({content: {title: {mainTitle: (AppStorage.get<Context>('pageContext') as
    // Context)?.resourceManager?.getStringSync($r('app.string.MultiWindow_title').id)}}})
    .backgroundColor(PAGE_BACKGROUND_COLOR)
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  @Builder
  guide() {
    Swiper(this.swiperController) {
      ForEach(this.sourceDataList, (item: MultiWindowSettingDataStruct, index: number) => {
        Column() {
          this.loadLottie(item, index);
          this.loadContent(index);
        }
        .width('100%')
      }, (item: MultiWindowSettingDataStruct) => item.dataPath)
    }
    .cachedCount(1)
    .indicator(Indicator.dot())
    .curve(Curve.Linear)
    .loop(false)
  }

  @Builder
  dockSwitch() {
    Column() {
      Row() {
        Text(SWITCH_DOCK_TITLE)
          .fontSize(SWITCH_TITLE_FONTSIZE)
          .fontColor(SWITCH_TITLE_FONTCOLOR)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.multiDockSwitchState })
          .onChange((isOn: boolean) => {
            SettingsDataUtils.setSettingsData(MULTI_DOCK_STATUS, isOn ? 'true' : 'false',
              settings.domainName.USER_PROPERTY);
            LogUtil.info(`${TAG} multiDockSwitchState change: ${isOn}`);
          })
          .accessibilityLevel(AccessibilityLevelType.YES)
          .hoverEffect(HoverEffect.None)
      }
      .padding({
        start: PADDING_12,
        end: PADDING_12,
        top: PADDING_14,
        bottom: PADDING_14
      })
      .margin({ bottom: PADDING_8 })
      .backgroundColor(SWITCH_BACKGROUND_COLOR)
      .borderRadius(SWITCH_TITLE_RADIUS)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .accessibilityGroup(true)
      .accessibilityDescription(' ')
      .onClick(() => {
        AccessibilityUtils.announceText(
          this.multiDockSwitchState ? $r('app.string.dialog_enable') : $r('app.string.dialog_disable'));
      })

      Row() {
        Text(SWITCH_DOCK_CONTENTS)
          .fontSize(SWITCH_CONTENT_FONTSIZE)
          .fontColor(SWITCH_CONTENT_FONTCOLOR)
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
      }
      .width('100%')
      .padding({ start: PADDING_12, end: PADDING_12 })
      .margin({ bottom: PADDING_16 })
    }
  }

  @Builder
  pipSwitch() {
    Column() {
      Row() {
        Text(SWITCH_PIP_TITLE)
          .fontSize(SWITCH_TITLE_FONTSIZE)
          .fontColor(SWITCH_TITLE_FONTCOLOR)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.pipSwitchState })
          .onChange((isOn: boolean) => {
            SettingsDataUtils.setSettingsData(PIP_AUTO_START_KEY, isOn ? 'true' : 'false',
              settings.domainName.USER_PROPERTY);
            LogUtil.info(`${TAG} pipSwitchState change: ${isOn}`);
          })
          .accessibilityLevel(AccessibilityLevelType.YES)
          .hoverEffect(HoverEffect.None)
      }
      .padding({
        start: PADDING_12,
        end: PADDING_12,
        top: PADDING_14,
        bottom: PADDING_14
      })
      .margin({ bottom: PADDING_8 })
      .backgroundColor(SWITCH_BACKGROUND_COLOR)
      .borderRadius(SWITCH_TITLE_RADIUS)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .accessibilityGroup(true)
      .accessibilityDescription(' ')
      .onClick(() => {
        AccessibilityUtils.announceText(
          this.pipSwitchState ? $r('app.string.dialog_enable') : $r('app.string.dialog_disable'));
      })

      Row() {
        Text(SWITCH_PIP_CONTENTS)
          .fontSize(SWITCH_CONTENT_FONTSIZE)
          .fontColor(SWITCH_CONTENT_FONTCOLOR)
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
      }
      .width('100%')
      .padding({ start: PADDING_12, end: PADDING_12 })
      .margin({ bottom: PADDING_16 })
    }
  }

  @Builder
  MultiWindowLinkageSceneSwitch() {
    Column() {
      Row() {
        Text(SWITCH_LINKAGE_SCENE_TITLE)
          .fontSize(SWITCH_TITLE_FONTSIZE)
          .fontColor(SWITCH_TITLE_FONTCOLOR)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.linkageSceneSwitchState })
          .onChange((isOn: boolean) => {
            SettingsDataUtils.setSettingsData(LINKAGE_SCENE_STATUS, isOn ? '1' : '0',
              settings.domainName.USER_PROPERTY);
            LogUtil.info(`${TAG} linkSceneSwitchState change: ${isOn}`);
          })
          .accessibilityLevel(AccessibilityLevelType.YES)
          .hoverEffect(HoverEffect.None)
      }
      .padding({
        start: PADDING_12,
        end: PADDING_12,
        top: PADDING_14,
        bottom: PADDING_14
      })
      .margin({ bottom: PADDING_8 })
      .backgroundColor(SWITCH_BACKGROUND_COLOR)
      .borderRadius(SWITCH_TITLE_RADIUS)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .accessibilityGroup(true)
      .accessibilityDescription(' ')
      .onClick(() => {
        AccessibilityUtils.announceText(
          this.linkageSceneSwitchState ? $r('app.string.dialog_enable') : $r('app.string.dialog_disable'));
      })

      Row() {
        Text() {
          Span(ResourceUtil.getStringSync(SWITCH_LINKAGE_SCENE_CONTENTS).split('%s')[0])
            .fontSize(SWITCH_CONTENT_FONTSIZE)
            .fontColor(SWITCH_CONTENT_FONTCOLOR)
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
          Span(SWITCH_LINKAGE_SCENE_CONTENTS_DECLARATION)
            .fontSize(SWITCH_CONTENT_FONTSIZE)
            .fontColor($r('sys.color.ohos_id_color_text_hyperlink'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .onClick(() => {
              PageRouter.push(NavEntryKey.MULTI_WINDOW_LINKAGE_SCENE_PRIVACY_ENTRY);
            })
          Span(ResourceUtil.getStringSync(SWITCH_LINKAGE_SCENE_CONTENTS).split('%s')[1])
            .fontSize(SWITCH_CONTENT_FONTSIZE)
            .fontColor(SWITCH_CONTENT_FONTCOLOR)
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
        }
      }
      .width('100%')
      .padding({ start: PADDING_12, end: PADDING_12 })
      .margin({ bottom: PADDING_16 })
    }
  }

  @Builder
  MultiWindowForceSwitchPageBuilder() {
    Column() {
      Row() {
        Text(MULTI_WINDOW_FORCE_SWITCH_PAGE_TITLE)
          .fontSize(SWITCH_TITLE_FONTSIZE)
          .fontColor(SWITCH_TITLE_FONTCOLOR)
          .fontWeight(FontWeight.Medium)
          .width('90%')
        Image(MULTI_WINDOW_FORCE_SWITCH_PAGE_ARROW_IMG)
          .draggable(false)
          .fillColor(MULTI_WINDOW_FORCE_SWITCH_PAGE_ARROW_COLOR)
          .width(12)
          .height(24)
          .matchTextDirection(true)
      }
      .constraintSize({
        minHeight: 50
      })
      .width('100%')
      .padding({
        start: PADDING_8,
        end: PADDING_8,
        top: PADDING_10,
        bottom: PADDING_10
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .hoverEffect(HoverEffect.Highlight)
      .focusable(true)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .stateStyles({
        normal: {
          .backgroundColor(Color.Transparent)
        },
        pressed: {
          .backgroundColor(MULTI_WINDOW_FORCE_SWITCH_PAGE_PRESS_COLOR)
        }
      })
    }
    .padding({
      start: PADDING_4,
      end: PADDING_4,
      top: PADDING_4,
      bottom: PADDING_4
    })
    .margin({ bottom: PADDING_8 })
    .borderRadius(SWITCH_TITLE_RADIUS)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      PageRouter.push(NavEntryKey.MULTI_WINDOW_FORCE_SWITCH_ENTRY);
    })
    .backgroundColor(SWITCH_BACKGROUND_COLOR)
  }

  @Builder
  loadLottie(multiWindowSettingDataStruct: MultiWindowSettingDataStruct, index: number){
    Canvas(multiWindowSettingDataStruct.mainCanvasRenderingContext)
      .height(300)
      .width(300 * this.lottieRatio)
      .onReady(() => {
        LogUtil.info(`${TAG} lottie onReady index: ${index}`);
        lottie.destroy(multiWindowSettingDataStruct.dataPath);
        this.lottieItems[index]?.resize();
        this.lottieItems[index] = lottie.loadAnimation({
          container: multiWindowSettingDataStruct.mainCanvasRenderingContext,
          renderer: 'canvas',
          loop: true,
          autoplay: true,
          packageName:'MultiWindowSettingPage',
          name: multiWindowSettingDataStruct.dataPath,
          frameRate: 40,
          contentMode: 'Contain',
          path: multiWindowSettingDataStruct.dataPath,
        })
      })
  }
  @Builder
  loadContent(index: number) {
    Stack({ alignContent: Alignment.Top }) {
      ForEach(this.sourceDataList, (innerItem: MultiWindowSettingDataStruct, innerIndex: number) => {
        Column() {
          Text($r(innerItem.title))
            .accessibilityLevel((index === innerIndex) ? AccessibilityLevelType.AUTO : AccessibilityLevelType.NO)
            .accessibilityText(index === 0 ?
            ResourceUtil.getStringSync($r('app.string.MultiWindow_change_views_title_read')) : '')
            .fontSize(SWIPER_TITLE_FONTSIZE)
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .textAlign(TextAlign.Center)

          Text($r(innerItem.content))
            .accessibilityLevel((index === innerIndex) ? AccessibilityLevelType.AUTO : AccessibilityLevelType.NO)
            .fontSize(SWIPER_CONTENT_FONTSIZE)
            .fontColor(SWIPER_CONTENT_FONTCOLOR)
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .align(Alignment.Top)
            .textAlign(TextAlign.Center)
            .margin({ top: PADDING_8, bottom: PADDING_40 })
        }
        .visibility((index === innerIndex) ? Visibility.Visible : Visibility.Hidden)
      })
    }
  }

}