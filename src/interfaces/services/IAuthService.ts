import { CreateUserDto } from '@/dtos/user/CreateUserDto';
import { IUser } from '../entities/user/IUser';

export interface IAuthService {
  register(createUserDto: CreateUserDto): Promise<IUser>;
  // login(email: string, password: string): Promise<IUser>;
  // logout(userId: string): Promise<void>;
  // refresh(refreshToken: string): Promise<void>;
}
