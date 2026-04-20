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

export class FileValidator {

  /**
   * 校验worker文件名是否满足要求
   */
  public static readonly validWorkerFileName: string = '^[A-Za-z]+[\w]*.ts$';

  /**
   * 校验文件是否可以作为worker.ts文件
   * @param fileName: worker文件名称
   *
   * @return boolean: 校验通过，返回true
   */
  public static validateWorkerFile(fileName: string): boolean {
    if (!fileName) {
      return false;
    } else {
      let reg = new RegExp(FileValidator.validWorkerFileName);
      return reg.test(fileName);
    }
  }
}