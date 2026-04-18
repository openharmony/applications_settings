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

export class Optional<T> {
  private readonly value: T;
  private static readonly EMPTY = new Optional(undefined);

  private constructor(value: T) {
    this.value = value;
  }

  public static empty<T>(): Optional<T> {
    let v = Optional.EMPTY as Optional<T>;
    return v;
  }

  public static of<T>(value: T): Optional<T> {
    return new Optional(value);
  }

  public static ofNullable<T>(value: T): Optional<T> {
    return Optional.isVaild(value) ? Optional.of(value) : Optional.empty();
  }

  private static isVaild(value): boolean {
    return !(value === undefined || value === null);
  }

  /*
   * @throw Error: if there is no value present
   */
  public get(): T {
    if (!Optional.isVaild(this.value)) {
      throw new Error('No value present');
    }
    return this.value;
  }

  public isPresent(): boolean {
    return Optional.isVaild(this.value);
  }

  public ifPresent(consumer: (value: T) => void): void {
    if (Optional.isVaild(this.value)) {
      consumer(this.value);
    }
  }

  public orElse(other: T): T {
    return Optional.isVaild(this.value) ? this.value : other;
  }
}