import type { BaseEntity } from '@/entities/BaseEntity';

export interface IBaseRepository<T extends BaseEntity, TData = unknown> {
  findById(id: string): Promise<T | null>;
  // findAll(limit?: number, offset?: number): Promise<T[]>;
  create(data: TData): Promise<T>;
  // update(id: string, data: Partial<TData>): Promise<T>;
  // delete(id: string): Promise<boolean>;
  // count(): Promise<number>;
}
