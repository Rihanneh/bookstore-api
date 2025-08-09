import { RoleEnum } from '@/constants/enums/RoleEnum';
import { ResponseUserSchemaType, UserConstants } from '@/constants/zod/UserConstants';
import { IUser } from '@/interfaces/entities/user/IUser';

export class ResponseUserDto {
  public readonly id: string;
  public readonly email: string;
  public readonly username: string;
  public readonly role: RoleEnum;

  constructor(data: unknown) {
    const validated: ResponseUserSchemaType = UserConstants.validateResponseUser(data);

    this.id = validated.id;
    this.email = validated.email;
    this.username = validated.username;
    this.role = validated.role as RoleEnum;
  }

  public static fromUser(user: IUser): ResponseUserDto {
    return new ResponseUserDto({
      id: user.getId(),
      email: user.getEmail(),
      username: user.getUsername(),
      role: user.getRole()
    });
  }
}
