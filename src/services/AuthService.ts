import { RoleEnum } from '@/constants/enums/RoleEnum';
import { CreateUserDto } from '@/dtos/user/CreateUserDto';
import { User } from '@/entities/User';
import { ConflictErrorFactory } from '@/exceptions/ConflictErrorFactory';
import { UserErrorFactory } from '@/exceptions/entities/UserErrorFactory';
import { IUser } from '@/interfaces/entities/user/IUser';
import { IUserData } from '@/interfaces/entities/user/IUserData';
import { IUserRepository } from '@/interfaces/repositories/IUserRepository';
import { IPasswordHasher } from '@/interfaces/security/IPasswordHasher';
import { IAuthService } from '@/interfaces/services/IAuthService';

export class AuthService implements IAuthService {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly passwordHasher: IPasswordHasher
  ) {}

  async register(createUserDto: CreateUserDto): Promise<IUser> {
    try {
      // 1. Vérifications
      const existingEmail: User | null = await this.userRepository.findByEmail(createUserDto.email);
      if (existingEmail) {
        throw UserErrorFactory.emailExists(createUserDto.email);
      }

      const existingUsername: User | null = await this.userRepository.findByUsername(
        createUserDto.username
      );
      if (existingUsername) {
        throw ConflictErrorFactory.usernameExists(createUserDto.username);
      }

      // 2. Hash password
      const hashedPassword: string = await this.passwordHasher.hash(createUserDto.password);

      // 3. - Crée IUserData pour le repository
      const userData: IUserData = {
        id: '',
        email: createUserDto.email,
        username: createUserDto.username,
        hashedPassword: hashedPassword,
        role: RoleEnum.CUSTOMER,
        isActive: false,
        emailVerified: false,
        lastLoginAt: undefined
      };

      // 4.Repository prend IUserData, retourne User
      return await this.userRepository.create(userData);
    } catch (error) {
      // Si c'est déjà une ApiError, on la laisse passer
      if (error instanceof UserErrorFactory || error instanceof ConflictErrorFactory) {
        throw error;
      }
      // Sinon, on transforme l'erreur technique
      throw UserErrorFactory.creation(error instanceof Error ? error.message : 'Unknown error');
    }
  }
}
