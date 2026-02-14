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
import router from '@ohos.router';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageContext, PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import DeviceNameDisable from '@ohos/settings.common/src/main/ets/utils/DeviceNameDisable';
import { AboutDevicePageController } from '../controller/AboutDevicePageController';
import { AboutDevicePageModel } from '../model/AboutDevicePageModel';
import { AboutDevicePageComponent } from './AboutDevicePageComponent';
import { PageUrl } from '../../../../pages/PageUrl';
import { HiSysAboutDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'AboutDeviceSettingsComponent: ';

@Component
export struct AboutDeviceSettingsComponent {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State nevDesArea: Area = { width: 0, height: 0, position: {}, globalPosition: {} };
  @State pageModel?: AboutDevicePageModel = undefined;
  private controller?: AboutDevicePageController = undefined;
  title: string = '';
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    HiSysEventUtil.reportEntryEvent('enter_internal_entry', 'pageUrl: ' + PageUrl.ABOUT_DEVICE_PAGE_URL);
    DeviceNameDisable.getInstance().disableItems();
    let pageContext: PageContext = PageLoader.getPageContext(NavEntryKey.ABOUT_DEVICE_ENTRY).get();
    let settingPageModel: SettingPageModel = pageContext?.configGenerator?.();
    this.controller = settingPageModel.compControl as AboutDevicePageController;
    settingPageModel.tabIndex = 100;
    this.tempTabIndex = settingPageModel.tabIndex + 1;
    this.pageModel = new AboutDevicePageModel(settingPageModel);
    this.controller.setPageModel(this.pageModel);
    this.preprocess(this.pageModel.aboutDevicePage);
    this.pageModel.isAboutDeviceTitleShow = true;
    this.pageModel.aboutDeviceTitleBackgroundColor = Color.Transparent;
    this.pageModel.onBackPressed = () => {
      this.processBackPress();
    };
    this.title = this.pageModel?.getTitle();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    if (DeviceNameDisable.getInstance().disableItems()) {
      DeviceNameDisable.getInstance().notifyMenuDisable();
    }
    LogUtil.info(`${TAG} onPageShow`);
    if (this.pageModel) {
      this.controller?.onPageShow(this.pageModel.aboutDevicePage);
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutDeviceEventGroup.ENTER_ABOUT_MOBILE_ENTRY);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    if (this.pageModel) {
      this.controller?.onPageHide(this.pageModel.aboutDevicePage);
    }
  }

  build() {
    NavDestination() {
      Column() {
        AboutDevicePageComponent({
          pageModel: this.pageModel,
          controller: this.controller,
          pushParams: this.params,
        })
      }
      .size({ width: '100%', height: '100%' })
      .onSizeChange((oldVal, newVal) => {
        this.nevDesArea.width = newVal.width as Length;
        this.nevDesArea.height = newVal.height as Length;
        LogUtil.info(`${TAG} width is ${this.nevDesArea.width}, height is ${this.nevDesArea.height}`);
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(!this.pageModel?.isAboutDeviceTitleShow)
    .hideBackButton(this.navigationMode === NavigationMode.Split)
    .title(this.title)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => this.processBackPress())
  }

  private processBackPress() {
    if (this.pathInfos.size() === 1 && (this.navigationMode === NavigationMode.Split)) {
      router.back();
    } else {
      this.pathInfos.pop();
    }
    return true;
  }

  private tempTabIndex: number = -1;

  private preprocessGroups(groups: SettingGroupModel[]): void {
    for (let groupIndex = 0; groupIndex < groups.length; ) {
      let group = groups[groupIndex];
      if (!group.items || group.items.length === 0) {
        groupIndex++;
        continue;
      }
      group.tabIndex = this.tempTabIndex;
      for (let itemIndex = 0; itemIndex < group.items.length; ) {
        let item = group.items[itemIndex];
        if (item.needHide?.()) {
          group.items.splice(itemIndex, 1);
          continue;
        }
        if (!itemIndex) {
          item.tabIndex = group.tabIndex
        }
        itemIndex++;
      }
      this.tempTabIndex += 1;
      if (group.items.length == 0) {
        groups.splice(groupIndex, 1);
        continue;
      }

      groupIndex++;
    }
  }

  private preprocess(page: SettingPageModel): void {
    if (page.fixedGroups && page.fixedGroups.length > 0) {
      this.preprocessGroups(page.fixedGroups);
      if (page.fixedGroups.length === 0) {
        page.fixedGroups = undefined;
      }
    }
    if (page.groups && page.groups.length > 0) {
      this.preprocessGroups(page.groups);
      if (page.groups.length === 0) {
        page.groups = undefined;
      }
    }
  }
}