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
import displaySync from '@ohos.graphics.displaySync';
import { window } from '@kit.ArkUI';
import { SettingGroup } from '@ohos/settings.common/src/main/ets/framework/view/SettingGroup';
import { SettingGroupFooter } from '@ohos/settings.common/src/main/ets/framework/view/SettingGroupFooter';
import { PageConfig } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { AvoidAreaParams, WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { AboutDevicePageModel } from '../model/AboutDevicePageModel';
import { AboutDevicePageController } from '../controller/AboutDevicePageController';

const TAG: string = 'AboutDevicePageComponent : ';
const OUC_CARD_ENABLE_OFFSET = 1;
const DELAY_FRAME: number = 1;
const DELAY_SHOW_GROUP_INDEX: number = 2;

@Component
export struct AboutDevicePageComponent {
  @State pageModel?: AboutDevicePageModel = undefined;
  private compId: string = '';
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  @State displaySyncCount: number = 0;
  private scroller: Scroller = new Scroller();
  private controller?: AboutDevicePageController;
  private avoidAreaChangeCallBack: (data: AvoidAreaParams) => void = (data: AvoidAreaParams) => {
  };
  private pushParams: PushParam | null = null;
  private isPhone: boolean = DeviceUtil.isDevicePhone();
  private displaySync: displaySync.DisplaySync = displaySync.create();
  private addFrameCallback = (intervalInfo: displaySync.IntervalInfo) => {
    LogUtil.info(`${TAG} displaySyncCount addFrameCallback`);
    this.displaySyncCount++;
    if (this.displaySyncCount >= DELAY_FRAME) {
      LogUtil.info(`${TAG} second frame to show displayGroups.`);
      this.displaySync.stop();
    }
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.compId = this.pageModel?.settingModel.id as string;
    this.controller?.init({
      compId: this.pageModel?.settingModel.id as string,
      component: this.pageModel?.settingModel as SettingBaseModel,
      param: this.pushParams as object,
    });
    this.onAvoidAreaChange();
    if (this.isPhone) {
      this.setDisplaySync();
    }
  }

  aboutToDisappear(): void {
    this.offAvoidAreaChange();
    if (this.isPhone) {
      this.disableDisplaySync();
    }
  }

  private getPreviousGroup(index: number, groups?: SettingGroupModel[]): SettingGroupModel | undefined {
    if (index > 0) {
      return groups?.[index - 1];
    }
    return undefined;
  }

  private setDisplaySync() {
    LogUtil.info(`${TAG} setDisplaySync`);
    this.displaySync.on('frame', this.addFrameCallback);
    this.displaySync.start();
  }

  private disableDisplaySync() {
    LogUtil.info(`${TAG} disableDisplaySync`);
    this.displaySync.off('frame', this.addFrameCallback);
  }

  @Builder groupFooterBuilder(group: SettingGroupModel, fixed?: boolean): void {
    if (group.footer) {
      if (fixed) {
        SettingGroupFooter({ group: group, compId: `${this.compId}.${group.id}.footer` })
      } else {
        ListItem() {
          SettingGroupFooter({ group: group, compId: `${this.compId}.${group.id}.footer` })
        }
      }
    }
  }

  @Builder
  private settingGroups(): void {
    Column() {
      List({ scroller: this.scroller }) {
        ForEach(this.pageModel?.aboutDevicePage.groups, (group: SettingGroupModel, index: number) => {
          if (index < DELAY_SHOW_GROUP_INDEX) {
            SettingGroup({
              groupInfo: group,
              compId: `${this.pageModel?.aboutDevicePage.id}.${group.id}`,
              pageCached: false,
              layout: PageConfig.getInstance()
                .getGroupLayout(group, this.getPreviousGroup(index, this.pageModel?.aboutDevicePage.groups)),
            })
            this.groupFooterBuilder(group)
          }
          if ((!this.isPhone || this.displaySyncCount >= DELAY_FRAME) && index >= DELAY_SHOW_GROUP_INDEX) {
            //api版本走的这里
            SettingGroup({
              groupInfo: group,
              compId: `${this.pageModel?.aboutDevicePage.id}.${group.id}`,
              pageCached: false,
              layout: PageConfig.getInstance()
                .getGroupLayout(group, this.getPreviousGroup(index, this.pageModel?.aboutDevicePage.groups)),
            })
            this.groupFooterBuilder(group)
          }
        }, (item: SettingGroupModel) => item.id)
      }
      .padding({
        start: this.pageModel?.paddingValue,
        end: this.pageModel?.paddingValue,
      })
      .borderRadius({
        topLeft: $r('sys.float.corner_radius_level10'),
        topRight: $r('sys.float.corner_radius_level10'),
        bottomLeft: $r('sys.float.corner_radius_level10'),
        bottomRight: $r('sys.float.corner_radius_level10'),
      })
      .contentStartOffset(12)
      .contentEndOffset(20)
      .width('100%')
    }
    .expandSafeArea(this.pageModel?.safeAreaParam.types, this.pageModel?.safeAreaParam.edges)
  }

  @Builder
  private aboutDeviceContent(): void {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Column()
            .width('100%')
            .height(this.pageModel?.listColumnMarginTop)
            .hitTestBehavior(HitTestMode.None)
            .accessibilityLevel(AccessibilityLevelType.NO)

          this.settingGroups();
        }
        .accessibilityLevel(AccessibilityLevelType.NO)
      }
      .hitTestBehavior(HitTestMode.Transparent)
      .accessibilityLevel(AccessibilityLevelType.NO)
      .scrollable(this.pageModel?.isScrollEnable ? ScrollDirection.Vertical : ScrollDirection.None)
      .expandSafeArea(this.pageModel?.safeAreaParam.types, this.pageModel?.safeAreaParam.edges)
      .align(Alignment.TopStart)
      .height('100%')
      .edgeEffect(this.pageModel?.scrollEdgeEffect ?? EdgeEffect.Spring)
      .scrollBar(this.pageModel?.isAboutDeviceBarStateOff ? BarState.Off : BarState.Auto)
      .onScrollStart(() => {
        LogUtil.info(`${TAG} onScrollStart`);
        AppStorage.setOrCreate('ListScrollOn', true);
      })
      .onScrollStop(() => {
        LogUtil.info(`${TAG} onScrollStop`);
        AppStorage.setOrCreate('ListScrollOn', false);
      })
      .onDidScroll((xOffset: number, yOffset: number) => {
        if (this.pageModel !== undefined) {
          this.pageModel.aboutDeviceTitleBackgroundColor = Color.Transparent;
        }
      })
    }
    .transition(this.pageModel?.menuListTransitionEffect ?
      this.pageModel?.menuListTransitionEffect : TransitionEffect.IDENTITY)
    .layoutWeight(1)
    .expandSafeArea(this.pageModel?.safeAreaParam.types, this.pageModel?.safeAreaParam.edges)
    .accessibilityLevel(AccessibilityLevelType.NO)
  }


  @Builder
  aboutDevice() {
    Column() {
      if (this.pageModel?.menuListShow) {
        this.aboutDeviceContent();
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea(this.pageModel?.safeAreaParam.types, this.pageModel?.safeAreaParam.edges)
    .zIndex(1)
    .hitTestBehavior(HitTestMode.Transparent)
    .accessibilityLevel(AccessibilityLevelType.NO)
  }

  build() {
    Stack() {
      this.aboutDevice();
    }
    .align(Alignment.TopStart)
    .expandSafeArea(this.pageModel?.safeAreaParam.types, this.pageModel?.safeAreaParam.edges)
    .height('100%')
  }


  private onAvoidAreaChange(): void {
    WindowManager.onAvoidAreaChange(AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage,
      this.avoidAreaChangeCallBack);
  }

  private offAvoidAreaChange(): void {
    WindowManager.offAvoidAreaChange(AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage,
      this.avoidAreaChangeCallBack);
  }
}