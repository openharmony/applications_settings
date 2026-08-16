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
import { LengthMetrics } from '@kit.ArkUI';
import { Configuration } from '@ohos.app.ability.Configuration';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';

const TAG: string = 'ScreenReaderHelpGroupComponent';

@Component
export struct ScreenReaderHelpGroupComponent {
  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  build() {
    Column() {
      SubHeader({
        secondaryTitle: $r('app.string.screenreader_help'),
        contentMargin: {
          start: LengthMetrics.vp(DeviceUtil.isDevicePad() ? 4 : 0),
          end: LengthMetrics.vp(DeviceUtil.isDevicePad() ? 4 : 0),
        },
      }).accessibilityGroup(true)

      Column() {
        Column() {
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_two'),
            textMargin: { bottom: $r('sys.float.padding_level4') }
          })
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_three'),
            textMargin: { bottom: $r('sys.float.padding_level2') },
          })
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_four'),
            textMargin: { bottom: $r('sys.float.padding_level2') },
            hasOval: true
          })
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_five'),
            textMargin: { bottom: $r('sys.float.padding_level2') },
            hasOval: true
          })
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_six'),
            textMargin: { bottom: $r('sys.float.padding_level4') },
            hasOval: true
          })
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_seven'),
            textMargin: { bottom: $r('sys.float.padding_level2') },
          })
          TextDefault({
            textValue: $r('app.string.screenreader_help_summary_eight'),
            hasOval: true
          })
        }
        .visibility(Visibility.Visible)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({
          top: $r('sys.float.padding_level4'),
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          bottom: $r('sys.float.padding_level4'),
        })
        .accessibilityGroup(true);
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width('100%')
  }
}

@Component
struct TextDefault {
  @State textAlign: TextAlign = TextAlign.JUSTIFY;
  textValue: Resource | string = '';
  textMargin?: Margin = {};
  hasOval?: boolean = false;
  LANGUAGE_ZH: string = 'zh-Han';
  LANGUAGE_MY: string = 'my';
  @StorageProp('envConfig') @Watch('onEnvConfig') envConfig: Configuration | undefined =
    AppStorage.get<Configuration>('envConfig');
  @State currentLanguage: string = LanguageUtils.getLanguage();

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
      if (this.hasOval) {
        Text('•')
          .margin({ top: $r('sys.float.padding_level1'), right: $r('sys.float.padding_level4') })
          .alignSelf(ItemAlign.Start)
          .fontColor($r('sys.color.font_secondary'))
          .font({
            size: $r('sys.float.Body_M'),
            weight: FontWeight.Regular,
          })
          .includeFontPadding(this.currentLanguage === this.LANGUAGE_MY)
      }
      Text(this.textValue)
        .fontColor($r('sys.color.font_secondary'))
        .textOverflow({ overflow: TextOverflow.None })
        .lineHeight($r('app.float.font_19'))
        .font({
          size: $r('sys.float.Body_M'),
          weight: FontWeight.Regular,
        })
        .size({
          width: '100%',
        })
        .textAlign(this.textAlign)
        .margin(this.textMargin)
        .wordBreak(WordBreak.HYPHENATION)
        .fallbackLineSpacing(true)
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.textAlign = this.currentLanguage.startsWith(this.LANGUAGE_ZH) ? TextAlign.JUSTIFY : TextAlign.Start;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private onEnvConfig(): void {
    if (this.envConfig?.language && this.currentLanguage !== this.envConfig?.language) {
      LogUtil.info(`${TAG} system language has changed: ${this.envConfig?.language}`);
      this.currentLanguage = this.envConfig.language;
      this.textAlign = this.envConfig.language.startsWith(this.LANGUAGE_ZH) ? TextAlign.JUSTIFY : TextAlign.Start;
    }
  }
}