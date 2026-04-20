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
import { describe, it, expect } from '@ohos/hypium'
import { EventPool, Event } from '@ohos/settings.common/src/main/ets/event/EventPool'

export default function EventPoolTest() {
  describe('EventPoolTest', () => {
    it('EventPoolTest_001', 0, () => {
      let eventP: EventPool = EventPool.getInstance();
      let eventP1: EventPool = EventPool.getInstance();
      expect(eventP == eventP1).assertTrue();
    })
    it('EventPoolTest_002', 0, async (done: Function) => {
      let eventP: EventPool = EventPool.getInstance();
      let event: Event = {
        name: 'test'
      };
      let event1: Event = {
        name: 'test01'
      };
      await eventP.publish(event);
      await eventP.publish(event);
      await eventP.publish(event1);
      expect(eventP != null).assertTrue();
      done();
    })
    it('EventPoolTest_003', 0, async (done: Function) => {
      let eventP: EventPool = EventPool.getInstance();
      let event: Event = {
        name: 'test'
      };
      let event1: Event = {
        name: 'test01'
      };
      (eventP as object)['eventPool'] = [event, event1];
      await eventP.consume('test');
      await eventP.consume('test02');
      expect(eventP != null).assertTrue();
      done();
    })
  })
}