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

import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DialToneControler } from './controller/DialToneControler';
import { VibrateWhenRingController } from './controller/VibrateWhenRingController';
import { NotDisturbController } from './controller/NotDisturbController';
import { NotDisturbGroupController } from './controller/NotDisturbGroupController';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ScreenLockToggleController } from './controller/ScreenLockToggleController';
import { TouchFeedBackController } from './controller/TouchFeedBackController';
import { VolumePageController } from './controller/VolumePageController';
import { RingtonesUtils } from './utils/RingtonesUtils';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { RingToneGroupComponent } from './view/RingToneGroupComponent';
import { SoundModeComponent } from './view/SoundModeComponent';
import { VolumeValueComponent } from './view/VolumeValueComponent';
import { IncomingCallUtils } from './utils/IncomingCallUtils';
import {
  COMFORT_ENJOY_MODE_ID,
  NOBLE_ENJOY_MODE_ID,
  QUIET_ENJOY_MODE_ID,
  SoundQualityAndEffectController
} from './controller/SoundQualityAndEffectController';
import { VolumeKeyControlComponent } from './components/VolumeKeyControlComponent';
import { VolumeKeyController } from './controller/VolumeKeyController';
import { RingtoneVibrationAdaptiveController } from './controller/RingtoneVibrationAdaptiveController';
import { VolumeUtils } from './utils/VolumeUtils';
/* instrument ignore file */
const dialToneControler = new DialToneControler();

const DEFAULT_DIAL_TONE_INDEX: number = 1;

@Builder
function ringToneGroupBuilder(item: object) {
  RingToneGroupComponent({ item: item as SettingBaseModel });
}

@Builder
function soundModeBuilder(item: object) {
  SoundModeComponent({ item: item as SettingBaseModel });
}

@Builder
function volumeValueBuilder(item: object) {
  VolumeValueComponent({ item: item as SettingBaseModel });
}

@Builder
function volumeKeyControlBuilder(item: object) {
  VolumeKeyControlComponent();
}

function volumePage(): SettingPageModel {
  return {
    id: 'Volume',
    url: NavEntryKey.VOLUME_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.phone_volume_control_setting_title'),
    compControl: new VolumePageController(),
    hdsNavDestinationUx: false,
    groups: [
      {
        id: 'ringtone_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(ringToneGroupBuilder),
      },
      {
        id: 'sound_mode_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        header: {
          id: 'sound_mode_header',
          content: $r('app.string.volume_mode'),
        },
        builder: wrapBuilder(soundModeBuilder),
      },
      {
        id: 'not_disturb',
        type: GroupType.GROUP_TYPE_STANDARD,
        compControl: new NotDisturbGroupController(),
        items: [
          {
            id: 'not_disturb_mode',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.not_disturb_title') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: '' },
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.NOT_DISTURB_ENTRY,
            },
            needHide: () => {
              return CapabilitySupportUtils.isSupportIntelligentScene();
            },
            compControl: new NotDisturbController(),
          }
        ]
      },
      {
        id: 'volume_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        header: {
          id: 'volume_group_header',
          content: $r('app.string.volume_value'),
        },
        builder: wrapBuilder(volumeValueBuilder),
      },
      {
        id: 'volume_key_control',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'volume_key_control_mode',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.volume_key_control_message') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: '' },
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_DIALOG,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              dialog: {
                title: $r('app.string.volume_key_control_message'),
                contentBuilder: wrapBuilder(volumeKeyControlBuilder),
                style: {
                  padding: {
                    start: PADDING_8,
                    end: PADDING_8,
                  }
                },
                buttons: [
                  {
                    value: $r('app.string.dialog_cancel'),
                    style: { buttonStyle: ButtonStyleMode.TEXTUAL},
                    action: (component: SettingItemModel) => {},
                  }
                ],
              }
            },
            compControl: new VolumeKeyController(),
          }
        ]
      },
      ...getSoundQualityAndEffectGroup(),
      {
        id: 'advanced_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'advanced_group_header',
          content: $r('app.string.advanced_level'),
        },
        items: [
          {
            id: 'dial_tone',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.dial_Tone') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: $r('app.string.no_sound') },
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MENU,
              icon: $r('app.media.ic_storage_spinner'),
              menu: {
                items: [
                  $r('app.string.no_sound'),
                  $r('app.string.default_ringtone'),
                  $r('app.string.music_melodies')
                ],
                defaultFocus: DEFAULT_DIAL_TONE_INDEX,
                selectIcon: $r('app.media.ic_selected'),
                onSelected: (index: number) => {
                  dialToneControler.onHandlerSelected(String(index));
                }
              }
            },
            needHide: () => RingtonesUtils.isVoiceCapabilityDisable(),
            compControl: dialToneControler,
          },
          {
            id: 'screen_lock_tone',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.screen_lock_tone') },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: { state: true },
            },
            compControl: new ScreenLockToggleController(),
          }
        ]
      },
      ...getVibrationsGroup()
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.VOLUME_ENTRY, {
  configGenerator:  volumePage
});

