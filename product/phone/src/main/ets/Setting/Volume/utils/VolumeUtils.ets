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
import audio from '@ohos.multimedia.audio';
import taskpool from '@ohos.taskpool';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AUDIO_VOLUME_TYPE_MEDIA, RINGER_MODE_NORMAL, VolumeAdapter } from '../controller/VolumeAdapter';
import { ToneAttrs, VolumeParams } from '../model/VolumeType';
import {
  RingtoneType,
  SimRingtoneKey,
  DEFAULT_NO_RINGTONE_URI,
  DEFAULT_NO_RING_URI
} from '../constant/VolumeConstant';
import { RingtonesUtils } from './RingtonesUtils';

const TAG: string = 'VolumeUtils :';
const MEDIA_MODE_SILENT: number = 0;
const MEDIA_MODE_SMALL: number = 1;
const MEDIA_MODE_MEDIUM: number = 2;
const MEDIA_MODE_NORMAL: number = 3;
const DEFAULT_RING_TONE_DATA_KEY1 = 'defaultRingToneCard1';
const DEFAULT_RING_TONE_DATA_KEY2 = 'defaultRingToneCard2';
const DEFAULT_MESSAGE_TONE_DATA_KEY1 = 'defaultMessageTone1';
const DEFAULT_MESSAGE_TONE_DATA_KEY2 = 'defaultMessageTone2';
const DEFAULT_NOTIFICATION_TONE_DATA_KEY: string = 'defaultNotificationTone';

/**
 * small图标的档位
 */
const SMALL_SCALE: number = 3;
/**
 * medium图标的档位
 */
const MEDIUM_SCALE: number = 1.5;

export class VolumeUtils {
  static getVolumeParams(): VolumeParams {
    let volumeParams: VolumeParams = { ringMode: RINGER_MODE_NORMAL, mediaMode: 0 };
    volumeParams.ringMode = VolumeAdapter.getInstance().getRingerMode();
    let mediaVolume: number = VolumeAdapter.getInstance().getVolume(AUDIO_VOLUME_TYPE_MEDIA);
    let maxVolume: number = VolumeAdapter.getInstance().getMaxVolume(AUDIO_VOLUME_TYPE_MEDIA);
    if (mediaVolume === 0) {
      volumeParams.mediaMode = MEDIA_MODE_SILENT;
    } else if (mediaVolume > 0 && mediaVolume <= maxVolume / SMALL_SCALE) {
      volumeParams.mediaMode = MEDIA_MODE_SMALL;
    } else if (mediaVolume > maxVolume / SMALL_SCALE && mediaVolume <= maxVolume / MEDIUM_SCALE) {
      volumeParams.mediaMode = MEDIA_MODE_MEDIUM;
    } else {
      volumeParams.mediaMode = MEDIA_MODE_NORMAL;
    }
    return volumeParams;
  }

  static getRingtoneName(ringtoneValue: string): string {
    let ringtoneName = '';
    let ringtoneArr: Array<string> | string = ringtoneValue.split('/');
    let ringtoneUri: string = ringtoneArr[ringtoneArr.length - 1];
    ringtoneArr = ringtoneUri.split('.');
    ringtoneUri = ringtoneArr[0];
    ringtoneName = ringtoneUri.replace(new RegExp('_', 'g'), ' ');
    return ringtoneName;
  }

  static isAudioRunning(uid?: number) : boolean {
    let audioStreamManager: audio.AudioStreamManager = audio.getAudioManager().getStreamManager();
    if (audioStreamManager === null) {
      return false;
    }
    let rendererChangeInfoArray = audioStreamManager.getCurrentAudioRendererInfoArraySync();
    if (rendererChangeInfoArray === null) {
      return false;
    }
    for (let rendererChangeInfo of rendererChangeInfoArray) {
      if (rendererChangeInfo.rendererState === audio.AudioState.STATE_RUNNING &&
        rendererChangeInfo.clientUid !== uid) {
        return true;
      }
    }
    return false;
  }

