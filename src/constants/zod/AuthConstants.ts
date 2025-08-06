// src/constants/zod/AuthConstants.ts
import { z } from 'zod';
import { UserConstants } from '@/constants/zod/UserConstants';

export class AuthConstants {
  // LOGIN SCHEMA
  public static readonly LOGIN_SCHEMA = z.object({
    email: UserConstants.EMAIL_SCHEMA,
    password: UserConstants.PASSWORD_SCHEMA
  });

  // REFRESH TOKEN SCHEMA
  public static readonly REFRESH_TOKEN_SCHEMA = z.object({
    refreshToken: z
      .string({ message: 'Refresh token requis' })
      .min(1, { message: 'Refresh token ne peut pas être vide' })
      .max(500, { message: 'Refresh token trop long' })
  });

  // LOGOUT SCHEMA
  public static readonly LOGOUT_SCHEMA = z.object({
    logoutAll: z.boolean().optional().default(false)
  });

  // AUTH RESPONSE SCHEMA
  public static readonly AUTH_RESPONSE_SCHEMA = z.object({
    accessToken: z
      .string({ message: '"Token d\'accès requis"' })
      .min(1, { message: '"Token d\'accès ne peut pas être vide"' }),
    refreshToken: z
      .string({ message: 'Token de rafraîchissement requis' })
      .min(1, { message: 'Token de rafraîchissement ne peut pas être vide' })
      .nullable(),
    user: z.object({
      id: UserConstants.ID_SCHEMA,
      email: UserConstants.EMAIL_SCHEMA,
      username: UserConstants.USERNAME_SCHEMA
    })
  });

  // VALIDATION METHODS
  public static validateLogin(data: unknown): LoginSchemaType {
    return AuthConstants.LOGIN_SCHEMA.parse(data);
  }

  public static validateRefreshToken(data: unknown): RefreshTokenSchemaType {
    return AuthConstants.REFRESH_TOKEN_SCHEMA.parse(data);
  }

  public static validateAuthResponse(data: unknown): AuthResponseSchemaType {
    return AuthConstants.AUTH_RESPONSE_SCHEMA.parse(data);
  }

  public static validateLogout(data: unknown): LogoutSchemaType {
    return AuthConstants.LOGOUT_SCHEMA.parse(data);
  }
}

// TYPES EXPORTÉS
export type LoginSchemaType = z.infer<typeof AuthConstants.LOGIN_SCHEMA>;
export type RefreshTokenSchemaType = z.infer<typeof AuthConstants.REFRESH_TOKEN_SCHEMA>;
export type LogoutSchemaType = z.infer<typeof AuthConstants.LOGOUT_SCHEMA>;
export type AuthResponseSchemaType = z.infer<typeof AuthConstants.AUTH_RESPONSE_SCHEMA>;
