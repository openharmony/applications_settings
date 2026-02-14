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

import { TaskKey } from '@ohos/settings.powersave/src/main/ets/PowerSaveTaskManager';

/* instrument ignore file */
export const SUPPORTED_TASK_KEYS: string[] = [
  TaskKey.SHUT_DOWN_APP,
  TaskKey.REFRESH_RATE,
  TaskKey.DISABLE_HOTSPOT,
  TaskKey.SCREEN_OFF_TIME_OUT,
  TaskKey.AOD_DISPLAY_TYPE,
  TaskKey.NOTIFICATION_WHEN_SLEEP,
  TaskKey.AUTO_SCREEN_ON_WITH_NOTIFICATION];