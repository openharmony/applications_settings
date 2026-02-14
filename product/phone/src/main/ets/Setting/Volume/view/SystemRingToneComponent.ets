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
import { BusinessError } from '@ohos.base';
import audio from '@ohos.multimedia.audio';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import fs from '@ohos.file.fs';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import {
  PADDING_0,
  PADDING_16,
  PADDING_12,
  PADDING_24,
  PADDING_4,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { RadioMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { CardRadioMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { RadioName } from '../constant/VibrateConstant';
import {
  DEFAULT_NO_RINGTONE_URI,
  DEFAULT_NO_RING_URI,
  RINGTONE_TYPE_CUSTOM,
  RINGTONE_TYPE_SYSTEM
} from '../constant/VolumeConstant';
import { VolumeAdapter } from '../controller/VolumeAdapter';
import { ItemGroupPostion, PageType, RingtoneParam, ToneType } from '../model/RingtoneParam';
import { MyToneHapticsSettings, VibrateParam } from '../model/VibrateParam';
import { ToneAttrs, VolumeDataType } from '../model/VolumeType';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { VibrateUtil } from '../utils/VibrateUtil';
import { common } from '@kit.AbilityKit';
import picker from '@ohos.file.picker';

let audioManager = audio.getAudioManager();
// 创建音频会话管理器
let audioSessionManager: audio.AudioSessionManager = audioManager.getSessionManager();
// 设置音频并发模式
let strategy: audio.AudioSessionStrategy = {
  concurrencyMode: audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT
};
// 查询音频会话是否已激活。
let isActivated = audioSessionManager.isAudioSessionActivated();

/**
 * 系统铃声页面
 */
@Component
export struct SystemRingTonePage {
  tag: string = 'SystemRingTonePage : ';
  noRingtone: string = ResourceUtil.getStringSync($r('app.string.no_ringtone'));
  style?: CardRadioMenuStyle;
  selectedRingtoneData: Record<string, Object> = {};
  currentIndex: number | null = null;
  navKey: string = '';
  radius: number = vp2px(20);
  ringToneDefaultValue: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_default'));
  private pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
  private localeChangeForRingtone: string = 'localeChangeForRingtone';
  private localeChangeForMessageTone: string = 'localeChangeForMessageTone';
  private localeChangeForNotificationTone: string = 'localeChangeForNotificationTone';
  private isFirstPageShow: boolean = true;
  @Prop @Watch('ringListChange') ringList: Array<ToneAttrs>;
  @State ringtoneList: SystemRingtoneSource = new SystemRingtoneSource([]);
  private vibrateParamTemp: VibrateParam = new VibrateParam();
  //选择的振动类型名
  @State checkedVibrateTypeName: string = '';
  @State isShowCurrentRingtone: boolean = false;
  @State selectedRingtone: string = '';
  @State controller?: RadioMenuController = undefined;
  @State isSelected: boolean = false;
  @State isSelectedIndex: number = -1;
  @State ringtonePlay: systemSoundManager.RingtonePlayer | undefined = undefined;
  @State systemMessageTonePlay: systemSoundManager.SystemTonePlayer | undefined = undefined;
  @State systemNotificationTonePlay: systemSoundManager.SystemTonePlayer | undefined = undefined;
  @State findName: string | null = null;
  @State streamId: number | null = null;
  @State systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined = undefined;
  @State cardWidth: number = 0;
  @State cardHeight: number = 0;
  @State hoverItem: string = '';
  @State isHover: boolean = false;
  @State currentURI:string=''
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private pageShowChange: (isVolumeRingTonePageShow: boolean) => void = (isVolumeRingTonePageShow: boolean) => {
    LogUtil.showInfo(this.tag, `pageShowChange: ${isVolumeRingTonePageShow}, isFirstPageShow: ${this.isFirstPageShow}`);
    if (!isVolumeRingTonePageShow) {
      this.isFirstPageShow = false;
      this.stopSystemTonePlayer();
    } else {
      this.updateRingtoneData();
      this.updateVibrateData();
      if (this.isFirstPageShow) {
        this.isFirstPageShow = false;
      } else {
        this.createSystemTonePlayer();
      }
    }
  }

  private updateRingtoneData() {
    let isCardOne: boolean = this.currentIndex !== 1;
    let toneType: ToneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
    let key: string = RingtonesUtils.getRingtoneKey(isCardOne, toneType);

    this.selectedRingtoneData = PreferencesUtil.getSync(key + '_music', []) as Record<string, Object>;
    if (PreferencesUtil.hasSync(key + '_music')) {
      this.selectedRingtone = this.selectedRingtoneData?.ringtoneName as string;
    } else {
      this.selectedRingtone = PreferencesUtil.getSync(key, '') as string;
    }
    let selectedRingtone: string = this.selectedRingtone;
    if (CheckEmptyUtils.isEmpty(selectedRingtone)) {
      this.refreshTone(toneType, key, isCardOne);
    }
    RingtonesUtils.formatNoRingtone(selectedRingtone, VibrateUtil.getToneHapticsType(toneType, this.currentIndex),
      toneType);
    LogUtil.showInfo(this.tag, ` this.selectedRingtone: ${selectedRingtone}`);
    this.findName = RingtonesUtils.formatDefaultTone(isCardOne, toneType, selectedRingtone);
    this.isShowCurrentRingtone = this.needShowCurrentRingtone(key + '_type');
    LogUtil.showInfo(this.tag, `key: ${key}, this.findName: ${this.findName} selectedRingtone: ${selectedRingtone},isShowCurrentRingtone: ${this.isShowCurrentRingtone}`);
  }

  private refreshTone(toneType: ToneType, key: string, isCardOne: boolean) {
    switch (toneType) {
      case ToneType.RINGTONE:
        this.refreshRingtone(key, isCardOne, toneType);
        break;
      case ToneType.MESSAGE_TONE:
        this.refreshMessageTone(key, isCardOne, toneType);
        break;
      case ToneType.NOTIFICATION_TONE:
        this.refreshNotificationTone(key, isCardOne, toneType);
        break;
      default:
        break;
    }
  }

  private refreshRingtone(key: string, isCardOne: boolean, toneType: ToneType): void {
    let context: Context = getContext(this);
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager =
      systemSoundManager.getSystemSoundManager();
    Promise.all([
      systemSoundManagerInstance.getRingtoneAttrList(context, systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0)
    ]).then(async (res) => {
      let ringtoneList: systemSoundManager.ToneAttrsArray = res[0];
      await RingtonesUtils.getCurrentTone(ringtoneList, systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0,
        ToneType.RINGTONE, 0);
      await RingtonesUtils.getCurrentTone(ringtoneList, systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1,
        ToneType.RINGTONE, 1);
      this.selectedRingtone = PreferencesUtil.getSync(key, '') as string;
      this.findName = RingtonesUtils.formatDefaultTone(isCardOne, toneType, this.selectedRingtone);
      this.isShowCurrentRingtone = this.needShowCurrentRingtone(key + '_type');
      LogUtil.showInfo(this.tag, `refreshRingtone key: ${key}, this.findName: ${this.findName} selectedRingtone： ${this.selectedRingtone}, ,isShowCurrentRingtone: ${this.isShowCurrentRingtone}`);
    }).catch((error: Error) => {
      LogUtil.error(`${this.tag} get Promise.all failed, error reason: ${error}`);
    });
  }

  private refreshMessageTone(key: string, isCardOne: boolean, toneType: ToneType): void {
    let context: Context = getContext(this);
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager =
      systemSoundManager.getSystemSoundManager();
    Promise.all([
      systemSoundManagerInstance.getSystemToneAttrList(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0)
    ]).then(async (res) => {
      let systemToneList = res[0];
      RingtonesUtils.getCurrentTone(systemToneList,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0, ToneType.MESSAGE_TONE, 0);
      await RingtonesUtils.getCurrentTone(systemToneList,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1, ToneType.MESSAGE_TONE, 1);
      this.selectedRingtone = PreferencesUtil.getSync(key, '') as string;
      this.findName = RingtonesUtils.formatDefaultTone(isCardOne, toneType, this.selectedRingtone);
      this.isShowCurrentRingtone = this.needShowCurrentRingtone(key + '_type');
      LogUtil.showInfo(this.tag, `refreshMessageTone key: ${key}, this.findName: ${this.findName} selectedRingtone： ${this.selectedRingtone}, ,isShowCurrentRingtone: ${this.isShowCurrentRingtone}`);
    }).catch((error: Error) => {
      LogUtil.error(`${this.tag} get Promise.all failed, error reason: ${error?.message}`);
    });
  }

  private refreshNotificationTone(key: string, isCardOne: boolean, toneType: ToneType): void {
    let context: Context = getContext(this);
    let systemSoundManagerInstance: systemSoundManager.SystemSoundManager =
      systemSoundManager.getSystemSoundManager();
    Promise.all([
      systemSoundManagerInstance.getSystemToneAttrList(context,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION)
    ]).then(async (res) => {
      let systemToneList1 = res[0];
      await RingtonesUtils.getCurrentTone(systemToneList1,
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION, ToneType.NOTIFICATION_TONE, 0);
      this.selectedRingtone = PreferencesUtil.getSync(key, '') as string;
      this.findName = RingtonesUtils.formatDefaultTone(isCardOne, toneType, this.selectedRingtone);
      this.isShowCurrentRingtone = this.needShowCurrentRingtone(key + '_type');
      LogUtil.showInfo(this.tag, `refreshNotificationTone key: ${key}, this.findName: ${this.findName} selectedRingtone： ${this.selectedRingtone}, ,isShowCurrentRingtone: ${this.isShowCurrentRingtone}`);
    }).catch((error: Error) => {
      LogUtil.error(`${this.tag} get Promise.all failed, error reason: ${error}`);
    });
  }

  private async initVibrateData(context: Context, audioRingMode: number, vibrateParamTemp: VibrateParam
    , vibrateParamKey: string): Promise<VibrateParam> {
    let toneType: ToneType = vibrateParamTemp.toneType;
    let toneHapticsType: systemSoundManager.ToneHapticsType = vibrateParamTemp.toneHapticsType;
    let isSystemRingTone: boolean = vibrateParamTemp.isSystemRingTone;
    let defaultVibrateParam: VibrateParam = this.vibrateParamTemp;
    if (!PreferencesUtil.hasSync(vibrateParamKey)) {
      LogUtil.showInfo(this.tag, `updateVibrateData, initVibrateData, has no vibrateParamKey: ${vibrateParamKey}`);
      defaultVibrateParam = await this.getDefaultVibrateParam(context, toneType, audioRingMode, toneHapticsType
        , isSystemRingTone);
      PreferencesUtil.putSync(vibrateParamKey + '.version', 2);
      PreferencesUtil.putSync(vibrateParamKey, defaultVibrateParam);
      LogUtil.showInfo(this.tag, `updateVibrateData, initVibrateData, getDefaultVibrateParam, success`);
      return defaultVibrateParam;
    } else {
      let vibrateParam: VibrateParam = VibrateUtil.getVibrateParamInMemory(vibrateParamKey, vibrateParamTemp);
      LogUtil.showInfo(this.tag, `updateVibrateData, initVibrateData, getSync, success`);
      return vibrateParam;
    }
  }

  private async updateVibrateData(): Promise<void> {
    let context: Context = getContext(this);
    let toneType: ToneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
    let audioRingMode: number = VolumeAdapter.getInstance().getRingerMode();
    let toneHapticsType: systemSoundManager.ToneHapticsType = VibrateUtil.getToneHapticsType(toneType
      , this.currentIndex);
    let isSystemRingTone: boolean = VibrateUtil.isSystemRingTone(toneHapticsType);
    LogUtil.showInfo(this.tag, `updateVibrateData, toneType : ${toneType}, audioRingMode: ${audioRingMode}, toneHapticsType: ${toneHapticsType}, selectedRingtone: ${this.selectedRingtone}, isSystemRingTone: ${isSystemRingTone}`);
    this.vibrateParamTemp.toneType = toneType;
    this.vibrateParamTemp.toneHapticsType = toneHapticsType;
    this.vibrateParamTemp.isSystemRingTone = isSystemRingTone;
    let vibrateParamKey: string = VibrateUtil.getVibrateParamKey(toneType, toneHapticsType, audioRingMode);
    let vibrateParam: VibrateParam = await this.initVibrateData(context, audioRingMode, this.vibrateParamTemp
      , vibrateParamKey);
    let isValidity: boolean = VibrateUtil.validityCheck(vibrateParam);
    if (!isValidity) {
      LogUtil.showWarn(this.tag, `updateVibrateData, validityCheck, isValidity: ${isValidity}, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType}
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}`);
      vibrateParam = await this.getDefaultVibrateParam(context, toneType, audioRingMode, toneHapticsType
        , isSystemRingTone);
    } else {
      LogUtil.showInfo(this.tag, `updateVibrateData, validityCheck, isValidity: ${isValidity}`);
    }

    LogUtil.showInfo(this.tag, `updateVibrateData, before update, vibrateParamKey: ${vibrateParamKey}, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType}
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}, checkedVibrateTypeName: ${this.checkedVibrateTypeName}`);

    vibrateParam = await VibrateUtil.updateVibrateParam(this.systemSoundManagerInstance, context, vibrateParam
      , isSystemRingTone);

    // 设置选择的振动类型名
    this.checkedVibrateTypeName = await VibrateUtil.getCheckedVibrateTypeName(this.systemSoundManagerInstance
      , context, vibrateParam.checkedVibrateRadioName);
    LogUtil.showInfo(this.tag, `updateVibrateData, after update, vibrateParamKey: ${vibrateParamKey}, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType}
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}, checkedVibrateTypeName: ${this.checkedVibrateTypeName}`);
    await PreferencesUtil.put(vibrateParamKey, vibrateParam);
    this.vibrateParamTemp = vibrateParam;
  }

  private async getDefaultVibrateParam(context: Context, toneType: ToneType, audioRingMode: number
    , toneHapticsType: systemSoundManager.ToneHapticsType, isSystemRingTone: boolean): Promise<VibrateParam> {
    let defaultVibrateParam: VibrateParam = new VibrateParam();
    // 读取现在使用的配置
    let toneHapticsSettings: systemSoundManager.ToneHapticsSettings | undefined =
      await VibrateUtil.getToneHapticsSettings(this.systemSoundManagerInstance, context, toneHapticsType);
    if (toneHapticsSettings) {
      defaultVibrateParam.toneType = toneType;
      defaultVibrateParam.isSystemRingTone = isSystemRingTone;
      defaultVibrateParam.toneHapticsType = toneHapticsType;
      defaultVibrateParam.toneHapticsSettings =
        new MyToneHapticsSettings(toneHapticsSettings?.mode, toneHapticsSettings?.hapticsUri);
      // 设置是否使用默认的振动类型
      if (defaultVibrateParam.isSystemRingTone) {
        defaultVibrateParam.isUseDefault =
          defaultVibrateParam.toneHapticsSettings.mode === systemSoundManager.ToneHapticsMode.SYNC;
      } else {
        defaultVibrateParam.isUseDefault = false;
      }
      // 设置默认的振动按钮名
      if (defaultVibrateParam.isSystemRingTone) {
        defaultVibrateParam.defaultVibrateRadioName = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
      } else {
        let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined =
          await VibrateUtil.getToneHapticsList(this.systemSoundManagerInstance, context);
        let nonSyncDefaultFileName: string = VibrateUtil.getNonSyncDefaultFileName(toneType);
        let nonSyncDefaultToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined =
          toneHapticsAttrsArray?.find((item: systemSoundManager.ToneHapticsAttrs) => {
            return item.getFileName() === nonSyncDefaultFileName;
          });
        if (nonSyncDefaultToneHapticsAttrs) {
          defaultVibrateParam.defaultVibrateRadioName = nonSyncDefaultToneHapticsAttrs?.getFileName();
        }
      }
      // 设置选择的振动按钮名
      if (defaultVibrateParam.isUseDefault) {
        defaultVibrateParam.checkedVibrateRadioName = defaultVibrateParam.defaultVibrateRadioName;
      } else {
        if (defaultVibrateParam.toneHapticsSettings.mode === systemSoundManager.ToneHapticsMode.NONE) {
          defaultVibrateParam.checkedVibrateRadioName = RadioName.NOT_VIBRATE;
        } else {
          let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined =
            await VibrateUtil.getToneHapticsList(this.systemSoundManagerInstance, context);
          let checkedToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined =
            toneHapticsAttrsArray?.find((toneHapticsAttrs: systemSoundManager.ToneHapticsAttrs) => {
              return toneHapticsAttrs.getUri() === defaultVibrateParam.toneHapticsSettings.hapticsUri;
            });
          if (checkedToneHapticsAttrs) {
            defaultVibrateParam.checkedVibrateRadioName = checkedToneHapticsAttrs.getFileName();
          }
        }
      }
    } else {
      if (audioRingMode === audio.AudioRingMode.RINGER_MODE_SILENT ||
        audioRingMode === audio.AudioRingMode.RINGER_MODE_NORMAL) {
        defaultVibrateParam = new VibrateParam(toneType, true, true, toneHapticsType
          , new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.SYNC));
      } else {
        let toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray | undefined =
          await VibrateUtil.getToneHapticsList(this.systemSoundManagerInstance, context);
        let nonSyncDefaultFileName: string = VibrateUtil.getNonSyncDefaultFileName(toneType);
        let nonSyncDefaultToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined =
          toneHapticsAttrsArray?.find((item: systemSoundManager.ToneHapticsAttrs) => {
            return item.getFileName() === nonSyncDefaultFileName;
          });
        defaultVibrateParam = new VibrateParam(toneType, true, true, toneHapticsType
          , new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.NON_SYNC
            , nonSyncDefaultToneHapticsAttrs?.getUri())
          , nonSyncDefaultToneHapticsAttrs?.getFileName(), RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE);
      }
    }
    return defaultVibrateParam;
  }

  private onTouchEvent(event: TouchEvent, index: number): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
      this.isSelectedIndex = index;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
      this.isSelectedIndex = -1;
    }
  }

  private getBackgroundColor(index: number): ResourceColor {
    if (this.isSelectedIndex === index) {
      return $r('sys.color.ohos_id_color_click_effect');
    }
    return $r('sys.color.comp_background_list_card');
  }

  private async onClickRingTone(navKey: string, filename: string, title: string, uri: string): Promise<void> {
    LogUtil.showInfo(this.tag, `onClick Ringtone, title: ${title}`);
    this.selectedRingtone = '';
    this.isShowCurrentRingtone = false;
    let isCardOne: boolean = this.currentIndex !== 1;
    let toneType: ToneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
    let key: string = RingtonesUtils.getRingtoneKey(isCardOne, toneType);
    HiSysEventUtil.reportChoseRingToneBehaviorEventByUE(filename, this.navKey, this.isShowCurrentRingtone, isCardOne);
    PreferencesUtil.delete(key + '_music');
    if (title === ResourceUtil.getStringSync($r('app.string.no_ringtone'))) {
      PreferencesUtil.putSync(key + '_type', RINGTONE_TYPE_CUSTOM);
      let ringTone = ResourceUtil.getStringSync($r('app.string.vibrate_only'));
      PreferencesUtil.putSync(key, ringTone);
      this.setRingTone(ringTone);
    } else {
      // 标记为系统铃声
      PreferencesUtil.putSync(key + '_type', RINGTONE_TYPE_SYSTEM);
      PreferencesUtil.putSync(key, title);
      this.setRingTone(title);
    }
    await this.setSystemSoundUri(navKey, filename, uri);
    await this.updateVibrateData();
    await this.systemTonePlayer(navKey);
  }

  private async createSystemTonePlayer(): Promise<void> {
    let context: Context = getContext(this);
    if (this.navKey === NavEntryKey.RING_TONE_ENTRY) {
      let ringToneType: systemSoundManager.RingtoneType = this.currentIndex === 1 ?
      systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1 :
      systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
      try {
        this.ringtonePlay = await this.systemSoundManagerInstance?.getRingtonePlayer(context, ringToneType);
        LogUtil.showInfo(this.tag, `ringtonePlay create success ${this.ringtonePlay}`);
      } catch (err) {
        LogUtil.showError(this.tag, `ringtonePlay create failed:${err?.code} message:${err?.message}`);
      }
    } else if (this.navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
      let systemToneType: systemSoundManager.SystemToneType = this.currentIndex === 1 ?
      systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1 :
      systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
      try {
        this.systemMessageTonePlay =
          await this.systemSoundManagerInstance?.getSystemTonePlayer(context, systemToneType);
        LogUtil.showInfo(this.tag, `systemMessageTonePlay create success ${this.systemMessageTonePlay}`);
      } catch (err) {
        LogUtil.showError(this.tag, `systemMessageTonePlay create failed:${err?.code} ${err?.message}`);
      }
    } else if (this.navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
      let systemToneType: systemSoundManager.SystemToneType =
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION;
      try {
        this.systemNotificationTonePlay =
          await this.systemSoundManagerInstance?.getSystemTonePlayer(context, systemToneType);
        LogUtil.showInfo(this.tag, `systemNotificationTonePlay create success ${this.systemNotificationTonePlay}`);
      } catch (err) {
        LogUtil.showError(this.tag, `systemNotificationTonePlay create failed:${err?.code} ${err?.message}`);
      }
    }
  }

  private async playRingTone(): Promise<void> {
    if (!isActivated) {
      audioSessionManager.activateAudioSession(strategy).then(() => {
        LogUtil.info('playRingTone activateAudioSession SUCCESS');
      }).catch((err: BusinessError) => {
        LogUtil.error(`playRingTone activateAudioSession ERROR: ${err.message}`);
      });
    }
    if (this.ringtonePlay) {
      try {
        await this.ringtonePlay.stop();
        LogUtil.info(`${this.tag} ringtonePlayer stop success`);
      } catch (err) {
        LogUtil.error(` ringtonePlayer stop failed:${err?.code} ${err?.message}`);
      }
    }
    try {
      await this.ringtonePlay?.configure({ volume: 1, loop: true });
      await this.ringtonePlay?.start();
      LogUtil.info(`${this.tag} ringtonePlayer start success`);
    } catch (err) {
      LogUtil.showError(this.tag, `ringtonePlayer start failed:${err?.code} ${err?.message}`);
    }
  }

  private async playMessageTone(): Promise<void> {
    if (this.streamId) {
      try {
        await this.systemMessageTonePlay?.stop(this.streamId);
        LogUtil.info(`${this.tag} systemMessageTonePlay stop success`);
      } catch (err) {
        LogUtil.error(`${this.tag} systemMessageTonePlay stop failed:${err?.code} ${err?.message}`);
      }
    }
    if (this.systemMessageTonePlay) {
      try {
        await this.systemMessageTonePlay?.prepare();
        await this.systemMessageTonePlay?.start().then((val) => {
          this.streamId = val;
        }).catch((err: BusinessError) => {
          LogUtil.error(`${this.tag} systemMessageTonePlay start failed:${err?.code} ${err?.message}`);
        })
        LogUtil.info(`${this.tag} systemMessageTonePlay start success`);
      } catch (err) {
        LogUtil.showError(this.tag, `systemMessageTonePlay prepare and start failed:${err?.code} ${err?.message}`);
      }
    }
  }

  private async playNotificationTone(): Promise<void> {
    if (this.streamId) {
      try {
        await this.systemNotificationTonePlay?.stop(this.streamId);
        LogUtil.info(`${this.tag} systemNotificationTonePlay stop success`);
      } catch (err) {
        LogUtil.showError(this.tag,
          `systemNotificationTonePlay stop failed:${err?.code} ${err?.message}`);
      }
    }
    try {
      await this.systemNotificationTonePlay?.prepare();
      await this.systemNotificationTonePlay?.start().then((val) => {
        this.streamId = val
      }).catch((err: BusinessError) => {
        LogUtil.error(`${this.tag} systemNotificationTonePlay start failed. ${err?.code} ${err?.message}`);
      })
      LogUtil.info(`${this.tag} systemNotificationTonePlay start success`);
    } catch (err) {
      LogUtil.showError(this.tag,
        `systemNotificationTonePlay prepare and start failed:${err?.code} ${err?.message}`);
    }
  }

  // 播放铃声
  private async systemTonePlayer(navKey: string): Promise<void> {
    if (navKey === NavEntryKey.RING_TONE_ENTRY) {
      await this.playRingTone();
    } else if (navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
      await this.playMessageTone();
    } else if (navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
      await this.playNotificationTone();
    }
  }

  // 退出页面停止播放
  private async stopSystemTonePlayer(): Promise<void> {
    if (this.ringtonePlay) {
      try {
        await this.ringtonePlay.stop();
        await this.ringtonePlay.release(); // 释放不了资源
        this.ringtonePlay = undefined;
        LogUtil.info(`${this.tag}  stopSystemTonePlayer ringtonePlay success`);
        audioSessionManager.deactivateAudioSession().then(() => {
          LogUtil.info('stopSystemTonePlayer deactivateAudioSession SUCCESS');
        }).catch((err: BusinessError) => {
          LogUtil.error(`stopSystemTonePlayer ERROR: ${err?.message}`);
        });
      } catch (err) {
        LogUtil.showError(this.tag, `stopSystemTonePlayer systemMessageTonePlay stop:${err?.code} ${err?.message}`);
      }
    }
    let streamId: number | null = this.streamId;
    if (this.systemMessageTonePlay && streamId) {
      try {
        await this.systemMessageTonePlay.stop(streamId);
        await this.systemMessageTonePlay.release();
        this.systemMessageTonePlay = undefined;
        LogUtil.info(`${this.tag} stopSystemTonePlayer systemMessageTonePlay success`);
      } catch (err) {
        LogUtil.showError(this.tag,
          `stopSystemTonePlayer systemMessageTonePlay failed:${err?.code} ${err?.message}`);
      }
    }
    if (this.systemNotificationTonePlay && streamId) {
      try {
        await this.systemNotificationTonePlay.stop(streamId);
        await this.systemNotificationTonePlay.release();
        this.systemNotificationTonePlay = undefined;
        LogUtil.info(`${this.tag} stopSystemTonePlayer systemNotificationTonePlay success`);
      } catch (err) {
        LogUtil.showError(this.tag,
          `stopSystemTonePlayer systemNotificationTonePlay failed:${err?.code} ${err?.message}`
        );
      }
    }
  }

  // 设置铃声
  private async setSystemSoundUri(navKey: string, filename: string, uri: string): Promise<void> {
    let context: Context = getContext(this);
    if (navKey === NavEntryKey.RING_TONE_ENTRY) {
      let ringToneType: systemSoundManager.RingtoneType = 0;
      if (this.currentIndex === 0 || this.currentIndex === 1) {
        ringToneType = this.currentIndex === 0 ? systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0 :
        systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1;
      } else {
        ringToneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
      }
      try {
        await this.systemSoundManagerInstance?.setRingtoneUri(context, uri, ringToneType);
        LogUtil.info(`${this.tag} setRingtoneUri ring_tone_settings success`);
      } catch (err) {
        LogUtil.error(`${this.tag} failed to set system ringtone err:${err?.code} message:${err?.message}`);
      }
    } else if (navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
      let systemToneType: systemSoundManager.SystemToneType = 0;
      if (this.currentIndex === 0 || this.currentIndex === 1) {
        systemToneType = this.currentIndex === 0 ? systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0 :
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1;
      } else {
        systemToneType = systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
      }
      try {
        await this.systemSoundManagerInstance?.setSystemToneUri(context, uri, systemToneType);
        LogUtil.info(`${this.tag} setSystemToneUri Messaging_tone_settings success`);
      } catch (err) {
        LogUtil.error(`${this.tag} failed to set system message uri ${err?.code} message ${err?.message}`);
      }
    } else if (navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
      let notificationType: systemSoundManager.SystemToneType =
        systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION;
      try {
        await this.systemSoundManagerInstance?.setSystemToneUri(context, uri, notificationType);
        LogUtil.info(`${this.tag} setSystemToneUri notification_tone_settings success`);
      } catch (err) {
        LogUtil.error(`${this.tag} failed to set system notification code:${err?.code} message: ${err?.message}`);
      }
    }
  }

  private async getRingToneValue(context: Context): Promise<string | undefined> {
    let ringtoneValue: string | undefined = '';
    let ringToneType: systemSoundManager.RingtoneType = 0;
    if (this.currentIndex === 0 || this.currentIndex === 1) {
      ringToneType = this.currentIndex === 0 ? systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0 :
      systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1;
    } else {
      ringToneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
    }

    try {
      ringtoneValue = await this.systemSoundManagerInstance?.getRingtoneUri(context, ringToneType);
      LogUtil.info(`${this.tag} ring_tone_settings getRingtoneUri ${ringtoneValue}`);
    } catch (err) {
      LogUtil.error(`${this.tag} getRingtoneUri code:${err?.code} message:${err?.message}`);
    }
    return ringtoneValue;
  }

  private async getSystemToneValue(context: Context): Promise<string | undefined> {
    let ringtoneValue: string | undefined = '';
    let messageType: systemSoundManager.SystemToneType = 0;
    if (this.currentIndex === 0 || this.currentIndex === 1) {
      messageType = this.currentIndex === 0 ? systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0 :
      systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1;
    } else {
      messageType = systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0
    }
    try {
      ringtoneValue = await this.systemSoundManagerInstance?.getSystemToneUri(context, messageType);
      LogUtil.info(`${this.tag} Messaging_tone_settings getSystemToneUri ${ringtoneValue}`);
    } catch (err) {
      LogUtil.error(`${this.tag} getSystemToneUri errorCode ${err?.code} errorMessage ${err?.message}`);
    }
    return ringtoneValue;
  }

  private async getNotificationToneValue(context: Context): Promise<string | undefined> {
    let ringtoneValue: string | undefined = '';
    let notificationType: systemSoundManager.SystemToneType =
      systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION;
    try {
      ringtoneValue = await this.systemSoundManagerInstance?.getSystemToneUri(context, notificationType);
      LogUtil.info(`${this.tag} notification_tone_settings getSystemToneUri ${ringtoneValue}`);
    } catch (err) {
      LogUtil.error(`${this.tag} getSystemToneUri errorCode ${err?.code} errorMessage ${err?.message}`);
    }
    return ringtoneValue;
  }

  private async getSystemRingtone(): Promise<void> {
    const DEFAULT_VALUE: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_default'));
    let context: Context = getContext(this);
    let ringtoneValue: string | undefined = '';
    if (this.navKey === NavEntryKey.RING_TONE_ENTRY) { // 来电铃声
      ringtoneValue = await this.getRingToneValue(context);
    } else if (this.navKey === NavEntryKey.MESSAGING_TONE_ENTRY) { // 信息铃声
      ringtoneValue = await this.getSystemToneValue(context);
    } else if (this.navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) { // 通知铃声
      ringtoneValue = await this.getNotificationToneValue(context);
    }

    let ringtoneArr: Array<string> | string | undefined = ringtoneValue ? ringtoneValue.split('/') : ringtoneValue;
    if (ringtoneArr) {
      ringtoneValue = ringtoneArr[ringtoneArr.length - 1];
    }
    if (ringtoneValue === '') {
      if (this.navKey === NavEntryKey.RING_TONE_ENTRY) {
        this.findName = this.currentIndex === 0 ? `Tune OpenHarmony (${DEFAULT_VALUE})` :
          `Tune Clean (${DEFAULT_VALUE})`;
      } else if (this.navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
        this.findName = `Leap (${DEFAULT_VALUE})`;
      } else if (this.navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
        this.findName = `Rise (${DEFAULT_VALUE})`;
      }
    } else {
      let isCheckedIndex = this.ringList?.findIndex((item) => {
        return item.fileName === ringtoneValue;
      })
      if (isCheckedIndex !== undefined && isCheckedIndex !== -1) {
        this.findName = this.ringList && this.ringList[isCheckedIndex].title;
      } else if (isCheckedIndex == -1) {
        this.findName = this.noRingtone;
      }
    }
  }

  private setRingTone(name: string): void {
    const DEFAULT_VALUE: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_default'));
    if (name && name.includes(DEFAULT_VALUE)) {
      name = name.replace(new RegExp(`\\(${DEFAULT_VALUE}\\)`, 'g'), '').trim();
    }
    EventBus.getInstance().emit(RingtonesUtils.getEmitId(this.navKey),
      {
        currentIndex: this.currentIndex,
        value: name,
      } as VolumeDataType
    );
  }

  private async getResource(): Promise<void> {
    try {
      this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
      this.currentURI=await this.systemSoundManagerInstance.getRingtoneUri(this.context,0)
      LogUtil.info(`${this.tag} systemSoundManagerInstance success`);
    } catch (err) {
      LogUtil.error(`${this.tag} systemSoundManagerInstance errorCode ${err?.code} errorMessage ${err?.message}`);
    }
    await this.createSystemTonePlayer();
  }

  aboutToAppear() {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.ringtoneList.pushDataList(this.ringList!)
    this.getResource();
    this.updateRingtoneData();
    this.updateVibrateData();
    EventBus.getInstance().on(EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED, this.onBundleAudioRingModeChangedCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE, this.pageShowChange);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED, this.onBundleAudioRingModeChangedCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE, this.pageShowChange);
    this.stopSystemTonePlayer();
  }

  private onBundleAudioRingModeChangedCallback: (isChanged: boolean) => void = (isChanged: boolean) => {
    LogUtil.showInfo(this.tag, `onBundleAudioRingModeChangedCallback changed: ${isChanged}`);
    if (!isChanged) {
      return;
    }
    let toneType: ToneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
    let audioRingMode: number = VolumeAdapter.getInstance().getRingerMode();
    let toneHapticsType: systemSoundManager.ToneHapticsType = VibrateUtil.getToneHapticsType(toneType
      , this.currentIndex);
    let vibrateParamKey: string = VibrateUtil.getVibrateParamKey(toneType, toneHapticsType, audioRingMode);
    let vibrateParam: VibrateParam = VibrateUtil.getVibrateParamInMemory(vibrateParamKey, 
      this.vibrateParamTemp) as VibrateParam;
    let context: Context = getContext(this);
    VibrateUtil.getCheckedVibrateTypeName(this.systemSoundManagerInstance, context
      , vibrateParam.checkedVibrateRadioName)
      .then((checkedVibrateTypeName: string) => {
        this.checkedVibrateTypeName = checkedVibrateTypeName;
      })
      .catch((err: BusinessError) => {
        LogUtil.showError(this.tag, `getCheckedVibrateTypeName failed, error code: ${err.code}, error message: ${err.message}`);
      });
    LogUtil.showInfo(this.tag, 'onBundleAudioRingModeChangedCallback end');
  };

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) ?
    $r('sys.color.interactive_click') : null)
  }

  @Builder
  ringToneItem(item: ToneAttrs, index: number): void {
    Flex({
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Text(this.getRingToneItemTitle(index, item))
        .margin({ start: PADDING_8 })
        .constraintSize({ minHeight: $r('app.float.height_36') })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.comp_foreground_primary'))
        .fontWeight(FontWeight.Medium)
        .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
      if (item.title === this.findName && !this.isShowCurrentRingtone) {
        Radio({ value: item.title, group: 'radioGroup' })
          .margin({ end: PADDING_8 })
          .width($r('app.float.wh_value_20'))
          .constraintSize({ minHeight: $r('app.float.wh_value_20') })
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.brand')
          })
          .checked(item.title === this.findName ? true : false)
          .onChange((isChecked: boolean) => {
            if (this.controller) {
              this.controller.isChecked = isChecked;
            }
          })
          .onClick((event) => {
            LogUtil.info(`onClick`);
            this.onClickRingTone(this.navKey, item.fileName, item.title, item.uri);
            this.findName = item.title;
          });
      }
    }
    .constraintSize({ minHeight: $r('app.float.height_48') })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor(this.getBackgroundColor(index))
    .stateStyles({
      normal: {
        .backgroundColor(this.hoverItem === item.fileName && this.isHover ? $r('sys.color.interactive_hover') :
          $r('sys.color.ohos_id_color_background_transparent'))
      },
      pressed: this.pressedStateIconStyles,
    })
    .padding({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level4') })
    .onClick((event) => {
      this.onClickRingTone(this.navKey, item.fileName, item.title, item.uri);
      this.findName = item.title;
    })
    .onTouch((event) => {
      this.onTouchEvent(event, index);
    })
    .accessibilityGroup(true)
    .accessibilityText(this.getRingToneItemTitle(index, item))
    .accessibilitySelected(item.title === this.findName)
    .accessibilityDescription(item.title === this.findName ? ' ' : '')
    .onHover((hover: boolean) => {
      this.isHover = hover;
      this.hoverItem = item.fileName;
    });
  }

  private getRingToneItemTitle(index: number, item: ToneAttrs) {
    return index == 0 ? (item.title.indexOf('(') >= 0 ?
      item.title.substring(0, item.title.indexOf('(')) + `(${this.ringToneDefaultValue})` :
      item.title + `(${this.ringToneDefaultValue})`) : item.title;
  }

  @Builder
  CurrentRingtoneBuilder(): void {
    Column() {
      Text($r('app.string.current_ringtone'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          top: PADDING_24,
          start: PADDING_12,
        })
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
    }
    .padding({ top: FontScaleUtils.getCurrentTopPadding(), bottom: FontScaleUtils.getCurrentTopPadding() })
    .width('100%')
    .constraintSize({
      minHeight: 56,
    })
    .alignItems(HorizontalAlign.Start)

    Column() {
      Row() {
        Text(this.selectedRingtone)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_foreground_primary'))
          .textAlign(TextAlign.Start)
          .width('calc(100% - 24vp - 8vp)')
          .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)

        Radio({ value: 'Radio1', group: 'radioGroup' })
          .checked(this.selectedRingtone !== '')
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.brand')
          })
          .margin({ end: PADDING_8 })
          .width($r('app.float.wh_value_20'))
          .constraintSize({ minHeight: $r('app.float.wh_value_20') })
      }
      .accessibilityGroup(true)
      .accessibilityText(this.selectedRingtone)
      .accessibilitySelected(this.selectedRingtone !== '')
      .accessibilityDescription(this.selectedRingtone !== '' ? ' ' : '')
      .padding({
        top: $r('sys.float.padding_level4'),
        bottom: $r('sys.float.padding_level4'),
        left: $r('sys.float.padding_level6'),
        right: $r('sys.float.padding_level6'),
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .constraintSize({
        minHeight: 48,
      })
      .width('100%')
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding({
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2'),
    })
  }

  @Builder
  VibrateBuilder() {
    Column() {
      this.vibrateItem()
    }
    .width('100%')
    .padding({
      top: PADDING_4,
      bottom: PADDING_4,
      start: PADDING_4,
      end: PADDING_4
    })
    .margin({
      top: RingtonesUtils.navKey2Type(this.navKey) as ToneType === ToneType.NOTIFICATION_TONE ? PADDING_16 : PADDING_0,
      bottom:PADDING_12,
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .clip(true)
  }

  @Builder
  vibrateItem() {
    if (this.isExtraLargeFontMode()) {
      this.vibrateBuildLargeStyle()
    } else {
      Row() {
        Text($r('app.string.volume_mode_vibrate'))
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .wordBreak(WordBreak.BREAK_ALL)
          .flexShrink(0)
        this.vibrateContentBuilder()
      }
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.height_48') })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .padding({ start: PADDING_8, end: PADDING_8 })
      .stateStyles({
        normal: {
          .backgroundColor(this.hoverItem === 'VIBRATE' && this.isHover ? $r('sys.color.interactive_hover') :
          Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
        pressed: this.pressedStyles,
      })
      .onClick(() => {
        this.vibrateEntryClick();
      })
      .onHover((hover: boolean) => {
        this.isHover = hover;
        this.hoverItem = 'VIBRATE';
      })
    }
  }

  @Builder
  vibrateBuildLargeStyle() {
    Column() {
      Text($r('app.string.volume_mode_vibrate'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .wordBreak(WordBreak.BREAK_WORD)
        .textAlign(TextAlign.Start)
      this.vibrateLargeContentBuilder()
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.height_48') })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({
      start: PADDING_8,
      end: PADDING_8,
      top: FontScaleUtils.getSafetyPadding(),
      bottom: FontScaleUtils.getSafetyPadding() })
    .stateStyles({
      normal: {
        .backgroundColor(this.hoverItem === 'VIBRATE' && this.isHover ? $r('sys.color.interactive_hover') :
        Color.Transparent)
        .borderRadius($r('sys.float.corner_radius_level8'))
      },
      pressed: this.pressedStyles,
    })
    .onClick(() => {
      this.vibrateEntryClick();
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
      this.hoverItem = 'VIBRATE';
    })
  }

  private isExtraLargeFontMode() {
    return FontScaleUtils.isExtraLargeFontMode();
  }

  @Builder
  vibrateContentBuilder() {
    Row() {
      Column() {
        Text() {
          Span(this.checkedVibrateTypeName)
        }
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .textAlign(TextAlign.End)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.End)
      .margin({ end: PADDING_4 })
      .constraintSize({ minHeight: $r('app.float.height_48') })
      .flexShrink(1)
      Image($r('app.media.ic_settings_arrow'))
        .fillColor($r('sys.color.icon_fourth'))
        .width('12vp')
        .height('24vp')
        .draggable(false)
        .syncLoad(true)
        .margin({ start: PADDING_4 })
        .flexShrink(0)
        .matchTextDirection(true)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .flexGrow(1)
    .flexShrink(1)
  }

  @Builder
  vibrateLargeContentBuilder() {
    Row() {
      Column() {
        Text() {
          Span(this.checkedVibrateTypeName)
        }
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .textAlign(TextAlign.Start)
          .wordBreak(WordBreak.BREAK_WORD)
          .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
      }
      .flexShrink(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ end: PADDING_4 })
      .constraintSize({ minHeight: $r('app.float.height_48') })
      Image($r('app.media.ic_settings_arrow'))
        .fillColor($r('sys.color.icon_fourth'))
        .width('12vp')
        .height('24vp')
        .draggable(false)
        .syncLoad(true)
        .margin({ start: PADDING_4 })
        .matchTextDirection(true)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  SelectRingtoneBuilder() {
    Column() {
      Text($r('app.string.select_ringtone'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          top: PADDING_24,
          start: PADDING_12,
        })
        .padding( {top: FontScaleUtils.getCurrentTopPadding(), bottom: FontScaleUtils.getCurrentTopPadding()} )
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
    }
    .width('100%')
    .constraintSize({
      minHeight: 56,
    })
    .alignItems(HorizontalAlign.Start)

    Column() {
      this.selectRingtoneItemBuilder($r('app.string.local_music'), PageType.LOCAL_PAGE_TYPE, ItemGroupPostion.TOP);
      this.dividerBuilder();
      // this.selectRingtoneItemBuilder($r('app.string.online_music'), PageType.ONLINE_PAGE_TYPE,
      //   this.navKey === NavEntryKey.RING_TONE_ENTRY ? ItemGroupPostion.MIDDLE : ItemGroupPostion.BOTTOM);
      if (this.navKey === NavEntryKey.RING_TONE_ENTRY) {
        // this.dividerBuilder();
        this.selectRingtoneItemBuilder($r('app.string.video_music'), PageType.VIDEO_PAGE_TYPE, ItemGroupPostion.BOTTOM);
      }
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ bottom: '12vp' })
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
    })
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  @Builder
  selectRingtoneItemBuilder(text: ResourceStr, pageType: PageType, position: ItemGroupPostion) {
    Row() {
      Text(text)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.comp_foreground_primary'))
        .textAlign(TextAlign.Start)
        .width('calc(100% - 12vp - 12vp)')

      Image($r('app.media.ic_settings_arrow'))
        .width($r('app.float.wh_value_12'))
        .height($r('app.float.wh_value_24'))
        .fillColor($r('sys.color.ohos_id_color_fourth'))
        .matchTextDirection(true)
    }
    .onClick(() => {
      this.entryClick(pageType);
    })
    .padding({
      left: '8vp',
      right: '8vp',
      top: FontScaleUtils.getCurrentTopPadding(),
      bottom: FontScaleUtils.getCurrentTopPadding()
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .constraintSize({
      minHeight: 48,
    })
    .width('100%')
    .margin({
      top: position === ItemGroupPostion.TOP ? '4vp' : '0vp',
      bottom: position === ItemGroupPostion.BOTTOM ? '4vp' : '0vp'
    })
    .stateStyles({
      normal: {
        .backgroundColor(this.hoverItem === pageType && this.isHover ? $r('sys.color.interactive_hover') :
        Color.Transparent)
        .borderRadius($r('sys.float.corner_radius_level8'))
      },
      pressed: this.pressedStateIconStyles,
    })
    .onHover((hover: boolean) => {
      this.hoverItem = pageType;
      this.isHover = hover;
    })
  }

  @Builder
  dividerBuilder() {
    Divider()
      .strokeWidth('1px')
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
      .width('100%')
  }

  private needShowCurrentRingtone(ringtoneTypeKey: string): boolean {
    if (this.isSelectedNoRingtone()) {
      return false;
    }
    return PreferencesUtil.getSync(ringtoneTypeKey, RINGTONE_TYPE_SYSTEM) === RINGTONE_TYPE_CUSTOM;
  }

  private isSelectedNoRingtone(): boolean {
    return this.findName === ResourceUtil.getStringSync($r('app.string.vibrate_only')) ||
      this.findName === ResourceUtil.getStringSync($r('app.string.volume_mode_silent'));
  }

  @Builder
  SelectBlankRingBuilder() {
    Column() {
      Row() {
        Text($r('app.string.no_ringtone'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_foreground_primary'))
          .textAlign(TextAlign.Start)
          .width('calc(100% - 12vp - 12vp)')

        if (this.isSelectedNoRingtone()) {
          Radio({ value: this.noRingtone, group: 'radioGroup' })
            .margin({ end: PADDING_8 })
            .width($r('app.float.wh_value_20'))
            .constraintSize({ minHeight: $r('app.float.wh_value_20') })
            .radioStyle({
              checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
            })
            .checked(true)
            .onChange((isChecked: boolean) => {
              if (this.controller) {
                this.controller.isChecked = isChecked;
              }
            })
            .onClick((event) => {
              this.ringClick();
            })
            .accessibilityLevel('no')
        }
      }
      .constraintSize({
        minHeight: 48,
      })
      .padding({
        start: PADDING_8,
        end: PADDING_12,
        top: PADDING_4,
        bottom: PADDING_4
      })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .stateStyles({
        normal: {
          .backgroundColor(this.hoverItem === 'NO_SOUND' && this.isHover ? $r('sys.color.interactive_hover') :
          Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
        pressed: this.pressedStateIconStyles,
      })
      .onHover((hover: boolean) => {
        this.isHover = hover;
        this.hoverItem = 'NO_SOUND';
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .constraintSize({
        minHeight: 48,
      })
      .width('100%')
      .margin({ top: '4vp'})
    }
    .padding({
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2')
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: '12vp'})
    .borderRadius('20vp')
    .onClick((event) => {
      this.ringClick();
    })
    .onTouch((event) => {
      this.onTouchEvent(event, -2);
    })
    .accessibilitySelected(this.findName === ResourceUtil.getStringSync($r('app.string.vibrate_only')) ||
      this.findName === ResourceUtil.getStringSync($r('app.string.volume_mode_silent')))
    .accessibilityDescription(this.findName === ResourceUtil.getStringSync($r('app.string.vibrate_only')) ||
      this.findName === ResourceUtil.getStringSync($r('app.string.volume_mode_silent')) ? ' ' : '')
  }

  private ringClick() {
    this.onClickRingTone(this.navKey, this.noRingtone, this.noRingtone,
      this.navKey === NavEntryKey.RING_TONE_ENTRY ? DEFAULT_NO_RING_URI : DEFAULT_NO_RINGTONE_URI);
    this.findName = ResourceUtil.getStringSync($r('app.string.vibrate_only'));
  }

  private entryClick(pageType: PageType) {
    LogUtil.showInfo(this.tag, `pageType: ${pageType} selectedRingtoneName: ${this.selectedRingtoneData?.ringtoneName}`);
    
    // 当点击本地音乐时，拉起文件管理选择MP3文件
    if (pageType === PageType.LOCAL_PAGE_TYPE) {
      this.pickMP3File();
      return;
    }
    // 其他类型铃声页面保持原有逻辑
    let ringtoneParam = new RingtoneParam();
    ringtoneParam.pageType = pageType;
    ringtoneParam.toneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
    ringtoneParam.card = this.currentIndex === 1 ? '1' : '0';
    ringtoneParam.uiStyle = '0';
    ringtoneParam.showTitle = true;
    let isSelectedRingToneEmpty: boolean = this.selectedRingtone === '';
    if (!isSelectedRingToneEmpty) {
      if (pageType !== PageType.VIDEO_PAGE_TYPE) {
        ringtoneParam.selectedRingtoneName = this.selectedRingtoneData?.ringtoneName as string ?? '';
        ringtoneParam.ringtonePath = this.selectedRingtoneData?.ringtonePath as string ?? '';
      }
      if (pageType === PageType.ONLINE_PAGE_TYPE) {
        ringtoneParam.selectRingtoneContentId = this.selectedRingtoneData?.ringtoneContentId as string ?? '';
      } /*else if (pageType == PageType.LOCAL_PAGE_TYPE) {
        ringtoneParam.selectedRingtonePath = this.selectedRingtoneData?.ringtonePath as string ?? '';
        ringtoneParam.selectedLibraryRingtonePath = this.selectedRingtoneData?.ringtoneLibaryPath as string ?? '';
      }*/ else {
        LogUtil.showWarn(this.tag, `entryClick invalid pageType: ${pageType}`);
      }
    }
    DynamicLoader.getInstance().fire(NavEntryKey.MUSIC_SERVICE).then(() => {
      this.pathInfoStack?.pushPathByName(NavEntryKey.MUSIC_SERVICE, new PushParam(ringtoneParam));
    });
  }
  /**
   * 拉起文件管理选择MP3文件
   */
  private pickMP3File(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    LogUtil.showInfo(this.tag, 'audioSelectOptions');
    const toneAttrs = systemSoundManager.createCustomizedToneAttrs();
    const categoryValue = systemSoundManager.TONE_CATEGORY_RINGTONE;
    const documentSelectOptions = new picker.DocumentSelectOptions()
    documentSelectOptions.fileSuffixFilters=['音频|.m4a,.aac,.mp3,.ogg,.wav,.flac,.amr,.ape']
    documentSelectOptions.maxSelectNumber=1
    const documentPicker = new picker.DocumentViewPicker(context)
    documentPicker.select(documentSelectOptions).then((audioSelectResult: Array<string>) => {
      //文件选择成功后，返回被选中音频的URI结果集。
      if (audioSelectResult.length > 0) {
        let uri = audioSelectResult[0]
        try {
          let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
          // 选择铃声和当前铃声是否一致
          if (this.findName === file.name) {
            return
          }
          toneAttrs.setTitle(file.name)
          toneAttrs.setFileName(file.name)
          toneAttrs.setCategory(categoryValue);
          toneAttrs.setMediaType(systemSoundManager.MediaType.AUDIO)
          this.systemSoundManagerInstance?.addCustomizedTone(this.context, toneAttrs, file.fd, 0).then(async (value: string) => {
            LogUtil.showInfo(this.tag, `addCustomizedTone  value:${value}`);
            let ctx: Context = getContext(this);
            let oldUri: string = '';
            if (this.navKey === NavEntryKey.RING_TONE_ENTRY) {
              oldUri = (await this.getRingToneValue(ctx)) ?? '';
            } else if (this.navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
              oldUri = (await this.getSystemToneValue(ctx)) ?? '';
            } else if (this.navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
              oldUri = (await this.getNotificationToneValue(ctx)) ?? '';
            }
            try {
              if (this.navKey === NavEntryKey.RING_TONE_ENTRY) {
                let ringToneType: systemSoundManager.RingtoneType = this.currentIndex === 1 ?
                  systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1 :
                  systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
                await this.systemSoundManagerInstance?.setRingtoneUri(this.context, value, ringToneType);
              } else if (this.navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
                let systemToneType: systemSoundManager.SystemToneType = this.currentIndex === 1 ?
                  systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1 :
                  systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
                await this.systemSoundManagerInstance?.setSystemToneUri(this.context, value, systemToneType);
              } else if (this.navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
                await this.systemSoundManagerInstance?.setSystemToneUri(this.context, value,
                  systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION);
              }
              LogUtil.showInfo(this.tag, 'Succeeded in setting tone.');
              this.selectedRingtone = file.name;
              this.getUIContext().getPromptAction().showToast({ message: '设置成功' });
              if (oldUri !== '') {
                this.systemSoundManagerInstance?.removeCustomizedTone(this.context, oldUri);
              }
              this.currentURI = value;
              // 持久化当前选择并同步摘要
              let isCardOne: boolean = this.currentIndex !== 1;
              let toneType: ToneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
              let key: string = RingtonesUtils.getRingtoneKey(isCardOne, toneType);
              let musicData: Record<string, Object> = {};
              musicData['ringtoneName'] = file.name;
              musicData['ringtonePath'] = value;
              musicData['uri'] = value;
              PreferencesUtil.putSync(key + '_music', musicData);
              PreferencesUtil.putSync(key + '_type', RINGTONE_TYPE_CUSTOM);
              let volumeData: VolumeDataType = {} as VolumeDataType;
              volumeData.currentIndex = this.currentIndex ?? 0;
              volumeData.value = file.name;
              EventBus.getInstance().emit(RingtonesUtils.getEmitId(this.navKey), volumeData);
            } catch (err) {
              let errObj = err as BusinessError;
              LogUtil.showError(this.tag, `Failed to set tone. Code: ${errObj?.code}, message: ${errObj?.message}`);
              this.systemSoundManagerInstance?.removeCustomizedTone(this.context, value);
            }
          }).catch(async (err: BusinessError) => {
            LogUtil.showError(this.tag, `addCustomizedTone error, error code: ${err.code}, error msg: ${err.message}`);
          }).finally(() => {
            fs.closeSync(file.fd);
          });
        } catch (err) {
          LogUtil.showError(this.tag, ` Code: ${(err as BusinessError)?.code}, message: ${(err as BusinessError)?.message}`);
        }
      }
    }).catch((err: BusinessError) => {
      LogUtil.showError(this.tag, `Invoke audioViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    });
  }


  private vibrateEntryClick(): void {
    let toneType: ToneType = RingtonesUtils.navKey2Type(this.navKey) as ToneType;
    let audioRingMode: number = VolumeAdapter.getInstance().getRingerMode();
    let toneHapticsType: systemSoundManager.ToneHapticsType = VibrateUtil.getToneHapticsType(toneType
      , this.currentIndex);
    LogUtil.showInfo(this.tag, `vibrateEntryClick, toneType : ${toneType}, audioRingMode: ${audioRingMode}, toneHapticsType: ${toneHapticsType}`);
    let vibrateParamKey: string = VibrateUtil.getVibrateParamKey(toneType, toneHapticsType, audioRingMode);
    let vibrateParam: VibrateParam = VibrateUtil.getVibrateParamInMemory(vibrateParamKey,
      this.vibrateParamTemp) as VibrateParam;
    LogUtil.showInfo(this.tag, `vibrateEntryClick, vibrateParamKey: ${vibrateParamKey}, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType};
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}`);
    DynamicLoader.getInstance().fire(NavEntryKey.VIBRATE_SERVICE).then(() => {
      this.pathInfoStack?.pushPathByName(NavEntryKey.VIBRATE_SERVICE, new PushParam(vibrateParam));
    });
  }

  build() {
    Column() {
      List() {
        ListItemGroup() {
          // 振动设置项 UI
          if (VibratorUtil.isSupportVibrate()) {
            this.VibrateBuilder();
          }
          if (this.isShowCurrentRingtone) {
            this.CurrentRingtoneBuilder();
          }
          this.SelectRingtoneBuilder();
        }

        ListItem() {
          this.SelectBlankRingBuilder()
        }

        ListItemGroup() {
          LazyForEach(this.ringtoneList, (item: ToneAttrs, index: number) => {
            ListItem() {
              Column() {
                this.ringToneItem(item, index);
                if (index !== (this.ringtoneList?.ringtoneArray.length - 1)) {
                  Divider()
                    .height(px2vp(2))
                    .strokeWidth(0.5)
                    .color($r('sys.color.comp_divider'))
                    .lineCap(LineCapStyle.Square)
                    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
                    .width('100%')
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding({
                top: index === 0 ? $r('sys.float.padding_level2') : 0,
                bottom: index === (this.ringtoneList?.ringtoneArray.length - 1) ? $r('sys.float.padding_level2') :
                  0,
                left: $r('sys.float.padding_level2'),
                right: $r('sys.float.padding_level2'),
              })
            }
          }, (item: ToneAttrs) => item?.title)
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius($r('sys.float.corner_radius_level10'))
      }
      .padding({
        left: DeviceUtil.isDevicePad() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
        right: DeviceUtil.isDevicePad() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
        bottom: 0,
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%')
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .justifyContent(FlexAlign.Start)
    .height('100%')
  }

  ringListChange(changedPropertyName: string) {
    let localeChangeForRingtone: boolean = PreferencesUtil.getSync(this.localeChangeForRingtone, false) as boolean;
    let localeChangeForMessageTone: boolean =
      PreferencesUtil.getSync(this.localeChangeForMessageTone, false) as boolean;
    let localeChangeForNotificationTone: boolean =
      PreferencesUtil.getSync(this.localeChangeForNotificationTone, false) as boolean;

    if (this.ringtoneList.ringtoneArray.length === 0 || localeChangeForRingtone ||
      localeChangeForMessageTone || localeChangeForNotificationTone) {
      LogUtil.showInfo(this.tag, `localeChange: ${localeChangeForRingtone}, ${localeChangeForMessageTone}, ${localeChangeForNotificationTone}, list: ${this.ringtoneList.ringtoneArray.length}`);
      this.ringtoneList.ringtoneArray = [];
      this.ringtoneList.pushDataList(this.ringList!)
      this.ringtoneList.notifyDataChange();
      this.getResource();
      this.updateRingtoneData();
      if (this.navKey === NavEntryKey.RING_TONE_ENTRY) {
        PreferencesUtil.putSync(this.localeChangeForRingtone, false);
      }
      if (this.navKey === NavEntryKey.MESSAGING_TONE_ENTRY) {
        PreferencesUtil.putSync(this.localeChangeForMessageTone, false);
      }
      if (this.navKey === NavEntryKey.NOTIFICATION_TONE_ENTRY) {
        PreferencesUtil.putSync(this.localeChangeForNotificationTone, false);
      }
    }
    LogUtil.info(`${this.tag} ringListChange this.RingtoneList ${this.ringtoneList?.totalCount()}`);
  }
}

class SystemRingtoneSource implements IDataSource {
  public ringtoneArray: Array<ToneAttrs> = [];
  private listeners: DataChangeListener[] = [];

  constructor(ringtoneArray: Array<ToneAttrs>) {
    this.ringtoneArray = ringtoneArray;
  }

  public totalCount(): number {
    return this.ringtoneArray.length;
  }

  public getData(index: number): ToneAttrs {
    return this.ringtoneArray[index];
  }

  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const position = this.listeners.indexOf(listener);
    if (position >= 0) {
      this.listeners.splice(position, 1);
    }
  }

  public pushDataList(data: Array<ToneAttrs>): void {
    if (data) {
      for (let element of data) {
        if (this.ringtoneArray.indexOf(element) > -1) {
          continue;
        }
        this.ringtoneArray.push(element);
      }
      this.notifyDataAdd(this.ringtoneArray.length - 1);
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }
}

