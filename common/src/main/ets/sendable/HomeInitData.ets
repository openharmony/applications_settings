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

@Sendable
export class HomeInitData {
  public deviceName: string | undefined = undefined;
  public wifiState: boolean | undefined = undefined;
  public bluetoothState: boolean = false;
  public fusionState: number = 0;
  public hiWriteState: string | undefined = undefined;
  public isMainAccount: boolean | undefined = undefined;
  public supportMeetTime: boolean | undefined = undefined;
  public supportVassistant: boolean | undefined = undefined;
  public supportHiWrite: boolean | undefined = undefined;
}

export let homeInitData = new HomeInitData();