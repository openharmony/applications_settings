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
import { bundleManager } from '@kit.AbilityKit';
import { ComponentContent } from '@ohos.arkui.node';
import { BusinessError } from '@ohos.base';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { enterNoNavigationPage } from '@ohos/settings.common/src/main/ets/other/SettingsNoNavigationPage';
import { PageType } from '../model/RingtoneParam';
import { VolumeDataType } from '../model/VolumeType';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { RINGTONE_TYPE_CUSTOM } from '../constant/VolumeConstant';

const TAG: string = 'MusicServiceComponent';
const MUSIC_SERVICE_BUNDLE_NAME: string = 'com.ohos.musicservice';
const APP_MUSIC_BUNDLE_NAME: string = 'com.ohos.music';
const FEATURE_LOCAL_MUSIC: string = 'feature-ringtonesetting.localmusic';
const FEATURE_ONLINE_RINGTONE: string = 'feature-ringtonesetting.onlineringtone';
const MUSIC_RINGTONE_ABILITY_NAME: string = 'ringtoneSettingUIExtensionAbility';
const CALL_SETTING_BUNDLE_NAME: string = 'com.ohos.callsetting';
const VIDEO_RINGTONE_ABILITY_NAME: string = 'VideoRingtoneSettingsAbility';

@Builder
export function MusicServiceLoader($$: Params): void {
  MusicServiceComponent({ params: $$ as Object as PushParam });
}

class LoadingParams {
}

@Builder
function loadingProgressBuilder(params: LoadingParams) {
  Column() {
    LoadingProgress()
      .width($r('app.float.wh_value_72'))
      .height($r('app.float.wh_value_72'))
  }
  .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  .alignItems(HorizontalAlign.Center)
}

@Component
export struct MusicServiceComponent {
  @State myProxy: UIExtensionProxy | null = null;
  @State params: PushParam | null = null;
  @Consume('pathInfos') pathInfos: NavPathStack;
  private contentNodeLoadingProgress = new ComponentContent(this.getUIContext(), wrapBuilder(loadingProgressBuilder),
    new LoadingParams);

  build() {
    NavDestination() {
      if (((this.params?.config as Record<string, Object>)?.pageType as string) === PageType.VIDEO_PAGE_TYPE) {
        this.loadMusicComponent(CALL_SETTING_BUNDLE_NAME, VIDEO_RINGTONE_ABILITY_NAME);
      } else {
        this.loadMusicComponent(MUSIC_SERVICE_BUNDLE_NAME, MUSIC_RINGTONE_ABILITY_NAME);
      }
    }
    .hideTitleBar(true)
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear, param.config: ${(this.params?.config as Record<string, Object>)?.pageType}`);
  }


  @Builder
  loadMusicComponent(bundleName: string, abilityName: string) {
    UIExtensionComponent({
      bundleName: bundleName,
      abilityName: abilityName, // RingtoneSettingExtAbility
      parameters: {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'ringtoneParam': this.params?.config,
      }},
      {
        placeholder: bundleName === APP_MUSIC_BUNDLE_NAME ? this.contentNodeLoadingProgress : null,
      })
      .defaultFocus(true)
      .onReceive((data: Record<string, Object>) => {
        // 区分卡1 和 卡2
        let isCardOne: boolean = (this.params?.config as Record<string, Object>)?.card === '0';
        // 区分来电、信息、通知
        let toneType: string = (this.params?.config as Record<string, Object>)?.toneType as string;

        // 完整铃声信息key
        let key: string = RingtonesUtils.getRingtoneKey(isCardOne, toneType);
        let datakey: string = key + '_music';
        if (data.isShowUIExtension) {
          LogUtil.showInfo(TAG, `set key: ${key}, toneType: ${toneType} ring is: ${data?.ringtoneName}`);
          PreferencesUtil.putSync(datakey, data);
          PreferencesUtil.putSync(key + '_type', RINGTONE_TYPE_CUSTOM);
          EventBus.getInstance().emit(RingtonesUtils.getEmitId(toneType),
            {
              currentIndex: isCardOne ? 0 : 1,
              value: data?.ringtoneName,
            } as VolumeDataType
          );
        } else {
          LogUtil.showInfo(TAG, `isShowUIExtension: ${data.isShowUIExtension}, exit music service page.`);
          if (data?.videoRingtoneFullScreen) {
            LogUtil.showInfo(TAG, `go to full screen page`);
            let want: Want = {
              bundleName: CALL_SETTING_BUNDLE_NAME,
              abilityName: 'VideoRingtoneViewAbility',
              parameters: {
                'ability.want.params.uiExtensionType': 'sys/commonUI',
                'wantParameters': data?.parameters ?? ''
              }
            };
            enterNoNavigationPage(want, true);
            return;
          }
          this.pathInfos.pop();
        }
      })
      .onError((error: BusinessError) => {
        LogUtil.showError(TAG, `onError exception,errorCode:${error.code},errorMessage:${error.message}`);
        this.pathInfos.pop();
      })
      .onTerminated((info: TerminationInfo) => {
        LogUtil.showInfo(TAG, `onTerminated, code: ${info?.code}, abilityName: ${info?.want?.abilityName}.`);
      })
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .expandSafeArea([SafeAreaType.SYSTEM], bundleName === MUSIC_SERVICE_BUNDLE_NAME ? [SafeAreaEdge.BOTTOM] : null)
      .height('100%')
      .width('100%')
      .id('ringtoneExtension')
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }
}