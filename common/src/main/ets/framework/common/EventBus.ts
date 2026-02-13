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

import HashMap from '@ohos.util.HashMap';
import { LogHelper } from './LogHelper';

export type EventCb = (...args: any[]) => void;

type Listener = {
  callback: EventCb;
  triggerCnt?: number;
};

const TAG: string = 'EventBus';

export class EventBus {
  private static instance: EventBus;
  private listenerMap: HashMap<string, Listener[]> = new HashMap();

  private constructor() {
  }

  public static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus();
    }
    return EventBus.instance;
  }

  public on(eventName: string, callback: EventCb): void {
    this.registerListener(eventName, callback);
  }

  public once(eventName: string, callback: EventCb): void {
    this.registerListener(eventName, callback, 1);
  }

  public exactly(eventName: string, callback: EventCb, capacity: number): void {
    this.registerListener(eventName, callback, capacity);
  }

  public off(eventName: string): void {
    this.die(eventName);
  }

  public detach(eventName: string, callback: EventCb): void {
    let listeners = this.listenerMap.get(eventName) ?? [];

    listeners = listeners.filter((value) => {
      return value.callback !== callback;
    });

    if (listeners.length === 0) {
      this.die(eventName);
      return;
    }

    this.listenerMap.set(eventName, listeners);
  }

  public emit(eventName: string, ...args: any): boolean {
    let listeners: Listener[] = [];

    if (this.hasListeners(eventName)) {
      listeners = this.listenerMap.get(eventName);
    }

    if (listeners.length === 0) {
      LogHelper.info(TAG, `event ${eventName} has no subscribers`);
      return false;
    }

    listeners.forEach((listener, k) => {
      if (listener.callback) {
        listener.callback(...args);
      }

      if (listener.triggerCnt !== undefined) {
        listener.triggerCnt--;
        listeners[k].triggerCnt = listener.triggerCnt;
      }
      if (this.checkToRemoveListener(listener)) {
        this.listenerMap.get(eventName)?.splice(k, 1);
      }
    });
    return true;
  }

  private registerListener(eventName: string, cb: EventCb, triggerCnt?: number): void {
    if (!this.hasListeners(eventName)) {
      this.listenerMap.set(eventName, []);
    }

    this.listenerMap.get(eventName).push({ callback: cb, triggerCnt: triggerCnt });
  }

  private die(eventName: string): void {
    this.listenerMap.remove(eventName);
  }

  private checkToRemoveListener(eventInformation: Listener): boolean {
    if (eventInformation.triggerCnt !== undefined) {
      return eventInformation.triggerCnt <= 0;
    }
    return false;
  }

  private hasListeners(eventName: string): boolean {
    return this.listenerMap.hasKey(eventName);
  }
}