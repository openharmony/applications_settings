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

import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AppInfo, AppInfoDataSource, AppOpenSourceStatementController } from '@ohos/settings.aboutdevice';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';

const TAG: string = 'AppOpenSourceStatementComponent : ';

@Component
export struct AppOpenSourceStatementComponent {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State touchItem: AppInfo | undefined = undefined;
  @State isLoading: boolean = true;
  @State isVisible: boolean = false;
  @State appInfoData: AppInfoDataSource = new AppInfoDataSource([]);
  title: string = ResourceUtil.getStringSync($r('app.string.open_source_show_title'));
  strokeWidth: Length = '0.5vp';
  color: ResourceColor = $r('sys.color.ohos_id_color_list_separator');
  startMargin: Length = '12vp';
  endMargin: Length = '12vp';
  touchBackgroundColor: ResourceColor = $r('app.color.color_1A000000_grey');
  listPadding: Padding = {
    top: '0',
    bottom: '0vp',
    left: '24vp',
    right: '24vp',
  };
  loadSize: SizeOptions = {
    width: '72vp',
    height: '72vp',
  };

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) ?
    $r('sys.color.ohos_id_color_click_effect') : null)
  }

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        Stack({ alignContent: Alignment.Center}) {
          Scroll() {
            List() {
              LazyForEach(this.appInfoData, (appInfo: AppInfo, index: number) => {
                ListItem() {
                  Column() {
                    Flex ({
                      direction: FlexDirection.Row,
                      justifyContent: FlexAlign.SpaceBetween,
                      alignItems: ItemAlign.Center
                    }) {
                      Row() {
                        Text(appInfo.label)
                          .fontColor($r('sys.color.ohos_id_color_text_primary'))
                          .fontWeight(FontWeight.Medium)
                      }
                      .alignItems(VerticalAlign.Center)

                      Row() {
                        SymbolGlyph($r('sys.symbol.chevron_right'))
                          .fontSize('24vp')
                          .fontColor([$r('sys.color.icon_fourth')])
                          .draggable(false)
                      }
                      .alignItems(VerticalAlign.Center)
                    }
                    .margin({ left: '8vp', right: '8vp' })
                    .constraintSize({ minHeight: '45vp' })
                  }
                  .margin({ left: $r('app.float.length_4'), right: $r('app.float.length_4') })
                  .borderRadius('16vp')
                  .backgroundColor(appInfo?.pkgName === this.touchItem?.pkgName ? this.touchBackgroundColor :
                    Color.Transparent)
                  .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
                  .stateStyles({
                    normal: this.normalStateIconStyles,
                    pressed: this.pressedStateIconStyles,
                  })
                  .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
                  .onTouch((event: TouchEvent | undefined) => {
                    if (event &&event.type === TouchType.Down) {
                      this.touchItem = appInfo;
                    } else if (event && event.type == TouchType.Up) {
                      this.touchItem = undefined;
                    }
                  })
                  .onHover((isHover: boolean | undefined) => {
                    this.touchItem = isHover ? appInfo : undefined
                  })
                  .onClick(() => {
                    LogUtil.info(`${TAG} start to show content for appLabel ${appInfo.label} ,
                    licenseFilePath: ${appInfo.licenseFilePath}`);
                    DynamicLoader.getInstance().fire(NavEntryKey.APP_OPEN_SOURCE_SHOW).then(() => {
                      const key : string = NavEntryKey.APP_OPEN_SOURCE_SHOW;
                      let obj: Record<string, string> = {
                        'title': appInfo.label,
                        'licenseFilePath': appInfo.licenseFilePath,
                      }
                      const pushParam: PushParam = new PushParam(obj);
                      PageRouter.push(NavEntryKey.APP_OPEN_SOURCE_SHOW, pushParam);
                    });
                  })
               }
              }, (appInfo: AppInfo) => JSON.stringify(appInfo));
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .divider({
              strokeWidth: this.strokeWidth,
              color: this.color,
              startMargin: this.startMargin,
              endMargin: this.endMargin,
            })
            .cachedCount(3)
            .scrollBar(BarState.Auto)
            .align(Alignment.TopStart)
            .edgeEffect(EdgeEffect.Spring)
            .alignSelf(ItemAlign.Start)
            .clip(true)
            .borderRadius('16vp')
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .margin({ top: $r('app.float.margin_16'), left: $r('app.float.margin_16'), right: $r('app.float.margin_16') })
            .padding({ top: $r('app.float.length_4'), bottom: $r('app.float.length_4') })
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .align(Alignment.Top)
          .padding({ bottom: '24vp' })
          .borderRadius('16vp')
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.Spring)
          .visibility(!this.isLoading ? Visibility.Visible : Visibility.None)

          Column() {
            LoadingProgress()
              .size(this.loadSize)
              .layoutWeight(1)
          }
          .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.margin({ bottom: $r('app.float.navigation_56') })
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(false)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`$${TAG} AboutToAppear`);
    let appInfoList = await AppOpenSourceStatementController.getAllAppList();
    this.appInfoData.pushDataList(appInfoList);
    if (this.appInfoData.totalCount() > 0) {
      this.isVisible = true
    }
    this.isLoading = false;
    AbilityUtils.timeoutForceGC(1000, 'AppOpenSourceStatement->AboutToAppear');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    DynamicLoader.getInstance().pageTransitionSuccess(TAG)
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`)
  }
}