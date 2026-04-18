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
import { describe, expect, it } from '@ohos/hypium';
import {
  SystemUpdateStatusListener,
  SystemUpdateStatusListenerManager
} from '@ohos/settings.systemUpdate/src/main/ets/listener/SystemUpdateStatusListener';

class parListener implements SystemUpdateStatusListener {
  public name: string = '';
  getListenName(): string {
    if (this.name === '') {
      this.name = Math.random().toString();
    }
    return this.name;
  }
  onSystemUpdateStatusChange(): void {
    console.log('All scene update badge changed.');
  }
}

let item: SystemUpdateStatusListener = new parListener();

export default function SystemUpdateStatusListenerManagerTest() {
  let listener: SystemUpdateStatusListener =
    AppStorage.get<SystemUpdateStatusListener>('null') as SystemUpdateStatusListener;

  describe('SystemUpdateStatusListenerManagerTest', () => {
    let SystemUpdateStatus = SystemUpdateStatusListenerManager.getInstance();
    it('test_getInstance', 0, (): void => {
      let resA = SystemUpdateStatusListenerManager.getInstance();
      expect(resA === null).assertFalse();
      let resB = SystemUpdateStatusListenerManager.getInstance();
      expect(resB === null).assertFalse();
    })

    it('test_registerHwNewSystemUpdateStatusDataChange', 0, (done: Function): void => {
      try {
        (SystemUpdateStatus as object)["dataHelper"] = null;
        let resA: Object = (SystemUpdateStatus as object)['registerHwNewSystemUpdateStatusDataChange']();
        expect(resA === null).assertFalse();
      } catch(e) {
        console.log(`error:${e}`)
      } finally {
        done();
      }
    })

    it('test_unRegisterHwNewSystemUpdateStatusDataChange', 0, (): void => {
      (SystemUpdateStatus as object)["dataHelper"] = null;
      let resA: Object = (SystemUpdateStatus as object)['unRegisterHwNewSystemUpdateStatusDataChange']();
      expect(resA === null).assertFalse();
    })

    it('test_registerSystemUpdateStatusChangeListener', 0, (): void => {
      let resA = SystemUpdateStatus.registerSystemUpdateStatusChangeListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let resB = SystemUpdateStatus.registerSystemUpdateStatusChangeListener(listener);
      expect(resB === null).assertFalse();
      let arr: SystemUpdateStatusListener[] = [];
      (SystemUpdateStatus as object)["isRegisterHwNewSystemUpdateStatusDataChange"] = true;
      (SystemUpdateStatus as object)["systemUpdateStatusChangeListeners"] = arr;
      let resC = SystemUpdateStatus.registerSystemUpdateStatusChangeListener(listener);
      expect(resC === null).assertFalse();
      arr.push(item);
      arr.push(listener);
      (SystemUpdateStatus as object)["systemUpdateStatusChangeListeners"] = arr;
      (SystemUpdateStatus as object)["isRegisterHwNewSystemUpdateStatusDataChange"] = false;
      let resD = SystemUpdateStatus.registerSystemUpdateStatusChangeListener(listener);
      expect(resD === null).assertFalse();
    })

    it('test_unRegisterSystemUpdateStatusChangeListener', 0, (): void => {
      listener =
        AppStorage.get<SystemUpdateStatusListener>('null') as SystemUpdateStatusListener;
      let resA = SystemUpdateStatus.unRegisterSystemUpdateStatusChangeListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let resB = SystemUpdateStatus.unRegisterSystemUpdateStatusChangeListener(listener);
      expect(resB === null).assertFalse();
      let arr: SystemUpdateStatusListener[] = [];
      (SystemUpdateStatus as object)["isRegisterHwNewSystemUpdateStatusDataChange"] = true;
      (SystemUpdateStatus as object)["systemUpdateStatusChangeListeners"] = arr;
      let resC = SystemUpdateStatus.unRegisterSystemUpdateStatusChangeListener(listener);
      expect(resC === null).assertFalse();
      arr.push(item);
      arr.push(listener);
      (SystemUpdateStatus as object)["systemUpdateStatusChangeListeners"] = arr;
      (SystemUpdateStatus as object)["isRegisterHwNewSystemUpdateStatusDataChange"] = false;
      let resD = SystemUpdateStatus.unRegisterSystemUpdateStatusChangeListener(listener);
      expect(resD === null).assertFalse();
    })

  });
}