  static getRingtoneTitleByUri(uri: string, isCardOne: boolean, ringtoneType: RingtoneType): string {
    if (uri === DEFAULT_NO_RINGTONE_URI || uri === DEFAULT_NO_RING_URI) {
      return ResourceUtil.getStringSync($r('app.string.vibrate_only'));
    }
    let ringToneDataKey1 = 'RingToneCard1';
    let ringToneDataKey2 = 'RingToneCard2';
    let messageToneDataKey = 'MessageTone';
    let notificationToneDataKey = 'NotificationTone';
    let resToneList: ToneAttrs[] = [];
    let ringtoneName = '';
    if (ringtoneType === RingtoneType.RINGTONE_TYPE_SIM) {
      resToneList = isCardOne ? PreferencesUtil.getSync(ringToneDataKey1, []) as Array<ToneAttrs> :
        PreferencesUtil.getSync(ringToneDataKey2, []) as Array<ToneAttrs>;
    } else if (ringtoneType === RingtoneType.RINGTONE_TYPE_SMS) {
      resToneList = PreferencesUtil.getSync(messageToneDataKey, []) as Array<ToneAttrs>;
    } else if (ringtoneType === RingtoneType.RINGTONE_TYPE_NOTIFICATION) {
      resToneList = PreferencesUtil.getSync(notificationToneDataKey, []) as Array<ToneAttrs>;
    }
    LogUtil.showInfo(TAG, `ringtoneType: ${ringtoneType}, resToneList length: ${resToneList.length}`);
    for (let index = 0; index < resToneList.length; index++) {
      let element = resToneList[index];
      if (element.uri === uri) {
        ringtoneName = element.title;
        break;
      }
    }
    LogUtil.info(`${TAG} getRingtoneTitleByUri: ${ringtoneName} uri: ${uri}`);
    return ringtoneName;
  }

  /*
   * 刷新铃声库
   * */
  public static async flushVolumeList(context: Context): Promise<void> {
    LogUtil.info(`${TAG} flushVolumeList`);
    let ringToneDataKey1 = 'RingToneCard1';
    let ringToneDataKey2 = 'RingToneCard2';
    let messageToneDataKey = 'MessageTone';
    let notificationToneDataKey = 'NotificationTone';
    let flushVolumeListTask: taskpool.Task = new taskpool.Task(taskFlushVolumeList, context);
    let result: ToneAttrs[][] =
      await taskpool.execute(flushVolumeListTask, taskpool.Priority.MEDIUM) as ToneAttrs[][];
    PreferencesUtil.putPreferencesData(ringToneDataKey1, result[0], context);
    PreferencesUtil.putPreferencesData(ringToneDataKey2, result[1], context);
    PreferencesUtil.putPreferencesData(messageToneDataKey, result[2], context);
    PreferencesUtil.putPreferencesData(notificationToneDataKey, result[3], context);
    LogUtil.showInfo(TAG, `result[0]: ${result[0].length}, result[1]: ${result[1].length}, result[2]: ${result[2].length}`);
  }

