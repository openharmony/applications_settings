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

/* instrument ignore file */
import { LogHelper } from '@ohos/settings.common/src/main/ets/framework/common/LogHelper';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { UserUtil } from '../utils/UserUtil';

const TAG: string = 'EventReporter';

/**
 * 用户模块事件打点
 */
export class UserEventReporter {
  protected eventNameParam: string;
  protected nameParam: string | undefined;
  protected valueParam: string = '';

  /**
   * 根据 eventName 创建一个 UserEventReporter 对象
   * @param eventName
   * @returns
   */
  public static eventName(eventName?: string): UserEventReporter {
    const reporter: UserEventReporter = new UserEventReporter(eventName);
    return reporter;
  }

  constructor(eventName?: string) {
    this.eventNameParam = eventName || '';
  }

  /**
   * nameParam 赋值
   * @param name
   * @returns
   */
  public name(name: string): UserEventReporter {
    this.nameParam = name;
    return this;
  }

  /**
   * valueParam 赋值
   * @param value
   * @returns
   */
  public value(value: string): UserEventReporter {
    this.valueParam = value;
    return this;
  }

  /**
   * 上报打点信息
   * @param type 默认值 fault；打点类型，分为 入口（entry），行为（behavior），故障（fault）
   * @returns
   */
  public async report(type: 'entry' | 'behavior' | 'fault' = 'fault'): Promise<void> {
    const currentUserId = await UserUtil.getCurrentUserId();
    this.nameParam = this.nameParam || '';
    this.valueParam = `userId: ${currentUserId}. ${this.valueParam}`;
    LogHelper.info(TAG,
      `report type: ${type}, event: ${this.eventNameParam}, name ${this.nameParam}, value: ${this.valueParam}`);
    if (type === 'entry') {
      HiSysEventUtil.reportEntryEvent(this.nameParam, this.valueParam);
    } else if (type === 'behavior') {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(this.eventNameParam, this.valueParam);
    } else {
      HiSysEventUtil.reportDefaultFaultEvent(this.eventNameParam, this.nameParam, this.valueParam);
    }
  }
}

/**
 * 用户模块企业用户相关事件打点
 */
export class DomainUserEventReporter extends UserEventReporter {
  protected static serverTypeParam: string | undefined;

  /**
   * serverTypeParam 赋值
   * @param serverType
   * @returns
   */
  public static serverType(serverType: string): void {
    DomainUserEventReporter.serverTypeParam = serverType;
  }

  /**
   * eventNameParam 赋值
   * @param eventName
   * @returns
   */
  public static eventName(eventName: string): DomainUserEventReporter {
    const reporter: DomainUserEventReporter = new DomainUserEventReporter(eventName);
    return reporter;
  }

  constructor(eventName: string) {
    super(eventName);
  }

  /**
   * nameParam 赋值
   * @param name
   * @returns
   */
  public name(name: string): DomainUserEventReporter {
    if (DomainUserEventReporter.serverTypeParam) {
      this.nameParam = `${DomainUserEventReporter.serverTypeParam}_${name}`;
    } else {
      this.nameParam = name;
    }
    return this;
  }

  /**
   * valueParam 赋值
   * @param value
   * @returns
   */
  public value(value: string): DomainUserEventReporter {
    super.value(value);
    return this;
  }
}