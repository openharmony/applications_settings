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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil as LegaInfoResourceUtil } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/util/ResourceUtil';
import { AppLicenseParam } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/model/type';
import { WebViewComponent } from '@ohos/settings.aboutdevice';
import { PageUrl } from '../../../../pages/PageUrl';

const TAG: string = 'AppOpenSourceShowComponent : ';

/**
 * 应用开源声明内容显示
 */
@Component
export struct AppOpenSourceShowComponent {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  title: string = '';
  webUrl: ResourceStr = '';

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom}) {
        WebViewComponent({ title: this.title, webUrl: this.webUrl, pageUrl: PageUrl.OPEN_SOURCE_CODE_LICENSE_URL })
          .margin({
            top: $r('app.float.margin_16'),
            left: $r('app.float.margin_16'),
            right: $r('app.float.margin_16'),
            bottom: $r('app.float.margin_12'),
          })

        Column() {
        }
        .width('100%')
        .linearGradient({
          colors: [[$r('sys.color.ohos_id_color_subtab_bg'), 0.0], [$r('sys.color.ohos_id_color_titlebar_sub_bg'), 1]]
        })
        .margin({ bottom: $r('app.float.margin_12') })
      }
    }
    .hideTitleBar(false)
    .title( this.title )
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (this.params) {
      LogUtil.info(`${TAG} params`);
      this.title = (this.params.config as AppLicenseParam).title;
      let licenseFilePath = (this.params.config as AppLicenseParam).licenseFilePath;
      if (LegaInfoResourceUtil.getResourceLicenseFile().some(item => licenseFilePath.includes(item))) {
        this.webUrl = 'file://' + (this.params.config as AppLicenseParam).licenseFilePath
      } else {
        this.pathInfos?.pop();
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}