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

import { LogUtil, PageLifecycleOwner, PageRoot, SettingsBaseMenu } from '@ohos/settings.common';
import { DialogPage, MenuPageComponent, PhoneBluetoothDialogPageStyle } from '@ohos/settings.uikit';
import { UsbDebugDialogController } from '../controller/UsbDebugDialogController';

const TAG: string = 'UsbDebugDialog';

@Component
@Entry
export struct UsbDebugDialog {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  controller: UsbDebugDialogController = new UsbDebugDialogController(this.pageRoot.menuPage as SettingsBaseMenu,
    this.pageRoot);

  build() {
    Column() {
      MenuPageComponent({ menuPage: this.pageRoot.menuPage })
        .backgroundColor(Color.Transparent)
    }
    .backgroundColor(Color.Transparent)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    let pbapPseMenu = new DialogPage({
      pageUrl: 'pages/developeroptions/DeveloperOptionsSettings/mapAuth',
      title: 'test_UsbDebug_dialog',
      style: new PhoneBluetoothDialogPageStyle(),
    });
    this.pageRoot.aboutToAppear(pbapPseMenu);
    this.controller.registerCommonEvent();

  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.controller.unRegisterCommonEvent();
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();


    this.controller.openMapAuthDialog();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }
}

