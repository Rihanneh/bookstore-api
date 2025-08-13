import { type CreateUserSchemaType, UserConstants } from '@/constants/zod/UserConstants';

export class CreateUserDto {
  public readonly email: string; // immuable
  public readonly password: string;
  public readonly username: string;

  constructor(data: unknown) {
    const validated: CreateUserSchemaType = UserConstants.validateCreateUser(data);

    this.email = validated.email;
    this.password = validated.password;
    this.username = validated.username;
  }
}
