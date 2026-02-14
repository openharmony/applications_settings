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

import { SwiperItem } from './SwiperItem';
/* instrument ignore file */
const TAG = 'SwiperDataMgr';

export class SwiperDataMgr {
  private static instance: SwiperDataMgr;

  private constructor() {
  }

  public static getInstance(): SwiperDataMgr {
    if (!SwiperDataMgr.instance) {
      SwiperDataMgr.instance = new SwiperDataMgr();
    }
    return SwiperDataMgr.instance;
  }

  private swiperItems: SwiperItem[] = [{
    loadCount: 0,
    index: 0,
    name: 'gesture_navigation_back.json',
    function: $r('app.string.Ai_bar_back'),
    detail: $r('app.string.Ai_bar_gesture_back_detail'),
    isPlaying: false
  }, {
    loadCount: 0,
    index: 1,
    name: 'gesture_navigation_desk.json',
    function: $r('app.string.Ai_bar_return_home'),
    detail: $r('app.string.Ai_bar_return_home_detail'),
    isPlaying: false
  }, {
    loadCount: 0,
    index: 2,
    name: 'gesture_navigation_open_muti_tasks.json',
    function: $r('app.string.Ai_bar_recent'),
    detail: $r('app.string.Ai_bar_recent_detail'),
    isPlaying: false
  }];

  public getSwiperItems(): SwiperItem[] {
    return this.swiperItems;
  }
}

export const swiperDataMgr = SwiperDataMgr.getInstance();