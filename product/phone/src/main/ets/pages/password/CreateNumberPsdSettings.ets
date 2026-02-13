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

import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CreateNumberPsdPage } from './model/CreateNumberPsdPage';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import window from '@ohos.window';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { BottomMenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import { PinAuthUtil } from '@ohos/settings.privacy/src/main/ets/PinAuthUtil';
import PageOperation from '../../Setting/Biometrics/utils/PageOperation';
import { CHANGE_PASSWORD_ENTRY_FLAG } from './controller/PasswordEntryController';
import PageData from '../../Setting/Biometrics/utils/PageData';
/* instrument ignore file */

/**
 * 创建自定义数字锁屏密码
 *
 * @since 2023-01-14
 */
@Builder
export function CreateNumberPsdSettingsLoader($$: Params): void {
  CreateNumberPsdSettings({ params: $$ as Object as PushParam });
}

@Component
export struct CreateNumberPsdSettings {
  private TAG: string = 'CreateNumberPsdSettings : ';
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State pageData: PageData = new PageData(NavigationSystemTransitionType.DEFAULT);
  private isDialogShowInSubWindow: boolean = true;

  build() {
    NavDestination() {
      Column() {
        BottomMenuPageComponent({
          menuPage: this.pageRoot.menuPage,
          isDialogShowInSubWindow: this.isDialogShowInSubWindow,
        });
      }
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .size({ width: '100%', height: '100%' })
    }
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .title(this.pageData.getTitle())
    // .titleBar(this.pageData.getTitleBarData())
    .systemTransition(this.pageData.transitionType)
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      this.pageData.setTransitionType(NavigationSystemTransitionType.TITLE);
      return PageOperation.back(this.params, this.pathInfos);
    })
    // .titleMode(this.pageData.titleMode)
  }

  private getTitle(): Resource {
    let title = $r('app.string.set_lock_screen_pin_title');
    if ((this.params?.config as Record<string, string>)?.source === CHANGE_PASSWORD_ENTRY_FLAG) {
      title = $r('app.string.set_new_lock_screen_password_title');
    }
    return title;
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear`);
    this.pageData.initData(this.params, this.getTitle());
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), true);
    this.pageRoot.aboutToAppear(new CreateNumberPsdPage(this.pathInfos, this.params as PushParam));
    LogUtil.info(`${this.TAG} isDialogShowInSubWindow value is ${this.isDialogShowInSubWindow}`);
    this.isDialogShowInSubWindow = PinAuthUtil.isDialogShowInSubWindow(this.params);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    PasswordUtil.setWindowNonPrivacyModeIfNeed((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), this.pathInfos);
  }

  onPageShow(): void {
    LogUtil.info(`${this.TAG} onPageShow`);
    this.pageRoot.onPageShow();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onPageHide(): void {
    LogUtil.info(`${this.TAG} onPageHide`);
    this.pageRoot.onPageHide();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }
}