  /*
 * 刷新系统铃声
 * */
  public static async flushSystemRingtone(context: Context): Promise<void> {
    LogUtil.info(`${TAG} flushSystemRingtone`);
    let task: taskpool.Task = new taskpool.Task(taskFlushSystemRingtone, context);
    let result: string[] = await taskpool.execute(task, taskpool.Priority.MEDIUM) as string[];
    let simRingTone1 = VolumeUtils.getRingtoneTitleByUri(result[0], true, RingtoneType.RINGTONE_TYPE_SIM);
    let simRingTone2 = VolumeUtils.getRingtoneTitleByUri(result[1], false, RingtoneType.RINGTONE_TYPE_SIM);
    let smsRingTone1 = VolumeUtils.getRingtoneTitleByUri(result[2], true, RingtoneType.RINGTONE_TYPE_SMS);
    let smsRingTone2 = VolumeUtils.getRingtoneTitleByUri(result[3], false, RingtoneType.RINGTONE_TYPE_SMS);
    let notficationRingTone = VolumeUtils.getRingtoneTitleByUri(result[4], false, RingtoneType
      .RINGTONE_TYPE_NOTIFICATION);
    LogUtil.showInfo(TAG,
      'taskFlushSystemRingtone, value: %{public}s | %{public}s | %{public}s | %{public}s | %{public}s',
      simRingTone1, simRingTone2, smsRingTone1, smsRingTone2, notficationRingTone);
    PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_0_RINGTONE_KEY, simRingTone1, context);
    PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_1_RINGTONE_KEY, simRingTone2, context);
    PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY, smsRingTone1, context);
    PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY, smsRingTone2, context);
    PreferencesUtil.putPreferencesData(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY, notficationRingTone, context);
  }

  /**
   * 刷新默认铃声
   */
  public static async flushVolumeDefault(context: Context): Promise<void> {
    LogUtil.info(`${TAG} flushVolumeDefault`);
    let ringtoneValueTask: taskpool.Task = new taskpool.Task(taskGetDefaultToneAttrs, context);
    let result: string[] = await taskpool.execute(ringtoneValueTask, taskpool.Priority.MEDIUM) as string[];
    PreferencesUtil.putPreferencesData(DEFAULT_RING_TONE_DATA_KEY1, result[0], context);
    PreferencesUtil.putPreferencesData(DEFAULT_RING_TONE_DATA_KEY2, result[1], context);
    PreferencesUtil.putPreferencesData(DEFAULT_MESSAGE_TONE_DATA_KEY1, result[2], context);
    PreferencesUtil.putPreferencesData(DEFAULT_MESSAGE_TONE_DATA_KEY2, result[3], context);
    PreferencesUtil.putPreferencesData(DEFAULT_NOTIFICATION_TONE_DATA_KEY, result[4], context);
  }

  /**
   * 刷新默认铃声、铃声库、用户选择铃声，上下有依赖关系
   */
  public static async flushVolumeByDependsOn(context: Context): Promise<void> {
    LogUtil.info(`${TAG} flushVolumeByDependsOn`);
    let ringToneDataKey1 = 'RingToneCard1';
    let ringToneDataKey2 = 'RingToneCard2';
    let messageToneDataKey = 'MessageTone';
    let notificationToneDataKey = 'NotificationTone';
    let flushVolumeListTaskPool: taskpool.Task = new taskpool.Task(taskFlushVolumeList, context);
    let flushVolumeDefaultTaskPool: taskpool.Task = new taskpool.Task(taskGetDefaultToneAttrs, context);
    let flushVolumeUserTaskPool: taskpool.Task = new taskpool.Task(taskFlushSystemRingtone, context);
    flushVolumeUserTaskPool.addDependency(flushVolumeListTaskPool);
    flushVolumeListTaskPool.addDependency(flushVolumeDefaultTaskPool);
    // 刷新默认铃声
    taskpool.execute(flushVolumeDefaultTaskPool, taskpool.Priority.MEDIUM).then((res: Object) => {
      let result: string[] = res as string[];
      PreferencesUtil.putPreferencesData(DEFAULT_RING_TONE_DATA_KEY1, result[0], context);
      PreferencesUtil.putPreferencesData(DEFAULT_RING_TONE_DATA_KEY2, result[1], context);
      PreferencesUtil.putPreferencesData(DEFAULT_MESSAGE_TONE_DATA_KEY1, result[2], context);
      PreferencesUtil.putPreferencesData(DEFAULT_MESSAGE_TONE_DATA_KEY2, result[3], context);
      PreferencesUtil.putPreferencesData(DEFAULT_NOTIFICATION_TONE_DATA_KEY, result[4], context);
    });

    // 刷新铃声列表
    taskpool.execute(flushVolumeListTaskPool, taskpool.Priority.MEDIUM).then((res: Object) => {
      let result: ToneAttrs[][] = res as ToneAttrs[][];
      PreferencesUtil.putPreferencesData(ringToneDataKey1, result[0], context);
      PreferencesUtil.putPreferencesData(ringToneDataKey2, result[1], context);
      PreferencesUtil.putPreferencesData(messageToneDataKey, result[2], context);
      PreferencesUtil.putPreferencesData(notificationToneDataKey, result[3], context);
      LogUtil.showInfo(TAG, `flushVolumeByDependsOn result[0]: ${result[0].length}, result[1]: ${result[1].length}, result[2]: ${result[2].length}`);
    });
    // 刷新用户选择铃声
    taskpool.execute(flushVolumeUserTaskPool, taskpool.Priority.MEDIUM).then((res: Object) => {
      let result: string[] = res as string[];
      let simRingTone1 = VolumeUtils.getRingtoneTitleByUri(result[0], true, RingtoneType.RINGTONE_TYPE_SIM);
      let simRingTone2 = VolumeUtils.getRingtoneTitleByUri(result[1], false, RingtoneType.RINGTONE_TYPE_SIM);
      let smsRingTone1 = VolumeUtils.getRingtoneTitleByUri(result[2], true, RingtoneType.RINGTONE_TYPE_SMS);
      let smsRingTone2 = VolumeUtils.getRingtoneTitleByUri(result[3], false, RingtoneType.RINGTONE_TYPE_SMS);
      let notficationRingTone = VolumeUtils.getRingtoneTitleByUri(result[4], false, RingtoneType
        .RINGTONE_TYPE_NOTIFICATION);
      LogUtil.showInfo(TAG,
        'taskFlushSystemRingtone, value: %{public}s | %{public}s | %{public}s | %{public}s | %{public}s',
        simRingTone1, simRingTone2, smsRingTone1, smsRingTone2, notficationRingTone);
      PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_0_RINGTONE_KEY, simRingTone1, context);
      PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_1_RINGTONE_KEY, simRingTone2, context);
      PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_0_SMS_RINGTONE_KEY, smsRingTone1, context);
      PreferencesUtil.putPreferencesData(SimRingtoneKey.CARD_1_SMS_RINGTONE_KEY, smsRingTone2, context);
      PreferencesUtil.putPreferencesData(SimRingtoneKey.NOTIFICATION_RINGTONE_KEY, notficationRingTone, context);
    });
  }
}

