import { LoggerSingleton } from '@/configs/LoggerSingleton';
import { CreateUserDto } from '@/dtos/user/CreateUserDto';
import { ResponseUserDto } from '@/dtos/user/ResponseUserDto';
import { IAuthController } from '@/interfaces/controllers/IAuthController';
import { IUser } from '@/interfaces/entities/user/IUser';
import { IApiResponseData } from '@/interfaces/http/IApiResponseData';
import { IAuthService } from '@/interfaces/services/IAuthService';
import { ApiResponseFactory } from '@/utils/ApiResponseFactory';
import { RequestIdGenerator } from '@/utils/RequestIdGenerator';
import { Response, Request, NextFunction } from 'express';

export class AuthController implements IAuthController {
  private readonly authService: IAuthService;
  private readonly logger = LoggerSingleton.getInstance();

  constructor(authService: IAuthService) {
    this.authService = authService;
  }

  private getRequestId(req: Request): string {
    return RequestIdGenerator.getFromRequest(req);
  }

  public async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const requestId: string = this.getRequestId(req);
      const createUserDto = new CreateUserDto(req.body);

      this.logger.info('User registration attempt', {
        requestId,
        email: createUserDto.email,
        username: createUserDto.username,
        timestamp: new Date().toISOString(),
        operation: 'user_registration'
      });

      const user: IUser = await this.authService.register(createUserDto);
      const userResponse: ResponseUserDto = ResponseUserDto.fromUser(user);

      this.logger.info('User registration successful', {
        requestId,
        userId: userResponse.id,
        email: userResponse.email,
        timestamp: new Date().toISOString(),
        operation: 'user_registration_success'
      });

      const response: IApiResponseData<{ user: ResponseUserDto }> = ApiResponseFactory.success(
        'Inscription réussie. Veuillez vous connecter.',
        { user: userResponse },
        requestId
      );

      res.status(201).json(response);
    } catch (error) {
      this.logger.error('User registration failed', {
        requestId: this.getRequestId(req),
        email: req.body?.email,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
        operation: 'user_registration_failed'
      });

      next(error);
    }
  }
}
