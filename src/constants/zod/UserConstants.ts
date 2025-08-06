import { z } from 'zod';
import { RoleEnum } from '@/constants/enums/RoleEnum';

export class UserConstants {
  // ID AUTO_INCREMENT
  public static readonly ID_SCHEMA = z.string().min(1);

  // SCHEMAS DE BASE
  public static readonly EMAIL_SCHEMA = z
    .string()
    .regex(/^[^\s@]+@[^\s@]+\.[^\s@]+$/, '"Le format de l\'email est invalide"')
    .lowercase()
    .trim();

  public static readonly PASSWORD_SCHEMA = z
    .string()
    .min(8, 'Le mot de passe doit contenir au moins 8 caractères')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s])/,
      'Le mot de passe doit contenir une majuscule, une minuscule, un chiffre et un caractère spécial'
    );

  public static readonly USERNAME_SCHEMA = z
    .string()
    .min(3, '"Le nom d\'utilisateur doit contenir au moins 3 caractères"')
    .max(30, '"Le nom d\'utilisateur doit contenir au maximum 30 caractères"')
    .regex(
      /^\w+$/,
      '"Le nom d\'utilisateur ne peut contenir que des lettres, chiffres et underscore"'
    )
    .trim();

  // SCHEMAS COMPLETS
  public static readonly CREATE_USER_SCHEMA = z.object({
    email: UserConstants.EMAIL_SCHEMA,
    password: UserConstants.PASSWORD_SCHEMA,
    username: UserConstants.USERNAME_SCHEMA
  });

  public static readonly RESPONSE_USER_SCHEMA = z.object({
    id: UserConstants.ID_SCHEMA,
    email: UserConstants.EMAIL_SCHEMA,
    username: UserConstants.USERNAME_SCHEMA,
    role: z.enum(Object.values(RoleEnum) as [string, ...string[]])
  });

  // VALIDATIONS
  public static validateCreateUser(data: unknown): CreateUserSchemaType {
    return UserConstants.CREATE_USER_SCHEMA.parse(data);
  }

  public static validateResponseUser(data: unknown): ResponseUserSchemaType {
    return UserConstants.RESPONSE_USER_SCHEMA.parse(data);
  }
}

// TYPES
export type CreateUserSchemaType = z.infer<typeof UserConstants.CREATE_USER_SCHEMA>;
export type ResponseUserSchemaType = z.infer<typeof UserConstants.RESPONSE_USER_SCHEMA>;
