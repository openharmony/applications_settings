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

import emitter from '@ohos.events.emitter';
import cardEmulation from '@ohos.nfc.cardEmulation';
import bundleManager from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { DefaultPaymentApplicationPage } from './model/DefaultPaymentApplicationPage';

const TAG: string = 'DefaultBrowser : ';

const NFC_LIST_CHANGE: number = 20231220;

@Builder
export function DefaultPaymentApplicationLoader($$: Params): void {
  DefaultPaymentApplication({ params: $$ as Object as PushParam });
}

@Component
export struct DefaultPaymentApplication {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params: PushParam | null = null;
  @State abilityInfos: bundleManager.AbilityInfo | null = null;
  @State nfcList: bundleManager.AbilityInfo[] = [];
  title: string = ResourceUtil.getStringSync($r('app.string.nfc_default_payment_text'));
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    NavDestination() {
      if (this.nfcList.length === 0){
        Column() {
          Image($r('app.media.search_no_result')).width(120).height(120).margin({ bottom: '16vp' })
          Text($r('app.string.no_application'))
            .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
            .fontSize('sys.color.ohos_id_text_size_body1')
        }.offset({ y: '180' })
      } else {
        Column() {
          MenuPageComponent({ menuPage: this.pageRoot.menuPage })
        }
        .size({ width: '100%', height: '100%' })
      }
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .backgroundColor($r('sys.color.ohos_id_color_bottom_tab_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getNfcList();
    this.pageRoot.aboutToAppear(new DefaultPaymentApplicationPage());
  }

  async getNfcList(): Promise<bundleManager.AbilityInfo[]> {
    try {
      this.nfcList = cardEmulation.getPaymentServices();
    } catch (error) {
      LogUtil.error(`${TAG} catch error : ${error?.message}`);
    }
    return this.nfcList;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    emitter.emit({
      eventId: NFC_LIST_CHANGE,
    }, {
      data: {
        DEFAULT_PAY_APP_SELECT: '',
      }
    });
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }
}

