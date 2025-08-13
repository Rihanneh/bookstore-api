import type { User } from '@/entities/User';
import type { IUserData } from '../entities/user/IUserData';
import type { IBaseRepository } from './IBaseRepository';

export interface IUserRepository extends IBaseRepository<User, IUserData> {
  findByEmail(email: string): Promise<User | null>;
  findByUsername(username: string): Promise<User | null>;
}
