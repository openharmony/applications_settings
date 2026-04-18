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

import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { VpnEditComponent } from '@ohos/settings.vpn/src/main/ets/VpnEditComponent';

@Builder
export function VpnEditLoader($$: Params): void {
  VpnEditComponent({ params: $$ as Object as PushParam });
}