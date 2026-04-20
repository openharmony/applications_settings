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
import hilog from '@ohos.hilog';

/**
 * 日志打印工具类
 */
export class Log {
  private domain: number;
  private preTag: string;
  private format: string = '%{public}s';
  private space: string = ' ';

  constructor() {
    this.preTag = 'Private_Pin';
    this.domain = 0x00FF;
  }

  debug(tag: string, logInfo: string): void {
    hilog.debug(this.domain, this.preTag, this.format, tag + ': ' + this.space + logInfo);
  }

  info(tag: string, logInfo: string): void {
    hilog.info(this.domain, this.preTag, this.format, tag + ': ' + this.space + logInfo);
  }

  warn(tag: string, logInfo: string): void {
    hilog.warn(this.domain, this.preTag, this.format, tag + ': ' + this.space + logInfo);
  }

  error(tag: string, logInfo: string): void {
    hilog.error(this.domain, this.preTag, this.format, tag + ': ' + this.space + logInfo);
  }
}

export default new Log();