@Concurrent
async function taskFlushVolumeList(context: Context): Promise<ToneAttrs[][]> {
  const TAG: string = 'VolumeUtils :';
  let result: ToneAttrs[][] = [];
  try {
    let ringToneTask1 = await RingtonesUtils.getRingerToneList(systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0,
      RingtoneType.RINGTONE_TYPE_SIM);
    result.push(ringToneTask1);
    LogUtil.info(`${TAG} RingToneCard1: ${ringToneTask1}`);
    let ringToneTask2 = await RingtonesUtils.getRingerToneList(systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1,
      RingtoneType.RINGTONE_TYPE_SIM);
    result.push(ringToneTask2);
    LogUtil.info(`${TAG} RingToneCard2: ${ringToneTask2}`);
    let messageToneTask = await RingtonesUtils.getRingerToneList(systemSoundManager
      .SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0, RingtoneType.RINGTONE_TYPE_SMS);
    result.push(messageToneTask);
    LogUtil.info(`${TAG} MessageTone: ${messageToneTask}`);
    let notificationToneTask = await RingtonesUtils.getRingerToneList(systemSoundManager
      .SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION, RingtoneType.RINGTONE_TYPE_NOTIFICATION);
    result.push(notificationToneTask);
    LogUtil.info(`${TAG} NotificationTone: ${notificationToneTask}`);
  } catch (err) {
    LogUtil.showError(TAG, `taskGetDefaultToneAttrs error, msg = ${err.message}`);
  }
  return result;
}

@Concurrent
async function taskGetDefaultToneAttrs(context: Context): Promise<string[]> {
  const TAG: string = 'VolumeUtils :';
  const SUB_LINE: string = '_';
  const CARD1: number = 0;
  const CARD2: number = 1;
  const NOTIFICATION: number = 32;
  let result: string[] = ['', '', '', '', ''];
  try {
    await import('@ohos.multimedia.systemSoundManager').then(async (systemSoundManager) => {
      const soundManager = systemSoundManager.default.getSystemSoundManager();
      let ringtoneCard1Value = await soundManager.getDefaultRingtoneAttrs(context, CARD1);
      let ringtoneCard2Value = await soundManager.getDefaultRingtoneAttrs(context, CARD2);
      let messageToneCard1Value = await soundManager.getDefaultSystemToneAttrs(context, CARD1);
      let messageToneCard2Value = await soundManager.getDefaultSystemToneAttrs(context, CARD2);
      let notificationToneValue = await soundManager.getDefaultSystemToneAttrs(context, NOTIFICATION);
      result = [ringtoneCard1Value.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' '),
        ringtoneCard2Value.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' '),
        messageToneCard1Value.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' '),
        messageToneCard2Value.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' '),
        notificationToneValue.getTitle().replace(new RegExp(SUB_LINE, 'g'), ' ')];
      LogUtil.showInfo(TAG,
        'taskGetDefaultToneAttrs, toneValues: %{public}s | %{public}s | %{public}s | %{public}s | %{public}s',
        ringtoneCard1Value.getTitle(), ringtoneCard2Value.getTitle(),
        messageToneCard1Value.getTitle(), messageToneCard2Value.getTitle(), notificationToneValue.getTitle());
    });
  } catch (err) {
    LogUtil.showError(TAG, `taskGetDefaultToneAttrs error, msg = ${err.message}`);
  }
  return result;
}

@Concurrent
async function taskFlushSystemRingtone(context: Context): Promise<string[]> {
  const TAG: string = 'VolumeUtils :';
  const CARD1: number = 0;
  const CARD2: number = 1;
  const NOTIFICATION: number = 32;
  let result: string[] = ['', '', '', '', ''];
  try {
    await import('@ohos.multimedia.systemSoundManager').then(async (systemSoundManager) => {
      const soundManager = systemSoundManager.default.getSystemSoundManager();
      let ringtoneCard1Value = await soundManager.getRingtoneUri(context, CARD1);
      let ringtoneCard2Value = await soundManager.getRingtoneUri(context, CARD2);
      let messageToneCard1Value = await soundManager.getSystemToneUri(context, CARD1);
      let messageToneCard2Value = await soundManager.getSystemToneUri(context, CARD2);
      let notificationToneValue = await soundManager.getSystemToneUri(context, NOTIFICATION);
      result =
        [ringtoneCard1Value, ringtoneCard2Value, messageToneCard1Value, messageToneCard2Value, notificationToneValue];
      LogUtil.showInfo(TAG,
        'taskFlushSystemRingtone, uri: %{public}s | %{public}s | %{public}s | %{public}s | %{public}s',
        ringtoneCard1Value, ringtoneCard2Value, messageToneCard1Value, messageToneCard2Value, notificationToneValue);
    });
  } catch (err) {
    LogUtil.showError(TAG, `get uri error, msg = ${err.message}`);
  }
  return result;
}