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

import { Configuration } from '@ohos.app.ability.Configuration';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';

/* instrument ignore file */
const TAG: string = 'HarassmentBlockingPromptComponent : ';
const LANGUAGE_ZH: string = 'zh-Han';

@Component
export struct HarassmentBlockingPromptComponent {
  @State elderCareSummary: string | Resource = '';
  @State isShowBlockRules: boolean = true;
  @State textAlign: TextAlign = TextAlign.JUSTIFY;
  @StorageProp('envConfig') @Watch('onEnvConfig') envConfig: Configuration | undefined =
    AppStorage.get<Configuration>('envConfig');
  private currentLanguage: string = LanguageUtils.getLanguage();

  build() {
    Column() {
      Row() {
        Text(this.elderCareSummary)
          .fontSize($r('sys.float.ohos_id_text_size_body3'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .textAlign(this.textAlign)
          .size({ width: '100%' })
      }
      .margin({ bottom: 0 })
      .width('100%')
    }
    .width('100%')
    .align(Alignment.TopStart)
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.textAlign = this.currentLanguage.startsWith(LANGUAGE_ZH) ? TextAlign.JUSTIFY : TextAlign.Start;
    this.elderCareSummary = $r('app.string.elder_care_switch_summary_no_sim');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private onEnvConfig(): void {
    if (this.envConfig?.language && this.currentLanguage !== this.envConfig?.language) {
      LogUtil.info(`${TAG} system language has changed: ${this.envConfig?.language}`);
      this.textAlign = this.envConfig.language.startsWith(LANGUAGE_ZH) ? TextAlign.JUSTIFY : TextAlign.Start;
    }
  }
}