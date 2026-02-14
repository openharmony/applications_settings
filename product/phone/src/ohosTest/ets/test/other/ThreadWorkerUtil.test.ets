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
  MockKit,
  ArgumentMatchers,
  when
} from '@ohos/hypium';
import { ThreadWorkerUtil } from '@ohos/settings.common/src/main/ets/utils/ThreadWorkerUtil';
import worker, { Event, WorkerEventListener } from '@ohos.worker';
import { FileValidator } from '@ohos/settings.common/src/main/ets/utils/Validator';

export default function threadWorkerUtilTest() {
  describe('threadWorkerUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('ThreadWorkerUtilTest_createWorker_success', 0, () => {
      let worker: worker.ThreadWorker | null = ThreadWorkerUtil.createWorker('worker/exampleWorker.ts');
      expect(worker).assertNull();
    })
    it('ThreadWorkerUtilTest_createWorker_failed', 0, () => {
      let worker: worker.ThreadWorker | null = ThreadWorkerUtil.createWorker('');
      expect(worker).assertNull();
    })
    it('ThreadWorkerUtilTest_001', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(FileValidator, FileValidator.validateWorkerFile);
      when(mockFun)(ArgumentMatchers.any).afterReturn(true);
      let re = ThreadWorkerUtil.createWorker('test')
      expect(re == null).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn(false);
      re = ThreadWorkerUtil.createWorker('test')
      expect(re == null).assertTrue();
      mocker.clear(FileValidator);
    })
    it('ThreadWorkerUtilTest_002', 0, () => {
      let worker: worker.ThreadWorker = {
        postMessage: () => {
          throw new Error('Function not implemented.');
        },
        postMessageWithSharedSendable: (message: Object, transfer?: ArrayBuffer[] | undefined): void => {
          throw new Error('Function not implemented.');
        },
        on: (type: string, listener: WorkerEventListener): void => {
          throw new Error('Function not implemented.');
        },
        once: (type: string, listener: WorkerEventListener): void => {
          throw new Error('Function not implemented.');
        },
        off: (type: string, listener?: WorkerEventListener | undefined): void => {
          throw new Error('Function not implemented.');
        },
        terminate: (): void => {
          throw new Error('Function not implemented.');
        },
        addEventListener: (type: string, listener: WorkerEventListener): void => {
          throw new Error('Function not implemented.');
        },
        dispatchEvent: (event: Event): boolean => {
          throw new Error('Function not implemented.');
        },
        removeEventListener: (type: string, callback?: WorkerEventListener | undefined): void => {
          throw new Error('Function not implemented.');
        },
        removeAllListener: (): void => {
          throw new Error('Function not implemented.');
        },
        registerGlobalCallObject: (instanceName: string, globalCallObject: Object): void => {
          throw new Error('Function not implemented.');
        },
        unregisterGlobalCallObject: (instanceName?: string | undefined): void => {
          throw new Error('Function not implemented.');
        }
      };
      ThreadWorkerUtil.terminateWorker(worker)
      let worker1: worker.ThreadWorker =
        AppStorage.get<worker.ThreadWorker>('worker1') as worker.ThreadWorker;
      ThreadWorkerUtil.terminateWorker(worker1);
      expect(worker != null).assertTrue();
    })
  })
}

