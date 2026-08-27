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
import collections from '@arkts.collections';

@Sendable
export class A11yInitData {
  public invertColorState: boolean | undefined = undefined;
  public highContrastTextState: boolean | undefined = undefined;
  public audioMonoState: boolean | undefined = undefined;
  public audioBalanceState: number | undefined = undefined;
  public shortkeyState: boolean | undefined = undefined;
  public shortkeyMultiTargets: collections.Array<string> = new collections.Array<string>();
  public daltonizationState: boolean | undefined = undefined;
  public ignoreRepeatClick: boolean | undefined = undefined;
  public elderCareSwitch: boolean | undefined = undefined;
  public simpleUiModeSwitch: boolean | undefined = undefined;
  public animationOffState: boolean | undefined = undefined;
}

export let a11yInitData = new A11yInitData();