function getSoundQualityAndEffectGroup(): SettingGroupModel[] {
  let isSupportSoundEffect: boolean = CapabilitySupportUtils.isSupportSoundQuality();
  if (!isSupportSoundEffect) {
    return [];
  }
  let soundEffectController: SoundQualityAndEffectController = new SoundQualityAndEffectController();
  return [{
    id: 'sound_effect',
    type: GroupType.GROUP_TYPE_STANDARD,
    header: {
      id: 'sound_effect_header',
      content: $r('app.string.sound_quality_effect'),
      visible: isSupportSoundEffect
    },
    footer: {
      id: 'sound_effect_footer',
      content: $r('app.string.sound_quality_effect_desp'),
      visible: isSupportSoundEffect
    },
    compControl: soundEffectController,
    visible: isSupportSoundEffect,
    items: [
      {
        id: NOBLE_ENJOY_MODE_ID,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.noble_enjoy_mode_title') },
        desc: { content: $r('app.string.noble_enjoy_mode_desp') },
        result: {
          type: ItemResultType.RESULT_TYPE_RADIO,
          result: {
            checked: soundEffectController.isChecked(NOBLE_ENJOY_MODE_ID),
            style: {
              width: 20,
              height: 20
            },
            onCheck: (isCheck: boolean, item: SettingItemModel) => {
              soundEffectController.onCheckFunc(isCheck, NOBLE_ENJOY_MODE_ID);
            }
          },
        }
      },
      {
        id: COMFORT_ENJOY_MODE_ID,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.comfort_enjoy_mode_title') },
        desc: { content: $r('app.string.comfort_enjoy_mode_desp') },
        result: {
          type: ItemResultType.RESULT_TYPE_RADIO,
          result: {
            checked: soundEffectController.isChecked(COMFORT_ENJOY_MODE_ID),
            style: {
              width: 20,
              height: 20
            },
            onCheck: (isCheck: boolean, item: SettingItemModel) => {
              soundEffectController.onCheckFunc(isCheck, COMFORT_ENJOY_MODE_ID);
            }
          },
        }
      },
      {
        id: QUIET_ENJOY_MODE_ID,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.quiet_enjoy_mode_title') },
        desc: { content: $r('app.string.quiet_enjoy_mode_desp') },
        result: {
          type: ItemResultType.RESULT_TYPE_RADIO,
          result: {
            checked: soundEffectController.isChecked(QUIET_ENJOY_MODE_ID),
            style: {
              width: 20,
              height: 20
            },
            onCheck: (isCheck: boolean, item: SettingItemModel) => {
              soundEffectController.onCheckFunc(isCheck, QUIET_ENJOY_MODE_ID);
            }
          },
        }
      }
    ]
  }];
}

function getVibrationsGroup(): SettingGroupModel[] {
  if (VibratorUtil.isSupportRingtoneVibrationAdaptive()) {
    return [
      {
        id: 'vibration_settings',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer:
        {
          id: 'touch_feedback_footer',
          content: VibratorUtil.isSupportVibrate() ? $r('app.string.ringtone_vibration_adaptive_detail') : '',
        },
        items: [
          ...getVibrateWhenRingItem(),
          ...getRingVibrateAdaptiveItem()
        ]
      },
      {
        id: 'touch_settings',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer:
        {
          id: 'touch_feedback_footer',
          content: VibratorUtil.isSupportVibrate() ? $r('app.string.only_operate_event_offer_feedback') : '',
        },
        items: [
          ...getSystemTouchFeedbackItem()
        ]
      }
    ]
  } else {
    return [
      {
        id: 'touch_settings',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: {
          id: 'touch_feedback_footer',
          content: VibratorUtil.isSupportVibrate() ? $r('app.string.only_operate_event_offer_feedback') : ''
        },
        items: [
          ...getVibrateWhenRingItem(),
          ...getSystemTouchFeedbackItem(),
        ]
      }
    ]
  }
}

function getVibrateWhenRingItem():  SettingItemModel[] {
  return [{
    id: 'vibrate_when_ring',
    type: ItemType.ITEM_TYPE_STANDARD,
    title: { content: $r('app.string.vibrate_when_ring') },
    result: {
      type: ItemResultType.RESULT_TYPE_TOGGLE,
      result: {
        state: true,
      }
    },
    compControl: new VibrateWhenRingController(),
    needHide: () => RingtonesUtils.isVoiceCapabilityDisable() || !VibratorUtil.isSupportVibrate()
  }]
}

function getRingVibrateAdaptiveItem(): SettingItemModel[] {
  return [
    {
      id: 'ringtone_vibration_adaptive',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.ringtone_vibration_adaptive') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: true,
        }
      },
      compControl: new RingtoneVibrationAdaptiveController(),
      needHide: () => !VibratorUtil.isSupportRingtoneVibrationAdaptive()
    }
  ]
}

function getSystemTouchFeedbackItem(): SettingItemModel[] {
  return [
    {
      id: 'touch_feedback',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.system_touch_feedback') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: true,
        }
      },
      compControl: new TouchFeedBackController(),
      needHide: () => !VibratorUtil.isSupportVibrate()
    }
  ]
}