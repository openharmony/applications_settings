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
import { DefaultPageConfig } from '@ohos/settings.common/src/main/ets/framework/common/DefaultPageConfig';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PageConfig, ScreenType } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { PageContext, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingSheetPageContext } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { URL_BLUETOOTH_OPP_PAGE } from '../OppBluetoothPage';

const TAG: string = 'BluetoothOppServicePageComponent: ';

@Entry
@Component
export struct BluetoothOppServicePageComponent {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @Builder
  modalBuilder(param: PageParams): void {
    if (param && param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(this.buildPageParam('OpenBluetoothEntry',
        ModalLoader.getPageContext(URL_BLUETOOTH_OPP_PAGE).get()));
    }
  }

  private buildPageParam(pageUrl: string, pageCtx: PageContext, item?: SettingItemModel): PageParams {
    return {
      router: 'bluetooth',
      pageUrl: pageUrl,
      pageCtx: {
        configGenerator: pageCtx.configGenerator,
        pageBuilder: pageCtx.pageBuilder
      },
      param: {
        param: item,
      } as SettingSheetPageContext
    }
  }

  build() {
    Column() {
      this.modalBuilder({
        router: 'bluetooth',
        pageUrl: 'OpenBluetoothEntry',
        pageCtx: ModalLoader.getPageContext(URL_BLUETOOTH_OPP_PAGE).get()
      })
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    PageConfig.getInstance().setPageConfigGlobal({
      defaultPageConfig: DefaultPageConfig.getInstance(),
      defaultPageBuilder: wrapBuilder(settingPageBuilder),
      screenType: ScreenType.SCREEN_TYPE_SMALL,
      navMode: NavigationMode.Auto
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    EventBus.getInstance().emit('pageShow');
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    EventBus.getInstance().emit('pageHide');
  }
}