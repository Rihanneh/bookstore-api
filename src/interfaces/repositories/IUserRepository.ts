import { User } from '@/entities/User';
import { IBaseRepository } from './IBaseRepository';
import { IUserData } from '../entities/user/IUserData';

export interface IUserRepository extends IBaseRepository<User, IUserData> {
  findByEmail(email: string): Promise<User | null>;
  findByUsername(username: string): Promise<User | null>;
}
