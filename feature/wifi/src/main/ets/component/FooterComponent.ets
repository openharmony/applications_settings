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
import inputMethod from '@ohos.inputMethod';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'FooterComponent: ';

const UX_DESIGN_MARGIN: number = 54;

const UX_DESIGN_DEFAULT_MARGIN: number = 60;

// 用于wlan密码输入半模态场景，拉起键盘后，底部布局被遮挡的问题
@Component
export struct FooterComponent {
  private inputMethodSetting = inputMethod.getSetting();
  @State marginBottom: number = UX_DESIGN_MARGIN;
  private imeShowCallBack: (info: Array<inputMethod.InputWindowInfo>) => void =
    (info: Array<inputMethod.InputWindowInfo>) => {
      LogUtil.info(`${TAG} imeShow.`);
      if (info.length <= 0) {
        LogUtil.error(`${TAG} imeShowCallBack occurs error.`);
        return;
      }
      this.marginBottom = px2vp(info[0].height) + UX_DESIGN_MARGIN;
    }
  private imeHideCallBack: (info: Array<inputMethod.InputWindowInfo>) => void =
    (info: Array<inputMethod.InputWindowInfo>) => {
      LogUtil.info(`${TAG} imeHide.`);
      this.marginBottom = UX_DESIGN_DEFAULT_MARGIN;
    }

  build() {
    Column() {}
    .padding({
       bottom: $r('sys.float.padding_level12'),
       top: $r('sys.float.padding_level8'),
    })
    .height(10)
    .width('100%')
    .margin({
      bottom: this.marginBottom,
    })
  }

  aboutToAppear(): void {
    try {
      this.inputMethodSetting.on('imeShow', this.imeShowCallBack);
      this.inputMethodSetting.on('imeHide', this.imeHideCallBack);
    } catch (err) {
      LogUtil.error(`${TAG} Failed to subscribing imeShow. err: ${err?.message}`);
    }
  }

  aboutToDisappear(): void {
    try {
      this.inputMethodSetting.off('imeShow', this.imeShowCallBack);
      this.inputMethodSetting.off('imeHide', this.imeHideCallBack);
    } catch (err) {
      LogUtil.error(`${TAG} Failed to unsubscribing imeShow. err: ${err?.message}`);
    }
  }
}