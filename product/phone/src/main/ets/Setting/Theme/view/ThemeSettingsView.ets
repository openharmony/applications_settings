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
import Common from '@ohos.app.ability.common';
import emitter from '@ohos.events.emitter';
import MediaQuery from '@ohos.mediaquery';
import { LengthMetrics } from '@kit.ArkUI';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { REFRESH_DESKTOP_AND_PERSONAL_PAGE } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { pageNavTitle } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { ThemeEditorMenuView } from './ThemeEditorMenuView';
import { ThemeSettingsController } from '../controller/ThemeSettingsController';

const TAG: string = 'ThemeSettingsView';
const IS_DEVICE_PAD: boolean = DeviceUtil.isDevicePad();

@Component
export struct ThemeSettingsView {
  private controller: ThemeSettingsController = ThemeSettingsController.getInstance();
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('isPortraitOrientation') isPortraitOrientation: boolean = false;
  @StorageLink('settingsThemePage') themeGalleryProxy: UIExtensionProxy | null = null;
  @State params: PushParam | null = null;
  @State isFromSearch: boolean = false;
  @State routerName: string = 'settingsThemePage';
  @StorageProp('navDesDynamicPadding') navDesDynamicPadding: number = AppStorage.get<number>('navDesDynamicPadding') as number;
  private orientationListener: MediaQuery.MediaQueryListener | undefined = undefined;
  private context = getContext(this) as Common.UIAbilityContext;
  pagePaddingStart: LengthMetrics | undefined = LengthMetrics.vp(24);
  title: string =
    DeviceUtil.isSmallFoldProduct() ? ResourceUtil.getStringSync($r('app.string.covertheme_settings_title'))
      : ResourceUtil.getStringSync($r('app.string.theme_settings_title'));
  isFromExternal: boolean = false;

  private updateSearchParams(): void {
    this.updateIsFromSearch();
    this.updateRouterName();
  }

  private updateIsFromSearch(): void {
    this.isFromSearch = this.params?.startReason === PageStartReason.FROM_SEARCH;
    if (this.params && !this.isFromSearch) {
      try {
        let params = this.params as PageParams;
        if (params.param && params.param['startReason']) {
          this.isFromSearch = params.param['startReason'] as string === PageStartReason.FROM_SEARCH;
        }
      } catch (e) {
        LogUtil.showInfo(TAG, `get isFromSearch error ${e?.code}`);
      }
    }
  }

  private updateRouterName(): void {
    if (this.params) {
      let routerName: string = this.params.config as string ?? '';
      if (routerName !== '') {
        this.routerName = routerName.split(',')[0];
        return;
      }
      try {
        let params = this.params as PageParams;
        if (params.param && params.param['config']) {
          routerName = params.param['config'] as string;
          this.routerName = routerName.split(',')[0];
          return;
        }
        if (this.params.subUri) {
          this.routerName = this.params.subUri;
          return;
        }
      } catch (e) {
        LogUtil.showInfo(TAG, `get routerName error ${e?.code}`);
      }
    }
  }

  async addOrientationListener(): Promise<void> {
    this.orientationListener = MediaQuery.matchMediaSync('(orientation: landscape)');
    this.orientationListener.on('change', () => {
      AppStorage.setOrCreate('isPortraitOrientation', DisplayUtils.isScreenPortraitOrientation());
    })
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear, this.params = ${JSON.stringify(this.params)}`)
    this.updateSearchParams();
    this.controller.setWindowStateValue(getContext());
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.THEME_ENTRY);
    // 添加平板页面横竖屏的监听器
    if (IS_DEVICE_PAD) {
      this.isPortraitOrientation = DisplayUtils.isScreenPortraitOrientation();
      this.addOrientationListener();
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.pageRoot.aboutToDisappear();
    this.controller.cancelWindowStateChange(getContext());
    // 销毁平板页面横竖屏监听器
    if (IS_DEVICE_PAD) {
      this.orientationListener?.off('change');
      this.orientationListener = undefined;
    }
  }

  build() {
    NavDestination() {
      ThemeEditorMenuView({ isFromSearch: this.isFromSearch, routerName: this.routerName });
    }
    .hideTitleBar(true)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.showInfo(TAG, 'onBackPressed');
        this.termiteAbility();
        return true;
      }
      return false;
    })
  }

  onPageShow(): void {
    LogUtil.showInfo(TAG, 'onPageShow');
    this.pageRoot.onPageShow();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
    emitter.emit({
      eventId: REFRESH_DESKTOP_AND_PERSONAL_PAGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {});
  }

  onPageHide(): void {
    LogUtil.showInfo(TAG, 'onPageHide');
    this.pageRoot.onPageHide();
    if (this.pathInfos.getParamByName(NavEntryKey.THEME_ENTRY)?.length !== 0) {
      LogUtil.showInfo(TAG, 'just background');
    } else {
      LogUtil.showInfo(TAG, 'need to set status bar');
      this.controller.setWindowSystemBar(getContext());
    }
  }
}

