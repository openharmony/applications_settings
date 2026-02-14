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
import intl from '@ohos.intl';
import common from '@ohos.app.ability.common';
import audio from '@ohos.multimedia.audio';
import { vibrator } from '@kit.SensorServiceKit';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { BusinessError } from '@kit.BasicServicesKit';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import {
  PADDING_2,
  PADDING_4,
  PADDING_8,
  PADDING_12,
  PADDING_16,
  PADDING_24
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED } from '@ohos/settings.common/src/main/ets/event/types';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysVibrationGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { MyToneHapticsSettings, VibrateParam } from '../model/VibrateParam';
import { RadioName } from '../constant/VibrateConstant';
import { VibrateUtil } from '../utils/VibrateUtil';
import { VolumeAdapter } from '../controller/VolumeAdapter';
import { ToneType } from '../model/RingtoneParam';

const TAG: string = 'VibrateServiceComponent : ';

@Builder
export function VibrateServiceLoader($$: Params): void {
  VibrateServiceComponent({ params: $$ as Object as PushParam });
}

@Component
export struct VibrateServiceComponent {
  private ringToneDefaultValue: string = ResourceUtil.getStringSync($r('app.string.screen_zoom_summary_default'));
  private params: PushParam | null = null;
  private title: string = ResourceUtil.getStringSync($r('app.string.volume_mode_vibrate'));
  private scroller: Scroller = new Scroller();
  private syncDefaultToneHapticsAttrs: systemSoundManager.ToneHapticsAttrs | undefined = undefined;
  private systemSoundManagerInstance: systemSoundManager.SystemSoundManager | undefined = undefined;

