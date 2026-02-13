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
import {
  afterAll,
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  Level
} from '@ohos/hypium';
import { DisableItemService, PreferencesUtil } from '../../../..';
import { CallMessage } from '../../../main/ets/stub/BaseServiceStub';

export default function disableItemServiceTest() {
  describe('disableItemServiceTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('disableItemService', Level.LEVEL0, (): void => {
      let message: CallMessage = {
        'method': 'disableMenu',
      };
      let jsonObject:Record<string, boolean> = {};
      jsonObject['wifi_entry'] = true;
      message.extra = jsonObject;
      let disableMenuService: DisableItemService = new DisableItemService();
      disableMenuService.disableItemService(message);
      expect(PreferencesUtil.getSync('wifi_entry', false) !== null).assertTrue();
    })

    it('disableUriParam', Level.LEVEL0, (): void => {
      let message: CallMessage = {
        'method': 'disableUriParam',
      };
      let uriParam: Record<string, Record<string, boolean>> = {};
      message.extra = uriParam;
      let disableMenuService: DisableItemService = new DisableItemService();
      disableMenuService.disableUriParam(message);
      expect(PreferencesUtil.getSync('parent_control_time', false) !== null).assertTrue();
    })
  })
}