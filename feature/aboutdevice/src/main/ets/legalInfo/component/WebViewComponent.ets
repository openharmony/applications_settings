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

import Want from '@ohos.application.Want';
import webView from '@ohos.web.webview';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
/* instrument ignore file */
const TAG: string = 'WebViewComponent : ';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';

/**
 * WebViewComponent显示html文件内容
 */
@Component
export struct WebViewComponent {
  title: string = '';
  @Prop  webUrl: ResourceStr = '';
  pageUrl: string = '';
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  controller: webView.WebviewController = new webView.WebviewController();
  @State mode: WebDarkMode = WebDarkMode.Auto
  @State access: boolean = true


  build() {
    Column() {
      Blank().height($r('app.float.navigation_56'))
      Web({ src: this.webUrl, controller: this.controller })
        .margin({bottom: $r('app.float.navigation_56')})
        .darkMode(this.mode)
        .forceDarkAccess(this.access)
        .size({ width: '100%'})
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        // 2.5.3 【规则】禁止将mixedMode属性配置成All 存在中间人攻击
        .mixedMode(MixedMode.None)
        .textZoomRatio(FontScaleUtils.getCurrentScale(getContext(this)) * 100)
        .fileAccess(true)
        .onControllerAttached(() => {
          try {
            LogUtil.info(TAG+'loadUrl'+this.webUrl)

            this.controller.loadUrl(this.webUrl)
          } catch (error) {
            // TODO: Implement error handling.
            LogUtil.error(TAG+'loadUrl'+JSON.stringify(error))
          }
        })
        .onLoadIntercept((event) => {
          let url: string = event?.data?.getRequestUrl();
          if (event) {
            if (url?.indexOf('https:') >= 0 || url?.indexOf('http:') >= 0) {
              LogUtil.info(`${TAG} start to access external url in Browser`);
              const want: Want = {
                'bundleName': 'com.ohos.browser',
                'abilityName': 'MainAbility',
                'action': 'ohos.want.action.viewData',
                'entities': ['entity.system.browsable'],
                'uri': url,
              }
              AbilityUtils.startAbility(want);
              return true;
            }
          }
          if (url?.indexOf('mailto:') >= 0) {
            AbilityUtils.startAbility({
              bundleName: 'com.ohos.email',
              abilityName: 'EntryAbility',
              action: 'ohos.want.action.sendToData',
              uri: url,
            });
            return true;
          }
          return false;
        })
        // 2.5.5 【规则】用户同意前禁止返回位置信息 无使用场景时 需要显式禁用geolocationAccess
        .geolocationAccess(false)
        .fileAccess(true)
    }
    .size({ width: '100%', height: '100%' })
  }

  aboutToAppear(): void {
    HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, 'pageUrl: ' + this.pageUrl);
    AbilityUtils.timeoutForceGC(1000, 'WebViewComponent->aboutToAppear');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    AbilityUtils.timeoutForceGC(1000, 'WebViewComponent->aboutToDisappear');
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}
