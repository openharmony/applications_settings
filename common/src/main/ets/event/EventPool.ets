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

import { LogUtil } from '../utils/LogUtil';

const TAG: string = 'EventPipeline: ';

/**
 * 创建凭证
 */
export const CREATE_USER_CREDENTIAL: string = 'create_user_credential';

/**
 * 更新凭证
 */
export const UPDATE_USER_CREDENTIAL: string = 'update_user_credential';

/**
 * 拉起创建密码弹窗
 */
export const OPEN_CREATE_PASSWORD_DIALOG: string = 'open_create_password_dialog';

/**
 * 事件池
 *
 * @since 2023-08-26
 */
export class EventPool {
  /**
   * 事件池
   */
  private eventPool: Event[] = [];

  /**
   * 单例方法
   *
   * @returns 单例对象
   */
  public static getInstance(): EventPool {
    if (!AppStorage.has(TAG)) {
      AppStorage.setOrCreate(TAG, new EventPool());
      LogUtil.info(`${TAG} create EnrollManager.`);
    }
    return AppStorage.get<EventPool>(TAG) as EventPool;
  }

  /**
   * 发布事件
   *
   * @param event 事件实体
   */
  public async publish(event: Event): Promise<void> {
    LogUtil.info(`${TAG}publish event`);
    let isNewEvent: boolean = true;
    for (let index = 0; index < this.eventPool.length; index++) {
      if (this.eventPool[index].name === event.name) {
        LogUtil.info(`${TAG}event already exist, replace it.`);
        this.eventPool[index] = event;
        isNewEvent = false;
        break;
      }
    }
    if (isNewEvent) {
      LogUtil.info(`${TAG}add new event.`);
      this.eventPool.push(event);
    }
  }

  /**
   * 消费事件
   *
   * @param name 事件名称
   * @returns
   */
  public async consume(name: string): Promise<Event | null> {
    LogUtil.info(`${TAG}consume event=${name}`);
    let target: Event | null = null;
    for (let index = 0; index < this.eventPool.length; index++) {
      if (this.eventPool[index].name === name) {
        LogUtil.info(`${TAG}find event`);
        target = {
          name: this.eventPool[index].name,
          param: this.eventPool[index].param,
        }
        this.eventPool.splice(index, 1);
        break;
      }
    }
    return target;
  }
}

/**
 * 事件定义
 *
 * 2023-08-26
 */
export class Event {
  /**
   * 事件名称
   */
  public name: string = '';
  /**
   * 事件参数
   */
  public param?: string;
}