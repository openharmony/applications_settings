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

/**
 * 本地铃声、在线铃声、视频铃声参数
 */
export class RingtoneParam {
  // 页面类型 localMusic（本地歌曲）、onlineRingtone（在线铃声）、videoRingtone（视频铃声）
  public pageType?: PageType;

  // 铃声类型 phone, message, notification, alarm
  public toneType?: ToneType;

  // SIM卡类型：0, 1
  public card?: string;

  // 设置选中的铃声路径
  public selectedRingtonePath: string = '';

  // 设置选中的铃声名字
  public selectedRingtoneName: string = '';

  // 设置选中的铃音库名字
  public selectedLibraryRingtonePath: string = '';

  // 是否显示标题栏
  public showTitle: boolean = false;

  // 设置选中的铃声id
  public selectRingtoneContentId: string = '';

  // UI样式
  public uiStyle: string = '';

  public ringtonePath: string = '';
}

/**
 * 铃声类型枚举
 */
export enum ToneType {
  RINGTONE = 'phone',
  MESSAGE_TONE = 'message',
  NOTIFICATION_TONE = 'notification',
  INVALID_TONE = 'invalid',
}

/**
 * 页面类型枚举
 */
export enum PageType {
  LOCAL_PAGE_TYPE = 'localMusic',
  ONLINE_PAGE_TYPE = 'onlineRingtone',
  VIDEO_PAGE_TYPE = 'videoRingtone',
}

export enum ItemGroupPostion {
  TOP,
  MIDDLE,
  BOTTOM,
}