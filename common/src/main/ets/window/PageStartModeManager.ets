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

import { PageStartReason } from '../data/types';

export class PageStartModeManager {
  private static instance: PageStartModeManager;
  private startReason: PageStartReason = PageStartReason.DEFAULT;

  public static getInstance(): PageStartModeManager {
    if (PageStartModeManager.instance == null) {
      PageStartModeManager.instance = new PageStartModeManager();
    }
    return PageStartModeManager.instance;
  }

  public setStartReason(startReason: PageStartReason): void {
    this.startReason = startReason;
  }

  public getStartReason(): PageStartReason {
    return this.startReason;
  }
}