  @Consume('pathInfos') pathInfos: NavPathStack;
  @State private toneHapticsAttrsArray: systemSoundManager.ToneHapticsAttrsArray = [];
  @State private checkedRadioName: string | undefined = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
  @State private audioRingMode: audio.AudioRingMode = audio.AudioRingMode.RINGER_MODE_NORMAL;
  @State private isSystemRingTone: boolean = true;
  @State private defaultVibrateRadioName: string = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
  @State private toneType: ToneType = ToneType.RINGTONE;

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
  }

  @Builder VibrateNavigationTitle() {
    Column() {
      Text($r('app.string.volume_mode_vibrate'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
    }
  }

  /**
   * 与铃声同步
   */
  @Builder VibrateSynchronizeWithRingtoneBuilder() {
    Column() {
      Row() {
        Column() {
          Text() {
            Span($r('app.string.vibrate_synchronize_with_ringtone'))
            if (this.isSystemRingTone) {
              Span(`（`)
              Span(this.ringToneDefaultValue)
              Span(`）`)
            }
          }
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ bottom: PADDING_2})

          Text($r('app.string.only_supports_synchronized_vibration_with_system_ringtone'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Start)
            .width('100%')
        }
        .width('calc(100% - 12vp - 44vp)')
        .justifyContent(FlexAlign.Center)
        Blank()
        if (RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE === this.checkedRadioName) {
          Radio({ value: RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE, group: 'vibrateRadioGroup' })
            .radioStyle({
              checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
            })
            .accessibilityLevel('no')
            .margin({end: PADDING_4})
            .width($r('app.float.wh_value_20'))
            .constraintSize({minHeight:$r('app.float.wh_value_20')})
            .checked(RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE === this.checkedRadioName ? true : false)
            .onClick((event: ClickEvent) => {
              LogUtil.showInfo(TAG, `vibrate synchronize with ringtone radio click title: ${RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE}`);
              this.onClickVibrateSynchronizeWithRingtoneRadio(RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE);
            });
        }
      }
      .padding({
        top: FontScaleUtils.getSafetyPadding(),
        bottom: FontScaleUtils.getSafetyPadding(),
        start: PADDING_8,
        end: PADDING_8
      })
      .constraintSize({
        minHeight: '64vp',
      })
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level8'))
      .alignItems(VerticalAlign.Center)
      .onClick((event: ClickEvent) => {
        LogUtil.showInfo(TAG, `vibrate synchronize with ringtone radio click title: ${RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE}`);
        this.onClickVibrateSynchronizeWithRingtoneRadio(RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE);
      })
      .opacity(this.isSystemRingTone ? 1.0 : 0.4)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .accessibilitySelected(this.checkedRadioName === RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE)
      .accessibilityDescription(this.checkedRadioName === RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE ? ' ' : '')
    }
    .enabled(this.isSystemRingTone)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ top: PADDING_16, bottom: PADDING_12})
    .padding({ top: PADDING_4, bottom: PADDING_4, start: PADDING_4, end: PADDING_4})
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  /**
   * 经典振动
   */
  @Builder ClassicVibrateBuilder() {
    Column() {
      ForEach(this.toneHapticsAttrsArray, (item: systemSoundManager.ToneHapticsAttrs, index: number) => {
        if (item) {
          Column() {
            Row() {
              Text() {
                if (LanguageUtils.isLtrDirection()) {
                  if (!this.isSystemRingTone && this.defaultVibrateRadioName === item.getFileName()) {
                    Span(item.getTitle() + '（' + this.ringToneDefaultValue + '）')
                  } else {
                    Span(item.getTitle())
                  }
                } else {
                  if (!this.isSystemRingTone && this.defaultVibrateRadioName === item.getFileName()) {
                    Span('（' + this.ringToneDefaultValue + '）' + item.getTitle())
                  } else {
                    Span(item.getTitle())
                  }
                }
              }
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Start)
                .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)
                .constraintSize({ maxWidth: '90%' })
              Blank()
              if (item.getFileName() === this.checkedRadioName) {
                Radio({ value: item.getFileName(), group: 'vibrateRadioGroup' })
                  .radioStyle({
                    checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
                  })
                  .accessibilityLevel('no')
                  .margin({end: PADDING_4})
                  .width($r('app.float.wh_value_20'))
                  .constraintSize({minHeight:$r('app.float.wh_value_20')})
                  .checked(item.getFileName() === this.checkedRadioName ? true : false)
                  .onClick((event: ClickEvent) => {
                    LogUtil.showInfo(TAG, `classic vibrate radio click title: ${item.getTitle()}`);
                    this.onClickRadio(item);
                  });
              }
            }
            .padding({ top: FontScaleUtils.getSafetyPadding(), bottom: FontScaleUtils.getSafetyPadding() })
            .constraintSize({
              minHeight: '48vp',
            })
            .width('100%')
            .alignItems(VerticalAlign.Center)

            if (index !== (this.toneHapticsAttrsArray.length - 1)) {
              Divider()
                .strokeWidth('1px')
                .color($r('sys.color.comp_divider'))
                .lineCap(LineCapStyle.Square)
                .width('100%')
            }
          }
          .padding({ start: PADDING_8, end: PADDING_8})
          .borderRadius($r('sys.float.corner_radius_level8'))
          .onClick((event: ClickEvent) => {
            LogUtil.showInfo(TAG, `classic vibrate radio click title: ${item.getTitle()}`);
            this.onClickRadio(item);
          })
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .accessibilitySelected(this.checkedRadioName === item.getFileName())
          .accessibilityDescription(this.checkedRadioName === item.getFileName() ? ' ' : '')
        }
      })
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ bottom: PADDING_12})
    .padding({ top: PADDING_4, bottom: PADDING_4, start: PADDING_4, end: PADDING_4})
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  /**
   * 无振动
   */
  @Builder NotVibrate() {
    Column() {
      Row() {
        Text($r('app.string.not_vibrate'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
        Blank()
        if (RadioName.NOT_VIBRATE === this.checkedRadioName) {
          Radio({ value: RadioName.NOT_VIBRATE, group: 'vibrateRadioGroup' })
            .radioStyle({
              checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
            })
            .accessibilityLevel('no')
            .margin({end: PADDING_4})
            .width($r('app.float.wh_value_20'))
            .constraintSize({minHeight:$r('app.float.wh_value_20')})
            .checked(RadioName.NOT_VIBRATE === this.checkedRadioName ? true : false)
            .onClick((event: ClickEvent) => {
              LogUtil.showInfo(TAG, `not vibrate radio click title: ${this.checkedRadioName}`);
              this.onClickNotVibrateRadio(RadioName.NOT_VIBRATE);
            });
        }
      }
      .width('calc(100%)')
      .constraintSize({
        minHeight: '48vp',
      })
      .padding({
        top: FontScaleUtils.getSafetyPadding(),
        bottom: FontScaleUtils.getSafetyPadding(),
        start: PADDING_8,
        end: PADDING_8
      })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .alignItems(VerticalAlign.Center)
      .onClick((event: ClickEvent) => {
        LogUtil.showInfo(TAG, `not vibrate radio click title: ${this.checkedRadioName}`);
        this.onClickNotVibrateRadio(RadioName.NOT_VIBRATE);
      })
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .accessibilitySelected(this.checkedRadioName === RadioName.NOT_VIBRATE)
      .accessibilityDescription(this.checkedRadioName === RadioName.NOT_VIBRATE ? ' ' : '')
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ bottom: PADDING_12})
    .padding({ top: PADDING_4, bottom: PADDING_4, start: PADDING_4, end: PADDING_4})
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        Stack({ alignContent: Alignment.Top }) {
          Scroll(this.scroller) {
            Column() {
              this.VibrateSynchronizeWithRingtoneBuilder();
              if (!(this.audioRingMode === audio.AudioRingMode.RINGER_MODE_VIBRATE &&
                this.toneType === ToneType.RINGTONE)) {
                this.NotVibrate();
              }
              this.ClassicVibrateBuilder();
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .align(Alignment.Top)
          .padding({
            start: DeviceUtil.isDevicePad() ? PADDING_24 : PADDING_16,
            end: DeviceUtil.isDevicePad() ? PADDING_24 : PADDING_16,
          })
          .borderRadius($r('sys.float.corner_radius_level10'))
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .justifyContent(FlexAlign.Start)
      .height('100%')
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      this.pathInfos.pop();
      return true;
    })
  }

  aboutToAppear(): void {
    let vibrateParam: VibrateParam = this.params?.config as VibrateParam;
    if (!vibrateParam) {
      LogUtil.showError(TAG, 'aboutToAppear invalid vibrateParam');
      return;
    }
    LogUtil.showInfo(TAG, `aboutToAppear, receive vibrateParam, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType}
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}`);
    this.initVibrateData();
    this.initSystemSoundManagerInstance();
    this.initToneHapticsList();
    this.initHapticsAttrsSyncedWithTone();
    EventBus.getInstance().on(EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED, this.onBundleAudioRingModeChangedCallback);
    // 页面进入entry打点
    if (vibrateParam.toneType === 'phone') {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVibrationGroup.ENTER_RINGTONE_VIBRATION_ENTRY);
    } else if (vibrateParam.toneType === 'message') {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVibrationGroup.ENTER_SMS_RINGTONE_VIBRATE_ENTRY);
    } else if (vibrateParam.toneType === 'notification') {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVibrationGroup.ENTER_NOTIFY_RINGTONE_VIBRATE);
    } else {
      return;
    }
  }

  onPageShow(): void {
    LogUtil.showInfo(TAG, `onPageShow`);
  }

  async onPageHide(): Promise<void> {
    LogUtil.showInfo(TAG, `onPageHide`);
    try {
      await vibrator.stopVibration();
      LogUtil.showInfo(TAG, `onPageHide, stopVibration success`);
    } catch (err) {
      LogUtil.showError(TAG, `onPageHide, stopVibration failed, error: ${err}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.toneHapticsAttrsArray.splice(0, this.toneHapticsAttrsArray.length);
    LogUtil.showInfo(TAG, `toneHapticsAttrsArray length: ${this.toneHapticsAttrsArray.length}`);
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_AUDIO_RING_MODE_CHANGED, this.onBundleAudioRingModeChangedCallback);
  }

  private initSystemSoundManagerInstance(): void {
    try {
      this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
      LogUtil.showInfo(TAG, ` systemSoundManagerInstance success`);
    } catch (err) {
      LogUtil.showError(TAG, `systemSoundManagerInstance errorCode ${err?.code} errorMessage ${err?.message}`);
    }
  }

  /**
   * 初始化经典振动的ToneHaptics
   */
  private initToneHapticsList(): void {
    LogUtil.showInfo(TAG, `initToneHapticsList`);
    let context: common.BaseContext = getContext(this);
    this.systemSoundManagerInstance?.getToneHapticsList(context, false)
      .then((value: systemSoundManager.ToneHapticsAttrsArray) => {
      this.toneHapticsAttrsArray = this.toneHapticsAttrsArray.concat(value);
      LogUtil.showInfo(TAG, `initToneHapticsList, toneHapticsAttrsArray length: ${this.toneHapticsAttrsArray.length}`);
      let collator = new intl.Collator();
      this.toneHapticsAttrsArray.sort((a, b) => collator.compare(a.getFileName(), b.getFileName()));
    }).catch ((err: BusinessError) => {
      LogUtil.showInfo(TAG, `initToneHapticsList, Failed to get the attribute list of tone haptics ${err}`);
    });
  }

  /**
   * 初始化与铃声同步的ToneHaptics
   *
   * @returns
   */
  private async initHapticsAttrsSyncedWithTone(): Promise<void> {
    let vibrateParam: VibrateParam = this.params?.config as VibrateParam;
    let context: common.BaseContext = getContext(this);
    if (vibrateParam.isSystemRingTone) {
      try {
        let ringtoneUri: string | undefined = '';
        if (vibrateParam.toneType === ToneType.RINGTONE) { // 来电铃声
          ringtoneUri = await this.systemSoundManagerInstance?.getRingtoneUri(context
            , VibrateUtil.toneHapticsTypeToToneType(vibrateParam.toneHapticsType) as systemSoundManager.RingtoneType);
        } else if (vibrateParam.toneType === ToneType.MESSAGE_TONE) { // 信息铃声
          ringtoneUri = await this.systemSoundManagerInstance?.getSystemToneUri(context
            , VibrateUtil.toneHapticsTypeToToneType(vibrateParam.toneHapticsType) as systemSoundManager.SystemToneType);
        } else if (vibrateParam.toneType === ToneType.NOTIFICATION_TONE) { // 通知铃声
          ringtoneUri = await this.systemSoundManagerInstance?.getSystemToneUri(context
            , VibrateUtil.toneHapticsTypeToToneType(vibrateParam.toneHapticsType) as systemSoundManager.SystemToneType);
        }
        this.syncDefaultToneHapticsAttrs = await this.systemSoundManagerInstance?.getHapticsAttrsSyncedWithTone(context
          , ringtoneUri);
        LogUtil.showInfo(TAG, `initHapticsAttrsSyncedWithTone, success, toneType: ${vibrateParam.toneType}, toneHapticsType: ${vibrateParam.toneHapticsType}, syncDefaultToneHapticsAttrs uri: ${this.syncDefaultToneHapticsAttrs?.getUri()}`);
      } catch (err) {
        LogUtil.showError(TAG, `initHapticsAttrsSyncedWithTone, failed, error: ${err}`);
      }
    }
  }

  /**
   * 设置振动铃声配置
   *
   * @param toneHapticsSettings
   * @returns
   */
  private async setVibrateSettings(toneHapticsSettings: MyToneHapticsSettings): Promise<void> {
    let context: common.Context = getContext(this);
    let vibrateParam: VibrateParam = this.params?.config as VibrateParam;
    let toneHapticsType: systemSoundManager.ToneHapticsType | undefined = vibrateParam?.toneHapticsType;
    LogUtil.showInfo(TAG, `set vibrate settings, hapticsUri: ${toneHapticsSettings?.hapticsUri}, mode: ${toneHapticsSettings?.mode}, toneHapticsType: ${toneHapticsType}`);
    try {
      await this.systemSoundManagerInstance?.setToneHapticsSettings(context, toneHapticsType, toneHapticsSettings);
      HiSysEventUtil.reportChoseVibtateBehaviorEventByUE(vibrateParam?.checkedVibrateRadioName, toneHapticsType);
    } catch (err) {
      LogUtil.showError(TAG, `failed to set vibrate settings err:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 点击与铃声同步的按钮
   *
   * @returns
   */
  private async onClickVibrateSynchronizeWithRingtoneRadio(checkedRadioName: string): Promise<void> {
    this.checkedRadioName = checkedRadioName;
    let toneHapticsSettings: MyToneHapticsSettings = new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.SYNC
      , this.syncDefaultToneHapticsAttrs?.getUri());
    await this.setVibrateSettings(toneHapticsSettings);
    await this.updateVibrateData(checkedRadioName, toneHapticsSettings);
    try {
      await vibrator.stopVibration();
      LogUtil.showInfo(TAG, `onClickVibrateSynchronizeWithRingtoneRadio, stopVibration success`);
    } catch (err) {
      LogUtil.showError(TAG, `onClickVibrateSynchronizeWithRingtoneRadio, stopVibration failed, error: ${err}`);
    }
    let context: common.BaseContext = getContext(this);
    if (this.systemSoundManagerInstance && this.params && this.syncDefaultToneHapticsAttrs) {
      await VibrateUtil.previewHaptics(this.systemSoundManagerInstance, context
        , (this.params.config as VibrateParam).toneType, this.syncDefaultToneHapticsAttrs.getUri());
    }
  }

  /**
   * 点击经典振动的按钮
   *
   * @param toneHapticsAttrs
   * @returns
   */
  private async onClickRadio(toneHapticsAttrs: systemSoundManager.ToneHapticsAttrs): Promise<void> {
    this.checkedRadioName = toneHapticsAttrs.getFileName();
    let toneHapticsSettings: MyToneHapticsSettings = new MyToneHapticsSettings(
      systemSoundManager.ToneHapticsMode.NON_SYNC, toneHapticsAttrs.getUri());
    await this.setVibrateSettings(toneHapticsSettings);
    await this.updateVibrateData(toneHapticsAttrs.getFileName(), toneHapticsSettings);
    LogUtil.showInfo(TAG, `onClickRadio, before stopVibration`);
    try {
      await vibrator.stopVibration();
      LogUtil.showInfo(TAG, `onClickRadio, stopVibration success`);
    } catch (err) {
      LogUtil.showError(TAG, `onClickRadio, stopVibration failed, error: ${err}`);
    }
    let context: common.BaseContext = getContext(this);
    if (this.systemSoundManagerInstance && this.params) {
      LogUtil.showInfo(TAG, `onClickRadio, before previewHaptics`);
      await VibrateUtil.previewHaptics(this.systemSoundManagerInstance, context
        , (this.params.config as VibrateParam).toneType, toneHapticsAttrs.getUri());
    }
  }

  /**
   * 点击无振动的按钮
   *
   * @returns
   */
  private async onClickNotVibrateRadio(checkedRadioName: string): Promise<void> {
    this.checkedRadioName = checkedRadioName;
    let toneHapticsSettings: MyToneHapticsSettings = new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.NONE);
    await this.setVibrateSettings(toneHapticsSettings);
    await this.updateVibrateData(checkedRadioName, toneHapticsSettings);
    try {
      await vibrator.stopVibration();
      LogUtil.showInfo(TAG, `onClickNotVibrateRadio, stopVibration success`);
    } catch (err) {
      LogUtil.showError(TAG, `onClickNotVibrateRadio, stopVibration failed, error: ${err}`);
    }
  }

  /**
   * 初始化振动页面数据
   */
  private initVibrateData(): void {
    let vibrateParam = this.params?.config as VibrateParam;
    this.checkedRadioName = vibrateParam.checkedVibrateRadioName;
    this.audioRingMode = VolumeAdapter.getInstance().getRingerMode();
    this.isSystemRingTone = vibrateParam.isSystemRingTone;
    this.defaultVibrateRadioName = vibrateParam.defaultVibrateRadioName;
    this.toneType = vibrateParam.toneType;
  }

  /**
   * 更新振动页面数据
   *
   * @param checkedRadioName
   * @param toneHapticsSettings
   * @returns
   */
  private async updateVibrateData(checkedRadioName: string, toneHapticsSettings: MyToneHapticsSettings): Promise<void> {
    let vibrateParam: VibrateParam = this.params?.config as VibrateParam;
    if (!vibrateParam) {
      LogUtil.showError(TAG, 'updateVibrateData invalid vibrateParam');
      return;
    }
    vibrateParam.checkedVibrateRadioName = checkedRadioName;
    if (vibrateParam.isSystemRingTone) {
      vibrateParam.isUseDefault = this.checkedRadioName === RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE;
    } else {
      vibrateParam.isUseDefault = false;
    }
    vibrateParam.toneHapticsSettings = toneHapticsSettings;
    let audioRingMode: number = VolumeAdapter.getInstance().getRingerMode();
    let vibrateParamKey: string =
      VibrateUtil.getVibrateParamKey(vibrateParam.toneType, vibrateParam.toneHapticsType, audioRingMode);
    await PreferencesUtil.put(vibrateParamKey, vibrateParam);
    LogUtil.showInfo(TAG,
      `updateVibrateData, vibrateParamKey: ${vibrateParamKey}, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType}
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}`);
  }

  private onBundleAudioRingModeChangedCallback: (isChanged: boolean) => void = (isChanged: boolean) => {
    LogUtil.showInfo(TAG, `onBundleAudioRingModeChangedCallback changed: ${isChanged}`);
    if (!isChanged) {
      return;
    }
    let vibrateParam: VibrateParam = this.params?.config as VibrateParam;
    if (!vibrateParam) {
      LogUtil.showError(TAG, 'onBundleAudioRingModeChangedCallback invalid vibrateParam');
      return;
    }
    let audioRingMode: number = VolumeAdapter.getInstance().getRingerMode();
    let vibrateParamKey: string =
      VibrateUtil.getVibrateParamKey(vibrateParam.toneType, vibrateParam.toneHapticsType, audioRingMode);
    this.params!.config = VibrateUtil.getVibrateParamInMemory(vibrateParamKey, vibrateParam);
    this.initVibrateData();
    this.initHapticsAttrsSyncedWithTone();
    LogUtil.showInfo(TAG,
      `onBundleAudioRingModeChangedCallback, vibrateParamKey: ${vibrateParamKey}, toneType: ${vibrateParam.toneType}, isUseDefault: ${vibrateParam.isUseDefault}, isSystemRingTone: ${vibrateParam.isSystemRingTone}, toneHapticsType: ${vibrateParam.toneHapticsType}
    , mode: ${vibrateParam.toneHapticsSettings.mode}, hapticsUri: ${vibrateParam.toneHapticsSettings.hapticsUri}, checkedVibrateRadioName: ${vibrateParam.checkedVibrateRadioName}, defaultVibrateRadioName: ${vibrateParam.defaultVibrateRadioName}, checkedRadioName: ${this.checkedRadioName}`);
  };
}